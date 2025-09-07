USE GDiseno;

DROP PROCEDURE IF EXISTS producto_agregarUnidad;

DROP PROCEDURE IF EXISTS producto_agregarPack;

DROP PROCEDURE IF EXISTS producto_borrar;

DROP PROCEDURE IF EXISTS producto_modificarSKU;

DROP PROCEDURE IF EXISTS producto_modificarNombre;

DROP PROCEDURE IF EXISTS producto_modificarPrecio;

DROP PROCEDURE IF EXISTS producto_modificarUnidades;

DROP PROCEDURE IF EXISTS producto_modificarProductoReferencia;

DROP PROCEDURE IF EXISTS producto_listar;

DROP PROCEDURE IF EXISTS producto_listarUnitarios;

DROP PROCEDURE IF EXISTS producto_mostrarDatos;

DROP PROCEDURE IF EXISTS producto_actualizarDescuentos;

DROP PROCEDURE IF EXISTS producto_buscarNombre;

DELIMITER $$

CREATE PROCEDURE producto_agregarUnidad (
	IN p_sku VARCHAR(20),
	IN p_nombre VARCHAR(100),
	IN p_precio DECIMAL(10, 2),
	IN p_idModelo INT,
	IN p_idColor INT,
	IN p_idMedida INT
)
BEGIN
	IF p_sku IS NOT NULL AND EXISTS (SELECT 1 FROM producto WHERE SKU = p_sku)
	THEN
		SET @mensaje := CONCAT('Ya existe un producto con el SKU ', p_sku, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSEIF EXISTS (SELECT 1 FROM producto WHERE nombre = p_nombre)
	THEN
		SET @mensaje := CONCAT('Ya existe un producto con el nombre ', p_nombre, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSE
		INSERT INTO producto (
			SKU,
			nombre,
			precio,
			unidades,
			idModelo,
			idColor,
			idMedida,
			idProductoReferencia
		)
		VALUES (
			p_sku,
			p_nombre,
			p_precio,
			1,
			p_idModelo,
			p_idColor,
			p_idMedida,
			NULL
		);
	END IF;
END$$

CREATE PROCEDURE producto_agregarPack(
	IN p_sku VARCHAR(20),
	IN p_nombre VARCHAR(100),
	IN p_unidades INT,
	IN p_idProductoReferencia INT
)
BEGIN
	DECLARE v_precio_unitario DECIMAL(10, 2);
	DECLARE v_descuento DECIMAL(5, 2);
	DECLARE v_idModelo INT;
	DECLARE v_idMedida INT;
	DECLARE v_idColor INT;
	
	IF p_sku IS NOT NULL AND EXISTS (SELECT 1 FROM producto WHERE SKU = p_sku)
	THEN
		SET @mensaje := CONCAT('Ya existe un producto con el SKU ', p_sku, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSEIF EXISTS (SELECT 1 FROM producto WHERE nombre = p_nombre)
	THEN
		SET @mensaje := CONCAT('Ya existe un producto con el nombre ', p_nombre, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSEIF (p_unidades <= 1)
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad de unidades debe ser mayor a 1.';
	ELSEIF NOT EXISTS (SELECT 1 FROM producto WHERE idProducto = p_idProductoReferencia)
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto de referencia no existe.';
	ELSE
		SET v_descuento = (
			SELECT descuento
			FROM descuento_por_cantidad
			WHERE cantidadMinima <= p_unidades
			ORDER BY cantidadMinima DESC
			LIMIT 1
		);
		SET v_precio_unitario = (
			SELECT precio
			FROM producto
			WHERE idProducto = p_idProductoReferencia
		);
		SELECT
			idModelo,
			idMedida,
			idColor
		INTO
			v_idModelo,
			v_idMedida,
			v_idColor
		FROM producto
		WHERE idProducto = p_idProductoReferencia;
		
		INSERT INTO producto (
			SKU,
			nombre,
			precio,
			unidades,
			idModelo,
			idColor,
			idMedida,
			idProductoReferencia
		)
		VALUES (
			p_sku,
			p_nombre,
			p_unidades * (v_precio_unitario * (1 - (v_descuento / 100))),
			p_unidades,
			v_idModelo,
			v_idColor,
			v_idMedida,
			p_idProductoReferencia
		);
	END IF;
END$$

CREATE PROCEDURE producto_borrar (
	IN p_id INT
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM producto WHERE idProducto = p_id)
	THEN
		SET @mensaje := CONCAT('No existe el id ', p_id, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSEIF EXISTS (SELECT 1 FROM producto WHERE idProductoReferencia = p_id)
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto es referencia de otros productos.';
	ELSE
		DELETE FROM producto
		WHERE idProducto = p_id;
	END IF;
END$$

CREATE PROCEDURE producto_modificarSKU (
	IN p_id INT,
	IN p_sku VARCHAR(20)
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM producto WHERE idProducto = p_id)
	THEN
		SET @mensaje := CONCAT('No existe el id ', p_id, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSE
		UPDATE producto
		SET SKU = p_sku
		WHERE idProducto = p_id;
	END IF;
END$$

CREATE PROCEDURE producto_modificarNombre (
	IN p_id INT,
	IN p_nombre VARCHAR(100)
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM producto WHERE idProducto = p_id)
	THEN
		SET @mensaje := CONCAT('No existe el id ', p_id, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSE
		UPDATE producto
		SET nombre = p_nombre
		WHERE idProducto = p_id;
	END IF;
END$$

CREATE PROCEDURE producto_modificarPrecio (
	IN p_id INT,
	IN p_precio DECIMAL(10, 2)
)
BEGIN
	DECLARE v_idActual INT;
	DECLARE v_unidadesActual INT;
	DECLARE v_descuento DECIMAL(5, 2);
	DECLARE v_precioUnitario DECIMAL(10 ,2);
	DECLARE v_productoReferencia INT;
	SET v_productoReferencia = (
		SELECT idProductoReferencia
		FROM producto
		WHERE idProducto = p_id
	);

	IF NOT EXISTS (SELECT 1 FROM producto WHERE idProducto = p_id)
	THEN
		SET @mensaje := CONCAT('No existe el id ', p_id, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSEIF (v_productoReferencia IS NOT NULL)
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se puede cambiar el precio a productos unitarios.';
	ELSE
		UPDATE producto
		SET precio = p_precio
		WHERE idProducto = p_id;
		
		CREATE TEMPORARY TABLE temp_producto AS
		SELECT idProducto
		FROM producto
		WHERE idProductoReferencia = p_id;
				
		SET v_precioUnitario = (
			SELECT precio
			FROM producto
			WHERE idProducto = p_id
		);
		
		SELECT MIN(idProducto)
		INTO v_idActual
		FROM temp_producto;
		
		WHILE v_idActual IS NOT NULL
		DO
			SET v_unidadesActual = (
				SELECT unidades
				FROM producto
				WHERE idProducto = v_idActual
			);
		
			SET v_descuento = (
				SELECT descuento
				FROM descuento_por_cantidad
				WHERE cantidadMinima <= v_unidadesActual
				ORDER BY cantidadMinima DESC
				LIMIT 1
			);
		
			UPDATE producto
			SET precio = v_unidadesActual * (v_precioUnitario * (1 - (v_descuento / 100)))
			WHERE idProducto = v_idActual;
			
			SELECT MIN(idProducto)
			INTO v_idActual
			FROM temp_producto
			WHERE idProducto > v_idActual;
		END WHILE;
			
		DROP TEMPORARY TABLE temp_producto;
	END IF;
END$$

CREATE PROCEDURE producto_modificarUnidades (
	IN p_id INT,
	IN p_unidades INT
)
BEGIN
	DECLARE v_descuento DECIMAL(5, 2);
	DECLARE v_precioUnitario DECIMAL(10, 2);
	DECLARE v_idProductoReferencia INT;
	SET v_idProductoReferencia = (
		SELECT idProductoReferencia
		FROM producto
		WHERE idProducto = p_id
	);

	IF (p_unidades <= 0)
	THEN
		SET @mensaje := CONCAT('El numero de unidades no puede ser menor a 1.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSEIF NOT EXISTS (SELECT 1 FROM producto WHERE idProducto = p_id)
	THEN
		SET @mensaje := CONCAT('No existe el id ', p_id, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSEIF (v_idProductoReferencia IS NULL)
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pueden modificar las unidades de un producto unitario.';
	ELSE
		SET v_descuento = (
			SELECT descuento
			FROM descuento_por_cantidad
			WHERE cantidadMinima <= p_unidades
			ORDER BY cantidadMinima DESC
			LIMIT 1
		);
		
		SET v_precioUnitario = (
			SELECT precio
			FROM producto
			WHERE idProducto = v_idProductoReferencia
		);
		
		UPDATE producto
		SET
			unidades = p_unidades,
			precio = p_unidades * (v_precioUnitario * (1 - (v_descuento / 100)))
		WHERE idProducto = p_id;
	END IF;
END$$

CREATE PROCEDURE producto_modificarProductoReferencia(
	IN p_id INT,
	IN p_idProductoReferencia INT
)
BEGIN
	DECLARE v_descuento DECIMAL(5, 2);
	DECLARE v_precioUnitario DECIMAL(10, 2);
	DECLARE v_idProductoReferencia INT;
	DECLARE v_idProductoReferenciaProducto INT;
	DECLARE v_unidades INT;
	SET v_idProductoReferencia = (
		SELECT idProducto
		FROM producto
		WHERE idProducto = p_idProductoReferencia
	);
	
	SET v_idProductoReferenciaProducto = (
		SELECT idProductoReferencia
		FROM producto
		WHERE idProducto = p_id
	);

	IF NOT EXISTS (SELECT 1 FROM producto WHERE idProducto = p_id)
	THEN
		SET @mensaje := CONCAT('No existe el id ', p_id, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSEIF NOT EXISTS (SELECT 1 FROM producto WHERE idProducto = p_idProductoReferencia)
	THEN
		SET @mensaje := CONCAT('No existe el id referencia ', p_idProductoReferencia, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSEIF (v_idProductoReferenciaProducto IS NULL)
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto a modificar no puede ser unitario.';
	ELSEIF (v_idProductoReferencia IS NOT NULL)
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto referencia debe ser unitario.';
	ELSEIF (p_id = p_idProductoReferencia)
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto no puede hacer referencia a si mismo.';
	ELSE
		SET v_unidades = (
			SELECT unidades
			FROM producto
			WHERE idProducto = p_id
		);
		
		SET v_descuento = (
			SELECT descuento
			FROM descuento_por_cantidad
			WHERE cantidadMinima <= v_unidades
			ORDER BY cantidadMinima DESC
			LIMIT 1
		);
		
		SET v_precioUnitario = (
			SELECT precio
			FROM producto
			WHERE idProducto = v_idProductoReferencia
		);
		
		UPDATE producto
		SET
			precio = v_unidades * (v_precioUnitario * (1 - (v_descuento / 100))),
			idProductoReferencia = p_idProductoReferencia
		WHERE idProducto = p_id;
	END IF;
END$$

CREATE PROCEDURE producto_listar ()
BEGIN
	SELECT
		p1.SKU,
		p1.nombre,
		p1.precio,
		p1.unidades,
		modelo.nombre AS 'modelo',
		color.nombre AS 'color',
		medida.numero AS 'medida',
		IFNULL(p2.nombre, 'Sin referencia') AS 'referencia'
	FROM producto AS p1
		INNER JOIN modelo
		ON p1.idModelo = modelo.idModelo
		INNER JOIN color
		ON p1.idColor = color.idColor
		INNER JOIN medida
		ON p1.idMedida = medida.idMedida
		LEFT JOIN producto AS p2
		ON p1.idProductoReferencia = p2.idProducto
	ORDER BY p1.nombre;
END$$

CREATE PROCEDURE producto_listarUnitarios ()
BEGIN
	SELECT
		producto.idProducto,
		IFNULL(producto.SKU, 'N/D') AS SKU,
		producto.nombre,
		producto.idModelo
	FROM producto
	WHERE producto.idProductoReferencia IS NULL
	ORDER BY producto.nombre;
END$$

CREATE PROCEDURE producto_mostrarDatos (
	IN p_id INT
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM producto WHERE idProducto = p_id)
	THEN
		SET @mensaje := CONCAT('No existe el id ', p_id, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSE
		SELECT
			producto.SKU,
			producto.nombre,
			producto.precio,
			producto.unidades,
			modelo.nombre AS 'modelo',
			color.nombre AS 'color',
			medida.numero AS 'medida'
		FROM producto
			INNER JOIN modelo
			ON producto.idModelo = modelo.idModelo
			INNER JOIN color
			ON producto.idColor = color.idColor
			INNER JOIN medida
			ON producto.idMedida = medida.idMedida
		WHERE producto.idProducto = p_id;
	END IF;
END$$

CREATE PROCEDURE producto_actualizarDescuentos ()
BEGIN
	DECLARE v_idUnitarioActual INT;
	DECLARE v_idPackActual INT;
	DECLARE v_precioActual DECIMAL(10, 2);
	DECLARE v_unidadesActual INT;
	DECLARE v_descuentoActual DECIMAL(5, 2);
	
	CREATE TEMPORARY TABLE temp_unitario AS
	SELECT idProducto
	FROM producto
	WHERE idProductoReferencia IS NULL;
	
	SET v_idUnitarioActual = (
		SELECT MIN(idProducto)
		FROM temp_unitario
	);
	
	WHILE v_idUnitarioActual IS NOT NULL
	DO
		SET v_precioActual = (
			SELECT precio
			FROM producto
			WHERE idProducto = v_idUnitarioActual
		);
	
		CREATE TEMPORARY TABLE temp_packActual AS
		SELECT idProducto
		FROM producto
		WHERE idProductoReferencia = v_idUnitarioActual;
		
		SET v_idPackActual = (
			SELECT MIN(idProducto)
			FROM temp_packActual
		);
		
		WHILE v_idPackActual IS NOT NULL
		DO
			SET v_unidadesActual = (
				SELECT unidades
				FROM producto
				WHERE idProducto = v_idPackActual
			);
			
			SET v_descuentoActual = (
				SELECT descuento
				FROM descuento_por_cantidad
				WHERE cantidadMinima <= v_unidadesActual
				ORDER BY cantidadMinima DESC
				LIMIT 1
			);
			
			UPDATE producto
			SET precio = v_unidadesActual * (v_precioActual * (1 - v_descuentoActual / 100))
			WHERE idProducto = v_idPackActual;
			
			SET v_idPackActual = (
				SELECT MIN(idProducto)
				FROM temp_packActual
				WHERE idProducto > v_idPackActual
			);
		END WHILE;
		
		SET v_idUnitarioActual = (
			SELECT MIN(idProducto)
			FROM temp_unitario
			WHERE idProducto > v_idUnitarioActual
		);
		
		DROP TEMPORARY TABLE temp_packActual;
	END WHILE;
	
	DROP TEMPORARY TABLE temp_unitario;
END$$

CREATE PROCEDURE producto_buscarNombre (
	IN p_busqueda VARCHAR(100)
)
BEGIN
	SELECT
		p1.SKU,
		p1.nombre,
		p1.precio,
		p1.unidades,
		modelo.nombre AS 'modelo',
		color.nombre AS 'color',
		medida.numero AS 'medida',
		IFNULL(p2.nombre, 'Sin referencia') AS 'referencia'
	FROM producto AS p1
		INNER JOIN modelo
		ON p1.idModelo = modelo.idModelo
		INNER JOIN color
		ON p1.idColor = color.idColor
		INNER JOIN medida
		ON p1.idMedida = medida.idMedida
		LEFT JOIN producto AS p2
		ON p1.idProductoReferencia = p2.idProducto
	WHERE p1.nombre LIKE p_busqueda ESCAPE '\\'
	ORDER BY p1.nombre;
	-- la busqueda no incluye los % para evitar sql injection
	-- en el backend el argumento que le mando le agrega los % al principio y al final
END$$

DELIMITER ;

USE GDiseno;

DROP PROCEDURE IF EXISTS descuento_por_cantidad_agregar;

DROP PROCEDURE IF EXISTS descuento_por_cantidad_borrar;

DROP PROCEDURE IF EXISTS descuento_por_cantidad_modificarDescuento;

DROP PROCEDURE IF EXISTS descuento_por_cantidad_listar;

DROP PROCEDURE IF EXISTS descuento_por_cantidad_mostrar;

DELIMITER $$

CREATE PROCEDURE descuento_por_cantidad_agregar(
	IN p_cantidadMinima INT,
	IN p_descuento DECIMAL(5, 2)
)
BEGIN
	IF EXISTS (SELECT 1 FROM descuento_por_cantidad WHERE cantidadMinima = p_cantidadMinima)
	THEN
		SET @mensaje := CONCAT('Ya existe un descuento con la cantidad minima ', p_cantidadMinima, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSE
		INSERT INTO descuento_por_cantidad (
			cantidadMinima,
			descuento
		)
		VALUES (
			p_cantidadMinima,
			p_descuento
		);
	END IF;
END$$

CREATE PROCEDURE descuento_por_cantidad_borrar (
	IN p_id INT
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM descuento_por_cantidad WHERE idDescuento = p_id)
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe ese descuento';
	ELSE
		DELETE FROM descuento_por_cantidad
		WHERE idDescuento = p_id;
	END IF;
END$$

CREATE PROCEDURE descuento_por_cantidad_modificarDescuento (
	IN p_id INT,
	IN p_descuento DECIMAL(5, 2)
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM descuento_por_cantidad WHERE idDescuento = p_id)
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe ese descuento';
	ELSE
		UPDATE descuento_por_cantidad
		SET descuento = p_descuento
		WHERE idDescuento = p_id;
	END IF;
END$$

CREATE PROCEDURE descuento_por_cantidad_listar ()
BEGIN
	SELECT
		idDescuento,
		cantidadMinima,
		descuento
	FROM descuento_por_cantidad;
END$$

CREATE PROCEDURE descuento_por_cantidad_mostrar (
	IN p_id INT
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM descuento_por_cantidad WHERE idDescuento = p_id)
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe ese descuento';
	ELSE
		SELECT
			cantidadMinima,
			descuento
		FROM descuento_por_cantidad
		WHERE idDescuento = p_id;
	END IF;
END$$
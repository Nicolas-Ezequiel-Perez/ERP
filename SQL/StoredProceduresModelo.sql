USE GDiseno;

DROP PROCEDURE IF EXISTS modelo_agregar;

DROP PROCEDURE IF EXISTS modelo_borrar;

DROP PROCEDURE IF EXISTS modelo_modificarNombre;

DROP PROCEDURE IF EXISTS modelo_modificarRubro;

DROP PROCEDURE IF EXISTS modelo_listar;

DROP PROCEDURE IF EXISTS modelo_listarId;

DROP PROCEDURE IF EXISTS modelo_listarIdRubro;

DROP PROCEDURE IF EXISTS modelo_mostrar;

DELIMITER $$

CREATE PROCEDURE modelo_agregar (
	IN p_nombre VARCHAR(50),
	IN p_idRubro INT
)
BEGIN
	INSERT INTO modelo (
		nombre,
		idRubro
	)
	VALUES (
		p_nombre,
		p_idRubro
	);
	SELECT LAST_INSERT_ID() AS 'idNuevo';
END$$

CREATE PROCEDURE modelo_borrar (
	IN p_id INT
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM modelo WHERE idModelo = p_id)
	THEN
		SET @mensaje := CONCAT('No existe modelo con el id ', p_id, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSE
		DELETE FROM modelo
		WHERE idModelo = p_id;
	END IF;
END$$

CREATE PROCEDURE modelo_modificarNombre (
	IN p_id INT,
	IN p_nombre VARCHAR(50)
)
BEGIN
	IF EXISTS (SELECT 1 FROM modelo WHERE nombre = p_nombre)
	THEN
		SET @mensaje := CONCAT('Ya existe el modelo ', p_nombre, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSE
		UPDATE modelo
		SET nombre = p_nombre
		WHERE idModelo = p_id;
	END IF;
END$$

CREATE PROCEDURE modelo_modificarRubro (
	IN p_id INT,
	IN p_idRubro INT
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM modelo WHERE idModelo = p_id)
	THEN
		SET @mensaje := CONCAT('No existe modelo con el id ', p_id, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSE
		UPDATE modelo
		SET idRubro = p_idRubro
		WHERE idModelo = p_id;
	END IF;
END$$

CREATE PROCEDURE modelo_listar ()
BEGIN
	SELECT
		modelo.nombre,
		r1.nombre
	FROM modelo
		INNER JOIN rubro AS r1
		ON r1.idRubro = modelo.idRubro;
END$$

CREATE PROCEDURE modelo_listarId ()
BEGIN
	SELECT
		modelo.idModelo,
		modelo.nombre
	FROM modelo;
END$$

CREATE PROCEDURE modelo_listarIdRubro ()
BEGIN
	SELECT
		modelo.idModelo,
		modelo.nombre,
		r1.nombre AS 'rubro'
	FROM modelo
		INNER JOIN rubro AS r1
		ON r1.idRubro = modelo.idRubro;
END$$

CREATE PROCEDURE modelo_mostrar(
	IN p_id INT
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM modelo WHERE idModelo = p_id)
	THEN
		SET @mensaje := CONCAT('No existe modelo con el id ', p_id, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSE
		SELECT
			modelo.idModelo,
			modelo.nombre,
			modelo.idRubro,
			r1.nombre
		FROM modelo
			INNER JOIN rubro AS r1
			ON r1.idRubro = modelo.idRubro
		WHERE idModelo = p_id;
	 END IF;
END$$

DELIMITER ;
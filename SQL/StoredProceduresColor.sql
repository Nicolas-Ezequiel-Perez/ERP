USE GDiseno;

DROP PROCEDURE IF EXISTS color_agregar;

DROP PROCEDURE IF EXISTS color_borrar;

DROP PROCEDURE IF EXISTS color_modificar;

DROP PROCEDURE IF EXISTS color_listar;

DROP PROCEDURE IF EXISTS color_mostrarNombre;

DELIMITER $$

CREATE PROCEDURE color_agregar (
	IN p_nombre VARCHAR(50)
)
BEGIN
	IF EXISTS (SELECT 1 FROM color WHERE nombre = p_nombre)
	THEN
		SET @mensaje := CONCAT('Error: El color ', p_nombre, ' ya existe.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSE
		INSERT INTO color (
			nombre
		)
		VALUES (
			p_nombre
		);
	END IF;
END$$

CREATE PROCEDURE color_borrar (
	IN p_id INT
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM color WHERE idColor = p_id)
	THEN
		SET @mensaje := CONCAT('Error: El id ', p_id, ' no existe');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSE
		DELETE FROM color
		WHERE idColor = p_id;
	END IF;
END$$

CREATE PROCEDURE color_modificar (
	IN p_id INT,
	IN p_nombre VARCHAR(50)
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM color WHERE idColor = p_id)
	THEN
		SET @mensaje := CONCAT('Error: El id ', p_id, ' no existe.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSEIF EXISTS (SELECT 1 FROM color WHERE nombre = p_nombre)
	THEN
		SET @mensaje := CONCAT('Error: El color ', p_nombre, ' ya existe.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSE
		UPDATE color
		SET nombre = p_nombre
		WHERE idColor = p_id;
	END IF;
END$$

CREATE PROCEDURE color_listar ()
BEGIN
	SELECT * FROM color;
END$$

CREATE PROCEDURE color_mostrarNombre(
	IN p_id INT
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM color WHERE idColor = p_id)
	THEN
		SET @mensaje := CONCAT('Error: El id ', p_id, ' no existe');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSE
		SELECT nombre FROM color WHERE idColor = p_id;
	END IF;
END$$

DELIMITER ;
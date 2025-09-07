USE GDiseno;

DROP PROCEDURE IF EXISTS puede_ser_color_agregar;

DROP PROCEDURE IF EXISTS puede_ser_color_borrar;

DROP PROCEDURE IF EXISTS puede_ser_color_listar;

DROP PROCEDURE IF EXISTS puede_ser_color_listarColores;

DROP PROCEDURE IF EXISTS puede_ser_color_listarModelos;

DROP PROCEDURE IF EXISTS puede_ser_color_mostrar;

DELIMITER $$

CREATE PROCEDURE puede_ser_color_agregar (
	IN p_idModelo INT,
	IN p_idColor INT
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM modelo WHERE idModelo = p_idModelo)
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el modelo indicado.';
	ELSEIF NOT EXISTS (SELECT 1 FROM color WHERE idColor =p_idColor)
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el color indicado.';
	ELSEIF EXISTS (SELECT 1 FROM puede_ser_color WHERE idModelo = p_idModelo AND idColor = p_idColor)
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe la relacion entre ese modelo y ese color.';
	ELSE
		INSERT INTO puede_ser_color (
			idModelo,
			idColor
		)
		VALUES (
			p_idModelo,
			p_idColor
		);
	END IF;
END$$

CREATE PROCEDURE puede_ser_color_borrar (
	IN p_id INT
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM puede_ser_color WHERE idPuedeSerColor = p_id)
	THEN
		SET @mensaje := CONCAT('No existe el id ', p_id, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSE
		DELETE FROM puede_ser_color
		WHERE idPuedeSerColor = p_id;
	END IF;
END$$

CREATE PROCEDURE puede_ser_color_listar ()
BEGIN
	SELECT
		puede_ser_color.idPuedeSerColor,
		puede_ser_color.idModelo,
		modelo.nombre,
		puede_ser_color.idColor,
		color.nombre
	FROM puede_ser_color
		INNER JOIN color
		ON puede_ser_color.idColor = color.idColor
		INNER JOIN modelo
		ON puede_ser_color.idModelo = modelo.idModelo;
END$$

CREATE PROCEDURE puede_ser_color_listarColores(
	IN p_idModelo INT
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM puede_ser_color WHERE idModelo = p_idModelo)
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese modelo no tiene asignado ningun color';
	ELSE
		SELECT
			color.idColor,
			color.nombre
		FROM puede_ser_color
			INNER JOIN color
			ON puede_ser_color.idColor = color.idColor
		WHERE puede_ser_color.idModelo = p_idModelo;
	END IF;
END$$

CREATE PROCEDURE puede_ser_color_listarModelos(
	IN p_idColor INT
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM puede_ser_color WHERE idColor = p_idColor)
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese color no tiene ningun modelo asignado';
	ELSE
		SELECT
			modelo.idModelo,
			modelo.nombre
		FROM puede_ser_color
			INNER JOIN modelo
			ON puede_ser_color.idModelo = modelo.idModelo
		WHERE puede_ser_color.idColor = p_idColor;
	END IF;
END$$

CREATE PROCEDURE puede_ser_color_mostrar (
	IN p_id INT
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM puede_ser_color WHERE idPuedeSerColor = p_id)
	THEN
		SET @mensaje := CONCAT('No existe el id ', p_id, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSE
		SELECT
			modelo.idModelo,
			modelo.nombre,
			color.idColor,
			color.nombre
		FROM puede_ser_color
			INNER JOIN modelo
			ON puede_ser_color.idModelo = modelo.idModelo
			INNER JOIN color
			ON puede_ser_color.idColor = color.idColor
		WHERE puede_ser_color.idPuedeSerColor = p_id;
	END IF;
END$$
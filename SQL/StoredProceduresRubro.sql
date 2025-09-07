USE GDiseno;

DROP PROCEDURE IF EXISTS rubro_agregar;

DROP PROCEDURE IF EXISTS rubro_borrar;

DROP PROCEDURE IF EXISTS rubro_modificarNombre;

DROP PROCEDURE IF EXISTS rubro_listar;

DROP PROCEDURE IF EXISTS rubro_listarId;

DROP PROCEDURE IF EXISTS rubro_mostrar;

DELIMITER $$

CREATE PROCEDURE rubro_agregar (
	IN p_nombre VARCHAR(50),
	IN p_idPadre INT
)
BEGIN
	INSERT INTO rubro (
		nombre,
		idRubroPadre
	)
	VALUES (
		p_nombre,
		p_idPadre
	);
	
	SELECT LAST_INSERT_ID() AS 'idNuevo';
END$$

CREATE PROCEDURE rubro_borrar (
	IN p_id INT
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM rubro WHERE idRubro = p_id)
	THEN
		SET @mensaje := CONCAT('Error: El id ', p_id, ' no existe');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSEIF EXISTS (SELECT 1 FROM rubro WHERE idRubroPadre = p_id)
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El rubro que se intento borrar tiene sub rubros.';
	ELSE
		DELETE FROM rubro
		WHERE idRubro = p_id;
	END IF;
END$$

CREATE PROCEDURE rubro_modificarNombre (
	IN p_id INT,
	IN p_nombre VARCHAR(50)
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM rubro WHERE idRubro = p_id)
	THEN
		SET @mensaje := CONCAT('Error: El id ', p_id, ' no existe.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSEIF EXISTS (SELECT 1 FROM rubro WHERE nombre = p_nombre)
	THEN
		SET @mensaje := CONCAT('Error: El rubro ', p_nombre, ' ya existe.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSE
		UPDATE rubro
		SET nombre = p_nombre
		WHERE idRubro = p_id;
	END IF;
END$$

CREATE PROCEDURE rubro_listar ()
BEGIN
	SELECT r1.nombre
	FROM rubro AS r1;
END$$

CREATE PROCEDURE rubro_listarId ()
BEGIN
	SELECT
		r1.idRubro,
		r1.nombre
	FROM rubro AS r1;
END$$

CREATE PROCEDURE rubro_mostrar (
	IN p_id INT
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM rubro WHERE idRubro = p_id)
	THEN
		SET @mensaje := CONCAT('Error: El id ', p_id, ' no existe');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSE
		SELECT
			r1.idRubro,
			r1.nombre,
			r1.idRubroPadre,
			r2.nombre
		FROM rubro AS r1
			LEFT JOIN rubro AS r2
			ON r1.idRubroPadre = r2.idRubro
		WHERE r1.idRubro = p_id;
	END IF;
END$$

DELIMITER ;
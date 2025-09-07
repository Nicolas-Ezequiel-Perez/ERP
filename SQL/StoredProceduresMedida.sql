USE GDiseno;

DROP PROCEDURE IF EXISTS medida_agregar;

DROP PROCEDURE IF EXISTS medida_borrar;

DROP PROCEDURE IF EXISTS medida_modificarNumero;

DROP PROCEDURE IF EXISTS medida_listar;

DROP PROCEDURE IF EXISTS medida_listarPorModelo;

DROP PROCEDURE IF EXISTS medida_mostrar;

DELIMITER $$

CREATE PROCEDURE medida_agregar (
	IN p_numero DECIMAL(4, 2),
	IN p_idModelo INT
)
BEGIN
	IF EXISTS (SELECT 1 FROM medida WHERE numero = p_numero AND idModelo = p_idModelo)
	THEN
		SET @mensaje := CONCAT('Error: Ya existe la medida ', p_numero, 'para ese modelo.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSE
		INSERT INTO medida (
			numero,
			idModelo
		)
		VALUES (
			p_numero,
			p_idModelo
		);
	END IF;
END$$

CREATE PROCEDURE medida_borrar (
	IN p_id INT
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM medida WHERE idMedida = p_id)
	THEN
		SET @mensaje := CONCAT('Error: No existe medida con el id ', p_id, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSE
		DELETE FROM medida
		WHERE idMedida = p_id;
	END IF;
END$$

CREATE PROCEDURE medida_modificarNumero (
	IN p_id INT,
	IN p_numero DECIMAL(4, 2)
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM medida WHERE idMedida = p_id)
	THEN
		SET @mensaje := CONCAT('Error: No existe medida con el id ', p_id, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSEIF EXISTS (
		SELECT 1 FROM medida
		WHERE numero = p_numero
			AND idModelo = (
				SELECT idModelo FROM medida
				WHERE idMedida = p_id))
	THEN
		SET @mensaje := CONCAT('Error: Ya existe la medida ', p_numero, ' para ese modelo.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSE
		UPDATE medida
		SET numero = p_numero
		WHERE idMedida = p_id;
	END IF;
END$$

CREATE PROCEDURE medida_listar ()
BEGIN
	SELECT
		medida.idMedida,
		medida.numero,
		modelo.idModelo,
		modelo.nombre
	FROM medida
		INNER JOIN modelo
		ON medida.idModelo = modelo.idModelo;
END$$

CREATE PROCEDURE medida_listarPorModelo (
	IN p_idModelo INT
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM medida WHERE idModelo = p_idModelo)
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese modelo no tiene asignado ninguna medida';
	ELSE
		SELECT
			medida.idMedida,
			medida.numero
		FROM medida
		WHERE medida.idModelo = p_idModelo;
	END IF;
END$$

CREATE PROCEDURE medida_mostrar (
	IN p_id INT
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM medida WHERE idMedida = p_id)
	THEN
		SET @mensaje := CONCAT('Error: No existe medida con el id ', p_id, '.');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @mensaje;
	ELSE
		SELECT
			medida.numero,
			modelo.idModelo,
			modelo.nombre
		FROM medida
			INNER JOIN modelo
			ON medida.idModelo = modelo.idModelo
		WHERE medida.idMedida = p_id;
	END IF;

END$$

DELIMITER ;
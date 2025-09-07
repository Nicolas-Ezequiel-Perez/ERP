USE GDiseno;

DROP TABLE IF EXISTS puede_ser_color;

DROP TABLE IF EXISTS Producto;

DROP TABLE IF EXISTS Color;

DROP TABLE IF EXISTS Medida;

DROP TABLE IF EXISTS Modelo;

DROP TABLE IF EXISTS rubro;

DROP TABLE IF EXISTS descuento_por_cantidad;

CREATE TABLE Rubro (
	idRubro INT AUTO_INCREMENT,
	nombre VARCHAR(50) NOT NULL UNIQUE,
	idRubroPadre INT,
	PRIMARY KEY (idRubro),
	FOREIGN KEY (idRubroPadre)
	REFERENCES rubro (idRubro),
	INDEX idx_rubro(nombre),
	INDEX idx_padre(idRubroPadre)
);

CREATE TABLE Modelo (
	idModelo INT AUTO_INCREMENT,
	nombre VARCHAR(50) UNIQUE,
	idRubro INT	NOT NULL,
	PRIMARY KEY (idModelo),
	FOREIGN KEY (idRubro)
	REFERENCES Rubro (idRubro),
	INDEX idx_modelo (nombre)
);

CREATE TABLE Medida (
	idMedida INT AUTO_INCREMENT,
	numero DECIMAL(4, 2) NOT NULL,
	idModelo INT NOT NULL,
	PRIMARY KEY (idMedida),
	FOREIGN KEY (idModelo)
	REFERENCES Modelo (idModelo)
);

CREATE TABLE Color (
	idColor INT AUTO_INCREMENT,
	nombre VARCHAR(50) NOT NULL,
	PRIMARY KEY (idColor),
	INDEX idx_color (nombre)
);

CREATE TABLE Producto (
	idProducto INT AUTO_INCREMENT,
	SKU VARCHAR(20),
	nombre VARCHAR(100) NOT NULL,
	precio DECIMAL(10, 2) NOT NULL,
	unidades INT NOT NULL,
	idModelo INT NOT NULL,
	idColor INT NOT NULL,
	idMedida INT NOT NULL,
	idProductoReferencia INT,
	PRIMARY KEY (idProducto),
	FOREIGN KEY (idModelo)
	REFERENCES Modelo (idModelo),
	FOREIGN KEY (idColor)
	REFERENCES Color (idColor),
	FOREIGN KEY (idMedida)
	REFERENCES Medida (idMedida),
	FOREIGN KEY (idProductoReferencia)
	REFERENCES producto (idProducto),
	INDEX idx_sku (SKU),
	INDEX idx_nombre (nombre)
);

CREATE TABLE puede_ser_color (
	idPuedeSerColor INT AUTO_INCREMENT,
	idModelo INT NOT NULL,
	idColor INT NOT NULL,
	PRIMARY KEY (idPuedeSerColor),
	FOREIGN KEY (idModelo)
	REFERENCES modelo (idModelo),
	FOREIGN KEY (idColor)
	REFERENCES color (idColor)
);

CREATE INDEX idx_color_modelo
ON puede_ser_color (idModelo, idColor);

CREATE TABLE descuento_por_cantidad (
	idDescuento INT AUTO_INCREMENT,
	cantidadMinima INT NOT NULL,
	descuento DECIMAL(5, 2) NOT NULL,
	PRIMARY KEY (idDescuento),
	INDEX idx_cantidadMinima (cantidadMinima)
);

-- hasta aca es para la primera parte, lo extendere cuando agrege el resto de funcionalidades
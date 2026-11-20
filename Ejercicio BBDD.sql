
-- Biblioteca (PostgreSQL)
--   CREATE DATABASE biblioteca;

-- Borrado previo (Para el orden por las claves foráneas)
-- asi lanzo el script varias veces sin errores
DROP TABLE IF EXISTS prestamos;
DROP TABLE IF EXISTS socios;
DROP TABLE IF EXISTS libros;

-- Tablas
CREATE TABLE libros (
    id_libro INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    autor VARCHAR(100) NOT NULL,
    num_ejemplares INT NOT NULL,
    editorial VARCHAR(100),
    num_paginas INT,
    anio_edicion INT
);

CREATE TABLE socios (
    id_socio INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    edad INT,
    direccion VARCHAR(150),
    telefono VARCHAR(15)
);

CREATE TABLE prestamos (
    id_prestamo INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_libro INT NOT NULL REFERENCES libros(id_libro),
    id_socio INT NOT NULL REFERENCES socios(id_socio),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL
);

-- Datos de prueba
INSERT INTO libros (titulo, autor, num_ejemplares, editorial, num_paginas, anio_edicion) VALUES
('El Quijote', 'Cervantes', 3, 'Cátedra', 900, 2015),
('Cien años de soledad', 'García Márquez', 2, 'Alfaguara', 471, 2007),
('1984', 'George Orwell', 2, 'Debolsillo', 352, 2013);

INSERT INTO socios (nombre, apellidos, edad, direccion, telefono) VALUES
('Ana', 'López Pérez', 30, 'C/ Mayor 1', '600111222'),
('Luis', 'Gómez Ruiz', 45, 'C/ Sol 5', '600333444');

-- Los ids 1 y 2 de libros y socios existen siempre porque las tablas se recrean arriba
INSERT INTO prestamos (id_libro, id_socio, fecha_inicio, fecha_fin) VALUES
(1, 1, '2026-10-01', '2026-10-15'),   -- vencido
(2, 2, '2026-11-10', '2026-11-30');   -- vigente
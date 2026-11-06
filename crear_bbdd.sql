-- =====================================================
-- BBDD de la clase 2º DAM (PostgreSQL)
-- =====================================================

-- 1) Ejecutar SOLO esta línea conectado a la BD "postgres"
CREATE DATABASE clase_dam;

-- 2) Conectarse a clase_dam y ejecutar el resto del script
DROP VIEW  IF EXISTS v_horas_semanales;
DROP TABLE IF EXISTS matriculas, horarios, asignaturas, alumnos, profesores, grupos CASCADE;

CREATE TABLE grupos (
    id             SERIAL PRIMARY KEY,
    nombre         VARCHAR(20)  NOT NULL,
    ciclo          VARCHAR(100) NOT NULL,
    curso          SMALLINT     NOT NULL,
    anio_academico VARCHAR(9)   NOT NULL
);

CREATE TABLE profesores (
    id     SERIAL PRIMARY KEY,
    nombre VARCHAR(50)  NOT NULL,
    email  VARCHAR(100) UNIQUE
);

CREATE TABLE alumnos (
    id               SERIAL PRIMARY KEY,
    nombre           VARCHAR(50)  NOT NULL,
    apellidos        VARCHAR(100) NOT NULL,
    email            VARCHAR(100) UNIQUE,
    fecha_nacimiento DATE,
    grupo_id         INT NOT NULL REFERENCES grupos(id)
);

CREATE TABLE asignaturas (
    id          SERIAL PRIMARY KEY,
    codigo      VARCHAR(10)  NOT NULL UNIQUE,
    nombre      VARCHAR(150) NOT NULL,
    profesor_id INT NOT NULL REFERENCES profesores(id),
    grupo_id    INT NOT NULL REFERENCES grupos(id)
);

CREATE TABLE horarios (
    id            SERIAL PRIMARY KEY,
    asignatura_id INT NOT NULL REFERENCES asignaturas(id),
    dia_semana    VARCHAR(10) NOT NULL
                  CHECK (dia_semana IN ('Lunes','Martes','Miércoles','Jueves','Viernes')),
    hora_inicio   TIME NOT NULL,
    hora_fin      TIME NOT NULL,
    CHECK (hora_fin > hora_inicio)
);

CREATE TABLE matriculas (
    alumno_id     INT NOT NULL REFERENCES alumnos(id),
    asignatura_id INT NOT NULL REFERENCES asignaturas(id),
    nota          NUMERIC(4,2) CHECK (nota BETWEEN 0 AND 10),
    PRIMARY KEY (alumno_id, asignatura_id)
);

-- ---------- DATOS ----------

INSERT INTO grupos (nombre, ciclo, curso, anio_academico) VALUES
    ('2DAM', 'CFGS Desarrollo de Aplicaciones Multiplataforma', 2, '2026-2027');

INSERT INTO profesores (nombre, email) VALUES
    ('Miguel',   'miguel@centro.example'),
    ('Sergio',   'sergio@centro.example'),
    ('Valentín', 'valentin@centro.example'),
    ('Graciela', 'graciela@centro.example'),
    ('Damián',   'damian@centro.example'),
    ('Alejandro','alejandro@centro.example'),
    ('María',    'maria@centro.example');

-- Alumnos ficticios
INSERT INTO alumnos (nombre, apellidos, email, fecha_nacimiento, grupo_id) VALUES
    ('Carlos', 'Martín Pérez',    'carlos.martin@alumnos.example',  '2003-02-14', 1),
    ('Laura',  'Fernández Gil',   'laura.fernandez@alumnos.example','2002-11-03', 1),
    ('David',  'Romero Sánchez',  'david.romero@alumnos.example',   '2003-06-21', 1),
    ('Sara',   'Jiménez Torres',  'sara.jimenez@alumnos.example',   '2004-01-30', 1),
    ('Álvaro', 'Navarro Díaz',    'alvaro.navarro@alumnos.example', '2002-09-12', 1),
    ('Lucía',  'Moreno Castro',   'lucia.moreno@alumnos.example',   '2003-04-08', 1),
    ('Pablo',  'Ortega Ruiz',     'pablo.ortega@alumnos.example',   '2001-12-25', 1),
    ('Elena',  'Herrera Vega',    'elena.herrera@alumnos.example',  '2003-08-17', 1),
    ('Javier', 'Molina Ramos',    'javier.molina@alumnos.example',  '2002-05-29', 1),
    ('Marta',  'Delgado Cano',    'marta.delgado@alumnos.example',  '2004-03-11', 1);

INSERT INTO asignaturas (codigo, nombre, profesor_id, grupo_id) VALUES
    ('0179',   'Inglés profesional GS',
        (SELECT id FROM profesores WHERE nombre = 'Miguel'), 1),
    ('1865',   'Digitalización aplicada a los sectores productivos GS',
        (SELECT id FROM profesores WHERE nombre = 'Sergio'), 1),
    ('0491',   'Sistemas de gestión empresarial',
        (SELECT id FROM profesores WHERE nombre = 'Sergio'), 1),
    ('0488',   'Desarrollo de interfaces',
        (SELECT id FROM profesores WHERE nombre = 'Valentín'), 1),
    ('0486',   'Acceso a datos',
        (SELECT id FROM profesores WHERE nombre = 'Graciela'), 1),
    ('CMO315', 'Arquitecturas en la nube',
        (SELECT id FROM profesores WHERE nombre = 'Damián'), 1),
    ('0489',   'Programación multimedia y dispositivos móviles',
        (SELECT id FROM profesores WHERE nombre = 'Damián'), 1),
    ('0490',   'Programación de servicios y procesos',
        (SELECT id FROM profesores WHERE nombre = 'Alejandro'), 1),
    ('1710',   'Itinerario personal para la empleabilidad II',
        (SELECT id FROM profesores WHERE nombre = 'María'), 1),
    ('1708',   'Sostenibilidad aplicada al sistema productivo',
        (SELECT id FROM profesores WHERE nombre = 'María'), 1);

-- Horario semanal (recreo 11:15-11:45)
INSERT INTO horarios (asignatura_id, dia_semana, hora_inicio, hora_fin)
SELECT a.id, v.dia, v.ini::time, v.fin::time
FROM (VALUES
    ('0179',   'Lunes',     '08:30', '10:20'),
    ('0486',   'Lunes',     '10:20', '11:15'),
    ('0486',   'Lunes',     '11:45', '12:40'),
    ('0488',   'Lunes',     '12:40', '14:30'),

    ('1865',   'Martes',    '08:30', '09:25'),
    ('0488',   'Martes',    '09:25', '10:20'),
    ('CMO315', 'Martes',    '10:20', '11:15'),
    ('1708',   'Martes',    '11:45', '12:40'),
    ('0490',   'Martes',    '12:40', '14:30'),

    ('0491',   'Miércoles', '08:30', '10:20'),
    ('CMO315', 'Miércoles', '10:20', '11:15'),
    ('CMO315', 'Miércoles', '11:45', '12:40'),
    ('0489',   'Miércoles', '12:40', '14:30'),

    ('0491',   'Jueves',    '08:30', '09:25'),
    ('0490',   'Jueves',    '09:25', '11:15'),
    ('0486',   'Jueves',    '11:45', '12:40'),
    ('0488',   'Jueves',    '12:40', '14:30'),

    ('1710',   'Viernes',   '08:30', '10:20'),
    ('0489',   'Viernes',   '10:20', '11:15'),
    ('0489',   'Viernes',   '11:45', '12:40'),
    ('0486',   'Viernes',   '12:40', '14:30')
) AS v(codigo, dia, ini, fin)
JOIN asignaturas a ON a.codigo = v.codigo;

-- Todos los alumnos matriculados en todas las asignaturas, con notas de prueba (5 a 10)
INSERT INTO matriculas (alumno_id, asignatura_id, nota)
SELECT al.id, asg.id, ROUND((5 + random() * 5)::numeric, 2)
FROM alumnos al
CROSS JOIN asignaturas asg;

-- Vista: horas semanales de cada asignatura
CREATE VIEW v_horas_semanales AS
SELECT a.codigo,
       a.nombre AS asignatura,
       p.nombre AS profesor,
       ROUND(SUM(EXTRACT(EPOCH FROM (h.hora_fin - h.hora_inicio)) / 3600)::numeric, 2) AS horas
FROM asignaturas a
JOIN profesores p ON p.id = a.profesor_id
JOIN horarios  h ON h.asignatura_id = a.id
GROUP BY a.codigo, a.nombre, p.nombre;

-- Comprobación
SELECT * FROM v_horas_semanales ORDER BY codigo;


CREATE TABLE saludmp.PRESTADOR_FAVORITO (
    tipo_documento VARCHAR(3),
    numero_identificacion VARCHAR(30) NOT NULL,
    codigo_plan VARCHAR(20) NOT NULL,
    nombre_plan VARCHAR(200) NOT NULL,
    codigo_prestador VARCHAR(10) NOT NULL,
    prestador VARCHAR(150),
    direccion_prestador VARCHAR(50) NOT NULL,
    codigo_ciudad VARCHAR(10) NOT NULL,
    cartilla VARCHAR(5) NOT NULL,
    marcacion VARCHAR(1),
    fecha_creacion DATETIME,
    fecha_actualizacion DATETIME
);

ALTER TABLE saludmp.PRESTADOR_FAVORITO
ADD CONSTRAINT PRESTADOR_FAVORITO_PK 
PRIMARY KEY (numero_identificacion,codigo_plan,codigo_prestador,codigo_ciudad,cartilla,direccion_prestador);

-- Agrega una descripción a la tabla
EXEC sp_addextendedproperty 
    @name = N'PRESTADOR_FAVORITO', 
    @value = N'Guarda la información de los prestadores favoritos asociados un usuario', 
    @level0type = N'SCHEMA', @level0name = N'saludmp', 
    @level1type = N'TABLE',  @level1name = N'PRESTADOR_FAVORITO';

-- Agrega una descripción a los campos de la tabla
EXEC sp_addextendedproperty 
    @name = 'tipo_documento', 
    @value = 'indica el tipo de documento', 
    @level0type = 'SCHEMA', @level0name = 'saludmp', 
    @level1type = 'TABLE',  @level1name = 'PRESTADOR_FAVORITO', 
    @level2type = 'COLUMN', @level2name = 'tipo_documento';

EXEC sp_addextendedproperty 
    @name = 'numero_identificacion', 
    @value = 'indica el numero de documento del usuario', 
    @level0type = 'SCHEMA', @level0name = 'saludmp', 
    @level1type = 'TABLE',  @level1name = 'PRESTADOR_FAVORITO', 
    @level2type = 'COLUMN', @level2name = 'numero_identificacion';

EXEC sp_addextendedproperty 
    @name = 'codigo_plan', 
    @value = 'indica el código del plan del usuario', 
    @level0type = 'SCHEMA', @level0name = 'saludmp', 
    @level1type = 'TABLE',  @level1name = 'PRESTADOR_FAVORITO', 
    @level2type = 'COLUMN', @level2name = 'codigo_plan';

EXEC sp_addextendedproperty 
    @name = 'nombre_plan', 
    @value = 'indica el nombre del plan del usuario', 
    @level0type = 'SCHEMA', @level0name = 'saludmp', 
    @level1type = 'TABLE',  @level1name = 'PRESTADOR_FAVORITO', 
    @level2type = 'COLUMN', @level2name = 'nombre_plan';

EXEC sp_addextendedproperty 
    @name = 'codigo_prestador', 
    @value = 'indica el código de prestador a marcar', 
    @level0type = 'SCHEMA', @level0name = 'saludmp', 
    @level1type = 'TABLE',  @level1name = 'PRESTADOR_FAVORITO', 
    @level2type = 'COLUMN', @level2name = 'codigo_prestador';

EXEC sp_addextendedproperty 
    @name = 'prestador', 
    @value = 'indicar el nombre del prestador a marcar', 
    @level0type = 'SCHEMA', @level0name = 'saludmp', 
    @level1type = 'TABLE',  @level1name = 'PRESTADOR_FAVORITO', 
    @level2type = 'COLUMN', @level2name = 'prestador';

EXEC sp_addextendedproperty 
    @name = 'direccion_prestador', 
    @value = 'indica el lugar de atención del prestador a marcar', 
    @level0type = 'SCHEMA', @level0name = 'saludmp', 
    @level1type = 'TABLE',  @level1name = 'PRESTADOR_FAVORITO', 
    @level2type = 'COLUMN', @level2name = 'direccion_prestador';

EXEC sp_addextendedproperty 
    @name = 'codigo_ciudad', 
    @value = 'indica el código de la ciudad en donde se encuentra el prestador a marcar', 
    @level0type = 'SCHEMA', @level0name = 'saludmp', 
    @level1type = 'TABLE',  @level1name = 'PRESTADOR_FAVORITO', 
    @level2type = 'COLUMN', @level2name = 'codigo_ciudad';

EXEC sp_addextendedproperty 
    @name = 'cartilla', 
    @value = 'indica la cartilla a la que pertenece el prestador a marcar', 
    @level0type = 'SCHEMA', @level0name = 'saludmp', 
    @level1type = 'TABLE',  @level1name = 'PRESTADOR_FAVORITO', 
    @level2type = 'COLUMN', @level2name = 'cartilla';

EXEC sp_addextendedproperty 
    @name = 'marcacion', 
    @value = '   indica la marcación que se entablecera para el prestardo: 0 = Inactivo, 1 = Activo', 
    @level0type = 'SCHEMA', @level0name = 'saludmp', 
    @level1type = 'TABLE',  @level1name = 'PRESTADOR_FAVORITO', 
    @level2type = 'COLUMN', @level2name = 'marcacion';

EXEC sp_addextendedproperty 
    @name = 'fecha_creacion', 
    @value = 'indica la fecha en que se realizo la marcación del prestador por primera vez', 
    @level0type = 'SCHEMA', @level0name = 'saludmp', 
    @level1type = 'TABLE',  @level1name = 'PRESTADOR_FAVORITO', 
    @level2type = 'COLUMN', @level2name = 'fecha_creacion';

EXEC sp_addextendedproperty 
    @name = 'fecha_actualizacion', 
    @value = 'indica la fecha de actualización de registro', 
    @level0type = 'SCHEMA', @level0name = 'saludmp', 
    @level1type = 'TABLE',  @level1name = 'PRESTADOR_FAVORITO', 
    @level2type = 'COLUMN', @level2name = 'fecha_actualizacion';





-- CREATE TABLE saludmp.PRESTADOR_FAVORITO (
--     tipo_documento VARCHAR(3),
--     numero_identificacion VARCHAR(30) NOT NULL,
--     codigo_plan VARCHAR(20) NOT NULL,
--     nombre_plan VARCHAR(180) NOT NULL,
--     codigo_prestador VARCHAR(10) NOT NULL,
--     prestador VARCHAR(150),
--     direccion_prestador VARCHAR(50) NOT NULL,
--     codigo_ciudad VARCHAR(10) NOT NULL,
--     cartilla VARCHAR(5) NOT NULL,
--     marcacion VARCHAR(1),
--     fecha_creacion DATETIME,
--     fecha_actualizacion DATETIME
-- );


-- Datos de pruebas
-- INSERT INTO saludmp.PRESTADOR_FAVORITO 
-- VALUES ('RC','1232815503','OP02','ORO PLUS GRUPO EMPRESARIAL COOMEVA','4985','CENTRO MEDICO IMBANACO','CALLE 38 BIS 5B2-04 SEDE 16','05001','001','1',GETDATE(),GETDATE());


-- INSERT INTO saludmp.PRESTADOR_FAVORITO 
-- VALUES ('RC','1232815503','OP02','ORO PLUS GRUPO EMPRESARIAL COOMEVA','4199','CHRISTUS SINERGIA  CLINICA FARALLONES','CALLE 9C 50-25 CHRISTUS SINERGIA  CLINICA FARALLONES','05001','001','1',GETDATE(),GETDATE());


-- INSERT INTO saludmp.PRESTADOR_FAVORITO 
-- VALUES ('CC','43018567','OP02','ORO PLUS GRUPO EMPRESARIAL COOMEVA','4985','CENTRO MEDICO IMBANACO','CALLE 38 BIS 5B2-04 SEDE 16','05001','001','1',GETDATE(),GETDATE());

-- INSERT INTO saludmp.PRESTADOR_FAVORITO 
-- VALUES ('CC','43018567','OP02','ORO PLUS GRUPO EMPRESARIAL COOMEVA','4199','CHRISTUS SINERGIA  CLINICA FARALLONES','CALLE 9C 50-25 CHRISTUS SINERGIA  CLINICA FARALLONES','05001','001','1',GETDATE(),GETDATE());






-- SELECT * FROM saludmp.PRESTADOR_FAVORITO;

-- muestra la descripción de la tabla y sus campos
-- SELECT 
--     obj.object_id,
--     obj.name AS ObjectName,
--     ep.name AS PropertyName,
--     ep.value AS PropertyValue
-- FROM 
--     sys.extended_properties ep
-- JOIN 
--     sys.objects obj ON ep.major_id = obj.object_id
-- WHERE 
--     obj.name = 'PRESTADOR_FAVORITO';


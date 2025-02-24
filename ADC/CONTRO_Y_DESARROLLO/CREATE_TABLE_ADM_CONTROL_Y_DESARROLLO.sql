
DROP TABLE ADM_CONTROL_Y_DESARROLLO;


CREATE TABLE ADM_CONTROL_Y_DESARROLLO (
        TIPO_DOCUMENTO VARCHAR(4) NOT NULL,
        NUMERO_DOCUMENTO VARCHAR2(32) NOT NULL,
        NOMBRE_AFILIADO VARCHAR2(100) NOT NULL,
        GENERO CHAR(1) NOT NULL,
        EDAD CHAR(1) NOT NULL,
        IPS_ATENCION VARCHAR2(300) NOT NULL,
        CODIGO_PLAN_MEDICINA_PREPAGADA VARCHAR2(10) NOT NULL,
        PLAN_MEDICINA_PREPAGADA VARCHAR2(200) NOT NULL,
        CODIGO_CIUDAD VARCHAR2(10) NOT NULL,
        CIUDAD VARCHAR2(100) NOT NULL,
        FECHA_REGISTRO VARCHAR2(12) NOT NULL,
        ESTADO_REGISTRO VARCHAR2(20) NOT NULL,
        CONSTRAINT ADM_CONTROL_Y_DESARROLLO_PK PRIMARY KEY (NUMERO_DOCUMENTO)
);




COMMENT ON TABLE ADM_CONTROL_Y_DESARROLLO IS 'Almacena los registros de los usuario afiliado o asociados al programa de Control y desarrollo';
COMMENT ON COLUMN ADM_CONTROL_Y_DESARROLLO.TIPO_DOCUMENTO IS 'Indica el tipo de identificación del usuario afiliado o asociado al programa de Control y desarrollo';
COMMENT ON COLUMN ADM_CONTROL_Y_DESARROLLO.NUMERO_DOCUMENTO IS 'Indica el número de identificación del usuario afiliado o asociado al programa de Control y desarrollo';
COMMENT ON COLUMN ADM_CONTROL_Y_DESARROLLO.NOMBRE_AFILIADO IS 'Indica el nombre completo de usuario afiliado o asociado al programa de Control y desarrollo';
COMMENT ON COLUMN ADM_CONTROL_Y_DESARROLLO.GENERO IS 'Indica el genero del usuario afiliado o asociado al programa de Control y desarrollo';
COMMENT ON COLUMN ADM_CONTROL_Y_DESARROLLO.GENERO IS 'Indica las edad del usuario afiliado o asociado al programa de Control y desarrollo';
COMMENT ON COLUMN ADM_CONTROL_Y_DESARROLLO.IPS_ATENCION IS 'Indica el nombre completo de la IPS de atentción del usuario afiliado o asociado al programa de Control y desarrollo';
COMMENT ON COLUMN ADM_CONTROL_Y_DESARROLLO.CODIGO_PLAN_MEDICINA_PREPAGADA IS 'Indica el código del plan al que esta el usuario afiliado o asociado al programa de Control y desarrollo';
COMMENT ON COLUMN ADM_CONTROL_Y_DESARROLLO.PLAN_MEDICINA_PREPAGADA IS 'Indica el nombre del plan del usuario afiliado o asociado al programa de Control y desarrollo';
COMMENT ON COLUMN ADM_CONTROL_Y_DESARROLLO.CODIGO_CIUDAD IS 'Indica el código de la ciudad de residencia del usuario afiliado o asociado al programa de Control y desarrollo';
COMMENT ON COLUMN ADM_CONTROL_Y_DESARROLLO.CIUDAD IS 'Indica el nombre de la ciudad de residencia del usuario afiliado o asociado al programa de Control y desarrollo';
COMMENT ON COLUMN ADM_CONTROL_Y_DESARROLLO.FECHA_REGISTRO IS 'Indica la fecha de registro del usuario afiliado o asociado al programa de Control y desarrollo';
COMMENT ON COLUMN ADM_CONTROL_Y_DESARROLLO.ESTADO_REGISTRO IS 'Indica el estado del registro del usuario afiliado o asociado al programa de Control y desarrollo';



INSERT INTO ADM_CONTROL_Y_DESARROLLO 
VALUES ('RC','1023595782','ALBERTO ARENAS GUZMAN','M','8','CENTRO MEDICO COOMEVA MEDICINA PREPAGADA SOTO MAYOR BUCARAMANGA MP','OPLF','ORO PLUS FAMILIAR','76002','CALI',TO_CHAR(SYSDATE, 'DD/MM/YYYY'),'VIGENTE');
COMMIT;



SELECT *
FROM ADM_CONTROL_Y_DESARROLLO;
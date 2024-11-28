    
CREATE SEQUENCE auto_increment_promociones;

CREATE OR REPLACE TRIGGER auto_increment_promociones
   BEFORE INSERT ON VDIR_PROMOCIONES
   FOR EACH ROW
BEGIN
   SELECT auto_increment_promociones.nextval
   INTO :new.COD_PROMOCION
   FROM dual;
END;
    
CREATE SEQUENCE auto_increment_beneasoc;

CREATE OR REPLACE TRIGGER auto_increment_beneasoc
   BEFORE INSERT ON VDIR_BENEFICIARIOS_ASOCIADOS
   FOR EACH ROW
BEGIN
   SELECT auto_increment_beneasoc.nextval
   INTO :new.COD_BENEFICIARIO
   FROM dual;
END;

ALTER TABLE VDIR_TARIFAS_ASOCIADAS
    ADD (
        CONSTRAINT pk_vdir_tarasoc PRIMARY KEY (COD_BENEFICIARIO)
    );
    
CREATE SEQUENCE auto_increment_tarasoc;

CREATE OR REPLACE TRIGGER auto_increment_tarasoc
   BEFORE INSERT ON VDIR_TARIFAS_ASOCIADAS
   FOR EACH ROW
BEGIN
   SELECT auto_increment_tarasoc.nextval
   INTO :new.COD_BENEFICIARIO
   FROM dual;
END;

  
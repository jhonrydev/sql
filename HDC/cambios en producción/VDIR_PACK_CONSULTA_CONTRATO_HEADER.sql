create or replace PACKAGE         VDIR_PACK_CONSULTA_CONTRATO AS
/* ---------------------------------------------------------------------
 Copyright  Tecnología Informática Coomeva - Colombia
 Package     : VDIR_PACK_CONSULTA_CONTRATO
 Caso de Uso : 
 Descripción : Procesos para la consulta los archivos de contratos
 --------------------------------------------------------------------
 Autor : katherine.latorre@kalettre.com
 Fecha : 20-02-2018  
 --------------------------------------------------------------------
 Procedimiento :     Descripcion:
 --------------------------------------------------------------------
 Historia de Modificaciones
 ---------------------------------------------------------------------
 Fecha Autor Modificación
 ----------------------------------------------------------------- */

	-- ---------------------------------------------------------------------
	-- Declaracion de estructuras dinamicas
	-- ---------------------------------------------------------------------
	TYPE type_cursor IS REF CURSOR;
    TYPE type_cadena IS TABLE OF VARCHAR2(2000)
            INDEX BY BINARY_INTEGER;
            
-- ---------------------------------------------------------------------
    -- fn_CadenatoArray
    -- ---------------------------------------------------------------------            
    FUNCTION fn_CadenatoArray
    (
        pvc_cadena       VARCHAR2 ,
        pch_separador CHAR DEFAULT ','
    )
    RETURN type_cadena;
	-- ---------------------------------------------------------------------
    -- fnGetDatosContrato
    -- ---------------------------------------------------------------------
    FUNCTION fnGetDatosContrato
    (
      	inu_codPersona  IN VDIR_PERSONA.COD_PERSONA%TYPE,
		inu_codPrograma IN VDIR_PROGRAMA.COD_PROGRAMA%TYPE,
        inu_codAfiliacion IN VDIR_AFILIACION.COD_AFILIACION%TYPE
    )
	RETURN VARCHAR2;

	-- ---------------------------------------------------------------------
    -- fnGetValidaContrato
    -- ---------------------------------------------------------------------
    FUNCTION fnGetValidaContrato
    (
        inu_codAfiliacion IN VDIR_PERSONA_CONTRATO.COD_AFILIACION%TYPE,
		inu_codPersona    IN VDIR_PERSONA_CONTRATO.COD_PERSONA%TYPE,
		inu_codPrograma   IN VDIR_PERSONA_CONTRATO.COD_PROGRAMA%TYPE
    )
	RETURN NUMBER;
	
	FUNCTION fnGetValidaInclusion
    (
        inu_codAfiliacion IN VDIR_PERSONA_CONTRATO.COD_AFILIACION%TYPE,
		inu_codPersona    IN VDIR_PERSONA_CONTRATO.COD_PERSONA%TYPE
    )
	RETURN type_cursor;
	
	FUNCTION fnGetContrato
    (      	
		inu_codPrograma IN VDIR_PROGRAMA.COD_PROGRAMA%TYPE,
        inu_codAfiliacion IN VDIR_AFILIACION.COD_AFILIACION%TYPE
    )
	RETURN VARCHAR2;


END VDIR_PACK_CONSULTA_CONTRATO;
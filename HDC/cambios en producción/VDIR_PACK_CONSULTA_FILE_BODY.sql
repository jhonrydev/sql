create or replace PACKAGE BODY VDIR_PACK_CONSULTA_FILE AS
/* ---------------------------------------------------------------------
 Copyright  Tecnolog¿a Inform¿tica Coomeva - Colombia
 Package     : VDIR_PACK_CONSULTA_FILE
 Caso de Uso : 
 Descripci¿n : Procesos para la consulta los archivos adjuntos - VENTA DIRECTA
 --------------------------------------------------------------------
 Autor : katherine.latorre@kalettre.com
 Fecha : 23-01-2018  
 --------------------------------------------------------------------
 Procedimiento :     Descripcion:
 --------------------------------------------------------------------
 Historia de Modificaciones
 ---------------------------------------------------------------------
 Fecha Autor Modificaci¿n
 ----------------------------------------------------------------- */

	-- ---------------------------------------------------------------------
    -- fnGetValidaDocumentos
    -- ---------------------------------------------------------------------
    FUNCTION fnGetValidaDocumentos
    (
        inu_codAfiliacion IN VDIR_FILE_BENEFICIARIO.COD_AFILIACION%TYPE,
		inu_codPersona    IN VDIR_FILE_BENEFICIARIO.COD_BENEFICIARIO%TYPE
    )
	RETURN NUMBER IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog¿a Inform¿tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_FILE
	 Caso de Uso : 
	 Descripci¿n : Retorna 1 = Si / 0 = No si el beneficiario tiene los 
	               documentos
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 23-01-2019  
	 ----------------------------------------------------------------------
	 Par¿metros :     Descripci¿n:
	 inu_codAfiliacion       C¿digo de la afiliaci¿n
	 inu_codPersona          C¿digo de la persona contratante / beneficiario
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci¿n
	 ----------------------------------------------------------------- */

	    CURSOR cu_valida_archivo IS
		SELECT COUNT(1)
		  FROM VDIR_FILE_BENEFICIARIO fibe,
		       VDIR_FILE              vfil		  
	     WHERE 
		 	fibe.cod_file = vfil.cod_file
		   	AND vfil.cod_tipo_file IN (6,7)
		 	AND fibe.COD_AFILIACION   = inu_codAfiliacion
		   	AND fibe.COD_BENEFICIARIO = inu_codPersona;

		lnu_validaArchivo NUMBER(1) := 0;

	BEGIN

		 OPEN cu_valida_archivo; 
		FETCH cu_valida_archivo INTO lnu_validaArchivo; 
		CLOSE cu_valida_archivo;

		RETURN lnu_validaArchivo;

	END fnGetValidaDocumentos;

	-- ---------------------------------------------------------------------
    -- fnGetDocumentosBeneficiario
    -- ---------------------------------------------------------------------
    FUNCTION fnGetDocumentosBeneficiario
    (
        inu_codAfiliacion IN VDIR_FILE_BENEFICIARIO.COD_AFILIACION%TYPE,
		inu_codPersona    IN VDIR_FILE_BENEFICIARIO.COD_BENEFICIARIO%TYPE
    )
	RETURN type_cursor IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog¿a Inform¿tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_FILE
	 Caso de Uso : 
	 Descripci¿n : Retorna los datos de las documentos por beneficiarip
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 23-01-2019  
	 ----------------------------------------------------------------------
	 Par¿metros :     Descripci¿n:
	 inu_codAfiliacion       C¿digo de la afiliaci¿n
	 inu_codPersona          C¿digo de la persona contratante / beneficiario
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci¿n
	 ----------------------------------------------------------------- */

		ltc_datos type_cursor;

	BEGIN 

		  OPEN ltc_datos FOR
		SELECT vfil.des_file,
		       vfil.ruta
		  FROM VDIR_FILE_BENEFICIARIO fibe,
		       VDIR_FILE              vfil
	 	 WHERE fibe.cod_file = vfil.cod_file
		   AND vfil.cod_tipo_file IN (6,7)
		   AND fibe.cod_afiliacion = inu_codAfiliacion
		   AND fibe.cod_beneficiario = inu_codPersona;

		RETURN ltc_datos;

	END fnGetDocumentosBeneficiario;


END VDIR_PACK_CONSULTA_FILE;

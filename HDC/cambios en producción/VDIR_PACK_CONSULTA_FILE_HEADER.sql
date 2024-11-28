create
or replace PACKAGE VDIR_PACK_CONSULTA_FILE AS
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
-- Declaracion de estructuras dinamicas
-- ---------------------------------------------------------------------
TYPE type_cursor IS REF CURSOR;

-- ---------------------------------------------------------------------
-- fnGetValidaDocumentos
-- ---------------------------------------------------------------------
FUNCTION fnGetValidaDocumentos (
    inu_codAfiliacion IN VDIR_FILE_BENEFICIARIO.COD_AFILIACION % TYPE,
    inu_codPersona IN VDIR_FILE_BENEFICIARIO.COD_BENEFICIARIO % TYPE
) RETURN NUMBER;

-- ---------------------------------------------------------------------
-- fnGetDocumentosBeneficiario
-- ---------------------------------------------------------------------
FUNCTION fnGetDocumentosBeneficiario (
    inu_codAfiliacion IN VDIR_FILE_BENEFICIARIO.COD_AFILIACION % TYPE,
    inu_codPersona IN VDIR_FILE_BENEFICIARIO.COD_BENEFICIARIO % TYPE
) RETURN type_cursor;

END VDIR_PACK_CONSULTA_FILE;
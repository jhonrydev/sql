create
or replace PACKAGE VDIR_PACK_REGISTRO_FILE AS
/* ---------------------------------------------------------------------
Copyright  Tecnología Informática Coomeva - Colombia
Package     : VDIR_PACK_REGISTRO_FILE
Caso de Uso : 
Descripción : Procesos para el registro los archivos adjuntos - VENTA DIRECTA
--------------------------------------------------------------------
Autor : katherine.latorre@kalettre.com
Fecha : 23-01-2018  
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

-- ---------------------------------------------------------------------
-- prGuardarFile
-- ---------------------------------------------------------------------
PROCEDURE prGuardarFile (
    ivc_desFile IN VDIR_FILE.DES_FILE % TYPE,
    ivc_observacion IN VDIR_FILE.OBSERVACION % TYPE,
    ivc_ruta IN VDIR_FILE.RUTA % TYPE,
    inu_codTipoFile IN VDIR_FILE.COD_TIPO_FILE % TYPE,
    onu_codFile OUT VDIR_FILE.COD_FILE % TYPE
);

-- ---------------------------------------------------------------------
-- prGuardarFileBeneficiario
-- ---------------------------------------------------------------------
PROCEDURE prGuardarFileBeneficiario (
    inu_codAfiliacion IN VDIR_FILE_BENEFICIARIO.COD_AFILIACION % TYPE,
    inu_codFile IN VDIR_FILE_BENEFICIARIO.COD_FILE % TYPE,
    inu_codBeneficiaro IN VDIR_FILE_BENEFICIARIO.COD_BENEFICIARIO % TYPE
);

END VDIR_PACK_REGISTRO_FILE;
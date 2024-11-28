create
or replace PACKAGE VDIR_PACK_REGISTRO_CONTRATO AS
/* ---------------------------------------------------------------------
Copyright  Tecnología Informática Coomeva - Colombia
Package     : VDIR_PACK_REGISTRO_CONTRATO
Caso de Uso : 
Descripción : Procesos para el registro del contrato asociado al contratante - VENTA DIRECTA
--------------------------------------------------------------------
Autor : katherine.latorre@kalettre.com
Fecha : 14-01-2018  
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
-- prGuardarContratoAdobe
-- ---------------------------------------------------------------------
PROCEDURE prGuardarContratoAdobe (
    inu_codPersona IN VDIR_PERSONA_CONTRATO.COD_PERSONA % TYPE,
    inu_codPrograma IN VDIR_PERSONA_CONTRATO.COD_PROGRAMA % TYPE,
    inu_codAfiliacion IN VDIR_PERSONA_CONTRATO.COD_AFILIACION % TYPE,
    ivc_nroContratoAdobe IN VDIR_PERSONA_CONTRATO.NUMERO_CONTRATO_ADOBE % TYPE
);

-- ---------------------------------------------------------------------
-- prActualizarAfiliacion
-- ---------------------------------------------------------------------
PROCEDURE prActualizarAfiliacion (
    inu_codAfiliacion IN VDIR_AFILIACION.COD_AFILIACION % TYPE
);

END VDIR_PACK_REGISTRO_CONTRATO;
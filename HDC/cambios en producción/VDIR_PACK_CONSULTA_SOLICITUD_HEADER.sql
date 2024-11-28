create
or replace PACKAGE VDIR_PACK_CONSULTA_SOLICITUD AS
/* ---------------------------------------------------------------------
Copyright  Tecnolog?a Inform?tica Coomeva - Colombia
Package     : VDIR_PACK_CONSULTA_SOLICITUD
Caso de Uso : 
Descripci?n : Procesos para la consulta las afiliaciones - VENTA DIRECTA
--------------------------------------------------------------------
Autor : katherine.latorre@kalettre.com
Fecha : 08-02-2018  
--------------------------------------------------------------------
Procedimiento :     Descripcion:
--------------------------------------------------------------------
Historia de Modificaciones
---------------------------------------------------------------------
Fecha Autor Modificaci?n
----------------------------------------------------------------- */
-- ---------------------------------------------------------------------
-- Declaracion de estructuras dinamicas
-- ---------------------------------------------------------------------
TYPE type_cursor IS REF CURSOR;

-- ---------------------------------------------------------------------
-- fnGetSolicitudesGestionar
-- ---------------------------------------------------------------------
FUNCTION fnGetSolicitudesGestionar (
    inu_codEstado IN VDIR_AFILIACION.COD_ESTADO % TYPE DEFAULT 7,
    inu_codAfiliacion IN VDIR_AFILIACION.COD_AFILIACION % TYPE DEFAULT NULL,
    ivc_fechaInicia IN VARCHAR2 DEFAULT NULL,
    ivc_fechaFinal IN VARCHAR2 DEFAULT NULL,
    ivc_nroDocumento IN VDIR_PERSONA.NUMERO_IDENTIFICACION % TYPE DEFAULT NULL,
    ivc_rolOperativo IN VDIR_ESTADO.ROL_OPERATIVO % TYPE DEFAULT NULL
) RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetSolicitudes
-- ---------------------------------------------------------------------
FUNCTION fnGetSolicitudes (
    inu_codEstado IN VDIR_AFILIACION.COD_ESTADO % TYPE DEFAULT NULL,
    inu_codAfiliacion IN VDIR_AFILIACION.COD_AFILIACION % TYPE DEFAULT NULL,
    ivc_fechaRadicaInicia IN VARCHAR2 DEFAULT NULL,
    ivc_fechaRadicaFinal IN VARCHAR2 DEFAULT NULL,
    ivc_fechaGestionInicia IN VARCHAR2 DEFAULT NULL,
    ivc_fechaGestionFinal IN VARCHAR2 DEFAULT NULL,
    ivc_nroDocumento IN VDIR_PERSONA.NUMERO_IDENTIFICACION % TYPE DEFAULT NULL,
    ivc_rolOperativo IN VDIR_ESTADO.ROL_OPERATIVO % TYPE DEFAULT NULL
) RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetDatosContratante
-- ---------------------------------------------------------------------
FUNCTION fnGetDatosContratante (
    inu_codAfiliacion IN VDIR_AFILIACION.COD_AFILIACION % TYPE
) RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetDatosBeneficiarios
-- ---------------------------------------------------------------------
FUNCTION fnGetDatosBeneficiarios (
    inu_codAfiliacion IN VDIR_AFILIACION.COD_AFILIACION % TYPE
) RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetTipoCompras
-- ---------------------------------------------------------------------
FUNCTION fnGetTipoCompras (
    inu_codAfiliacion IN VDIR_BENEFICIARIO_PROGRAMA.COD_AFILIACION % TYPE,
    inu_codBeneficiario IN VDIR_BENEFICIARIO_PROGRAMA.COD_BENEFICIARIO % TYPE,
    inu_codPlan IN VDIR_PLAN_PROGRAMA.COD_PLAN % TYPE
) RETURN VARCHAR2;

-- ---------------------------------------------------------------------
-- fnGetFechasServicio
-- ---------------------------------------------------------------------
FUNCTION fnGetFechasServicio (
    inu_codAfiliacion IN VDIR_PERSONA_CONTRATO.COD_AFILIACION % TYPE,
    inu_codContrante IN VDIR_PERSONA_CONTRATO.COD_PERSONA % TYPE,
    inu_codPlan IN VDIR_PLAN_PROGRAMA.COD_PLAN % TYPE
) RETURN VARCHAR2;

-- ---------------------------------------------------------------------
-- fnGetProgramas
-- ---------------------------------------------------------------------
FUNCTION fnGetProgramas (
    inu_codAfiliacion IN VDIR_BENEFICIARIO_PROGRAMA.COD_AFILIACION % TYPE,
    inu_codBeneficiario IN VDIR_BENEFICIARIO_PROGRAMA.COD_BENEFICIARIO % TYPE,
    inu_codPlan IN VDIR_PLAN_PROGRAMA.COD_PLAN % TYPE
) RETURN VARCHAR2;

-- ---------------------------------------------------------------------
-- fnGetTarifas
-- ---------------------------------------------------------------------
FUNCTION fnGetTarifas (
    inu_codAfiliacion IN VDIR_BENEFICIARIO_PROGRAMA.COD_AFILIACION % TYPE,
    inu_codBeneficiario IN VDIR_BENEFICIARIO_PROGRAMA.COD_BENEFICIARIO % TYPE
) RETURN VARCHAR2;

-- ---------------------------------------------------------------------
-- fnGetDatosBitacora
-- ---------------------------------------------------------------------
FUNCTION fnGetDatosBitacora (
    inu_codAfiliacion IN VDIR_AFILIACION.COD_AFILIACION % TYPE
) RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetValidaExisteCola
-- ---------------------------------------------------------------------
FUNCTION fnGetValidaExisteCola (
    inu_codAfiliacion IN VDIR_COLA_SOLICITUD.COD_AFILIACION % TYPE,
    inu_codUsuario IN VDIR_COLA_SOLICITUD.COD_USUARIO % TYPE
) RETURN NUMBER;

-- ---------------------------------------------------------------------
-- fnGetNombreUsuarioCola
-- ---------------------------------------------------------------------
FUNCTION fnGetNombreUsuarioCola (
    inu_codAfiliacion IN VDIR_COLA_SOLICITUD.COD_AFILIACION % TYPE
) RETURN VARCHAR2;

-- ---------------------------------------------------------------------
-- fnGetSolicitudesPendientes
-- ---------------------------------------------------------------------
FUNCTION fnGetSolicitudesPendientes (inu_codUsuario IN VDIR_USUARIO.COD_USUARIO % TYPE) RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetValidaSolicitudEnGestion
-- ---------------------------------------------------------------------
FUNCTION fnGetValidaSolicitudEnGestion (
    inu_codUsuario IN VDIR_COLA_SOLICITUD.COD_USUARIO % TYPE
) RETURN NUMBER;

FUNCTION fnGetDatosProgramas (
    inu_codAfiliacion IN VDIR_AFILIACION.COD_AFILIACION % TYPE
) RETURN type_cursor;

FUNCTION fnGetBenexPrograma (
    inu_codAfiliacion IN VDIR_AFILIACION.COD_AFILIACION % TYPE,
    inu_codprograma IN VDIR_PROGRAMA.COD_PROGRAMA % TYPE
) RETURN type_cursor;

END VDIR_PACK_CONSULTA_SOLICITUD;
create
or replace PACKAGE "VDIR_PACK_UTILIDADES" AS FUNCTION VDIR_FN_GETCOLECCION_WHERE (
    p_nom_cod_tabla IN VARCHAR2,
    p_nom_des_tabla IN VARCHAR2,
    p_nom_table IN VARCHAR2,
    p_aux_where IN VARCHAR2,
    p_fila_order IN VARCHAR2
) RETURN sys_refcursor;

------------------------------------------------------------------------------FUNCION PARA TRAER LA DESCRIPCION DE UNA PARAMETRO 
FUNCTION VDIR_FN_GET_PARAMETRO (p_codigoParametro IN NUMBER) RETURN VARCHAR2;

----------------------------------------------------------------------------  FUNCION PARA TRAER LOS DAOS DE LA PERSONA,USUAIRO Y ROLES 
FUNCTION VDIR_FN_GET_DATOS_PERSONA (
    p_identificacion IN vdir_persona.numero_identificacion % TYPE
) RETURN sys_refcursor;

------------------------------------------------------------------------------FUNCION PARA TRAER LOS ROLES QUE TIENE UNA PERSONA 
FUNCTION VDIR_FN_GET_ROLES_PERSONA (p_cod_user IN vdir_usuario.cod_usuario % TYPE) RETURN VARCHAR2;

TYPE type_cursor IS REF CURSOR;

TYPE datasplit_record IS RECORD (idx NUMBER, dato VARCHAR2(4000));

TYPE datasplit_table IS TABLE OF datasplit_record;

/* ------------------------------------------
fn_splitData: funcion para retornar tabla con los datos de una cadena separados por un caracter
-- ------------------------------------------  */
FUNCTION fn_splitData (
    P_STRING_DATA IN VARCHAR2,
    P_SEPARATOR IN VARCHAR2
) RETURN datasplit_table PIPELINED;

----------------------------------------------------------------------------  FUNCION PARA TRAER LOS DATOS DE PAGAR EN PAYU 
FUNCTION VDIR_FN_GET_DATOS_PAGO (
    p_cod_afiliacion vdir_afiliacion.cod_afiliacion % TYPE
) RETURN sys_refcursor;

/*---------------------------------------------------------------------
fn_getMonthSpainish: funcion para obtener el nombre del un mes en español
----------------------------------------------------------------------- */
FUNCTION fn_getMonthSpainish (p_num_mes IN INTEGER) RETURN VARCHAR2;

/*---------------------------------------------------------------------
fn_getFormatMiles: funcion para obtener el formateo a miles de un numero entero o decimal
----------------------------------------------------------------------- */
FUNCTION fn_getFormatMiles (
    p_numero IN INTEGER,
    p_incluir_decimal IN INTEGER,
    p_prefijo IN CHAR
) RETURN VARCHAR2;

------------------------------------------------------------------------------FUNCION PARA TRAER LOS PROGRAMAS DE UN CONTRATANTE PARA UNA AFLIACION 
FUNCTION VDIR_FN_GET_PROGRAMAS (
    p_cod_afiliacion vdir_afiliacion.cod_afiliacion % TYPE
) RETURN VARCHAR2;

/*---------------------------------------------------------------------
VDIR_FN_GET_DATOS_KIT BIENVENIDA: funcion para obtener los datos del kit de bienvenida
----------------------------------------------------------------------- */
FUNCTION VDIR_FN_GET_DATOS_KIT_BIENV (
    p_cod_afiliacion vdir_afiliacion.cod_afiliacion % TYPE
) RETURN sys_refcursor;

FUNCTION VDIR_FN_GET_INFO_PAGO (
    p_cod_afiliacion vdir_afiliacion.cod_afiliacion % TYPE
) RETURN sys_refcursor;

END VDIR_PACK_UTILIDADES;
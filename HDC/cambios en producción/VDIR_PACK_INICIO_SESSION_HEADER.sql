create
or replace PACKAGE "VDIR_PACK_INICIO_SESSION" AS
----------------------------------------------- FUNCION PARA TRAER DATOS DEL TIPO DE DOCUMENTO  
FUNCTION VDIR_FN_GET_TIPO_DOCUMENTO RETURN sys_refcursor;

----------------------------------------------- FUNCION PARA TRAER DATOS DEL SEXO  
FUNCTION VDIR_FN_GET_SEXO RETURN sys_refcursor;

------------------------------------------------ PROCEDIMIENTO PARA GUARDAR EL USUARIO  
PROCEDURE VDIR_SP_GUARDAR_USUARIO (
    p_tipo_identificacion IN VDIR_PERSONA.COD_TIPO_IDENTIFICACION % TYPE,
    p_numero_identificacion IN VDIR_PERSONA.NUMERO_IDENTIFICACION % TYPE,
    p_nombre_1 IN VDIR_PERSONA.NOMBRE_1 % TYPE,
    p_nombre_2 IN VDIR_PERSONA.NOMBRE_2 % TYPE,
    p_apellido_1 IN VDIR_PERSONA.APELLIDO_1 % TYPE,
    p_apellido_2 IN VDIR_PERSONA.APELLIDO_2 % TYPE,
    p_fecha_nacimiento IN DATE,
    p_cod_sexo IN VDIR_PERSONA.COD_SEXO % TYPE,
    p_telefono IN VDIR_PERSONA.TELEFONO % TYPE,
    p_celular IN VDIR_PERSONA.CELULAR % TYPE,
    p_email IN VDIR_PERSONA.EMAIL % TYPE,
    p_usuario IN VDIR_USUARIO.LOGIN % TYPE,
    p_clave IN VDIR_USUARIO.CLAVE % TYPE,
    p_tipo_persona IN VDIR_TIPO_PERSONA.COD_TIPO_PERSONA % TYPE,
    p_plan IN VDIR_PLAN.COD_PLAN % TYPE,
    p_cod_estado IN VDIR_ESTADO.COD_ESTADO % TYPE,
    p_corte IN VDIR_USUARIO.CORTE % TYPE,
    p_respuesta OUT VARCHAR2
);

------------------------------------------------ PROCEDIMIENTO PARA ACTUALIZAR EL CODIGO DE SEGURIDAD PARA CAMBIAR LA CLAVE
PROCEDURE VDIR_SP_ACTUALIZAR_COD_SEG (
    p_identificacacion IN VDIR_PERSONA.numero_identificacion % TYPE,
    p_codigo_seguridad OUT VDIR_USUARIO.CODIGO_SEGURIDAD % TYPE
);

------------------------------------------------ PROCEDIMIENTO PARA ACTUALIZAR LA CLAVE DEL USUARIO
PROCEDURE VDIR_SP_CAMBIAR_CLAVE (
    p_identificacacion IN VDIR_PERSONA.numero_identificacion % TYPE,
    p_codigo_seguridad IN VDIR_USUARIO.CODIGO_SEGURIDAD % TYPE,
    p_clave IN VDIR_USUARIO.CLAVE % TYPE,
    p_respuesta OUT VARCHAR2
);

------------------------------------------------FUNCION PARA TRAER LOS DAOS DE LA PERSONA,USUAIRO Y ROLES 
FUNCTION VDIR_FN_GET_DATOS_USUARIO (
    p_login IN vdir_usuario.login % TYPE,
    p_clave IN vdir_usuario.clave % TYPE
) RETURN sys_refcursor;

-------------------------------------------------FUNCION PARA TRAER LOS ROLES QUE TIENE UNA PERSONA 
FUNCTION VDIR_FN_GET_ROLES_PERSONA (p_cod_user IN vdir_usuario.cod_usuario % TYPE) RETURN VARCHAR2;

------------------------------------------------ PROCEDIMIENTO PARA INSERTAR EL LOG DE USUARIO
PROCEDURE VDIR_SP_INSERT_LOG_USER (
    p_login IN VDIR_USUARIO.login % TYPE,
    p_ip IN VARCHAR2,
    p_navegador IN VARCHAR2
);

------------------------------------------------ FUNCION PARA TRAER LAS IMAGENES DE LAS PROMOCIONES DE LOS PRODUCTOS 
FUNCTION VDIR_FN_GET_DATOS_IMG_PROMO (
    p_codigo_plan IN vdir_plan.cod_plan % TYPE DEFAULT NULL
) RETURN sys_refcursor;

------------------------------------------------ FUNCION PARA ENVIAR EMAILS 
FUNCTION VDIR_FN_SEND_EMAIL (
    p_to IN CLOB,
    p_asunto IN CLOB,
    p_mensaje IN CLOB,
    p_mensaje2 IN CLOB DEFAULT ''
) RETURN VARCHAR2;

/*---------------------------------------------------------------------
fn_get_keyPagesNot: Traer el key calss de las paginas a las que el usuario no tiene acceso
---------------------------------------------------------------------- */
FUNCTION fn_get_keyPagesNot (
    pty_cod_usuario in vdir_usuario.cod_usuario % type
) RETURN VARCHAR2;

END VDIR_PACK_INICIO_SESSION;
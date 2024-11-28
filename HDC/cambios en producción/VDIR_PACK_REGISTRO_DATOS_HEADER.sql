create
or replace PACKAGE VDIR_PACK_REGISTRO_DATOS AS
/* ---------------------------------------------------------------------
Copyright  Tecnología Informática Coomeva - Colombia
Package     : VDIR_PACK_REGISTRO_DATOS
Caso de Uso : 
Descripción : Procesos para la ejecucion del requerimiento Registro datos basicos - VENTA DIRECTA
--------------------------------------------------------------------
Autor : diego.castillo@kalettre.com
Fecha : 03-12-2018  
--------------------------------------------------------------------
Procedimiento :     Descripcion:
--------------------------------------------------------------------
Historia de Modificaciones
---------------------------------------------------------------------
Fecha Autor Modificación
----------------------------------------------------------------- */
----------------------------------------------------------------------------
-- Declaracion de estructuras dinamicas
----------------------------------------------------------------------------
TYPE type_cursor IS REF CURSOR;

TYPE datasplit_record IS RECORD (idx NUMBER, dato VARCHAR2(4000));

TYPE datasplit_table IS TABLE OF datasplit_record;

/*---------------------------------------------------------------------
fn_get_contratante: Traer la informacion del usuario contratante
----------------------------------------------------------------------- */
FUNCTION fn_get_contratante (
    pty_cod_usuario in vdir_usuario.cod_usuario % type
) RETURN type_cursor;

/*---------------------------------------------------------------------
fn_get_info_persona: Taer iformacion de la persona con el numero de y tipo de identificacion
----------------------------------------------------------------------- */
FUNCTION fn_get_info_persona (
    pty_num_indentificacion in vdir_persona.numero_identificacion % type,
    pty_tip_indentificacion in vdir_persona.cod_tipo_identificacion % type
) RETURN type_cursor;

/*---------------------------------------------------------------------
sp_set_beneficiario: Agregar beneficiario
----------------------------------------------------------------------- */
PROCEDURE sp_set_beneficiario (
    p_cod_contratante in vdir_persona.cod_persona % type,
    p_cod_tipo_doc in vdir_persona.cod_tipo_identificacion % type,
    p_num_doc in vdir_persona.numero_identificacion % type,
    p_nombre_1 in vdir_persona.nombre_1 % type,
    p_nombre_2 in vdir_persona.nombre_2 % type,
    p_apellido_1 in vdir_persona.apellido_1 % type,
    p_apellido_2 in vdir_persona.apellido_2 % type,
    p_fecha_nacimiento in vdir_persona.fecha_nacimiento % type,
    p_telefono in vdir_persona.telefono % type,
    p_email in vdir_persona.email % type,
    p_cod_sexo in vdir_persona.cod_sexo % type,
    p_cod_municipio in vdir_persona.cod_municipio % type,
    p_celular in vdir_persona.celular % type,
    p_eps in vdir_persona.cod_eps % type,
    p_estado_civil in vdir_persona.cod_estado_civil % type,
    p_ind_tiene_mascota in vdir_persona.ind_tiene_mascota % type,
    p_tipo_via_dir in vdir_tipo_via.cod_tipo_via % type,
    p_num_tipo_via_dir in varchar2,
    p_num_placa_dir in varchar2,
    p_complemento_dir in varchar2,
    p_parentesco in vdir_parentesco.cod_parentesco % type,
    p_estado in vdir_persona.cod_estado % type,
    p_cod_afiliacion in vdir_afiliacion.cod_afiliacion % type,
    p_cod_direccion in vdir_persona.cod_direccion % type,
    p_cod_asesor in vdir_persona.cod_asesor % type,
    p_ced_referido in vdir_persona.cedula_referido % type,
    p_tipo_ced_referido in vdir_persona.tipo_identificacion_referido % type,
    p_cod_afiliacion_out out vdir_afiliacion.cod_afiliacion % type
);

/*---------------------------------------------------------------------
fn_get_afiliacion_pendiente: Trae afiliacion pendiente
----------------------------------------------------------------------- */
FUNCTION fn_get_afiliacion_pendiente (
    pty_cod_usuario in vdir_usuario.cod_usuario % type
) RETURN vdir_afiliacion.cod_afiliacion % type;

/*---------------------------------------------------------------------
fn_get_benficiarios_contra: Traer los beneficiarios que esta registrando un contratante
----------------------------------------------------------------------- */
FUNCTION fn_get_benficiarios_contra (
    pty_cod_usuario in vdir_usuario.cod_usuario % type
) RETURN type_cursor;

/*---------------------------------------------------------------------
sp_quitar_contra_benefi: Quitar la relacion entre el contratante y los beneficiarios de una afiliacion pendiente
----------------------------------------------------------------------- */
PROCEDURE sp_quitar_contra_benefi (
    pty_cod_usuario in vdir_usuario.cod_usuario % type,
    pnu_result out numeric
);

/*---------------------------------------------------------------------
sp_cambiar_estado_contra_benefi: Cambiar de estado la relacion entre el contratante y los beneficiarios de una afiliacion pendiente
---------------------------------------------------------------------- */
PROCEDURE sp_set_estado_contra_benefi (
    pty_cod_usuario in vdir_usuario.cod_usuario % type,
    pty_cod_estado in vdir_estado.cod_estado % type
);

/* ------------------------------------------
fn_splitData: funcion para retornar tabla con los datos de una cadena separados por un caracter
-- ------------------------------------------  */
FUNCTION fn_splitData (
    P_STRING_DATA IN VARCHAR2,
    P_SEPARATOR IN VARCHAR2
) RETURN datasplit_table PIPELINED;

-- ---------------------------------------------------------------------
-- fnGetProgramasBeneficiario
-- --------------------------------------------------------------------- 
FUNCTION fnGetProgramasBeneficiario (
    inu_codBeneficiario IN VDIR_BENEFICIARIO_PROGRAMA.COD_BENEFICIARIO % TYPE,
    inu_codAfiliacion IN VDIR_AFILIACION.COD_AFILIACION % TYPE
) RETURN VARCHAR2;

/*---------------------------------------------------------------------
fn_get_habeasData: Traer el texto habeas datada para la compra de productos
---------------------------------------------------------------------- */
FUNCTION fn_get_habeasData (p_tipo VARCHAR2) RETURN VARCHAR2;

END VDIR_PACK_REGISTRO_DATOS;
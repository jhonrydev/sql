create
or replace PACKAGE VDIR_PACK_CONSULTA_USUARIOS AS
/* ---------------------------------------------------------------------
Copyright  Tecnología Informática Coomeva - Colombia
Package     : VDIR_PACK_CONSULTA_USUARIOS
Caso de Uso : 
Descripción : Procesos para la consulta los usuarios - VENTA DIRECTA
--------------------------------------------------------------------
Autor : katherine.latorre@kalettre.com
Fecha : 29-01-2019 
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
-- fnGetUsuarios
-- ---------------------------------------------------------------------
FUNCTION fnGetUsuarios RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetTiposIdentificacion
-- ---------------------------------------------------------------------
FUNCTION fnGetTiposIdentificacion RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetPerfiles
-- ---------------------------------------------------------------------
FUNCTION fnGetPerfiles RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetUsuario
-- ---------------------------------------------------------------------
FUNCTION fnGetUsuario (
    inu_codUsuario IN VDIR_USUARIO.COD_USUARIO % TYPE,
    inu_codPersona IN VDIR_USUARIO.COD_PERSONA % TYPE,
    inu_codPerfil IN VDIR_ROL_USUARIO.COD_ROL % TYPE
) RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetExistePersona
-- ---------------------------------------------------------------------
FUNCTION fnGetExistePersona (
    inu_codTipoId IN VDIR_PERSONA.COD_TIPO_IDENTIFICACION % TYPE,
    inu_nroId IN VDIR_PERSONA.NUMERO_IDENTIFICACION % TYPE
) RETURN VDIR_PERSONA.COD_PERSONA % TYPE;

-- ---------------------------------------------------------------------
-- fnGetExisteLogin
-- ---------------------------------------------------------------------
FUNCTION fnGetExisteLogin (ivc_login IN VDIR_USUARIO.LOGIN % TYPE) RETURN VDIR_USUARIO.COD_USUARIO % TYPE;

-- ---------------------------------------------------------------------
-- fnGetExistePerfil
-- ---------------------------------------------------------------------
FUNCTION fnGetExistePerfil (
    inu_codUsuario IN VDIR_ROL_USUARIO.COD_USUARIO % TYPE,
    inu_codPerfil IN VDIR_ROL_USUARIO.COD_ROL % TYPE
) RETURN VDIR_ROL_USUARIO.COD_ROL_USUARIO % TYPE;

-- ---------------------------------------------------------------------
-- fnGetValidaClaveActual
-- ---------------------------------------------------------------------
FUNCTION fnGetValidaClaveActual (
    inu_codUsuario IN VDIR_USUARIO.COD_USUARIO % TYPE,
    ivc_clave IN VDIR_USUARIO.CLAVE % TYPE
) RETURN VDIR_USUARIO.COD_USUARIO % TYPE;

END VDIR_PACK_CONSULTA_USUARIOS;
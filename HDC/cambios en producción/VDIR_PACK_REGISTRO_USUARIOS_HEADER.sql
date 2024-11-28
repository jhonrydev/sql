create or replace PACKAGE VDIR_PACK_REGISTRO_USUARIOS AS
/* ---------------------------------------------------------------------
 Copyright  Tecnología Informática Coomeva - Colombia
 Package     : VDIR_PACK_REGISTRO_USUARIOS
 Caso de Uso : 
 Descripción : Procesos para el registro del los usuarios - VENTA DIRECTA
 --------------------------------------------------------------------
 Autor : katherine.latorre@kalettre.com
 Fecha : 30-01-2018  
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
	-- prGuardarUsuario
	-- ---------------------------------------------------------------------
	PROCEDURE prGuardarUsuario
	(
		inu_codTipoId         IN VDIR_PERSONA.COD_TIPO_IDENTIFICACION%TYPE,
        inu_nroId             IN VDIR_PERSONA.NUMERO_IDENTIFICACION%TYPE,
		ivc_primerNombre      IN VDIR_PERSONA.NOMBRE_1%TYPE,
		ivc_segundoNombre     IN VDIR_PERSONA.NOMBRE_2%TYPE,
		ivc_primerApellido    IN VDIR_PERSONA.APELLIDO_1%TYPE,
		ivc_segundoApellido   IN VDIR_PERSONA.APELLIDO_2%TYPE,
		ivc_correoElectronico IN VDIR_PERSONA.EMAIL%TYPE,
		ivc_telefono          IN VDIR_PERSONA.TELEFONO%TYPE,
		ivc_login             IN VDIR_USUARIO.LOGIN%TYPE,
		ivc_clave             IN VDIR_USUARIO.CLAVE%TYPE,
		inu_codPerfil         IN VDIR_ROL_USUARIO.COD_ROL%TYPE,
		inu_codEstado         IN VDIR_USUARIO.COD_ESTADO%TYPE
    );

	-- ---------------------------------------------------------------------
	-- prActualizarUsuario
	-- ---------------------------------------------------------------------
	PROCEDURE prActualizarUsuario
	(
	    inu_codUsuario   IN VDIR_USUARIO.COD_USUARIO%TYPE,
        inu_codPerfil    IN VDIR_ROL_USUARIO.COD_ROL%TYPE,
		inu_codEstado    IN VDIR_USUARIO.COD_ESTADO%TYPE
    );

	-- ---------------------------------------------------------------------
	-- prActualizarClave
	-- ---------------------------------------------------------------------
	PROCEDURE prActualizarClave
	(
	    inu_codUsuario IN VDIR_USUARIO.COD_USUARIO%TYPE,
        ivc_clave      IN VDIR_USUARIO.CLAVE%TYPE
    );

END VDIR_PACK_REGISTRO_USUARIOS;
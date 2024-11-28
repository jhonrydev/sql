create or replace PACKAGE BODY VDIR_PACK_CONSULTA_USUARIOS AS
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
    -- fnGetUsuarios
    -- ---------------------------------------------------------------------
    FUNCTION fnGetUsuarios RETURN type_cursor IS
	
	/* ---------------------------------------------------------------------
	 Copyright   : Tecnología Informática Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_USUARIOS
	 Caso de Uso : 
	 Descripción : Retorna los datos de los usuarios
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 29-01-2019  
	 ----------------------------------------------------------------------
	 Parámetros :     Descripción:
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificación
	 ----------------------------------------------------------------- */
	 
		ltc_datos type_cursor;
	
	BEGIN 
	 
		  OPEN ltc_datos FOR
		SELECT tiid.des_abr,
			   pers.numero_identificacion,
			   pers.nombre_1,
			   pers.apellido_1,
			   usua.login,
			   pers.email,
			   vrol.des_rol,
			   pers.cod_persona,
			   usua.cod_usuario,
			   vrol.cod_rol
		  FROM VDIR_USUARIO             usua,
		       VDIR_PERSONA             pers,
			   VDIR_TIPO_IDENTIFICACION tiid,
			   VDIR_ROL_USUARIO         rous,
			   VDIR_ROL                 vrol
	 	 WHERE usua.cod_persona             = pers.cod_persona
		   AND pers.cod_tipo_identificacion = tiid.cod_tipo_identificacion
		   AND usua.cod_usuario             = rous.cod_usuario
		   AND rous.cod_rol                 = vrol.cod_rol
		   AND rous.cod_rol                 <> 1;
		   
		RETURN ltc_datos;
	 
	END fnGetUsuarios;
	
	-- ---------------------------------------------------------------------
    -- fnGetTiposIdentificacion
    -- ---------------------------------------------------------------------
    FUNCTION fnGetTiposIdentificacion RETURN type_cursor IS
	
	/* ---------------------------------------------------------------------
	 Copyright   : Tecnología Informática Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_USUARIOS
	 Caso de Uso : 
	 Descripción : Retorna los datos de los tipos de identificación
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 30-01-2019  
	 ----------------------------------------------------------------------
	 Parámetros :     Descripción:
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificación
	 ----------------------------------------------------------------- */
	 
		ltc_datos type_cursor;
	
	BEGIN 
	 
		  OPEN ltc_datos FOR
		SELECT tiid.cod_tipo_identificacion,
		       tiid.des_tipo_identificacion
		  FROM VDIR_TIPO_IDENTIFICACION tiid			   
	 	 WHERE tiid.cod_estado = 1;
		   
		RETURN ltc_datos;
	 
	END fnGetTiposIdentificacion;
	
	-- ---------------------------------------------------------------------
    -- fnGetPerfiles
    -- ---------------------------------------------------------------------
    FUNCTION fnGetPerfiles RETURN type_cursor IS
	
	/* ---------------------------------------------------------------------
	 Copyright   : Tecnología Informática Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_USUARIOS
	 Caso de Uso : 
	 Descripción : Retorna los datos de los perfiles
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 30-01-2019  
	 ----------------------------------------------------------------------
	 Parámetros :     Descripción:
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificación
	 ----------------------------------------------------------------- */
	 
		ltc_datos type_cursor;
	
	BEGIN 
	 
		  OPEN ltc_datos FOR
		SELECT vrol.cod_rol,
		       vrol.des_rol
		  FROM VDIR_ROL vrol			   
	 	 WHERE vrol.cod_estado = 1;
		   
		RETURN ltc_datos;
	 
	END fnGetPerfiles;
	
	-- ---------------------------------------------------------------------
    -- fnGetUsuario
    -- ---------------------------------------------------------------------
    FUNCTION fnGetUsuario 
	(
		inu_codUsuario IN VDIR_USUARIO.COD_USUARIO%TYPE,
		inu_codPersona IN VDIR_USUARIO.COD_PERSONA%TYPE,
		inu_codPerfil  IN VDIR_ROL_USUARIO.COD_ROL%TYPE
	)
	RETURN type_cursor IS
	
	/* ---------------------------------------------------------------------
	 Copyright   : Tecnología Informática Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_USUARIOS
	 Caso de Uso : 
	 Descripción : Retorna los datos del usuario
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 28-01-2019  
	 ----------------------------------------------------------------------
	 Parámetros :     Descripción:
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificación
	 ----------------------------------------------------------------- */
	 
		ltc_datos type_cursor;
	
	BEGIN 
	 
		  OPEN ltc_datos FOR
		SELECT pers.cod_tipo_identificacion,
			   pers.numero_identificacion,
			   pers.nombre_1,
			   pers.nombre_2,
			   pers.apellido_1,
			   pers.apellido_2,
			   pers.email,
			   pers.telefono,
			   rous.cod_rol,
			   usua.login,
			   usua.cod_estado,
			   pers.cod_persona,
			   usua.cod_usuario,
			   usua.clave
		  FROM VDIR_USUARIO      usua,
		       VDIR_PERSONA      pers,
			   VDIR_ROL_USUARIO  rous
	 	 WHERE usua.cod_persona  = pers.cod_persona
		   AND usua.cod_usuario  = rous.cod_usuario
		   AND pers.cod_persona  = inu_codPersona
		   AND usua.cod_usuario  = inu_codUsuario
		   AND rous.cod_rol      = inu_codPerfil;
		   
		RETURN ltc_datos;
	 
	END fnGetUsuario;
	
	-- ---------------------------------------------------------------------
    -- fnGetExistePersona
    -- ---------------------------------------------------------------------
    FUNCTION fnGetExistePersona 
	(
		inu_codTipoId IN VDIR_PERSONA.COD_TIPO_IDENTIFICACION%TYPE,
        inu_nroId     IN VDIR_PERSONA.NUMERO_IDENTIFICACION%TYPE
	)
	RETURN VDIR_PERSONA.COD_PERSONA%TYPE IS
	
	/* ---------------------------------------------------------------------
	 Copyright   : Tecnología Informática Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_USUARIOS
	 Caso de Uso : 
	 Descripción : Retorna el código de la persona
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 31-01-2019  
	 ----------------------------------------------------------------------
	 Parámetros :     Descripción:
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificación
	 ----------------------------------------------------------------- */
	 
		lnu_codPersona VDIR_PERSONA.COD_PERSONA%TYPE;
	
	BEGIN 
	 
		BEGIN 
		
			SELECT cod_persona 
			  INTO lnu_codPersona   
			  FROM VDIR_PERSONA 
			 WHERE numero_identificacion   = inu_nroId 
			   AND cod_tipo_identificacion = inu_codTipoId;
			   
		EXCEPTION WHEN OTHERS THEN  
			lnu_codPersona := NULL;
		END;       
			   
		RETURN lnu_codPersona;
	 
	END fnGetExistePersona;
	
	-- ---------------------------------------------------------------------
    -- fnGetExisteLogin
    -- ---------------------------------------------------------------------
    FUNCTION fnGetExisteLogin 
	(
		ivc_login  IN VDIR_USUARIO.LOGIN%TYPE
	)
	RETURN VDIR_USUARIO.COD_USUARIO%TYPE IS
	
	/* ---------------------------------------------------------------------
	 Copyright   : Tecnología Informática Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_USUARIOS
	 Caso de Uso : 
	 Descripción : Retorna el código del usuario si el login existe
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 31-01-2019  
	 ----------------------------------------------------------------------
	 Parámetros :     Descripción:
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificación
	 ----------------------------------------------------------------- */
	 
		lnu_codUsuario VDIR_USUARIO.COD_USUARIO%TYPE;
	
	BEGIN 
	 
		BEGIN 
		
			SELECT cod_usuario INTO lnu_codUsuario       
              FROM VDIR_USUARIO
             WHERE UPPER(login) = UPPER(ivc_login);
			   
		EXCEPTION WHEN OTHERS THEN  
			lnu_codUsuario := NULL;
		END;       
			   
		RETURN lnu_codUsuario;
	 
	END fnGetExisteLogin;
	
	-- ---------------------------------------------------------------------
    -- fnGetExistePerfil
    -- ---------------------------------------------------------------------
    FUNCTION fnGetExistePerfil 
	(
		inu_codUsuario   IN VDIR_ROL_USUARIO.COD_USUARIO%TYPE,
        inu_codPerfil    IN VDIR_ROL_USUARIO.COD_ROL%TYPE
	)
	RETURN VDIR_ROL_USUARIO.COD_ROL_USUARIO%TYPE IS
	
	/* ---------------------------------------------------------------------
	 Copyright   : Tecnología Informática Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_USUARIOS
	 Caso de Uso : 
	 Descripción : Retorna el código del usuario asocido al rol
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 31-01-2019  
	 ----------------------------------------------------------------------
	 Parámetros :     Descripción:
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificación
	 ----------------------------------------------------------------- */
	 
		lnu_codRolUsuario VDIR_ROL_USUARIO.COD_ROL_USUARIO%TYPE;
	
	BEGIN 
	 
		BEGIN 
		
			SELECT cod_rol_usuario INTO lnu_codRolUsuario       
              FROM VDIR_ROL_USUARIO
             WHERE cod_usuario = inu_codUsuario
			   AND cod_rol     = inu_codPerfil;
			   
		EXCEPTION WHEN OTHERS THEN  
			lnu_codRolUsuario := NULL;
		END;       
			   
		RETURN lnu_codRolUsuario;
	 
	END fnGetExistePerfil;
	
	-- ---------------------------------------------------------------------
    -- fnGetValidaClaveActual
    -- ---------------------------------------------------------------------
    FUNCTION fnGetValidaClaveActual 
	(
		inu_codUsuario IN VDIR_USUARIO.COD_USUARIO%TYPE,
        ivc_clave      IN VDIR_USUARIO.CLAVE%TYPE
	)
	RETURN VDIR_USUARIO.COD_USUARIO%TYPE IS
	
	/* ---------------------------------------------------------------------
	 Copyright   : Tecnología Informática Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_USUARIOS
	 Caso de Uso : 
	 Descripción : Retorna el código del usuario si la clave es correcta
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 01-02-2019  
	 ----------------------------------------------------------------------
	 Parámetros :     Descripción:
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificación
	 ----------------------------------------------------------------- */
	 
		lnu_codUsuario VDIR_USUARIO.COD_USUARIO%TYPE;
	
	BEGIN 
	 
		BEGIN 
		
			SELECT cod_usuario INTO lnu_codUsuario       
              FROM VDIR_USUARIO
             WHERE cod_usuario = inu_codUsuario
			   AND clave       = ivc_clave;
			   
		EXCEPTION WHEN OTHERS THEN  
			lnu_codUsuario := NULL;
		END;       
			   
		RETURN lnu_codUsuario;
	 
	END fnGetValidaClaveActual;
		
END VDIR_PACK_CONSULTA_USUARIOS;
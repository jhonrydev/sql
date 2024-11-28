CREATE OR REPLACE PACKAGE           PSGEN_SNDAceptaDocTyC_HD
AS
   /* -----------------------------------------------------------------------------
   Copyright ¿Coomeva S.A. - Colombia
   Package : PSGEN_SNDAceptaDocTyC_HD
   Caso de Uso :
   Descripci¿ :  Obtiene versiones y documentos de TyC y HD
   -------------------------------------------------------------------------------
   Autor : 
   Fecha : 15-10-2023
   -------------------------------------------------------------------------------
   Procedimiento : Descripcion:
   -------------------------------------------------------------------------------
   Historia de Modificaciones
   -------------------------------------------------------------------------------
   Fecha Autor Modificaci¿
   ------------------------------------------------------------------------------*/
   TYPE TYPE_CURSOR IS REF CURSOR;

  PROCEDURE fncu_getDocTyC_HD(pty_tipo_doc    IN ADM_VERSION_DOCUMENTOS.tipo_documento%type,
							  pty_cod_app     IN ADM_VERSION_DOCUMENTOS.codigo_app%type,
						      codError OUT NUMBER,
						      msgError OUT VARCHAR2,
						      registros OUT SYS_REFCURSOR);

  PROCEDURE fncu_getVersionDocTyC_HD(pty_tipo_id    IN ACEPTA_TERMINOS_INFOMEDICA.TIPO_DOCUMENTO%type,
							         pty_num_id     IN ACEPTA_TERMINOS_INFOMEDICA.NUMERO_DOCUMENTO%TYPE,
							         pty_cod_app    IN ADM_VERSION_DOCUMENTOS.codigo_app%type,
						             codError OUT NUMBER,
						             msgError OUT VARCHAR2,
						             registros OUT SYS_REFCURSOR);


 END PSGEN_SNDAceptaDocTyC_HD;






CREATE OR REPLACE PACKAGE BODY           PSGEN_SNDAceptaDocTyC_HD AS

  PROCEDURE fncu_getDocTyC_HD(pty_tipo_doc    IN ADM_VERSION_DOCUMENTOS.tipo_documento%type,
 						      pty_cod_app     IN ADM_VERSION_DOCUMENTOS.codigo_app%type,
						      codError OUT NUMBER,
						      msgError OUT VARCHAR2,
						      registros OUT SYS_REFCURSOR)
   AS

	CURSOR cu_app IS

		Select COUNT(1)
		  from ADM_VERSION_DOCUMENTOS 
		 where codigo_app     = pty_cod_app;

	CURSOR cu_tyc IS

		Select COUNT(1)
		 from ADM_VERSION_DOCUMENTOS 
		where id = (Select max(id) 
					  from ADM_VERSION_DOCUMENTOS 
					 where tipo_documento = 'Términos y Condiciones'
					   and codigo_app     = pty_cod_app);

	CURSOR cu_hd IS

		Select COUNT(1)
		 from ADM_VERSION_DOCUMENTOS 
		where id = (Select max(id) 
					  from ADM_VERSION_DOCUMENTOS 
					 where tipo_documento = 'Política de Tratamiento de Datos'
					   and codigo_app     = pty_cod_app);

	lty_cantDoc  NUMBER;
	lty_cantTyC  NUMBER;
	lty_cantHD   NUMBER;

   BEGIN    

		-- Se consulta si la app tiene documentos parametrizados
		OPEN cu_app;
		FETCH cu_app INTO  lty_cantDoc;	
		CLOSE cu_app;

		IF (lty_cantDoc > 0) THEN

			IF (pty_tipo_doc='TyC') THEN

				-- Se consulta si existe al menos un documento parametrizado
				OPEN cu_tyc;
				FETCH cu_tyc INTO  lty_cantTyC;	
				CLOSE cu_tyc;

				IF (lty_cantTyC > 0) THEN

					OPEN registros FOR

					   --Select Version, DECOMPOSE(descripcion) descripcion
					   Select Version, descripcion
						 from ADM_VERSION_DOCUMENTOS 
						where id = (Select max(id) 
									  from ADM_VERSION_DOCUMENTOS 
									 where tipo_documento = 'Términos y Condiciones'
									   and codigo_app     = pty_cod_app);

					codError := 0;
					msgError := 'Ok';
				ELSE 
					codError := 3;
					msgError := 'No existe una version de documento parametrizada para la aplicacion y tipo de documento';				
				END IF;

			ELSIF (pty_tipo_doc='HD') THEN

				-- Se consulta si existe al menos un documento parametrizado
				OPEN cu_hd;
				FETCH cu_hd INTO  lty_cantHD;	
				CLOSE cu_hd;

				IF (lty_cantHD > 0) THEN

					OPEN registros FOR

					   --Select Version, DECOMPOSE(descripcion) descripcion
					   Select Version, descripcion
						 from ADM_VERSION_DOCUMENTOS 
						where id = (Select max(id) 
									  from ADM_VERSION_DOCUMENTOS 
									 where tipo_documento = 'Política de Tratamiento de Datos'
									   and codigo_app     = pty_cod_app);

					codError := 0;
					msgError := 'Ok';

				ELSE 
					codError := 3;
					msgError := 'No existe una version de documento parametrizada para la aplicacion y tipo de documento';				
				END IF;

			ELSE

				codError := 1;
				msgError := 'El tipo de documento no existe, los tipos de documentos existentes son TyC/HD';

			END IF;
		ELSE 
			codError := 2;
			msgError := 'La aplicacion no existe o no tiene documentos parametrizados';		
		END IF;

  END fncu_getDocTyC_HD; 

  PROCEDURE fncu_getVersionDocTyC_HD(pty_tipo_id    IN ACEPTA_TERMINOS_INFOMEDICA.TIPO_DOCUMENTO%type,
							         pty_num_id     IN ACEPTA_TERMINOS_INFOMEDICA.NUMERO_DOCUMENTO%TYPE,
							         pty_cod_app    IN ADM_VERSION_DOCUMENTOS.codigo_app%type,
						             codError OUT NUMBER,
						             msgError OUT VARCHAR2,
						             registros OUT SYS_REFCURSOR)

   AS


   BEGIN    

	codError:=0;

	IF (pty_tipo_id IS NULL OR pty_tipo_id = '')THEN
		codError := 5;
		msgError := 'El parametro de entrada Tipo Documento Usuario es obligatorio';			
	END IF;
	IF (pty_num_id IS NULL OR pty_num_id = '')THEN
		codError := 5;
		msgError := 'El parametro de entrada Numero Documento Usuario es obligatorio';			
	END IF;
	IF (pty_cod_app IS NULL OR pty_cod_app = '')THEN
		codError := 5;
		msgError := 'El parametro de entrada Aplicacion es obligatorio';			
	END IF;

	IF (codError = 0) THEN 

		OPEN registros FOR

			SELECT 
			(Select Version 
			 from ADM_VERSION_DOCUMENTOS 
			where id = (Select max(id) 
						  from ADM_VERSION_DOCUMENTOS 
						 where tipo_documento = 'Términos y Condiciones'
						   and codigo_app     = pty_cod_app))vTyCVigente,
			(SELECT VERSION_DOCUMENTO 
			   FROM ACEPTA_TERMINOS_INFOMEDICA 
			 WHERE CONSECUTIVO = (SELECT MAX(CONSECUTIVO) 
									FROM ACEPTA_TERMINOS_INFOMEDICA
								   WHERE tipo_documento    = pty_tipo_id
									 AND NUMERO_DOCUMENTO  = pty_num_id
									 AND NOMBRE_APLICACION = pty_cod_app))vTyCAcepta,
			(Select Version 
			 from ADM_VERSION_DOCUMENTOS 
			where id = (Select max(id) 
						  from ADM_VERSION_DOCUMENTOS 
						 where tipo_documento = 'Política de Tratamiento de Datos'
						   and codigo_app     = pty_cod_app))vHDVigente,
			(SELECT VERSION_DOCUMENTO 
			   FROM ACEPTA_TERMINOS_HD 
			 WHERE CONSECUTIVO = (SELECT MAX(CONSECUTIVO) 
									FROM ACEPTA_TERMINOS_HD
								   WHERE tipo_documento    = pty_tipo_id
									 AND NUMERO_DOCUMENTO  = pty_num_id
									 AND NOMBRE_APLICACION = pty_cod_app))vHDAcepta                         
			FROM DUAL;



			codError := 0;
			msgError := 'Ok';

	END IF;		

  END fncu_getVersionDocTyC_HD; 

END PSGEN_SNDAceptaDocTyC_HD;
create or replace PACKAGE BODY VDIR_PACK_REGISTRO_CONTRATO AS
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
	-- prGuardarContratoAdobe
	-- ---------------------------------------------------------------------
	PROCEDURE prGuardarContratoAdobe
	(
		inu_codPersona        IN VDIR_PERSONA_CONTRATO.COD_PERSONA%TYPE, 
		inu_codPrograma       IN VDIR_PERSONA_CONTRATO.COD_PROGRAMA%TYPE,
		inu_codAfiliacion     IN VDIR_PERSONA_CONTRATO.COD_AFILIACION%TYPE,
		ivc_nroContratoAdobe  IN VDIR_PERSONA_CONTRATO.NUMERO_CONTRATO_ADOBE%TYPE
    ) 
	IS
	
	/* ---------------------------------------------------------------------
	 Copyright   : Tecnología Informática Coomeva - Colombia
	 Package     : VDIR_PACK_REGISTRO_CONTRATO
	 Caso de Uso : 
	 Descripción : Procedimiento que guarda el contrato de Adobe Sign 
	               asociado a la persona y al programa
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 14-01-2019  
	 ----------------------------------------------------------------------
	 Parámetros :     Descripción:
	   inu_codPersona        Código de la persona contratante
	   inu_codPrograma       Código del programa
	   inu_codAfiliacion     Código de la afiliación
	   ivc_nroContratoAdobe  Número del contrato proveniente de Adobe Sign
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificación
	 ----------------------------------------------------------------- */
	 
	    lnu_codPersonaContrato VDIR_PERSONA_CONTRATO.COD_PERSONA_CONTRATO%TYPE;
	
	BEGIN
		
	    -- ---------------------------------------------------------------------
		-- Se avanza la secuencia
		-- --------------------------------------------------------------------- 
	    SELECT VDIR_SEQ_PERSONACONTRATO.NEXTVAL INTO lnu_codPersonaContrato FROM DUAL;   
		
		BEGIN
		
		    -- ---------------------------------------------------------------------
			-- Se ingresa la persona asociada al contrato
			-- --------------------------------------------------------------------- 
			INSERT INTO VDIR_PERSONA_CONTRATO
			(
				COD_PERSONA_CONTRATO, 
				COD_PERSONA, 
				COD_PROGRAMA, 
				COD_AFILIACION,
				NUMERO_CONTRATO_ADOBE
			) 
			VALUES 
			(
				lnu_codPersonaContrato,
				inu_codPersona,
				inu_codPrograma,
				inu_codAfiliacion,
				ivc_nroContratoAdobe
			);
			
		EXCEPTION WHEN OTHERS THEN
		
		    RAISE_APPLICATION_ERROR(-20001,'Ocurrió un error al guardar el contrato: '||SQLERRM); 
		
		END;		
	 
	END prGuardarContratoAdobe;	
	
	-- ---------------------------------------------------------------------
	-- prActualizarAfiliacion
	-- ---------------------------------------------------------------------
	PROCEDURE prActualizarAfiliacion
	(		
		inu_codAfiliacion     IN VDIR_AFILIACION.COD_AFILIACION%TYPE
    )
	IS
	
	/* ---------------------------------------------------------------------
	 Copyright   : Tecnología Informática Coomeva - Colombia
	 Package     : VDIR_PACK_REGISTRO_CONTRATO
	 Caso de Uso : 
	 Descripción : Procedimiento que actualiza el estado de la afiliación
	               para enviarla a la bandeja de operaciones
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 21-02-2019  
	 ----------------------------------------------------------------------
	 Parámetros :     Descripción:	  
	   inu_codAfiliacion     Código de la afiliación	 
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificación
	 ----------------------------------------------------------------- */
	 
	 	
	BEGIN
		
	 	BEGIN
		
		    -- ---------------------------------------------------------------------
			-- Se actualiza el estado de la solicitud
			-- --------------------------------------------------------------------- 
			UPDATE VDIR_AFILIACION
			   SET cod_estado      = 7
		     WHERE cod_afiliacion  = inu_codAfiliacion;
			
		EXCEPTION WHEN OTHERS THEN
		
		    RAISE_APPLICATION_ERROR(-20001,'Ocurrió un error al actualizar la afiliación para enviar a la bandeja: '||SQLERRM); 
		
		END;		
	 
	END prActualizarAfiliacion;
 
END VDIR_PACK_REGISTRO_CONTRATO;
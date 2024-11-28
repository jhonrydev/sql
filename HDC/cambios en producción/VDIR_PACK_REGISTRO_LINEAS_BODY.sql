create or replace PACKAGE BODY VDIR_PACK_REGISTRO_LINEAS AS
/* ---------------------------------------------------------------------
 Copyright  Tecnolog¿a Inform¿tica Coomeva - Colombia
 Package     : VDIR_PACK_REGISTRO_LINEAS
 Caso de Uso : 
 Descripci¿n : Procesos para el registro del los programas asociados al 
               plan - VENTA DIRECTA
 --------------------------------------------------------------------
 Autor : katherine.latorre@kalettre.com
 Fecha : 25-01-2018  
 --------------------------------------------------------------------
 Procedimiento :     Descripcion:
 --------------------------------------------------------------------
 Historia de Modificaciones
 ---------------------------------------------------------------------
 Fecha Autor Modificaci¿n
 ----------------------------------------------------------------- */
 
	-- ---------------------------------------------------------------------
	-- prGuardarPlanPrograma
	-- ---------------------------------------------------------------------
	PROCEDURE prGuardarPlanPrograma
	(
		inu_codPlan           IN VDIR_PLAN_PROGRAMA.COD_PLAN%TYPE, 
		inu_codPrograma       IN VDIR_PLAN_PROGRAMA.COD_PROGRAMA%TYPE,
		inu_codEstado         IN VDIR_PLAN_PROGRAMA.COD_ESTADO%TYPE,
		ivc_coberturaInicial  IN VDIR_PLAN_PROGRAMA.COBERTURA_INICIAL%TYPE,
		ivc_coberturaFinal    IN VDIR_PLAN_PROGRAMA.COBERTURA_FINAL%TYPE,
        ivc_codProgramaHologa IN VDIR_PLAN_PROGRAMA.COD_PROGRAMA_HOMOLOGA%TYPE,
        ivc_cuenta IN VDIR_PLAN_PROGRAMA.CUENTA%TYPE,
        ivc_sub_cuenta IN VDIR_PLAN_PROGRAMA.SUB_CUENTA%TYPE,
        ivc_programa IN VDIR_PLAN_PROGRAMA.PROGRAMA%TYPE,
        ivc_tarifa IN VDIR_PLAN_PROGRAMA.TARIFA%TYPE,
        ivc_edadIni IN VDIR_PLAN_PROGRAMA.EDAD_INI%TYPE,
        ivc_edadFin IN VDIR_PLAN_PROGRAMA.EDAD_FIN%TYPE,
        ivc_errorMesg IN VDIR_PLAN_PROGRAMA.MENSAJE_ERROR%TYPE,
        ivc_isFree              IN VDIR_PLAN_PROGRAMA.SWITCH_MES%TYPE,
        ivc_fechaPrimerMes             IN VDIR_PLAN_PROGRAMA.FECHA_FIN_PROMOCION%TYPE
    )
	IS
	
	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog¿a Inform¿tica Coomeva - Colombia
	 Package     : VDIR_PACK_REGISTRO_LINEAS
	 Caso de Uso : 
	 Descripci¿n : Procedimiento que guarda el plan programa
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 25-01-2019  
	 ----------------------------------------------------------------------
	 Par¿metros :     Descripci¿n:
	   inu_codPlan           C¿digo del plan
	   inu_codPrograma       C¿digo del programa
	   inu_codEstado         C¿digo del estado
	   ivc_coberturaInicial  Cobertura inicial
	   ivc_coberturaFinal    Cobertura final
	   ivc_cuenta            Solicitado por operaciones
	   ivc_sub_cuenta        Solicitado por operaciones
	   ivc_programa          Solicitado por operaciones
	   ivc_tarifa            Solicitado por operaciones
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci¿n
	 ----------------------------------------------------------------- */
	 
	    lnu_codPlanPrograma VDIR_PLAN_PROGRAMA.COD_PLAN_PROGRAMA%TYPE;
	
	BEGIN
		
	    -- ---------------------------------------------------------------------
		-- Se avanza la secuencia
		-- --------------------------------------------------------------------- 
	    SELECT VDIR_SEQ_PLANPROGRAMA.NEXTVAL INTO lnu_codPlanPrograma FROM DUAL;   
		
		BEGIN
		
		    -- ---------------------------------------------------------------------
			-- Se ingresa el programa asociado al plan
			-- --------------------------------------------------------------------- 
			INSERT INTO VDIR_PLAN_PROGRAMA
			(
				COD_PLAN_PROGRAMA, 
				COD_PLAN,
				COD_PROGRAMA, 
				COD_ESTADO, 
				COBERTURA_INICIAL,
				COBERTURA_FINAL,
                COD_PROGRAMA_HOMOLOGA,
                CUENTA,
                SUB_CUENTA,
                PROGRAMA,
                TARIFA,
                edad_ini,
                edad_fin,
                mensaje_error,
                switch_mes,
                fecha_fin_promocion
			) 
			VALUES 
			(
			    lnu_codPlanPrograma,
				inu_codPlan,
				inu_codPrograma,
				inu_codEstado,
				ivc_coberturaInicial,
				ivc_coberturaFinal,
                ivc_codProgramaHologa,
                ivc_cuenta,
                ivc_sub_cuenta,
                ivc_programa,
                ivc_tarifa,
                ivc_edadIni,
                ivc_edadFin,
                ivc_errorMesg,
                ivc_isFree,
                ivc_fechaPrimerMes
			);
			
		EXCEPTION WHEN OTHERS THEN
		
		    RAISE_APPLICATION_ERROR(-20001,'Ocurri¿ un error al guardar el programa asociado al plan: '||SQLERRM); 
		
		END;
		
	END prGuardarPlanPrograma;
	
	-- ---------------------------------------------------------------------
	-- prActualizarPlanPrograma
	-- ---------------------------------------------------------------------
	PROCEDURE prActualizarPlanPrograma
	(
	    inu_codPlanPrograma   IN VDIR_PLAN_PROGRAMA.COD_PLAN_PROGRAMA%TYPE,
		inu_codPlan           IN VDIR_PLAN_PROGRAMA.COD_PLAN%TYPE, 
		inu_codPrograma       IN VDIR_PLAN_PROGRAMA.COD_PROGRAMA%TYPE,
		inu_codEstado         IN VDIR_PLAN_PROGRAMA.COD_ESTADO%TYPE,
		ivc_coberturaInicial  IN VDIR_PLAN_PROGRAMA.COBERTURA_INICIAL%TYPE,
		ivc_coberturaFinal    IN VDIR_PLAN_PROGRAMA.COBERTURA_FINAL%TYPE,
        ivc_codProgramaHologa IN VDIR_PLAN_PROGRAMA.COD_PROGRAMA_HOMOLOGA%TYPE,
        ivc_cuenta IN VDIR_PLAN_PROGRAMA.CUENTA%TYPE,
        ivc_sub_cuenta IN VDIR_PLAN_PROGRAMA.SUB_CUENTA%TYPE,
        ivc_programa IN VDIR_PLAN_PROGRAMA.PROGRAMA%TYPE,
        ivc_tarifa IN VDIR_PLAN_PROGRAMA.TARIFA%TYPE,
        ivc_edadIni IN VDIR_PLAN_PROGRAMA.EDAD_INI%TYPE,
        ivc_edadFin IN VDIR_PLAN_PROGRAMA.EDAD_FIN%TYPE
    )
	IS
	
	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog¿a Inform¿tica Coomeva - Colombia
	 Package     : VDIR_PACK_REGISTRO_LINEAS
	 Caso de Uso : 
	 Descripci¿n : Procedimiento que actualiza el plan programa
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 25-01-2019  
	 ----------------------------------------------------------------------
	 Par¿metros :     Descripci¿n:
	   inu_codPlanPrograma   C¿digo del plan asociado al programa
	   inu_codPlan           C¿digo del plan
	   inu_codPrograma       C¿digo del programa
	   inu_codEstado         C¿digo del estado
	   ivc_coberturaInicial  Cobertura inicial
	   ivc_coberturaFinal    Cobertura final
	   ivc_cuenta            Solicitado por operaciones
	   ivc_sub_cuenta        Solicitado por operaciones
	   ivc_programa          Solicitado por operaciones
	   ivc_tarifa            Solicitado por operaciones
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci¿n
	 ----------------------------------------------------------------- */
	
	BEGIN
			    	
		BEGIN
		
		    -- ---------------------------------------------------------------------
			-- Se actualiza el programa asociado al plan
			-- --------------------------------------------------------------------- 
			UPDATE VDIR_PLAN_PROGRAMA
			   SET COD_PLAN          = inu_codPlan,
				   COD_PROGRAMA      = inu_codPrograma, 
				   COD_ESTADO        = inu_codEstado, 
				   COBERTURA_INICIAL = ivc_coberturaInicial,
				   COBERTURA_FINAL   = ivc_coberturaFinal,
                   COD_PROGRAMA_HOMOLOGA = ivc_codProgramaHologa,
                   CUENTA            = ivc_cuenta,
                   SUB_CUENTA        = ivc_sub_cuenta,
                   PROGRAMA         = ivc_programa, 
                   TARIFA           = ivc_tarifa,
                   EDAD_INI         = ivc_edadIni,
                   EDAD_FIN         = ivc_edadFin
    
		     WHERE COD_PLAN_PROGRAMA = inu_codPlanPrograma;
	
		EXCEPTION WHEN OTHERS THEN
		
		    RAISE_APPLICATION_ERROR(-20001,'Ocurri¿ un error al guardar el programa asociado al plan: '||SQLERRM); 
		
		END;
		
	END prActualizarPlanPrograma;
 
END VDIR_PACK_REGISTRO_LINEAS;
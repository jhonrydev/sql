create or replace PACKAGE BODY VDIR_PACK_CONSULTA_TARIFAS AS
/* ---------------------------------------------------------------------
 Copyright  Tecnolog¿a Inform¿tica Coomeva - Colombia
 Package     : VDIR_PACK_CONSULTA_TARIFAS
 Caso de Uso : 
 Descripci¿n : Procesos para la consulta las tarifas - VENTA DIRECTA
 --------------------------------------------------------------------
 Autor : katherine.latorre@kalettre.com
 Fecha : 28-01-2019 
 --------------------------------------------------------------------
 Procedimiento :     Descripcion:
 --------------------------------------------------------------------
 Historia de Modificaciones
 ---------------------------------------------------------------------
 Fecha Autor Modificaci¿n
 ----------------------------------------------------------------- */

	-- ---------------------------------------------------------------------
    -- fnGetTarifas
    -- ---------------------------------------------------------------------
    FUNCTION fnGetTarifas RETURN type_cursor IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog¿a Inform¿tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_TARIFAS
	 Caso de Uso : 
	 Descripci¿n : Retorna los datos de los datos de los productos 
	               asociados a las tarifas
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 28-01-2019  
	 ----------------------------------------------------------------------
	 Par¿metros :     Descripci¿n:
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci¿n
	 ----------------------------------------------------------------- */

		ltc_datos type_cursor;

	BEGIN 

		  OPEN ltc_datos FOR
		SELECT tari.cod_tarifa,
               tari.cod_tarifa_mp,
               prod.cod_producto,
		       prod.des_producto,
			   prog.des_programa,
			   vpla.des_plan,
			   vtta.des_tipo_tarifa,
			   TO_CHAR(tari.fecha_vige_inicial, 'dd/mm/yyyy') fecha_vige_inicial,
			   TO_CHAR(tari.fecha_vige_fin, 'dd/mm/yyyy') fecha_vige_fin,
			   vest.des_estado,
			   cota.des_condicion_tarifa,
			   vsex.des_sexo,
               CONCAT(CONCAT(tari.edad_inicial, ' - '), tari.edad_final) rango_edades,
               cod_num_usuarios_tarifa as num_usuarios
		  FROM VDIR_TARIFA           tari,
		       VDIR_PLAN_PROGRAMA    plpr,
		       VDIR_PROGRAMA         prog,
		       VDIR_PRODUCTO         prod,
			   VDIR_PLAN             vpla,
			   VDIR_ESTADO           vest,
			   VDIR_TIPO_TARIFA      vtta,
			   VDIR_CONDICION_TARIFA cota,
			   VDIR_SEXO             vsex
	 	 WHERE tari.cod_plan_programa     = plpr.cod_plan_programa
		    AND plpr.cod_programa         = prog.cod_programa
			AND plpr.cod_plan             = vpla.cod_plan
			AND prog.cod_producto         = prod.cod_producto
			AND tari.cod_estado           = vest.cod_estado
			AND tari.cod_tipo_tarifa      = vtta.cod_tipo_tarifa
			AND tari.cod_condicion_tarifa = cota.cod_condicion_tarifa
			AND tari.cod_sexo             = vsex.cod_sexo(+)
			AND vest.cod_estado			  iN (1,2)
            ORDER BY decode(prod.cod_producto, 3,4,5,6,1,7,2),tari.cod_tarifa DESC, decode(vtta.des_tipo_tarifa, 'Promociones', 'Estandar'), fecha_vige_inicial ASC;

		RETURN ltc_datos;

	END fnGetTarifas;

	-- ---------------------------------------------------------------------
    -- fnGetTipoTarifas
    -- ---------------------------------------------------------------------
    FUNCTION fnGetTipoTarifas RETURN type_cursor IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog¿a Inform¿tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_TARIFAS
	 Caso de Uso : 
	 Descripci¿n : Retorna los datos de los tipos de tarifas
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 28-01-2019  
	 ----------------------------------------------------------------------
	 Par¿metros :     Descripci¿n:
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci¿n
	 ----------------------------------------------------------------- */

		ltc_datos type_cursor;

	BEGIN 

		  OPEN ltc_datos FOR
		SELECT vtta.cod_tipo_tarifa,
		       vtta.des_tipo_tarifa
		  FROM VDIR_TIPO_TARIFA   vtta			   
	 	 WHERE vtta.cod_estado = 1;

		RETURN ltc_datos;

	END fnGetTipoTarifas;

	-- ---------------------------------------------------------------------
    -- fnGetProgramasPlan
    -- ---------------------------------------------------------------------
    FUNCTION fnGetProgramasPlan 
	(
		inu_codPlan IN VDIR_PLAN_PROGRAMA.COD_PLAN%TYPE
	)
	RETURN type_cursor IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog¿a Inform¿tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_TARIFAS
	 Caso de Uso : 
	 Descripci¿n : Retorna los datos de los productos y programas por plan
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 28-01-2019  
	 ----------------------------------------------------------------------
	 Par¿metros :     Descripci¿n:
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci¿n
	 ----------------------------------------------------------------- */

		ltc_datos type_cursor;

	BEGIN 

		  OPEN ltc_datos FOR
		SELECT plpr.cod_plan_programa,
		       prod.des_producto||' - '||prog.des_programa des_plan_programa
		  FROM VDIR_PLAN_PROGRAMA plpr,
		       VDIR_PROGRAMA      prog,
			   VDIR_PRODUCTO      prod
	 	 WHERE plpr.cod_programa = prog.cod_programa
		   AND prog.cod_producto = prod.cod_producto
		   AND plpr.cod_estado   = 1
		   AND plpr.cod_plan     = inu_codPlan;

		RETURN ltc_datos;

	END fnGetProgramasPlan;

	-- ---------------------------------------------------------------------
    -- fnGetGeneros
    -- ---------------------------------------------------------------------
    FUNCTION fnGetGeneros RETURN type_cursor IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog¿a Inform¿tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_TARIFAS
	 Caso de Uso : 
	 Descripci¿n : Retorna los datos de los tipos de generos
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 28-01-2019  
	 ----------------------------------------------------------------------
	 Par¿metros :     Descripci¿n:
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci¿n
	 ----------------------------------------------------------------- */

		ltc_datos type_cursor;

	BEGIN 

		  OPEN ltc_datos FOR
		SELECT vsex.cod_sexo,
		       vsex.des_sexo
		  FROM VDIR_SEXO vsex			   
	 	 WHERE vsex.cod_estado = 1;

		RETURN ltc_datos;

	END fnGetGeneros;

	-- ---------------------------------------------------------------------
    -- fnGetCondicionTarifa
    -- ---------------------------------------------------------------------
    FUNCTION fnGetCondicionTarifa RETURN type_cursor IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog¿a Inform¿tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_TARIFAS
	 Caso de Uso : 
	 Descripci¿n : Retorna los datos de los tipos condicion por tarifa
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 28-01-2019  
	 ----------------------------------------------------------------------
	 Par¿metros :     Descripci¿n:
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci¿n
	 ----------------------------------------------------------------- */

		ltc_datos type_cursor;

	BEGIN 

		  OPEN ltc_datos FOR
		SELECT vcot.cod_condicion_tarifa,
		       vcot.des_condicion_tarifa
		  FROM VDIR_CONDICION_TARIFA vcot			   
	 	 WHERE vcot.cod_estado = 1;

		RETURN ltc_datos;

	END fnGetCondicionTarifa;

	-- ---------------------------------------------------------------------
    -- fnGetNumUsuarios
    -- ---------------------------------------------------------------------
    FUNCTION fnGetNumUsuarios RETURN type_cursor IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog¿a Inform¿tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_TARIFAS
	 Caso de Uso : 
	 Descripci¿n : Retorna los datos de los n¿meros de usuarios por tarifa
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 28-01-2019  
	 ----------------------------------------------------------------------
	 Par¿metros :     Descripci¿n:
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci¿n
	 ----------------------------------------------------------------- */

		ltc_datos type_cursor;

	BEGIN 

		  OPEN ltc_datos FOR
		SELECT vnut.cod_num_usuarios_tarifa,
		       vnut.des_num_usuarios_tarifa
		  FROM VDIR_NUM_USUARIOS_TARIFA vnut			   
	 	 WHERE vnut.cod_estado = 1;

		RETURN ltc_datos;

	END fnGetNumUsuarios;

	-- ---------------------------------------------------------------------
    -- fnGetTarifa
    -- ---------------------------------------------------------------------
    FUNCTION fnGetTarifa 
	(
		inu_codTarifa IN VDIR_TARIFA.COD_TARIFA%TYPE
	)
	RETURN type_cursor IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog¿a Inform¿tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_TARIFAS
	 Caso de Uso : 
	 Descripci¿n : Retorna los datos de la tarifa
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 28-01-2019  
	 ----------------------------------------------------------------------
	 Par¿metros :     Descripci¿n:
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci¿n
	 ----------------------------------------------------------------- */

		ltc_datos type_cursor;

	BEGIN 

		  OPEN ltc_datos FOR
		SELECT tari.cod_tarifa,
               tari.iva,
		       tari.cod_plan_programa,
			   plpr.cod_plan,
			   tari.cod_estado,
			   tari.cod_tipo_tarifa,
			   tari.valor,
			   TO_CHAR(tari.fecha_vige_inicial , 'dd/mm/yyyy') fecha_vige_inicial,
			   TO_CHAR(tari.fecha_vige_fin, 'dd/mm/yyyy') fecha_vige_fin,
			   tari.cod_condicion_tarifa,
			   tari.cod_num_usuarios_tarifa,
			   tari.cod_sexo,
			   tari.edad_inicial,
			   tari.edad_final,
			   tari.cod_tarifa_mp
		  FROM VDIR_TARIFA        tari,
		       VDIR_PLAN_PROGRAMA plpr
	 	 WHERE tari.cod_plan_programa = plpr.cod_plan_programa 
		   AND tari.cod_tarifa        = inu_codTarifa;

		RETURN ltc_datos;

	END fnGetTarifa;

	-- ---------------------------------------------------------------------
    -- fnGetExisteTarifa
    -- ---------------------------------------------------------------------
    FUNCTION fnGetExisteTarifa 
	(
		ivc_codTarifaMP  IN VDIR_TARIFA.COD_TARIFA_MP%TYPE
	)
	RETURN VDIR_TARIFA.COD_TARIFA%TYPE IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog¿a Inform¿tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_TARIFAS
	 Caso de Uso : 
	 Descripci¿n : Retorna el c¿digo de la tarifa si existe
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 31-01-2019  
	 ----------------------------------------------------------------------
	 Par¿metros :     Descripci¿n:
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci¿n
	 ----------------------------------------------------------------- */

		lnu_codTarifa VDIR_TARIFA.COD_TARIFA%TYPE;

	BEGIN 

		BEGIN 

			SELECT cod_tarifa INTO lnu_codTarifa       
              FROM VDIR_TARIFA
             WHERE UPPER(COD_TARIFA_MP) = UPPER(ivc_codTarifaMP)
			   AND cod_estado = 1;

		EXCEPTION WHEN OTHERS THEN  
			lnu_codTarifa := NULL;
		END;       

		RETURN lnu_codTarifa;

	END fnGetExisteTarifa;	

END VDIR_PACK_CONSULTA_TARIFAS;
create or replace PACKAGE BODY VDIR_PACK_CONSULTA_SOLICITUD AS
/* ---------------------------------------------------------------------
 Copyright  Tecnolog?a Inform?tica Coomeva - Colombia
 Package     : VDIR_PACK_CONSULTA_SOLICITUD
 Caso de Uso : 
 Descripci?n : Procesos para la consulta las afiliaciones - VENTA DIRECTA
 --------------------------------------------------------------------
 Autor : katherine.latorre@kalettre.com
 Fecha : 08-02-2018  
 --------------------------------------------------------------------
 Procedimiento :     Descripcion:
 --------------------------------------------------------------------
 Historia de Modificaciones
 ---------------------------------------------------------------------
 Fecha Autor Modificaci?n
 ----------------------------------------------------------------- */

	-- ---------------------------------------------------------------------
    -- fnGetSolicitudesGestionar
    -- ---------------------------------------------------------------------
    FUNCTION fnGetSolicitudesGestionar
    (
	    inu_codEstado     IN VDIR_AFILIACION.COD_ESTADO%TYPE DEFAULT 7,
        inu_codAfiliacion IN VDIR_AFILIACION.COD_AFILIACION%TYPE DEFAULT NULL,
		ivc_fechaInicia   IN VARCHAR2 DEFAULT NULL,
		ivc_fechaFinal    IN VARCHAR2 DEFAULT NULL,
        ivc_nroDocumento  IN VDIR_PERSONA.NUMERO_IDENTIFICACION%TYPE DEFAULT NULL,
        ivc_rolOperativo  IN VDIR_ESTADO.ROL_OPERATIVO%TYPE DEFAULT NULL
    )
	RETURN type_cursor IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog?a Inform?tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_SOLICITUD
	 Caso de Uso : 
	 Descripci?n : Retorna los datos de las afiliaciones
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 08-02-2019  
	 ----------------------------------------------------------------------
	 Par?metros :     Descripci?n:
	    inu_codAfiliacion  N?mero de la solicitud o c?digo de la afiliaci?n
		idt_fechaInicia    Fecha Inicial de radicaci?n
		idt_fechaFinal     Fecha Final de radicaci?n
		inu_codEstado      C?digo del estado de la afiliaci?n
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci?n
	 ----------------------------------------------------------------- */

	    lvc_query VARCHAR2(32767);
		ltc_datos type_cursor;

	BEGIN 

		 lvc_query := 'SELECT afil.cod_afiliacion, afil.motivo_pendiente, afil.observacion_pendiente, pers.celular, pers.paso_usuario,
                             INITCAP(pers.nombre_1) nombre_1,
                             INITCAP(pers.apellido_1) apellido_1,
                             (select DES_ABR from VDIR_TIPO_IDENTIFICACION 
                                where VDIR_TIPO_IDENTIFICACION.COD_TIPO_IDENTIFICACION=pers.COD_TIPO_IDENTIFICACION) tipoDocumentoContratante,
                             pers.NUMERO_IDENTIFICACION documentoContratante,
                             --plan.des_plan,
                             (SELECT des_plan FROM VDIR_PLAN WHERE COD_PLAN=(SELECT COD_PLAN 
                            FROM VDIR_TARIFA 
                            WHERE 
                            COD_TARIFA = (SELECT COD_TARIFA FROM VDIR_BENEFICIARIO_PROGRAMA 
                                WHERE COD_AFILIACION =afil.cod_afiliacion AND ROWNUM=1) AND ROWNUM=1)) des_plan,
                             esta.des_estado,
                             TO_CHAR(afil.fecha_creacion, ''dd/mm/yyyy'') fecha_radicacion,
                             esta.cod_estado,
                             pers.cod_asesor,
                             pers.cedula_referido,
                             (SELECT DES_ABR FROM VDIR_TIPO_IDENTIFICACION WHERE COD_TIPO_IDENTIFICACION=pers.tipo_identificacion_referido)  tipo_identificacion_referido,
                             (SELECT REGIONAL FROM VDIR_REGIONAL_CIUDAD 
                                WHERE CODIGO_DANE = (SELECT cod_municipio FROM vdir_persona WHERE cod_persona = (SELECT cod_beneficiario FROM vdir_beneficiario_programa WHERE cod_afiliacion = afil.cod_afiliacion AND ROWNUM = 1))) regional
                             --(SELECT des_municipio FROM vdir_municipio WHERE cod_municipio = (SELECT cod_municipio FROM vdir_persona WHERE cod_persona = (SELECT cod_beneficiario FROM vdir_beneficiario_programa WHERE cod_afiliacion = afil.cod_afiliacion AND ROWNUM = 1))) regional
                        FROM VDIR_AFILIACION               afil,
                             VDIR_ENCUESTA_PERSONA         cobe,
                             VDIR_PERSONA                  pers,
                             VDIR_USUARIO                  usua,
                             VDIR_ESTADO                   esta,
                             VDIR_PLAN                     plan
                       WHERE afil.cod_afiliacion  = cobe.cod_afiliacion
                         AND cobe.cod_persona     = pers.cod_persona 
                         AND pers.cod_persona     = usua.cod_persona
                         AND usua.cod_plan        = plan.cod_plan
                         AND afil.cod_estado      = esta.cod_estado
                         AND cobe.cod_encuesta    = 1 ';


		IF inu_codEstado <> -1  AND inu_codEstado IS NOT NULL THEN
			lvc_query := lvc_query||' AND afil.cod_estado = '||inu_codEstado;
		END IF;

		IF inu_codAfiliacion IS NOT NULL THEN

		   --NULL;
           lvc_query := lvc_query||' AND afil.cod_afiliacion = '||inu_codAfiliacion;

		END IF;		

		IF ivc_fechaInicia IS NOT NULL AND ivc_fechaFinal IS NOT NULL THEN
            lvc_query := lvc_query||' AND TO_DATE(TO_CHAR(afil.fecha_creacion,''dd/mm/yyyy''),''dd/mm/yyyy'') BETWEEN TO_DATE('''||ivc_fechaInicia||''',''dd/mm/yyyy'') AND TO_DATE('''||ivc_fechaFinal||''',''dd/mm/yyyy'')';
            --lvc_query := lvc_query||' AND afil.fecha_creacion BETWEEN TO_DATE('||ivc_fechaInicia||',''dd/mm/yyyy'') AND TO_DATE('||ivc_fechaFinal||',''dd/mm/yyyy'')';

		END IF;
        
        IF ivc_nroDocumento IS NOT NULL THEN
            lvc_query := lvc_query||' AND pers.numero_identificacion = '''||ivc_nroDocumento||'''';
        END IF;
        
        IF ivc_rolOperativo IS NOT NULL THEN
            lvc_query := lvc_query||' AND esta.rol_operativo = '''||ivc_rolOperativo||'''';
        END IF;

        lvc_query := lvc_query || ' ORDER BY afil.fecha_creacion ASC';

		--lvc_query := lvc_query||'group by afil.cod_afiliacion,
						     --INITCAP(pers.nombre_1), 
						     --INITCAP(pers.apellido_1), 
						     --plan.des_plan,
						     --esta.des_estado,
	                         --TO_CHAR(afil.fecha_creacion, ''dd/mm/yyyy''),
							--esta.cod_estado';

		--DBMS_OUTPUT.PUT_LINE(lvc_query);
		--Se retorna el cursor
		OPEN ltc_datos FOR lvc_query;		

		RETURN ltc_datos;

	END fnGetSolicitudesGestionar;

	-- ---------------------------------------------------------------------
    -- fnGetSolicitudes
    -- ---------------------------------------------------------------------
    FUNCTION fnGetSolicitudes
    (
	    inu_codEstado           IN VDIR_AFILIACION.COD_ESTADO%TYPE DEFAULT NULL,
        inu_codAfiliacion       IN VDIR_AFILIACION.COD_AFILIACION%TYPE DEFAULT NULL,
		ivc_fechaRadicaInicia   IN VARCHAR2 DEFAULT NULL,
		ivc_fechaRadicaFinal    IN VARCHAR2 DEFAULT NULL,
		ivc_fechaGestionInicia  IN VARCHAR2 DEFAULT NULL,
		ivc_fechaGestionFinal   IN VARCHAR2 DEFAULT NULL,
        ivc_nroDocumento  IN VDIR_PERSONA.NUMERO_IDENTIFICACION%TYPE DEFAULT NULL,
        ivc_rolOperativo  IN VDIR_ESTADO.ROL_OPERATIVO%TYPE DEFAULT NULL
    )
	RETURN type_cursor IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog?a Inform?tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_SOLICITUD
	 Caso de Uso : 
	 Descripci?n : Retorna los datos de las afiliaciones
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 08-02-2019  
	 ----------------------------------------------------------------------
	 Par?metros :     Descripci?n:
	    inu_codEstado           C?digo del estado de la afiliaci?n
	    inu_codAfiliacion       N?mero de la solicitud o c?digo de la afiliaci?n		
		ivc_fechaRadicaInicia   Fecha Inicial de radicaci?n
		ivc_fechaRadicaFinal    Fecha Final de radicaci?n
		ivc_fechaGestionInicia  Fecha Inicial de radicaci?n
		ivc_fechaGestionFinal   Fecha Final de radicaci?n
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci?n
	 ----------------------------------------------------------------- */

	    lvc_query VARCHAR2(32767);
		ltc_datos type_cursor;

	BEGIN 

		lvc_query := 'SELECT afil.cod_afiliacion,
						     INITCAP(pers.nombre_1) nombre_1,
						     INITCAP(pers.apellido_1) apellido_1,
                             pers.email,
                             pers.celular,
                             (SELECT vp.DES_PROGRAMA  FROM VDIR_BENEFICIARIO_PROGRAMA bp INNER JOIN VDIR_PROGRAMA vp ON bp.COD_PROGRAMA = vp.COD_PROGRAMA  WHERE COD_AFILIACION = afil.cod_afiliacion  AND ROWNUM = 1) producto,
                             (select DES_ABR from VDIR_TIPO_IDENTIFICACION 
                                where VDIR_TIPO_IDENTIFICACION.COD_TIPO_IDENTIFICACION=pers.COD_TIPO_IDENTIFICACION) tipoDocumentoContratante,
                             pers.NUMERO_IDENTIFICACION documentoContratante,
						     --plan.des_plan,
                             (SELECT des_plan FROM VDIR_PLAN WHERE COD_PLAN=(SELECT COD_PLAN 
                            FROM VDIR_TARIFA 
                            WHERE 
                            COD_TARIFA = (SELECT COD_TARIFA FROM VDIR_BENEFICIARIO_PROGRAMA 
                                WHERE COD_AFILIACION =afil.cod_afiliacion AND ROWNUM=1) AND ROWNUM=1)) des_plan,
						     esta.des_estado,
                            (SELECT REGIONAL FROM VDIR_REGIONAL_CIUDAD 
                                WHERE CODIGO_DANE = (SELECT cod_municipio FROM vdir_persona WHERE cod_persona = pers.cod_persona)) regional,
	                         TO_CHAR(afil.fecha_creacion, ''dd/mm/yyyy'') fecha_radicacion,
							 esta.cod_estado,
                             pers.cod_asesor,
                             pers.cedula_referido,
                             (SELECT DES_ABR FROM VDIR_TIPO_IDENTIFICACION WHERE COD_TIPO_IDENTIFICACION=pers.tipo_identificacion_referido)  tipo_identificacion_referido,
							 TO_CHAR(afil.fecha_gestion, ''dd/mm/yyyy'') fecha_gestion,
	                         (SELECT CONCAT(CONCAT(INITCAP(per.nombre_1), '' ''),INITCAP(per.apellido_1)) nombre_usuario
							    FROM VDIR_PERSONA per,
						             VDIR_USUARIO usu
							   WHERE per.cod_persona = usu.cod_persona
							     AND afil.cod_usuario_gestion = usu.cod_usuario) usuario_gestion,
						     (SELECT CONCAT(CONCAT(INITCAP(per.nombre_1), '' ''),INITCAP(per.apellido_1)) nombre_usuario
							    FROM VDIR_PERSONA per,
						             VDIR_USUARIO usu,
									 VDIR_COLA_SOLICITUD coso
							   WHERE per.cod_persona = usu.cod_persona
							     AND coso.cod_usuario= usu.cod_usuario
								 AND coso.cod_afiliacion = afil.cod_afiliacion) usuario_toma
					    FROM VDIR_AFILIACION               afil,
						     VDIR_ENCUESTA_PERSONA         cobe,
						     VDIR_PERSONA                  pers,
						     VDIR_USUARIO                  usua,
						     VDIR_ESTADO                   esta,
						     VDIR_PLAN                     plan
					   WHERE afil.cod_afiliacion  = cobe.cod_afiliacion
					     AND cobe.cod_persona     = pers.cod_persona 
					     AND pers.cod_persona     = usua.cod_persona
					     AND usua.cod_plan        = plan.cod_plan
					     AND afil.cod_estado      = esta.cod_estado
					     AND cobe.cod_encuesta    = 1';
						 /*AND esta.ind_tipo        = 2
						 AND afil.cod_estado	  <> 3';*/
                         /*Modificación para mostrar todas las tablas
                           By:Intelecto
                         */
                         

		IF inu_codEstado IS NOT NULL THEN

		    lvc_query := lvc_query||' AND afil.cod_estado = '||inu_codEstado;

		END IF;		

		IF inu_codAfiliacion IS NOT NULL THEN

		    lvc_query := lvc_query||' AND afil.cod_afiliacion = '||inu_codAfiliacion;

		END IF;		

		IF ivc_fechaRadicaInicia IS NOT NULL AND ivc_fechaRadicaFinal IS NOT NULL THEN

		    lvc_query := lvc_query||' AND TO_DATE(TO_CHAR(afil.fecha_creacion,''dd/mm/yyyy''),''dd/mm/yyyy'') BETWEEN TO_DATE('''||ivc_fechaRadicaInicia||''',''dd/mm/yyyy'') AND TO_DATE('''||ivc_fechaRadicaFinal||''',''dd/mm/yyyy'')';

		END IF;

		IF ivc_fechaGestionInicia IS NOT NULL AND ivc_fechaGestionFinal IS NOT NULL THEN

		    lvc_query := lvc_query||' AND TO_DATE(TO_CHAR(afil.fecha_gestion,''dd/mm/yyyy''),''dd/mm/yyyy'') BETWEEN TO_DATE('''||ivc_fechaGestionInicia||''',''dd/mm/yyyy'') AND TO_DATE('''||ivc_fechaGestionFinal||''',''dd/mm/yyyy'')';

		END IF;
        
        IF ivc_nroDocumento IS NOT NULL THEN
            lvc_query := lvc_query||' AND pers.numero_identificacion = '''||ivc_nroDocumento||'''';
        END IF;
        
        IF ivc_rolOperativo IS NOT NULL THEN
            lvc_query := lvc_query||' AND esta.rol_operativo = '''||ivc_rolOperativo||'''';
        END IF;

        lvc_query := lvc_query||' ORDER BY esta.des_estado asc, afil.fecha_creacion asc ';
		--DBMS_OUTPUT.PUT_LINE(lvc_query);
		--Se retorna el cursor
		OPEN ltc_datos FOR lvc_query;		

		RETURN ltc_datos;

	END fnGetSolicitudes;


	-- ---------------------------------------------------------------------
    -- fnGetDatosContratante
    -- ---------------------------------------------------------------------
     FUNCTION fnGetDatosContratante
    (
	    inu_codAfiliacion IN VDIR_AFILIACION.COD_AFILIACION%TYPE
    )
	RETURN type_cursor IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog?a Inform?tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_SOLICITUD
	 Caso de Uso : 
	 Descripci?n : Retorna los datos del contratante por afiliaci?n
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 13-02-2019  
	 ----------------------------------------------------------------------
	 Par?metros :       Descripci?n:
	 inu_codAfiliacion   C?digo de la afiliaci?n
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci?n
	 29-01-2019 - 2022
	 Autor: Intelecto
	 ----------------------------------------------------------------- */

		ltc_datos type_cursor;

	BEGIN 

		  OPEN ltc_datos FOR
	    SELECT TO_CHAR(afil.fecha_creacion, 'yyyy-mm-dd') fecha_radicacion,
               pers.apellido_1,
               pers.apellido_2,
               pers.nombre_1,
               pers.nombre_2,
               pers.paso_usuario,
               sexo.des_abr genero,
               tiid.des_abr tipo_identificacion,
               pers.numero_identificacion,
               TO_CHAR(pers.fecha_nacimiento, 'yyyy-mm-dd') fecha_nacimiento,
               (SELECT pais.abr_pais
                  FROM VDIR_PAIS         pais,
                       VDIR_DEPARTAMENTO depa
                 WHERE pais.cod_pais         = depa.cod_pais
                   AND depa.cod_departamento = muni.cod_departamento) nacionalidad,
               esci.des_estado_civil abr_estado_civil,
               veps.des_eps,
               tivi.abr_tipo_via,
               pers.dir_num_via,
               pers.dir_num_placa,
               pers.dir_complemento,
               '01' pais,
               (SELECT des_municipio FROM VDIR_MUNICIPIO WHERE COD_MUNICIPIO=pers.cod_municipio) cod_municipio,
               pers.barrio,
               (SELECT MUNICIPIO_DANE FROM VDIR_MUNICIPIO WHERE COD_MUNICIPIO=pers.cod_municipio) codigo_dane,
               pers.telefono,
               pers.email,
               pers.cod_persona,
               afil.cod_afiliacion,
               pers.COD_DIRECCION,
               pers.COD_ASESOR,
               pers.CELULAR,
               pers.CORTE,
               pers.FECHA_CORTE,
               pers.CEDULA_REFERIDO,
               pers.acepta_terminos,
               pers.dia_terminos,
               pers.mes_terminos,
               pers.anio_terminos,
               (SELECT DES_ABR FROM VDIR_TIPO_IDENTIFICACION WHERE COD_TIPO_IDENTIFICACION=pers.tipo_identificacion_referido)  tipo_identificacion_referido,
              (SELECT trmc.ip 
                    FROM vdir_terminoscondiciones trmc 
                    WHERE trmc.documento    = pers.numero_identificacion
                    AND trmc.tipodocumento  = tiid.des_abr
                    AND trmc.cod_afiliacion = inu_codAfiliacion
                    AND ROWNUM=1) ip,
              (SELECT trmc.fecha 
                    FROM vdir_terminoscondiciones trmc 
                    WHERE trmc.documento    = pers.numero_identificacion
                    AND trmc.tipodocumento  = tiid.des_abr
                    AND trmc.cod_afiliacion = inu_codAfiliacion
                    AND ROWNUM=1) fecha_aceptacion,
              (SELECT trmc.ip_cobertura 
                    FROM vdir_terminoscondiciones trmc 
                    WHERE trmc.documento    = pers.numero_identificacion
                    AND trmc.tipodocumento  = tiid.des_abr
                    AND trmc.cod_afiliacion = inu_codAfiliacion
                    AND ROWNUM=1) ip_cobertura,
              (SELECT trmc.fecha_cobertura 
                    FROM vdir_terminoscondiciones trmc 
                    WHERE trmc.documento    = pers.numero_identificacion
                    AND trmc.tipodocumento  = tiid.des_abr
                    AND trmc.cod_afiliacion = inu_codAfiliacion
                    AND ROWNUM=1) fecha_cobertura,
              (SELECT trmc.ip_tratamientodatos 
                    FROM vdir_terminoscondiciones trmc 
                    WHERE trmc.documento    = pers.numero_identificacion
                    AND trmc.tipodocumento  = tiid.des_abr
                    AND trmc.cod_afiliacion = inu_codAfiliacion
                    AND ROWNUM=1) ip_tratamientodatos,
              (SELECT trmc.fecha_tratamientodatos 
                    FROM vdir_terminoscondiciones trmc 
                    WHERE trmc.documento    = pers.numero_identificacion
                    AND trmc.tipodocumento  = tiid.des_abr
                    AND trmc.cod_afiliacion = inu_codAfiliacion
                    AND ROWNUM=1) fecha_tratamientodatos,
                (SELECT DES_FORMA_PAGO 
                    FROM vdir_forma_pago 
                    WHERE cod_forma_pago = factura.COD_FORMA_PAGO) forma_pago
          FROM VDIR_AFILIACION               afil,
               VDIR_CONTRATANTE_BENEFICIARIO cobe,
               VDIR_PERSONA                  pers,
               VDIR_SEXO                     sexo,
               VDIR_TIPO_IDENTIFICACION      tiid,
               VDIR_MUNICIPIO                muni,
               VDIR_ESTADO_CIVIL             esci,
               VDIR_EPS                      veps,
               VDIR_TIPO_VIA                 tivi,
               VDIR_FACTURA                  factura
         WHERE afil.cod_afiliacion          = cobe.cod_afiliacion
           AND cobe.cod_contratante         = pers.cod_persona
           --AND cobe.cod_beneficiario        = pers.cod_persona
           AND pers.cod_sexo                = sexo.cod_sexo
           AND pers.cod_tipo_identificacion = tiid.cod_tipo_identificacion
           AND pers.cod_municipio           = muni.cod_municipio
           AND pers.cod_estado_civil        = esci.cod_estado_civil
           --AND pers.cod_eps                 = veps.cod_eps
           AND veps.cod_eps                 = 176
           AND pers.dir_tipo_via            = tivi.cod_tipo_via
           AND factura.COD_AFILIACION       = afil.cod_afiliacion
           AND afil.cod_afiliacion          = inu_codAfiliacion;

		RETURN ltc_datos;

	END fnGetDatosContratante;

	-- ---------------------------------------------------------------------
    -- fnGetDatosBeneficiarios
    -- ---------------------------------------------------------------------
    FUNCTION fnGetDatosBeneficiarios
    (
	    inu_codAfiliacion IN VDIR_AFILIACION.COD_AFILIACION%TYPE
    )
	RETURN type_cursor IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog?a Inform?tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_SOLICITUD
	 Caso de Uso : 
	 Descripci?n : Retorna los datos del beneficiario por afiliaci?n
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 13-02-2019  
	 ----------------------------------------------------------------------
	 Par?metros :       Descripci?n:
	 inu_codAfiliacion   C?digo de la afiliaci?n
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci?n
	 ----------------------------------------------------------------- */

		ltc_datos type_cursor;

	BEGIN 

		  OPEN ltc_datos FOR
	    SELECT vdpa.abr_parentesco parentesco,
                TO_CHAR(afil.fecha_creacion, 'yyyy-mm-dd') fecha_radicacion,
                pers.apellido_1,
                pers.apellido_2,
                pers.nombre_1,
                pers.nombre_2,
                sexo.des_abr genero,
                tiid.des_abr tipo_identificacion,
                pers.numero_identificacion,
                TO_CHAR(pers.fecha_nacimiento, 'yyyy-mm-dd') fecha_nacimiento,
                (SELECT pais.abr_pais
                   FROM VDIR_PAIS         pais,
                        VDIR_DEPARTAMENTO depa
                  WHERE pais.cod_pais         = depa.cod_pais
                    AND depa.cod_departamento = muni.cod_departamento) nacionalidad,
                esci.abr_estado_civil,
                veps.des_eps,
                tivi.abr_tipo_via, 
                pers.dir_num_via,
                pers.dir_num_placa,
                pers.dir_complemento,
                '01' pais,
                pers.cod_municipio,
                pers.cod_municipio barrio,
                pers.cod_municipio codigo_dane,
                pers.telefono,
                pers.email,				
				VDIR_PACK_CONSULTA_SOLICITUD.fnGetTipoCompras(afil.cod_afiliacion, pers.cod_persona,vusu.cod_plan) tipo_venta,
				VDIR_PACK_CONSULTA_SOLICITUD.fnGetProgramas(afil.cod_afiliacion, pers.cod_persona,vusu.cod_plan) cod_programas,
				VDIR_PACK_CONSULTA_SOLICITUD.fnGetTarifas(afil.cod_afiliacion, pers.cod_persona) cod_tarifas,
				VDIR_PACK_CONSULTA_SOLICITUD.fnGetFechasServicio(afil.cod_afiliacion, cobe.cod_contratante,vusu.cod_plan) fecha_inicio_servicio,		
				pers.cod_persona,
                afil.cod_afiliacion,
                pers.cod_sexo,
                TRUNC(MONTHS_BETWEEN(SYSDATE,pers.fecha_nacimiento)/12) edad,
				VDIR_PACK_ENCUESTAS.fnGetValidaEncuesta(afil.cod_afiliacion, pers.cod_persona,'2') ind_encuesta_salud,
				pers.COD_DIRECCION
		  FROM VDIR_AFILIACION               afil,
			   VDIR_CONTRATANTE_BENEFICIARIO cobe,
			   VDIR_PERSONA                  pers,
			   VDIR_SEXO                     sexo,
			   VDIR_TIPO_IDENTIFICACION      tiid,
			   VDIR_MUNICIPIO                muni,
			   VDIR_ESTADO_CIVIL             esci,
			   VDIR_EPS                      veps,
			   VDIR_TIPO_VIA                 tivi,
			   VDIR_PARENTESCO               vdpa,
			   VDIR_USUARIO                  vusu
	     WHERE afil.cod_afiliacion          = cobe.cod_afiliacion
		   AND cobe.cod_beneficiario        = pers.cod_persona 
		   AND pers.cod_sexo                = sexo.cod_sexo
		   AND pers.cod_tipo_identificacion = tiid.cod_tipo_identificacion
		   AND pers.cod_municipio           = muni.cod_municipio
		   AND pers.cod_estado_civil        = esci.cod_estado_civil
		   AND pers.cod_eps                 = veps.cod_eps
		   AND pers.dir_tipo_via            = tivi.cod_tipo_via
		   AND cobe.cod_parentesco          = vdpa.cod_parentesco
		   AND cobe.cod_contratante         = vusu.cod_persona
		   AND afil.cod_afiliacion          = inu_codAfiliacion;

		RETURN ltc_datos;

	END fnGetDatosBeneficiarios;

    -- ---------------------------------------------------------------------
    -- fnGetTipoCompras
    -- ---------------------------------------------------------------------
    FUNCTION fnGetTipoCompras
    (
	    inu_codAfiliacion   IN VDIR_BENEFICIARIO_PROGRAMA.COD_AFILIACION%TYPE,
		inu_codBeneficiario IN VDIR_BENEFICIARIO_PROGRAMA.COD_BENEFICIARIO%TYPE,
		inu_codPlan         IN VDIR_PLAN_PROGRAMA.COD_PLAN%TYPE
    )
	RETURN VARCHAR2 IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog?a Inform?tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_SOLICITUD
	 Caso de Uso : 
	 Descripci?n : Retorna los tipos de compras por programa
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 21-02-2019  
	 ----------------------------------------------------------------------
	 Par?metros :       Descripci?n:
	 inu_codAfiliacion   C?digo de la afiliaci?n
	 inu_codBeneficiario C?digo del beneficiario
	 inu_codPlan         C?digo del plan
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci?n
	 ----------------------------------------------------------------- */

		ltc_datos type_cursor;
		lvc_desTipoSolicitud VARCHAR2(4000);

	BEGIN 

	    FOR fila IN (SELECT tiso.des_tipo_solicitud
			           FROM VDIR_BENEFICIARIO_PROGRAMA bepr,
					        VDIR_PLAN_PROGRAMA         plpr,
					        VDIR_TIPO_SOLICITUD        tiso
					  WHERE bepr.cod_programa       = plpr.cod_programa 
					    AND bepr.cod_tipo_solicitud = tiso.cod_tipo_solicitud
					    AND bepr.cod_beneficiario   = inu_codBeneficiario
					    AND bepr.cod_afiliacion     = inu_codAfiliacion
		                AND plpr.cod_plan           = inu_codPlan)
		LOOP					
			lvc_desTipoSolicitud := lvc_desTipoSolicitud || fila.des_tipo_solicitud || ',';			
		END LOOP;

		lvc_desTipoSolicitud := SUBSTR(lvc_desTipoSolicitud, 1,LENGTH(lvc_desTipoSolicitud)-1);

		RETURN lvc_desTipoSolicitud;   		

	END fnGetTipoCompras;

	-- ---------------------------------------------------------------------
    -- fnGetFechasServicio
    -- ---------------------------------------------------------------------
    FUNCTION fnGetFechasServicio
    (
	    inu_codAfiliacion IN VDIR_PERSONA_CONTRATO.COD_AFILIACION%TYPE,
		inu_codContrante  IN VDIR_PERSONA_CONTRATO.COD_PERSONA%TYPE,
		inu_codPlan       IN VDIR_PLAN_PROGRAMA.COD_PLAN%TYPE
    )
	RETURN VARCHAR2 IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog?a Inform?tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_SOLICITUD
	 Caso de Uso : 
	 Descripci?n : Retorna las fechas de inicio de los servicios
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 21-02-2019  
	 ----------------------------------------------------------------------
	 Par?metros :       Descripci?n:
	 inu_codAfiliacion   C?digo de la afiliaci?n
	 inu_codContrante    C?digo del contratante
	 inu_codPlan         C?digo del plan
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci?n
	 ----------------------------------------------------------------- */

		ltc_datos type_cursor;
		lvc_fechasServicio VARCHAR2(4000);

	BEGIN 	 


	    FOR fila IN (SELECT CASE WHEN EXTRACT(DAY FROM peco.fecha_creacion) <= 15 THEN 
		                        TO_CHAR(peco.fecha_creacion,'YYYY-MM')||'-16'
                            ELSE 
                                TO_CHAR(ADD_MONTHS(peco.fecha_creacion, 1),'YYYY-MM')||'-01'
                            END fecha_inicio_servicio
			           FROM VDIR_PERSONA_CONTRATO peco,
					        VDIR_PLAN_PROGRAMA    plpr
					  WHERE peco.cod_programa   = plpr.cod_programa 					  
					    AND peco.cod_persona    = inu_codContrante
					    AND peco.cod_afiliacion = inu_codAfiliacion
		                AND plpr.cod_plan       = inu_codPlan)
		LOOP					
			lvc_fechasServicio := lvc_fechasServicio || fila.fecha_inicio_servicio || ',';			
		END LOOP;

		lvc_fechasServicio := SUBSTR(lvc_fechasServicio, 1,LENGTH(lvc_fechasServicio)-1);

		RETURN lvc_fechasServicio;   		

	END fnGetFechasServicio;

    -- ---------------------------------------------------------------------
    -- fnGetProgramas
    -- ---------------------------------------------------------------------
    FUNCTION fnGetProgramas
    (
	    inu_codAfiliacion   IN VDIR_BENEFICIARIO_PROGRAMA.COD_AFILIACION%TYPE,
		inu_codBeneficiario IN VDIR_BENEFICIARIO_PROGRAMA.COD_BENEFICIARIO%TYPE,
		inu_codPlan         IN VDIR_PLAN_PROGRAMA.COD_PLAN%TYPE
    )
	RETURN VARCHAR2 IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog?a Inform?tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_SOLICITUD
	 Caso de Uso : 
	 Descripci?n : Retorna los c?digos de los programas por cada beneficiario
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 14-02-2019  
	 ----------------------------------------------------------------------
	 Par?metros :       Descripci?n:
	 inu_codAfiliacion   C?digo de la afiliaci?n
	 inu_codBeneficiario C?digo del beneficiario
	 inu_codPlan         C?digo del plan
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci?n
	 ----------------------------------------------------------------- */

		ltc_datos type_cursor;
		lvc_codProgramas  VARCHAR2(4000);

	BEGIN 

	    FOR fila IN (SELECT plpr.cod_programa_homologa
			           FROM VDIR_BENEFICIARIO_PROGRAMA bepr,
					        VDIR_PLAN_PROGRAMA         plpr
					  WHERE bepr.cod_programa     = plpr.cod_programa
					    AND bepr.cod_beneficiario = inu_codBeneficiario
					    AND bepr.cod_afiliacion   = inu_codAfiliacion
						AND plpr.cod_plan         = inu_codPlan
						AND plpr.cod_estado       = 1)
		LOOP					
			lvc_codProgramas := lvc_codProgramas || fila.cod_programa_homologa || ',';			
		END LOOP;

		lvc_codProgramas := SUBSTR(lvc_codProgramas, 1,LENGTH(lvc_codProgramas)-1);

		RETURN lvc_codProgramas;   		

	END fnGetProgramas;

	-- ---------------------------------------------------------------------
    -- fnGetTarifas
    -- ---------------------------------------------------------------------
    FUNCTION fnGetTarifas
    (
	    inu_codAfiliacion   IN VDIR_BENEFICIARIO_PROGRAMA.COD_AFILIACION%TYPE,
		inu_codBeneficiario IN VDIR_BENEFICIARIO_PROGRAMA.COD_BENEFICIARIO%TYPE
    )
	RETURN VARCHAR2 IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog?a Inform?tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_SOLICITUD
	 Caso de Uso : 
	 Descripci?n : Retorna los c?digos de las tarifas por cada beneficiario
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 14-02-2019  
	 ----------------------------------------------------------------------
	 Par?metros :       Descripci?n:
	 inu_codAfiliacion   C?digo de la afiliaci?n
	 inu_codBeneficiario C?digo del beneficiario
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci?n
	 ----------------------------------------------------------------- */

		ltc_datos type_cursor;
		lvc_codTarifas VARCHAR2(4000);

	BEGIN 

	    FOR fila IN (SELECT vtar.cod_tarifa_mp
			           FROM VDIR_BENEFICIARIO_PROGRAMA bepr,
					        VDIR_TARIFA                vtar
					  WHERE bepr.cod_tarifa       = vtar.cod_tarifa
					    AND bepr.cod_beneficiario = inu_codBeneficiario
					    AND bepr.cod_afiliacion   = inu_codAfiliacion)
		LOOP	
			lvc_codTarifas := lvc_codTarifas || fila.cod_tarifa_mp|| ',';				
		END LOOP;

		lvc_codTarifas := SUBSTR(lvc_codTarifas, 1,LENGTH(lvc_codTarifas)-1);

		RETURN lvc_codTarifas;   		

	END fnGetTarifas;

	-- ---------------------------------------------------------------------
    -- fnGetDatosBitacora
    -- ---------------------------------------------------------------------
    FUNCTION fnGetDatosBitacora
    (
	    inu_codAfiliacion IN VDIR_AFILIACION.COD_AFILIACION%TYPE
    )
	RETURN type_cursor IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog?a Inform?tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_SOLICITUD
	 Caso de Uso : 
	 Descripci?n : Retorna los datos de la trazabilidad realizada a la
	               afiliaci?n
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 14-02-2019  
	 ----------------------------------------------------------------------
	 Par?metros :       Descripci?n:
	 inu_codAfiliacion   C?digo de la afiliaci?n
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci?n
	 ----------------------------------------------------------------- */

		ltc_datos type_cursor;

	BEGIN 

		  OPEN ltc_datos FOR
	    SELECT TO_CHAR(biso.fecha_bitacora,'dd/mm/yyyy HH24:MI:SS') fecha_bitacora, 
		       pers.nombre_1||' '||pers.apellido_1 nombre_persona,
			   biso.observacion		
		  FROM VDIR_BITACORA_SOLICITUD biso,
		       VDIR_USUARIO            vusu,
			   VDIR_PERSONA            pers
	     WHERE biso.cod_usuario    = vusu.cod_usuario
		   AND vusu.cod_persona    = pers.cod_persona
		   AND biso.cod_afiliacion = inu_codAfiliacion
		   ORDER BY biso.fecha_bitacora DESC;

		RETURN ltc_datos;

	END fnGetDatosBitacora;

	-- ---------------------------------------------------------------------
    -- fnGetValidaExisteCola
    -- ---------------------------------------------------------------------
    FUNCTION fnGetValidaExisteCola
    (
	    inu_codAfiliacion   IN VDIR_COLA_SOLICITUD.COD_AFILIACION%TYPE,
		inu_codUsuario      IN VDIR_COLA_SOLICITUD.COD_USUARIO%TYPE
    )
	RETURN NUMBER IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog?a Inform?tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_SOLICITUD
	 Caso de Uso : 
	 Descripci?n : Indica si la afiliaci?n existe en la cola
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 14-02-2019  
	 ----------------------------------------------------------------------
	 Par?metros :     Descripci?n:
	   inu_codAfiliacion    C?digo de la afiliaci?n
	   inu_codUsuario       C?digo del usuario 	   
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci?n
	 ----------------------------------------------------------------- */

		lnu_valida            NUMBER(1)  := 0;
		lnu_codColaSolicitud  VDIR_COLA_SOLICITUD.COD_COLA_SOLICITUD%TYPE;  		

	BEGIN 	 

	    BEGIN 

			SELECT cod_cola_solicitud 
			  INTO lnu_codColaSolicitud       
			  FROM VDIR_COLA_SOLICITUD
			 WHERE cod_afiliacion = inu_codAfiliacion
			   AND cod_usuario    = inu_codUsuario;  

			IF lnu_codColaSolicitud IS NOT NULL THEN

				-- ---------------------------------------------------------------------
				-- El usuario va a retomar la solicitud
				-- ---------------------------------------------------------------------
				lnu_valida := 1;

			END IF;					

		EXCEPTION WHEN OTHERS THEN  
			lnu_valida := 0;
		END;

		IF lnu_valida = 0 THEN

		    BEGIN 

				SELECT cod_cola_solicitud 
				  INTO lnu_codColaSolicitud       
				  FROM VDIR_COLA_SOLICITUD
				 WHERE cod_afiliacion = inu_codAfiliacion;  

				IF lnu_codColaSolicitud IS NOT NULL THEN

					-- ---------------------------------------------------------------------
					-- El usuario se va a reasignar la solicitud de otro usuario
					-- ---------------------------------------------------------------------
					lnu_valida := 2;		

				END IF;

		    EXCEPTION WHEN OTHERS THEN  
				lnu_valida := 0;
			END;		

		END IF;		

		RETURN lnu_valida;

	END fnGetValidaExisteCola;	

	-- ---------------------------------------------------------------------
    -- fnGetNombreUsuarioCola
    -- ---------------------------------------------------------------------
    FUNCTION fnGetNombreUsuarioCola
    (
	    inu_codAfiliacion IN VDIR_COLA_SOLICITUD.COD_AFILIACION%TYPE
    )
	RETURN VARCHAR2 IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog?a Inform?tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_SOLICITUD
	 Caso de Uso : 
	 Descripci?n : Retorna el nombre del usuario que tiene la solicitud 
	               en la cola	  
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 14-02-2019  
	 ----------------------------------------------------------------------
	 Par?metros :     Descripci?n:
	   inu_codAfiliacion    C?digo de la afiliaci?n 
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci?n
	 ----------------------------------------------------------------- */

		lnu_nombreUsuario VARCHAR2(1000);		

	BEGIN 

		SELECT pers.nombre_1||' '||pers.apellido_1 nombre_persona 
		  INTO lnu_nombreUsuario
		  FROM VDIR_COLA_SOLICITUD coso,
		       VDIR_USUARIO        vusu,
			   VDIR_PERSONA        pers
		 WHERE coso.cod_usuario    = vusu.cod_usuario
		   AND vusu.cod_persona    = pers.cod_persona
		   AND coso.cod_afiliacion = inu_codAfiliacion;   


		RETURN lnu_nombreUsuario;

	END fnGetNombreUsuarioCola;		

	-- ---------------------------------------------------------------------
    -- fnGetSolicitudesPendientes
    -- ---------------------------------------------------------------------
    FUNCTION fnGetSolicitudesPendientes
    (
	    inu_codUsuario IN VDIR_USUARIO.COD_USUARIO%TYPE
    )
	RETURN type_cursor IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog?a Inform?tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_SOLICITUD
	 Caso de Uso : 
	 Descripci?n : Retorna los datos de las solicitudes pendientes
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 14-02-2019  
	 ----------------------------------------------------------------------
	 Par?metros :       Descripci?n:
	 inu_codUsuario      C?digo del usuario
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci?n
	 ----------------------------------------------------------------- */

		ltc_datos type_cursor;

	BEGIN 

		  OPEN ltc_datos FOR
	    SELECT afil.cod_afiliacion,
			   pers.nombre_1,
			   pers.apellido_1,
			   --plan.des_plan,
			   esta.des_estado,
			   TO_CHAR(afil.fecha_creacion, 'dd/mm/yyyy') fecha_radicacion,
			   esta.cod_estado,
               (SELECT des_plan FROM VDIR_PLAN WHERE COD_PLAN=(SELECT COD_PLAN 
                FROM VDIR_TARIFA 
                WHERE 
                COD_TARIFA = (SELECT COD_TARIFA FROM VDIR_BENEFICIARIO_PROGRAMA 
                                WHERE COD_AFILIACION =afil.cod_afiliacion AND ROWNUM=1) AND ROWNUM=1)) des_plan
		  FROM (select pc.cod_persona, pc.cod_afiliacion, af.FECHA_CREACION,af.COD_ESTADO 
                            from VDIR_AFILIACION af,
                                 VDIR_PERSONA_CONTRATO pc
                                 where af.COD_AFILIACION = pc.COD_AFILIACION
                                   AND af.cod_estado = 4 
                                   group by pc.cod_persona, pc.cod_afiliacion, af.FECHA_CREACION,af.COD_ESTADO ) afil,
		  	   VDIR_ENCUESTA_PERSONA         cobe,
			   VDIR_PERSONA                  pers,
			   VDIR_USUARIO                  usua,
			   VDIR_ESTADO                   esta,
			   VDIR_PLAN                     plan,
			   VDIR_COLA_SOLICITUD           coso,
               VDIR_TARIFA                   tari
	     WHERE afil.cod_persona  = cobe.cod_persona
		   AND cobe.cod_persona     = pers.cod_persona 
		   AND pers.cod_persona     = usua.cod_persona
		   AND usua.cod_plan        = plan.cod_plan
		   AND afil.cod_estado      = esta.cod_estado
		   AND afil.cod_afiliacion  = coso.cod_afiliacion
		   AND cobe.cod_encuesta    = 1		   
		   AND coso.cod_usuario     = inu_codUsuario
		   GROUP BY afil.cod_afiliacion,
			   pers.nombre_1,
			   pers.apellido_1,
			   plan.des_plan,
			   esta.des_estado,
			   TO_CHAR(afil.fecha_creacion, 'dd/mm/yyyy'),
			   esta.cod_estado;

		RETURN ltc_datos;

	END fnGetSolicitudesPendientes;

	-- ---------------------------------------------------------------------
    -- fnGetValidaSolicitudEnGestion
    -- ---------------------------------------------------------------------
    FUNCTION fnGetValidaSolicitudEnGestion
    (
	  	inu_codUsuario      IN VDIR_COLA_SOLICITUD.COD_USUARIO%TYPE
    )
	RETURN NUMBER IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog?a Inform?tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_SOLICITUD
	 Caso de Uso : 
	 Descripci?n : Valida si el usuario actual tiene una solicitud en gesti?n
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 14-02-2019  
	 ----------------------------------------------------------------------
	 Par?metros :     Descripci?n:	  
	   inu_codUsuario       C?digo del usuario 	   
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci?n
	 ----------------------------------------------------------------- */

		lnu_codAfiliacion VDIR_COLA_SOLICITUD.COD_AFILIACION%TYPE;  		

	BEGIN 	 

	    BEGIN 

			SELECT coso.cod_afiliacion 
			  INTO lnu_codAfiliacion       
			  FROM VDIR_COLA_SOLICITUD coso,
			       VDIR_AFILIACION     vafi
			 WHERE coso.cod_afiliacion = vafi.cod_afiliacion 
			   AND vafi.cod_estado     = 5
			   AND coso.cod_usuario    = inu_codUsuario; 						

		EXCEPTION WHEN OTHERS THEN  
			lnu_codAfiliacion := NULL;
		END;

		RETURN lnu_codAfiliacion;

	END fnGetValidaSolicitudEnGestion;	

	FUNCTION fnGetDatosProgramas
    (
	    inu_codAfiliacion IN VDIR_AFILIACION.COD_AFILIACION%TYPE
    )
	RETURN type_cursor IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog?a Inform?tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_SOLICITUD
	 Caso de Uso : 
	 Descripci?n : Retorna los datos del beneficiario por afiliaci?n
	 ----------------------------------------------------------------------
	 Autor : jors.castro@iteria.com
	 Fecha : 05-07-2019  
	 ----------------------------------------------------------------------
	 Par?metros :       Descripci?n:
	 inu_codAfiliacion   C?digo de la afiliaci?n
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci?n
	 ----------------------------------------------------------------- */

		ltc_datos type_cursor;

	BEGIN 

		  OPEN ltc_datos FOR
	    SELECT 
            bp.COD_PROGRAMA,            
            PP.CUENTA,
            PP.PROGRAMA,
            PP.SUB_CUENTA,
            PP.TARIFA
		  FROM VDIR_BENEFICIARIO_PROGRAMA bp,
               VDIR_TARIFA vt,
               VDIR_PLAN_PROGRAMA PP
	     WHERE bp.cod_afiliacion = inu_codAfiliacion
         AND   bp.COD_TARIFA = vt.COD_TARIFA
         AND   vt.COD_PLAN_PROGRAMA = PP.COD_PLAN_PROGRAMA
         group by bp.COD_PROGRAMA,PP.CUENTA,PP.PROGRAMA,PP.SUB_CUENTA,PP.TARIFA;

		RETURN ltc_datos;

	END fnGetDatosProgramas;

	FUNCTION fnGetBenexPrograma
    (
	    inu_codAfiliacion IN VDIR_AFILIACION.COD_AFILIACION%TYPE,
	    inu_codprograma IN VDIR_PROGRAMA.COD_PROGRAMA%TYPE
    )
	RETURN type_cursor IS

	/* ---------------------------------------------------------------------
	 Copyright   : Tecnolog?a Inform?tica Coomeva - Colombia
	 Package     : VDIR_PACK_CONSULTA_SOLICITUD
	 Caso de Uso : 
	 Descripci?n : Retorna los datos del beneficiario por afiliaci?n
	 ----------------------------------------------------------------------
	 Autor : jors.castro@iteria.com
	 Fecha : 05-07-2019  
	 ----------------------------------------------------------------------
	 Par?metros :       Descripci?n:
	 inu_codAfiliacion   C?digo de la afiliaci?n
	 inu_codprograma    Codigo programa
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificaci?n
	 ----------------------------------------------------------------- */

		ltc_datos type_cursor;

	BEGIN 

		  OPEN ltc_datos FOR
	    SELECT vdpa.des_parentesco parentesco,
                TO_CHAR(afil.fecha_creacion, 'yyyy-mm-dd') fecha_radicacion,
                pers.apellido_1,
                pers.apellido_2,
                pers.nombre_1,
                pers.nombre_2,
                sexo.des_abr genero,
                tiid.des_abr tipo_identificacion,
                pers.numero_identificacion,
                TO_CHAR(pers.fecha_nacimiento, 'yyyy-mm-dd') fecha_nacimiento,
                (SELECT pais.abr_pais
                   FROM VDIR_PAIS         pais,
                        VDIR_DEPARTAMENTO depa
                  WHERE pais.cod_pais         = depa.cod_pais
                    AND depa.cod_departamento = muni.cod_departamento) nacionalidad,
                esci.des_estado_civil abr_estado_civil,
                veps.des_eps,                                                                                                 			
				VDIR_PACK_CONSULTA_SOLICITUD.fnGetTipoCompras(afil.cod_afiliacion, pers.cod_persona,vusu.cod_plan) tipo_venta,														
				pers.cod_persona,
                afil.cod_afiliacion,
                pers.cod_sexo,
                TRUNC(MONTHS_BETWEEN(SYSDATE,pers.fecha_nacimiento)/12) edad,
				VDIR_PACK_ENCUESTAS.fnGetValidaEncuesta(afil.cod_afiliacion, pers.cod_persona,'2') ind_encuesta_salud,
				pers.COD_DIRECCION
		  FROM VDIR_AFILIACION               afil,
			   VDIR_CONTRATANTE_BENEFICIARIO cobe,
			   VDIR_BENEFICIARIO_PROGRAMA    bp,
			   VDIR_PERSONA                  pers,
			   VDIR_SEXO                     sexo,
			   VDIR_TIPO_IDENTIFICACION      tiid,
			   VDIR_MUNICIPIO                muni,
			   VDIR_ESTADO_CIVIL             esci,
			   VDIR_EPS                      veps,
			   VDIR_PARENTESCO               vdpa,
			   VDIR_USUARIO                  vusu
	     WHERE bp.COD_PROGRAMA              = inu_codprograma
           AND bp.COD_AFILIACION            = inu_codAfiliacion
           AND bp.COD_AFILIACION            = afil.COD_AFILIACION
           AND bp.COD_BENEFICIARIO          = cobe.COD_BENEFICIARIO
           AND bp.COD_AFILIACION            = cobe.COD_AFILIACION
		   AND cobe.cod_beneficiario        = pers.cod_persona 
		   AND pers.cod_sexo                = sexo.cod_sexo
		   AND pers.cod_tipo_identificacion = tiid.cod_tipo_identificacion
		   AND pers.cod_municipio           = muni.cod_municipio
		   AND pers.cod_estado_civil        = esci.cod_estado_civil
		   --AND pers.cod_eps                 = veps.cod_eps
           AND veps.cod_eps                 = 176
		   AND cobe.cod_parentesco          = vdpa.cod_parentesco
		   AND cobe.cod_contratante         = vusu.cod_persona;		   

		RETURN ltc_datos;

	END fnGetBenexPrograma;

END VDIR_PACK_CONSULTA_SOLICITUD;
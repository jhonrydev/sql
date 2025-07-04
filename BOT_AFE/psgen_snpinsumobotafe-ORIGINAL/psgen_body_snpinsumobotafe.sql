--------------------------------------------------------
-- Archivo creado  - jueves-julio-03-2025   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body PSGEN_SNPINSUMOBOTAFE
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "SALUDMP"."PSGEN_SNPINSUMOBOTAFE" IS

PROCEDURE ajustaCuotaMesAFE (prm_solicitud_afe    IN VARCHAR2,			
									 prm_cuota   IN NUMBER,
									 prm_usuario          IN VARCHAR2,											      								   
								     codError     OUT NUMBER,
								     msgError     OUT VARCHAR2,
								     registros    OUT SYS_REFCURSOR)
   AS



	

	CURSOR cu_permiso_usuario(lnu_tipo_cambio NUMBER) IS

		SELECT COUNT(1)
		  FROM gen_permiso_usuario 
		 WHERE usuario         = prm_usuario
		   AND cod_tipo_cambio = lnu_tipo_cambio;
           
	CURSOR cu_solici IS

		SELECT id, primera_cuota
		FROM Api_afemp_step6
		WHERE ID = prm_solicitud_afe;		

	lnu_permiso               NUMBER(1);	
	rc_solic                  cu_solici%ROWTYPE;
	lvc_estados               VARCHAR2(100); 
	lnu_existEst              NUMBER(1);

   BEGIN    



			codError := 0;

		IF (prm_solicitud_afe IS NULL OR prm_solicitud_afe = '')THEN

			msgError := msgError ||' El campo prm_cuota no puede estar vacio'||chr(13);
			codError := 1;

		END IF;

		IF (prm_cuota IS NULL OR prm_cuota = '')THEN

			msgError := msgError ||' El campo prm_cuota no puede estar vacio'||chr(13);
			codError := 1;
	
		END IF;


		lnu_permiso := NULL;		

		OPEN cu_permiso_usuario(10);
		FETCH cu_permiso_usuario INTO lnu_permiso;
		CLOSE cu_permiso_usuario;

		IF(lnu_permiso = 0) THEN

			msgError := msgError ||'Usuario sin permisos'||chr(13);	
			codError := 1;

		END IF;

		IF (codError = 0) THEN


			

				rc_solic.id := NULL;

				OPEN cu_solici;
				FETCH cu_solici INTO rc_solic;
				CLOSE cu_solici;

				IF (rc_solic.id IS NULL) THEN

					msgError := msgError ||'Solicitud AFE no existe'||chr(13);	
					codError := 1;					

				ELSE

					UPDATE Api_afemp_step6 SET primera_cuota =  prm_cuota
					WHERE ID = rc_solic.id;

					INSERT INTO GEN_BITACORA_CAMBIO VALUES (SEQ_GEN_BITACORA_CAMBIO.NEXTVAL,
															prm_solicitud_afe,
															10,
															rc_solic.primera_cuota, --valor_anterior,
															prm_cuota,      --valor_nuevo,  
															SYSDATE,
															prm_usuario);
                                                            
                    msgError := msgError ||' CUOTA_MES='||rc_solic.primera_cuota||'/'||prm_cuota;



				END IF;

			END IF;
COMMIT;
  END ajustaCuotaMesAFE;   

 PROCEDURE ajustaTarifarioAFE (prm_solicitud_afe    IN VARCHAR2,			
									 prm_tarifario   IN VARCHAR2,
									 prm_usuario          IN VARCHAR2,											      								   
								     codError     OUT NUMBER,
								     msgError     OUT VARCHAR2,
								     registros    OUT SYS_REFCURSOR)
   AS



	

	CURSOR cu_permiso_usuario(lnu_tipo_cambio NUMBER) IS

		SELECT COUNT(1)
		  FROM gen_permiso_usuario 
		 WHERE usuario         = prm_usuario
		   AND cod_tipo_cambio = lnu_tipo_cambio;
           
	CURSOR cu_solici IS

		SELECT id, CODIGO_TARIFA
		FROM Api_afemp_step6
		WHERE ID = prm_solicitud_afe;		

	lnu_permiso               NUMBER(1);	
	rc_solic                  cu_solici%ROWTYPE;
	lvc_estados               VARCHAR2(100); 
	lnu_existEst              NUMBER(1);
	lnu_estado                NUMBER(5);

   BEGIN    



			codError := 0;

		IF (prm_solicitud_afe IS NULL OR prm_solicitud_afe = '')THEN

			msgError := msgError ||' El campo prm_solicitud_afe no puede estar vacio'||chr(13);
			codError := 1;

		END IF;

		IF (prm_tarifario IS NULL OR prm_tarifario = '')THEN

			msgError := msgError ||' El campo prm_tarifario no puede estar vacio'||chr(13);
			codError := 1;
	
		END IF;


		lnu_permiso := NULL;		

		OPEN cu_permiso_usuario(9);
		FETCH cu_permiso_usuario INTO lnu_permiso;
		CLOSE cu_permiso_usuario;

		IF(lnu_permiso = 0) THEN

			msgError := msgError ||'Usuario sin permisos'||chr(13);	
			codError := 1;

		END IF;

		IF (codError = 0) THEN


			

				rc_solic.id := NULL;

				OPEN cu_solici;
				FETCH cu_solici INTO rc_solic;
				CLOSE cu_solici;

				IF (rc_solic.id IS NULL) THEN

					msgError := msgError ||'Solicitud AFE no existe'||chr(13);	
					codError := 1;					

				ELSE

					UPDATE Api_afemp_step6 SET CODIGO_TARIFA =  prm_tarifario
					WHERE ID = rc_solic.id;

					INSERT INTO GEN_BITACORA_CAMBIO VALUES (SEQ_GEN_BITACORA_CAMBIO.NEXTVAL,
															prm_solicitud_afe,
															9,
															rc_solic.CODIGO_TARIFA, --valor_anterior,
															prm_tarifario,      --valor_nuevo,  
															SYSDATE,
															prm_usuario);
                                                            
                                      msgError := msgError ||' CODIGO_TARIFA='||rc_solic.CODIGO_TARIFA||'/'||prm_tarifario;
                                          


				END IF;

			END IF;
COMMIT;
  END ajustaTarifarioAFE;   

 
  PROCEDURE pr_ajustaInsumoBotAFE   (prm_solicitudes_afe IN VARCHAR2,			
									 prm_estado        IN VARCHAR2,			
									 prm_observaciones IN VARCHAR2,			
									 prm_intentos      IN VARCHAR2,
									 prm_usuario       IN VARCHAR2,											      								   
								     codError     OUT NUMBER,
								     msgError     OUT VARCHAR2,
								     registros    OUT SYS_REFCURSOR)
   AS
   

	CURSOR cu_solic IS

		SELECT DISTINCT REGEXP_SUBSTR (prm_solicitudes_afe, '[^/,]+', 1, level) as solic
		  FROM dual
		CONNECT BY LEVEL <= length(regexp_replace(prm_solicitudes_afe,'[^/,]+'))+1;

	CURSOR cu_venta_general(lnu_solic NUMBER) IS
		SELECT solicitud_afe, estado, observaciones, intentos
		  FROM rpa_venta_general 
		 WHERE solicitud_afe = lnu_solic;

	CURSOR cu_permiso_usuario(lnu_tipo_cambio NUMBER) IS

		SELECT COUNT(1)
		  FROM gen_permiso_usuario 
		 WHERE usuario         = prm_usuario
		   AND cod_tipo_cambio = lnu_tipo_cambio;

	rc_solic            cu_solic%ROWTYPE;
	rc_venta_general	cu_venta_general%ROWTYPE;
	lnu_registro        NUMBER(1):= 0;
	lnu_permiso         NUMBER(1);

   BEGIN    

		codError := 0;


		FOR rc_solic IN cu_solic LOOP


			rc_venta_general.solicitud_afe := NULL;			


			OPEN cu_venta_general(rc_solic.solic);
			FETCH cu_venta_general INTO rc_venta_general;
			CLOSE cu_venta_general;

			IF (lnu_registro=1) THEN
				msgError := msgError ||' | ';
			END IF;

			msgError := msgError ||' Solicitud ' || rc_solic.solic;

			IF(rc_venta_general.solicitud_afe IS NULL) THEN

				msgError := msgError ||' No existe ';

			ELSE

				IF (prm_estado <> 'N/A') THEN

					lnu_permiso := NULL;		

					OPEN cu_permiso_usuario(1);
					FETCH cu_permiso_usuario INTO lnu_permiso;
					CLOSE cu_permiso_usuario;

					IF(lnu_permiso > 0) THEN

						UPDATE rpa_venta_general SET estado = prm_estado, intentos = nvl(intentos,0) + 1
						 WHERE solicitud_afe = rc_solic.solic;

						INSERT INTO GEN_BITACORA_CAMBIO VALUES (SEQ_GEN_BITACORA_CAMBIO.NEXTVAL,
																rc_solic.solic,
																1,
																rc_venta_general.estado, --valor_anterior,
																prm_estado,              --valor_nuevo,  
																SYSDATE,
																prm_usuario);

						msgError := msgError ||' ESTADO='||rc_venta_general.estado||'/'||prm_estado;
					ELSE 
						msgError := msgError ||' ESTADO='||'Usuario sin permisos';
					END IF;

				END IF;

				IF (prm_observaciones <> 'N/A' OR prm_observaciones IS NULL) THEN

					lnu_permiso := NULL;		

					OPEN cu_permiso_usuario(2);
					FETCH cu_permiso_usuario INTO lnu_permiso;
					CLOSE cu_permiso_usuario;

					IF(lnu_permiso > 0) THEN

						UPDATE rpa_venta_general SET observaciones = prm_observaciones
						 WHERE solicitud_afe = rc_solic.solic;

						INSERT INTO GEN_BITACORA_CAMBIO VALUES (SEQ_GEN_BITACORA_CAMBIO.NEXTVAL,
																rc_solic.solic,
																2,
																rc_venta_general.observaciones, --valor_anterior,
																prm_observaciones,              --valor_nuevo,  
																SYSDATE,
																prm_usuario);

						msgError := msgError ||' OBSERVACIONES='||rc_venta_general.observaciones||'/'||prm_observaciones;
					ELSE 
						msgError := msgError ||' OBSERVACIONES='||'Usuario sin permisos';
					END IF;

				END IF;

				IF (prm_intentos <> 'N/A' OR prm_intentos IS NULL) THEN

					lnu_permiso := NULL;		

					OPEN cu_permiso_usuario(3);
					FETCH cu_permiso_usuario INTO lnu_permiso;
					CLOSE cu_permiso_usuario;

					IF(lnu_permiso > 0) THEN

						UPDATE rpa_venta_general SET intentos = prm_intentos
						 WHERE solicitud_afe = rc_solic.solic;

						INSERT INTO GEN_BITACORA_CAMBIO VALUES (SEQ_GEN_BITACORA_CAMBIO.NEXTVAL,
																rc_solic.solic,
																3,
																rc_venta_general.intentos, --valor_anterior,
																prm_intentos,              --valor_nuevo,  
																SYSDATE,
																prm_usuario);

						msgError := msgError ||' INTENTOS='||rc_venta_general.intentos||'/'||prm_intentos;
					ELSE 
						msgError := msgError ||' INTENTOS='||'Usuario sin permisos';
					END IF;

				END IF;
			END IF;

			lnu_registro := 1;

		END LOOP;

		COMMIT;

  END pr_ajustaInsumoBotAFE;   

PROCEDURE pr_ajustePesoTallaBebe  (prm_solicitud_afe    IN VARCHAR2,			
									 prm_tipo_doc_benef   IN VARCHAR2,
									 prm_numero_doc_benef IN VARCHAR2,			
									 prm_peso             IN VARCHAR2,			
									 prm_talla            IN VARCHAR2,
									 prm_usuario          IN VARCHAR2,											      								   
								     codError     OUT NUMBER,
								     msgError     OUT VARCHAR2,
								     registros    OUT SYS_REFCURSOR)
   AS


	CURSOR cu_solic IS

		SELECT id, codigo_tipo_documento, numero_documento
		FROM API_AFEMP_STEP5_BENEF
		WHERE ID_STEP5 = prm_solicitud_afe;		

	CURSOR cu_benefic(lnu_beneficiario NUMBER, lnu_pregunta NUMBER) IS

		SELECT respuesta_decimal
		FROM API_AFEMP_STEP5_B_ESTA_SALUD
		WHERE ID_STEP5_BENEF  = lnu_beneficiario		
		  AND CODIGO_PREGUNTA = lnu_pregunta;

	CURSOR cu_permiso_usuario(lnu_tipo_cambio NUMBER) IS

		SELECT COUNT(1)
		  FROM gen_permiso_usuario 
		 WHERE usuario         = prm_usuario
		   AND cod_tipo_cambio = lnu_tipo_cambio;

	lnu_permiso               NUMBER(1);
	rc_solic                  cu_solic%ROWTYPE;
	rc_benific                cu_benefic%ROWTYPE;
	lnu_encontro_solic        NUMBER(1) :=0; 
	lnu_encontro_benef        NUMBER(1) :=0; 

   BEGIN    

		codError := 0;

		IF (prm_talla IS NULL OR prm_talla = '')THEN

			msgError := msgError ||' Debe ingresar la TALLA, si no la quiere cambiar debe ingresar N/A'||chr(13);
			codError := 1;

		END IF;

		IF (prm_peso IS NULL OR prm_peso = '')THEN

			msgError := msgError ||' Debe ingresar el PESO, si no la quiere cambiar debe ingresar N/A'||chr(13);
			codError := 1;

		END IF;

		IF (codError = 0) THEN

			FOR rc_solic IN cu_solic LOOP

				lnu_encontro_solic := 1;

				IF (rc_solic.codigo_tipo_documento = prm_tipo_doc_benef  AND rc_solic.numero_documento = prm_numero_doc_benef) THEN

					lnu_encontro_benef := 1;

					IF (prm_talla <> 'N/A' AND prm_talla IS NOT NULL) THEN
						--Se actualiza talla

						lnu_permiso := NULL;		

						OPEN cu_permiso_usuario(4);
						FETCH cu_permiso_usuario INTO lnu_permiso;
						CLOSE cu_permiso_usuario;

						IF(lnu_permiso > 0) THEN

							OPEN cu_benefic(rc_solic.id, 26);
							FETCH cu_benefic INTO rc_benific;
							CLOSE cu_benefic;

							UPDATE API_AFEMP_STEP5_B_ESTA_SALUD SET respuesta_decimal = prm_talla
							WHERE ID_STEP5_BENEF = rc_solic.id
							  AND CODIGO_PREGUNTA = 26;

							INSERT INTO GEN_BITACORA_CAMBIO VALUES (SEQ_GEN_BITACORA_CAMBIO.NEXTVAL,
																	prm_solicitud_afe||'-'||rc_solic.id,
																	4,
																	rc_benific.respuesta_decimal, --valor_anterior,
																	prm_talla,              --valor_nuevo,  
																	SYSDATE,
																	prm_usuario);

							msgError := msgError ||' TALLA='||rc_benific.respuesta_decimal||'/'||prm_talla||chr(13);
						ELSE
							msgError := msgError ||' TALLA='||'Usuario sin permisos'||chr(13);	
						END IF;

					END IF;

					IF (prm_peso <> 'N/A' AND prm_peso IS NOT NULL) THEN

						lnu_permiso := NULL;		

						OPEN cu_permiso_usuario(5);
						FETCH cu_permiso_usuario INTO lnu_permiso;
						CLOSE cu_permiso_usuario;

						IF(lnu_permiso > 0) THEN

							OPEN cu_benefic(rc_solic.id, 27);
							FETCH cu_benefic INTO rc_benific;
							CLOSE cu_benefic;

							--Se actualiza peso
							UPDATE API_AFEMP_STEP5_B_ESTA_SALUD SET respuesta_decimal = prm_peso
							WHERE ID_STEP5_BENEF = rc_solic.id
							  AND CODIGO_PREGUNTA = 27;

							INSERT INTO GEN_BITACORA_CAMBIO VALUES (SEQ_GEN_BITACORA_CAMBIO.NEXTVAL,
																	prm_solicitud_afe||'-'||rc_solic.id,
																	5,
																	rc_benific.respuesta_decimal, --valor_anterior,
																	prm_peso,              --valor_nuevo,  
																	SYSDATE,
																	prm_usuario);

							msgError := msgError ||' PESO='||rc_benific.respuesta_decimal||'/'||prm_peso||chr(13);
						ELSE
							msgError := msgError ||' PESO='||'Usuario sin permisos'||chr(13);							
						END IF;	

					END IF;	
				END IF;

			END LOOP;

			IF (lnu_encontro_solic = 0) THEN
				msgError := msgError ||'Solicitud AFE no existe'||chr(13);
			ELSE

				IF (lnu_encontro_benef = 0) THEN
					msgError := msgError ||'Beneficiario no existe para la solicigud AFE'||chr(13);
				END IF;
			END IF;

		END IF;


		COMMIT;

  END pr_ajustePesoTallaBebe;   

PROCEDURE pr_ajustePlanVoluntario  (prm_solicitud_afe     IN VARCHAR2,			
									 prm_tipo_doc_benef   IN VARCHAR2,
									 prm_numero_doc_benef IN VARCHAR2,			
									 prm_plan_voluntario  IN VARCHAR2,			
									 prm_observacion      IN VARCHAR2,
									 prm_usuario          IN VARCHAR2,											      								   
								     codError     OUT NUMBER,
								     msgError     OUT VARCHAR2,
								     registros    OUT SYS_REFCURSOR)
   AS


	CURSOR cu_solic IS

		SELECT id, codigo_tipo_documento, numero_documento
		FROM API_AFEMP_STEP5_BENEF
		WHERE ID_STEP5 = prm_solicitud_afe;		

	CURSOR cu_benefic(lnu_beneficiario NUMBER, lnu_pregunta NUMBER) IS

		SELECT respuesta_boolean, observacion
		FROM API_AFEMP_STEP5_B_ESTA_SALUD
		WHERE ID_STEP5_BENEF  = lnu_beneficiario		
		  AND CODIGO_PREGUNTA = lnu_pregunta;

	CURSOR cu_permiso_usuario(lnu_tipo_cambio NUMBER) IS

		SELECT COUNT(1)
		  FROM gen_permiso_usuario 
		 WHERE usuario         = prm_usuario
		   AND cod_tipo_cambio = lnu_tipo_cambio;

	lnu_permiso               NUMBER(1);	
	rc_solic                  cu_solic%ROWTYPE;
	rc_benific                cu_benefic%ROWTYPE;
	lnu_encontro_solic        NUMBER(1) :=0; 
	lnu_encontro_benef        NUMBER(1) :=0; 

   BEGIN    

		codError := 0;

		IF (prm_plan_voluntario IS NULL OR prm_plan_voluntario = '')THEN

			msgError := msgError ||' El campo prm_plan_voluntario no puede estar vacio, debe ingresar 0/1'||chr(13);
			codError := 1;

		END IF;

		IF (prm_plan_voluntario = '1' AND (prm_observacion IS NULL OR prm_observacion = ''))THEN

			msgError := msgError ||' El campo prm_observacion no puede estar vacio'||chr(13);
			codError := 1;

		END IF;

		IF (prm_plan_voluntario NOT IN ('0', '1'))THEN

			msgError := msgError ||' Campo prm_plan_voluntario es invalido, debe ingresar 0/1'||chr(13);
			codError := 1;

		END IF;

		lnu_permiso := NULL;		

		OPEN cu_permiso_usuario(6);
		FETCH cu_permiso_usuario INTO lnu_permiso;
		CLOSE cu_permiso_usuario;

		IF(lnu_permiso = 0) THEN

			msgError := msgError ||'Usuario sin permisos'||chr(13);	
			codError := 1;

		END IF;

		IF (codError = 0) THEN

			FOR rc_solic IN cu_solic LOOP

				lnu_encontro_solic := 1;

				IF (rc_solic.codigo_tipo_documento = prm_tipo_doc_benef  AND rc_solic.numero_documento = prm_numero_doc_benef) THEN

					lnu_encontro_benef := 1;


					--Se actualiza Plan voluntario del que viene (Encuesta de salud)
					OPEN cu_benefic(rc_solic.id, 24);
					FETCH cu_benefic INTO rc_benific;
					CLOSE cu_benefic;

					UPDATE API_AFEMP_STEP5_B_ESTA_SALUD SET respuesta_boolean = prm_plan_voluntario,
															observacion       = prm_observacion
					WHERE ID_STEP5_BENEF = rc_solic.id
					  AND CODIGO_PREGUNTA = 24;

					INSERT INTO GEN_BITACORA_CAMBIO VALUES (SEQ_GEN_BITACORA_CAMBIO.NEXTVAL,
															prm_solicitud_afe||'-'||rc_solic.id,
															6,
															rc_benific.respuesta_boolean, --valor_anterior,
															prm_plan_voluntario,          --valor_nuevo,  
															SYSDATE,
															prm_usuario);

					msgError := msgError ||' PLAN VOLUNTARIO='||rc_benific.respuesta_boolean||'/'||prm_plan_voluntario||chr(13);

					INSERT INTO GEN_BITACORA_CAMBIO VALUES (SEQ_GEN_BITACORA_CAMBIO.NEXTVAL,
															prm_solicitud_afe||'-'||rc_solic.id,
															7,
															rc_benific.observacion,  --valor_anterior,
															prm_observacion,         --valor_nuevo,  
															SYSDATE,
															prm_usuario);

					msgError := msgError ||' OBSERVACION='||rc_benific.observacion||'/'||prm_observacion||chr(13);

				END IF;

			END LOOP;

			IF (lnu_encontro_solic = 0) THEN
				msgError := msgError ||'Solicitud AFE no existe'||chr(13);
			ELSE

				IF (lnu_encontro_benef = 0) THEN
					msgError := msgError ||'Beneficiario no existe para la solicigud AFE'||chr(13);
				END IF;
			END IF;

			COMMIT;

		END IF;

  END pr_ajustePlanVoluntario;   

  PROCEDURE pr_ajusteEstadoSolicAFE (prm_solicitud_afe    IN VARCHAR2,			
									 prm_codigo_estado    IN VARCHAR2,
									 prm_usuario          IN VARCHAR2,											      								   
								     codError     OUT NUMBER,
								     msgError     OUT VARCHAR2,
								     registros    OUT SYS_REFCURSOR)
   AS


	CURSOR cu_solic IS

		SELECT id, codigo_estado
		FROM API_AFEMP_STEP1
		WHERE ID = prm_solicitud_afe;		

	CURSOR cu_estado(lnu_estado NUMBER) IS

		SELECT codigo, descripcion
		FROM API_AFEMP_P_ESTADOS
		WHERE CODIGO = lnu_estado;		

	CURSOR cu_permiso_usuario(lnu_tipo_cambio NUMBER) IS

		SELECT COUNT(1)
		  FROM gen_permiso_usuario 
		 WHERE usuario         = prm_usuario
		   AND cod_tipo_cambio = lnu_tipo_cambio;

	lnu_permiso               NUMBER(1);	
	rc_solic                  cu_solic%ROWTYPE;
	rc_estado                 cu_estado%ROWTYPE;
	lvc_estados               VARCHAR2(100); 
	lnu_existEst              NUMBER(1);
	lnu_estado                NUMBER(5);

   BEGIN    

		codError := 0;

		IF (prm_solicitud_afe IS NULL OR prm_solicitud_afe = '')THEN

			msgError := msgError ||' El campo prm_solicitud_afe no puede estar vacio'||chr(13);
			codError := 1;

		END IF;

		IF (prm_codigo_estado IS NULL OR prm_codigo_estado = '')THEN

			msgError := msgError ||' El campo prm_codigo_estado no puede estar vacio'||chr(13);
			codError := 1;
		ELSE


			SELECT valor INTO lvc_estados FROM app_config WHERE varkey='ESTAFE_MODIF';
			lnu_estado := TRIM(SUBSTR(prm_codigo_estado,0,INSTR(prm_codigo_estado,'-')-1));
			lnu_existEst := PSGEN_Generalservices.fn_ExistString(lnu_estado, lvc_estados);	

			IF(lnu_existEst = 0) THEN
				msgError := msgError ||' El estado seleccionado no es valido'||chr(13);
				codError := 1;
			END IF;
		END IF;


		lnu_permiso := NULL;		

		OPEN cu_permiso_usuario(6);
		FETCH cu_permiso_usuario INTO lnu_permiso;
		CLOSE cu_permiso_usuario;

		IF(lnu_permiso = 0) THEN

			msgError := msgError ||'Usuario sin permisos'||chr(13);	
			codError := 1;

		END IF;

		IF (codError = 0) THEN


			rc_estado.codigo := NULL;

			OPEN cu_estado(lnu_estado);
			FETCH cu_estado INTO rc_estado;
			CLOSE cu_estado;

			IF (rc_estado.codigo IS NULL)THEN

				msgError := msgError ||'Estado ingresado no existe'||chr(13);	
				codError := 1;

			ELSE

				rc_solic.id := NULL;

				OPEN cu_solic;
				FETCH cu_solic INTO rc_solic;
				CLOSE cu_solic;

				IF (rc_solic.id IS NULL) THEN

					msgError := msgError ||'Solicitud AFE no existe'||chr(13);	
					codError := 1;					

				ELSE

					UPDATE API_AFEMP_STEP1 SET CODIGO_ESTADO = lnu_estado
					WHERE ID = rc_solic.id;

					INSERT INTO GEN_BITACORA_CAMBIO VALUES (SEQ_GEN_BITACORA_CAMBIO.NEXTVAL,
															prm_solicitud_afe,
															8,
															rc_solic.codigo_estado, --valor_anterior,
															lnu_estado,      --valor_nuevo,  
															SYSDATE,
															prm_usuario);

					msgError := msgError ||' CODIGO_ESTADO ='||rc_solic.codigo_estado||'/'||prm_codigo_estado||chr(13);

				END IF;

			END IF;

			COMMIT;

		END IF;

  END pr_ajusteEstadoSolicAFE;   


  PROCEDURE pr_envio_reporte_afe (codError OUT NUMBER, msgError OUT VARCHAR2, registros OUT SYS_REFCURSOR) 

	AS

		v_fecha DATE;
		v_mensaje VARCHAR2(400);
		v_afiliaciones_pendientes VARCHAR2(100);
		v_afiliaciones_grabadas VARCHAR2(100);
		v_lista_destinatarios VARCHAR2(500);
        v_afiliaciones_novedad VARCHAR2(100);


		v_telefono_actual VARCHAR2(20);
		v_posicion_inicio NUMBER := 1;
		v_posicion_fin NUMBER;
		v_asunto_sms VARCHAR2(50);
        v_param VARCHAR2(20);


		BEGIN 
        
        -- Se obtiene valor para dias de la novedad
        
		SELECT valor INTO v_param FROM app_config WHERE varkey='PARAM_NOVEDAD';

		-- Obtiene la fecha actual
		SELECT TRUNC(SYSDATE) INTO v_fecha FROM dual;
        
        -- Obtiene ventas en novedad
        SELECT count(*) into v_afiliaciones_novedad  FROM rpa_venta_general WHERE estado ='NOVEDAD' and trunc(sysdate)-trunc(fecha_novedad) <=v_param;


		-- Obtiene el n�mero de afiliaciones gabadas
		SELECT COUNT(*) INTO v_afiliaciones_grabadas FROM rpa_venta_general WHERE estado= 'GRABADO' AND trunc(fecha_grabacion) = trunc(sysdate);


		-- Obtiene el n�mero de afiliaciones pendientes
		SELECT COUNT(*) INTO v_afiliaciones_pendientes FROM rpa_venta_general WHERE estado= 'LISTO';

		-- Obtiene el mensaje a enviar
		SELECT valor INTO v_mensaje FROM app_config WHERE varkey='MSG_REPORT_AFE';

		v_mensaje:=REPLACE(v_mensaje,'{fecha}',v_fecha);
        
        	IF v_afiliaciones_novedad <= 1 THEN
			v_mensaje:=REPLACE(v_mensaje,'novedad','novedad');
			v_mensaje:=REPLACE(v_mensaje,' afiliaciones ',' afiliaci�n ');
			v_mensaje:=REPLACE(v_mensaje,'{num_novedad}',v_afiliaciones_novedad);
		ELSE
			v_mensaje:=REPLACE(v_mensaje,'{num_novedad}',v_afiliaciones_novedad);
		END IF;

		IF v_afiliaciones_grabadas <= 1 THEN
			v_mensaje:=REPLACE(v_mensaje,'grabaron','grab�');
			v_mensaje:=REPLACE(v_mensaje,' afiliaciones ',' afiliaci�n ');
			v_mensaje:=REPLACE(v_mensaje,'{num_grabados}',v_afiliaciones_grabadas);
		ELSE
			v_mensaje:=REPLACE(v_mensaje,'{num_grabados}',v_afiliaciones_grabadas);
		END IF;

		IF v_afiliaciones_pendientes <= 1 THEN
			v_mensaje:=REPLACE(v_mensaje,'quedaron pendientes','quedo pendiente');
			v_mensaje:=REPLACE(v_mensaje,'{num_pendientes}',v_afiliaciones_pendientes);
		ELSE
			v_mensaje:=REPLACE(v_mensaje,'{num_pendientes}',v_afiliaciones_pendientes);
		END IF;

		-- Obtiene la lista de destinatarios de mensajes SMS
		SELECT valor INTO v_lista_destinatarios FROM app_config WHERE varkey='SEND_REPORT_TO';

		-- Contar las afiliaciones pendientes
		SELECT COUNT(*) INTO v_afiliaciones_pendientes FROM rpa_venta_general WHERE estado = 'LISTO';

		-- Contar el asunto que va a tener el mensaje
		SELECT valor INTO v_asunto_sms FROM app_config WHERE varkey='ASUNTO_SMS_AFE';

		-- Iterar sobre la lista de tel�fonos
		WHILE v_posicion_inicio < LENGTH(v_lista_destinatarios) LOOP
			-- Encontrar la posici�n de la coma
			v_posicion_fin := INSTR(v_lista_destinatarios, ',', v_posicion_inicio);

			-- Extraer el n�mero de tel�fono
			IF v_posicion_fin = 0 THEN
				v_telefono_actual := SUBSTR(v_lista_destinatarios, v_posicion_inicio);
				v_posicion_inicio:= LENGTH(v_lista_destinatarios)+1;
			ELSE
				v_telefono_actual := SUBSTR(v_lista_destinatarios, v_posicion_inicio, v_posicion_fin - v_posicion_inicio);
				v_posicion_inicio := v_posicion_fin + 1;
			END IF;

			-- Enviar mensaje SMS
			CORE_SEND_SMS_EMAIL(
				P_SMS_ORIGEN => 'BOT_AFE',
				P_EMAIL_ASUNTO => v_asunto_sms,
				P_SMS_CONTENIDO => v_mensaje,
				P_SMS_LARGO => 'false',
				P_SMS_NUM_DESTINO => v_telefono_actual,
				P_SMS_ESTADO => 'NOE',
				P_EMAIL_DESTINO => NULL,
				P_EMAIL_ESTADO => 'NOA',
				P_EMAIL_CONTENIDO => NULL,
				P_SMS_URL => NULL
			);

		END LOOP;

		codError := 0; -- Asignar un c�digo de error, 0 si no hay errores
		msgError := 'Ok'; -- Asignar el mensaje de salida

		EXCEPTION
			WHEN OTHERS THEN
			codError := SQLCODE;
			msgError := SQLERRM;

  END pr_envio_reporte_afe;


/*  PROCEDURE pr_envio_bloqueo_botAfe (codError OUT NUMBER, msgError OUT VARCHAR2, registros OUT SYS_REFCURSOR) 

	AS

		CURSO cu_ultimaSolic IS

			SELECT T.SOLICITUD_AFE SOLICITUD_AFE_GRABADA, 
                   ROUND((TO_NUMBER(to_CHAR(SYSDATE, 'SSSSS'))/60 - TO_NUMBER(to_CHAR(T.FECHA_GRABACION, 'SSSSS'))/60)) MINUTOS
			FROM(
			SELECT *
			FROM(
			SELECT solicitud_afe, FECHA_GRABACION
			FROM rpa_venta_general
			where estado= 'GRABADO'
			AND FECHA_GRABACION IS NOT NULL
			ORDER BY FECHA_GRABACION DESC)
			WHERE ROWNUM<= 1) T;

		v_fecha DATE;
		v_mensaje VARCHAR2(400);
		v_afiliaciones_pendientes VARCHAR2(100);
		v_afiliaciones_grabadas VARCHAR2(100);
		v_lista_destinatarios VARCHAR2(500);

		v_telefono_actual VARCHAR2(20);
		v_posicion_inicio NUMBER := 1;
		v_posicion_fin NUMBER;
		v_asunto_sms VARCHAR2(50);
		rc_ultimaSolic cu_ultimaSolic%ROWTYPE;

		BEGIN 

		-- Obtiene la fecha actual
		SELECT TRUNC(SYSDATE) INTO v_fecha FROM dual;

		-- Obtiene ultima solicitud
		OPEN cu_ultimaSolic;
		FETCH cu_ultimaSolic INTO rc_ultimaSolic;
		CLOSE cu_ultimaSolic;	

		-- Obtiene el n�mero de afiliaciones gabadas
		SELECT COUNT(*) INTO v_afiliaciones_grabadas FROM rpa_venta_general WHERE estado= 'GRABADO' AND trunc(fecha_grabacion) = trunc(sysdate);;

		-- Obtiene el n�mero de afiliaciones pendientes
		SELECT COUNT(*) INTO v_afiliaciones_pendientes FROM rpa_venta_general WHERE estado= 'LISTO';

		IF(rc_ultimaSolic.MINUTOS > 30) THEN

			BOTAFE: Ultima solicitud grabada xxxx hace xx minutos. total solicitudes gabadas xxx, pendientes xxxx

		END IF;

		-- Obtiene el mensaje a enviar
		SELECT valor INTO v_mensaje FROM app_config WHERE varkey='MSG_REPORT_AFE';

		v_mensaje:=REPLACE(v_mensaje,'{fecha}',v_fecha);

		IF v_afiliaciones_grabadas <= 1 THEN
			v_mensaje:=REPLACE(v_mensaje,'grabaron','grab�');
			v_mensaje:=REPLACE(v_mensaje,' afiliaciones ',' afiliaci�n ');
			v_mensaje:=REPLACE(v_mensaje,'{num_grabados}',v_afiliaciones_grabadas);
		ELSE
			v_mensaje:=REPLACE(v_mensaje,'{num_grabados}',v_afiliaciones_grabadas);
		END IF;

		IF v_afiliaciones_pendientes <= 1 THEN
			v_mensaje:=REPLACE(v_mensaje,'quedaron pendientes','quedo pendiente');
			v_mensaje:=REPLACE(v_mensaje,'{num_pendientes}',v_afiliaciones_pendientes);
		ELSE
			v_mensaje:=REPLACE(v_mensaje,'{num_pendientes}',v_afiliaciones_pendientes);
		END IF;

		-- Obtiene la lista de destinatarios de mensajes SMS
		SELECT valor INTO v_lista_destinatarios FROM app_config WHERE varkey='SEND_REPORT_TO';

		-- Contar las afiliaciones pendientes
		SELECT COUNT(*) INTO v_afiliaciones_pendientes FROM rpa_venta_general WHERE estado = 'LISTO';

		-- Contar el asunto que va a tener el mensaje
		SELECT valor INTO v_asunto_sms FROM app_config WHERE varkey='ASUNTO_SMS_AFE';

		-- Iterar sobre la lista de tel�fonos
		WHILE v_posicion_inicio < LENGTH(v_lista_destinatarios) LOOP
			-- Encontrar la posici�n de la coma
			v_posicion_fin := INSTR(v_lista_destinatarios, ',', v_posicion_inicio);

			-- Extraer el n�mero de tel�fono
			IF v_posicion_fin = 0 THEN
				v_telefono_actual := SUBSTR(v_lista_destinatarios, v_posicion_inicio);
				v_posicion_inicio:= LENGTH(v_lista_destinatarios)+1;
			ELSE
				v_telefono_actual := SUBSTR(v_lista_destinatarios, v_posicion_inicio, v_posicion_fin - v_posicion_inicio);
				v_posicion_inicio := v_posicion_fin + 1;
			END IF;

			-- Enviar mensaje SMS
			CORE_SEND_SMS_EMAIL(
				P_SMS_ORIGEN => 'BOT_AFE',
				P_EMAIL_ASUNTO => v_asunto_sms,
				P_SMS_CONTENIDO => v_mensaje,
				P_SMS_LARGO => 'false',
				P_SMS_NUM_DESTINO => v_telefono_actual,
				P_SMS_ESTADO => 'NOE',
				P_EMAIL_DESTINO => NULL,
				P_EMAIL_ESTADO => 'NOA',
				P_EMAIL_CONTENIDO => NULL,
				P_SMS_URL => NULL
			);

		END LOOP;

		codError := 0; -- Asignar un c�digo de error, 0 si no hay errores
		msgError := 'Ok'; -- Asignar el mensaje de salida

		EXCEPTION
			WHEN OTHERS THEN
			codError := SQLCODE;
			msgError := SQLERRM;

  END pr_envio_bloqueo_botAfe;*/

END PSGEN_SNPInsumoBotAFE;

/

create or replace PACKAGE           PSGEN_SNDSAODENT
AS
   /* -----------------------------------------------------------------------------
   Copyright ¿Coomeva S.A. - Colombia
   Package : PSGEN_SNDSAODENT
   Caso de Uso :
   Descripci¿ :  Obtiene datos del producto de SALUD ORAL
   -------------------------------------------------------------------------------
   Autor : 
   Fecha : 01-02-2024
   -------------------------------------------------------------------------------
   Procedimiento : Descripcion:
   -------------------------------------------------------------------------------
   Historia de Modificaciones
   -------------------------------------------------------------------------------
   Fecha Autor Modificaci¿
   ------------------------------------------------------------------------------*/
   TYPE TYPE_CURSOR IS REF CURSOR;
 
  PROCEDURE pr_getUtilizacionesUsuSAO(prm_docu_tipo  IN MSO_P_USUARIO.COD_TIPO_DOCUMENTO%TYPE,
											prm_docu_nro   IN MSO_P_USUARIO.NO_DOCUMENTO%TYPE,
											prm_ciudad     IN MSO_P_SUCURSAL.COD_SUCURSAL%TYPE,
											prm_fec_inicio IN VARCHAR2,
											prm_fec_fin	   IN VARCHAR2,										
											codError OUT NUMBER,
											msgError OUT VARCHAR2,
											registros OUT SYS_REFCURSOR);


 END PSGEN_SNDSAODENT;
 /
 create or replace PACKAGE BODY           PSGEN_SNDSAODENT AS

  PROCEDURE pr_getUtilizacionesUsuSAO(prm_docu_tipo IN MSO_P_USUARIO.COD_TIPO_DOCUMENTO%TYPE,
											prm_docu_nro  IN MSO_P_USUARIO.NO_DOCUMENTO%TYPE,
											prm_ciudad    IN MSO_P_SUCURSAL.COD_SUCURSAL%TYPE,
											prm_fec_inicio IN VARCHAR2,
											prm_fec_fin	   IN VARCHAR2,						  
											codError OUT NUMBER,
											msgError OUT VARCHAR2,
											registros OUT SYS_REFCURSOR)
   AS
   
   CURSOR CU_tipoId IS
   
		SELECT count(1)
		  FROM MSO_P_TIPO_DOCUMENTO
		 WHERE cod_tipo_documento = prm_docu_tipo;
	
   CURSOR CU_usuario IS
   
		SELECT count(1)
		  FROM MSO_P_USUARIO
		 WHERE cod_tipo_documento = prm_docu_tipo
		   AND no_documento       = prm_docu_nro;

   CURSOR CU_ciudad IS
   
		SELECT count(1)
		  FROM MSO_P_SUCURSAL
		 WHERE cod_ciudad = prm_ciudad;
		   
	lnu_cantTipoId   NUMBER(2);
	lnu_cantUsuario  NUMBER(2);
	lnu_cantCiudad   NUMBER(2);
	
	ldt_fec_inicio   DATE;
	ldt_fec_fin      DATE;
	
   BEGIN    
		
		codError := 0;
		
		-- Valida si el tipo de documento existe
		OPEN CU_tipoId;
		FETCH CU_tipoId INTO  lnu_cantTipoId;	
		CLOSE CU_tipoId;
		
		IF (lnu_cantTipoId = 0) THEN
			codError := 1;
			msgError := 'El tipo de documento no es valido.';		
		END IF;

		-- Valida si el usuario existe
		OPEN CU_usuario;
		FETCH CU_usuario INTO  lnu_cantUsuario;	
		CLOSE CU_usuario;
		
		IF (lnu_cantUsuario = 0) THEN
			codError := 2;
			msgError := 'Usuario no existe.';		
		END IF;
		
		IF (prm_fec_inicio IS NULL OR prm_fec_fin IS NULL) THEN
			
			codError := 3;
			msgError := 'Debe ingresar fecha de inicio y fecha fin.';		
		
		ELSE 
		
			BEGIN
				ldt_fec_inicio := to_date(prm_fec_inicio,'YYYY/MM/DD');
				ldt_fec_fin    := to_date(prm_fec_fin,'YYYY/MM/DD');
			
				IF (ldt_fec_inicio > ldt_fec_fin) THEN
					codError := 15;
					msgError := 'La fecha de inicio debe ser menor o igual a la fecha fin';										
				END IF;
			
			EXCEPTION WHEN OTHERS THEN
				codError := 4;
				msgError := 'Formato de fecha invalido. Debe ingresar la fecha en formato YYYY/MM/DD';					
			END;	
			 
			 
		END IF;

		
		IF (codError = 0) THEN 
		
			IF (prm_ciudad IS NULL) THEN
			
				OPEN registros FOR
				
				SELECT TO_CHAR(Z.FECHA_SOLICITUD,'YYYY/MM/DD')FECHA_SOLICITUD, 
					   PO.NOMBRE AS DESC_PROC, 
					   PRES.RAZON_SOCIAL AS PRESTADOR, 
					   X.OBSERVACION_AUDITORIA AS OBSERVACION, 
					   EVOL.ESTADO_EVOLUCION_SOLICITUD AS ESTADO_SOLICITUD, 
					   X.ESTADO AS ESTADO_PIV, 
					   X.NUM_AUTORIZACION, 
					   TO_CHAR(X.FECHA_AUDITORIA,'YYYY/MM/DD') AS FECHA_AUDITORIA, 
					   TO_CHAR(X.FECHA_ATENCION,'YYYY/MM/DD') AS FECHA_PROC, 
					   SUC.COD_CIUDAD AS CIUDAD 
				  FROM MSO_P_USUARIO A 
			INNER JOIN SALUDMP.MSO_P_CARNET_USUARIO B ON A.NO_DOCUMENTO = B.NO_DOCUMENTO 
			INNER JOIN SALUDMP.MSO_PLAN_TRATAMIENTO_PIV Z on Z.NUM_CARNET = B.NUM_CARNET 
			INNER JOIN SALUDMP.MSO_SOLICITUD_TRATAMIENTO_PIV X on X.CONS_PLAN_TRATAMIENTO = Z.CONS_PLAN_TRATAMIENTO 
			 LEFT JOIN SALUDMP.MSO_P_PROCEDIMIENTO PO ON PO.COD_PROCEDIMIENTO = X.COD_PROCEDIMIENTO 
			 LEFT JOIN SALUDMP.MSO_P_SUCURSAL SUC ON SUC.COD_SUCURSAL = Z.COD_SUCURSAL 
			 LEFT JOIN SALUDMP.MSO_EVOLUCION_SOLICITUD EVOL ON EVOL.CONS_SOLICITUD_TRATAMIENTO = X.CONS_SOLICITUD_TRATAMIENTO 
			 LEFT JOIN SALUDMP.MSO_P_PRESTADOR PRES ON PRES.NIT_PRESTADOR = Z.NIT_PRESTADOR 
			INNER JOIN MSO_H_ESTADO_SOLICITUD EST on EST.CONS_SOLICITUD_TRATAMIENTO = Z.CONS_PLAN_TRATAMIENTO 
				 WHERE A.COD_TIPO_DOCUMENTO = prm_docu_tipo 
				   AND A.NO_DOCUMENTO = prm_docu_nro
				   AND Z.FECHA_CREA >= TO_DATE(prm_fec_inicio, 'yyyy-mm-dd') 
				   AND Z.FECHA_CREA <= TO_DATE (prm_fec_fin, 'yyyy-mm-dd')+1        
			UNION 
				SELECT TO_CHAR(D.FECHA_SOLICITUD,'YYYY/MM/DD')FECHA_SOLICITUD, PO.NOMBRE AS DESC_PROC, PRES.RAZON_SOCIAL AS PRESTADOR, C.OBSERVACION_AUDITORIA AS OBSERVACION, EVOL.ESTADO_EVOLUCION_SOLICITUD AS ESTADO_SOLICITUD, C.ESTADO AS ESTADO__PIV, + C.NUM_AUTORIZACION, TO_CHAR(C.FECHA_AUDITORIA,'YYYY/MM/DD') AS FECHA_AUDITORIA, TO_CHAR(C.FECHA_ATENCION,'YYYY/MM/DD') AS FECHA_PROC, SUC.COD_CIUDAD AS CIUDAD 
				  FROM MSO_P_USUARIO A 
			INNER JOIN SALUDMP.MSO_P_CARNET_USUARIO B ON A.NO_DOCUMENTO = B.NO_DOCUMENTO 
			INNER JOIN SALUDMP.MSO_PLAN_TRATAMIENTO D ON D.NUM_CARNET = B.NUM_CARNET 
			INNER JOIN SALUDMP.MSO_SOLICITUD_TRATAMIENTO C ON C.CONS_PLAN_TRATAMIENTO = D.CONS_PLAN_TRATAMIENTO 
			 LEFT JOIN SALUDMP.MSO_P_PROCEDIMIENTO PO ON PO.COD_PROCEDIMIENTO = C.COD_PROCEDIMIENTO 
			 LEFT JOIN SALUDMP.MSO_P_SUCURSAL SUC ON SUC.COD_SUCURSAL = D.COD_SUCURSAL 
			 LEFT JOIN SALUDMP.MSO_EVOLUCION_SOLICITUD EVOL ON EVOL.CONS_SOLICITUD_TRATAMIENTO = C.CONS_SOLICITUD_TRATAMIENTO 
			 LEFT JOIN SALUDMP.MSO_P_PRESTADOR PRES ON PRES.NIT_PRESTADOR = D.NIT_PRESTADOR 
			INNER JOIN MSO_H_ESTADO_SOLICITUD EST on EST.CONS_SOLICITUD_TRATAMIENTO = D.CONS_PLAN_TRATAMIENTO 
				 WHERE A.COD_TIPO_DOCUMENTO = prm_docu_tipo
				   AND A.NO_DOCUMENTO = prm_docu_nro
				   AND D.FECHA_CREA >= TO_DATE (prm_fec_inicio, 'yyyy-mm-dd') 
				   AND D.FECHA_CREA <= TO_DATE (prm_fec_fin, 'yyyy-mm-dd')+1 
			  ORDER BY FECHA_SOLICITUD DESC;
			  
				codError := 0;
				msgError := 'Ok';
								
			ELSE 

				-- Valida si la ciudad existe
				OPEN CU_ciudad;
				FETCH CU_ciudad INTO  lnu_cantCiudad;	
				CLOSE CU_ciudad;
				
				IF (lnu_cantCiudad = 0) THEN
					codError := 3;
					msgError := 'Ciudad no existe.';		
				END IF;

				IF (codError = 0) THEN 
				
					OPEN registros FOR
					
					SELECT TO_CHAR(Z.FECHA_SOLICITUD,'YYYY/MM/DD')FECHA_SOLICITUD, 
						   PO.NOMBRE AS DESC_PROC, 
						   PRES.RAZON_SOCIAL AS PRESTADOR, 
						   X.OBSERVACION_AUDITORIA AS OBSERVACION, 
						   EVOL.ESTADO_EVOLUCION_SOLICITUD AS ESTADO_SOLICITUD, 
						   X.ESTADO AS ESTADO_PIV, 
						   X.NUM_AUTORIZACION, 
						   TO_CHAR(X.FECHA_AUDITORIA,'YYYY/MM/DD') AS FECHA_AUDITORIA, 
						   TO_CHAR(X.FECHA_ATENCION,'YYYY/MM/DD') AS FECHA_PROC, 
						   SUC.COD_CIUDAD AS CIUDAD 
					  FROM MSO_P_USUARIO A  
				INNER JOIN SALUDMP.MSO_P_CARNET_USUARIO B ON A.NO_DOCUMENTO = B.NO_DOCUMENTO 
				INNER JOIN SALUDMP.MSO_PLAN_TRATAMIENTO_PIV Z on Z.NUM_CARNET = B.NUM_CARNET 
				INNER JOIN SALUDMP.MSO_SOLICITUD_TRATAMIENTO_PIV X on X.CONS_PLAN_TRATAMIENTO = Z.CONS_PLAN_TRATAMIENTO 
				 LEFT JOIN SALUDMP.MSO_P_PROCEDIMIENTO PO ON PO.COD_PROCEDIMIENTO = X.COD_PROCEDIMIENTO 
				 LEFT JOIN SALUDMP.MSO_P_SUCURSAL SUC ON SUC.COD_SUCURSAL = Z.COD_SUCURSAL 
				 LEFT JOIN SALUDMP.MSO_EVOLUCION_SOLICITUD EVOL ON EVOL.CONS_SOLICITUD_TRATAMIENTO = X.CONS_SOLICITUD_TRATAMIENTO 
				 LEFT JOIN SALUDMP.MSO_P_PRESTADOR PRES ON PRES.NIT_PRESTADOR = Z.NIT_PRESTADOR  
				 LEFT JOIN (SELECT vw.*, ROW_NUMBER() OVER(PARTITION BY CONS_SOLICITUD_TRATAMIENTO order by FECHA_ESTADO desc) AS RN FROM SALUDMP.MSO_H_ESTADO_SOLICITUD vw) EST ON EST.CONS_SOLICITUD_TRATAMIENTO = X.CONS_SOLICITUD_TRATAMIENTO AND RN = 1 
					 WHERE SUC.COD_CIUDAD = prm_ciudad
					   AND A.COD_TIPO_DOCUMENTO = prm_docu_tipo
					   AND A.NO_DOCUMENTO = prm_docu_nro
					   AND Z.FECHA_CREA >= TO_DATE(prm_fec_inicio, 'yyyy-mm-dd')  
					   AND Z.FECHA_CREA <= TO_DATE (prm_fec_fin, 'yyyy-mm-dd')+1  
					 UNION 
					SELECT TO_CHAR(D.FECHA_SOLICITUD,'YYYY/MM/DD')FECHA_SOLICITUD, PO.NOMBRE AS DESC_PROC, PRES.RAZON_SOCIAL AS PRESTADOR, C.OBSERVACION_AUDITORIA AS OBSERVACION, EVOL.ESTADO_EVOLUCION_SOLICITUD AS ESTADO_SOLICITUD, C.ESTADO AS ESTADO__PIV, C.NUM_AUTORIZACION, TO_CHAR(C.FECHA_AUDITORIA,'YYYY/MM/DD') AS FECHA_AUDITORIA, TO_CHAR(C.FECHA_ATENCION,'YYYY/MM/DD') AS FECHA_PROC, SUC.COD_CIUDAD AS CIUDAD 
					  FROM MSO_P_USUARIO A  
				INNER JOIN SALUDMP.MSO_P_CARNET_USUARIO B ON A.NO_DOCUMENTO = B.NO_DOCUMENTO 
				INNER JOIN SALUDMP.MSO_PLAN_TRATAMIENTO D ON D.NUM_CARNET = B.NUM_CARNET 
				INNER JOIN SALUDMP.MSO_SOLICITUD_TRATAMIENTO C ON C.CONS_PLAN_TRATAMIENTO = D.CONS_PLAN_TRATAMIENTO 
				 LEFT JOIN SALUDMP.MSO_P_PROCEDIMIENTO PO ON PO.COD_PROCEDIMIENTO = C.COD_PROCEDIMIENTO 
				 LEFT JOIN SALUDMP.MSO_P_SUCURSAL SUC ON SUC.COD_SUCURSAL = D.COD_SUCURSAL 
				 LEFT JOIN SALUDMP.MSO_EVOLUCION_SOLICITUD EVOL ON EVOL.CONS_SOLICITUD_TRATAMIENTO = C.CONS_SOLICITUD_TRATAMIENTO 
				 LEFT JOIN SALUDMP.MSO_P_PRESTADOR PRES ON PRES.NIT_PRESTADOR = D.NIT_PRESTADOR  
				 LEFT JOIN (SELECT vw.*, ROW_NUMBER() OVER(PARTITION BY CONS_SOLICITUD_TRATAMIENTO order by FECHA_ESTADO desc) AS RN1 FROM MSO_H_ESTADO_SOLICITUD vw) EST ON EST.CONS_SOLICITUD_TRATAMIENTO = C.CONS_SOLICITUD_TRATAMIENTO AND RN1 = 1 
					 WHERE SUC.COD_CIUDAD = prm_ciudad
					   AND A.COD_TIPO_DOCUMENTO = prm_docu_tipo
					   AND A.NO_DOCUMENTO = prm_docu_nro 
					   AND D.FECHA_CREA >= TO_DATE (prm_fec_inicio, 'yyyy-mm-dd')  
					   AND D.FECHA_CREA <= TO_DATE (prm_fec_fin, 'yyyy-mm-dd')+1 
				  ORDER BY FECHA_PROC DESC;

					codError := 0;
					msgError := 'Ok';
				
				END IF;
				
			END IF;			
			
		END IF;
      
  END pr_getUtilizacionesUsuSAO;   
 

END PSGEN_SNDSAODENT;
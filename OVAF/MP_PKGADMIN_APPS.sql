	CREATE OR REPLACE PACKAGE MP_PKGADMIN_APPS AS

	
		PROCEDURE pr_ListaAppsPorNomApp (
			  nomApp IN VARCHAR2,
			  codError OUT NUMBER,
			  msgError OUT VARCHAR2,
			  registros OUT SYS_REFCURSOR
			);

		PROCEDURE pr_ListaPlayerIDPorNumDoc (
			  numDoc IN VARCHAR2,
			  codError OUT NUMBER,
			  msgError OUT VARCHAR2,
			  registros OUT SYS_REFCURSOR
			);

		PROCEDURE pr_ListaNotificacionesPush (
			  tipoDoc IN VARCHAR2,
			  numDoc IN VARCHAR2,
			  fecInic IN DATE,
			  fecFin IN DATE,
			  nomApp IN VARCHAR2,
			  mensaje IN VARCHAR2,
			  codError OUT NUMBER,
			  msgError OUT VARCHAR2,
			  registros OUT SYS_REFCURSOR
			);
		PROCEDURE pr_CantNotificPush (
			  tipoDoc IN VARCHAR2,
			  numDoc IN VARCHAR2,
			  pvc_estado IN VARCHAR2,
			  codError OUT NUMBER,
			  msgError OUT VARCHAR2,
			  registros OUT SYS_REFCURSOR
			);		

		PROCEDURE pr_MarcarNotificPush (
			  pvc_lista_id  IN VARCHAR2,
			  pvc_estado IN VARCHAR2,
			  codError OUT NUMBER,
			  msgError OUT VARCHAR2,
			  registros OUT SYS_REFCURSOR
			);		

	END MP_PKGADMIN_APPS;
	/


	CREATE OR REPLACE PACKAGE BODY MP_PKGADMIN_APPS AS

	   PROCEDURE pr_ListaAppsPorNomApp (
			  nomApp IN VARCHAR2,
			  codError OUT NUMBER,
			  msgError OUT VARCHAR2,
			  registros OUT SYS_REFCURSOR
			) IS
		BEGIN

		  codError := 0;
		  msgError := 'Procedimiento ejecutado exitosamente';

		  -- Abrir el cursor y realizar una consulta SQL
		  OPEN registros FOR
			select APP_ID, ID from ADM_APPS WHERE NOMBRE = nomApp;
		END;

		PROCEDURE pr_ListaPlayerIDPorNumDoc (
			  numDoc IN VARCHAR2,
			  codError OUT NUMBER,
			  msgError OUT VARCHAR2,
			  registros OUT SYS_REFCURSOR
			) IS
		BEGIN

		  codError := 0;
		  msgError := 'Procedimiento ejecutado exitosamente';

		  -- Abrir el cursor y realizar una consulta SQL
		  OPEN registros FOR
			select PLAYER_ID from ADM_PUSHID where CODE_USER = numDoc;
		END;

		PROCEDURE pr_ListaNotificacionesPush (
			  tipoDoc IN VARCHAR2,
			  numDoc IN VARCHAR2,
			  fecInic IN DATE,
			  fecFin IN DATE,
			  nomApp IN VARCHAR2,
			  mensaje IN VARCHAR2,
			  codError OUT NUMBER,
			  msgError OUT VARCHAR2,
			  registros OUT SYS_REFCURSOR
			) IS
		BEGIN

		  codError := 0;
		  msgError := 'Procedimiento ejecutado exitosamente';

		  -- Abrir el cursor y realizar una consulta SQL
		  OPEN registros FOR
			SELECT  C.ID,
					C.DES_MENSAJE MENSAJE,
					TO_CHAR(C.FECHA, 'DD/MM/YYYY') FECHA,
					TO_CHAR(C.FECHA, 'HH24:MI:SS') HORA,
					NVL(C.ESTADO, 'NO LEIDO') ESTADO
			FROM    ADM_CENTRO_NOTIFICACIONES C
			INNER   JOIN ADM_APPS A on A.ID = C.ID_APP
			WHERE   C.TIPO_DOC = tipoDoc
			AND     C.NUM_DOC = numDoc
			AND     TRUNC(C.FECHA) between fecInic and fecFin
			AND     A.NOMBRE like nomApp
			AND     C.DES_MENSAJE like mensaje;

		END;

		PROCEDURE pr_CantNotificPush (
			  tipoDoc IN VARCHAR2,
			  numDoc IN VARCHAR2,
			  pvc_estado IN VARCHAR2,
			  codError OUT NUMBER,
			  msgError OUT VARCHAR2,
			  registros OUT SYS_REFCURSOR
			) IS
		BEGIN
		-- Se vaida si igreso un estado valido	
		IF (pvc_estado NOT IN ('NO LEIDO', 'LEIDO', 'ELIMINADO')) THEN
			codError := 1;
			msgError := 'Estado no valido';			  
		
		ELSE

		  codError := 0;
		  msgError := 'Procedimiento ejecutado exitosamente';

		  -- Abrir el cursor y realizar una consulta SQL
		  OPEN registros FOR
			SELECT  COUNT(1) cant_notific
			FROM    ADM_CENTRO_NOTIFICACIONES C
			WHERE   C.TIPO_DOC = tipoDoc
			AND     C.NUM_DOC = numDoc
			AND     NVL(C.ESTADO,'NO LEIDO') = NVL(pvc_estado,NVL(C.ESTADO,'NO LEIDO'));
			
		END IF;
		
		END;

		PROCEDURE pr_MarcarNotificPush (
			  pvc_lista_id  IN VARCHAR2,
			  pvc_estado IN VARCHAR2,
			  codError OUT NUMBER,
			  msgError OUT VARCHAR2,
			  registros OUT SYS_REFCURSOR
			) IS

			CURSOR cu_notificacion(lnu_id ADM_CENTRO_NOTIFICACIONES.ID%TYPE) IS

			  SELECT   COUNT(1)
				FROM   ADM_CENTRO_NOTIFICACIONES C
			   WHERE   C.ID = lnu_id;
			
			ltb_id      PSGEN_Generalservices.type_cadena;
			lnu_exist   NUMBER(1); 
			vc_id_error VARCHAR2(1000):=NULL;
			vc_id_exito VARCHAR2(1000):=NULL;
			lnu_marca   NUMBER(1):=0;
		BEGIN

		  --codError := 0;
		  --msgError := 'Procedimiento ejecutado exitosamente';


		-- Se vaida si igreso un estado valido	
		IF (pvc_estado NOT IN ('NO LEIDO', 'LEIDO', 'ELIMINADO')) THEN
			codError := 1;
			msgError := 'Estado no valido';			  
		
		ELSE
	
			ltb_id := PSGEN_Generalservices.fn_CadenatoArray(pvc_lista_id);	  
		
			FOR i IN ltb_id.FIRST .. ltb_id.LAST
			LOOP
				
				OPEN cu_notificacion(ltb_id (i));
				FETCH cu_notificacion INTO lnu_exist;
				CLOSE cu_notificacion;
				
				IF (lnu_exist=0) THEN 
					IF (vc_id_error IS NOT NULL) THEN
						vc_id_error:= vc_id_error||', ';
					END IF;
					vc_id_error := vc_id_error||ltb_id (i);
				ELSE
					lnu_marca := 1;
					UPDATE ADM_CENTRO_NOTIFICACIONES SET ESTADO = pvc_estado, FEC_ESTADO = SYSDATE WHERE ID = ltb_id (i);
					IF (vc_id_exito IS NOT NULL) THEN
						vc_id_exito:= vc_id_exito||', ';
					END IF;
					vc_id_exito := vc_id_exito||ltb_id (i);
				END IF;
			END LOOP;
			
			IF (lnu_marca=1) THEN 
				codError := 0;
				msgError := 'Marcación exitosa: '||vc_id_exito;			
				COMMIT;
			END IF;
			
			IF (vc_id_error IS NOT NULL) THEN
			
				IF (codError IS NULL) THEN 				
					codError := 2;
				ELSE
					msgError := msgError||' / ';				
				END IF;
				
				msgError := msgError||' Notificaciones Push no existen: '||vc_id_error;
				
			END IF;	

		END IF;
		
		END;
		
	END MP_PKGADMIN_APPS;
	/

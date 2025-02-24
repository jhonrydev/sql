create or replace PACKAGE BODY             PKG_ADM AS

   -- Procedimiento para obtener imágenes en formato JSON
    PROCEDURE SP_GET_IMAGES(
    pnu_id IN NUMBER DEFAULT NULL, -- ID opcional de la imagen
    pcl_json_result OUT CLOB, -- Resultado en formato JSON
    pnu_indconsulta OUT NUMBER, -- Indicador de éxito de la consulta
    pva_error_msg OUT VARCHAR2 -- Mensaje de error
) IS
    -- Declaración de cursores y variables locales
        lcu_images SYS_REFCURSOR; -- Cursor para obtener imágenes generales
        lcu_ios SYS_REFCURSOR; -- Cursor para obtener detalles de imágenes en dispositivos iOS
        lcu_android SYS_REFCURSOR; -- Cursor para obtener detalles de imágenes en dispositivos Android
        lnu_id NUMBER; -- Variable para almacenar el ID de la imagen
        lva_url VARCHAR2(255); -- Variable para almacenar la URL de la imagen
        lva_size VARCHAR2(10); -- Variable para almacenar el tamaño de la imagen
        lva_device VARCHAR2(255); -- Variable para almacenar el tipo de dispositivo
        lcl_json_ios CLOB; -- Variable para almacenar el JSON de las imágenes en iOS
        lcl_json_android CLOB; -- Variable para almacenar el JSON de las imágenes en Android
        lcl_json_images CLOB := '['; -- Variable para almacenar el JSON final de todas las imágenes
        lbo_first BOOLEAN := TRUE; -- Variable para controlar la concatenación de JSON
        lva_nombre VARCHAR2(100); -- Variable para almacenar el nombre de la imagen
        lva_usuario VARCHAR2(50); -- Variable para almacenar el usuario que registró la imagen
        lda_fecha_inicio DATE; -- Variable para almacenar la fecha de inicio de la imagen
        lda_fecha_expiracion DATE; -- Variable para almacenar la fecha de expiración de la imagen
        lnu_estado NUMBER; -- Variable para almacenar el estado de la imagen
				lva_estado VARCHAR2(5); -- Variable para almacenar el estado convertido (true/false)

        lva_tipo VARCHAR2(255); -- Variable para almacenar el tipo de la imagen
        lts_fecha_registro TIMESTAMP(6); -- Variable para almacenar la fecha de registro de la imagen
        lnu_version NUMBER; -- Variable para almacenar la versión de la imagen
        lnu_image_id NUMBER; -- Variable para almacenar el ID de la imagen detallada
    BEGIN
        BEGIN
            -- Abrir cursor para obtener información general de ADM_IMAGES_HOME si tiene detalles en ADM_DETAIL_IMAGES_HOME y ESTADO = 1
            IF pnu_id IS NOT NULL THEN
                -- Si se proporciona un ID específico, se filtra por ese ID
                OPEN lcu_images FOR
                    SELECT NOMBRE, USUARIO_REGISTRO, FECHA_INICIO, FECHA_EXPIRACION, FECHA_REGISTRO, VERSION, ESTADO, TIPO, ID
                    FROM ADM_IMAGES_HOME
                    WHERE ESTADO = 1 AND ID = pnu_id
                    AND EXISTS (
                        SELECT 1
                        FROM ADM_DETAIL_IMAGES_HOME d
                        WHERE d.IMAGE_HOME_ID = ADM_IMAGES_HOME.ID
                    );
            ELSE
                -- Si no se proporciona un ID, se obtienen todas las imágenes activas
                OPEN lcu_images FOR
                    SELECT NOMBRE, USUARIO_REGISTRO, FECHA_INICIO, FECHA_EXPIRACION, FECHA_REGISTRO, VERSION, ESTADO, TIPO, ID
                    FROM ADM_IMAGES_HOME
                    WHERE ESTADO = 1
                    AND EXISTS (
                        SELECT 1
                        FROM ADM_DETAIL_IMAGES_HOME d
                        WHERE d.IMAGE_HOME_ID = ADM_IMAGES_HOME.ID
                    );
            END IF;

            -- Iterar sobre cada imagen general obtenida
            LOOP
                FETCH lcu_images INTO lva_nombre, lva_usuario, lda_fecha_inicio, lda_fecha_expiracion, lts_fecha_registro, lnu_version, lnu_estado, lva_tipo, lnu_image_id;
                EXIT WHEN lcu_images%NOTFOUND;

                -- Inicializar los JSON para cada tipo de dispositivo
                lcl_json_ios := '[';
                lcl_json_android := '[';
                lbo_first := TRUE;

                -- Abrir cursor para dispositivos iOS
                OPEN lcu_ios FOR
                    SELECT d.ID, d.URL_IMAGE, d.SIZE_IMAGE, d.DEVICE
                    FROM ADM_DETAIL_IMAGES_HOME d
                    WHERE d.DEVICE = 'iOS' AND d.IMAGE_HOME_ID = lnu_image_id;

                -- Procesar resultados para iOS
                LOOP
                    FETCH lcu_ios INTO lnu_id, lva_url, lva_size, lva_device;
                    EXIT WHEN lcu_ios%NOTFOUND;
                    -- Añadir comas entre objetos JSON si no es el primer elemento
                    IF lbo_first THEN
                        lbo_first := FALSE;
                    ELSE
                        lcl_json_ios := lcl_json_ios || ',';
                    END IF;
                    -- Construir objeto JSON para una imagen iOS
                    lcl_json_ios := lcl_json_ios || '{"id":' || lnu_id || ',"url":"' || lva_url || '","size":"' || lva_size || '","device":"' || lva_device || '"}';
                END LOOP;
                CLOSE lcu_ios;
                lcl_json_ios := lcl_json_ios || ']'; -- Cerrar el array JSON para iOS

                -- Inicializar variable de control para Android
                lbo_first := TRUE;
                -- Abrir cursor para dispositivos Android
                OPEN lcu_android FOR
                    SELECT d.ID, d.URL_IMAGE, d.SIZE_IMAGE, d.DEVICE
                    FROM ADM_DETAIL_IMAGES_HOME d
                    WHERE d.DEVICE = 'Android' AND d.IMAGE_HOME_ID = lnu_image_id;

                -- Procesar resultados para Android
                LOOP
                    FETCH lcu_android INTO lnu_id, lva_url, lva_size, lva_device;
                    EXIT WHEN lcu_android%NOTFOUND;
                    -- Añadir comas entre objetos JSON si no es el primer elemento
                    IF lbo_first THEN
                        lbo_first := FALSE;
                    ELSE
                        lcl_json_android := lcl_json_android || ',';
                    END IF;
                    -- Construir objeto JSON para una imagen Android
                    lcl_json_android := lcl_json_android || '{"id":' || lnu_id || ',"url":"' || lva_url || '","size":"' || lva_size || '","device":"' || lva_device || '"}';
                END LOOP;
                CLOSE lcu_android;
                lcl_json_android := lcl_json_android || ']'; -- Cerrar el array JSON para Android

                -- Convertir el estado a true o false
                lva_estado := CASE WHEN lnu_estado = 1 THEN 'true' ELSE 'false' END;

                -- Añadir información de la imagen al JSON final
                IF lcl_json_images <> '[' THEN
                    lcl_json_images := lcl_json_images || ','; -- Añadir coma si no es el primer elemento
                END IF;
                lcl_json_images := lcl_json_images || '{"name": "' || lva_nombre || '", "user": "' || lva_usuario || '", "startDate": "' || TO_CHAR(lda_fecha_inicio, 'YYYY-MM-DD HH24:MI:SS') || '", "expirationDate": "' || TO_CHAR(lda_fecha_expiracion, 'YYYY-MM-DD HH24:MI:SS') || '", "version": ' || lnu_version || ', "status": ' || lva_estado || ', "type": "' || lva_tipo || '", "images": {"ios": ' || lcl_json_ios || ', "android": ' || lcl_json_android || '}}';
            END LOOP;
            CLOSE lcu_images;

            -- Completar el JSON final
            lcl_json_images := lcl_json_images || ']';
            pcl_json_result := lcl_json_images; -- Asignar resultado al parámetro de salida
						COMMIT;
            -- Indicar que la consulta fue exitosa
            pnu_indconsulta := 1;
            pva_error_msg := NULL;
        EXCEPTION
            WHEN OTHERS THEN
                -- En caso de error, indicar que la consulta falló y devolver mensaje de error
                pnu_indconsulta := 0;
                pva_error_msg := SQLERRM;
                -- Devolver mensaje de error en formato JSON
                pcl_json_result := '{"error": "Error en la consulta."}';
        END;
    END SP_GET_IMAGES;



		PROCEDURE SP_GET_IMAGES_BY_TYPE(
  	pva_device IN VARCHAR2,
					pva_size_image IN VARCHAR2,
					pva_arquetipo IN VARCHAR2,
					pcur_generica OUT SYS_REFCURSOR,
					pcur_arquetipo OUT SYS_REFCURSOR,
					pva_error_msg OUT VARCHAR2
) IS
    lnu_home_id NUMBER;
    lnu_home_version NUMBER;
    lnu_splash_id NUMBER;
    lnu_splash_version NUMBER;
BEGIN


        OPEN pcur_generica FOR
          WITH LatestImages AS (
						SELECT ih.ID,
									 ih.NOMBRE,
									 ih.FECHA_EXPIRACION,
									 ih.FECHA_INICIO,
									 ih.FECHA_REGISTRO,
									 ih.USUARIO_REGISTRO,
									 ih.VERSION,
									 ih.ESTADO,
									 ih.TIPO,
									 ih.ARQUETIPO,
									 RANK() OVER (PARTITION BY ih.TIPO ORDER BY ih.VERSION DESC) AS rnk
						FROM ADM_IMAGES_HOME ih
						WHERE ih.TIPO IN ('SPLASH', 'HOME') 
							AND ih.ESTADO = 1
							AND ih.ARQUETIPO IS NULL
					)
					SELECT li.ID,
								 li.NOMBRE,
								 li.VERSION,
								 li.TIPO,
								 di.DEVICE,
								 di.SIZE_IMAGE,
								 di.URL_IMAGE,
								 di.STATUS
					FROM LatestImages li
					JOIN ADM_DETAIL_IMAGES_HOME di ON li.ID = di.IMAGE_HOME_ID
					WHERE li.rnk = 1 
							AND LOWER(di.DEVICE) = LOWER(pva_device)
						AND LOWER(di.SIZE_IMAGE) = LOWER(pva_size_image)
					ORDER BY li.TIPO, li.VERSION DESC;


					 OPEN pcur_arquetipo FOR
          WITH LatestImages AS (
						SELECT ih.ID,
									 ih.NOMBRE,
									 ih.FECHA_EXPIRACION,
									 ih.FECHA_INICIO,
									 ih.FECHA_REGISTRO,
									 ih.USUARIO_REGISTRO,
									 ih.VERSION,
									 ih.ESTADO,
									 ih.TIPO,
									 ih.ARQUETIPO,
									 RANK() OVER (PARTITION BY ih.TIPO ORDER BY ih.VERSION DESC) AS rnk
						FROM ADM_IMAGES_HOME ih
						WHERE ih.TIPO IN ('SPLASH', 'HOME') 
							AND ih.ESTADO = 1
						AND EXISTS (
                    SELECT 1
                    FROM (
                        SELECT TRIM(REGEXP_SUBSTR(pva_arquetipo, '[^,]+', 1, LEVEL)) AS valor
                        FROM DUAL
                        CONNECT BY REGEXP_SUBSTR(pva_arquetipo, '[^,]+', 1, LEVEL) IS NOT NULL
                    ) temp
                    WHERE UPPER(ih.ARQUETIPO) = UPPER(temp.valor)
                )

					)
					SELECT li.ID,
								 li.NOMBRE,
								 li.VERSION,
								 li.TIPO,
								 di.DEVICE,
								 di.SIZE_IMAGE,
								 di.URL_IMAGE,
								 di.STATUS,
								 pva_arquetipo 
					FROM LatestImages li
					JOIN ADM_DETAIL_IMAGES_HOME di ON li.ID = di.IMAGE_HOME_ID
					WHERE li.rnk = 1 
						AND LOWER(di.DEVICE) = LOWER(pva_device)
						AND LOWER(di.SIZE_IMAGE) = LOWER(pva_size_image)
					ORDER BY li.TIPO, li.VERSION DESC;

				COMMIT;
        pva_error_msg := CONCAT('Transaccion ejecutada correctamente - ',pva_arquetipo);
    EXCEPTION
        WHEN OTHERS THEN

							pva_error_msg := SUBSTR(SQLERRM, 1, 4000);

            IF pcur_generica%ISOPEN THEN
                CLOSE pcur_generica;
            END IF;

						IF pcur_arquetipo%ISOPEN THEN
                CLOSE pcur_arquetipo;
            END IF;


END SP_GET_IMAGES_BY_TYPE;




  PROCEDURE SP_INSERT_IMAGES_HOME (
         p_json IN VARCHAR2
    ) IS
        v_id_home        NUMBER;
        v_nombre         VARCHAR2(100);
        v_usuario        VARCHAR2(50);
        v_fecha_inicio   VARCHAR2(20);
        v_fecha_expiracion VARCHAR2(20);
        v_fecha_inicio_date   DATE;
        v_fecha_expiracion_date DATE;
        v_version        NUMBER;
        v_tipo           VARCHAR2(10);

        -- Cursors para manejar los detalles
        CURSOR c_ios IS
            SELECT t.url, t.SIZE_IMAGE, t.device
            FROM JSON_TABLE(p_json, '$.images.ios[*]'
                COLUMNS (
                    url VARCHAR2(255) PATH '$.url',
                    SIZE_IMAGE VARCHAR2(10) PATH '$.size',
                    device VARCHAR2(10) PATH '$.device'
                )) t;

        CURSOR c_android IS
            SELECT t.url, t.SIZE_IMAGE, t.device
            FROM JSON_TABLE(p_json, '$.images.android[*]'
                COLUMNS (
                    url VARCHAR2(255) PATH '$.url',
                    SIZE_IMAGE VARCHAR2(10) PATH '$.size',
                    device VARCHAR2(10) PATH '$.device'
                )) t;

    BEGIN
        -- Parsear el JSON de entrada para obtener los detalles generales
        SELECT nombre, usuario, fecha_inicio, fecha_expiracion, version, tipo
        INTO v_nombre, v_usuario, v_fecha_inicio, v_fecha_expiracion, v_version, v_tipo
        FROM JSON_TABLE(p_json, '$'
            COLUMNS (
                nombre VARCHAR2(100) PATH '$.nombre',
                usuario VARCHAR2(50) PATH '$.usuario',
                fecha_inicio VARCHAR2(20) PATH '$.fechaInicio',
                fecha_expiracion VARCHAR2(20) PATH '$.fechaExpiracion',
                version NUMBER PATH '$.version',
                tipo VARCHAR2(10) PATH '$.tipo'
            ));

        -- Convertir las fechas de VARCHAR2 a DATE
        v_fecha_inicio_date := TO_DATE(v_fecha_inicio, 'YYYY-MM-DD HH24:MI:SS');
        v_fecha_expiracion_date := TO_DATE(v_fecha_expiracion, 'YYYY-MM-DD HH24:MI:SS');

        -- Validar el tipo
        IF v_tipo NOT IN ('HOME', 'SPLASH') THEN
            RAISE_APPLICATION_ERROR(-20003, 'Invalid TIPO value: ' || v_tipo);
        END IF;

        -- Obtener el siguiente valor de la secuencia
        SELECT ADM_IMAGES_HOME_SEQ.NEXTVAL INTO v_id_home FROM DUAL;

        -- Insertar en ADM_IMAGES_HOME
        INSERT INTO ADM_IMAGES_HOME (
            ID,
            NOMBRE,
            FECHA_EXPIRACION,
            FECHA_INICIO,
            FECHA_REGISTRO,
            USUARIO_REGISTRO,
            VERSION,
            ESTADO,
            TIPO
        ) VALUES (
            v_id_home,
            v_nombre,
            v_fecha_expiracion_date,
            v_fecha_inicio_date,
            SYSTIMESTAMP,
            v_usuario,
            v_version,
            1, -- Asumiendo que 1 es el estado activo
            v_tipo -- Valor enviado como parámetro
        );

        -- Insertar en ADM_DETAIL_IMAGES_HOME para iOS
        FOR r IN c_ios LOOP
            INSERT INTO ADM_DETAIL_IMAGES_HOME (
                ID,
                IMAGE_HOME_ID,
                DEVICE,
                SIZE_IMAGE,
                URL_IMAGE,
                STATUS
            ) VALUES (
                ADM_DETAIL_IMAGES_HOME_SEQ.NEXTVAL,
                v_id_home,
                r.device,
                r.SIZE_IMAGE,
                r.url,
                1 -- Asumiendo que 1 es el estado activo
            );
        END LOOP;

        -- Insertar en ADM_DETAIL_IMAGES_HOME para Android
        FOR r IN c_android LOOP
            INSERT INTO ADM_DETAIL_IMAGES_HOME (
                ID,
                IMAGE_HOME_ID,
                DEVICE,
                SIZE_IMAGE,
                URL_IMAGE,
                STATUS
            ) VALUES (
                ADM_DETAIL_IMAGES_HOME_SEQ.NEXTVAL,
                v_id_home,
                r.device,
                r.SIZE_IMAGE,
                r.url,
                1 -- Asumiendo que 1 es el estado activo
            );
        END LOOP;

        COMMIT;
    END SP_INSERT_IMAGES_HOME;

		PROCEDURE SP_UPDATE_IMAGES_HOME(
        p_id IN NUMBER,
        p_json IN VARCHAR2
    ) IS
        v_nombre VARCHAR2(100);
        v_usuario VARCHAR2(50);
        v_fecha_inicio VARCHAR2(20);
        v_fecha_expiracion VARCHAR2(20);
        v_fecha_inicio_date DATE;
        v_fecha_expiracion_date DATE;
        v_version NUMBER;
        v_tipo VARCHAR2(10);

        CURSOR c_ios IS
            SELECT t.url, t.SIZE_IMAGE, t.device
            FROM JSON_TABLE(p_json, '$.images.ios[*]'
                COLUMNS (
                    url VARCHAR2(255) PATH '$.url',
                    SIZE_IMAGE VARCHAR2(10) PATH '$.size',
                    device VARCHAR2(10) PATH '$.device'
                )) t;

        CURSOR c_android IS
            SELECT t.url, t.SIZE_IMAGE, t.device
            FROM JSON_TABLE(p_json, '$.images.android[*]'
                COLUMNS (
                    url VARCHAR2(255) PATH '$.url',
                    SIZE_IMAGE VARCHAR2(10) PATH '$.size',
                    device VARCHAR2(10) PATH '$.device'
                )) t;

    BEGIN
        SELECT nombre, usuario, fecha_inicio, fecha_expiracion, version, tipo
        INTO v_nombre, v_usuario, v_fecha_inicio, v_fecha_expiracion, v_version, v_tipo
        FROM JSON_TABLE(p_json, '$'
            COLUMNS (
                nombre VARCHAR2(100) PATH '$.nombre',
                usuario VARCHAR2(50) PATH '$.usuario',
                fecha_inicio VARCHAR2(20) PATH '$.fechaInicio',
                fecha_expiracion VARCHAR2(20) PATH '$.fechaExpiracion',
                version NUMBER PATH '$.version',
                tipo VARCHAR2(10) PATH '$.tipo'
            ));

        v_fecha_inicio_date := TO_DATE(v_fecha_inicio, 'YYYY-MM-DD HH24:MI:SS');
        v_fecha_expiracion_date := TO_DATE(v_fecha_expiracion, 'YYYY-MM-DD HH24:MI:SS');

        IF v_tipo NOT IN ('HOME', 'SPLASH') THEN
            RAISE_APPLICATION_ERROR(-20003, 'Invalid TIPO value: ' || v_tipo);
        END IF;

        UPDATE ADM_IMAGES_HOME
        SET NOMBRE = v_nombre,
            FECHA_EXPIRACION = v_fecha_expiracion_date,
            FECHA_INICIO = v_fecha_inicio_date,
            USUARIO_REGISTRO = v_usuario,
            VERSION = v_version,
            TIPO = v_tipo
        WHERE ID = p_id;

        DELETE FROM ADM_DETAIL_IMAGES_HOME WHERE IMAGE_HOME_ID = p_id;

        FOR r IN c_ios LOOP
            INSERT INTO ADM_DETAIL_IMAGES_HOME (
                ID,
                IMAGE_HOME_ID,
                DEVICE,
                SIZE_IMAGE,
                URL_IMAGE,
                STATUS
            ) VALUES (
                ADM_DETAIL_IMAGES_HOME_SEQ.NEXTVAL,
                p_id,
                r.device,
                r.SIZE_IMAGE,
                r.url,
                1
            );
        END LOOP;

        FOR r IN c_android LOOP
            INSERT INTO ADM_DETAIL_IMAGES_HOME (
                ID,
                IMAGE_HOME_ID,
                DEVICE,
                SIZE_IMAGE,
                URL_IMAGE,
                STATUS
            ) VALUES (
                ADM_DETAIL_IMAGES_HOME_SEQ.NEXTVAL,
                p_id,
                r.device,
                r.SIZE_IMAGE,
                r.url,
                1
            );
        END LOOP;

        COMMIT;
    END SP_UPDATE_IMAGES_HOME;

		---------------------------------------
		---NOMBRE: Jose Luis Escobar
		---Desarrollador Backend
		---Proximate SAS
		---Cel: 3197757661
		---Email: jlescobar@proximateapps.com
		--- Sp para guardar los datos del Skill Agente desde el backoffice
		---------------------------------------
		PROCEDURE PR_GUARDAR_SKILL(
		num_id IN NUMBER,
		var_nombre_completo IN VARCHAR2,
		var_foto IN VARCHAR2,				
		var_url_chat IN VARCHAR2,
		var_numero_whatsapp IN VARCHAR2,
		dat_fecha_alta IN VARCHAR2,
		dat_fecha_baja IN VARCHAR2,
		dat_fecha_actualizacion IN VARCHAR2,
		var_observaciones IN VARCHAR2,
		num_estado IN NUMBER,
		codError OUT NUMBER,
		msgError OUT VARCHAR2,
		registros OUT SYS_REFCURSOR
			) IS


							CURSOR curskill IS
							SELECT ID
							FROM ADM_SKILL_AGENTE
							WHERE ADM_SKILL_AGENTE.ESTADO IN (1,2) AND ADM_SKILL_AGENTE.ID = num_id;

							p_skill NUMBER;
						BEGIN
							IF curskill%isopen THEN
							CLOSE curskill;
							END IF;
							OPEN curskill;
							FETCH curskill INTO
									p_skill;
							CLOSE curskill;



						IF p_skill IS NULL AND num_id != 0 THEN
							raise_application_error(-20003,CONCAT('No se encontro el agente a actualizar',p_skill));
						END IF;

					  IF num_id IS NULL OR num_id= '' THEN
							raise_application_error(-20001, 'El valor de num_id no puede ser nullo  o vacio');
						END IF;
						IF var_nombre_completo IS NULL OR var_nombre_completo = '' THEN
							raise_application_error(-20002, 'El valor de var_nombre_completo no puede ser nullo o vacio');
						END IF;
						IF var_foto IS NULL OR var_foto = '' THEN
							raise_application_error(-20003, 'El valor de var_foto no puede ser nullo o vacio');
						END IF;
						IF var_url_chat IS NULL OR var_url_chat = '' THEN
							raise_application_error(-20004, 'El valor de var_url_chat no puede ser nullo o vacio');
						END IF;

						/*IF dat_fecha_alta IS NULL OR dat_fecha_alta = ''THEN
							raise_application_error(-20006, 'El valor de dat_fecha_alta no puede ser nullo o vacio');
						END IF;*/
						IF num_estado IS NULL  OR num_estado = '' THEN
							raise_application_error(-20007, 'El valor de num_estado no puede ser nullo o vacio');
						END IF;
						IF num_estado < 0  OR num_estado > 2 THEN
							raise_application_error(-20008, 'El valor de num_estado no es valido');
						END IF;

					IF num_id = 0 THEN
						INSERT INTO ADM_SKILL_AGENTE( 
						ID,
						NOMBRE_COMPLETO,
						FOTO,
						URL_CHAT,
						NUMERO_WHATSAPP,
						FECHA_ALTA,
						ESTADO)
						VALUES (
						ADM_SEQ_SKILL.NEXTVAL,
						var_nombre_completo,
						var_foto,
						var_url_chat,
						var_numero_whatsapp,
						SYSDATE,
						num_estado);
					ELSE
						UPDATE ADM_SKILL_AGENTE 
						SET NOMBRE_COMPLETO =var_nombre_completo ,
						FOTO = var_foto,
						URL_CHAT = var_url_chat,
						NUMERO_WHATSAPP = var_numero_whatsapp,
						FECHA_ACTUALIZACION= SYSDATE,
						ESTADO = num_estado 
						WHERE id = num_id;
					END IF;

					COMMIT;
            codError := 1;
						msgError := 'Registro guardado correctamente';
			 EXCEPTION


				WHEN OTHERS THEN
              codError := SQLCODE;
							msgError := SUBSTR(SQLERRM, 1, 4000);
			END PR_GUARDAR_SKILL;

		---------------------------------------
		---NOMBRE: Jose Luis Escobar
		---Desarrollador Backend
		---Proximate SAS
		---Cel: 3197757661
		---Email: jlescobar@proximateapps.com
		--- SP para guardar listar los skills
		---------------------------------------

			PROCEDURE PR_LIST_SKILL(
				num_id NUMBER,
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			) IS BEGIN


				OPEN registros FOR 
				SELECT ID,NOMBRE_COMPLETO,FOTO,URL_CHAT,NUMERO_WHATSAPP,FECHA_ALTA,FECHA_BAJA,FECHA_ACTUALIZACION,OBSERVACIONES,ESTADO
				FROM ADM_SKILL_AGENTE
				WHERE ADM_SKILL_AGENTE.ESTADO IN (1,2) AND (num_id = 0 OR ADM_SKILL_AGENTE.ID = num_id)
				ORDER BY ADM_SKILL_AGENTE.ID ASC;


				COMMIT;
            codError := 1;
						msgError := 'Regsitros encontrados';
			 EXCEPTION
				WHEN OTHERS THEN
              codError := SQLCODE;
							msgError := SUBSTR(SQLERRM, 1, 4000);
			END PR_LIST_SKILL;


			---------------------------------------
		---NOMBRE: Jose Luis Escobar
		---Desarrollador Backend
		---Proximate SAS
		---Cel: 3197757661
		---Email: jlescobar@proximateapps.com
		--- SP para guardar filtrar skill por ID
		---------------------------------------

			PROCEDURE PR_GET_SKILL_BY_ID(
				num_id NUMBER,
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			) IS BEGIN

			 IF num_id IS NULL OR num_id= '' THEN
				raise_application_error(-20001, 'El valor de id no puede ser nullo  o vacio');
				END IF;


				OPEN registros FOR 
				SELECT ID,NOMBRE_COMPLETO,FOTO,URL_CHAT,NUMERO_WHATSAPP,FECHA_ALTA,FECHA_BAJA,FECHA_ACTUALIZACION,OBSERVACIONES,ESTADO
				FROM ADM_SKILL_AGENTE
				WHERE ADM_SKILL_AGENTE.ESTADO IN (1) AND  ADM_SKILL_AGENTE.ID = num_id
				ORDER BY ADM_SKILL_AGENTE.ID ASC;


				COMMIT;
            codError := 1;
						msgError := 'Regsitros encontrados';
			 EXCEPTION
				WHEN OTHERS THEN
             codError := SQLCODE;
							msgError := SUBSTR(SQLERRM, 1, 4000);
			END PR_GET_SKILL_BY_ID;


			---------------------------------------
		---NOMBRE: Jose Luis Escobar
		---Desarrollador Backend
		---Proximate SAS
		---Cel: 3197757661
		---Email: jlescobar@proximateapps.com
		--- SP para guardar cambiar el estado de los skills
		---------------------------------------

			PROCEDURE PR_CAMBIAR_ESTADO_SKILL(
						var_id IN VARCHAR2,
					num_estado IN NUMBER,
					var_observaciones IN VARCHAR2,
					codError OUT NUMBER,
					msgError OUT VARCHAR2,
					registros OUT SYS_REFCURSOR
				) IS 


					p_fechabaja VARCHAR2(20);
					p_skill NUMBER;
				BEGIN




					  IF var_id IS NULL OR var_id= '' THEN
							raise_application_error(-20001, 'No se han especificado agentes para cambiar de estado');
						END IF;
						IF num_estado IS NULL OR num_estado = '' THEN
							raise_application_error(-20002, 'El valor de num_estado no puede ser nullo o vacio');
						END IF;
						IF num_estado < 0  OR num_estado > 2 THEN
							raise_application_error(-20008, 'El valor de num_estado no es valido');
						END IF;

						IF(num_estado = 0) THEN
							p_fechabaja:= SYSDATE;
						END IF;

						UPDATE ADM_SKILL_AGENTE SET ESTADO = num_estado, OBSERVACIONES = var_observaciones, 
						FECHA_BAJA = CASE 
									WHEN num_estado = 0 THEN SYSDATE ELSE NULL
							END
						WHERE ADM_SKILL_AGENTE.ID IN (
								SELECT regexp_substr(var_id, '[^,]+', 1, level) valor
								FROM dual
								CONNECT BY regexp_substr(var_id, '[^,]+', 1, level) IS NOT NULL);

					COMMIT;
						codError := 1;
						msgError := 'Transacción ejecutada correctamente ';
						EXCEPTION
							WHEN OTHERS THEN
									   codError := SQLCODE;
							msgError := SUBSTR(SQLERRM, 1, 4000);
				END PR_CAMBIAR_ESTADO_SKILL;

		---------------------------------------
		---NOMBRE: Jose Luis Escobar
		---Desarrollador Backend
		---Proximate SAS
		---Cel: 3197757661
		---Email: jlescobar@proximateapps.com
		--- SP para guardar los datos de los usuarios del backoffice
		---------------------------------------
				PROCEDURE PR_GUARDAR_USUARIO(
				num_id IN NUMBER,
				var_nombre_completo IN VARCHAR2,
				num_id_tipo_identificacion IN NUMBER,				
				var_numero_identificacion IN VARCHAR2,
				num_id_agente_asignado IN NUMBER,
				dat_fecha_alta IN VARCHAR2,
				dat_fecha_baja IN VARCHAR2,
				dat_fecha_actualizacion IN VARCHAR2,

				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			)  IS

							CURSOR cursUser IS
							SELECT ID
							FROM ADM_USUARIO
							WHERE ADM_USUARIO.ESTADO IN (1,2) AND ADM_USUARIO.ID = num_id;

								CURSOR cursDocTipo IS
							SELECT ID
							FROM ADM_TIPO_P_DOCUMENTO
							WHERE ADM_TIPO_P_DOCUMENTO.ESTADO IN (1,2) AND ADM_TIPO_P_DOCUMENTO.ID = num_id_tipo_identificacion;

								CURSOR cursSkill IS
							SELECT ID
							FROM ADM_SKILL_AGENTE
							WHERE ADM_SKILL_AGENTE.ESTADO IN (1,2) AND ADM_SKILL_AGENTE.ID = num_id_agente_asignado;

							p_idSkill NUMBER;
							p_documentoTipoId NUMBER;
							p_user NUMBER;
						BEGIN
							IF cursUser%isopen THEN
							CLOSE cursUser;
							END IF;
							OPEN cursUser;
							FETCH cursUser INTO
									p_user;
							CLOSE cursUser;

							IF cursDocTipo%isopen THEN
							CLOSE cursDocTipo;
							END IF;
							OPEN cursDocTipo;
							FETCH cursDocTipo INTO
									p_documentoTipoId;
							CLOSE cursDocTipo;

							IF cursSkill%isopen THEN
							CLOSE cursSkill;
							END IF;
							OPEN cursSkill;
							FETCH cursSkill INTO
									p_idSkill;
							CLOSE cursSkill;


						IF var_nombre_completo IS NULL OR var_nombre_completo = '' THEN
							raise_application_error(-20002, 'El valor de var_nombre_completo no puede ser nullo o vacio');
						END IF;
						IF num_id_tipo_identificacion IS NULL OR num_id_tipo_identificacion = '' THEN
							raise_application_error(-20003, 'El valor de num_id_tipo_identificacion no puede ser nullo o vacio');
						END IF;
						IF p_documentoTipoId IS NULL OR p_documentoTipoId = '' THEN
							raise_application_error(-20004, 'El tipo de identificacion seleccionado no existe: '+p_documentoTipoId);
						END IF;
						IF var_numero_identificacion IS NULL OR var_numero_identificacion = '' THEN
							raise_application_error(-20005, 'El valor de var_numero_identificacion no puede ser nullo o vacio');
						END IF;
						IF num_id_agente_asignado IS NULL OR num_id_agente_asignado = '' THEN
							raise_application_error(-20006, 'El valor de num_id_agente_asignado no puede ser nullo o vacio');
						END IF;

						IF p_idSkill IS NULL THEN
							raise_application_error(-20007, 'El agente asinado no existe');
						END IF;

						IF dat_fecha_alta IS NULL OR dat_fecha_alta = ''THEN
							raise_application_error(-20008, 'El valor de dat_fecha_alta no puede ser nullo o vacio');
						END IF;




						IF num_id = 0 THEN
							INSERT INTO ADM_USUARIO(ID,NOMBRE_COMPLETO,ID_TIPO_IDENTIFICACION,NUMERO_IDENTIFICACION,ID_AGENTE_ASIGNADO,FECHA_ALTA,ESTADO)
							VALUES (ADM_SEQ_USUARIO.NEXTVAL,var_nombre_completo,num_id_tipo_identificacion,var_numero_identificacion,num_id_agente_asignado,dat_fecha_alta,1);
						ELSE

						IF dat_fecha_actualizacion IS NULL  OR dat_fecha_actualizacion = '' THEN
								raise_application_error(-20011, 'El valor de dat_fecha_actualizacion no puede ser nullo o vacio');
						END IF;

						IF p_user IS NULL  OR p_user = '' THEN
								raise_application_error(-20012, 'El usuario a actualizar no existe');
						END IF;


						UPDATE ADM_USUARIO SET NOMBRE_COMPLETO =var_nombre_completo ,
						ID_TIPO_IDENTIFICACION = num_id_tipo_identificacion,
						NUMERO_IDENTIFICACION = var_numero_identificacion,
						ID_AGENTE_ASIGNADO = num_id_agente_asignado,
						FECHA_ACTUALIZACION= dat_fecha_actualizacion

						WHERE id = num_id;
					END IF;


					COMMIT;
            codError := 1;
						msgError := 'Registro guardado correctamente';
			 EXCEPTION
				WHEN OTHERS THEN
              codError := SQLCODE;
							msgError := SUBSTR(SQLERRM, 1, 4000);
			END PR_GUARDAR_USUARIO;


			PROCEDURE PR_CAMBIAR_ESTADO_USUARIO(
			var_id IN VARCHAR2,
			num_estado IN NUMBER,
			codError OUT NUMBER,
			msgError OUT VARCHAR2,
			registros OUT SYS_REFCURSOR
	) IS
			p_usuario NUMBER;
	BEGIN



			IF var_id IS NULL THEN
					raise_application_error(-20001, 'El valor de num_id no puede ser nulo o vacío');
			END IF;

			IF num_estado IS NULL THEN
					raise_application_error(-20002, 'El valor de num_estado no puede ser nulo o vacío');
			END IF;

			IF num_estado < 0 OR num_estado > 2 THEN
					raise_application_error(-20008, 'El valor de num_estado no es válido');
			END IF;

			UPDATE ADM_USUARIO 
			SET ESTADO = num_estado
			WHERE ADM_USUARIO.ID IN (
								SELECT regexp_substr(var_id, '[^,]+', 1, level) valor
								FROM dual
								CONNECT BY regexp_substr(var_id, '[^,]+', 1, level) IS NOT NULL);

			COMMIT;

			codError := 1;
			msgError := 'Transacción ejecutada correctamente';

	EXCEPTION
			WHEN OTHERS THEN
					   codError := SQLCODE;
							msgError := SUBSTR(SQLERRM, 1, 4000);
	END PR_CAMBIAR_ESTADO_USUARIO;

	---------------------------------------
			---NOMBRE: Jose Luis Escobar
			---Desarrollador Backend
			---Proximate SAS
			---Cel: 3197757661
			---Email: jlescobar@proximateapps.com
			--- SP para reasignar el agente de varos usuarios
			---------------------------------------


			---------------------------------------
			---NOMBRE: Jose Luis Escobar
			---Desarrollador Backend
			---Proximate SAS
			---Cel: 3197757661
			---Email: jlescobar@proximateapps.com
			--- SP para guardar los datos de los horarios de los skill
			---------------------------------------


			PROCEDURE PR_GUARDAR_HORARIO(
					num_id IN NUMBER,
					var_lun_vie_inicio IN VARCHAR2,
					var_lun_vie_fin IN VARCHAR2,
					var_sabado_inicio IN VARCHAR2,
					var_sabado_fin IN VARCHAR2,
					var_domingo_inicio IN VARCHAR2,
					var_domingo_fin IN VARCHAR2,
					var_festivo_inicio IN VARCHAR2,
					var_festivo_fin IN VARCHAR2,
					var_mensaje IN VARCHAR2,
					codError OUT NUMBER,
					msgError OUT VARCHAR2,
					registros OUT SYS_REFCURSOR
				) IS
						pnum_idskill NUMBER;

				 BEGIN


						IF(num_id =0 OR num_id IS NULL) THEN
							INSERT INTO ADM_HORARIO (ID,LUN_VIE_INICIO,LUN_VIV_FIN,SABADO_INICIO,SABADO_FIN,DOMINGO_INICIO,DOMINGO_FIN,FESTIVO_INICIO,FESTIVO_FIN,MENSAJE_HORARIO_NO_HABIL)
							VALUES (ADM_SEQ_HORARIO.NEXTVAL,var_lun_vie_inicio,var_lun_vie_fin, var_sabado_inicio, var_sabado_fin, var_domingo_inicio,var_domingo_fin,var_festivo_inicio,var_festivo_fin,
					var_mensaje);
						ELSE
						UPDATE ADM_HORARIO SET LUN_VIE_INICIO=var_lun_vie_inicio,
							LUN_VIV_FIN=var_lun_vie_fin,
							SABADO_INICIO=var_sabado_inicio,
							SABADO_FIN=var_sabado_fin,
							DOMINGO_INICIO=var_domingo_inicio,
							DOMINGO_FIN=var_domingo_fin,
							FESTIVO_INICIO=var_festivo_inicio,
							FESTIVO_FIN=var_festivo_fin,
							MENSAJE_HORARIO_NO_HABIL=var_mensaje

						WHERE ID = num_id;
						END IF;

					COMMIT;
            codError := 1;
						msgError := 'Transaccion ejecutada correctamente';
			 EXCEPTION
				WHEN OTHERS THEN
               codError := SQLCODE;
							msgError := SUBSTR(SQLERRM, 1, 4000);
			END PR_GUARDAR_HORARIO;


			PROCEDURE PR_GET_HORARIO(
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
				) IS BEGIN



						OPEN registros FOR 
						SELECT ID,LUN_VIE_INICIO,LUN_VIV_FIN,SABADO_INICIO,SABADO_FIN,DOMINGO_INICIO,DOMINGO_FIN,FESTIVO_INICIO,FESTIVO_FIN,MENSAJE_HORARIO_NO_HABIL
						FROM ADM_HORARIO WHERE ID = 1 AND ESTADO = 1;


					COMMIT;
            codError := 1;
						msgError := 'Transaccion ejecutada correctamente';
			 EXCEPTION
				WHEN OTHERS THEN
              codError := SQLCODE;
							msgError := SUBSTR(SQLERRM, 1, 4000);

			END PR_GET_HORARIO;


				---------------------------------------
			---NOMBRE: Jose Luis Escobar
			---Desarrollador Backend
			---Proximate SAS
			---Cel: 3197757661
			---Email: jlescobar@proximateapps.com
			--- SP obtener usuario por documento
			---------------------------------------


			PROCEDURE PR_GET_USER_POR_DOCUMENTO(
				num_documento NUMBER,
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			) IS BEGIN

				IF num_documento IS NULL THEN
					raise_application_error(-20001, 'Se requiere el numero de documento del usuario a consultar');
				END IF;

				OPEN registros FOR 
				SELECT ID,NOMBRE_COMPLETO,ID_TIPO_IDENTIFICACION,NUMERO_IDENTIFICACION,ID_AGENTE_ASIGNADO,FECHA_BAJA,FECHA_ALTA,FECHA_ACTUALIZACION,ESTADO
				FROM ADM_USUARIO
				WHERE ADM_USUARIO.NUMERO_IDENTIFICACION = num_documento AND ADM_USUARIO.ESTADO IN (1,2);

				COMMIT;
            codError := 1;
						msgError := 'Transaccion ejecutada correctamente';
			 EXCEPTION
				WHEN OTHERS THEN
              codError := SQLCODE;
							msgError := SUBSTR(SQLERRM, 1, 4000);

			END PR_GET_USER_POR_DOCUMENTO;	



				---------------------------------------
			---NOMBRE: Jose Luis Escobar
			---Desarrollador Backend
			---Proximate SAS
			---Cel: 3197757661
			---Email: jlescobar@proximateapps.com
			--- SP obtener usuario por ID
			---------------------------------------
			PROCEDURE PR_GET_USER_POR_ID(
				num_id NUMBER,
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			) IS BEGIN

				IF num_id IS NULL THEN
					raise_application_error(-20001, 'Se requiere el id del usuario a consultar');
				END IF;

				OPEN registros FOR 
				SELECT ID,NOMBRE_COMPLETO,ID_TIPO_IDENTIFICACION,NUMERO_IDENTIFICACION,ID_AGENTE_ASIGNADO,FECHA_BAJA,FECHA_ALTA,FECHA_ACTUALIZACION,ESTADO
				FROM ADM_USUARIO
				WHERE ADM_USUARIO.ID = num_id AND ADM_USUARIO.ESTADO IN (1,2);

				COMMIT;
            codError := 1;
						msgError := 'Transaccion ejecutada correctamente';
			 EXCEPTION
				WHEN OTHERS THEN
              codError := SQLCODE;
							msgError := SUBSTR(SQLERRM, 1, 4000);

			END PR_GET_USER_POR_ID;		



				---------------------------------------
			---NOMBRE: Jose Luis Escobar
			---Desarrollador Backend
			---Proximate SAS
			---Cel: 3197757661
			---Email: jlescobar@proximateapps.com
			--- SP PARA LISTAR USUARIOS
			---------------------------------------

				PROCEDURE PR_LISTARUSUARIO(
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			) IS BEGIN


				OPEN registros FOR 
				SELECT ADM_USUARIO.ID,ADM_USUARIO.NOMBRE_COMPLETO,ID_TIPO_IDENTIFICACION, ADM_TIPO_P_DOCUMENTO.DESCRIPCION AS TIPO_DOCUMENTO,NUMERO_IDENTIFICACION,ID_AGENTE_ASIGNADO,ADM_USUARIO.FECHA_BAJA,ADM_USUARIO.FECHA_ALTA,ADM_USUARIO.FECHA_ACTUALIZACION,ADM_USUARIO.ESTADO,ADM_SKILL_AGENTE.ID AS SKILL_ID,ADM_SKILL_AGENTE.NOMBRE_COMPLETO, ADM_SKILL_AGENTE.ESTADO
				FROM ADM_USUARIO
				JOIN ADM_TIPO_P_DOCUMENTO ON ADM_TIPO_P_DOCUMENTO.ID = ADM_USUARIO.ID_TIPO_IDENTIFICACION
				JOIN ADM_SKILL_AGENTE ON ADM_SKILL_AGENTE.ID = ADM_USUARIO.ID_AGENTE_ASIGNADO
				WHERE ADM_USUARIO.ESTADO IN (1,2);

				COMMIT;
            codError := 1;
						msgError := 'Transaccion ejecutada correctamente';
			 EXCEPTION
				WHEN OTHERS THEN
              codError := SQLCODE;
							msgError := SUBSTR(SQLERRM, 1, 4000);

			END PR_LISTARUSUARIO;			


			PROCEDURE PR_LISTARTIPOSDOCUMENTOS(
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			) IS BEGIN


				OPEN registros FOR 
				SELECT ID, CODIGO, DESCRIPCION, ESTADO
				FROM ADM_TIPO_P_DOCUMENTO
				WHERE ADM_TIPO_P_DOCUMENTO.ESTADO IN (1);

				COMMIT;
            codError := 1;
						msgError := 'Transaccion ejecutada correctamente';
			 EXCEPTION
				WHEN OTHERS THEN
              codError := SQLCODE;
							msgError := SUBSTR(SQLERRM, 1, 4000);

			END PR_LISTARTIPOSDOCUMENTOS;	

			PROCEDURE PR_GUARDAR_USUARIOS_MASIVOS(
				p_users IN T_TABLA_USUARIOS,
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			) IS


			BEGIN


				DELETE FROM ADM_USUARIO;
				COMMIT;


					-- Utiliza FORALL para realizar la inserción masiva de registros
					FORALL i IN INDICES OF p_users
							INSERT INTO ADM_USUARIO (ID,NOMBRE_COMPLETO,ID_TIPO_IDENTIFICACION,NUMERO_IDENTIFICACION,ID_AGENTE_ASIGNADO,FECHA_ALTA,ESTADO)
							VALUES (
									ADM_SEQ_USUARIO.NEXTVAL,
									p_users(i).NOMBRE_COMPLETO,
									p_users(i).ID_TIPO_IDENTIFICACION,
									p_users(i).NUMERO_IDENTIFICACION,
									p_users(i).ID_AGENTE_ASIGNADO,
									(SELECT SYSDATE FROM dual),
									p_users(i).ESTADO
							);
					COMMIT;
            codError := 1;
						msgError := 'Transaccion ejecutada correctamente';
			 EXCEPTION
				WHEN OTHERS THEN
              codError := SQLCODE;
							msgError := SUBSTR(SQLERRM, 1, 4000);
			END PR_GUARDAR_USUARIOS_MASIVOS;

			PROCEDURE PR_REASIGNARAGENTE(
				pvar_idusuarios IN VARCHAR2,
				pnum_idskill IN NUMBER,
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			)IS


						CURSOR cursSkill IS
					SELECT ID
					FROM ADM_SKILL_AGENTE
					WHERE ADM_SKILL_AGENTE.ESTADO IN (1,2) AND ADM_SKILL_AGENTE.ID = pnum_idskill;

					p_idSkill NUMBER;

				BEGIN

					IF pnum_idskill IS NULL OR pnum_idskill = 0 THEN
					raise_application_error(-20001, 'No se especifico un agente');
				END IF;

					IF cursSkill%isopen THEN
					CLOSE cursSkill;
					END IF;
					OPEN cursSkill;
					FETCH cursSkill INTO
							p_idSkill;
					CLOSE cursSkill;

					IF p_idSkill IS NULL THEN
						raise_application_error(-20002, 'El agente asinado no existe');
					END IF;

				IF pvar_idusuarios IS NULL OR pvar_idusuarios = '' THEN
					raise_application_error(-20003, 'No se especificaron los usuarios para reasignar agente');
				END IF;


			UPDATE ADM_USUARIO SET ADM_USUARIO.ID_AGENTE_ASIGNADO = pnum_idskill
			WHERE ADM_USUARIO.ID   IN (
								SELECT regexp_substr(pvar_idusuarios, '[^,]+', 1, level) valor
								FROM dual
								CONNECT BY regexp_substr(pvar_idusuarios, '[^,]+', 1, level) IS NOT NULL);

			COMMIT;
            codError := 1;
						msgError := 'Transaccion ejecutada correctamente';
			 EXCEPTION
				WHEN OTHERS THEN
              codError := SQLCODE;
							msgError := SUBSTR(SQLERRM, 1, 4000);
			END PR_REASIGNARAGENTE;
            
            
           PROCEDURE PR_getfuncionalidadesinactivas(
                codError OUT NUMBER,
                msgError OUT VARCHAR2,
                registros OUT SYS_REFCURSOR
            ) IS
            BEGIN
                OPEN registros FOR 
                    SELECT 
                        Nombre as nombre_funcionalidad, msg_alerta  as mensaje_usuario
                    FROM 
                        ADM_P_FUNCIONALIDADES 
                    WHERE 
                        estado = 0
                    UNION ALL
                    SELECT
                        Nombre as nombre_funcionalidad, msg_alerta  as mensaje_usuario  
                    FROM 
                        ADM_P_SUBFUNCIONALIDADES 
                    WHERE 
                        estado = 0;
            
                codError := 0;
                msgError := 'Operación exitosa';
            
            EXCEPTION
                WHEN OTHERS THEN
                    codError := 2;
                    msgError := 'Error desconocido: ' || SQLERRM;
            END PR_getfuncionalidadesinactivas;
            
            ---------------------------------------------------------------------------------------------------------------------------
			---NOMBRE: Jhon Medina
			---Email: jhoni_medina@coomeva.com.co
			---Descripción: Obtiene todos los usuarios afiliados al programa Control y desarrollo menores o igual a 8 años de edad
			---------------------------------------------------------------------------------------------------------------------------
			
            PROCEDURE PR_GET_AFILIADOS_CONTROL_Y_DESARROLLO(
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			) IS BEGIN
        
         
            OPEN registros FOR 
            SELECT *
            FROM ADM_CONTROL_Y_DESARROLLO
            WHERE EDAD <= 8
            AND ESTADO_REGISTRO = 'VIGENTE';
        
            codError := 1;
            msgError := 'Transaccion ejecutada correctamente';
			 
             EXCEPTION
				WHEN OTHERS THEN
                codError := SQLCODE;
                msgError := SUBSTR(SQLERRM, 1, 4000);
						
			END PR_GET_AFILIADOS_CONTROL_Y_DESARROLLO;
            
END PKG_ADM;
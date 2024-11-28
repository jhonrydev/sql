create or replace PACKAGE BODY         "VDIR_PACK_INICIO_SESSION" AS

  FUNCTION VDIR_FN_GET_TIPO_DOCUMENTO RETURN sys_refcursor AS
  vl_cursor  sys_refcursor;
  BEGIN

     OPEN vl_cursor
       FOR 
        SELECT
            cod_tipo_identificacion as codigo,
            des_tipo_identificacion as nombre,    
            des_abr as nombre_abr
        FROM
            vdir_tipo_identificacion
        WHERE
          cod_estado = 1
          ORDER BY 2;

    RETURN vl_cursor;
  END VDIR_FN_GET_TIPO_DOCUMENTO;

  -------------------------------------------------------FUNCION PARA TRAER DATOS DEL SEXO

  FUNCTION VDIR_FN_GET_SEXO RETURN sys_refcursor AS
  vl_cursor  sys_refcursor;
  BEGIN

     OPEN vl_cursor
       FOR 
        SELECT
            cod_sexo as codigo,
            des_sexo as nombre,    
            des_abr as nombre_abr
        FROM
            vdir_sexo
        WHERE
          cod_estado = 1
          ORDER BY 2;

    RETURN vl_cursor;
  END VDIR_FN_GET_SEXO;


   ------------------------------------------------ PROCEDIMIENTO PARA GUARDAR EL USUARIO  
  PROCEDURE VDIR_SP_GUARDAR_USUARIO(
                             p_tipo_identificacion IN VDIR_PERSONA.COD_TIPO_IDENTIFICACION%TYPE,                            
                             p_numero_identificacion IN VDIR_PERSONA.NUMERO_IDENTIFICACION%TYPE,
                             p_nombre_1 IN VDIR_PERSONA.NOMBRE_1%TYPE,
                             p_nombre_2 IN VDIR_PERSONA.NOMBRE_2%TYPE,
                             p_apellido_1 IN VDIR_PERSONA.APELLIDO_1%TYPE,
                             p_apellido_2 IN VDIR_PERSONA.APELLIDO_2%TYPE,
                             p_fecha_nacimiento IN DATE, 
                             p_cod_sexo IN VDIR_PERSONA.COD_SEXO%TYPE,
                             p_telefono IN VDIR_PERSONA.TELEFONO%TYPE,
                             p_celular IN VDIR_PERSONA.CELULAR%TYPE,
                             p_email IN VDIR_PERSONA.EMAIL%TYPE,
                             p_usuario IN VDIR_USUARIO.LOGIN%TYPE,
                             p_clave IN VDIR_USUARIO.CLAVE%TYPE,
                             p_tipo_persona IN VDIR_TIPO_PERSONA.COD_TIPO_PERSONA%TYPE,
                             p_plan IN VDIR_PLAN.COD_PLAN%TYPE,
                             p_cod_estado IN VDIR_ESTADO.COD_ESTADO%TYPE,
                             p_corte IN VDIR_USUARIO.CORTE%TYPE,                             
                             p_respuesta OUT VARCHAR2 
                             )
 IS

  vl_sec_persona vdir_persona.cod_persona%TYPE;
  vl_sec_usuario vdir_usuario.cod_usuario%TYPE;
  vl_tipo_pesona vdir_tipo_persona.cod_tipo_persona%TYPE;

 BEGIN
     vl_tipo_pesona := 2;
     p_respuesta := 'Operaci&oacute;n realizada correctamente.';
     --se valida si la persona existe con su numero de cedula y el tipo de identificacion 

	 vl_sec_persona := VDIR_PACK_CONSULTA_USUARIOS.fnGetExistePersona(p_tipo_identificacion,p_numero_identificacion);       


   -- si la paersona no existe se inserta  
   IF(vl_sec_persona IS NULL)THEN

           SELECT VDIR_SEQ_PERSONA.NEXTVAL INTO vl_sec_persona FROM DUAL ;

           INSERT INTO vdir_persona (
            cod_persona,
            cod_tipo_identificacion,
            numero_identificacion,
            nombre_1,
            nombre_2,
            apellido_1,
            apellido_2,
            fecha_nacimiento,
            telefono,
            celular,
            email,            
            cod_sexo,           
            cod_estado

        ) VALUES (
           vl_sec_persona,
           p_tipo_identificacion,
           p_numero_identificacion,
           p_nombre_1,
           p_nombre_2,
           p_apellido_1,
           p_apellido_2 ,
           p_fecha_nacimiento,                                     
           p_telefono,
           p_celular,
           p_email ,
           p_cod_sexo ,
           p_cod_estado            
        );
   ELSE
       UPDATE vdir_persona
        SET
            cod_tipo_identificacion = p_tipo_identificacion,
            numero_identificacion = p_numero_identificacion,
            nombre_1 = p_nombre_1,
            nombre_2 = p_nombre_2,
            apellido_1 = p_apellido_1,
            apellido_2 = p_apellido_2,
            fecha_nacimiento = p_fecha_nacimiento,
            telefono = p_telefono,
            celular = p_celular,
            email = p_email,            
            cod_sexo = p_cod_sexo,           
            cod_estado = p_cod_estado
        WHERE
            cod_persona = vl_sec_persona;

   END IF;

   -- se inserta el tipo de persona al que pertence el usuario   
   MERGE INTO vdir_persona_tipoper tipop
   USING (
           SELECT
            vl_sec_persona AS cod_persona,
            p_tipo_persona AS cod_tipo_persona
          FROM
             DUAL   
      ) tipop2
   ON (tipop.cod_persona = tipop2.cod_persona AND tipop.cod_tipo_persona = tipop2.cod_tipo_persona)   
   WHEN NOT MATCHED THEN   
    INSERT (tipop.cod_persona_tipoper, tipop.cod_persona,tipop.cod_tipo_persona)
     VALUES (VDIR_SEQ_PERSONA_TIPOPER.NEXTVAL,tipop2.cod_persona, tipop2.cod_tipo_persona);
    
   -- se inserta al usuario como tipo persona beneficiario  
   MERGE INTO vdir_persona_tipoper tipop
   USING (
           SELECT
            vl_sec_persona AS cod_persona,
            vl_tipo_pesona AS cod_tipo_persona
          FROM
             DUAL   
      ) tipop2
   ON (tipop.cod_persona = tipop2.cod_persona AND tipop.cod_tipo_persona = tipop2.cod_tipo_persona)   
   WHEN NOT MATCHED THEN   
    INSERT (tipop.cod_persona_tipoper, tipop.cod_persona,tipop.cod_tipo_persona)
     VALUES (VDIR_SEQ_PERSONA_TIPOPER.NEXTVAL,tipop2.cod_persona, tipop2.cod_tipo_persona);       


    --Se valida si el login de usuario existe
	vl_sec_usuario := VDIR_PACK_CONSULTA_USUARIOS.fnGetExisteLogin(p_usuario);


    IF(vl_sec_usuario IS NULL)THEN

        SELECT VDIR_SEQ_USUARIO.NEXTVAL INTO vl_sec_usuario FROM DUAL ; 

        INSERT INTO vdir_usuario (
            cod_usuario,
            login,
            clave,
            cod_persona,
            cod_estado,
            cod_plan,
            corte
        ) VALUES (
           vl_sec_usuario,
           p_usuario,
           p_clave,
           vl_sec_persona,
           p_cod_estado,
           p_plan,
           p_corte
        );
    ELSE

        UPDATE vdir_usuario
            SET
                login = p_usuario,
                clave = p_clave,
                cod_persona = vl_sec_persona,
                cod_estado = p_cod_estado,
                cod_plan = p_plan,
                corte = p_corte
        WHERE
            cod_usuario = vl_sec_usuario;

    END IF;

     -- se enlaza el rol con el usuario   
   MERGE INTO vdir_rol_usuario rolusu
   USING (
            SELECT
               vl_sec_usuario AS cod_usuario,
               1   AS cod_rol 
            FROM
                DUAL

      ) rolusu2
   ON (rolusu.cod_usuario = rolusu2.cod_usuario AND rolusu.cod_rol = rolusu2.cod_rol)   
   WHEN NOT MATCHED THEN INSERT (rolusu.cod_rol_usuario, rolusu.cod_usuario,rolusu.cod_rol)
     VALUES (VDIR_SEQ_ROL_USUARIO.NEXTVAL,rolusu2.cod_usuario,rolusu2.cod_rol);


  COMMIT;

  EXCEPTION 
   WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, vl_sec_persona||' error VDIR_SP_GUARDAR_USUARIO. '||SQLERRM);
     p_respuesta := 'Ocurrio un error en la base de datos.';
   ROLLBACK;

 END VDIR_SP_GUARDAR_USUARIO;

 ------------------------------------------------ PROCEDIMIENTO PARA ACTUALIZAR EL CODIGO DE SEGURIDAD PARA CAMBIAR LA CLAVE

 PROCEDURE VDIR_SP_ACTUALIZAR_COD_SEG(p_identificacacion IN VDIR_PERSONA.numero_identificacion%TYPE,p_codigo_seguridad OUT VDIR_USUARIO.CODIGO_SEGURIDAD%TYPE)

 IS
  vl_codigo_usuario NUMBER;
  vl_codigo_seguridad NUMBER;
 BEGIN  


    SELECT
       usu.cod_usuario INTO vl_codigo_usuario    
    FROM
        vdir_persona per

        INNER JOIN VDIR_USUARIO usu
         ON usu.cod_persona = per.cod_persona
    WHERE
      per.numero_identificacion = p_identificacacion; 

    SELECT 
       (1000+ABS(MOD(dbms_random.random,9999))) INTO vl_codigo_seguridad
    FROM   dual;  

    UPDATE vdir_usuario

    SET
        codigo_seguridad = vl_codigo_seguridad
    WHERE
       cod_usuario = vl_codigo_usuario;    

    p_codigo_seguridad := vl_codigo_seguridad;

    COMMIT; 
    
   EXCEPTION 
   WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20000, 'error VDIR_SP_ACTUALIZAR_COD_SEG.');     
   ROLLBACK;

 END VDIR_SP_ACTUALIZAR_COD_SEG;

 ------------------------------------------------ PROCEDIMIENTO PARA ACTUALIZAR LA CLAVE DEL USUARIO
 PROCEDURE VDIR_SP_CAMBIAR_CLAVE(p_identificacacion IN VDIR_PERSONA.numero_identificacion%TYPE,p_codigo_seguridad IN VDIR_USUARIO.CODIGO_SEGURIDAD%TYPE, p_clave IN VDIR_USUARIO.CLAVE%TYPE,p_respuesta OUT VARCHAR2)

 IS

   vl_codigo_usuario NUMBER;   

 BEGIN

   p_respuesta := 'Operaci&oacute;n realizada correctamente.';

    BEGIN
    SELECT
       usu.cod_usuario INTO vl_codigo_usuario    
    FROM
        vdir_persona per

        INNER JOIN VDIR_USUARIO usu
         ON usu.cod_persona = per.cod_persona

    WHERE
      per.numero_identificacion = p_identificacacion
      AND usu.CODIGO_SEGURIDAD = p_codigo_seguridad;

    EXCEPTION WHEN OTHERS THEN    
     vl_codigo_usuario := NULL;
    END;  

    UPDATE vdir_usuario
        SET
            clave = p_clave
    WHERE
        cod_usuario = vl_codigo_usuario;

    IF vl_codigo_usuario IS NULL THEN
       p_respuesta := 'El c&oacute;digo de seguridad no corresponde con el n&uacute;mero de identificaci&oacute;n.';
    END IF;

    COMMIT;

     EXCEPTION 
       WHEN OTHERS THEN 
       
     RAISE_APPLICATION_ERROR(-20000, 'error VDIR_SP_CAMBIAR_CLAVE.');
     p_respuesta := 'Ocurrio un error en la base de datos.';
     ROLLBACK;  


 END VDIR_SP_CAMBIAR_CLAVE;

 ----------------------------------------------------------------------------  FUNCION PARA TRAER LOS DAOS DE LA PERSONA,USUAIRO Y ROLES 
 FUNCTION VDIR_FN_GET_DATOS_USUARIO(p_login IN vdir_usuario.login%TYPE,p_clave IN vdir_usuario.clave%TYPE) 

   RETURN sys_refcursor 
   AS

   vl_cursor sys_refcursor;   

    BEGIN

  OPEN vl_cursor
    FOR 
     SELECT
        persona.cod_persona ,
        persona.cod_tipo_identificacion,
        ti.DES_TIPO_IDENTIFICACION AS DES_TIP_IDENT_LONG,
        ti.DES_ABR AS DES_TIP_IDENT_SMALL,
        persona.numero_identificacion,
        persona.nombre_1,
        persona.nombre_2,
        persona.apellido_1,
        persona.apellido_2,
        COALESCE(persona.nombre_1,' ')||' '|| COALESCE(persona.nombre_2,' ')||' '|| COALESCE(persona.apellido_1,' ')||' '||COALESCE(persona.apellido_2,' ') AS NOMBRE_COMPLETO,
        persona.fecha_nacimiento,
        trunc(months_between(sysdate,persona.fecha_nacimiento)/12) as EDAD,
        persona.telefono,
        persona.email,
        persona.direccion,
        persona.cod_sexo,
        sexo.des_sexo as DESCRIPCION_LONG_SEXO,
        sexo.DES_ABR as DESCRIPCION_SMALL_SEXO,
        persona.cod_municipio,
        --persona.fecha_creacion,
        persona.cod_estado,
        persona.celular,
        usu.COD_USUARIO,
        usu.CLAVE,
        usu.LOGIN,
        VDIR_FN_GET_ROLES_PERSONA(usu.COD_USUARIO) as ROLESS,
        usu.COD_PLAN AS CODIGO_PLAN,
        VDIR_PACK_INICIO_SESSION.fn_get_keyPagesNot(usu.COD_USUARIO) AS PAGINAS_NO_APLICA,
        usu.CORTE        
    FROM
        vdir_persona persona

        INNER JOIN vdir_usuario usu
         ON usu.cod_persona = persona.cod_persona

        LEFT JOIN VDIR_SEXO sexo
         ON sexo.cod_sexo = persona.cod_sexo

        INNER JOIN  VDIR_TIPO_IDENTIFICACION ti
         ON ti.COD_TIPO_IDENTIFICACION =persona.COD_TIPO_IDENTIFICACION

    WHERE
       TRIM(UPPER(usu.login)) = TRIM(UPPER(p_login))
       AND usu.COD_ESTADO = 1
       AND  usu.clave = p_clave; 

    RETURN vl_cursor;      

    END VDIR_FN_GET_DATOS_USUARIO; 

     ------------------------------------------------------------------------------FUNCION PARA TRAER LOS ROLES QUE TIENE UNA PERSONA 
    FUNCTION VDIR_FN_GET_ROLES_PERSONA(p_cod_user IN vdir_usuario.cod_usuario%TYPE) RETURN VARCHAR2

    IS
    json_datos VARCHAR2(4000);
    BEGIN
      JSON_DATOS := '[ ';
      FOR FILA IN (
                     SELECT 
                        ROL.COD_ROL ,
                        ROL.DES_ROL
                      FROM 
                        VDIR_ROL_USUARIO ROL_USER

                        INNER JOIN VDIR_ROL ROL 
                         ON ROL.COD_ROL = ROL_USER.COD_ROL
                      WHERE 
                        ROL_USER.COD_USUARIO = p_cod_user
                        ) LOOP

      JSON_DATOS := JSON_DATOS ||'{';      
      JSON_DATOS := JSON_DATOS ||'"CODIGO": "'||FILA.COD_ROL||'",';
      JSON_DATOS := JSON_DATOS ||'"NOMBRE": "'||FILA.DES_ROL||'"';
      JSON_DATOS := JSON_DATOS ||'},';

   END LOOP;
    JSON_DATOS := SUBSTR(JSON_DATOS, 1,LENGTH(JSON_DATOS)-1);
    JSON_DATOS := JSON_DATOS || ']'; 

    RETURN json_datos; 

    END VDIR_FN_GET_ROLES_PERSONA;

  ------------------------------------------------ PROCEDIMIENTO PARA INSERTAR EL LOG DE USUARIO
 PROCEDURE  VDIR_SP_INSERT_LOG_USER(p_login IN VDIR_USUARIO.login%TYPE,p_ip IN VARCHAR2,p_navegador IN VARCHAR2)

 IS

 BEGIN 

     INSERT INTO vdir_log_usuarios_sistema (
        cod_log_usuarios_sistema,
        usuario,       
        ip,
        navegador
    ) VALUES (
       VDIR_SEQ_LOG_USUARIOS_SISTEMA.NEXTVAL,
       p_login,
       p_ip,
       p_navegador        
    );

 END VDIR_SP_INSERT_LOG_USER;

 ------------------------------------------------ FUNCION PARA TRAER LAS IMAGENES DE LAS PROMOCIONES DE LOS PRODUCTOS 
 FUNCTION VDIR_FN_GET_DATOS_IMG_PROMO(p_codigo_plan IN vdir_plan.cod_plan%TYPE DEFAULT NULL) 
  RETURN sys_refcursor 
   AS

   vl_cursor sys_refcursor;   

 BEGIN

         OPEN vl_cursor FOR 
	   SELECT ruta AS RUTA_FILE
         FROM VDIR_FILE
		WHERE COD_TIPO_FILE = 5;

    RETURN vl_cursor;   

 END VDIR_FN_GET_DATOS_IMG_PROMO;

 ------------------------------------------------ FUNCION PARA ENVIAR EMAILS 
 FUNCTION VDIR_FN_SEND_EMAIL(p_to IN CLOB,p_asunto IN CLOB, p_mensaje IN CLOB, p_mensaje2 IN CLOB DEFAULT '')  RETURN VARCHAR2

 AS 

 vl_remite VARCHAR2(50);
 vl_puerto NUMBER(3);
 vl_servidor VARCHAR2(50);
 vl_smtp_usuario VARCHAR2(50);
 vl_smtp_clave VARCHAR2(50);
 vl_respuesta_email VARCHAR2(50); 

 BEGIN 

      vl_remite := 'ventaDirecta@coomeva.com.co';
      --vl_asunto := 'Codigo de verificacion'; 
      vl_puerto := 25;
      vl_servidor := 'appcorreo.intracoomeva.com.co';
      vl_smtp_usuario := '';
      vl_smtp_clave := ''; 
    
    SELECT VDIR_PACK_ENVIAR_EMAIL.send_email2(vl_remite,p_to,p_asunto,p_mensaje,vl_puerto,vl_servidor,vl_smtp_usuario,vl_smtp_clave,p_mensaje2) INTO vl_respuesta_email FROM DUAL;

    RETURN vl_respuesta_email;

 END VDIR_FN_SEND_EMAIL;

 /*---------------------------------------------------------------------
  fn_get_keyPagesNot: Traer el key calss de las paginas a las que el usuario no tiene acceso
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 01-03-2019
 ----------------------------------------------------------------------- */
 FUNCTION fn_get_keyPagesNot
 (
    pty_cod_usuario in vdir_usuario.cod_usuario%type
 )RETURN VARCHAR2 IS
    json_datos VARCHAR2(8000);
    key_datos VARCHAR2(4000);
    url_datos VARCHAR2(4000);
 BEGIN
    key_datos := '[ ';
    url_datos := '["#",';
    FOR FILA IN (SELECT 
                        key_pagina,
                        url_pagina
                    FROM
                        vdir_pagina
                    WHERE
                        cod_pagina NOT IN (SELECT
                                                pa.cod_pagina
                                            FROM
                                                vdir_usuario us
                                                INNER JOIN vdir_rol_usuario rul ON rul.cod_usuario = us.cod_usuario
                                                INNER JOIN vdir_pagina_rol par ON par.cod_rol = rul.cod_rol
                                                INNER JOIN vdir_pagina pa ON pa.cod_pagina = par.cod_pagina
                                            WHERE
                                               us.cod_usuario = pty_cod_usuario)) 
    LOOP
        key_datos := key_datos ||'"'||FILA.key_pagina||'",';
        IF FILA.url_pagina <> '#' THEN
            url_datos := url_datos ||'"'||FILA.url_pagina||'",';
        END IF;
    END LOOP;
    key_datos := SUBSTR(key_datos, 1,LENGTH(key_datos)-1);
    url_datos := SUBSTR(url_datos, 1,LENGTH(url_datos)-1);
    key_datos := key_datos || ']';
    url_datos := url_datos || ']';
    json_datos := '{"css":' || key_datos || ', "url":'|| url_datos ||'}'; 

    RETURN json_datos; 

 END fn_get_keyPagesNot;

END VDIR_PACK_INICIO_SESSION;
create or replace PACKAGE BODY           "VDIR_PACK_UTILIDADES" AS

  FUNCTION VDIR_FN_GETCOLECCION_WHERE(p_nom_cod_tabla IN VARCHAR2,p_nom_des_tabla IN VARCHAR2,p_nom_table IN VARCHAR2,p_aux_where IN VARCHAR2,p_fila_order IN VARCHAR2) RETURN sys_refcursor 
  AS
   
    vl_cursor sys_refcursor; 
    vl_cadena VARCHAR2(3000) DEFAULT '';   
    vl_existe_where VARCHAR2(4000);
    vl_fila_order VARCHAR2(50);    

  BEGIN

   IF(p_aux_where IS NOT NULL) THEN    
      vl_existe_where := ' WHERE ' ||p_aux_where;
   ELSE
      vl_existe_where := '';
   END IF; 

   vl_fila_order := 'ORDER BY '||p_fila_order;

   vl_cadena := 'SELECT ' ||p_nom_cod_tabla || ' AS codigo ,' || p_nom_des_tabla || ' AS nombre FROM ' || p_nom_table || vl_existe_where||' '||vl_fila_order;   

      OPEN vl_cursor
       FOR 
         vl_cadena;

  RETURN vl_cursor;

  END VDIR_FN_GETCOLECCION_WHERE;

  -----------------------------------------------------------------------FUNCION PARA TRAER LA DESCRIPCION DE UN PARAMETRO

  FUNCTION VDIR_FN_GET_PARAMETRO(p_codigoParametro IN NUMBER) 
    RETURN VARCHAR2
    AS  

    v_retorno VARCHAR2(4000);

    BEGIN

      BEGIN     
        SELECT 
          VALOR_PARAMETRO  INTO v_retorno
        FROM 
          VDIR_PARAMETRO 
        WHERE
         COD_PARAMETRO = p_codigoParametro;
      EXCEPTION WHEN OTHERS THEN
       v_retorno := '';
      END;       

    RETURN v_retorno;

    END VDIR_FN_GET_PARAMETRO; 

   ----------------------------------------------------------------------------  FUNCION PARA TRAER LOS DAOS DE LA PERSONA,USUAIRO Y ROLES 
   FUNCTION VDIR_FN_GET_DATOS_PERSONA(p_identificacion IN vdir_persona.numero_identificacion%TYPE) 

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
        18 as EDAD,
        --trunc(months_between(sysdate, to_char(persona.fecha_nacimiento,'dd/mm/yyyy'))/12) as EDAD,
        persona.telefono,
        persona.email,
        persona.direccion,
        persona.cod_sexo,
        sexo.des_sexo as DESCRIPCION_LONG_SEXO,
        sexo.DES_ABR as DESCRIPCION_SMALL_SEXO,
        persona.cod_municipio,
        persona.fecha_creacion,
        persona.cod_estado,
        persona.celular,
        usu.COD_USUARIO,
        usu.CLAVE,
        usu.LOGIN,
        VDIR_FN_GET_ROLES_PERSONA(usu.COD_USUARIO) as ROLESS
    FROM
        vdir_persona persona

        INNER JOIN vdir_usuario usu
         ON usu.cod_persona = persona.cod_persona

        LEFT JOIN VDIR_SEXO sexo
         ON sexo.cod_sexo = persona.cod_sexo

        INNER JOIN  VDIR_TIPO_IDENTIFICACION ti
         ON ti.COD_TIPO_IDENTIFICACION =persona.COD_TIPO_IDENTIFICACION

    WHERE
       persona.numero_identificacion = p_identificacion
       AND usu.COD_ESTADO = 1; 

    RETURN vl_cursor;      

    END VDIR_FN_GET_DATOS_PERSONA; 

  ------------------------------------------------------------------------------FUNCION PARA TRAER LOS ROLES QUE TIENE UNA PERSONA 
    FUNCTION VDIR_FN_GET_ROLES_PERSONA(p_cod_user IN vdir_usuario.cod_usuario%TYPE) RETURN VARCHAR2

    IS
    json_datos VARCHAR2(4000);
    BEGIN

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

      JSON_DATOS:= JSON_DATOS ||'{';      
      JSON_DATOS:= JSON_DATOS ||'"CODIGO": "'||FILA.COD_ROL||'",';
      JSON_DATOS:= JSON_DATOS ||'"NOMBRE": "'||FILA.DES_ROL||'"';
      JSON_DATOS:= JSON_DATOS ||'},';

   END LOOP;
    JSON_DATOS:=SUBSTR(JSON_DATOS, 1,LENGTH(JSON_DATOS)-1);
    JSON_DATOS:= JSON_DATOS || ']'; 

    RETURN json_datos; 

    END VDIR_FN_GET_ROLES_PERSONA;


 /*---------------------------------------------------------------------
  fn_splitData: funcion para retornar tabla con los datos de una cadena separados por un caracter
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 02-01-2019
 ----------------------------------------------------------------------- */  
 FUNCTION fn_splitData
 (
    P_STRING_DATA IN VARCHAR2,
    P_SEPARATOR IN VARCHAR2
 )RETURN datasplit_table PIPELINED
 IS
     ltc_datos type_cursor;
     rec datasplit_record;
 BEGIN

    --OPEN ltc_datos FOR
    FOR registro IN  (SELECT level AS IDX, regexp_substr(P_STRING_DATA,'[^'|| P_SEPARATOR ||']+', 1, level) DATO from dual
                    connect by regexp_substr(P_STRING_DATA, '[^'|| P_SEPARATOR ||']+', 1, level) is not null)
    LOOP
        SELECT 
            registro.idx, 
            registro.dato
            INTO rec
        FROM DUAL;

        PIPE ROW(rec);

    END LOOP;

    --RETURN ltc_datos;
    RETURN;

 END fn_splitData;

----------------------------------------------------------------------------  FUNCION PARA TRAER LOS DATOS DE PAGAR EN PAYU 
    FUNCTION VDIR_FN_GET_DATOS_PAGO(p_cod_afiliacion IN vdir_afiliacion.cod_afiliacion%TYPE) 

   RETURN sys_refcursor 
   AS

   vl_cursor sys_refcursor;   

    BEGIN

  OPEN vl_cursor
    FOR 
        SELECT  
            DISTINCT
             factura.cod_factura AS CODIGO_FACTURA,
             factura.total_pagar as AMOUNT,
             factura.SUB_TOTAL as BASE,
             factura.VALOR_IMPUESTO as IVA,
             COALESCE(persona.nombre_1,' ')||' '|| COALESCE(persona.nombre_2,' ')||' '|| COALESCE(persona.apellido_1,' ')||' '||COALESCE(persona.apellido_2,' ') AS NOMBRE_COMPLETO,
             persona.email AS EMAIL,
             persona.NUMERO_IDENTIFICACION AS NUMERO_IDENTIFICACION,
             VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(27) AS MERCHANTID,
             VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(28) AS ACCOUNTID,
             VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(29) AS DESCRIPTION,
             VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(30) AS CURRENCY,
             VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(31) AS TESTT,
             VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(3) AS BASEURL,
             VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(32) AS APIKEY,
             (SELECT SUM(CANTIDAD) FROM VDIR_FACTURA_DETALLE WHERE COD_FACTURA = factura.COD_FACTURA) AS CANTIDAD,
             pr.DES_PROGRAMA_ABR AS PROGRAMA,
             pl.DES_PLAN_ABR AS TIPO_PLAN,
             VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(58) AS URL_EJECUCION      
        FROM
            vdir_factura factura

            INNER JOIN vdir_contratante_beneficiario cb
             ON cb.cod_afiliacion = factura.cod_afiliacion

            INNER JOIN vdir_beneficiario_programa bp
             ON bp.cod_afiliacion = factura.cod_afiliacion

            INNER JOIN vdir_programa pr
             ON pr.cod_programa = bp.cod_programa

            INNER JOIN vdir_persona persona
             ON persona.cod_persona = cb.cod_contratante

            INNER JOIN  vdir_usuario usu
             ON usu.cod_persona = persona.cod_persona

            INNER JOIN vdir_plan pl
             ON pl.cod_plan = usu.cod_plan            

            INNER JOIN VDIR_PERSONA_TIPOPER ptp
             ON ptp.cod_persona = persona.cod_persona     

            WHERE
              ptp.COD_TIPO_PERSONA = 1
              AND factura.cod_afiliacion = p_cod_afiliacion; 

    RETURN vl_cursor;      

    END VDIR_FN_GET_DATOS_PAGO;

 /*---------------------------------------------------------------------
  fn_getMonthSpainish: funcion para obtener el nombre del un mes en español
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 03-04-2019
 ----------------------------------------------------------------------- */  
 FUNCTION fn_getMonthSpainish
 (
    p_num_mes IN INTEGER
 )RETURN VARCHAR2
 IS
     ltc_mes VARCHAR2(10);
     ltc_cadena_meses VARCHAR(200);
 BEGIN
    --Traer cadena de meses separados pod guin medio (-) 
    ltc_cadena_meses := VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(55);
    --Traer nombre del mes en de acuerdo al parametro entero ingresado
    SELECT
        dato INTO ltc_mes
    FROM
        TABLE(VDIR_PACK_UTILIDADES.fn_splitData(ltc_cadena_meses,'-'))
    WHERE
        idx = p_num_mes;    

    RETURN ltc_mes;

 END fn_getMonthSpainish;

  /*---------------------------------------------------------------------
  fn_getFormatMiles: funcion para obtener el formateo a miles de un numero entero o decimal
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 03-04-2019
 ----------------------------------------------------------------------- */  
 FUNCTION fn_getFormatMiles
 (
    p_numero IN INTEGER,
    p_incluir_decimal IN INTEGER,
    p_prefijo IN CHAR
 )RETURN VARCHAR2
 IS
     lnu_format VARCHAR2(300);
     lnu_tipo_format VARCHAR2(300);
 BEGIN

    IF p_incluir_decimal = 1 THEN
        lnu_format := TRIM(TO_CHAR(p_numero, p_prefijo || '999G999G999G999G999D99'));
    ELSE
        lnu_format := TRIM(TO_CHAR(p_numero, p_prefijo || '999G999G999G999G999'));
    END IF;

    RETURN lnu_format;

 END fn_getFormatMiles;
 
 ----------------------------------------------------------------------------------------------------------
         ----------------VDIR_FN_GET_PROGRAMAS
 ---------------------------------------------------------------------------------------------------------------
 
 FUNCTION VDIR_FN_GET_PROGRAMAS(p_cod_afiliacion  vdir_afiliacion.cod_afiliacion%TYPE) RETURN VARCHAR2
 
 IS 
 
  V_CADENA VARCHAR2(10000);
 
 BEGIN
 
   V_CADENA := '';
 
    FOR FILA IN (SELECT   
                    DISTINCT
                    pr.des_programa as PROGRAMA
                 FROM
                    vdir_factura f
                    
                    INNER JOIN vdir_factura_detalle fd
                     ON fd.cod_factura = f.cod_factura
                     
                    INNER JOIN vdir_beneficiario_programa bp
                     ON bp.cod_afiliacion = f.cod_afiliacion                  
                     
                    INNER JOIN  vdir_programa pr
                     ON pr.cod_programa = bp.cod_programa
                     
                 WHERE
                    f.cod_afiliacion = p_cod_afiliacion) LOOP
    
    V_CADENA := V_CADENA||','||FILA.PROGRAMA;
    
    END LOOP;
    
     V_CADENA := SUBSTR(V_CADENA,2,LENGTH(V_CADENA));
  
    RETURN V_CADENA;
 
 END;
 
 ----------------------------------------------------------------------------------------------------------
         ----------------VDIR_FN_GET_DATOS_KIT_BIENV
 ---------------------------------------------------------------------------------------------------------------
 FUNCTION VDIR_FN_GET_DATOS_KIT_BIENV(p_cod_afiliacion  vdir_afiliacion.cod_afiliacion%TYPE) RETURN sys_refcursor
 
 IS
 
 vl_cursor sys_refcursor; 
 
 BEGIN 
  
  OPEN vl_cursor
    FOR
    
        SELECT   
            COALESCE(per.nombre_1,' ')||' '|| COALESCE(per.nombre_2,' ')||' '|| COALESCE(per.apellido_1,' ')||' '||COALESCE(per.apellido_2,' ') AS NOMBRE_COMPLETO,
            per.email as CORREO,
            VDIR_FN_GET_PROGRAMAS(f.cod_afiliacion) as PROGRAMAS,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(59) AS PARAM59,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(60) AS PARAM60,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(61) AS PARAM61,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(62) AS PARAM62,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(63) AS PARAM63,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(64) AS PARAM64,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(65) AS PARAM65,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(66) AS PARAM66,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(67) AS PARAM67,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(68) AS PARAM68,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(69) AS PARAM69,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(70) AS PARAM70,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(71) AS PARAM71,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(72) AS PARAM72,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(73) AS PARAM73,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(74) AS PARAM74,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(75) AS PARAM75,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(88) AS PARAM88,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(89) AS PARAM89,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(202) AS PARAM202,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(203) AS PARAM203,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(204) AS PARAM204,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(205) AS PARAM205,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(206) AS PARAM206,
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(207) AS PARAM207
         FROM
            vdir_factura f
            
            INNER JOIN vdir_factura_detalle fd
             ON fd.cod_factura = f.cod_factura
             
            INNER JOIN vdir_contratante_beneficiario cb
             ON cb.cod_afiliacion = f.cod_afiliacion
            
            INNER JOIN vdir_persona per
             ON per.cod_persona = cb.cod_contratante            
             
         WHERE
            f.cod_afiliacion = p_cod_afiliacion;
    
      
 
  RETURN  vl_cursor;
 
 END VDIR_FN_GET_DATOS_KIT_BIENV;
 
 FUNCTION VDIR_FN_GET_INFO_PAGO(p_cod_afiliacion  vdir_afiliacion.cod_afiliacion%TYPE) 
 
 RETURN sys_refcursor
 
 IS
 
 vl_cursor sys_refcursor; 
 
 BEGIN 
  
  OPEN vl_cursor
    FOR
    
        SELECT               
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(29) AS Descripcion,
            f.COD_RECIBO AS Referencia,
            f.TOTAL_PAGAR AS Valor,            
            VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(30) AS Moneda,
            f.FECHA_PAGO AS Fecha,
            cb.DES_FORMA_PAGO||' '||f.FRANQUICIA_PAGO AS Metodo            
         FROM
            vdir_factura f
            
            INNER JOIN vdir_factura_detalle fd
             ON fd.cod_factura = f.cod_factura
             
             INNER JOIN vdir_forma_pago cb
             ON f.COD_FORMA_PAGO = cb.COD_FORMA_PAGO
                           
         WHERE
            f.cod_afiliacion = p_cod_afiliacion;
    
      
 
  RETURN  vl_cursor;
 
 END VDIR_FN_GET_INFO_PAGO;
 

END VDIR_PACK_UTILIDADES;
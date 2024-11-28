create or replace PACKAGE BODY         VDIR_PACK_REGISTRO_PRODUCTOS AS
/* ---------------------------------------------------------------------
 Copyright  Tecnolog¿a Inform¿tica Coomeva - Colombia
 Package     : VDIR_PACK_REGISTRO_PRODUCTOS BODY
 Caso de Uso : 
 Descripci¿n : Procesos para la ejecucion del requerimiento Registro de productos - VENTA DIRECTA
 --------------------------------------------------------------------
 Autor : diego.castillo@kalettre.com
 Fecha : 10-12-2018  
 --------------------------------------------------------------------
 Procedimiento :     Descripcion:
 --------------------------------------------------------------------
 Historia de Modificaciones
 ---------------------------------------------------------------------
 Fecha Autor Modificaci¿n
 ----------------------------------------------------------------- */
 
 /*---------------------------------------------------------------------
  fn_get_producto: Traer la informacion del producto y sus programas
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 10-12-2018
 ----------------------------------------------------------------------- */
 FUNCTION fn_get_producto
 (
    pty_cod_producto in vdir_producto.cod_producto%type,
	inu_codPlan      IN VDIR_PLAN_PROGRAMA.COD_PLAN%TYPE
 )RETURN type_cursor IS
    ltc_datos type_cursor;
 BEGIN 
 
    OPEN ltc_datos FOR
    SELECT
        vpro.cod_producto,
        COALESCE(vpro.des_producto, ' ') AS des_producto,
        COALESCE(vpro.descripcion, ' ') AS descripcion,
        VDIR_PACK_REGISTRO_PRODUCTOS.fn_get_programaxproducto_str(vpro.cod_producto, inu_codPlan) AS programas
    FROM
        vdir_producto vpro
    WHERE
        vpro.cod_producto = CASE WHEN pty_cod_producto = -1 THEN vpro.cod_producto ELSE pty_cod_producto END
		AND EXISTS (SELECT plpr.cod_programa
					  FROM VDIR_PROGRAMA      prog,
					       VDIR_PLAN_PROGRAMA plpr
					 WHERE prog.cod_programa = plpr.cod_programa 
					   AND prog.cod_producto = vpro.cod_producto
					   AND plpr.cod_estado   = 1
					   AND plpr.cod_plan     = inu_codPlan)
        AND cod_estado = 1
    ORDER BY cod_producto;
       
       
    RETURN ltc_datos;
 
 END fn_get_producto;
 
  /*---------------------------------------------------------------------
  fn_get_programaxproducto_str: Traer los programas de cada producto en un string con estructura de objeto
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 11-12-2018
 ----------------------------------------------------------------------- */
 FUNCTION fn_get_programaxproducto_str
 (
    pty_cod_producto in vdir_producto.cod_producto%type,
	inu_codPlan      IN VDIR_PLAN_PROGRAMA.COD_PLAN%TYPE
 )RETURN VARCHAR2 IS
    ltc_datos type_cursor;
    lv_programas VARCHAR2(4000);
 BEGIN
    lv_programas := '[ ';
    
    FOR fila IN (SELECT prog.cod_programa,
					    prog.des_programa,
					    vfil.ruta,
	                    vfil.url,
						prog.descripcion,
                        plpr.edad_ini,
                        plpr.edad_fin
			 	   FROM vdir_programa prog,
					    vdir_programa_file prfi,
					    vdir_file vfil,
						vdir_plan_programa plpr
				  WHERE prog.cod_programa  = prfi.cod_programa
				    AND prog.cod_programa  = plpr.cod_programa
				    AND prfi.cod_file      = vfil.cod_file
				    AND vfil.cod_tipo_file = 3
					AND plpr.cod_estado    = 1
					AND plpr.cod_plan      = inu_codPlan 
				    AND prog.cod_producto  = CASE WHEN pty_cod_producto = -1 THEN prog.cod_producto ELSE pty_cod_producto END)
    LOOP
        lv_programas := lv_programas || '{"cod_programa":"' || fila.cod_programa || '",';
        lv_programas := lv_programas || '"des_programa":"'  || fila.des_programa || '",';
		lv_programas := lv_programas || '"link_url_firma":"'  || fila.url || '",';
		lv_programas := lv_programas || '"descripcion":"'  || fila.descripcion || '",';
        lv_programas := lv_programas || '"edad_ini":"'  || fila.edad_ini || '",';
        lv_programas := lv_programas || '"edad_fin":"'  || fila.edad_fin || '",';
		lv_programas := lv_programas || '"link_contrato":"' || fila.ruta || '"},';
    END LOOP;
    lv_programas := SUBSTR(lv_programas, 1,LENGTH(lv_programas)-1)  ||']';
       
    RETURN lv_programas;
 
 END fn_get_programaxproducto_str;
 
 /*---------------------------------------------------------------------
  fn_get_promocion_producto: Trae la el valor de la promocion a la que aplica un producto
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 17-12-2018
 ----------------------------------------------------------------------- */
 FUNCTION fn_get_promocion_producto
 (
    pty_cod_producto in vdir_producto.cod_producto%type
 )RETURN NUMBER IS
    lv_valor_promo NUMBER;
 BEGIN
    
    IF pty_cod_producto = 2 THEN
        lv_valor_promo := 2000;
    ELSE
        lv_valor_promo := -1;
    END IF;
    
       
    RETURN lv_valor_promo;
 
 END fn_get_promocion_producto;  
	
	     
 /*---------------------------------------------------------------------
  fn_get_tarifa: Traer tarifa beneficiario por programa
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 20-01-2019
 ----------------------------------------------------------------------- */
 FUNCTION fn_get_tarifa
 (
    pty_cod_beneficiario in vdir_persona.cod_persona%type,
    pty_cod_programa in vdir_programa.cod_programa%type,
    pty_cod_afiliacion in vdir_afiliacion.cod_afiliacion%type
 )RETURN vdir_tarifa.cod_tarifa%type IS
    
    TYPE datos_benefi IS RECORD(
        cod_sexo vdir_sexo.cod_sexo%type,
        edad NUMBER
    );
    
    lv_cod_tarifa vdir_tarifa.cod_tarifa%type;
    lt_benefi datos_benefi;
    lv_cod_plan vdir_plan.cod_plan%type;
    lv_count_user NUMBER;
 BEGIN    
    --Consultar el plan al pertenese el usuario
    BEGIN

        SELECT 
            tf.cod_plan INTO lv_cod_plan
        FROM
            VDIR_BENEFICIARIO_PROGRAMA bp,
            VDIR_TARIFA tf
        WHERE
            bp.cod_beneficiario = pty_cod_beneficiario
            AND bp.cod_afiliacion = pty_cod_afiliacion
            AND bp.cod_programa=pty_cod_programa
            AND tf.cod_tarifa=bp.cod_tarifa;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            lv_cod_plan := -1;    
    END;
    --Consultar sexo y edad del beneficiario
    BEGIN
        SELECT 
            cod_sexo,
            trunc(months_between(sysdate, fecha_nacimiento)/12)
            INTO
            lt_benefi
        FROM
            vdir_persona
        WHERE
            cod_persona = pty_cod_beneficiario;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            lt_benefi.cod_sexo := -1;    
            lt_benefi.edad := -1;
    END;
    --Consultar cuantos beneficiarios estas asociados al programa en la afiliacion
    BEGIN
        SELECT 
            COUNT(*) INTO lv_count_user
        FROM 
            vdir_beneficiario_programa
        WHERE 
            cod_programa = pty_cod_programa
            AND cod_afiliacion = pty_cod_afiliacion
            AND cod_estado in(1,3);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            lv_count_user := 0;  
    END;
    
    --IF lv_count_user >0THEN
    --    lv_count_user := lv_count_user - 1;
    --END IF;
    --Consultar tarifa a la aplica el beneficiario al adquireir el programa
    SELECT
        COALESCE(MAX(tr.cod_tarifa), -1) INTO lv_cod_tarifa
    FROM
        vdir_tarifa tr
        INNER JOIN vdir_plan_programa pp ON pp.cod_plan_programa = tr.cod_plan_programa
    WHERE
        pp.cod_plan = lv_cod_plan
        AND pp.cod_programa = pty_cod_programa
        AND ((cod_sexo = lt_benefi.cod_sexo AND cod_condicion_tarifa = 2)
                OR (cod_sexo IS NULL AND cod_condicion_tarifa = 1))
        AND ((edad_inicial <= lt_benefi.edad AND cod_condicion_tarifa = 2)
                OR (edad_inicial IS NULL AND cod_condicion_tarifa = 1))
        AND ((tr.edad_final >= lt_benefi.edad AND cod_condicion_tarifa = 2)
                OR (tr.edad_final IS NULL AND cod_condicion_tarifa = 1))
        AND ((cod_num_usuarios_tarifa = lv_count_user AND cod_condicion_tarifa = 1)
            OR(lv_count_user >= 5 AND cod_num_usuarios_tarifa = 5 AND cod_condicion_tarifa = 1)
            OR (cod_num_usuarios_tarifa IS NULL AND cod_condicion_tarifa = 2))        
        AND (fecha_vige_inicial <= SYSDATE OR fecha_vige_inicial IS NULL)
        AND (fecha_vige_fin >= SYSDATE OR fecha_vige_fin IS NULL)
        AND tr.cod_estado = 1;
       
    RETURN lv_cod_tarifa;
 
 END fn_get_tarifa;  
    
 /*---------------------------------------------------------------------
  fn_get_valor_tarifa: Traer el valor de la tarifa
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 22-01-2019
 ----------------------------------------------------------------------- */
 FUNCTION fn_get_valor_tarifa
 (
    pty_cod_tarifa in vdir_tarifa.cod_tarifa%type
 )RETURN vdir_tarifa.valor%type IS
    lv_val_tarifa vdir_tarifa.valor%type;
 BEGIN
    
    BEGIN
      SELECT
            valor INTO lv_val_tarifa
        FROM
            vdir_tarifa
        WHERE
            cod_tarifa = pty_cod_tarifa;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            lv_val_tarifa := 0;
    END;
       
    RETURN lv_val_tarifa;
 
 END fn_get_valor_tarifa;      

 /*---------------------------------------------------------------------
  sp_registra_benefi_programa: Agregar beneficiario programa 
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 20-01-2019
 ----------------------------------------------------------------------- */
 PROCEDURE sp_registra_benefi_programa
 (
    p_cod_beneficiario in vdir_persona.cod_persona%type,
    p_cod_programa in vdir_programa.cod_programa%type,
    p_cod_afiliacion in vdir_afiliacion.cod_afiliacion%type,
    p_cod_estado in vdir_estado.cod_estado%type,
    p_cod_tipoSolicitud in vdir_tipo_solicitud.cod_tipo_solicitud%type,
    p_val_tarifa out number,
    p_replica_val_tarifa out number
 ) IS
    lv_cod_tarifa vdir_tarifa.cod_tarifa%type;
    lv_sec_beneficiario_programa integer;
    lv_existe integer;
    
    
 BEGIN
    lv_cod_tarifa := -1;
    
    --Validar si beneficiario ya se encuentra relacionado al programa en la misma afiliacion
    SELECT 
        COUNT(*) INTO lv_existe
    FROM
        vdir_beneficiario_programa
    WHERE
        cod_programa = p_cod_programa
        AND cod_beneficiario = p_cod_beneficiario
        AND cod_afiliacion = p_cod_afiliacion;
       
    IF lv_existe < 1 THEN
        SELECT VDIR_SEQ_BENEFICIARIO_PROGRAMA.NEXTVAL INTO lv_sec_beneficiario_programa FROM DUAL;        
        INSERT INTO vdir_beneficiario_programa(
            cod_beneficiario_programa,
            cod_programa,
            cod_beneficiario,
            cod_tarifa,
            cod_afiliacion,
            cod_estado,
            cod_tipo_solicitud
        ) VALUES (
            lv_sec_beneficiario_programa,
            p_cod_programa,
            p_cod_beneficiario,
            lv_cod_tarifa,
            p_cod_afiliacion,
            p_cod_estado,
            p_cod_tipoSolicitud
        );    
    ELSE
        UPDATE vdir_beneficiario_programa
        SET
            cod_tarifa = lv_cod_tarifa,
            cod_estado = p_cod_estado,
            cod_tipo_solicitud = p_cod_tipoSolicitud
        WHERE
            cod_programa = p_cod_programa
            AND cod_beneficiario = p_cod_beneficiario
            AND cod_afiliacion = p_cod_afiliacion;
    END IF;
    
    --Consultar codigo de tarifa a la que aplica l beneficiario en el programa
    lv_cod_tarifa := VDIR_PACK_REGISTRO_PRODUCTOS.fn_get_tarifa(p_cod_beneficiario, p_cod_programa, p_cod_afiliacion);    
    --Consultar valor de la tarifa y a cuantos usurios se replica este valor
    BEGIN
        SELECT
            valor,
            (CASE WHEN cod_num_usuarios_tarifa IS NULL OR cod_tarifa = -1 THEN 0 ELSE cod_num_usuarios_tarifa END)
            INTO
            p_val_tarifa,
            p_replica_val_tarifa
        FROM
            vdir_tarifa
        WHERE
            cod_tarifa = lv_cod_tarifa;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_val_tarifa := -1;
            p_replica_val_tarifa := 0;
    END;
    
    --Actualizar tarifa a la que aplica el beneficiario por la compra del programa
    UPDATE vdir_beneficiario_programa
        SET
            cod_tarifa = lv_cod_tarifa,
            cod_estado = CASE WHEN lv_cod_tarifa = -1 THEN 2 ELSE cod_estado END --Si tarifa es default(-1), se inactiva el registro pasando el valor 2
    WHERE
        cod_programa = p_cod_programa
        AND cod_beneficiario = p_cod_beneficiario
        AND cod_afiliacion = p_cod_afiliacion;
    
    --Aplicar tarifa cuando esta se realice por nuero de usuarios
    IF p_replica_val_tarifa > 0 THEN
        UPDATE vdir_beneficiario_programa
        SET
            cod_tarifa = lv_cod_tarifa
        WHERE
            cod_programa = p_cod_programa
            AND cod_afiliacion = p_cod_afiliacion;    
    END IF;
     
 END sp_registra_benefi_programa;
 
  /*---------------------------------------------------------------------
  sp_quitar_beneficiario_programa: Quitar registros diferentes a estado 1 en la tabla vdir_beneficiario_programa
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 22-01-2019
 ----------------------------------------------------------------------- */
 PROCEDURE sp_quitar_benefi_programa
 (
    pty_cod_usuario in vdir_usuario.cod_usuario%type
 ) IS
    lv_cod_afiliacion_pendiente vdir_afiliacion.cod_afiliacion%type;
 BEGIN
    lv_cod_afiliacion_pendiente := VDIR_PACK_REGISTRO_DATOS.fn_get_afiliacion_pendiente(pty_cod_usuario);
    
    --Eliminar registros de vdir_factura_detalle donde el cod_beneficiario_programa se encuentre en estado diferente a 1=activo
    DELETE FROM vdir_factura_detalle
    WHERE
        cod_factura_detalle IN (SELECT 
                                        fd.cod_factura_detalle
                                    FROM
                                        vdir_beneficiario_programa bp
                                        INNER JOIN vdir_factura fa ON  fa.cod_afiliacion = bp.cod_afiliacion
                                        INNER JOIN vdir_factura_detalle fd ON fd.cod_factura = fa.cod_factura
                                                                            AND fd.cod_beneficiario_programa = bp.cod_beneficiario_programa
                                    WHERE
                                        bp.cod_afiliacion = lv_cod_afiliacion_pendiente
                                        AND bp.cod_estado <> 1);    
    
    --Eliminar registros de vdir_beneficiario_programa que con estado diferente a 1 (no se encuentran activos)
    DELETE vdir_beneficiario_programa
    WHERE
        cod_afiliacion = lv_cod_afiliacion_pendiente
        AND cod_estado <> 1;
     
 END sp_quitar_benefi_programa;
 
 
  /*---------------------------------------------------------------------
  sp_registra_factura: Registrar factura de compra productos (linea, programa, beneficiario) 
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 21-01-2019
 ----------------------------------------------------------------------- */
 PROCEDURE sp_registra_factura
 (
    pty_cod_usuario in vdir_usuario.cod_usuario%type,
    pty_cod_afiliacion in vdir_afiliacion.cod_afiliacion%type,
    pty_cod_factura out vdir_factura.cod_factura%type
 ) IS
    lv_cod_tarifa vdir_tarifa.cod_tarifa%type;
    lv_sec_factura integer;
    lv_sec_factura_detalle integer;
    lv_existe integer;
    lv_valor_tarifa number;
    lv_aux_valor_total number;
    lnu_iva NUMBER := VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(87);
    lnu_impuesto NUMBER := 0;
    lnu_base NUMBER := 0;
        
 BEGIN
    
    --Consultar valor total de la factura
    SELECT 
        COALESCE(SUM(tr.valor), 0) INTO lv_aux_valor_total
    FROM
        vdir_beneficiario_programa bp
        INNER JOIN vdir_tarifa tr ON tr.cod_tarifa = bp.cod_tarifa
    WHERE
        bp.cod_afiliacion = pty_cod_afiliacion
        AND bp.cod_estado = 1;
        
    BEGIN    
        --Consultar codigo factura
        SELECT 
            cod_factura INTO lv_sec_factura
        FROM
            vdir_factura
        WHERE
            cod_usuario = pty_cod_usuario
            AND cod_afiliacion = pty_cod_afiliacion;
            
        --Eliminar registros de vdir_beneficiario_programa que con estado diferente a 1 (no se encuentran selecionados)
        VDIR_PACK_REGISTRO_PRODUCTOS.sp_quitar_benefi_programa(pty_cod_usuario);
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            lv_sec_factura := 0;
    END;
    
    IF lv_aux_valor_total > 0 THEN

            lnu_base :=  round(lv_aux_valor_total / lnu_iva,0);
            lnu_impuesto := lv_aux_valor_total - lnu_base;
    ELSE  

        lnu_base := 0;
        lnu_impuesto := 0;  
    END IF;    

    IF lv_sec_factura < 1 THEN
    
        --Consultar secuencia factura
        SELECT VDIR_SEQ_FACTURA.NEXTVAL INTO lv_sec_factura FROM DUAL;
          
        --Insertar datos factura
        INSERT INTO vdir_factura(
            cod_factura,
            total_pagar,
            valor_impuesto,
            fecha_creacion,
            sub_total,
            valor_promocion,
            cod_tipo_pago,
            cod_forma_pago,
            cod_estado,
            cod_usuario,
            cod_afiliacion            
        ) VALUES (
            lv_sec_factura,
            lv_aux_valor_total,
            lnu_impuesto,
            SYSDATE,
            lnu_base,
            NULL,
            NULL,
            NULL,
            1,
            pty_cod_usuario,
            pty_cod_afiliacion
        );    
    ELSE            
        --Actualizar datos factura
        
        UPDATE vdir_factura
        SET
            total_pagar = lv_aux_valor_total,
            sub_total = lnu_base,
            valor_impuesto = lnu_impuesto
        WHERE
            cod_factura = lv_sec_factura;
    END IF;

    --Registrar detalle factura
    FOR fila IN (SELECT 
                        COALESCE(tr.valor, 0) AS valor,
                        bp.cod_tarifa,
                        bp.cod_beneficiario_programa
                    FROM
                        vdir_beneficiario_programa bp
                        INNER JOIN vdir_tarifa tr ON tr.cod_tarifa = bp.cod_tarifa
                    WHERE
                        bp.cod_afiliacion = pty_cod_afiliacion
                        AND bp.cod_estado = 1)
    LOOP
        --Validar si existe el registro
        SELECT 
            COUNT(*) INTO lv_existe 
        FROM 
            vdir_factura_detalle 
        WHERE 
            cod_factura = lv_sec_factura 
            AND cod_beneficiario_programa = fila.cod_beneficiario_programa;
        --Consultar valor tarifa
        lv_valor_tarifa := fila.valor; --SELECT valor INTO lv_valor_tarifa FROM vdir_tarifa WHERE cod_tarifa = fila.cod_tarifa;
        IF lv_valor_tarifa > 0 THEN

            lnu_base :=  round((lv_valor_tarifa / lnu_iva),0);
            lnu_impuesto := lv_valor_tarifa - lnu_base;
        ELSE

            lnu_base := 0;
            lnu_impuesto := 0;            
        END IF;
        IF lv_existe < 1 THEN

            --Consultar secuencia factura detalle
            SELECT VDIR_SEQ_FACTURA_DETALLE.NEXTVAL INTO lv_sec_factura_detalle FROM DUAL;
            lnu_base := 0;
            lnu_impuesto := 0;
            
            
            INSERT INTO vdir_factura_detalle(
                cod_factura_detalle,
                valor_total,
                sub_total,
                cantidad,
                valor_impuesto,
                valor_promocion,
                valor_tarifa,
                porcentaje_impuesto,
                cod_beneficiario_programa,
                cod_factura
            )VALUES(
                lv_sec_factura_detalle,
                lv_valor_tarifa,
                lnu_base,
                1,
                lnu_impuesto,
                NULL,
                lv_valor_tarifa,
                NULL,
                fila.cod_beneficiario_programa,
                lv_sec_factura
            );
        ELSE
            UPDATE vdir_factura_detalle
            SET
                valor_total = lv_valor_tarifa,
                sub_total = lnu_base,
                valor_impuesto = lnu_impuesto
            WHERE
                cod_beneficiario_programa = fila.cod_beneficiario_programa
                AND cod_factura = lv_sec_factura;
        END IF;
        
        pty_cod_factura := lv_sec_factura;
    
    END LOOP;
       
     
 END sp_registra_factura;
 
 /*---------------------------------------------------------------------
  fn_get_benficiarios_programas: Traer los beneficiarios que estan registrados a un programa
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 22-01-2019
 ----------------------------------------------------------------------- */
 FUNCTION fn_get_benficiarios_programas
 (
    pty_cod_usuario in vdir_usuario.cod_usuario%type
 )RETURN type_cursor IS
    ltc_datos type_cursor;
    lv_cod_afiliacion_pendiente vdir_afiliacion.cod_afiliacion%type;
 BEGIN
    lv_cod_afiliacion_pendiente := VDIR_PACK_REGISTRO_DATOS.fn_get_afiliacion_pendiente(pty_cod_usuario);
    
    BEGIN
        OPEN ltc_datos FOR
        SELECT 
                bp.cod_programa,
                bp.cod_beneficiario,
                bp.cod_afiliacion,
                bp.cod_tarifa,
                tr.valor AS val_tarifa,
                pm.cod_producto,
                pe.cod_tipo_identificacion,
                pe.numero_identificacion,
                bp.cod_tipo_solicitud,
                (SELECT cod_encuesta FROM vdir_encuesta_persona WHERE cod_persona = bp.cod_beneficiario AND rownum = 1) status_encuesta
            FROM
                vdir_beneficiario_programa bp
                INNER JOIN vdir_programa pm ON pm.cod_programa = bp.cod_programa
                INNER JOIN vdir_persona pe ON pe.cod_persona = bp.cod_beneficiario
                INNER JOIN vdir_tarifa tr ON tr.cod_tarifa = bp.cod_tarifa
            WHERE
                cod_afiliacion = lv_cod_afiliacion_pendiente
                AND bp.cod_estado = 1;
            
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            OPEN ltc_datos FOR
            SELECT -1 AS cod_beneficiario_programa FROM DUAL;
    END;       

    RETURN ltc_datos;

 END fn_get_benficiarios_programas;
 
 /*---------------------------------------------------------------------
  fn_get_codPrograma_homologa: Traer el codigo de hologacion del programa plan
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 14-02-2019
 ----------------------------------------------------------------------- */
 FUNCTION fn_get_codPrograma_homologa
 (
    pty_cod_programa in vdir_programa.cod_programa%type,
    pty_cod_plan in vdir_plan.cod_plan%type
 )RETURN vdir_plan_programa.cod_programa_homologa%type IS
    lv_codPrograma_homologa vdir_plan_programa.cod_programa_homologa%type;
 BEGIN
 
    BEGIN
        SELECT
            cod_programa_homologa INTO lv_codPrograma_homologa
        FROM
            vdir_plan_programa
        WHERE
            cod_programa = pty_cod_programa
            AND cod_plan = pty_cod_plan;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            lv_codPrograma_homologa := '-1';
    END;
       
    RETURN lv_codPrograma_homologa;
 
 END fn_get_codPrograma_homologa;
 
  /*---------------------------------------------------------------------
  sp_set_estado_benefi_program: Actualizar estado alos pregamas agragados a un beneficiario temporalmente de una afiliacion pendiente
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 18-02-2019
 ----------------------------------------------------------------------- */
 PROCEDURE sp_set_estado_benefi_program
 (
    pty_cod_usuario in vdir_usuario.cod_usuario%type,
    pty_cod_estado in vdir_estado.cod_estado%type
 ) IS
    ltc_datos type_cursor;
    lv_cod_afiliacion vdir_afiliacion.cod_afiliacion%type;
 BEGIN
    lv_cod_afiliacion := VDIR_PACK_REGISTRO_DATOS.fn_get_afiliacion_pendiente(pty_cod_usuario);
 
    UPDATE vdir_beneficiario_programa
    SET
        cod_estado = pty_cod_estado
    WHERE
        cod_afiliacion = lv_cod_afiliacion
        AND cod_estado = 3;    
    
 END sp_set_estado_benefi_program;
 
END VDIR_PACK_REGISTRO_PRODUCTOS;
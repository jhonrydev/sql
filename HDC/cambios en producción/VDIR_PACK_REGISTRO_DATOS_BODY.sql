create or replace PACKAGE BODY         VDIR_PACK_REGISTRO_DATOS AS
/* ---------------------------------------------------------------------
 Copyright  Tecnología Informática Coomeva - Colombia
 Package     : VDIR_PACK_REGISTRO_DATOS BODY
 Caso de Uso : 
 Descripción : Procesos para la ejecucion del requerimiento Registro datos basicos
 --------------------------------------------------------------------
 Autor : diego.castillo@kalettre.com
 Fecha : 03-12-2018  
 --------------------------------------------------------------------
 Procedimiento :     Descripcion:
 --------------------------------------------------------------------
 Historia de Modificaciones
 ---------------------------------------------------------------------
 Fecha Autor Modificación
 ----------------------------------------------------------------- */

 /*---------------------------------------------------------------------
  fn_get_contratante: Traer la informacion del usuario contratante
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 03-12-2018
 ----------------------------------------------------------------------- */
 FUNCTION fn_get_contratante
 (
    pty_cod_usuario in vdir_usuario.cod_usuario%type
 )RETURN type_cursor IS
    ltc_datos type_cursor;
 BEGIN 

    OPEN ltc_datos FOR
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
        to_char(persona.fecha_nacimiento,'dd/mm/yyyy') AS fecha_nacimiento,
        trunc(months_between(sysdate, to_date(to_char(persona.fecha_nacimiento,'dd/mm/yyyy'),'dd/mm/yyyy'))/12) as EDAD,
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
        dp.cod_pais,
        persona.dir_tipo_via,
        persona.dir_num_via,
        persona.dir_num_placa,
        persona.dir_complemento,
        persona.cod_estado_civil,
        persona.cod_eps,
        persona.cod_asesor,
        persona.cedula_referido,
        persona.tipo_identificacion_referido,
        persona.ind_tiene_mascota,
        VDIR_PACK_REGISTRO_DATOS.fn_get_afiliacion_pendiente(pty_cod_usuario) AS cod_afiliacion,
		(SELECT pai.des_pais
		   FROM VDIR_PAIS pai
		WHERE pai.cod_pais = dp.cod_pais) nacionalidad,
		mu.des_municipio,
		(SELECT esc.des_estado_civil
		   FROM VDIR_ESTADO_CIVIL esc
		  WHERE esc.cod_estado_civil = persona.cod_estado_civil) des_estado_civil,
		(SELECT eps.des_eps
	 	   FROM VDIR_EPS eps
		  WHERE eps.cod_eps = persona.cod_eps) des_eps,
		usu.cod_plan
    FROM
        vdir_persona persona
        INNER JOIN vdir_usuario usu
            ON usu.cod_persona = persona.cod_persona        
        INNER JOIN VDIR_SEXO sexo
            ON sexo.cod_sexo = persona.cod_sexo        
        INNER JOIN VDIR_TIPO_IDENTIFICACION ti
            ON ti.COD_TIPO_IDENTIFICACION = persona.COD_TIPO_IDENTIFICACION         
        LEFT JOIN vdir_municipio mu
            ON mu.cod_municipio = persona.cod_municipio
        LEFT JOIN vdir_departamento dp
            ON dp.cod_departamento = mu.cod_departamento

    WHERE
       usu.cod_usuario = pty_cod_usuario;


    RETURN ltc_datos;

 END fn_get_contratante; 

 /*---------------------------------------------------------------------
  fn_get_info_persona: Taer iformacion de la persona con el numero de y tipo de identificacion
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 03-12-2018
 ----------------------------------------------------------------------- */
 FUNCTION fn_get_info_persona
 (
    pty_num_indentificacion in vdir_persona.numero_identificacion%type,
    pty_tip_indentificacion in vdir_persona.cod_tipo_identificacion%type
 )RETURN type_cursor IS
    ltc_datos type_cursor;
 BEGIN 

    OPEN ltc_datos FOR
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
        to_char(persona.fecha_nacimiento,'dd/mm/yyyy') AS fecha_nacimiento,
        trunc(months_between(sysdate, to_date(to_char(persona.fecha_nacimiento,'dd/mm/yyyy'),'dd/mm/yyyy'))/12) as EDAD,
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
        dp.cod_pais,
        persona.dir_tipo_via,
        persona.dir_num_via,
        persona.dir_num_placa,
        persona.dir_complemento,
        persona.cod_estado_civil,
        persona.cod_eps,
        persona.ind_tiene_mascota,
        usu.cod_plan
    FROM
        vdir_persona persona
        LEFT JOIN vdir_usuario usu ON usu.cod_persona = persona.cod_persona
        INNER JOIN VDIR_SEXO sexo ON sexo.cod_sexo = persona.cod_sexo
        INNER JOIN  VDIR_TIPO_IDENTIFICACION ti ON ti.COD_TIPO_IDENTIFICACION = persona.COD_TIPO_IDENTIFICACION
        LEFT JOIN vdir_municipio mu ON mu.cod_municipio = persona.cod_municipio
        LEFT JOIN vdir_departamento dp ON dp.cod_departamento = mu.cod_departamento
    WHERE
       persona.numero_identificacion = pty_num_indentificacion
       AND persona.cod_tipo_identificacion = pty_tip_indentificacion;


    RETURN ltc_datos;

 END fn_get_info_persona;

 /*---------------------------------------------------------------------
  sp_set_beneficiario: Agregar beneficiario
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 26-12-2018
 ----------------------------------------------------------------------- */
 PROCEDURE sp_set_beneficiario
 (
    p_cod_contratante in vdir_persona.cod_persona%type,
    p_cod_tipo_doc in vdir_persona.cod_tipo_identificacion%type,
    p_num_doc in vdir_persona.numero_identificacion%type,
    p_nombre_1 in vdir_persona.nombre_1%type,
    p_nombre_2 in vdir_persona.nombre_2%type,
    p_apellido_1 in vdir_persona.apellido_1%type,
    p_apellido_2 in vdir_persona.apellido_2%type,
    p_fecha_nacimiento in vdir_persona.fecha_nacimiento%type,
    p_telefono in vdir_persona.telefono%type,
    p_email in vdir_persona.email%type,
    p_cod_sexo in vdir_persona.cod_sexo%type,
    p_cod_municipio in vdir_persona.cod_municipio%type,
    p_celular in vdir_persona.celular%type,
    p_eps in vdir_persona.cod_eps%type,
    p_estado_civil in vdir_persona.cod_estado_civil%type,
    p_ind_tiene_mascota in vdir_persona.ind_tiene_mascota%type,
    p_tipo_via_dir in vdir_tipo_via.cod_tipo_via%type,
    p_num_tipo_via_dir in varchar2,
    p_num_placa_dir in varchar2,
    p_complemento_dir in varchar2,
    p_parentesco in vdir_parentesco.cod_parentesco%type,
    p_estado in vdir_persona.cod_estado%type,
    p_cod_afiliacion in vdir_afiliacion.cod_afiliacion%type,
    p_cod_direccion in vdir_persona.cod_direccion%type,
    p_cod_asesor in vdir_persona.cod_asesor%type,
    p_ced_referido in vdir_persona.cedula_referido%type,
    p_tipo_ced_referido in vdir_persona.tipo_identificacion_referido%type,
    p_cod_afiliacion_out out vdir_afiliacion.cod_afiliacion%type
 ) IS
    lv_des_tipo_via varchar(4000);
    lv_existe_registro integer;
    lv_direccion vdir_persona.direccion%type;
    lv_cod_beneficiario vdir_persona.cod_persona%type;
    lv_cod_afiliacion vdir_afiliacion.cod_afiliacion%type;
    lv_cod_usuario vdir_usuario.cod_usuario%type;
    lv_cod_persona_tipoper vdir_persona_tipoper.cod_persona_tipoper%type;
 BEGIN
    lv_existe_registro := 0;
    --Consultar descripcion del tipo via
    SELECT des_tipo_via INTO lv_des_tipo_via FROM vdir_tipo_via WHERE cod_tipo_via = p_tipo_via_dir;
    --Consultar codigo usuario del contratante
    SELECT cod_usuario INTO lv_cod_usuario FROM vdir_usuario WHERE cod_persona = p_cod_contratante;

    lv_direccion := lv_des_tipo_via||' '||p_num_tipo_via_dir||' # '||p_num_placa_dir||' '||p_complemento_dir;
    lv_cod_afiliacion :=  VDIR_PACK_REGISTRO_DATOS.fn_get_afiliacion_pendiente(lv_cod_usuario);

    --Agregar afiliacion si no existe una pendiente
    IF lv_cod_afiliacion < 0 THEN
        SELECT VDIR_SEQ_AFILIACION.NEXTVAL INTO lv_cod_afiliacion FROM DUAL;
        INSERT INTO vdir_afiliacion (
                            cod_afiliacion,
                            fecha_creacion,
                            cod_estado
                        ) VALUES (
                            lv_cod_afiliacion,
                            SYSDATE,
                            3 --Temporal
                        );
    END IF;   


    --Validar si esxite la persona
    SELECT 
        COUNT(*) INTO lv_existe_registro 
    FROM 
        vdir_persona 
    WHERE 
        cod_tipo_identificacion = p_cod_tipo_doc 
        AND numero_identificacion = p_num_doc;

    IF lv_existe_registro > 0 THEN
        --Obtener codigo de persona
        SELECT 
            cod_persona INTO lv_cod_beneficiario 
        FROM 
            vdir_persona 
        WHERE 
            cod_tipo_identificacion = p_cod_tipo_doc 
            AND numero_identificacion = p_num_doc;
        --Actualizar persona    
        UPDATE vdir_persona
        SET
            nombre_1 = p_nombre_1,
            nombre_2 = p_nombre_2,
            apellido_1 = p_apellido_1,
            apellido_2 = p_apellido_2,
            fecha_nacimiento = p_fecha_nacimiento,
            telefono = p_telefono,
            email = p_email,
            direccion = lv_direccion,
            cod_sexo = p_cod_sexo,
            cod_municipio = p_cod_municipio,
            celular = p_celular,
            cod_eps = p_eps,
            cod_estado_civil = p_estado_civil,
            ind_tiene_mascota = p_ind_tiene_mascota,
            cod_estado = p_estado,
            dir_tipo_via = p_tipo_via_dir,
            dir_num_via = p_num_tipo_via_dir,
            dir_num_placa = p_num_placa_dir,
            dir_complemento = p_complemento_dir,
            cod_direccion = p_cod_direccion
        WHERE
            cod_persona = lv_cod_beneficiario;

        IF p_cod_asesor is not null THEN
            UPDATE vdir_persona
            SET
                cod_asesor = p_cod_asesor
            WHERE
                cod_persona = lv_cod_beneficiario;
        END IF;

        IF p_ced_referido is not null THEN
            UPDATE vdir_persona
            SET
                cedula_referido = p_ced_referido,
                tipo_identificacion_referido=p_tipo_ced_referido
            WHERE
                cod_persona = lv_cod_beneficiario;
        END IF;

    ELSE
        --Obtener secuencia persona
        SELECT VDIR_SEQ_PERSONA.NEXTVAL INTO lv_cod_beneficiario FROM DUAL;
        --Agregar persona 
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
                email,
                direccion,
                cod_sexo,
                cod_municipio,
                fecha_creacion,
                cod_estado,
                celular,
                cod_eps,
                cod_estado_civil,
                ind_tiene_mascota,
                dir_tipo_via,
                dir_num_via,
                dir_num_placa,
                dir_complemento,
                cod_direccion
            ) VALUES (
                lv_cod_beneficiario,
                p_cod_tipo_doc,
                p_num_doc,
                p_nombre_1,
                p_nombre_2,
                p_apellido_1,
                p_apellido_2,
                p_fecha_nacimiento,
                p_telefono,
                p_email,
                lv_direccion,
                p_cod_sexo,
                p_cod_municipio,
                SYSDATE,
                p_estado,
                p_celular,
                p_eps,
                p_estado_civil,
                p_ind_tiene_mascota,
                p_tipo_via_dir,
                p_num_tipo_via_dir,
                p_num_placa_dir,
                p_complemento_dir,
                p_cod_direccion
            );

            --Insertar tipo de persona            
            SELECT VDIR_SEQ_PERSONA_TIPOPER.NEXTVAL INTO lv_cod_persona_tipoper FROM DUAL;
            insert into vdir_persona_tipoper(
                cod_persona_tipoper,
                cod_persona,
                cod_tipo_persona
            ) VALUES (
                lv_cod_persona_tipoper,
                lv_cod_beneficiario,
                2
            );
    END IF;

    --Validar si existe la relacion entre el beneficiario y el contratante
    SELECT
        COUNT(*) INTO lv_existe_registro
    FROM
        vdir_contratante_beneficiario
    WHERE
        cod_contratante = p_cod_contratante
        AND cod_beneficiario = lv_cod_beneficiario
        AND cod_afiliacion = lv_cod_afiliacion;

    --Agregar o actualizar la relacion entre el beneficiario y el contratante
    IF lv_existe_registro > 0 THEN
        UPDATE vdir_contratante_beneficiario
        SET
            cod_parentesco = p_parentesco,
            cod_estado = 1
        WHERE
            cod_contratante = p_cod_contratante
            AND cod_beneficiario = lv_cod_beneficiario
            AND cod_afiliacion = lv_cod_afiliacion;
    ELSE
        INSERT INTO vdir_contratante_beneficiario (
                cod_contratante_beneficiario,
                cod_contratante,
                cod_beneficiario,
                cod_parentesco,
                cod_afiliacion,
                cod_tipo_solicitud,
                cod_estado
            ) VALUES (
                VDIR_SEQ_CONTRATANTE_BENEFI.NEXTVAL,
                p_cod_contratante,
                lv_cod_beneficiario,
                p_parentesco,
                lv_cod_afiliacion,
                null,
                1
            );
    END IF;

     p_cod_afiliacion_out := lv_cod_afiliacion;

	 EXCEPTION 
     WHEN OTHERS THEN
     p_cod_afiliacion_out := -1;

 END sp_set_beneficiario;

  /*---------------------------------------------------------------------
  fn_get_afiliacion_pendiente: Trae afiliacion pendiente
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 27-12-2018
 ----------------------------------------------------------------------- */
 FUNCTION fn_get_afiliacion_pendiente
 (
    pty_cod_usuario in vdir_usuario.cod_usuario%type
 )RETURN vdir_afiliacion.cod_afiliacion%type IS
    lv_cod_afiliacion vdir_afiliacion.cod_afiliacion%type;
 BEGIN

    BEGIN
      SELECT DISTINCT
          va.cod_afiliacion INTO lv_cod_afiliacion
      FROM
          vdir_usuario us
          INNER JOIN vdir_contratante_beneficiario cb ON cb.cod_contratante = us.cod_persona
          INNER JOIN vdir_afiliacion va ON va.cod_afiliacion = cb.cod_afiliacion          
      WHERE
          us.cod_usuario = pty_cod_usuario
          AND (va.cod_estado = 3 OR va.cod_estado = 8);
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
      lv_cod_afiliacion := -1;
    END;

    RETURN lv_cod_afiliacion;

 END fn_get_afiliacion_pendiente;

 /*---------------------------------------------------------------------
  fn_get_benficiarios_contra: Traer los beneficiarios que esta registrando un contratante
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 31-12-2018
 -----------------------------------------------------------------------
  modificacion : intelecto
  Fecha : 31-08-2020
  decripcion: se eliminó ROWNUM = 1
 ----------------------------------------------------------------------- */
 FUNCTION fn_get_benficiarios_contra
 (
    pty_cod_usuario in vdir_usuario.cod_usuario%type
 )RETURN type_cursor IS
    ltc_datos type_cursor;
 BEGIN 
     BEGIN
        OPEN ltc_datos FOR
        SELECT
            va.cod_afiliacion AS "cod_afiliacion",
            pr.cod_persona AS "cod_persona",
            pr.cod_tipo_identificacion AS "tipoDocumento",
            pr.numero_identificacion AS "numeroDocumento",
            pr.nombre_1 AS "nombre1",
            pr.nombre_2 AS "nombre2",
            pr.apellido_1 AS "apellido1",
            pr.apellido_2 AS "apellido2",
            TO_CHAR(pr.fecha_nacimiento, 'DD/MM/YYYY') AS "fechaNacimiento",
            pr.cod_sexo AS "tipoSexo",
            pr.telefono AS "telefono",
            pr.celular AS "celular",
            pr.email AS "correo",
            dp.cod_pais AS "pais",
            pr.cod_municipio AS "municipio",
            pr.direccion AS "direccion",
            pr.cod_estado_civil AS "estado_civil",
            pr.cod_eps AS "eps",
            pr.ind_tiene_mascota AS "mascota",
            pr.dir_tipo_via AS "tipoVia",
            pr.dir_num_via AS "numeroTipoVia",
            pr.dir_num_placa AS "numeroPlaca",
            pr.dir_complemento AS "complemento",
            ti.des_abr AS "tipoDocumento_abr",
            tv.abr_tipo_via AS "tipoVia_abr",
            --COALESCE(tv.abr_tipo_via, ' ')||' '||COALESCE(pr.dir_num_via, ' ')||' # '||COALESCE(pr.dir_num_placa, ' ')||' '||COALESCE(pr.dir_complemento, ' ')  AS "direccion",
            COALESCE(pr.nombre_1, ' ') || ' ' || COALESCE(pr.nombre_2, ' ') || ' ' || COALESCE(pr.apellido_1, ' ') || ' ' || COALESCE(pr.apellido_2, ' ') AS "nombre_completo",
            cb.cod_parentesco AS "parentesco",
            0 AS "tarifa",
            trunc(months_between(sysdate, to_date(to_char(pr.fecha_nacimiento,'dd/mm/yyyy'),'dd/mm/yyyy'))/12) AS "edad",
			des_parentesco AS "des_parentesco",
			VDIR_PACK_REGISTRO_DATOS.fnGetProgramasBeneficiario(pr.cod_persona, va.cod_afiliacion) "benefiProgramas",
			(SELECT SUM(tari.valor)
			   FROM VDIR_BENEFICIARIO_PROGRAMA bepo,
				    VDIR_TARIFA tari
		 	  WHERE bepo.cod_tarifa = tari.cod_tarifa
				AND bepo.cod_beneficiario = pr.cod_persona
				AND bepo.cod_estado = 1
                AND bepo.cod_afiliacion = va.cod_afiliacion) "tarifaBeneficiario",
            (SELECT max(tari.fecha_vige_inicial)
			   FROM VDIR_BENEFICIARIO_PROGRAMA bepo,
				    VDIR_TARIFA tari
		 	  WHERE bepo.cod_tarifa = tari.cod_tarifa
				AND bepo.cod_beneficiario = pr.cod_persona
				AND bepo.cod_estado = 1
                AND bepo.cod_afiliacion = va.cod_afiliacion) "fechaVigencia"
        FROM
            vdir_usuario us
            INNER JOIN vdir_contratante_beneficiario cb ON cb.cod_contratante = us.cod_persona
            INNER JOIN vdir_afiliacion va ON va.cod_afiliacion = cb.cod_afiliacion
            INNER JOIN vdir_persona pr ON pr.cod_persona = cb.cod_beneficiario
            INNER JOIN vdir_tipo_identificacion ti ON ti.cod_tipo_identificacion = pr.cod_tipo_identificacion
			INNER JOIN vdir_parentesco pare ON pare.cod_parentesco = cb.cod_parentesco
		    LEFT JOIN vdir_municipio mu ON mu.cod_municipio = pr.cod_municipio
            LEFT JOIN vdir_departamento dp ON dp.cod_departamento = mu.cod_departamento
            LEFT JOIN vdir_tipo_via tv ON pr.dir_tipo_via = tv.cod_tipo_via
          WHERE
              us.cod_usuario = pty_cod_usuario
              AND va.cod_estado IN (3,8)
            ORDER BY pr.cod_persona ASC;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            OPEN ltc_datos FOR
            SELECT -1 AS cod_afiliacion FROM DUAL;
    END;       

    RETURN ltc_datos;

 END fn_get_benficiarios_contra;

 /*---------------------------------------------------------------------
  sp_quitar_contra_benefi: Quitar la relacion entre el contratante y los beneficiarios de una afiliacion pendiente
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 03-01-2019
 ----------------------------------------------------------------------- */
 PROCEDURE sp_quitar_contra_benefi
 (
    pty_cod_usuario in vdir_usuario.cod_usuario%type,
    pnu_result out numeric
 ) IS
    ltc_datos type_cursor;
    lv_cod_afiliacion vdir_afiliacion.cod_afiliacion%type;
 BEGIN
    lv_cod_afiliacion := VDIR_PACK_REGISTRO_DATOS.fn_get_afiliacion_pendiente(pty_cod_usuario);
    BEGIN
        pnu_result := 1;
        --Inactivar registros de beneficiario a quitar en vdir_beneficiario_programa
        /*
        UPDATE vdir_beneficiario_programa
        SET 
            cod_estado = 2
        WHERE
            cod_afiliacion = lv_cod_afiliacion
            AND cod_beneficiario IN (SELECT
                                            cb.cod_beneficiario 
                                        FROM
                                            vdir_contratante_beneficiario cb
                                        WHERE
                                            cb.cod_afiliacion = lv_cod_afiliacion
                                            AND cb.cod_estado = 2);

        --Quitar registros inactivos de vdir_contratante_beneficiario
        DELETE FROM 
            vdir_contratante_beneficiario
        WHERE
            cod_afiliacion = lv_cod_afiliacion
            AND cod_estado = 2;

        --Quitar registros inactivos de vdir_beneficiario_programa
        VDIR_PACK_REGISTRO_PRODUCTOS.sp_quitar_benefi_programa(pty_cod_usuario);
        */
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
        pnu_result := 0;
    END;

 END sp_quitar_contra_benefi;

 /*---------------------------------------------------------------------
  sp_set_estado_contra_benefi: Asgnar estado a la relacion entre el contratante y los beneficiarios de una afiliacion pendiente
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 23-01-2019
 ----------------------------------------------------------------------- */
 PROCEDURE sp_set_estado_contra_benefi
 (
    pty_cod_usuario in vdir_usuario.cod_usuario%type,
    pty_cod_estado in vdir_estado.cod_estado%type
 ) IS
    ltc_datos type_cursor;
    lv_cod_afiliacion vdir_afiliacion.cod_afiliacion%type;
 BEGIN
    lv_cod_afiliacion := VDIR_PACK_REGISTRO_DATOS.fn_get_afiliacion_pendiente(pty_cod_usuario);

    UPDATE vdir_contratante_beneficiario
    SET
        cod_estado = pty_cod_estado
    WHERE
        cod_afiliacion = lv_cod_afiliacion;    

 END sp_set_estado_contra_benefi;

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

    -- ---------------------------------------------------------------------
    -- fnGetProgramasBeneficiario
    -- --------------------------------------------------------------------- 
	FUNCTION fnGetProgramasBeneficiario
	(
		inu_codBeneficiario  IN VDIR_BENEFICIARIO_PROGRAMA.COD_BENEFICIARIO%TYPE,
        inu_codAfiliacion    IN VDIR_AFILIACION.COD_AFILIACION%TYPE
	)
	RETURN VARCHAR2 IS

    /* ---------------------------------------------------------------------
	 Copyright   : Tecnología Informática Coomeva - Colombia
	 Package     : VDIR_PACK_REGISTRO_PRODUCTOS
	 Caso de Uso : 
	 Descripción : Retorna una cadena con los datos de los programas por 
	               beneficiario
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 21-01-2019  
	 ----------------------------------------------------------------------
	 Parámetros :         Descripción:
	 inu_codBeneficiario   Código del beneficiario
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor Modificación
	 ----------------------------------------------------------------- */

		lvc_codProgramas VARCHAR2(4000);

	BEGIN

		lvc_codProgramas := '';

		FOR fila IN (SELECT bepo.cod_programa
					   FROM VDIR_BENEFICIARIO_PROGRAMA bepo
		              WHERE bepo.cod_beneficiario = inu_codBeneficiario
                        AND bepo.cod_afiliacion = inu_codAfiliacion
					    AND bepo.cod_estado = 1)
		LOOP

			lvc_codProgramas := lvc_codProgramas || fila.cod_programa || ',';

		END LOOP;

		RETURN lvc_codProgramas;

	END fnGetProgramasBeneficiario;

 /*---------------------------------------------------------------------
  fn_get_habeasData: Traer el texto habeas datada para la compra de productos
  ----------------------------------------------------------------------
  Autor : diego.castillo@kalettre.com
  Fecha : 18-02-2019
 ----------------------------------------------------------------------- */
 FUNCTION fn_get_habeasData
 (
    p_tipo IN VARCHAR2
 )
 RETURN VARCHAR2 IS
    lv_texto_habeasData VARCHAR2(32767);
 BEGIN

    BEGIN
        lv_texto_habeasData := '';
        IF p_tipo <> 'CEM' THEN
            lv_texto_habeasData := lv_texto_habeasData || VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(49);
            lv_texto_habeasData := lv_texto_habeasData || '<br>';
            lv_texto_habeasData := lv_texto_habeasData || VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(50);
        ELSE
            lv_texto_habeasData := lv_texto_habeasData || VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(51);
            lv_texto_habeasData := lv_texto_habeasData || '<br>';
            lv_texto_habeasData := lv_texto_habeasData || VDIR_PACK_UTILIDADES.VDIR_FN_GET_PARAMETRO(52);            
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            lv_texto_habeasData := 'NO DATA';
    END;

    RETURN lv_texto_habeasData;

 END fn_get_habeasData;

END VDIR_PACK_REGISTRO_DATOS;
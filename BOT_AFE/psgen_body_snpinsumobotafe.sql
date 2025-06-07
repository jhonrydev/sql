create or replace package body psgen_snpinsumobotafe is

   procedure ajustacuotamesafe (
      prm_solicitud_afe in varchar2,
      prm_cuota         in number,
      prm_usuario       in varchar2,
      coderror          out number,
      msgerror          out varchar2,
      registros         out sys_refcursor
   ) as





      cursor cu_permiso_usuario (
         lnu_tipo_cambio number
      ) is
      select count(1)
        from gen_permiso_usuario
       where usuario = prm_usuario
         and cod_tipo_cambio = lnu_tipo_cambio;

      cursor cu_solici is
      select id,
             primera_cuota
        from api_afemp_step8
       where id = prm_solicitud_afe;

      lnu_permiso  number(1);
      rc_solic     cu_solici%rowtype;
      lvc_estados  varchar2(100);
      lnu_existest number(1);
   begin
      coderror := 0;
      if ( prm_solicitud_afe is null
      or prm_solicitud_afe = '' ) then
         msgerror := msgerror
                     || ' El campo prm_cuota no puede estar vacio'
                     || chr(13);
         coderror := 1;
      end if;

      if ( prm_cuota is null
      or prm_cuota = '' ) then
         msgerror := msgerror
                     || ' El campo prm_cuota no puede estar vacio'
                     || chr(13);
         coderror := 1;
      end if;


      lnu_permiso := null;
      open cu_permiso_usuario(10);
      fetch cu_permiso_usuario into lnu_permiso;
      close cu_permiso_usuario;
      if ( lnu_permiso = 0 ) then
         msgerror := msgerror
                     || 'Usuario sin permisos'
                     || chr(13);
         coderror := 1;
      end if;

      if ( coderror = 0 ) then
         rc_solic.id := null;
         open cu_solici;
         fetch cu_solici into rc_solic;
         close cu_solici;
         if ( rc_solic.id is null ) then
            msgerror := msgerror
                        || 'Solicitud AFE no existe'
                        || chr(13);
            coderror := 1;
         else
            update api_afemp_step8
               set
               primera_cuota = prm_cuota
             where id = rc_solic.id;

            insert into gen_bitacora_cambio values ( seq_gen_bitacora_cambio.nextval,
                                                     prm_solicitud_afe,
                                                     10,
                                                     rc_solic.primera_cuota, --valor_anterior,
                                                     prm_cuota,      --valor_nuevo,  
                                                     sysdate,
                                                     prm_usuario );

            msgerror := msgerror
                        || ' CUOTA_MES='
                        || rc_solic.primera_cuota
                        || '/'
                        || prm_cuota;



         end if;

      end if;
      commit;
   end ajustacuotamesafe;

   procedure ajustatarifarioafe (
      prm_solicitud_afe in varchar2,
      prm_tarifario     in varchar2,
      prm_usuario       in varchar2,
      coderror          out number,
      msgerror          out varchar2,
      registros         out sys_refcursor
   ) as





      cursor cu_permiso_usuario (
         lnu_tipo_cambio number
      ) is
      select count(1)
        from gen_permiso_usuario
       where usuario = prm_usuario
         and cod_tipo_cambio = lnu_tipo_cambio;

      cursor cu_solici is
      select id,
             codigo_tarifa
        from api_afemp_step6
       where id = prm_solicitud_afe;

      lnu_permiso  number(1);
      rc_solic     cu_solici%rowtype;
      lvc_estados  varchar2(100);
      lnu_existest number(1);
      lnu_estado   number(5);
   begin
      coderror := 0;
      if ( prm_solicitud_afe is null
      or prm_solicitud_afe = '' ) then
         msgerror := msgerror
                     || ' El campo prm_solicitud_afe no puede estar vacio'
                     || chr(13);
         coderror := 1;
      end if;

      if ( prm_tarifario is null
      or prm_tarifario = '' ) then
         msgerror := msgerror
                     || ' El campo prm_tarifario no puede estar vacio'
                     || chr(13);
         coderror := 1;
      end if;


      lnu_permiso := null;
      open cu_permiso_usuario(9);
      fetch cu_permiso_usuario into lnu_permiso;
      close cu_permiso_usuario;
      if ( lnu_permiso = 0 ) then
         msgerror := msgerror
                     || 'Usuario sin permisos'
                     || chr(13);
         coderror := 1;
      end if;

      if ( coderror = 0 ) then
         rc_solic.id := null;
         open cu_solici;
         fetch cu_solici into rc_solic;
         close cu_solici;
         if ( rc_solic.id is null ) then
            msgerror := msgerror
                        || 'Solicitud AFE no existe'
                        || chr(13);
            coderror := 1;
         else
            update api_afemp_step6
               set
               codigo_tarifa = prm_tarifario
             where id = rc_solic.id;

            insert into gen_bitacora_cambio values ( seq_gen_bitacora_cambio.nextval,
                                                     prm_solicitud_afe,
                                                     9,
                                                     rc_solic.codigo_tarifa, --valor_anterior,
                                                     prm_tarifario,      --valor_nuevo,  
                                                     sysdate,
                                                     prm_usuario );

            msgerror := msgerror
                        || ' CODIGO_TARIFA='
                        || rc_solic.codigo_tarifa
                        || '/'
                        || prm_tarifario;



         end if;

      end if;
      commit;
   end ajustatarifarioafe;


   procedure pr_ajustainsumobotafe (
      prm_solicitudes_afe in varchar2,
      prm_estado          in varchar2,
      prm_observaciones   in varchar2,
      prm_intentos        in varchar2,
      prm_usuario         in varchar2,
      coderror            out number,
      msgerror            out varchar2,
      registros           out sys_refcursor
   ) as


      cursor cu_solic is
      select distinct regexp_substr(
         prm_solicitudes_afe,
         '[^/,]+',
         1,
         level
      ) as solic
        from dual
      connect by
         level <= length(regexp_replace(
            prm_solicitudes_afe,
            '[^/,]+'
         )) + 1;

      cursor cu_venta_general (
         lnu_solic number
      ) is
      select solicitud_afe,
             estado,
             observaciones,
             intentos
        from rpa_venta_general
       where solicitud_afe = lnu_solic;

      cursor cu_permiso_usuario (
         lnu_tipo_cambio number
      ) is
      select count(1)
        from gen_permiso_usuario
       where usuario = prm_usuario
         and cod_tipo_cambio = lnu_tipo_cambio;

      rc_solic         cu_solic%rowtype;
      rc_venta_general cu_venta_general%rowtype;
      lnu_registro     number(1) := 0;
      lnu_permiso      number(1);
   begin
      coderror := 0;
      for rc_solic in cu_solic loop
         rc_venta_general.solicitud_afe := null;
         open cu_venta_general(rc_solic.solic);
         fetch cu_venta_general into rc_venta_general;
         close cu_venta_general;
         if ( lnu_registro = 1 ) then
            msgerror := msgerror || ' | ';
         end if;
         msgerror := msgerror
                     || ' Solicitud '
                     || rc_solic.solic;
         if ( rc_venta_general.solicitud_afe is null ) then
            msgerror := msgerror || ' No existe ';
         else
            if ( prm_estado <> 'N/A' ) then
               lnu_permiso := null;
               open cu_permiso_usuario(1);
               fetch cu_permiso_usuario into lnu_permiso;
               close cu_permiso_usuario;
               if ( lnu_permiso > 0 ) then
                  update rpa_venta_general
                     set estado = prm_estado,
                         intentos = nvl(
                            intentos,
                            0
                         ) + 1
                   where solicitud_afe = rc_solic.solic;

                  insert into gen_bitacora_cambio values ( seq_gen_bitacora_cambio.nextval,
                                                           rc_solic.solic,
                                                           1,
                                                           rc_venta_general.estado, --valor_anterior,
                                                           prm_estado,              --valor_nuevo,  
                                                           sysdate,
                                                           prm_usuario );

                  msgerror := msgerror
                              || ' ESTADO='
                              || rc_venta_general.estado
                              || '/'
                              || prm_estado;
               else
                  msgerror := msgerror
                              || ' ESTADO='
                              || 'Usuario sin permisos';
               end if;

            end if;

            if ( prm_observaciones <> 'N/A'
            or prm_observaciones is null ) then
               lnu_permiso := null;
               open cu_permiso_usuario(2);
               fetch cu_permiso_usuario into lnu_permiso;
               close cu_permiso_usuario;
               if ( lnu_permiso > 0 ) then
                  update rpa_venta_general
                     set
                     observaciones = prm_observaciones
                   where solicitud_afe = rc_solic.solic;

                  insert into gen_bitacora_cambio values ( seq_gen_bitacora_cambio.nextval,
                                                           rc_solic.solic,
                                                           2,
                                                           rc_venta_general.observaciones, --valor_anterior,
                                                           prm_observaciones,              --valor_nuevo,  
                                                           sysdate,
                                                           prm_usuario );

                  msgerror := msgerror
                              || ' OBSERVACIONES='
                              || rc_venta_general.observaciones
                              || '/'
                              || prm_observaciones;
               else
                  msgerror := msgerror
                              || ' OBSERVACIONES='
                              || 'Usuario sin permisos';
               end if;

            end if;

            if ( prm_intentos <> 'N/A'
            or prm_intentos is null ) then
               lnu_permiso := null;
               open cu_permiso_usuario(3);
               fetch cu_permiso_usuario into lnu_permiso;
               close cu_permiso_usuario;
               if ( lnu_permiso > 0 ) then
                  update rpa_venta_general
                     set
                     intentos = prm_intentos
                   where solicitud_afe = rc_solic.solic;

                  insert into gen_bitacora_cambio values ( seq_gen_bitacora_cambio.nextval,
                                                           rc_solic.solic,
                                                           3,
                                                           rc_venta_general.intentos, --valor_anterior,
                                                           prm_intentos,              --valor_nuevo,  
                                                           sysdate,
                                                           prm_usuario );

                  msgerror := msgerror
                              || ' INTENTOS='
                              || rc_venta_general.intentos
                              || '/'
                              || prm_intentos;
               else
                  msgerror := msgerror
                              || ' INTENTOS='
                              || 'Usuario sin permisos';
               end if;

            end if;
         end if;

         lnu_registro := 1;
      end loop;

      commit;
   end pr_ajustainsumobotafe;

   procedure pr_ajustepesotallabebe (
      prm_solicitud_afe    in varchar2,
      prm_tipo_doc_benef   in varchar2,
      prm_numero_doc_benef in varchar2,
      prm_peso             in varchar2,
      prm_talla            in varchar2,
      prm_usuario          in varchar2,
      coderror             out number,
      msgerror             out varchar2,
      registros            out sys_refcursor
   ) as


      cursor cu_solic is
      select id,
             codigo_tipo_documento,
             numero_documento
        from api_afemp_step5_benef
       where id_step5 = prm_solicitud_afe;

      cursor cu_benefic (
         lnu_beneficiario number,
         lnu_pregunta     number
      ) is
      select respuesta_decimal
        from api_afemp_step5_b_esta_salud
       where id_step5_benef = lnu_beneficiario
         and codigo_pregunta = lnu_pregunta;

      cursor cu_permiso_usuario (
         lnu_tipo_cambio number
      ) is
      select count(1)
        from gen_permiso_usuario
       where usuario = prm_usuario
         and cod_tipo_cambio = lnu_tipo_cambio;

      lnu_permiso        number(1);
      rc_solic           cu_solic%rowtype;
      rc_benific         cu_benefic%rowtype;
      lnu_encontro_solic number(1) := 0;
      lnu_encontro_benef number(1) := 0;
   begin
      coderror := 0;
      if ( prm_talla is null
      or prm_talla = '' ) then
         msgerror := msgerror
                     || ' Debe ingresar la TALLA, si no la quiere cambiar debe ingresar N/A'
                     || chr(13);
         coderror := 1;
      end if;

      if ( prm_peso is null
      or prm_peso = '' ) then
         msgerror := msgerror
                     || ' Debe ingresar el PESO, si no la quiere cambiar debe ingresar N/A'
                     || chr(13);
         coderror := 1;
      end if;

      if ( coderror = 0 ) then
         for rc_solic in cu_solic loop
            lnu_encontro_solic := 1;
            if (
               rc_solic.codigo_tipo_documento = prm_tipo_doc_benef
               and rc_solic.numero_documento = prm_numero_doc_benef
            ) then
               lnu_encontro_benef := 1;
               if (
                  prm_talla <> 'N/A'
                  and prm_talla is not null
               ) then
						--Se actualiza talla

                  lnu_permiso := null;
                  open cu_permiso_usuario(4);
                  fetch cu_permiso_usuario into lnu_permiso;
                  close cu_permiso_usuario;
                  if ( lnu_permiso > 0 ) then
                     open cu_benefic(
                        rc_solic.id,
                        26
                     );
                     fetch cu_benefic into rc_benific;
                     close cu_benefic;
                     update api_afemp_step5_b_esta_salud
                        set
                        respuesta_decimal = prm_talla
                      where id_step5_benef = rc_solic.id
                        and codigo_pregunta = 26;

                     insert into gen_bitacora_cambio values ( seq_gen_bitacora_cambio.nextval,
                                                              prm_solicitud_afe
                                                              || '-'
                                                              || rc_solic.id,
                                                              4,
                                                              rc_benific.respuesta_decimal, --valor_anterior,
                                                              prm_talla,              --valor_nuevo,  
                                                              sysdate,
                                                              prm_usuario );

                     msgerror := msgerror
                                 || ' TALLA='
                                 || rc_benific.respuesta_decimal
                                 || '/'
                                 || prm_talla
                                 || chr(13);
                  else
                     msgerror := msgerror
                                 || ' TALLA='
                                 || 'Usuario sin permisos'
                                 || chr(13);
                  end if;

               end if;

               if (
                  prm_peso <> 'N/A'
                  and prm_peso is not null
               ) then
                  lnu_permiso := null;
                  open cu_permiso_usuario(5);
                  fetch cu_permiso_usuario into lnu_permiso;
                  close cu_permiso_usuario;
                  if ( lnu_permiso > 0 ) then
                     open cu_benefic(
                        rc_solic.id,
                        27
                     );
                     fetch cu_benefic into rc_benific;
                     close cu_benefic;

							--Se actualiza peso
                     update api_afemp_step5_b_esta_salud
                        set
                        respuesta_decimal = prm_peso
                      where id_step5_benef = rc_solic.id
                        and codigo_pregunta = 27;

                     insert into gen_bitacora_cambio values ( seq_gen_bitacora_cambio.nextval,
                                                              prm_solicitud_afe
                                                              || '-'
                                                              || rc_solic.id,
                                                              5,
                                                              rc_benific.respuesta_decimal, --valor_anterior,
                                                              prm_peso,              --valor_nuevo,  
                                                              sysdate,
                                                              prm_usuario );

                     msgerror := msgerror
                                 || ' PESO='
                                 || rc_benific.respuesta_decimal
                                 || '/'
                                 || prm_peso
                                 || chr(13);
                  else
                     msgerror := msgerror
                                 || ' PESO='
                                 || 'Usuario sin permisos'
                                 || chr(13);
                  end if;

               end if;
            end if;

         end loop;

         if ( lnu_encontro_solic = 0 ) then
            msgerror := msgerror
                        || 'Solicitud AFE no existe'
                        || chr(13);
         else
            if ( lnu_encontro_benef = 0 ) then
               msgerror := msgerror
                           || 'Beneficiario no existe para la solicigud AFE'
                           || chr(13);
            end if;
         end if;

      end if;


      commit;
   end pr_ajustepesotallabebe;

   procedure pr_ajusteplanvoluntario (
      prm_solicitud_afe    in varchar2,
      prm_tipo_doc_benef   in varchar2,
      prm_numero_doc_benef in varchar2,
      prm_plan_voluntario  in varchar2,
      prm_observacion      in varchar2,
      prm_usuario          in varchar2,
      coderror             out number,
      msgerror             out varchar2,
      registros            out sys_refcursor
   ) as


      cursor cu_solic is
      select id,
             codigo_tipo_documento,
             numero_documento
        from api_afemp_step5_benef
       where id_step5 = prm_solicitud_afe;

      cursor cu_benefic (
         lnu_beneficiario number,
         lnu_pregunta     number
      ) is
      select respuesta_boolean,
             observacion
        from api_afemp_step5_b_esta_salud
       where id_step5_benef = lnu_beneficiario
         and codigo_pregunta = lnu_pregunta;

      cursor cu_permiso_usuario (
         lnu_tipo_cambio number
      ) is
      select count(1)
        from gen_permiso_usuario
       where usuario = prm_usuario
         and cod_tipo_cambio = lnu_tipo_cambio;

      lnu_permiso        number(1);
      rc_solic           cu_solic%rowtype;
      rc_benific         cu_benefic%rowtype;
      lnu_encontro_solic number(1) := 0;
      lnu_encontro_benef number(1) := 0;
   begin
      coderror := 0;
      if ( prm_plan_voluntario is null
      or prm_plan_voluntario = '' ) then
         msgerror := msgerror
                     || ' El campo prm_plan_voluntario no puede estar vacio, debe ingresar 0/1'
                     || chr(13);
         coderror := 1;
      end if;

      if (
         prm_plan_voluntario = '1'
         and ( prm_observacion is null
         or prm_observacion = '' )
      ) then
         msgerror := msgerror
                     || ' El campo prm_observacion no puede estar vacio'
                     || chr(13);
         coderror := 1;
      end if;

      if ( prm_plan_voluntario not in ( '0',
                                        '1' ) ) then
         msgerror := msgerror
                     || ' Campo prm_plan_voluntario es invalido, debe ingresar 0/1'
                     || chr(13);
         coderror := 1;
      end if;

      lnu_permiso := null;
      open cu_permiso_usuario(6);
      fetch cu_permiso_usuario into lnu_permiso;
      close cu_permiso_usuario;
      if ( lnu_permiso = 0 ) then
         msgerror := msgerror
                     || 'Usuario sin permisos'
                     || chr(13);
         coderror := 1;
      end if;

      if ( coderror = 0 ) then
         for rc_solic in cu_solic loop
            lnu_encontro_solic := 1;
            if (
               rc_solic.codigo_tipo_documento = prm_tipo_doc_benef
               and rc_solic.numero_documento = prm_numero_doc_benef
            ) then
               lnu_encontro_benef := 1;


					--Se actualiza Plan voluntario del que viene (Encuesta de salud)
               open cu_benefic(
                  rc_solic.id,
                  24
               );
               fetch cu_benefic into rc_benific;
               close cu_benefic;
               update api_afemp_step5_b_esta_salud
                  set respuesta_boolean = prm_plan_voluntario,
                      observacion = prm_observacion
                where id_step5_benef = rc_solic.id
                  and codigo_pregunta = 24;

               insert into gen_bitacora_cambio values ( seq_gen_bitacora_cambio.nextval,
                                                        prm_solicitud_afe
                                                        || '-'
                                                        || rc_solic.id,
                                                        6,
                                                        rc_benific.respuesta_boolean, --valor_anterior,
                                                        prm_plan_voluntario,          --valor_nuevo,  
                                                        sysdate,
                                                        prm_usuario );

               msgerror := msgerror
                           || ' PLAN VOLUNTARIO='
                           || rc_benific.respuesta_boolean
                           || '/'
                           || prm_plan_voluntario
                           || chr(13);

               insert into gen_bitacora_cambio values ( seq_gen_bitacora_cambio.nextval,
                                                        prm_solicitud_afe
                                                        || '-'
                                                        || rc_solic.id,
                                                        7,
                                                        rc_benific.observacion,  --valor_anterior,
                                                        prm_observacion,         --valor_nuevo,  
                                                        sysdate,
                                                        prm_usuario );

               msgerror := msgerror
                           || ' OBSERVACION='
                           || rc_benific.observacion
                           || '/'
                           || prm_observacion
                           || chr(13);

            end if;

         end loop;

         if ( lnu_encontro_solic = 0 ) then
            msgerror := msgerror
                        || 'Solicitud AFE no existe'
                        || chr(13);
         else
            if ( lnu_encontro_benef = 0 ) then
               msgerror := msgerror
                           || 'Beneficiario no existe para la solicigud AFE'
                           || chr(13);
            end if;
         end if;

         commit;
      end if;

   end pr_ajusteplanvoluntario;

   procedure pr_ajusteestadosolicafe (
      prm_solicitud_afe in varchar2,
      prm_codigo_estado in varchar2,
      prm_usuario       in varchar2,
      coderror          out number,
      msgerror          out varchar2,
      registros         out sys_refcursor
   ) as

      -- Obtiene toda la información de una afiliación
      cursor cu_valida_solicitud is
      select id,
             codigo_estado
        from api_afemp_step1
       where id = prm_solicitud_afe;

      -- Obtiene todos los estados que puede tener una afiliación
      cursor cu_estados_solicitud (
         lnu_estado varchar2
      ) is
      select codigo,
             descripcion
        from api_afemp_p_estados
       where codigo = lnu_estado;

      -- Obtiene los permisos que tiene un usuario para hacer cambios
      cursor cu_permiso_usuario (
         lnu_tipo_cambio number
      ) is
      select count(1)
        from gen_permiso_usuario
       where upper(usuario) = upper(prm_usuario)
         and cod_tipo_cambio = lnu_tipo_cambio;

      -- Obtiene los roles que tiene un usuario desde el PROFILE
      cursor cu_role_user_profile is
      select ar.clave,
       ar.nombre as rol,
       au.nombre
      from aut_usuario au
      inner join aut_aplicaciones_usuario aau
      on au.codigo = aau.codigo_usuario
      inner join aut_aplicaciones aa
      on aa.codigo = aau.codigo_aplicacion
      inner join aut_roles_usuario_aplicacion arua
      on arua.codigo_usuario_aplicacion = aau.codigo
      inner join aut_roles ar
      on ar.codigo = arua.codigo_rol
      where upper(trim(au.documento)) = upper(trim(prm_usuario))
         and upper(trim(aa.aplicativo)) = upper(trim('Macro actualiza datos'))
         and trim(aau.estado) = 'A'
         and au.estado = 1
         and ar.estado = 1
         and arua.estado = 1;

      v_permiso_profile       cu_role_user_profile%rowtype;
      v_permiso_cambio        number(1);
      v_solicitud             cu_valida_solicitud%rowtype;
      v_estados_solicitud     cu_estados_solicitud%rowtype;
      v_permiso_rol           varchar2(100);
      v_existe_estado        number(1);
      v_codigo_estado         api_afemp_step1.id%TYPE;
   begin

      coderror := 0;
      if ( prm_solicitud_afe is null or prm_solicitud_afe = '' ) then
         msgerror := ' El campo (prm_solicitud_afe) es requerido';
         coderror := 5;
         return;
      else

         open cu_valida_solicitud;
         fetch cu_valida_solicitud into v_solicitud;
         close cu_valida_solicitud;

         if ( v_solicitud.id is null ) then
            msgerror := 'La solicitud AFE '|| prm_solicitud_afe ||' no existe';
            coderror := 5;
            return;
         end if;

      end if;

      if ( prm_usuario is null or prm_usuario = '' ) then
         msgerror := ' El campo (prm_usuario) es requerido';
         coderror := 5;
         return;
      else
         open cu_role_user_profile;
            loop
               fetch cu_role_user_profile into v_permiso_profile;
               exit when cu_role_user_profile%notfound;
               exit when v_permiso_profile.clave = 'MsComercialAFE'
               or v_permiso_profile.clave = 'AdminOperacionesAFE';
            end loop;
         close cu_role_user_profile;

         if(v_permiso_profile.clave is null or v_permiso_profile.clave ='') then
            msgerror := 'El usuario ('||prm_usuario||') no tiene permisos para ejecutar esta aplicación en el PROFILE!';
            coderror := 5;
            return;
         end if;

         open cu_permiso_usuario(8);
         fetch cu_permiso_usuario into v_permiso_cambio;
         close cu_permiso_usuario;

      end if;

      if ( v_permiso_cambio = 0 ) then
         msgerror := 'Usuario sin permisos para realizar esta acción';
         coderror := 1;
         return;
      end if;

      if ( prm_codigo_estado is null or prm_codigo_estado = '' ) then
         msgerror := 'El campo (prm_codigo_estado) es requerido';
         coderror := 5;
         return;
      else
         v_codigo_estado := trim(substr(prm_codigo_estado,0,instr(prm_codigo_estado,'-') - 1));

         open cu_estados_solicitud(v_codigo_estado);
            fetch cu_estados_solicitud into v_estados_solicitud;
         close cu_estados_solicitud;

         if(v_estados_solicitud.codigo is null)then
            msgerror := 'El código de estado ('|| prm_codigo_estado || ') no es valido!';
            coderror := 1;
            return;
         end if;
      end if;

      if(v_permiso_profile.clave = 'MsComercialAFE' and v_permiso_cambio = 1 ) then

         select valor
           into v_permiso_rol
           from app_config
          where varkey = 'ROLE_COMERC_AFE';

         v_existe_estado := psgen_generalservices.fn_existstring(v_codigo_estado,v_permiso_rol);

         if ( v_existe_estado = 0 ) then
            msgerror := 'El estado seleccionado (' || prm_codigo_estado ||') no es valido para su rol!';
            coderror := 1;
            return;
         end if;

         -- Actualiza el estado de la afilición
         update api_afemp_step1 set codigo_estado = v_codigo_estado where id = v_solicitud.id; 

         -- Actualiza la bitacora
         insert into gen_bitacora_cambio 
         values ( seq_gen_bitacora_cambio.nextval,
                  prm_solicitud_afe,
                  8,
                  v_solicitud.codigo_estado, --valor_anterior,
                  v_codigo_estado,      --valor_nuevo,  
                  sysdate,
                  prm_usuario );

         commit;
      end if;

      if(v_permiso_profile.clave = 'AdminOperacionesAFE' and v_permiso_cambio = 1 ) then

         select valor
           into v_permiso_rol
           from app_config
          where varkey = 'ROLE_ADMIN_AFE';

         v_existe_estado := psgen_generalservices.fn_existstring(v_codigo_estado,v_permiso_rol);

         if ( v_existe_estado = 0 ) then
            msgerror := 'El estado seleccionado (' || prm_codigo_estado ||') no es valido para su rol!';
            coderror := 1;
            return;
         end if;

         -- Actualiza el estado de la afilición
         update api_afemp_step1 set codigo_estado = v_codigo_estado where id = v_solicitud.id; 

         -- Actualiza la bitacora
         insert into gen_bitacora_cambio 
         values ( seq_gen_bitacora_cambio.nextval,
                  prm_solicitud_afe,
                  8,
                  v_solicitud.codigo_estado, --valor_anterior,
                  v_codigo_estado,      --valor_nuevo,  
                  sysdate,
                  prm_usuario );

         commit;
      end if;

         open registros for 
            select id, codigo_estado from api_afemp_step1 where id=prm_solicitud_afe; 

         msgerror := 'Solicitud actualizada!';
         coderror := 0;

   end pr_ajusteestadosolicafe;


   procedure pr_envio_reporte_afe (
      coderror  out number,
      msgerror  out varchar2,
      registros out sys_refcursor
   ) as

      v_fecha                   date;
      v_mensaje                 varchar2(400);
      v_afiliaciones_pendientes varchar2(100);
      v_afiliaciones_grabadas   varchar2(100);
      v_lista_destinatarios     varchar2(500);
      v_afiliaciones_novedad    varchar2(100);
      v_telefono_actual         varchar2(20);
      v_posicion_inicio         number := 1;
      v_posicion_fin            number;
      v_asunto_sms              varchar2(50);
      v_param                   varchar2(20);
   begin 

        -- Se obtiene valor para dias de la novedad

      select valor
        into v_param
        from app_config
       where varkey = 'PARAM_NOVEDAD';

		-- Obtiene la fecha actual
      select trunc(sysdate)
        into v_fecha
        from dual;

        -- Obtiene ventas en novedad
      select count(*)
        into v_afiliaciones_novedad
        from rpa_venta_general
       where estado = 'NOVEDAD'
         and trunc(sysdate) - trunc(fecha_novedad) <= v_param;


		-- Obtiene el número de afiliaciones gabadas
      select count(*)
        into v_afiliaciones_grabadas
        from rpa_venta_general
       where estado = 'GRABADO'
         and trunc(fecha_grabacion) = trunc(sysdate);


		-- Obtiene el número de afiliaciones pendientes
      select count(*)
        into v_afiliaciones_pendientes
        from rpa_venta_general
       where estado = 'LISTO';

		-- Obtiene el mensaje a enviar
      select valor
        into v_mensaje
        from app_config
       where varkey = 'MSG_REPORT_AFE';

      v_mensaje := replace(
         v_mensaje,
         '{fecha}',
         v_fecha
      );
      if v_afiliaciones_novedad <= 1 then
         v_mensaje := replace(
            v_mensaje,
            'novedad',
            'novedad'
         );
         v_mensaje := replace(
            v_mensaje,
            ' afiliaciones ',
            ' afiliación '
         );
         v_mensaje := replace(
            v_mensaje,
            '{num_novedad}',
            v_afiliaciones_novedad
         );
      else
         v_mensaje := replace(
            v_mensaje,
            '{num_novedad}',
            v_afiliaciones_novedad
         );
      end if;

      if v_afiliaciones_grabadas <= 1 then
         v_mensaje := replace(
            v_mensaje,
            'grabaron',
            'grabó'
         );
         v_mensaje := replace(
            v_mensaje,
            ' afiliaciones ',
            ' afiliación '
         );
         v_mensaje := replace(
            v_mensaje,
            '{num_grabados}',
            v_afiliaciones_grabadas
         );
      else
         v_mensaje := replace(
            v_mensaje,
            '{num_grabados}',
            v_afiliaciones_grabadas
         );
      end if;

      if v_afiliaciones_pendientes <= 1 then
         v_mensaje := replace(
            v_mensaje,
            'quedaron pendientes',
            'quedo pendiente'
         );
         v_mensaje := replace(
            v_mensaje,
            '{num_pendientes}',
            v_afiliaciones_pendientes
         );
      else
         v_mensaje := replace(
            v_mensaje,
            '{num_pendientes}',
            v_afiliaciones_pendientes
         );
      end if;

		-- Obtiene la lista de destinatarios de mensajes SMS
      select valor
        into v_lista_destinatarios
        from app_config
       where varkey = 'SEND_REPORT_TO';

		-- Contar las afiliaciones pendientes
      select count(*)
        into v_afiliaciones_pendientes
        from rpa_venta_general
       where estado = 'LISTO';

		-- Contar el asunto que va a tener el mensaje
      select valor
        into v_asunto_sms
        from app_config
       where varkey = 'ASUNTO_SMS_AFE';

		-- Iterar sobre la lista de teléfonos
      while v_posicion_inicio < length(v_lista_destinatarios) loop
			-- Encontrar la posición de la coma
         v_posicion_fin := instr(
            v_lista_destinatarios,
            ',',
            v_posicion_inicio
         );

			-- Extraer el número de teléfono
         if v_posicion_fin = 0 then
            v_telefono_actual := substr(
               v_lista_destinatarios,
               v_posicion_inicio
            );
            v_posicion_inicio := length(v_lista_destinatarios) + 1;
         else
            v_telefono_actual := substr(
               v_lista_destinatarios,
               v_posicion_inicio,
               v_posicion_fin - v_posicion_inicio
            );
            v_posicion_inicio := v_posicion_fin + 1;
         end if;

			-- Enviar mensaje SMS
         core_send_sms_email(
            p_sms_origen      => 'BOT_AFE',
            p_email_asunto    => v_asunto_sms,
            p_sms_contenido   => v_mensaje,
            p_sms_largo       => 'false',
            p_sms_num_destino => v_telefono_actual,
            p_sms_estado      => 'NOE',
            p_email_destino   => null,
            p_email_estado    => 'NOA',
            p_email_contenido => null,
            p_sms_url         => null
         );

      end loop;

      coderror := 0; -- Asignar un código de error, 0 si no hay errores
      msgerror := 'Ok'; -- Asignar el mensaje de salida

   exception
      when others then
         coderror := sqlcode;
         msgerror := sqlerrm;
   end pr_envio_reporte_afe;

end psgen_snpinsumobotafe;
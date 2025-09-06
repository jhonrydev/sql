create or replace package body psgen_sndaceptadoctyc_hd as

   -- Obtiene la verción de los documentos de TyC o HD más reciente
   procedure fncu_getdoctyc_hd (
      pty_tipo_doc in adm_version_documentos.tipo_documento%type,
      pty_cod_app  in adm_version_documentos.codigo_app%type,
      coderror     out number,
      msgerror     out varchar2,
      registros    out sys_refcursor
   ) as

      cursor cu_app(cod_app adm_version_documentos.codigo_app%type) is
      select count(1)
        from adm_version_documentos
       where codigo_app = cod_app;

   -- valida la versión del documento de TyC mas reciente
      cursor cu_tyc (cod_app adm_version_documentos.codigo_app%type)is
      select count(1)
        from adm_version_documentos
       where id = (
         select max(id)
           from adm_version_documentos
          where tipo_documento = 'Términos y Condiciones'
            and codigo_app = cod_app
      );

   -- valida la versión del documento de HD mas reciente
      cursor cu_hd (cod_app adm_version_documentos.codigo_app%type)is
      select count(1)
        from adm_version_documentos
       where id = (
         select max(id)
           from adm_version_documentos
          where tipo_documento = 'Política de Tratamiento de Datos'
            and codigo_app = cod_app
      );

      lty_cantdoc number;
      lty_canttyc number;
      lty_canthd  number;
      cod_app     varchar2(20);
   begin    

      if(pty_tipo_doc is null OR pty_tipo_doc ='') THEN
         coderror := 5;
         msgerror := 'El parametro de entrada (pty_tipo_doc) es obligatorio';
         return;
      end if;

      if(pty_cod_app is null OR pty_cod_app ='') THEN
         coderror := 5;
         msgerror := 'El parametro de entrada (pty_cod_app) es obligatorio';
         return;
      end if;

      if(pty_cod_app='APPMP' or pty_cod_app='OVAWEB' or pty_cod_app='WSP') THEN
         cod_app:='OVU-APPMP-WSP';
      else
         cod_app:= UPPER(pty_cod_app);
      end if;

		-- Consulta si la app tiene una nueva versión del documento TyC parametrizados
      open cu_app(cod_app);
      fetch cu_app into lty_cantdoc;
      close cu_app;
      if ( lty_cantdoc > 0 ) then
         if ( UPPER(pty_tipo_doc) = UPPER('TyC') ) then
				-- Consulta si existe al menos una versión del documento TyC parametrizado
            open cu_tyc(cod_app);
            fetch cu_tyc into lty_canttyc;
            close cu_tyc;

            if ( lty_canttyc > 0 ) then
               open registros for
                select version,
                        to_char(fecha,'dd-mm-yyyy') fecha,
                        descripcion
               from adm_version_documentos
               where id = (
                  select max(id)
                  from adm_version_documentos
                  where tipo_documento = 'Términos y Condiciones'
                     and codigo_app = cod_app
               );

               coderror := 0;
               msgerror := 'Ok';
            else
               coderror := 3;
               msgerror := 'No existe una version de documento parametrizada para la aplicacion y tipo de documento';
            end if;

         elsif ( UPPER(pty_tipo_doc) = 'HD' ) then
				-- Consulta si existe al menos una versión del documento HD parametrizado
            open cu_hd(cod_app);
            fetch cu_hd into lty_canthd;
            close cu_hd;
            if ( lty_canthd > 0 ) then
               open registros for
                select version,
                       to_char(fecha,'dd-mm-yyyy') fecha,
                        descripcion
               from adm_version_documentos
               where id = (
                  select max(id)
                  from adm_version_documentos
                  where tipo_documento = 'Política de Tratamiento de Datos'
                     and codigo_app = cod_app
               );

               coderror := 0;
               msgerror := 'Ok';
            else
               coderror := 3;
               msgerror := 'No existe una version de documento parametrizada para la aplicacion y tipo de documento';
            end if;

         else
            coderror := 1;
            msgerror := 'El tipo de documento ('|| pty_tipo_doc||') no existe, los tipos de documentos permitidos son TyC|HD';
         end if;
      else
         cod_app:=pty_cod_app;
         coderror := 2;
         msgerror := 'La aplicacion ('||cod_app ||') no existe o no tiene una versión de documentos parametrizados';
      end if;

   end fncu_getdoctyc_hd;

-- Obtiene la información de aceptación de TyC y HD del usuario
   procedure fncu_getversiondoctyc_hd (
      pty_tipo_id in acepta_terminos_infomedica.tipo_documento%type,
      pty_num_id  in acepta_terminos_infomedica.numero_documento%type,
      pty_cod_app in adm_version_documentos.codigo_app%type,
      coderror    out number,
      msgerror    out varchar2,
      registros   out sys_refcursor
   ) as
      -- Valida la aceptación de TyC y HD de en las app (OVU-APPMP-WSP)
      cursor cu_valida_aceptacion_tyc_hd (
         tipo_id in acepta_terminos_infomedica.tipo_documento%type,
         num_id  in acepta_terminos_infomedica.numero_documento%type
      ) is  
      WITH cti_valida_aceptacion as ( 
         SELECT 
         TYC.NOMBRE_APLICACION AS APP_TYC,
         TYC.VERSION_DOCUMENTO AS VER_TYC,
         HD.NOMBRE_APLICACION AS APP_HD, 
         HD.VERSION_DOCUMENTO AS VER_HD
         FROM ACEPTA_TERMINOS_INFOMEDICA TYC 
         INNER JOIN ACEPTA_TERMINOS_HD HD 
         ON TYC.NUMERO_DOCUMENTO = HD.NUMERO_DOCUMENTO AND TYC.TIPO_DOCUMENTO = HD.TIPO_DOCUMENTO
         WHERE TYC.NUMERO_DOCUMENTO = pty_num_id
         AND UPPER(TYC.TIPO_DOCUMENTO) = UPPER(tipo_id)
         AND UPPER(TYC.NOMBRE_APLICACION) IN ('APPMP','OVAWEB','WSP')
               ),
         cti_valida_version_reciente as (
            SELECT 
            MAX(TYC.VERSION_DOCUMENTO) AS MAX_VER_TYC,
            MAX(HD.VERSION_DOCUMENTO) AS MAX_VER_HD
            FROM ACEPTA_TERMINOS_INFOMEDICA TYC 
            INNER JOIN ACEPTA_TERMINOS_HD HD 
            ON TYC.NUMERO_DOCUMENTO = HD.NUMERO_DOCUMENTO AND TYC.TIPO_DOCUMENTO = HD.TIPO_DOCUMENTO
            WHERE TYC.NUMERO_DOCUMENTO = pty_num_id
            AND UPPER(TYC.TIPO_DOCUMENTO) = UPPER(tipo_id)
            AND UPPER(TYC.NOMBRE_APLICACION) IN ('APPMP','OVAWEB','WSP')
         )
         SELECT 
            v.APP_TYC
         FROM 
            cti_valida_aceptacion v,
            cti_valida_version_reciente vr
         WHERE v.VER_TYC=vr.MAX_VER_TYC AND v.VER_HD = vr.MAX_VER_HD;

      cod_app VARCHAR2(20);
      cod_app_doc VARCHAR2(20);
      app_acepto VARCHAR2(20);
   begin

      if ( pty_tipo_id is null or pty_tipo_id = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada (pty_tipo_id) es obligatorio';
         return;
      end if;

      if ( pty_num_id is null or pty_num_id = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada (pty_num_id) es obligatorio';
         return;
      end if;

      if ( pty_cod_app is null or pty_cod_app = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada (pty_cod_app) es obligatorio';
         return;
      end if;

      if(pty_cod_app='APPMP' or pty_cod_app='OVAWEB' or pty_cod_app='WSP') THEN

         open cu_valida_aceptacion_tyc_hd(pty_tipo_id,pty_num_id);
         fetch cu_valida_aceptacion_tyc_hd into app_acepto;
         close cu_valida_aceptacion_tyc_hd;

         cod_app_doc:='OVU-APPMP-WSP';
         cod_app:=app_acepto;
      else
         cod_app_doc:=pty_cod_app;
         cod_app:=pty_cod_app;
      end if;

        -- Obtiene la informació de la version del documentos de TyC y HD mas reciente
         open registros for with 
         -- Versión vigente de TyC
          tyc_vigente as (
                               select version
                                 from adm_version_documentos
                                where id = (
                                  select max(id)
                                    from adm_version_documentos
                                   where tipo_documento = 'Términos y Condiciones'
                                     and codigo_app = cod_app_doc
                               )
                            ),
         -- Última aceptación TyC
                            tyc_aceptacion as (
                               select version_documento,
                                      to_char(
                                         fecha,
                                         'DD-MM-YYYY'
                                      ) as fecha
                                 from acepta_terminos_infomedica
                                where consecutivo = (
                                  select max(consecutivo)
                                    from acepta_terminos_infomedica
                                   where tipo_documento = pty_tipo_id
                                     and numero_documento = pty_num_id
                                     and nombre_aplicacion = cod_app
                               )
                            ),
         -- Versión vigente de HD
                            hd_vigente as (
                               select version
                                 from adm_version_documentos
                                where id = (
                                  select max(id)
                                    from adm_version_documentos
                                   where tipo_documento = 'Política de Tratamiento de Datos'
                                     and codigo_app = cod_app_doc
                               )
                            ),
         -- Última aceptación HD
                            hd_aceptacion as (
                               select version_documento,
                                      to_char(
                                         fecha,
                                         'DD-MM-YYYY'
                                      ) as fecha
                                 from acepta_terminos_hd
                                where consecutivo = (
                                  select max(consecutivo)
                                    from acepta_terminos_hd
                                   where tipo_documento = pty_tipo_id
                                     and numero_documento = pty_num_id
                                     and nombre_aplicacion = cod_app
                               )
                            )
                            select (
                               select version
                                 from tyc_vigente
                            ) as vtycvigente,
                                   (
                                      select version_documento
                                        from tyc_aceptacion
                                   ) as vtycacepta,
                                   (
                                      select fecha
                                        from tyc_aceptacion
                                   ) as fechaaceptatyc,
                                   (
                                      select version
                                        from hd_vigente
                                   ) as vhdvigente,
                                   (
                                      select version_documento
                                        from hd_aceptacion
                                   ) as vhdacepta,
                                   (
                                      select fecha
                                        from hd_aceptacion
                                   ) as fechaaceptahd
                              from dual;
         coderror := 0;
         msgerror := 'Ok';

   end fncu_getversiondoctyc_hd; 



  /****************** INICIO WFMS5471***********************/

 /******* Muestra la lista de aplicaciones existentes ***************/
   procedure pr_getlistaapptyc_hd (
      coderror  out number,
      msgerror  out varchar2,
      registros out sys_refcursor
   ) as
   begin
      open registros for select distinct codigo aplicacion
                                              from aut_aplicaciones_info
                          where estado = 1;

      coderror := 0;
      msgerror := 'Registro encontrado';
   exception
      when others then
         coderror := 1;
         msgerror := 'No se encontro ningun registro';
   end pr_getlistaapptyc_hd;

 /******* Inserta el registro segun la aplicacion y tipo documento ***************/
   procedure pr_getguardatyc_hd (
      pty_tipo_doc    in adm_version_documentos.tipo_documento%type,
      pty_cod_app     in adm_version_documentos.codigo_app%type,
      prm_usuario     in adm_version_documentos.usuario%type,
      prm_descripcion in adm_version_documentos.descripcion%type,
      coderror        out number,
      msgerror        out varchar2,
      registros       out sys_refcursor
   ) as
      lty_cantdoc        number := 0;
      lty_tipo_documento varchar2(50);
      lty_version_seq    number;
   begin
      if pty_tipo_doc is null
      or pty_tipo_doc = '' then
         coderror := 1;
         msgerror := 'El parámetro tipo documento no puede ser nulo o vacío.';
         return;
      elsif pty_tipo_doc not in ( 'TyC',
                                  'HD' ) then
         coderror := 2;
         msgerror := 'Valor no válido para el tipo de documento. Debe ser TyC o HD.';
         return;
      end if;

      if pty_cod_app is null
      or pty_cod_app = '' then
         coderror := 1;
         msgerror := 'El parámetro código aplicación no puede ser nulo o vacío.';
         return;
      end if;

      if prm_usuario is null
      or prm_usuario = '' then
         coderror := 1;
         msgerror := 'El parámetro usuario no puede ser nulo o vacío.';
         return;
      end if;

      if prm_descripcion is null
      or prm_descripcion = '' then
         coderror := 1;
         msgerror := 'El parámetro descripción no puede ser nulo o vacío.';
         return;
      end if;

      if length(prm_descripcion) = 0
      or length(prm_descripcion) <= 100 then
         coderror := 1;
         msgerror := 'El parámetro descripción no cuenta con una longitud minima valida, validar el texto ingresado.';
         return;
      end if;

      select count(1)
        into lty_cantdoc
        from adm_version_documentos
       where codigo_app = pty_cod_app;

      if lty_cantdoc = 0 then
         coderror := 1;
         msgerror := 'La aplicación especificada no existe.';
         return;
      end if;

      if pty_tipo_doc = 'TyC' then
         lty_tipo_documento := 'Términos y Condiciones';
         select adm_version_terms_cond_seq.nextval
           into lty_version_seq
           from dual;
      else
         lty_tipo_documento := 'Política de Tratamiento de Datos';
         select adm_version_tto_datos_seq.nextval
           into lty_version_seq
           from dual;
      end if;

      begin
         insert into adm_version_documentos (
            id,
            usuario,
            fecha,
            version,
            tipo_documento,
            descripcion,
            codigo_app
         ) values ( adm_version_documentos_id_seq.nextval,
                    prm_usuario,
                    sysdate,
                    lty_version_seq,
                    lty_tipo_documento,
                    prm_descripcion,
                    pty_cod_app );

         coderror := 0;
         msgerror := 'Registro de '
                     || lty_tipo_documento
                     || ' insertado correctamente para la aplicación '
                     || pty_cod_app;
         commit;
      exception
         when dup_val_on_index then
            coderror := 1;
            msgerror := 'ERROR: Ya existe un registro con este identificador.';
            rollback;
         when others then
            coderror := 1;
            msgerror := 'ERROR al insertar '
                        || lty_tipo_documento
                        || ' para la aplicación '
                        || pty_cod_app
                        || ': '
                        || sqlerrm;
            rollback;
      end;

   end pr_getguardatyc_hd;

 /******* Actualiza el registro segun la aplicacion y tipo documento ***************/
   procedure pr_getactualizatyc_hd (
      pty_tipo_doc    in adm_version_documentos.tipo_documento%type,
      pty_cod_app     in adm_version_documentos.codigo_app%type,
      prm_descripcion in adm_version_documentos.descripcion%type,
      coderror        out number,
      msgerror        out varchar2,
      registros       out sys_refcursor
   ) as
      lty_cantdoc    number;
      lty_cantdoctyc number;
      lty_cantdochd  number;
   begin
      coderror := 0;
      msgerror := 'Ok';
      if pty_tipo_doc is null
      or pty_tipo_doc = '' then
         coderror := 1;
         msgerror := 'El parámetro tipo documento no puede ser nulo o vacío.';
         return;
      elsif pty_tipo_doc not in ( 'TyC',
                                  'HD' ) then
         coderror := 2;
         msgerror := 'Valor no válido para el parametro tipo de documento. Debe ser TyC para términos y condiciones o HD para Política de tratamiento de datos'
         ;
         return;
      end if;

      if ( pty_cod_app is null
      or pty_cod_app = '' ) then
         coderror := 1;
         msgerror := 'El parametro Codigo Aplicación es obligatorio';
         return;
      end if;

      if ( prm_descripcion is null
      or prm_descripcion = '' ) then
         coderror := 1;
         msgerror := 'El parametro Descripción es obligatorio';
         return;
      end if;

      select count(1)
        into lty_cantdoc
        from adm_version_documentos
       where codigo_app = pty_cod_app;

      if lty_cantdoc = 0 then
         coderror := 1;
         msgerror := 'La aplicación no existe o no tiene documentos parametrizados';
         return;
      end if;

      if pty_tipo_doc = 'TyC' then
         select count(1)
           into lty_cantdoctyc
           from adm_version_documentos
          where id = (
            select max(id)
              from adm_version_documentos
             where tipo_documento = 'Términos y Condiciones'
               and codigo_app = pty_cod_app
         );

         if lty_cantdoctyc > 0 then
            begin
               update adm_version_documentos
                  set version = adm_version_terms_cond_seq.nextval,
                      descripcion = prm_descripcion
                where id = (
                  select max(id)
                    from adm_version_documentos
                   where tipo_documento = 'Términos y Condiciones'
                     and codigo_app = pty_cod_app
               );
               commit;
               msgerror := 'Se actualizan los términos y condiciones para la aplicación: ' || pty_cod_app;
            exception
               when others then
                  coderror := 1;
                  msgerror := 'Error al actualizar términos y condiciones para la aplicación '
                              || pty_cod_app
                              || ': '
                              || sqlerrm;
                  rollback;
            end;
         else
            coderror := 3;
            msgerror := 'No existe versión de documento parametrizada para la aplicación: '
                        || pty_cod_app
                        || ' y tipo de documento Términos y Condiciones';
         end if;

      elsif pty_tipo_doc = 'HD' then
         select count(1)
           into lty_cantdochd
           from adm_version_documentos
          where id = (
            select max(id)
              from adm_version_documentos
             where tipo_documento = 'Política de Tratamiento de Datos'
               and codigo_app = pty_cod_app
         );

         if lty_cantdochd > 0 then
            begin
               update adm_version_documentos
                  set version = adm_version_tto_datos_seq.nextval,
                      descripcion = prm_descripcion
                where id = (
                  select max(id)
                    from adm_version_documentos
                   where tipo_documento = 'Política de Tratamiento de Datos'
                     and codigo_app = pty_cod_app
               );
               commit;
               msgerror := 'Se actualiza la Política de Tratamiento de Datos para la aplicación: ' || pty_cod_app;
            exception
               when others then
                  coderror := 1;
                  msgerror := 'Error al actualizar la Política de Tratamiento de Datos para la aplicación '
                              || pty_cod_app
                              || ': '
                              || sqlerrm;
                  rollback;
            end;
         else
            coderror := 1;
            msgerror := 'No existe versión de documento parametrizada para la aplicación: '
                        || pty_cod_app
                        || ' y tipo de documento Política de Tratamiento de Datos';
         end if;

      else
         coderror := 1;
         msgerror := 'El tipo de documento no existe, los tipos válidos son TyC o HD';
      end if;

   end pr_getactualizatyc_hd;
/****************** FIN WFMS5471 ********************************/

end psgen_sndaceptadoctyc_hd;
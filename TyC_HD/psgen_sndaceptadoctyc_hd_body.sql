create or replace package body psgen_sndaceptadoctyc_hd as

   procedure fncu_getdoctyc_hd (
      pty_tipo_doc in adm_version_documentos.tipo_documento%type,
      pty_cod_app  in adm_version_documentos.codigo_app%type,
      coderror     out number,
      msgerror     out varchar2,
      registros    out sys_refcursor
   ) as

      cursor cu_app is
      select count(1)
        from adm_version_documentos
       where codigo_app = pty_cod_app;

      cursor cu_tyc is
      select count(1)
        from adm_version_documentos
       where id = (
         select max(id)
           from adm_version_documentos
          where tipo_documento = 'Términos y Condiciones'
            and codigo_app = pty_cod_app
      );

      cursor cu_hd is
      select count(1)
        from adm_version_documentos
       where id = (
         select max(id)
           from adm_version_documentos
          where tipo_documento = 'Política de Tratamiento de Datos'
            and codigo_app = pty_cod_app
      );

      lty_cantdoc number;
      lty_canttyc number;
      lty_canthd  number;
   begin    

		-- Se consulta si la app tiene documentos parametrizados
      open cu_app;
      fetch cu_app into lty_cantdoc;
      close cu_app;
      if ( lty_cantdoc > 0 ) then
         if ( pty_tipo_doc = 'TyC' ) then

				-- Se consulta si existe al menos un documento parametrizado
            open cu_tyc;
            fetch cu_tyc into lty_canttyc;
            close cu_tyc;
            if ( lty_canttyc > 0 ) then
               open registros for

					   --Select Version, DECOMPOSE(descripcion) descripcion
					   --Select Version, descripcion
                select version,
                                         to_char(
                                                        fecha,
                                                        'dd-mm-yyyy'
                                                     ) fecha,
                                         descripcion
                                                       from adm_version_documentos
                                   where id = (
                                     select max(id)
                                       from adm_version_documentos
                                      where tipo_documento = 'Términos y Condiciones'
                                        and codigo_app = pty_cod_app
                                  );

               coderror := 0;
               msgerror := 'Ok';
            else
               coderror := 3;
               msgerror := 'No existe una version de documento parametrizada para la aplicacion y tipo de documento';
            end if;

         elsif ( pty_tipo_doc = 'HD' ) then

				-- Se consulta si existe al menos un documento parametrizado
            open cu_hd;
            fetch cu_hd into lty_canthd;
            close cu_hd;
            if ( lty_canthd > 0 ) then
               open registros for

					   --Select Version, DECOMPOSE(descripcion) descripcion
					   --Select Version, descripcion
                select version,
                                         to_char(
                                                        fecha,
                                                        'dd-mm-yyyy'
                                                     ) fecha,
                                         descripcion
                                                       from adm_version_documentos
                                   where id = (
                                     select max(id)
                                       from adm_version_documentos
                                      where tipo_documento = 'Política de Tratamiento de Datos'
                                        and codigo_app = pty_cod_app
                                  );

               coderror := 0;
               msgerror := 'Ok';
            else
               coderror := 3;
               msgerror := 'No existe una version de documento parametrizada para la aplicacion y tipo de documento';
            end if;

         else
            coderror := 1;
            msgerror := 'El tipo de documento no existe, los tipos de documentos existentes son TyC/HD';
         end if;
      else
         coderror := 2;
         msgerror := 'La aplicacion no existe o no tiene documentos parametrizados';
      end if;

   end fncu_getdoctyc_hd;

   procedure fncu_getversiondoctyc_hd (
      pty_tipo_id in acepta_terminos_infomedica.tipo_documento%type,
      pty_num_id  in acepta_terminos_infomedica.numero_documento%type,
      pty_cod_app in adm_version_documentos.codigo_app%type,
      coderror    out number,
      msgerror    out varchar2,
      registros   out sys_refcursor
   ) as
   begin
      coderror := 0;
      if ( pty_tipo_id is null
      or pty_tipo_id = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada Tipo Documento Usuario es obligatorio';
      end if;
      if ( pty_num_id is null
      or pty_num_id = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada Numero Documento Usuario es obligatorio';
      end if;
      if ( pty_cod_app is null
      or pty_cod_app = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada Aplicacion es obligatorio';
      end if;

      if ( coderror = 0 ) then
         open registros for select (
                               select version
                                 from adm_version_documentos
                                where id = (
                                  select max(id)
                                    from adm_version_documentos
                                   where tipo_documento = 'Términos y Condiciones'
                                     and codigo_app = pty_cod_app
                               )
                            ) vtycvigente,
                                   (
                                      select version_documento
                                        from acepta_terminos_infomedica
                                       where consecutivo = (
                                         select max(consecutivo)
                                           from acepta_terminos_infomedica
                                          where tipo_documento = pty_tipo_id
                                            and numero_documento = pty_num_id
                                            and nombre_aplicacion = pty_cod_app
                                      )
                                   ) vtycacepta,
                                   (
                                      select to_char(
                                         fecha,
                                         'DD-MM-YYYY'
                                      )
                                        from acepta_terminos_infomedica
                                       where consecutivo = (
                                         select max(consecutivo)
                                           from acepta_terminos_infomedica
                                          where tipo_documento = pty_tipo_id
                                            and numero_documento = pty_num_id
                                            and nombre_aplicacion = pty_cod_app
                                      )
                                   ) fechaaceptatyc,
                                   (
                                      select version
                                        from adm_version_documentos
                                       where id = (
                                         select max(id)
                                           from adm_version_documentos
                                          where tipo_documento = 'Política de Tratamiento de Datos'
                                            and codigo_app = pty_cod_app
                                      )
                                   ) vhdvigente,
                                   (
                                      select version_documento
                                        from acepta_terminos_hd
                                       where consecutivo = (
                                         select max(consecutivo)
                                           from acepta_terminos_hd
                                          where tipo_documento = pty_tipo_id
                                            and numero_documento = pty_num_id
                                            and nombre_aplicacion = pty_cod_app
                                      )
                                   ) vhdacepta,
                                   (
                                      select to_char(
                                         fecha,
                                         'DD-MM-YYYY'
                                      )
                                        from acepta_terminos_hd
                                       where consecutivo = (
                                         select max(consecutivo)
                                           from acepta_terminos_hd
                                          where tipo_documento = pty_tipo_id
                                            and numero_documento = pty_num_id
                                            and nombre_aplicacion = pty_cod_app
                                      )
                                   ) fechaaceptahd
                              from dual;



         coderror := 0;
         msgerror := 'Ok';
      end if;

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
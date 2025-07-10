create or replace package body psgen_snpaceptadoctyc_hd2 as



   procedure pr_aceptdoctyc (
      pty_hora        in acepta_terminos_infomedica.hora%type,
      pty_fecha       in varchar2,
      pty_tipo_doc    in acepta_terminos_infomedica.tipo_documento%type,
      pty_num_doc     in acepta_terminos_infomedica.numero_documento%type,
      pty_nom_usu     in acepta_terminos_infomedica.nombre_completo%type,
      pty_ip          in acepta_terminos_infomedica.dir_ip%type,
      pty_cod_app     in acepta_terminos_infomedica.nombre_aplicacion%type,
      pty_tipo_usu    in acepta_terminos_infomedica.tipo_usuario%type,
      pty_nom_emp     in acepta_terminos_infomedica.nombre_empresa%type,
      pty_version_doc in acepta_terminos_infomedica.version_documento%type,
      coderror        out number,
      msgerror        out varchar2,
      registros       out sys_refcursor
   ) as

      cursor cu_tipo_id is
      select count(1)
        from core_tipo_documentos
       where codigo = pty_tipo_doc;

      ldt_fecha date;
      lvc_hora  varchar2(8);
      lnu_exist number(2) := 0;
      cod_app varchar2(20);
   begin
      coderror := 0;
      if ( pty_tipo_doc is null or pty_tipo_doc = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada Tipo Documento Usuario es obligatorio';
         return;
      else
         open cu_tipo_id;
         fetch cu_tipo_id into lnu_exist;
         close cu_tipo_id;
         if ( lnu_exist = 0 ) then
            coderror := 1;
            msgerror := 'El parametro de entrada Tipo Documento Usuario no es valido';
            return;
         end if;

      end if;

      if ( pty_num_doc is null or pty_num_doc = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada Numero Documento Usuario es obligatorio';
         return;
      end if;

      if ( pty_nom_usu is null or pty_nom_usu = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada Nombre Completo del Usario es obligatorio';
         return;
      end if;

      if ( pty_ip is null or pty_ip = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada Direccion IP es obligatorio';
         return;
      end if;

      if ( pty_cod_app is null or pty_cod_app = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada Codigo Aplicación es obligatorio';
         return;
      end if;

      if ( pty_tipo_usu is null or pty_tipo_usu = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada Tipo Usuario es obligatorio';
         return;
      else
         if ( pty_tipo_usu not in ( 'USUARIO','PRESTADOR','ASESOR' ) ) then
            coderror := 1;
            msgerror := 'El parametro de entrada Tipo Usuario no es valido';
            return;
         end if;
      end if;

      if ( pty_nom_emp is null or pty_nom_emp = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada Nombre Empresa es obligatorio';
         return;
      end if;

      if ( pty_version_doc is null or pty_version_doc = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada Version del Documento es obligatorio';
         return;
      end if;

      if(pty_cod_app='APPMP' or pty_cod_app='OVAWEB' or pty_cod_app='WSP') THEN
         cod_app:='OVU-APPMP-WSP';
      else
         cod_app:=pty_cod_app;
      end if;

      if ( coderror = 0 ) then
         ldt_fecha := to_date ( pty_fecha,'DD/MM/YY' );
         if ( ldt_fecha is null or ldt_fecha = '' ) then
            ldt_fecha := trunc(sysdate);
         end if;

         lvc_hora := pty_hora;
         if ( lvc_hora is null or lvc_hora = '' ) then
            lvc_hora := to_char(sysdate,'HH:MI:SS');
         end if;

         begin
            insert into acepta_terminos_infomedica (
               hora,
               tipo_documento,
               numero_documento,
               nombre_completo,
               dir_ip,
               nombre_aplicacion,
               tipo_usuario,
               nombre_empresa,
               version_documento,
               fecha
            ) values ( lvc_hora,
                       pty_tipo_doc,
                       pty_num_doc,
                       pty_nom_usu,
                       pty_ip,
                       cod_app,
                       pty_tipo_usu,
                       pty_nom_emp,
                       pty_version_doc,
                       ldt_fecha );
            coderror := 0;
            msgerror := 'Ok';
            commit;
         exception
            when others then
               coderror := -1;
               msgerror := sqlerrm;
         end;
      end if;

   end pr_aceptdoctyc;

   procedure pr_aceptdochd (
      pty_hora        in acepta_terminos_infomedica.hora%type,
      pty_fecha       in varchar2,
      pty_tipo_doc    in acepta_terminos_infomedica.tipo_documento%type,
      pty_num_doc     in acepta_terminos_infomedica.numero_documento%type,
      pty_nom_usu     in acepta_terminos_infomedica.nombre_completo%type,
      pty_ip          in acepta_terminos_infomedica.dir_ip%type,
      pty_cod_app     in acepta_terminos_infomedica.nombre_aplicacion%type,
      pty_tipo_usu    in acepta_terminos_infomedica.tipo_usuario%type,
      pty_nom_emp     in acepta_terminos_infomedica.nombre_empresa%type,
      pty_version_doc in acepta_terminos_infomedica.version_documento%type,
      coderror        out number,
      msgerror        out varchar2,
      registros       out sys_refcursor
   ) as

      cursor cu_tipo_id is
      select count(1)
        from core_tipo_documentos
       where codigo = pty_tipo_doc;


      ldt_fecha date;
      lvc_hora  varchar2(8);
      lnu_exist number(2) := 0;
      cod_app varchar2(20);
   begin
      coderror := 0;
      if ( pty_tipo_doc is null or pty_tipo_doc = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada Tipo Documento Usuario es obligatorio';
         return;
      else
         open cu_tipo_id;
         fetch cu_tipo_id into lnu_exist;
         close cu_tipo_id;
         if ( lnu_exist = 0 ) then
            coderror := 1;
            msgerror := 'El parametro de entrada Tipo Documento Usuario no es valido';
            return;
         end if;

      end if;

      if ( pty_num_doc is null or pty_num_doc = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada Numero Documento Usuario es obligatorio';
         return;
      end if;

      if ( pty_nom_usu is null or pty_nom_usu = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada Nombre Completo del Uusario es obligatorio';
         return;
      end if;

      if ( pty_ip is null or pty_ip = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada Direccion IP es obligatorio';
         return;
      end if;

      if ( pty_cod_app is null or pty_cod_app = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada Codigo Aplicación es obligatorio';
         return;
      end if;

      if ( pty_tipo_usu is null or pty_tipo_usu = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada Tipo Usuario es obligatorio';
         return;
      else
         if ( pty_tipo_usu not in ( 'USUARIO','PRESTADOR','ASESOR' ) ) then
            coderror := 1;
            msgerror := 'El parametro de entrada Tipo Usuario no es valido';
            return;
         end if;
      end if;

      if ( pty_nom_emp is null or pty_nom_emp = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada Nombre Empresa es obligatorio';
         return;
      end if;

      if ( pty_version_doc is null or pty_version_doc = '' ) then
         coderror := 5;
         msgerror := 'El parametro de entrada Version del Documento es obligatorio';
         return;
      end if;

      if(pty_cod_app='APPMP' or pty_cod_app='OVAWEB' or pty_cod_app='WSP') THEN
         cod_app:='OVU-APPMP-WSP';
      else
         cod_app:=pty_cod_app;
      end if;

      if ( coderror = 0 ) then
         ldt_fecha := to_date ( pty_fecha,'DD/MM/YY' );
         if ( ldt_fecha is null or ldt_fecha = '' ) then
            ldt_fecha := trunc(sysdate);
         end if;

         lvc_hora := pty_hora;
         if ( lvc_hora is null or lvc_hora = '' ) then
            lvc_hora := to_char( sysdate,'HH:MI:SS');
         end if;

         begin
            insert into acepta_terminos_hd (
               hora,
               tipo_documento,
               numero_documento,
               nombre_completo,
               dir_ip,
               nombre_aplicacion,
               tipo_usuario,
               nombre_empresa,
               version_documento,
               fecha
            ) values ( lvc_hora,
                       pty_tipo_doc,
                       pty_num_doc,
                       pty_nom_usu,
                       pty_ip,
                       cod_app,
                       pty_tipo_usu,
                       pty_nom_emp,
                       pty_version_doc,
                       ldt_fecha );
            coderror := 0;
            msgerror := 'Ok';
            commit;
         exception
            when others then
               coderror := -1;
               msgerror := sqlerrm;
         end;
      end if;

   end pr_aceptdochd;

end psgen_snpaceptadoctyc_hd2;
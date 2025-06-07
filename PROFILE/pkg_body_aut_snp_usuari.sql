create or replace package body aut_snp_usuarios as
   procedure pr_user_status_change (
      p_user        in aut_usuario.documento%type,
      p_status_code in aut_usuario.estado%type,
      p_user_red    in gen_permiso_usuario.usuario%type,
      coderror      out number,
      msgerror      out varchar2,
      registros     out sys_refcursor
   ) is

      cursor cu_usuario is
      select aut.codigo,
             aut.estado
        from aut_usuario aut
       where aut.documento = upper(trim(p_user));

      cursor cu_data (
         pty_cod_usuario aut_usuario.codigo%type
      ) is
      select au.codigo as codigo_app,
             au.estado as estado_app,
             rua.codigo as codigo_rol,
             rua.estado as estado_rol
        from aut_aplicaciones_usuario au
       inner join aut_roles_usuario_aplicacion rua
      on au.codigo = rua.codigo_usuario_aplicacion
       where au.codigo_usuario = pty_cod_usuario;

      lty_data       cu_data%rowtype;
      lty_usuario    cu_usuario%rowtype;
      v_status       aut_aplicaciones_usuario.estado%type;
      v_user_permiso number(1);
      v_user_exist   number(1);
   begin
      if p_user is null
      or trim(p_user) = '' then
         coderror := 5;
         msgerror := 'El parametro de entrada (p_user) es obligatorio';
         return;
      elsif p_status_code is null
      or trim(p_status_code) = '' then
         coderror := 5;
         msgerror := 'El parametro de entrada (p_status_code) es obligatorio';
         return;
      elsif p_user_red is null
      or trim(p_user_red) = '' then
         coderror := 5;
         msgerror := 'El parametro de entrada (p_user_red) es obligatorio';
         return;
      end if;

      select count(*)
        into v_user_permiso
        from gen_permiso_usuario
       where trim(upper(usuario)) = trim(upper(p_user_red))
         and cod_tipo_cambio in ( 13,
                                  14,
                                  15 );

      if v_user_permiso = 0 then
         msgerror := 'El usuario '
                     || p_user_red
                     || ' no tiene permisos para realizar esta operacion!';
         coderror := 5;
         return;
      end if;

      select count(*)
        into v_user_exist
        from aut_usuario autu
       where upper(autu.documento) = upper(p_user);

      if v_user_exist > 0 then
         if to_number ( p_status_code ) = to_number ( 1 ) then
            v_status := 'A';
         else
            v_status := 'I';
         end if;
        -- DBMS_OUTPUT.PUT_LINE('llega v_status: '||v_status||'-p_status_code:'||p_status_code);
         lty_usuario := null;
         open cu_usuario;
         fetch cu_usuario into lty_usuario;
         close cu_usuario;

         -- Inserta la bitacora el cambio de los valores
         insert into gen_bitacora_cambio values ( seq_gen_bitacora_cambio.nextval,
                                                  lty_usuario.codigo,
                                                  13,
                                                  lty_usuario.estado,
                                                  p_status_code,
                                                  sysdate,
                                                  upper(p_user_red) );

         update aut_usuario
            set
            estado = p_status_code
          where codigo = lty_usuario.codigo;

         lty_data := null;
         open cu_data(lty_usuario.codigo);
         loop
            fetch cu_data into lty_data;
            exit when cu_data%notfound;

            -- Inserta la bitacora el cambio de los valores
            insert into gen_bitacora_cambio values ( seq_gen_bitacora_cambio.nextval,
                                                     lty_data.codigo_app,
                                                     14,
                                                     lty_data.estado_app,
                                                     v_status,
                                                     sysdate,
                                                     upper(p_user_red) );

            update aut_aplicaciones_usuario
               set
               estado = v_status
             where codigo = lty_data.codigo_app;

             -- Inserta la bitacora el cambio de los valores
            insert into gen_bitacora_cambio values ( seq_gen_bitacora_cambio.nextval,
                                                     lty_data.codigo_rol,
                                                     15,
                                                     lty_data.estado_rol,
                                                     p_status_code,
                                                     sysdate,
                                                     upper(p_user_red) );

            update aut_roles_usuario_aplicacion
               set
               estado = p_status_code
             where codigo_usuario_aplicacion = lty_data.codigo_app;
         end loop;

         commit;
         open registros for select autu.codigo,
                                   autu.documento,
                                   autu.nombre,
                                   autu.apellido1,
                                   autu.apellido2,
                                   aute.nombre estado
                                                 from aut_usuario autu
                                                inner join aut_estado aute
                                               on autu.estado = aute.codigo
                             where autu.documento = upper(p_user);

         coderror := 0;
         msgerror := 'Ok';
      else
         coderror := 5;
         msgerror := 'El usuario no está registrado en el PROFILE!';
      end if;
   exception
      when others then
         dbms_output.put_line('ERROR: ' || sqlerrm);
         rollback;
   end;

end;
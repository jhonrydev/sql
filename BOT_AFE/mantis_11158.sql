-- pruebas sao

select *
  from api_afemp_p_tipo_devoluciones;

/**
* tabla de configuración de estados de devoluciones
*/
select *
  from api_afemp_p_devoluciones
--  where estado = 'activo'
 order by descripcion;

select * from AUT_ROLES;


select *
  from api_afemp_bitacorasolicitud
 where id = 6847;

/**
* tabla donde se guardan las devoluciones 
*/
select *
  from api_afemp_devolucion
 where id_step1 in ( 6847 );

-- delete from api_afemp_devolucion
--  where id_step1 = 6842;

commit;

/**
* tabla donde se guarda las ordenes
*/
select *
  from api_afemp_step1
 where id in ( 6842,
               6837 );

update api_afemp_step1
   set
   codigo_estado = 24
 where id = 6842;

commit;

/**
* tabla de estados de ordenes
*/
select *
  from api_afemp_p_estados
 where codigo in ( 9,
                   14,
                   24 );

select *  from gen_bitacora_cambio;
select *  from gen_modulo;
select *  from gen_permiso_usuario;
select *  from gen_tipo_Cambio;


select *
  from api_afemp_bitacorasolicitud
 where id = 6847;

select *
  from api_afemp_devolucion
 where id_step1 in ( 6847 );

 SELECT * FROM gen_tipo_cambio order by COD_TIPO_CAMBIO;

select *--id,       codigo_estado
  from api_afemp_step1
 where id in ( 6819 );

 DESCRIBE api_afemp_step1;
 DESCRIBE api_afemp_step2;

DESCRIBE API_AFEMP_BITACORASOLICITUD;

 --==--=====================================================================================================
   procedure pr_cambio_motivo_devolucion (
      prm_usuario       in varchar2,
      prm_solicitud_afe in varchar2,
      prm_motivo_actual in varchar2,
      prm_motivo_nuevo  in varchar2,
      prm_observacion   in varchar2,
      coderror          out number,
      msgerror          out varchar2,
      registros         out sys_refcursor
   ) as

      -- Obtiene la devolución a modifica
      cursor cu_devolucion_a_modificar(
         orden api_afemp_devolucion.id_step1%type,
         codigo_devolucion api_afemp_devolucion.codigo_devolucion%type
         ) is
      select id_step1,
             codigo_devolucion,
             observaciones 
      from api_afemp_devolucion
      where id_step1 = orden 
      and codigo_devolucion=codigo_devolucion;

      -- Obtiene todos los estados de devolución que puede tener una afiliación
      cursor cu_estados_devolucion (
         codigo_devolucion varchar2
      ) is
      select codigo, descripcion
        from api_afemp_p_devoluciones
       where estado='activo' 
       and codigo = codigo_devolucion;

      -- Obtiene los permisos que tiene un usuario para hacer cambios desde la Macro
      cursor cu_permiso_fn_macro is
      select count(1) as permisos_fn
        from gen_permiso_usuario
       where upper(usuario) = upper(prm_usuario)
         and cod_tipo_cambio in (16,17,18,19,20,21,22,23);

      -- Obtiene los roles asignados al usuario desde el PROFILE para ejecutar la Macro
      cursor cu_role_user_profile_macro(usuario varchar2) is
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
       where upper(trim(au.documento)) = upper(trim(usuario))
         and upper(trim(aa.aplicativo)) = upper(trim('Macro actualiza datos'))
         and trim(aau.estado) = 'A'
         and au.estado = 1
         and ar.estado = 1
         and arua.estado = 1;

      v_info_devolucion             cu_devolucion_a_modificar%rowtype;
      v_info_devolucion_orden       api_afemp_devolucion.id_step1%type;
      v_info_devolucion_observacion       api_afemp_devolucion.observaciones%type;

      v_info_devolucion_actual       cu_estados_devolucion%rowtype;
      v_motivo_devolucion_actual        api_afemp_p_devoluciones.codigo%type;
      v_info_devolucion_nuevo       cu_estados_devolucion%rowtype;
      v_motivo_devolucion_nuevo        api_afemp_p_devoluciones.codigo%type;

      v_roles_usuario_macro  cu_role_user_profile_macro%rowtype;
      v_role_usuario_macro       number(1) := 0;

      v_permisos_usuario_macro   cu_permiso_fn_macro%rowtype;
      v_permisos_fn              number(1) :=0;
   begin

      -- open registros for 
      --    select * from api_afemp_devolucion
      --    where id_step1 = prm_solicitud_afe 
      --    and codigo_devolucion=prm_motivo_actual;

      -- coderror := 0;
      -- msgerror := 'Motivo actualizado exitosamente!';
      -- return;

      if ( prm_usuario is null or prm_usuario = '' ) then
         msgerror := 'El campo (prm_usuario) es requerido';
         coderror := 5;
         return;
      else
         open cu_role_user_profile_macro(prm_usuario);
         loop
            fetch cu_role_user_profile_macro into v_roles_usuario_macro;
            exit when cu_role_user_profile_macro%notfound;
            if ( trim(v_roles_usuario_macro.clave) = 'ROLE_CAMBIO_MOTIVO_DEVOLUCION_AFE' ) then
               v_role_usuario_macro := 1;
               exit;
            end if;
         end loop;
         close cu_role_user_profile_macro;

         -- if (v_role_usuario_macro <> 1) then
         if (v_role_usuario_macro = 1) then
            msgerror := 'El usuario ('|| prm_usuario||') no tiene permisos para ejecutar esta función';
            coderror := 5;
            return;
         end if;

      end if;

      if ( prm_motivo_actual is null or prm_motivo_actual = '' ) then
         msgerror := 'El campo (prm_motivo_actual) es requerido';
         coderror := 5;
         return;
      else

         open cu_estados_devolucion(prm_motivo_actual);
         fetch cu_estados_devolucion into v_info_devolucion_actual;
         close cu_estados_devolucion;

         if ( v_info_devolucion_actual.codigo is null ) then
            msgerror := 'El motivo actual no coincide con el del registrado';
            -- msgerror := 'El motivo de devolución (' ||prm_motivo_actual|| ') no es valido!';
            coderror := 5;
            return;
         else
            v_motivo_devolucion_actual := v_info_devolucion_actual.codigo;
         end if;
      end if;

      if ( prm_motivo_nuevo is null or prm_motivo_nuevo = '' ) then
         msgerror := 'El campo (prm_motivo_nuevo) es requerido';
         coderror := 5;
         return;
      else

         open cu_estados_devolucion(prm_motivo_nuevo);
         fetch cu_estados_devolucion into v_info_devolucion_nuevo;
         close cu_estados_devolucion;

         if ( v_info_devolucion_actual.codigo is null ) then
            msgerror := 'El motivo de devolución (' ||prm_motivo_nuevo|| ') no es valido!';
            coderror := 5;
            return;
         else
            v_motivo_devolucion_nuevo := v_info_devolucion_nuevo.codigo;
         end if;
      end if;

      if ( prm_solicitud_afe is null or prm_solicitud_afe = '' ) then
         msgerror := 'El campo (prm_solicitud_afe) es requerido';
         coderror := 5;
         return;
      else
         open cu_devolucion_a_modificar(prm_solicitud_afe,prm_motivo_actual);
         fetch cu_devolucion_a_modificar into v_info_devolucion;
         close cu_devolucion_a_modificar;

         if ( v_info_devolucion.id_step1 <> prm_solicitud_afe ) then
            msgerror := 'No se encontró la orden AFE '||prm_solicitud_afe;
            coderror := 5;
            return;
         elsif( v_info_devolucion.codigo_devolucion <> prm_motivo_actual ) then
            msgerror := 'El motivo de devolucion (' ||prm_motivo_actual|| ') no corresponde al actual';
            coderror := 5;
            return;
         elsif(v_info_devolucion.id_step1 = prm_solicitud_afe and v_info_devolucion.codigo_devolucion = prm_motivo_actual )then
            v_info_devolucion_orden       := v_info_devolucion.id_step1;
            v_info_devolucion_observacion   := v_info_devolucion.observaciones;
         end if;

      end if;

     open cu_permiso_fn_macro;
     fetch cu_permiso_fn_macro into v_permisos_usuario_macro;
     close cu_permiso_fn_macro;

      if ( v_permisos_usuario_macro.permisos_fn = 0 ) then
         msgerror := 'Usuario sin permisos para esta función';
         coderror := 5;
         return;
      else
         -- Actualiza el motivo de devolución
         update api_afemp_devolucion
            set
            codigo_devolucion = v_motivo_devolucion_nuevo,
            observaciones     = prm_observacion
          where id_step1 = v_info_devolucion_orden
          and codigo_devolucion= v_motivo_devolucion_actual; 
   commit;
         -- Actualizar la bitacoras
         insert into API_AFEMP_BITACORASOLICITUD values ( 
                                                  (SELECT max(COD_BITACORA_SOLICITUD)+1 from API_AFEMP_BITACORASOLICITUD),
                                                  prm_solicitud_afe,
                                                  13,
                                                  v_motivo_devolucion_actual, 
                                                  v_motivo_devolucion_nuevo,
                                                  prm_usuario,
                                                  'Cambio realizado por Macro',
                                                  sysdate
                                                   );

         insert into gen_bitacora_cambio values ( 
                                                   seq_gen_bitacora_cambio.nextval,
                                                   (v_info_devolucion.id_step1||'-'||v_info_devolucion.codigo_devolucion),
                                                  16,
                                                  v_motivo_devolucion_actual,
                                                  v_motivo_devolucion_nuevo, 
                                                  sysdate,
                                                  prm_usuario );

         insert into gen_bitacora_cambio values ( 
                                                   seq_gen_bitacora_cambio.nextval,
                                                   (v_info_devolucion.id_step1||'-'||v_info_devolucion.codigo_devolucion),
                                                  17,
                                                  v_info_devolucion_observacion,
                                                  prm_observacion, 
                                                  sysdate,
                                                  prm_usuario );

         insert into gen_bitacora_cambio values ( 
                                                   seq_gen_bitacora_cambio.nextval,
                                                   (SELECT max(COD_BITACORA_SOLICITUD) from API_AFEMP_BITACORASOLICITUD),
                                                  18,
                                                  null,
                                                  prm_solicitud_afe, 
                                                  sysdate,
                                                  prm_usuario );

         insert into gen_bitacora_cambio values ( 
                                                   seq_gen_bitacora_cambio.nextval,
                                                   (SELECT max(COD_BITACORA_SOLICITUD) from API_AFEMP_BITACORASOLICITUD),
                                                  19,
                                                  null,
                                                  13, 
                                                  sysdate,
                                                  prm_usuario );

         insert into gen_bitacora_cambio values ( 
                                                   seq_gen_bitacora_cambio.nextval,
                                                   (SELECT max(COD_BITACORA_SOLICITUD) from API_AFEMP_BITACORASOLICITUD),
                                                  20,
                                                  null,
                                                  v_motivo_devolucion_actual, 
                                                  sysdate,
                                                  prm_usuario );

         insert into gen_bitacora_cambio values ( 
                                                   seq_gen_bitacora_cambio.nextval,
                                                   (SELECT max(COD_BITACORA_SOLICITUD) from API_AFEMP_BITACORASOLICITUD),
                                                  21,
                                                  null,
                                                  v_motivo_devolucion_nuevo, 
                                                  sysdate,
                                                  prm_usuario );

         insert into gen_bitacora_cambio values ( 
                                                   seq_gen_bitacora_cambio.nextval,
                                                   (SELECT max(COD_BITACORA_SOLICITUD) from API_AFEMP_BITACORASOLICITUD),
                                                  22,
                                                  null,
                                                  prm_usuario, 
                                                  sysdate,
                                                  prm_usuario );

         insert into gen_bitacora_cambio values ( 
                                                   seq_gen_bitacora_cambio.nextval,
                                                   (SELECT max(COD_BITACORA_SOLICITUD) from API_AFEMP_BITACORASOLICITUD),
                                                  23,
                                                  null,
                                                  'Cambio realizado por Macro', 
                                                  sysdate,
                                                  prm_usuario );

         commit;
      end if;

      open registros for 
         select * from api_afemp_devolucion
         where id_step1 = prm_solicitud_afe 
         and codigo_devolucion=prm_motivo_actual;

      msgerror := 'Motivo actualizado exitosamente!';
      coderror := 0;
   end pr_cambio_motivo_devolucion;
--=====================================================================================================
   procedure pr_cambio_motivo_devolucion (
      prm_usuario       in varchar2,
      prm_solicitud_afe in varchar2,
      prm_motivo_actual in varchar2,
      prm_motivo_nuevo  in varchar2,
      prm_observacion   in varchar2,
      coderror          out number,
      msgerror          out varchar2,
      registros         out sys_refcursor
   ) as

      -- Obtiene la devolución a modifica
      cursor cu_devolucion_a_modificar(
         orden api_afemp_devolucion.id_step1%type,
         codigo_devolucion api_afemp_devolucion.codigo_devolucion%type
         ) is
      select id_step1,
             codigo_devolucion,
             observaciones 
      from api_afemp_devolucion
      where id_step1 = orden 
      and codigo_devolucion=codigo_devolucion;

      -- Obtiene todos los estados de devolución que puede tener una afiliación
      cursor cu_estados_devolucion (
         codigo_devolucion varchar2
      ) is
      select codigo, descripcion
        from api_afemp_p_devoluciones
       where estado='activo' 
       and codigo = codigo_devolucion;

      -- Obtiene los permisos que tiene un usuario para hacer cambios desde la Macro
      cursor cu_permiso_fn_macro(usuario aut_usuario.documento%type) is
      select count(1) as permisos_fn
        from gen_permiso_usuario
       where upper(usuario) = upper(usuario)
         and cod_tipo_cambio in (16,17,18,19,20,21,22,23);

      -- Obtiene los roles asignados al usuario desde el PROFILE para ejecutar la Macro
      cursor cu_role_user_profile_macro(usuario varchar2) is
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
       where upper(trim(au.documento)) = upper(trim(usuario))
         and upper(trim(aa.aplicativo)) = upper(trim('Macro actualiza datos'))
         and trim(aau.estado) = 'A'
         and au.estado = 1
         and ar.estado = 1
         and arua.estado = 1;

      v_info_devolucion             cu_devolucion_a_modificar%rowtype;
      v_info_devolucion_orden       api_afemp_devolucion.id_step1%type;
      v_info_devolucion_observacion       api_afemp_devolucion.observaciones%type;

      v_info_devolucion_actual       cu_estados_devolucion%rowtype;
      v_motivo_devolucion_actual_id        api_afemp_p_devoluciones.codigo%type;
      v_motivo_devolucion_actual_des        api_afemp_p_devoluciones.descripcion%type;
      v_motivo_actual_id      number(10);--  api_afemp_p_devoluciones.codigo%type;

      v_info_devolucion_nuevo       cu_estados_devolucion%rowtype;
      v_motivo_devolucion_nuevo_id        api_afemp_p_devoluciones.codigo%type;
      v_motivo_devolucion_nuevo_desc        api_afemp_p_devoluciones.descripcion%type;
      v_motivo_nuevo_id       number(10);-- api_afemp_p_devoluciones.codigo%type;

      v_roles_usuario_macro  cu_role_user_profile_macro%rowtype;
      v_role_usuario_macro       number(1) := 0;

      v_permisos_usuario_macro   cu_permiso_fn_macro%rowtype;
      v_usuario              aut_usuario.documento%type;
   begin

      coderror := 0;

      if ( prm_usuario is null or prm_usuario = '' ) then
         msgerror := 'El campo (prm_usuario) es requerido';
         coderror := 5;
         return;
      else
         -- prm_usuario:=upper(trim(prm_usuario));
         open cu_role_user_profile_macro(prm_usuario);
         loop
            fetch cu_role_user_profile_macro into v_roles_usuario_macro;
            exit when cu_role_user_profile_macro%notfound;
            if ( trim(v_roles_usuario_macro.clave) = 'ROLE_CAMBIO_MOTIVO_DEVOLUCION_AFE' ) then
               v_role_usuario_macro := 1;
               exit;
            end if;
         end loop;
         close cu_role_user_profile_macro;

         if (v_role_usuario_macro <> 1) then
            msgerror := 'El usuario ('|| prm_usuario||') no tiene permisos para ejecutar esta función';
            coderror := 5;
            return;
         end if;

      end if;

      if ( prm_motivo_actual is null or prm_motivo_actual = '' ) then
         msgerror := 'El campo (prm_motivo_actual) es requerido';
         coderror := 5;
         return;
      else

         v_motivo_actual_id:= to_char(trim(substr(
            prm_motivo_actual,
            0,
            instr(
                    prm_motivo_actual,
                    '-'
                 ) - 1
         )));

         open cu_estados_devolucion(v_motivo_actual_id);
         fetch cu_estados_devolucion into v_info_devolucion_actual;
         if ( cu_estados_devolucion%notfound ) then
          v_info_devolucion_actual.codigo := null;
         end if;
         close cu_estados_devolucion;


         if ( v_info_devolucion_actual.codigo is null ) then
            msgerror := 'El motivo (prm_motivo_actual) no es válido';
            coderror := 5;
            return;
         else
            v_motivo_devolucion_actual_id := v_info_devolucion_actual.codigo;
            v_motivo_devolucion_actual_des := v_info_devolucion_actual.descripcion;
         end if;
      end if;

      if ( prm_motivo_nuevo is null or prm_motivo_nuevo = '' ) then
         msgerror := 'El campo (prm_motivo_nuevo) es requerido';
         coderror := 5;
         return;
      else

         v_motivo_nuevo_id:= to_char(trim(substr(
            prm_motivo_nuevo,
            0,
            instr(
                    prm_motivo_nuevo,
                    '-'
                 ) - 1
         )));

         open cu_estados_devolucion(v_motivo_nuevo_id);
         fetch cu_estados_devolucion into v_info_devolucion_nuevo;
         if ( cu_estados_devolucion%notfound ) then
          v_info_devolucion_nuevo.codigo := null;
         end if;
         close cu_estados_devolucion;

         if ( v_info_devolucion_nuevo.codigo is null ) then
            msgerror := 'El motivo de devolución (' ||prm_motivo_nuevo|| ') no es valido!';
            coderror := 5;
            return;
         else
            v_motivo_devolucion_nuevo_id := v_info_devolucion_nuevo.codigo;
            v_motivo_devolucion_nuevo_desc := v_info_devolucion_nuevo.descripcion;
         end if;
      end if;

      if ( prm_solicitud_afe is null or prm_solicitud_afe = '' ) then
         msgerror := 'El campo (prm_solicitud_afe) es requerido';
         coderror := 5;
         return;
      else
         open cu_devolucion_a_modificar(prm_solicitud_afe,v_motivo_actual_id);
         fetch cu_devolucion_a_modificar into v_info_devolucion;
         close cu_devolucion_a_modificar;

         if ( v_info_devolucion.id_step1 <> prm_solicitud_afe ) then
            msgerror := 'No se encontró la orden AFE '||prm_solicitud_afe;
            coderror := 5;
            return;
         elsif( v_info_devolucion.codigo_devolucion <> v_motivo_actual_id ) then
            msgerror := 'El motivo de devolucion (' ||prm_motivo_actual|| ') no corresponde al actual';
            coderror := 5;
            return;
         elsif(v_info_devolucion.id_step1 = prm_solicitud_afe and v_info_devolucion.codigo_devolucion = v_motivo_actual_id )then
            v_info_devolucion_orden       := v_info_devolucion.id_step1;
            v_info_devolucion_observacion   := v_info_devolucion.observaciones;
         end if;

      end if;

      if(prm_observacion is null or prm_observacion='')then
         msgerror := 'El campo (prm_observacion) es requerido';
         coderror := 5;
         return;
      end if;

     open cu_permiso_fn_macro(v_usuario);
     fetch cu_permiso_fn_macro into v_permisos_usuario_macro;
     close cu_permiso_fn_macro;

      if ( v_permisos_usuario_macro.permisos_fn = 0 ) then
         msgerror := 'Usuario sin permisos para esta función';
         coderror := 5;
         return;
      else
         -- Actualiza el motivo de devolución
         update api_afemp_devolucion
            set
            codigo_devolucion = v_motivo_devolucion_nuevo_id,
            observaciones     = prm_observacion
          where id_step1 = v_info_devolucion_orden
          and codigo_devolucion= v_motivo_devolucion_actual_id; 

         -- Actualizar la bitacoras
         insert into api_afemp_bitacorasolicitud values ( 
                                                  afemp_seq__bitacora_solicitud.NEXTVAL,
                                                  prm_solicitud_afe,
                                                  13,
                                                  v_motivo_devolucion_actual_des, 
                                                  v_motivo_devolucion_nuevo_desc,
                                                  prm_usuario,
                                                  'Cambio realizado desde la Macro',
                                                  sysdate
                                                   );

         insert into gen_bitacora_cambio values ( 
                                                   seq_gen_bitacora_cambio.nextval,
                                                   (v_info_devolucion.id_step1||'-'||v_info_devolucion.codigo_devolucion),
                                                  16,
                                                  v_motivo_devolucion_actual_id,
                                                  v_motivo_devolucion_nuevo_id, 
                                                  sysdate,
                                                  prm_usuario );

         insert into gen_bitacora_cambio values ( 
                                                   seq_gen_bitacora_cambio.nextval,
                                                   (v_info_devolucion.id_step1||'-'||v_info_devolucion.codigo_devolucion),
                                                  17,
                                                  v_info_devolucion_observacion,
                                                  prm_observacion, 
                                                  sysdate,
                                                  prm_usuario );

         insert into gen_bitacora_cambio values ( 
                                                   seq_gen_bitacora_cambio.nextval,
                                                   (SELECT max(COD_BITACORA_SOLICITUD) from API_AFEMP_BITACORASOLICITUD),
                                                  18,
                                                  null,
                                                  prm_solicitud_afe, 
                                                  sysdate,
                                                  prm_usuario );

         insert into gen_bitacora_cambio values ( 
                                                   seq_gen_bitacora_cambio.nextval,
                                                   (SELECT max(COD_BITACORA_SOLICITUD) from API_AFEMP_BITACORASOLICITUD),
                                                  19,
                                                  null,
                                                  13, 
                                                  sysdate,
                                                  prm_usuario );

         insert into gen_bitacora_cambio values ( 
                                                   seq_gen_bitacora_cambio.nextval,
                                                   (SELECT max(COD_BITACORA_SOLICITUD) from API_AFEMP_BITACORASOLICITUD),
                                                  20,
                                                  null,
                                                  v_motivo_devolucion_actual_id, 
                                                  sysdate,
                                                  prm_usuario );

         insert into gen_bitacora_cambio values ( 
                                                   seq_gen_bitacora_cambio.nextval,
                                                   (SELECT max(COD_BITACORA_SOLICITUD) from API_AFEMP_BITACORASOLICITUD),
                                                  21,
                                                  null,
                                                  v_motivo_devolucion_nuevo_id, 
                                                  sysdate,
                                                  prm_usuario );

         insert into gen_bitacora_cambio values ( 
                                                   seq_gen_bitacora_cambio.nextval,
                                                   (SELECT max(COD_BITACORA_SOLICITUD) from API_AFEMP_BITACORASOLICITUD),
                                                  22,
                                                  null,
                                                  prm_usuario, 
                                                  sysdate,
                                                  prm_usuario );

         insert into gen_bitacora_cambio values ( 
                                                   seq_gen_bitacora_cambio.nextval,
                                                   (SELECT max(COD_BITACORA_SOLICITUD) from API_AFEMP_BITACORASOLICITUD),
                                                  23,
                                                  null,
                                                  'Cambio realizado por Macro', 
                                                  sysdate,
                                                  prm_usuario );

         commit;
      end if;

      open registros for 
         select id_step1 as orden_afe,
                codigo_devolucion,
                observaciones 
         from api_afemp_devolucion
         where id_step1 = prm_solicitud_afe 
         and codigo_devolucion=v_motivo_nuevo_id;

      msgerror := 'Motivo actualizado exitosamente!';
      coderror := 0;
   end pr_cambio_motivo_devolucion;
--=====================================================================================================

-- psgen_snpinsumobotafe.pr_ajusteestadosolicafe
/*
JIMB8316
6819
767 - Pago con otra CC
769 - Falla tecnológica
Nueva Observación
*/

SELECT * FROM api_afemp_devolucion where id_step1=6819;
SELECT * FROM api_afemp_bitacorasolicitud where id=6819;
SELECT * FROM gen_tipo_cambio order by cod_tipo_cambio desc;
SELECT * FROM gen_bitacora_cambio order by cod_biracora_cambio desc;


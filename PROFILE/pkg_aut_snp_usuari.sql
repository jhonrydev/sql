create or replace package aut_snp_usuarios as
   procedure pr_user_status_change (
      p_user        in aut_usuario.documento%type,
      p_status_code in aut_usuario.estado%type,
      p_user_red    in gen_permiso_usuario.usuario%type,
      coderror      out number,
      msgerror      out varchar2,
      registros     out sys_refcursor
   );
end; 
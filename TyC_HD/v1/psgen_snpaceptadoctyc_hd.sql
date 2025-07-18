create or replace package psgen_snpaceptadoctyc_hd as
   /* -----------------------------------------------------------------------------
   Copyright ¿Coomeva S.A. - Colombia
   Package : PSGEN_SNPAceptaDocTyC_HD
   Caso de Uso :
   Descripci¿ :  Obtiene versiones y documentos de TyC y HD
   -------------------------------------------------------------------------------
   Autor : 
   Fecha : 15-10-2023
   -------------------------------------------------------------------------------
   Procedimiento : Descripcion:
   -------------------------------------------------------------------------------
   Historia de Modificaciones
   -------------------------------------------------------------------------------
   Fecha Autor Modificaci¿
   ------------------------------------------------------------------------------*/
   type type_cursor is ref cursor;
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
   );

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
   );

end psgen_snpaceptadoctyc_hd;
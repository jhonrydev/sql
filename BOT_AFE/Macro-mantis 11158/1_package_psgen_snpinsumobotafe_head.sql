create or replace package psgen_snpinsumobotafe as
   /* -----------------------------------------------------------------------------
   Copyright ¿Coomeva S.A. - Colombia
   Package : PSGEN_SNPInsumoBotAFE
   Caso de Uso :
   Descripci¿ :  Procedimientos gestionar el insumo del BOT de AFE
   -------------------------------------------------------------------------------
   Autor : 
   Fecha : 30-05-2024
   -------------------------------------------------------------------------------
   Procedimiento : Descripcion:
   -------------------------------------------------------------------------------
   Historia de Modificaciones
   -------------------------------------------------------------------------------
   Fecha Autor Modificaci¿
   ------------------------------------------------------------------------------*/
   type type_cursor is ref cursor;
   procedure ajustacuotamesafe (
      prm_solicitud_afe in varchar2,
      prm_cuota         in number,
      prm_usuario       in varchar2,
      coderror          out number,
      msgerror          out varchar2,
      registros         out sys_refcursor
   );

   procedure ajustatarifarioafe (
      prm_solicitud_afe in varchar2,
      prm_tarifario     in varchar2,
      prm_usuario       in varchar2,
      coderror          out number,
      msgerror          out varchar2,
      registros         out sys_refcursor
   );

   procedure pr_ajustainsumobotafe (
      prm_solicitudes_afe in varchar2,
      prm_estado          in varchar2,
      prm_observaciones   in varchar2,
      prm_intentos        in varchar2,
      prm_usuario         in varchar2,
      coderror            out number,
      msgerror            out varchar2,
      registros           out sys_refcursor
   );

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
   );

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
   );

   procedure pr_ajusteestadosolicafe (
      prm_solicitud_afe in varchar2,
      prm_codigo_estado in varchar2,
      prm_usuario       in varchar2,
      coderror          out number,
      msgerror          out varchar2,
      registros         out sys_refcursor
   );

   procedure pr_envio_reporte_afe (
      coderror  out number,
      msgerror  out varchar2,
      registros out sys_refcursor
   );

   procedure pr_cambio_motivo_devolucion (
      prm_usuario_red   in varchar2,
      prm_solicitud_afe in varchar2,
      prm_motivo_actual in varchar2,
      prm_motivo_nuevo  in varchar2,
      prm_observacion   in varchar2,
      coderror          out number,
      msgerror          out varchar2,
      registros         out sys_refcursor
   );
end psgen_snpinsumobotafe;
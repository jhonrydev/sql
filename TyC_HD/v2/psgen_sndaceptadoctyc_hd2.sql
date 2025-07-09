create or replace PACKAGE           PSGEN_SNDAceptaDocTyC_HD2
AS
   /* -----------------------------------------------------------------------------
   Copyright ¿Coomeva S.A. - Colombia
   Package : PSGEN_SNDAceptaDocTyC_HD
   Caso de Uso :
   Descripci¿ : Obtiene, versiones y documentos de TyC y HD, se adiciona la 
                actualizacion y guardado de Tyc y HD
   -------------------------------------------------------------------------------
   Autor : 
   Fecha : 15-10-2023
   -------------------------------------------------------------------------------
   Procedimiento : Descripcion:
   -------------------------------------------------------------------------------
   Historia de Modificaciones: Se adiciona guardado y actualizacion Tyc y HD
   -------------------------------------------------------------------------------
   Fecha Autor Modificacion 26/09/2024 WFMS5471
   ------------------------------------------------------------------------------*/
   TYPE TYPE_CURSOR IS REF CURSOR;

  PROCEDURE fncu_getDocTyC_HD(pty_tipo_doc    IN ADM_VERSION_DOCUMENTOS.tipo_documento%type,
							  pty_cod_app     IN ADM_VERSION_DOCUMENTOS.codigo_app%type,
						      codError OUT NUMBER,
						      msgError OUT VARCHAR2,
						      registros OUT SYS_REFCURSOR);

  PROCEDURE fncu_getVersionDocTyC_HD(pty_tipo_id    IN ACEPTA_TERMINOS_INFOMEDICA.TIPO_DOCUMENTO%type,
							         pty_num_id     IN ACEPTA_TERMINOS_INFOMEDICA.NUMERO_DOCUMENTO%TYPE,
							         pty_cod_app    IN ADM_VERSION_DOCUMENTOS.codigo_app%type,
						             codError   OUT NUMBER,
						             msgError OUT VARCHAR2,
						             registros OUT SYS_REFCURSOR);

  /* Creados por WFMS5471 para consumo del nuevo ADM*/

  PROCEDURE pr_getListaAppTyC_HD(codError         OUT NUMBER,
  					             msgError         OUT VARCHAR2,
						         registros        OUT SYS_REFCURSOR);

  PROCEDURE pr_getGuardaTyC_HD(pty_tipo_doc       IN ADM_VERSION_DOCUMENTOS.tipo_documento%type,
 						       pty_cod_app        IN ADM_VERSION_DOCUMENTOS.codigo_app%type,
                               prm_usuario        IN ADM_VERSION_DOCUMENTOS.usuario%type,
                               prm_descripcion    IN ADM_VERSION_DOCUMENTOS.descripcion%type,
						       codError           OUT NUMBER,
                               msgError           OUT VARCHAR2,
						       registros          OUT SYS_REFCURSOR);

  PROCEDURE pr_getActualizaTyC_HD(pty_tipo_doc  IN ADM_VERSION_DOCUMENTOS.tipo_documento%type,
 						          pty_cod_app     IN ADM_VERSION_DOCUMENTOS.codigo_app%type,
                                  prm_descripcion    IN ADM_VERSION_DOCUMENTOS.descripcion%type,
                                  codError        OUT NUMBER,
                                  msgError        OUT VARCHAR2,
                                  registros       OUT SYS_REFCURSOR);


 END PSGEN_SNDAceptaDocTyC_HD2;
--------------------------------------------------------
-- Archivo creado  - miércoles-julio-09-2025   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package PSGEN_SNPACEPTADOCTYC_HD
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "SALUDMP"."PSGEN_SNPACEPTADOCTYC_HD" 
AS
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
   TYPE TYPE_CURSOR IS REF CURSOR;


  PROCEDURE pr_aceptDocTyC   (  pty_hora        IN ACEPTA_TERMINOS_INFOMEDICA.HORA%TYPE,                                    
                                pty_fecha       IN VARCHAR2,
                                pty_tipo_doc    IN ACEPTA_TERMINOS_INFOMEDICA.TIPO_DOCUMENTO%type,
							    pty_num_doc     IN ACEPTA_TERMINOS_INFOMEDICA.NUMERO_DOCUMENTO%TYPE,
							    pty_nom_usu     IN ACEPTA_TERMINOS_INFOMEDICA.NOMBRE_COMPLETO%TYPE,
								pty_ip          IN ACEPTA_TERMINOS_INFOMEDICA.DIR_IP%TYPE, 
								pty_cod_app     IN ACEPTA_TERMINOS_INFOMEDICA.NOMBRE_APLICACION%TYPE, 
								pty_tipo_usu    IN ACEPTA_TERMINOS_INFOMEDICA.TIPO_USUARIO%TYPE,
								pty_nom_emp     IN ACEPTA_TERMINOS_INFOMEDICA.NOMBRE_EMPRESA%TYPE, 
								pty_version_doc IN ACEPTA_TERMINOS_INFOMEDICA.VERSION_DOCUMENTO%TYPE, 
								codError        OUT NUMBER,
						        msgError        OUT VARCHAR2,
						        registros       OUT SYS_REFCURSOR);

  PROCEDURE pr_aceptDocHD    (  pty_hora        IN ACEPTA_TERMINOS_INFOMEDICA.HORA%TYPE,                                    
                                pty_fecha       IN VARCHAR2,
                                pty_tipo_doc    IN ACEPTA_TERMINOS_INFOMEDICA.TIPO_DOCUMENTO%type,
							    pty_num_doc     IN ACEPTA_TERMINOS_INFOMEDICA.NUMERO_DOCUMENTO%TYPE,
							    pty_nom_usu     IN ACEPTA_TERMINOS_INFOMEDICA.NOMBRE_COMPLETO%TYPE,
								pty_ip          IN ACEPTA_TERMINOS_INFOMEDICA.DIR_IP%TYPE, 
								pty_cod_app     IN ACEPTA_TERMINOS_INFOMEDICA.NOMBRE_APLICACION%TYPE, 
								pty_tipo_usu    IN ACEPTA_TERMINOS_INFOMEDICA.TIPO_USUARIO%TYPE,
								pty_nom_emp     IN ACEPTA_TERMINOS_INFOMEDICA.NOMBRE_EMPRESA%TYPE, 
								pty_version_doc IN ACEPTA_TERMINOS_INFOMEDICA.VERSION_DOCUMENTO%TYPE, 
								codError        OUT NUMBER,
						        msgError        OUT VARCHAR2,
						        registros       OUT SYS_REFCURSOR);

 END PSGEN_SNPAceptaDocTyC_HD;

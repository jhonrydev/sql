CREATE OR REPLACE PACKAGE VDIR_PACK_BANDEJA_OPERACIONES AS
/* ---------------------------------------------------------------------
 Copyright  Tecnología Informática Coomeva - Colombia
 Package     : VDIR_PACK_BANDEJA_OPERACIONES
 Caso de Uso : 
 Descripción : Procesos para realizar la gestión de la bandeja de 
               operaciones
 --------------------------------------------------------------------
 Autor : katherine.latorre@kalettre.com
 Fecha : 14-02-2018  
 --------------------------------------------------------------------
 Procedimiento :     Descripcion:
 --------------------------------------------------------------------
 Historia de Modificaciones
 ---------------------------------------------------------------------
 Fecha Autor Modificación
 ----------------------------------------------------------------- */
 
	-- ---------------------------------------------------------------------
	-- Declaracion de estructuras dinamicas
	-- ---------------------------------------------------------------------
	TYPE type_cursor IS REF CURSOR;
 
    -- ---------------------------------------------------------------------
	-- prGuardarBitacora
	-- ---------------------------------------------------------------------
	PROCEDURE prGuardarBitacora
	(
		inu_codAfiliacion    IN VDIR_BITACORA_SOLICITUD.COD_AFILIACION%TYPE, 
		inu_codUsuario       IN VDIR_BITACORA_SOLICITUD.COD_USUARIO%TYPE, 
		ivc_desValorAnterior IN VDIR_BITACORA_SOLICITUD.DES_VALOR_ANTERIOR%TYPE, 
		ivc_desValorNuevo    IN VDIR_BITACORA_SOLICITUD.DES_VALOR_NUEVO%TYPE, 
		ivc_observacion      IN VDIR_BITACORA_SOLICITUD.OBSERVACION%TYPE
	);
	
	-- ---------------------------------------------------------------------
	-- prActualizaAfiliacion
	-- ---------------------------------------------------------------------
	PROCEDURE prActualizaAfiliacion
	(
		inu_codAfiliacion IN VDIR_AFILIACION.COD_AFILIACION%TYPE,
		inu_codEstado     IN VDIR_AFILIACION.COD_ESTADO%TYPE,
		idt_fechaGestion  IN VDIR_AFILIACION.FECHA_GESTION%TYPE DEFAULT NULL,
		inu_codUsuario    IN VDIR_AFILIACION.COD_USUARIO_GESTION%TYPE DEFAULT NULL
    );
	
	-- ---------------------------------------------------------------------
	-- prGuardarColaSolicitud
	-- ---------------------------------------------------------------------
	PROCEDURE prGuardarColaSolicitud
	(
		inu_codUsuario       IN VDIR_COLA_SOLICITUD.COD_USUARIO%TYPE,
		inu_codAfiliacion    IN VDIR_COLA_SOLICITUD.COD_AFILIACION%TYPE,
        ivc_rolOperativo     IN VARCHAR2 DEFAULT NULL
    );
				
	-- ---------------------------------------------------------------------
	-- prEliminaColaSolicitud
	-- ---------------------------------------------------------------------
	PROCEDURE prEliminaColaSolicitud
	(
		inu_codUsuario        IN VDIR_COLA_SOLICITUD.COD_USUARIO%TYPE,
		inu_codAfiliacion     IN VDIR_COLA_SOLICITUD.COD_AFILIACION%TYPE
    );
	
	-- ---------------------------------------------------------------------
	-- prActualizaColaSolicitud
	-- ---------------------------------------------------------------------
	PROCEDURE prActualizaColaSolicitud
	(
		inu_codUsuario        IN VDIR_COLA_SOLICITUD.COD_USUARIO%TYPE,
		inu_codAfiliacion     IN VDIR_COLA_SOLICITUD.COD_AFILIACION%TYPE,
        ivc_rolOperativo     IN VARCHAR2 DEFAULT NULL
    );
  
    -- ---------------------------------------------------------------------
	-- prGestionSolicitud
	-- ---------------------------------------------------------------------
	PROCEDURE prGestionSolicitud
	(
		inu_codUsuario     IN VDIR_COLA_SOLICITUD.COD_USUARIO%TYPE,
		inu_codAfiliacion  IN VDIR_COLA_SOLICITUD.COD_AFILIACION%TYPE,
		inu_tipoGestion    IN NUMBER
    );
	
END VDIR_PACK_BANDEJA_OPERACIONES;
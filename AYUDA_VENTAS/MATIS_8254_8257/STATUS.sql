USE [PreCoreMP]
GO
/****** Object:  StoredProcedure [saludmp].[SP_ADM_CHANGE_INCONSISTENCY_STATUS]    Script Date: 12/04/2024 12:07:09 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [saludmp].[SP_ADM_CHANGE_INCONSISTENCY_STATUS]
    @cod_error INTEGER OUTPUT,
    @msg_error VARCHAR(500) OUTPUT,
    @cod_inconsis_prestapp INT,
	@cod_tipo_datopres INT,
    @cod_estado CHAR(2),
    @id_asesor VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE cursor_gestion_gestion_inconsistencias CURSOR FOR
		SELECT cod_tipo_datopres 
		FROM #INCONSISTENCIAS_PRESTADOR; 

    IF (@cod_inconsis_prestapp='' OR @cod_inconsis_prestapp IS NULL) 
    BEGIN 
        SET @cod_error = 5;
        SET @msg_error = 'Debe ingresar el valor de "cod_inconsis_prestapp" es obligatorio.';
        GOTO ERROR;
    END;

	IF (@cod_tipo_datopres = '' OR @cod_tipo_datopres IS NULL ) 
		BEGIN 
			SET @cod_error = 5;
			SET @msg_error = 'Debe ingresar el valor de "cod_tipo_datopres" es obligatorio.';
			GOTO ERROR;
		END;

    IF (@cod_estado = '' OR @cod_estado IS NULL) 
		BEGIN 
			SET @cod_error = 5;
			SET @msg_error = 'Debe ingresar el valor de "cod_estado" es obligatorio.';
			GOTO ERROR;
		END;

    -- IF (@id_asesor = '' OR @id_asesor IS NULL) 
	-- 	BEGIN 
	-- 		SET @id_asesor = NULL;
	-- 	END;

    IF (@id_asesor='' OR @id_asesor IS NULL) 
		BEGIN 
			UPDATE saludmp.ADM_INCONSIS_PRESTAPP_3 SET cod_estado = @cod_estado WHERE cod_inconsis_prestapp = @cod_inconsis_prestapp AND cod_tipo_datopres = @cod_tipo_datopres;
			SET @cod_error = 0;
			SET @msg_error = 'Se Actualizó Exitosamente';
		END;
    ELSE
        BEGIN
            UPDATE saludmp.ADM_GESTION_INCONSISTENCIA_PRESTADORES SET id_asesor = @id_asesor WHERE cod_inconsis_prestapp = @cod_inconsis_prestapp;
            SET @cod_error = 0;
            SET @msg_error = 'Se Actualizó Exitosamente';
        END;

        SELECT
            ADM_IP.fecha_registro,
            ADM_IP.cod_inconsis_prestapp,
            ADM_IP.cod_tipo_datopres,
            ADM_PTD.descripcion AS descripcion_fallo,
            ADM_IP.tipo_id_usuario,
            ADM_IP.cod_prestador,
            CASE 
                WHEN PRESTA.tipo = 'I' THEN PRESTA.nombre_abre
                ELSE PRESTA.ape_razon
            END AS nombre_prestador,
            ADM_IP.id_usuario,
            CONCAT(LTRIM(RTRIM(AFI.nombre)), ' ', LTRIM(RTRIM(AFI.ape)), ' ', LTRIM(RTRIM(AFI.nombre2)), ' ', LTRIM(RTRIM(AFI.ape2))) AS nombre_usuario,
            ADM_IP.app,
            ADM_IP.ruta,
            ADM_IP.observacion,
            ADM_IP.cod_estado,
            CONCAT(LTRIM(RTRIM(ASE.PrimerNombre)),LTRIM(RTRIM(ASE.PrimerApellido)),LTRIM(RTRIM(ASE.SegundoNombre)),LTRIM(RTRIM(ASE.SegundoApellido))) AS nombre_usuario,
            ADM_GIP.fecha_asignacion,
            ADM_GIP.fecha_resuelto,
            ADM_GIP.observaciones_gestion
        FROM
            saludmp.ADM_INCONSIS_PRESTAPP_3 ADM_IP
            INNER JOIN saludmp.ADM_GESTION_INCONSISTENCIA_PRESTADORES ADM_GIP ON ADM_IP.cod_inconsis_prestapp = ADM_GIP.cod_inconsis_prestapp
            INNER JOIN saludmp.ADM_P_TIPO_DATOPRES ADM_PTD ON ADM_PTD.cod_tipo_datopres = ADM_IP.cod_tipo_datopres
            INNER JOIN PRESTADORES PRESTA ON PRESTA.prestad = ADM_IP.cod_prestador
            INNER JOIN AFILIADOS AFI ON ADM_IP.id_usuario = AFI.docu_nro AND ADM_IP.tipo_id_usuario = AFI.docu_tipo
            INNER JOIN ASESOR ASE ON ASE.NumeroDocumento = ADM_GIP.id_asesor
        WHERE
            ADM_IP.cod_inconsis_prestapp = @cod_inconsis_prestapp
            AND PRESTA.baja_fecha IS NULL
            AND AFI.baja_fecha IS NULL
            -- AND ASE.FechaAprobacion IS NOT NULL

        RETURN; -- Termina el procedimiento correctamente

ERROR:
    SET @cod_inconsis_prestapp = NULL;
    SET @cod_estado = NULL;
    SET @id_asesor = NULL;
    RETURN; -- Termina el procedimiento debido al error
END;

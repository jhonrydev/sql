USE [PreCoreMP]
GO
/****** Object:  StoredProcedure [saludmp].[SP_ADM_GET_INCONSISTENCIES_PROVIDERS]    Script Date: 9/01/2025 2:55:59 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
  Nombre del Stored Procedure: SP_ADM_GET_INCONSISTENCIES_PROVIDERS
  Autor: Jhon Medina
  Fecha de creación: Enero 2025
  Objetivo: Permite obtener todos los planes que están relacionados con un programa
*/
CREATE PROCEDURE [saludmp].[SP_ADM_GET_PLANES_POR_PROGRAMA]
    @coderror INTEGER  = 0 OUTPUT,
    @msgerror VARCHAR(500)  = 0 OUTPUT
AS
BEGIN
    BEGIN TRY
       
        SELECT PG.plan_grupo cod_programa,PG.deno programa,P.plan_codi cod_plan,P.deno 'plan'
        FROM PLANES P INNER JOIN PLANES_GRUPOS PG
        ON P.plan_grupo = PG.plan_grupo
        WHERE P.baja_fecha IS NULL
        AND PG.baja_fecha IS NULL
        ORDER by PG.plan_grupo;

        -- Establecer códigos de éxito y mensaje de éxito
        SET @coderror = 0;
        SET @msgerror = 'Consulta Exitosa';
			
    END TRY
    BEGIN CATCH
        -- Capturar y manejar el error
        DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
        SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY();
        
        -- Establecer códigos de error y mensaje de error
        SET @coderror = @ErrSeverity;
        SET @msgerror = @ErrMsg;
    END CATCH
END;
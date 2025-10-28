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
ALTER PROCEDURE [saludmp].[SP_ADM_GET_PLANES_POR_PROGRAMA_BORRAR]
    @coderror INTEGER  = 0 OUTPUT,
    @msgerror VARCHAR(500)  = 0 OUTPUT
AS
BEGIN
    BEGIN TRY
       
        -- SELECT TRIM(PG.plan_grupo) cod_programa,TRIM(PG.deno) programa,TRIM(P.plan_codi) cod_plan,TRIM(P.deno) 'plan'
        -- FROM PLANES P INNER JOIN PLANES_GRUPOS PG
        -- ON P.plan_grupo = PG.plan_grupo
        -- WHERE P.baja_fecha IS NULL
        -- AND PG.baja_fecha IS NULL
        -- ORDER by PG.plan_grupo;

        SELECT 
        TRIM(P.plan_grupo) cod_programa, 
        TRIM(P.deno) descripcion,
        (
            SELECT TRIM(PL.plan_codi )cod_plan, TRIM(PL.deno) descripcion
            FROM PLANES PL
            WHERE baja_fecha IS NULL AND PL.plan_grupo=P.plan_grupo
            ORDER BY descripcion
            FOR JSON PATH
        ) planes
        FROM PLANES_GRUPOS P
        WHERE baja_fecha IS NULL
        ORDER BY descripcion

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
GO

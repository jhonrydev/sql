SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jhon Iber Medina Bueno
-- Create date: 20240904
-- Description:	Permite obtine lista de los Arquetipos displonible para cada una de las lineas de negocio
-- =============================================
ALTER PROCEDURE [saludmp].[SP_GET_ARQUETIPOS]
	@coderror INTEGER = 0 OUTPUT,
    @msgerror VARCHAR(500) = 0 OUTPUT
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY
		
		SELECT
			RTRIM(LTRIM(LN.linea_negocio)) cod_linea, 
			RTRIM(LTRIM(LN.linea_negocio)) linea_negocio, 
			RTRIM(LTRIM(PT.tipo_perfil)) cod_perfil,
			RTRIM(LTRIM(PT.deno)) arquetipo ,
			RTRIM(LTRIM(PC.deno)) marcacion ,
			RTRIM(LTRIM(PCS.deno)) submarcacion 
		FROM PERFILES_CONFIG PC 
		LEFT JOIN PERFILES_CONFIG_SUB PCS ON pc.cod_perfil=pcs.cod_perfil
		LEFT JOIN PERFILES_TIPO PT ON pc.tipo_perfil = pt.tipo_perfil
		LEFT JOIN LINEA_NEGOCIO LN ON pc.linea_negocio=ln.cod
		
		WHERE LN.baja_fecha IS NULL
			AND PT.baja_fecha IS NULL
			AND PC.baja_fecha IS NULL
			AND PCS.baja_fecha IS NULL
			-- AND pt.tipo_perfil='V' 
		ORDER BY arquetipo,marcacion,submarcacion
		
		SET @coderror = 0
		SET @msgerror = 'Ok'
	END TRY
	BEGIN CATCH
		
		-- Captura del error
		SET @coderror = CAST(ERROR_NUMBER() AS VARCHAR);
		SET @msgerror = ERROR_MESSAGE();

	END CATCH

    
END
GO

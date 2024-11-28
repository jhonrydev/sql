USE [PreCoreMP]
GO

DECLARE	@return_value int,
		@coderror int,
		@msgerror varchar(500)

EXEC	@return_value = [saludmp].[SP_ADM_GET_INCONSISTENCIES_PROVIDERS]
		@coderror = @coderror OUTPUT,
		@msgerror = @msgerror OUTPUT,
		@cod_regional_asesor = 9

SELECT	@coderror as N'@coderror',
		@msgerror as N'@msgerror'

SELECT	'Return Value' = @return_value

GO

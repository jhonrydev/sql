
CREATE PROCEDURE saludmp.SP_ADM_MIGRACION_DATA

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE
    @cod_tipo_datopres NVARCHAR(50),
    @observacion NVARCHAR(500),
    @cod_prestador NVARCHAR(50),
    @fecha_registro NVARCHAR(50),
    @app NVARCHAR(50);

	DECLARE adm_migracion_data CURSOR FOR
		SELECT cod_tipo_datopres ,observacion,cod_prestador,fecha_registro,app
		FROM saludmp.ADM_INCONSIS_PRESTAPP;

		OPEN adm_migracion_data
			FETCH NEXT FROM adm_migracion_data INTO @cod_tipo_datopres,@observacion,@cod_prestador,@fecha_registro,@app
				WHILE @@FETCH_STATUS=0
					BEGIN
						
						DECLARE	@return_value int,
								@coderror int,
								@msgerror varchar(500)

						EXEC	@return_value = [saludmp].[SP_ADM_REGISTER_INCONSISTENCIES_PROVIDERS]
								@coderror = @coderror OUTPUT,
								@msgerror = @msgerror OUTPUT,
								@cod_tipo_datopres = @cod_tipo_datopres,
								@observacion = @observacion,
								@cod_prestador = @cod_prestador,
								@cod_ciudad_prestador = N'',
								@app = @app,
								@ruta = N'',
								@tipo_id_usuario = N'',
								@id_usuario = N' '

						SELECT	@coderror as N'@coderror',
								@msgerror as N'@msgerror'

						SELECT	'Return Value' = @return_value

						FETCH NEXT FROM adm_migracion_data INTO @cod_tipo_datopres,@observacion,@cod_prestador,@fecha_registro,@app
					END
		CLOSE adm_migracion_data

		DEALLOCATE adm_migracion_data

  
END


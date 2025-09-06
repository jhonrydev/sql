/*
  Nombre del Stored Procedure: getEspecialidadesPrestador
  Autor: Jhon Medina
  Fecha de creación: Abril 2024
  Objetivo: Permite obtener las especialidades, subespecialidades y afinidades de un prestador
*/

ALTER PROCEDURE [saludmp].[getEspecialidadesPrestador]
	@codCiudad varchar(10),
	@codPrestador varchar(10) = NULL,
	@codDireccion varchar(200),
	@cartilla varchar(5),
	@coderror INTEGER = 0 OUTPUT,
    @msgerror VARCHAR(500) = NULL OUTPUT
AS
BEGIN
	
	SET NOCOUNT ON;

	IF (@codCiudad = '' OR UPPER(@codCiudad) = 'NULL' OR UPPER(@codCiudad) IS NULL) 
		BEGIN 
			SET @coderror = 5;
			SET @msgerror = 'Debe ingresar el valor de "codCiudad" es obligatorio.';
			GOTO ERROR;
		END;

	IF (@codPrestador = '' OR UPPER(@codPrestador) = 'NULL' OR UPPER(@codPrestador) IS NULL) 
		BEGIN 
			SET @coderror = 5;
			SET @msgerror = 'Debe ingresar el valor de "codPrestador" es obligatorio.';
			GOTO ERROR;
		END;

    IF (@codDireccion = '' OR UPPER(@codDireccion) = 'NULL' OR UPPER(@codDireccion) IS NULL) 
		BEGIN 
			SET @coderror = 5;
			SET @msgerror = 'Debe ingresar el valor de "direccion" es obligatorio.';
			GOTO ERROR;
		END;

    IF (@cartilla = '' OR UPPER(@cartilla) = 'NULL' OR UPPER(@cartilla) IS NULL) 
		BEGIN 
			SET @coderror = 5;
			SET @msgerror = 'Debe ingresar el valor de "cartilla" es obligatorio.';
			GOTO ERROR;
		END;

    IF (@codCiudad IS NOT NULL AND @codPrestador IS NOT NULL AND  @codDireccion IS NOT NULL AND @cartilla IS NOT NULL)
    BEGIN
        SELECT DISTINCT especialidades_exten_deno AS especialidad, sub_especialidades_exten_deno AS sudEspecialidad, Nombre_Afinidad AS afinidad
        FROM Visor_directorios_5 v5
        WHERE V5.cod_ciudad = @codCiudad
        AND V5.prestad = @codPrestador
        AND V5.lugar = @codDireccion
        AND V5.carti = @cartilla
        ORDER BY especialidad,sudEspecialidad,afinidad

        SET @coderror = 0
        SET @msgerror ='Ok'
    END

	ERROR:
		SELECT @coderror AS coderror , @msgerror AS msgerror
		RETURN

END
GO
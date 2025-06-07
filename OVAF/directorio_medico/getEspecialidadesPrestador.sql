SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
  Nombre del Stored Procedure: getEspecialidadesPrestador
  Autor: Jhon Medina
  Fecha de creación: Abril 2024
  Objetivo: Permite obtener las especialidades, subespecialidades y afinidades de un prestador
*/

ALTER PROCEDURE [saludmp].[getEspecialidadesPrestador]
	@codCiudad varchar(10),
	@codPrestador varchar(10) = NULL,
	@direccion varchar(200),
	@cartilla varchar(5),
	@coderror INTEGER = 0 OUTPUT,
    @msgerror VARCHAR(500) = NULL OUTPUT
AS
BEGIN
	
	SET NOCOUNT ON;

	IF (@codCiudad = '' OR @codCiudad = 'NULL' OR @codCiudad IS NULL) 
		BEGIN 
			SET @coderror = 5;
			SET @msgerror = 'Debe ingresar el valor de "codCiudad" es obligatorio.';
			RETURN
		END;

	IF (@codPrestador = '' OR @codPrestador = 'NULL' OR @codPrestador IS NULL) 
		BEGIN 
			SET @coderror = 5;
			SET @msgerror = 'Debe ingresar el valor de "codPrestador" es obligatorio.';
			RETURN
		END;

    IF (@direccion = '' OR @direccion = 'NULL' OR @direccion IS NULL) 
		BEGIN 
			SET @coderror = 5;
			SET @msgerror = 'Debe ingresar el valor de "direccion" es obligatorio.';
			RETURN
		END;

    IF (@cartilla = '' OR @cartilla = 'NULL' OR @cartilla IS NULL) 
		BEGIN 
			SET @coderror = 5;
			SET @msgerror = 'Debe ingresar el valor de "cartilla" es obligatorio.';
			RETURN
		END;

    IF (@codCiudad IS NOT NULL AND @codPrestador IS NOT NULL AND  @direccion IS NOT NULL AND @cartilla IS NOT NULL)
    BEGIN
        SELECT DISTINCT especialidades_exten_deno AS especialidad, sub_especialidades_exten_deno AS sudEspecialidad, Nombre_Afinidad AS afinidad
        FROM Visor_directorios_5 v5
        WHERE V5.cod_ciudad = @codCiudad
        AND V5.prestad = @codPrestador
        AND V5.direccion_lugar_atencion = @direccion
        AND V5.carti = @cartilla
        ORDER BY especialidad,sudEspecialidad,afinidad

        SET @coderror = 0
        SET @msgerror ='Ok'
    END

END
GO

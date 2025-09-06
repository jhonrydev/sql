/*
  Nombre del Stored Procedure: getEspecialidadesPorCartillaDirectorio
  Autor: Jhon Medina
  Fecha de creación: Febrero 2025
  Objetivo: Permite obtener las especialidades de una ciudad teniendo en cuenta la cartilla
*/

ALTER PROCEDURE [saludmp].[getEspecialidadesPorCartillaDirectorio]
	@cartilla varchar(5) = NULL,
	@codCiudad varchar(10),
	@coderror INTEGER = 0 OUTPUT,
    @msgerror VARCHAR(500) = NULL OUTPUT
AS
BEGIN
	
	SET NOCOUNT ON;

	 IF (@cartilla = '' OR @cartilla = 'NULL' OR @cartilla IS NULL) 
	 	BEGIN 
	 		SET @coderror = 5;
	 		SET @msgerror = 'Debe ingresar el valor de "cartilla" es obligatorio.';
	 		RETURN
	 	END;	

	IF (@codCiudad = '' OR @codCiudad = 'NULL' OR @codCiudad IS NULL) 
		BEGIN 
			SET @coderror = 5;
			SET @msgerror = 'Debe ingresar el valor de "codCiudad" es obligatorio.';
			RETURN
		END;

	IF(@codCiudad IS NOT NULL AND @cartilla IS NOT NULL)
		BEGIN

			SELECT DISTINCT CONCAT(RTRIM(v3.especialidades_exten_deno),' ', RTRIM(v3.sub_especialidades_exten_deno),' ',RTRIM(v3.Nombre_Afinidad) ) AS especialidades, CONCAT(v3.espe,'-',v3.codsubespecialidad, '-',v3.codafinidad) as codeEspecialidades
			FROM Visor_directorios_3 v3
			WHERE v3.cod_ciudad = @codCiudad
			AND v3.carti = @cartilla
			ORDER BY especialidades

			SET @coderror = 0
			SET @msgerror ='Ok'
			RETURN
		END

END
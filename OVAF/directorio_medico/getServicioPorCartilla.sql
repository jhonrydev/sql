SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
  Nombre del Stored Procedure: getServicioPorCartilla
  Autor: Jhon Medina
  Fecha de creación: Abril 2024
  Objetivo: Permite obtener los servicio que estan asociados a una cartilla
*/

ALTER PROCEDURE [saludmp].[getServicioPorCartilla]
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
				SELECT 
                    CONCAT(v3.espe,'-',v3.codsubespecialidad,'-',v3.codafinidad) AS codAgrupador,
                    v3.espe AS codEspecialidad,
                    LTRIM(RTRIM(v3.especialidades_exten_deno)) AS especialidad,
                    v3.codsubespecialidad AS codSubEspecialidad,
                    LTRIM(RTRIM(v3.sub_especialidades_exten_deno)) subEspecialidad,
                    v3.codafinidad AS codAfinidad,
                    CASE
                        WHEN v3.Nombre_Afinidad IS NULL THEN ''
                        ELSE LTRIM(RTRIM(v3.Nombre_Afinidad)) 
                    END AS afinidad
                FROM Visor_directorios_3 v3
                WHERE v3.cod_ciudad=@codCiudad
                AND v3.carti = @cartilla
                ORDER BY especialidad,subEspecialidad,afinidad

				SET @coderror = 0
				SET @msgerror ='Ok'
				RETURN
			END
	
END
GO

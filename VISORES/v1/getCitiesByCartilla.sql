SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
  Nombre del Stored Procedure: getCitiesByCartilla
  Autor: Jhon Medina
  Fecha de creación: Abril 2025
  Objetivo: Permite obtener información de las ciudades teniendo en cuenta una cartilla
*/

ALTER PROCEDURE [saludmp].[getCitiesByCartilla]
	@cartilla varchar(5) = NULL,
	@coderror INTEGER = 0 OUTPUT,
    @msgerror VARCHAR(500) = NULL OUTPUT
AS
    
BEGIN
	
	SET NOCOUNT ON;
		
	 IF (@cartilla = '' OR @cartilla = 'NULL' OR @cartilla IS NULL) 
	 	BEGIN 
	 		SET @coderror = 5;
	 		SET @msgerror = 'Debe ingresar el valor de cartilla es obligatorio.';
			RETURN;
	 	END;
		
		SELECT DISTINCT cod_ciudad, ciudad
		FROM Visor_directorios_3
		WHERE carti = @cartilla
		ORDER BY ciudad;

		SET @coderror = 0
		SET @msgerror ='Ok'
		RETURN
	
END
GO

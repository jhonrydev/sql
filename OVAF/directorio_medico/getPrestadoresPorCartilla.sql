--Server
-- drop Procedure [saludmp].[getServicioXCartilla]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
  Nombre del Stored Procedure: getServicioPorCartilla
  Autor: Jhon Medina
  Fecha de creación: Febrero 2025
  Objetivo: Permite obtener los prestadores que estan asociados a una cartilla teniendo en cuenta la ciudad
*/

CREATE PROCEDURE [saludmp].[getPrestadoresPorCartilla]
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
                    prestad AS codPrestador, 
                    LTRIM(RTRIM(PRESTADOR)) AS prestador,
                    prestadores_tipo AS codTipoPrestador, 
                    CASE
                        WHEN prestadores_tipo= 'P' THEN 'Prestador Natural'
                        ELSE 'Prestador Jurídico'
                    END AS tipoPrestador,
                    LTRIM(RTRIM(nombre_abre)) AS nombreAbreviadoPrestador, 
                    LTRIM(RTRIM(prestadores_ape_razon)) AS razonSocial
                FROM Visor_directorios_3 v3
                WHERE v3.cod_ciudad=@codCiudad
                AND v3.carti = @cartilla
                ORDER BY prestador

				SET @coderror = 0
				SET @msgerror ='Ok'
				RETURN
			END
	
END
GO

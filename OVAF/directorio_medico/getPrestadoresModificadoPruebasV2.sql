SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
  Nombre del Stored Procedure: getPrestadoresUrgenciasPediatricas
  Autor: Jhon Medina
  Fecha de creación: Abril 2024
  Objetivo: Permite obtener los prestadores que ofrecen servicios de acuerdo a filtros especificados
*/

ALTER PROCEDURE [saludmp].[getPrestadores]
	@cartilla varchar(5) = NULL,
	@codCiudad varchar(10),
	@codEspecialidad varchar (10) = NULL,
	@codSubEspecialidad varchar (10) = NULL,
	@codAfinidad varchar(10) = NULL,
	@codPrestador varchar(15) = NULL,
	@coderror INTEGER = 0 OUTPUT,
    @msgerror VARCHAR(500) = NULL OUTPUT
AS
BEGIN
	
	SET NOCOUNT ON;
		
	 IF (@cartilla = '' OR @cartilla = 'NULL' OR @cartilla IS NULL) 
	 	BEGIN 
	 		SET @coderror = 5;
	 		SET @msgerror = 'Debe ingresar el valor de cartilla es obligatorio.';
			GOTO ERROR;
	 	END;
		
	IF (@codCiudad = '' OR @codCiudad = 'NULL' OR @codCiudad IS NULL) 
		BEGIN 
			SET @coderror = 5;
			SET @msgerror = 'Debe ingresar el valor de codCiudad es obligatorio.';
			GOTO ERROR;
		END;


	IF (@codEspecialidad = '' OR @codEspecialidad = 'NULL' OR @codEspecialidad IS NULL) 
		BEGIN 
			SET @codEspecialidad = NULL;
		END;

	IF (@codSubEspecialidad = '' OR @codSubEspecialidad = 'NULL' OR @codSubEspecialidad IS NULL) 
		BEGIN 
			SET @codSubEspecialidad = NULL;
		END;

	IF (@codAfinidad = '' OR @codAfinidad = 'NULL' OR @codAfinidad IS NULL) 
		BEGIN 
			SET @codAfinidad = NULL;
		END;

	IF (@codPrestador = '' OR @codPrestador = 'NULL' OR @codPrestador IS NULL) 
		BEGIN 
			SET @codPrestador = NULL;
		END;
		
		-- Filtro especialidades
		IF(@codCiudad IS NOT NULL AND @cartilla IS NOT NULL AND @codEspecialidad IS NOT NULL AND @codSubEspecialidad IS NOT NULL AND @codAfinidad IS NOT NULL)
			BEGIN
				SELECT carti AS cartilla,prestad AS codPrestador,prestadores_tipo AS tipoPrestador, PRESTADOR AS prestador, nombre_abre AS descripcionPrestador,prestadores_ape_razon AS razonSocial, espe AS codEspecialidad, especialidades_exten_deno AS especialidad, codsubespecialidad AS codSubEspecialidad ,sub_especialidades_exten_deno AS subEspecialidad,codafinidad AS codAfinidad ,Nombre_Afinidad AS Afinidad, cod_ciudad AS codCiudad, ciudad, direccion_lugar_atencion AS direccion,lugar AS lugarPrestador,latitud, longitud, email_citas AS email,prestad_lugares_tele1 AS telefono1,ext1,  prestad_lugares_tele2 AS telefono2, ext2,tele_nacional AS lineaNacional, prestad_lugares_celu1 AS celular1, prestad_lugares_celu2 AS celular2, telcelu_wp AS celularWhatsApp
				FROM Visor_directorios_5 v5
				WHERE V5.cod_ciudad = @codCiudad
				AND V5.carti = @cartilla
				AND V5.espe = @codEspecialidad
				AND V5.codsubespecialidad = @codSubEspecialidad
				AND V5.codafinidad = @codAfinidad
				ORDER BY prestador

				SET @coderror = 0
				SET @msgerror ='Ok'
				RETURN
			END
		
		-- Filtro prestadores
		IF(@codCiudad IS NOT NULL AND @cartilla IS NOT NULL AND @codPrestador IS NOT NULL)
			BEGIN
				SELECT top 3 carti AS cartilla,prestad AS codPrestador,prestadores_tipo AS tipoPrestador, PRESTADOR AS prestador, nombre_abre AS descripcionPrestador,prestadores_ape_razon AS razonSocial, espe AS codEspecialidad, especialidades_exten_deno AS especialidad, codsubespecialidad AS codSubEspecialidad ,sub_especialidades_exten_deno AS subEspecialidad,codafinidad AS codAfinidad ,Nombre_Afinidad AS Afinidad, cod_ciudad AS codCiudad, ciudad, direccion_lugar_atencion AS direccion,lugar AS lugarPrestador,latitud, longitud, email_citas AS email,prestad_lugares_tele1 AS telefono1,ext1,  prestad_lugares_tele2 AS telefono2, ext2,tele_nacional AS lineaNacional, prestad_lugares_celu1 AS celular1, prestad_lugares_celu2 AS celular2, telcelu_wp AS celularWhatsApp
				FROM Visor_directorios_5 v5
				WHERE V5.cod_ciudad = @codCiudad
				AND V5.carti = @cartilla
				AND V5.prestad = @codPrestador
				ORDER BY prestador

				SET @coderror = 0
				SET @msgerror ='Ok'
				RETURN
			END

	ERROR:
		SELECT @coderror AS coderror , @msgerror AS msgerror
		RETURN
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
  Nombre del Stored Procedure: getPrestadoresDirectorio
  Autor: Jhon Medina
  Fecha de creación: Abril 2024
  Objetivo: Permite obtener los prestadores que ofrecen servicios de acuerdo a filtros especificados
*/

ALTER PROCEDURE [saludmp].[getPrestadoresDirectorio]
	@cartilla VARCHAR(5),
	@codCiudad VARCHAR(10),
	@codEspecialidad VARCHAR (10) = NULL,
	@codSubEspecialidad VARCHAR (10) = NULL,
	@codAfinidad VARCHAR(10) = NULL,
	@codPrestador VARCHAR(15) = NULL,
	@getPrestadores NVARCHAR(MAX) = NULL,
	-- @pagina INT= 1,
	@coderror VARCHAR = '0' OUTPUT,
    @msgerror VARCHAR(500) = NULL OUTPUT
AS

-- DECLARE @registrosXpagina INT= 9
-- DECLARE @offSet INT= (@pagina - 1) * @registrosXpagina

BEGIN
	
	SET NOCOUNT ON;
	
	IF ((@cartilla = '' OR LOWER(@cartilla) = 'null' OR LOWER(@cartilla) IS NULL) AND (@getPrestadores = '' OR LOWER(@getPrestadores) = 'null' OR LOWER(@getPrestadores) IS NULL AND @codPrestador='' AND LOWER(@codPrestador)='NULL' AND LOWER(@codPrestador) IS NULL)) 
		BEGIN 
			SET @coderror = '5';
			SET @msgerror = 'Debe ingresar el valor de "cartilla" es obligatorio.';
			RETURN
		END;

	-- IF ((@codCiudad = '' OR LOWER(@codCiudad) = 'null' OR LOWER(@codCiudad) IS NULL) AND (@getPrestadores = '' OR LOWER(@getPrestadores) = 'null' OR LOWER(@getPrestadores) IS NULL)) 
	-- 	BEGIN 
	-- 		SET @coderror = '5';
	-- 		SET @msgerror = 'Debe ingresar el valor de "codCiudad" es obligatorio.';
	-- 		SELECT null res
	-- 		RETURN
	-- 	END;
	-- 		SELECT @codCiudad  codCiudad RETURN
	-- 	SELECT 'codPrestador ' + LOWER(@codPrestador)  res RETURN

	IF (@codEspecialidad = '' OR LOWER(@codEspecialidad) = 'null' OR LOWER(@codEspecialidad) IS NULL) 
		BEGIN 
			SET @codEspecialidad = NULL;
		END;

	IF (@codSubEspecialidad = '' OR LOWER(@codSubEspecialidad) = 'null' OR LOWER(@codSubEspecialidad) IS NULL) 
		BEGIN 
			SET @codSubEspecialidad = NULL;
		END;

	IF (@codAfinidad = '' OR LOWER(@codAfinidad) = 'null' OR LOWER(@codAfinidad) IS NULL) 
		BEGIN 
			SET @codAfinidad = NULL;
		END;
	
	IF (@codPrestador = '' OR LOWER(@codPrestador) = 'null' OR LOWER(@codPrestador) IS NULL) 
		BEGIN 
			SET @codPrestador = NULL;
		END;
	-- SELECT 'codPrestador ' + LOWER(@codPrestador)  res RETURN
	-- SELECT 'cartilla ' + LOWER(@cartilla) + ' codCiudad '+@codCiudad +' codPrestador '+@codPrestador as res RETURN
	

		--obtener los prestadores teniendo en cuenta los filtros OK
		IF(@codCiudad IS NOT NULL AND @cartilla IS NOT NULL AND @codEspecialidad IS NOT NULL AND @codSubEspecialidad IS NOT NULL AND @codAfinidad IS NOT NULL)
			BEGIN
			-- RETURN 'aqui'
				SELECT DISTINCT carti AS cartilla,RTRIM(cartilla_deno) AS cartilla_descripcion,prestad AS codPrestador,prestadores_tipo AS tipoPrestador, 
					CASE prestadores_tipo 
						WHEN 'I' THEN  
							CASE
								WHEN nombre_abre IS NOT NULL OR LEN(nombre_abre) = 0 THEN  RTRIM(nombre_abre)
								ELSE RTRIM(prestadores_ape_razon)
							END
						ELSE RTRIM(PRESTADOR)
					END AS prestador,
					nombre_abre AS descripcionPrestador,prestadores_ape_razon AS razonSocial, espe AS codEspecialidad, especialidades_exten_deno AS especialidad, codsubespecialidad AS codSubEspecialidad ,sub_especialidades_exten_deno AS subEspecialidad,codafinidad AS codAfinidad ,Nombre_Afinidad AS Afinidad, cod_ciudad AS codCiudad, ciudad, direccion_lugar_atencion AS direccion,lugar AS codDireccion,latitud, longitud, email_citas AS email,prestad_lugares_tele1 AS telefono1,ext1 AS extension1,  prestad_lugares_tele2 AS telefono2, ext2 AS extension2,tele_nacional AS lineaNacional, prestad_lugares_celu1 AS celular1, prestad_lugares_celu2 AS celular2, telcelu_wp AS celularWP
				FROM Visor_directorios_5 v5
				WHERE V5.espe = @codEspecialidad
				AND V5.codafinidad = @codAfinidad
				AND V5.cod_ciudad = @codCiudad
				AND V5.carti = @cartilla
				AND V5.carti NOT IN ('011', '002', '012', '013')
				AND V5.codsubespecialidad = @codSubEspecialidad
				ORDER BY prestador,lugar,espe,codsubespecialidad,codafinidad

				SET @coderror = 0
				SET @msgerror ='Ok'
				RETURN
			END

		--obtener los prestadores teniendo en cuenta los filtros Ok
		IF(@codCiudad IS NOT NULL AND @cartilla IS NOT NULL AND @codPrestador IS NOT NULL)
			BEGIN
				SELECT DISTINCT carti AS cartilla,RTRIM(cartilla_deno) AS cartilla_descripcion,prestad AS codPrestador,prestadores_tipo AS tipoPrestador, 
					CASE prestadores_tipo 
						WHEN 'I' THEN  
							CASE
								WHEN nombre_abre IS NOT NULL OR LEN(nombre_abre) = 0 THEN  RTRIM(nombre_abre)
								ELSE RTRIM(prestadores_ape_razon)
							END
						ELSE RTRIM(PRESTADOR)
					END AS prestador,
					nombre_abre AS descripcionPrestador,prestadores_ape_razon AS razonSocial, espe AS codEspecialidad, especialidades_exten_deno AS especialidad, codsubespecialidad AS codSubEspecialidad ,sub_especialidades_exten_deno AS subEspecialidad,codafinidad AS codAfinidad ,Nombre_Afinidad AS Afinidad, cod_ciudad AS codCiudad, ciudad, direccion_lugar_atencion AS direccion,lugar AS codDireccion,latitud, longitud, email_citas AS email,prestad_lugares_tele1 AS telefono1,ext1 AS extension1,  prestad_lugares_tele2 AS telefono2, ext2 AS extension2,tele_nacional AS lineaNacional, prestad_lugares_celu1 AS celular1, prestad_lugares_celu2 AS celular2, telcelu_wp AS celularWP
				FROM Visor_directorios_5 v5
				WHERE V5.prestad = @codPrestador
				AND V5.cod_ciudad = @codCiudad
				AND V5.carti = @cartilla
				AND V5.carti NOT IN ('011', '002', '012', '013')
				ORDER BY prestador,lugar,espe,codsubespecialidad,codafinidad

				SET @coderror = 0
				SET @msgerror ='Ok'
				RETURN
			END
	
		IF(@getPrestadores IS NOT NULL)
			BEGIN
				SELECT DISTINCT prestad AS codPrestador,
					CASE prestadores_tipo 
						WHEN 'I' THEN  
							CASE
								WHEN nombre_abre IS NOT NULL OR LEN(nombre_abre) = 0 THEN  RTRIM(nombre_abre)
								ELSE RTRIM(prestadores_ape_razon)
							END
						ELSE RTRIM(PRESTADOR)
					END AS prestador--, prestadores_tipo AS tipoPrestador,nombre_abre AS descripcionPrestador, prestadores_ape_razon AS razonSocial
				FROM Visor_directorios_5
				WHERE PRESTADOR COLLATE Latin1_General_CI_AI LIKE '%' +@getPrestadores + '%' COLLATE Latin1_General_CI_AI
				AND carti NOT IN ('002', '009', '011', '012', '013')
				AND espe NOT IN ('115', '116', '111', '800', '112', '733', '738', '714', '106', '105', '113', '200', '720')
				ORDER BY prestador

				SET @coderror = 0
				SET @msgerror ='Ok'
				RETURN
			END;
		
		--obtener los prestadores teniendo en cuenta los filtros Ok
		IF(@codCiudad IS NOT NULL AND @codPrestador IS NOT NULL)
			BEGIN  
				SELECT DISTINCT carti AS cartilla,RTRIM(cartilla_deno) AS cartilla_descripcion,prestad AS codPrestador,prestadores_tipo AS tipoPrestador, 
					CASE prestadores_tipo 
						WHEN 'I' THEN  
							CASE
								WHEN nombre_abre IS NOT NULL OR LEN(nombre_abre) = 0 THEN  RTRIM(nombre_abre)
								ELSE RTRIM(prestadores_ape_razon)
							END
						ELSE RTRIM(PRESTADOR)
					END AS prestador,
					nombre_abre AS descripcionPrestador,prestadores_ape_razon AS razonSocial, espe AS codEspecialidad, especialidades_exten_deno AS especialidad, codsubespecialidad AS codSubEspecialidad ,sub_especialidades_exten_deno AS subEspecialidad,codafinidad AS codAfinidad ,Nombre_Afinidad AS Afinidad, cod_ciudad AS codCiudad, ciudad, direccion_lugar_atencion AS direccion,lugar AS codDireccion,latitud, longitud, email_citas AS email,prestad_lugares_tele1 AS telefono1,ext1 AS extension1,  prestad_lugares_tele2 AS telefono2, ext2 AS extension2,tele_nacional AS lineaNacional, prestad_lugares_celu1 AS celular1, prestad_lugares_celu2 AS celular2, telcelu_wp AS celularWP
				FROM Visor_directorios_5 v5
				WHERE V5.prestad = @codPrestador
				AND V5.cod_ciudad = @codCiudad
				AND V5.carti NOT IN ('011', '002', '012', '013')
				ORDER BY prestador,lugar,espe,codsubespecialidad,codafinidad

				SET @coderror = 0
				SET @msgerror ='Ok'
				RETURN
			END;
		
		--obtener los prestadores teniendo en cuenta los filtros Ok
		IF(@codCiudad IS NOT NULL AND @cartilla IS NOT NULL)
			BEGIN
				SELECT 
				CASE UPPER(prestadores_tipo) 
				WHEN 'I' THEN
					CASE 
						WHEN nombre_abre IS NOT NULL THEN RTRIM(PRESTADOR)
					END
				ELSE
					RTRIM(PRESTADOR)
				END	AS prestador, 
				prestad AS codPrestador, 
				prestadores_tipo AS tipoPrestador
				FROM Visor_directorios_3
				WHERE carti=@cartilla AND cod_ciudad=@codCiudad
				ORDER BY prestador
			END

		--obtener los prestadores teniendo en cuenta los filtros Ok
		IF(@codCiudad IS NULL AND @codPrestador IS NOT NULL)
			BEGIN 
				SELECT DISTINCT carti AS cartilla,RTRIM(cartilla_deno) AS cartilla_descripcion,prestad AS codPrestador,prestadores_tipo AS tipoPrestador, 
					CASE prestadores_tipo 
						WHEN 'I' THEN  
							CASE
								WHEN nombre_abre IS NOT NULL OR LEN(nombre_abre) = 0 THEN  RTRIM(nombre_abre)
								ELSE RTRIM(prestadores_ape_razon)
							END
						ELSE RTRIM(PRESTADOR)
					END AS prestador,
					nombre_abre AS descripcionPrestador,prestadores_ape_razon AS razonSocial, espe AS codEspecialidad, especialidades_exten_deno AS especialidad, codsubespecialidad AS codSubEspecialidad ,sub_especialidades_exten_deno AS subEspecialidad,codafinidad AS codAfinidad ,Nombre_Afinidad AS Afinidad, cod_ciudad AS codCiudad, ciudad, direccion_lugar_atencion AS direccion,lugar AS codDireccion,latitud, longitud, email_citas AS email,prestad_lugares_tele1 AS telefono1,ext1 AS extension1,  prestad_lugares_tele2 AS telefono2, ext2 AS extension2,tele_nacional AS lineaNacional, prestad_lugares_celu1 AS celular1, prestad_lugares_celu2 AS celular2, telcelu_wp AS celularWP
				FROM Visor_directorios_5 v5
				WHERE V5.prestad = @codPrestador
				-- AND V5.cod_ciudad = @codCiudad
				AND V5.carti NOT IN ('011', '002', '012', '013')
				ORDER BY ciudad,lugar,espe,codsubespecialidad,codafinidad
				-- OFFSET @offSet ROWS
				-- FETCH NEXT @registrosXpagina ROWS ONLY

				SET @coderror = 0
				SET @msgerror ='Ok'
				RETURN
			END;
END
GO

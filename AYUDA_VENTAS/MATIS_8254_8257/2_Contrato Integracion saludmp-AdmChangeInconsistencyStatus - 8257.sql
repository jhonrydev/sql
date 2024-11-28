/*
  Nombre del Stored Procedure: SP_ADM_CHANGE_INCONSISTENCY_STATUS
  Autor: Jhon Medina
  Fecha de creación: Abril 2024
  Objetivo: Permite cambiar el estador de un reporte de inconsistencia o la inconsistencia a un asesor si enviamos su id como parametro
*/
CREATE PROCEDURE [saludmp].[SP_ADM_CHANGE_INCONSISTENCY_STATUS]
    @coderror INTEGER = 0 OUTPUT,
    @msgerror VARCHAR(500) = 0 OUTPUT,
    @cod_inconsis_prestapp NVARCHAR(20)=NULL,
    @cod_estado NVARCHAR(20)=NULL,
	@observaciones_gestion NVARCHAR(4000)=NULL,
    @id_asesor NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @cod_registro_inconsis CHAR(5)
    DECLARE @cod_inconsistencia CHAR(5)
    DECLARE @cod_estado_inconsistencia CHAR(5)

	IF(@id_asesor = '' OR @id_asesor = 'NULL' OR @id_asesor IS NULL) 
		BEGIN 
			SET @id_asesor = NULL
		END

	
	IF (@id_asesor IS NULL) 
		BEGIN 

			IF (@cod_inconsis_prestapp = '' OR @cod_inconsis_prestapp = 'NULL' OR @cod_inconsis_prestapp IS NULL) 
				BEGIN 
					SET @coderror = 5;
					SET @msgerror = 'Debe ingresar el valor de "cod_inconsis_prestapp" es obligatorio.';
					RETURN
				END;

			IF ( @cod_estado IS NULL) 
				BEGIN 
					SET @coderror = 5;
					SET @msgerror = 'Debe ingresar el valor de "cod_estado" es obligatorio.';
					RETURN
				END;
			ELSE IF ( @cod_estado > 4 OR @cod_estado < 1) 
				BEGIN 
					SET @coderror = 5;
					SET @msgerror = 'El valor de "cod_estado" no es correcto.';
					RETURN
				END;
			
			
			--IF (@observaciones_gestion = '' OR @observaciones_gestion = 'NULL'  OR @observaciones_gestion IS NULL) 
			--	BEGIN 
			--		SET @coderror = 5;
			--		SET @msgerror = 'Debe ingresar el valor de "observaciones_gestion" es obligatorio.';
			--		RETURN
			--	END;
		END;
	ELSE
		BEGIN 
			SET @observaciones_gestion = NULL
			SET @cod_estado = NULL
		END;

		
    IF (@id_asesor IS NULL) 
	--cambia el estado de la inconsistencia
		BEGIN 
			
			DECLARE @inconsistencia_asignada_asesor INT
			
			SELECT @inconsistencia_asignada_asesor = COUNT(id_asesor) FROM saludmp.ADM_GESTION_INCONSISTENCIAS_PRESTADORES WHERE cod_inconsis_prestapp=@cod_inconsis_prestapp 
				
			IF (@inconsistencia_asignada_asesor <> 0)
				BEGIN
			
					DECLARE @estado_inconsistencia_principal INT
			
					SELECT @estado_inconsistencia_principal = cod_estado FROM saludmp.ADM_INCONSISTENCIAS_PRESTADORES_X_APP WHERE cod_inconsis_prestapp = @cod_inconsis_prestapp
			
					IF @estado_inconsistencia_principal = 3
						BEGIN

							SELECT DISTINCT 
								ADM_GIP.cod_inconsis_prestapp,
								ADM_GIP.cod_tipo_datopres,
								ADM_PTD.descripcion AS descripcion_fallo,
								ADM_IP.observacion,
								PRESTAD.prestad AS cod_prestador,
								CASE 
									WHEN PRESTAD.tipo = 'I' THEN PRESTAD.nombre_abre
									ELSE concat(LTRIM(PRESTAD.ape_razon), ' ', PRESTAD.apellido_2, ' ', PRESTAD.nombre_abre, ' ', PRESTAD.nombre_2) 
								END AS nombre_prestador,
								CONVERT(varchar, ADM_IP.fecha_registro, 5) AS fecha_registro,
								ADM_IP.app,
								ADM_IP.tipo_id_usuario,
								RTRIM(ADM_IP.id_usuario) AS id_usuario,
								CONCAT(LTRIM(RTRIM(AFI.nombre)),' ',LTRIM(RTRIM(AFI.nombre2)),' ',LTRIM(RTRIM(AFI.ape)),' ',LTRIM(RTRIM(AFI.ape2))) AS nombre_usuario,
								RTRIM(ADM_GIP.id_asesor) AS id_asesor,
								CONCAT(LTRIM(RTRIM(ASE.PrimerNombre)),' ',LTRIM(RTRIM(ASE.SegundoNombre)), ' ',LTRIM(RTRIM(ASE.PrimerApellido)),' ',LTRIM(RTRIM(ASE.SegundoApellido))) AS nombre_asesor,
								ADM_IP.ruta,
								CONVERT(varchar, ADM_GIP.fecha_asignacion, 5) AS fecha_asignacion,
								CONVERT(varchar, ADM_GIP.fecha_resuelto, 5) AS fecha_resuelto,
								ADM_GIP.observaciones_gestion,
								ADM_IP.cod_estado,
								ADM_EST.descripcion AS estado,
								ADM_GIP.cod_estado AS cod_estado_inconsistencia
							FROM 
								saludmp.ADM_INCONSISTENCIAS_PRESTADORES_X_APP ADM_IP INNER JOIN saludmp.ADM_ESTADOS ADM_EST ON ADM_IP.cod_estado = ADM_EST.id
								INNER JOIN saludmp.ADM_GESTION_INCONSISTENCIAS_PRESTADORES ADM_GIP ON ADM_IP.cod_inconsis_prestapp = ADM_GIP.cod_inconsis_prestapp
								INNER JOIN PRESTADORES PRESTAD ON ADM_IP.cod_prestador = PRESTAD.prestad 
								INNER JOIN PRESTAD_LUGARES PRESTAD_L ON PRESTAD_L.prestad = PRESTAD.prestad
								INNER JOIN LOCALIDADES LOCALI ON LOCALI.loca=PRESTAD_L.loca
								INNER JOIN PARTIDOS ON PARTIDOS.partido=LOCALI.partido
								INNER JOIN AFILIADOS AFI ON AFI.docu_nro = ADM_IP.id_usuario
								INNER JOIN saludmp.ADM_P_TIPO_DATOPRES ADM_PTD ON ADM_PTD.cod_tipo_datopres = ADM_GIP.cod_tipo_datopres
								INNER JOIN Asesor ASE ON ASE.NumeroDocumento = ADM_GIP.id_asesor
							WHERE 
								PRESTAD.baja_fecha IS NULL
								AND PRESTAD_L.baja_fecha IS NULL
								AND LOCALI.baja_fecha IS NULL
								AND PARTIDOS.baja_fecha IS NULL
								AND ADM_IP.cod_ciudad_prestador = LOCALI.loca
								AND ADM_GIP.cod_inconsis_prestapp = @cod_inconsis_prestapp
								AND ASE.NumeroDocumento = ADM_GIP.id_asesor
								AND ASE.FechaAprobacion IS NOT NULL

								SET @coderror = 0;
								SET @msgerror = 'Reporte De Fallo Número '+ @cod_inconsis_prestapp +' Resuelto'
								RETURN
						END
					ELSE IF @estado_inconsistencia_principal = 2 AND @cod_estado = 1
						BEGIN
							UPDATE saludmp.ADM_INCONSISTENCIAS_PRESTADORES_X_APP SET cod_estado = @cod_estado WHERE cod_inconsis_prestapp = @cod_inconsis_prestapp

							UPDATE saludmp.ADM_GESTION_INCONSISTENCIAS_PRESTADORES SET id_asesor=NULL,cod_estado = @cod_estado, fecha_resuelto = GETDATE(), observaciones_gestion = '' WHERE  cod_inconsis_prestapp = @cod_inconsis_prestapp 
							
							SELECT DISTINCT 
									ADM_GIP.cod_inconsis_prestapp,
									ADM_GIP.cod_tipo_datopres,
									ADM_PTD.descripcion AS descripcion_fallo,
									ADM_IP.observacion,
									PRESTAD.prestad AS cod_prestador,
									CASE 
										WHEN PRESTAD.tipo = 'I' THEN PRESTAD.nombre_abre
										ELSE concat(LTRIM(PRESTAD.ape_razon), ' ', PRESTAD.apellido_2, ' ', PRESTAD.nombre_abre, ' ', PRESTAD.nombre_2) 
									END AS nombre_prestador,
									CONVERT(varchar, ADM_IP.fecha_registro, 5) AS fecha_registro,
									ADM_IP.app,
									ADM_IP.tipo_id_usuario,
									RTRIM(ADM_IP.id_usuario) AS id_usuario,
									CONCAT(LTRIM(RTRIM(AFI.nombre)),' ',LTRIM(RTRIM(AFI.nombre2)),' ',LTRIM(RTRIM(AFI.ape)),' ',LTRIM(RTRIM(AFI.ape2))) AS nombre_usuario,
									RTRIM(ADM_GIP.id_asesor) AS id_asesor,
									CONCAT(LTRIM(RTRIM(ASE.PrimerNombre)),' ',LTRIM(RTRIM(ASE.SegundoNombre)), ' ',LTRIM(RTRIM(ASE.PrimerApellido)),' ',LTRIM(RTRIM(ASE.SegundoApellido))) AS nombre_asesor,
									ADM_IP.ruta,
									CONVERT(varchar, ADM_GIP.fecha_asignacion, 5) AS fecha_asignacion,
									CONVERT(varchar, ADM_GIP.fecha_resuelto, 5) AS fecha_resuelto,
									ADM_GIP.observaciones_gestion,
									ADM_IP.cod_estado,
									ADM_EST.descripcion AS estado,
									ADM_GIP.cod_estado AS cod_estado_inconsistencia
								FROM 
									saludmp.ADM_INCONSISTENCIAS_PRESTADORES_X_APP ADM_IP INNER JOIN saludmp.ADM_ESTADOS ADM_EST ON ADM_IP.cod_estado = ADM_EST.id
									INNER JOIN saludmp.ADM_GESTION_INCONSISTENCIAS_PRESTADORES ADM_GIP ON ADM_IP.cod_inconsis_prestapp = ADM_GIP.cod_inconsis_prestapp
									INNER JOIN PRESTADORES PRESTAD ON ADM_IP.cod_prestador = PRESTAD.prestad 
									INNER JOIN PRESTAD_LUGARES PRESTAD_L ON PRESTAD_L.prestad = PRESTAD.prestad
									INNER JOIN LOCALIDADES LOCALI ON LOCALI.loca=PRESTAD_L.loca
									INNER JOIN PARTIDOS ON PARTIDOS.partido=LOCALI.partido
									INNER JOIN saludmp.ADM_P_TIPO_DATOPRES ADM_PTD ON ADM_PTD.cod_tipo_datopres = ADM_GIP.cod_tipo_datopres
									INNER JOIN Asesor ASE ON ASE.NumeroDocumento = ADM_GIP.id_asesor
									LEFT JOIN AFILIADOS AFI ON AFI.docu_nro = ADM_IP.id_usuario	
								WHERE 
									PRESTAD.baja_fecha IS NULL
									AND PRESTAD_L.baja_fecha IS NULL
									AND LOCALI.baja_fecha IS NULL
									AND PARTIDOS.baja_fecha IS NULL
									AND ADM_IP.cod_ciudad_prestador = LOCALI.loca
									AND ADM_GIP.cod_inconsis_prestapp = @cod_inconsis_prestapp

								SET @coderror = 0;
								SET @msgerror = 'Se Actualizó El Estado De La Inconsistencia'
						END
					ELSE
						BEGIN

						UPDATE saludmp.ADM_INCONSISTENCIAS_PRESTADORES_X_APP SET cod_estado = @cod_estado WHERE cod_inconsis_prestapp = @cod_inconsis_prestapp

						UPDATE saludmp.ADM_GESTION_INCONSISTENCIAS_PRESTADORES SET cod_estado = @cod_estado, fecha_resuelto = GETDATE(), observaciones_gestion = @observaciones_gestion WHERE  cod_inconsis_prestapp = @cod_inconsis_prestapp 

							SELECT DISTINCT 
									ADM_GIP.cod_inconsis_prestapp,
									ADM_GIP.cod_tipo_datopres,
									ADM_PTD.descripcion AS descripcion_fallo,
									ADM_IP.observacion,
									PRESTAD.prestad AS cod_prestador,
									CASE 
										WHEN PRESTAD.tipo = 'I' THEN PRESTAD.nombre_abre
										ELSE concat(LTRIM(PRESTAD.ape_razon), ' ', PRESTAD.apellido_2, ' ', PRESTAD.nombre_abre, ' ', PRESTAD.nombre_2) 
									END AS nombre_prestador,
									CONVERT(varchar, ADM_IP.fecha_registro, 5) AS fecha_registro,
									ADM_IP.app,
									ADM_IP.tipo_id_usuario,
									RTRIM(ADM_IP.id_usuario) AS id_usuario,
									CONCAT(LTRIM(RTRIM(AFI.nombre)),' ',LTRIM(RTRIM(AFI.nombre2)),' ',LTRIM(RTRIM(AFI.ape)),' ',LTRIM(RTRIM(AFI.ape2))) AS nombre_usuario,
									RTRIM(ADM_GIP.id_asesor) AS id_asesor,
									CONCAT(LTRIM(RTRIM(ASE.PrimerNombre)),' ',LTRIM(RTRIM(ASE.SegundoNombre)), ' ',LTRIM(RTRIM(ASE.PrimerApellido)),' ',LTRIM(RTRIM(ASE.SegundoApellido))) AS nombre_asesor,
									ADM_IP.ruta,
									CONVERT(varchar, ADM_GIP.fecha_asignacion, 5) AS fecha_asignacion,
									CONVERT(varchar, ADM_GIP.fecha_resuelto, 5) AS fecha_resuelto,
									ADM_GIP.observaciones_gestion,
									ADM_IP.cod_estado,
									ADM_EST.descripcion AS estado,
									ADM_GIP.cod_estado AS cod_estado_inconsistencia
								FROM 
									saludmp.ADM_INCONSISTENCIAS_PRESTADORES_X_APP ADM_IP INNER JOIN saludmp.ADM_ESTADOS ADM_EST ON ADM_IP.cod_estado = ADM_EST.id
									INNER JOIN saludmp.ADM_GESTION_INCONSISTENCIAS_PRESTADORES ADM_GIP ON ADM_IP.cod_inconsis_prestapp = ADM_GIP.cod_inconsis_prestapp
									INNER JOIN PRESTADORES PRESTAD ON ADM_IP.cod_prestador = PRESTAD.prestad 
									INNER JOIN PRESTAD_LUGARES PRESTAD_L ON PRESTAD_L.prestad = PRESTAD.prestad
									INNER JOIN LOCALIDADES LOCALI ON LOCALI.loca=PRESTAD_L.loca
									INNER JOIN PARTIDOS ON PARTIDOS.partido=LOCALI.partido
									INNER JOIN saludmp.ADM_P_TIPO_DATOPRES ADM_PTD ON ADM_PTD.cod_tipo_datopres = ADM_GIP.cod_tipo_datopres
									INNER JOIN Asesor ASE ON ASE.NumeroDocumento = ADM_GIP.id_asesor
									LEFT JOIN AFILIADOS AFI ON AFI.docu_nro = ADM_IP.id_usuario	
								WHERE 
									PRESTAD.baja_fecha IS NULL
									AND PRESTAD_L.baja_fecha IS NULL
									AND LOCALI.baja_fecha IS NULL
									AND PARTIDOS.baja_fecha IS NULL
									AND ADM_IP.cod_ciudad_prestador = LOCALI.loca
									AND ADM_GIP.cod_inconsis_prestapp = @cod_inconsis_prestapp

								SET @coderror = 0;
								SET @msgerror = 'Se Actualizó El Estado De La Inconsistencia'

						RETURN
					END
				END
			ELSE
				BEGIN
					SET @coderror = 0;
					SET @msgerror = 'Debe Asignar primero a un Asesor';
					RETURN
				END
		END;
	ELSE
	--asigna una inconsistencia a un asesor
		BEGIN
			
			UPDATE saludmp.ADM_INCONSISTENCIAS_PRESTADORES_X_APP SET cod_estado = 2 WHERE cod_inconsis_prestapp = @cod_inconsis_prestapp;
			UPDATE saludmp.ADM_GESTION_INCONSISTENCIAS_PRESTADORES SET id_asesor = @id_asesor,cod_estado = 2, fecha_asignacion = GETDATE() WHERE cod_inconsis_prestapp = @cod_inconsis_prestapp;

			SELECT DISTINCT 
					ADM_GIP.cod_inconsis_prestapp,
					ADM_GIP.cod_tipo_datopres,
					ADM_PTD.descripcion AS descripcion_fallo,
					ADM_IP.observacion,
					PRESTAD.prestad AS cod_prestador,
					CASE 
						WHEN PRESTAD.tipo = 'I' THEN PRESTAD.nombre_abre
						ELSE concat(LTRIM(PRESTAD.ape_razon), ' ', PRESTAD.apellido_2, ' ', PRESTAD.nombre_abre, ' ', PRESTAD.nombre_2) 
					END AS nombre_prestador,
					CONVERT(varchar, ADM_IP.fecha_registro, 5) AS fecha_registro,
					ADM_IP.app,
					ADM_IP.tipo_id_usuario,
					RTRIM(ADM_IP.id_usuario) AS id_usuario,
					CONCAT(LTRIM(RTRIM(AFI.nombre)),' ',LTRIM(RTRIM(AFI.nombre2)),' ',LTRIM(RTRIM(AFI.ape)),' ',LTRIM(RTRIM(AFI.ape2))) AS nombre_usuario,
					RTRIM(ADM_GIP.id_asesor) AS id_asesor,
					CONCAT(LTRIM(RTRIM(ASE.PrimerNombre)),' ',LTRIM(RTRIM(ASE.SegundoNombre)), ' ',LTRIM(RTRIM(ASE.PrimerApellido)),' ',LTRIM(RTRIM(ASE.SegundoApellido))) AS nombre_asesor,
					ADM_IP.ruta,
					CONVERT(varchar, ADM_GIP.fecha_asignacion, 5) AS fecha_asignacion,
					CONVERT(varchar, ADM_GIP.fecha_resuelto, 5) AS fecha_resuelto,
					ADM_GIP.observaciones_gestion,
					ADM_IP.cod_estado,
					ADM_EST.descripcion AS estado,
					ADM_GIP.cod_estado AS cod_estado_inconsistencia
				FROM 
					saludmp.ADM_INCONSISTENCIAS_PRESTADORES_X_APP ADM_IP 
					INNER JOIN saludmp.ADM_ESTADOS ADM_EST ON ADM_IP.cod_estado = ADM_EST.id
					INNER JOIN saludmp.ADM_GESTION_INCONSISTENCIAS_PRESTADORES ADM_GIP ON ADM_IP.cod_inconsis_prestapp = ADM_GIP.cod_inconsis_prestapp
					INNER JOIN PRESTADORES PRESTAD ON ADM_IP.cod_prestador = PRESTAD.prestad 
					INNER JOIN PRESTAD_LUGARES PRESTAD_L ON PRESTAD_L.prestad = PRESTAD.prestad
					INNER JOIN LOCALIDADES LOCALI ON LOCALI.loca=PRESTAD_L.loca
					INNER JOIN PARTIDOS ON PARTIDOS.partido=LOCALI.partido
					INNER JOIN saludmp.ADM_P_TIPO_DATOPRES ADM_PTD ON ADM_PTD.cod_tipo_datopres = ADM_GIP.cod_tipo_datopres
					INNER JOIN Asesor ASE ON ASE.NumeroDocumento = ADM_GIP.id_asesor
					LEFT JOIN AFILIADOS AFI ON AFI.docu_nro = ADM_IP.id_usuario
				WHERE 
					PRESTAD.baja_fecha IS NULL
					AND PRESTAD_L.baja_fecha IS NULL
					AND LOCALI.baja_fecha IS NULL
					AND PARTIDOS.baja_fecha IS NULL
					AND ADM_IP.cod_ciudad_prestador = LOCALI.loca
					AND ADM_GIP.cod_inconsis_prestapp = @cod_inconsis_prestapp
					AND ASE.NumeroDocumento = ADM_GIP.id_asesor
					AND ASE.FechaAprobacion IS NOT NULL

			SET @coderror = 0;
			SET @msgerror = 'Se Asigno Registro';
    
			RETURN;
		
		END;
	
END;

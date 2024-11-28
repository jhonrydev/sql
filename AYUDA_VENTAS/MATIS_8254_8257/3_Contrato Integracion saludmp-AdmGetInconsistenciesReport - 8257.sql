/*
  Nombre del Stored Procedure: SP_ADM_GET_INCONSISTENCIES_REPORT
  Autor: Jhon Medina
  Fecha de creación: Abril 2024
  Objetivo: Permite obtener todos los registros de reportes de inconsistencias 
*/
CREATE PROCEDURE [saludmp].[SP_ADM_GET_INCONSISTENCIES_REPORT] 
	@coderror INTEGER  =0  OUTPUT,
    @msgerror VARCHAR(500)  =0  OUTPUT,
	@fecha_inicio NVARCHAR(100) = NULL,
	@fecha_fin NVARCHAR(100) = NULL
AS
BEGIN

	IF(@fecha_inicio = '')
		BEGIN
			SET @fecha_inicio = NULL
		END
	  
	IF(@fecha_fin = '')
		BEGIN
			SET @fecha_fin = NULL
		END	

	IF (@fecha_inicio IS NOT NULL AND @fecha_fin IS NOT NULL)
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
				saludmp.ADM_INCONSISTENCIAS_PRESTADORES_X_APP ADM_IP 
				INNER JOIN saludmp.ADM_ESTADOS ADM_EST ON ADM_IP.cod_estado = ADM_EST.id
				INNER JOIN saludmp.ADM_GESTION_INCONSISTENCIAS_PRESTADORES ADM_GIP ON ADM_IP.cod_inconsis_prestapp = ADM_GIP.cod_inconsis_prestapp
				INNER JOIN saludmp.ADM_P_TIPO_DATOPRES ADM_PTD ON ADM_PTD.cod_tipo_datopres = ADM_GIP.cod_tipo_datopres
				INNER JOIN PRESTADORES PRESTAD ON ADM_IP.cod_prestador = PRESTAD.prestad 
				INNER JOIN PRESTAD_LUGARES PRESTAD_L ON PRESTAD_L.prestad = PRESTAD.prestad
				INNER JOIN LOCALIDADES LOCALI ON LOCALI.loca=PRESTAD_L.loca
				INNER JOIN PARTIDOS ON PARTIDOS.partido=LOCALI.partido
				LEFT JOIN Asesor ASE ON ASE.NumeroDocumento = ADM_GIP.id_asesor
				LEFT JOIN AFILIADOS AFI ON AFI.docu_nro = ADM_IP.id_usuario
			WHERE 
				PRESTAD.baja_fecha IS NULL
				AND PRESTAD_L.baja_fecha IS NULL
				AND LOCALI.baja_fecha IS NULL
				AND PARTIDOS.baja_fecha IS NULL
				AND ADM_IP.cod_ciudad_prestador = LOCALI.loca
				AND ADM_IP.cod_estado IN (1,2,3)
				AND ADM_IP.fecha_registro BETWEEN @fecha_inicio AND @fecha_fin
			ORDER BY ADM_IP.cod_estado

			SET @coderror = 0
			SET @msgerror = 'Lista De Reporte De Fallos'
			RETURN
		END
	ELSE
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
				saludmp.ADM_INCONSISTENCIAS_PRESTADORES_X_APP ADM_IP 
				INNER JOIN saludmp.ADM_ESTADOS ADM_EST ON ADM_IP.cod_estado = ADM_EST.id
				INNER JOIN saludmp.ADM_GESTION_INCONSISTENCIAS_PRESTADORES ADM_GIP ON ADM_IP.cod_inconsis_prestapp = ADM_GIP.cod_inconsis_prestapp
				INNER JOIN saludmp.ADM_P_TIPO_DATOPRES ADM_PTD ON ADM_PTD.cod_tipo_datopres = ADM_GIP.cod_tipo_datopres
				INNER JOIN PRESTADORES PRESTAD ON ADM_IP.cod_prestador = PRESTAD.prestad 
				INNER JOIN PRESTAD_LUGARES PRESTAD_L ON PRESTAD_L.prestad = PRESTAD.prestad
				INNER JOIN LOCALIDADES LOCALI ON LOCALI.loca=PRESTAD_L.loca
				INNER JOIN PARTIDOS ON PARTIDOS.partido=LOCALI.partido
				LEFT JOIN Asesor ASE ON ASE.NumeroDocumento = ADM_GIP.id_asesor
				LEFT JOIN AFILIADOS AFI ON AFI.docu_nro = ADM_IP.id_usuario
			WHERE 
				PRESTAD.baja_fecha IS NULL
				AND PRESTAD_L.baja_fecha IS NULL
				AND LOCALI.baja_fecha IS NULL
				AND PARTIDOS.baja_fecha IS NULL
				AND ADM_IP.cod_ciudad_prestador = LOCALI.loca
				-- AND ADM_IP.fecha_registro BETWEEN @fecha_inicio AND @fecha_fin
			ORDER BY ADM_IP.cod_estado
			
			SET @coderror = 0
			SET @msgerror = 'Lista De Reporte De Fallos'
			RETURN
		END
END;
GO

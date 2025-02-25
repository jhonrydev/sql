SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [saludmp].[GET_CERTIFICADOS_AFILIADOS]
       @coderror INTEGER = 0 OUTPUT,
       @msgerror VARCHAR(500) = 0 OUTPUT,
       @prm_docu_nro NVARCHAR(1000)
AS  
      SET NOCOUNT ON

		IF ( @prm_docu_nro IS NULL OR @prm_docu_nro = '') 
        BEGIN 
            SET @coderror = 5;
            SET @msgerror = 'Debe ingresar el valor de prm_docu_nro es obligatorio.';
            GOTO ERROR;
        END;
	  
		-- DECLARE @titular NVARCHAR = NULL
	   
		-- Guarde la lista de todos los documentos que vienen por @prm_docu_nro
		CREATE TABLE #Documentos (documento NVARCHAR(MAX))

		INSERT INTO #Documentos (documento)
			SELECT Value
			FROM dbo.fn_Split(@prm_docu_nro, ',');
		
		-- Guarda todo los contratos asociados a un a los documentos de la tabla #Documentos
		CREATE TABLE #tmp (contra VARCHAR(50))
	
		INSERT INTO #tmp
			SELECT contra FROM afiliados a WHERE docu_nro IN (SELECT * FROM #Documentos)
			UNION 
			SELECT contra FROM afi_resp_pagador af WHERE docu_nro IN (SELECT * FROM #Documentos)
				
		SELECT 
			LTRIM((CONCAT(RTRIM(LTRIM(a.ape)), +' '+RTRIM(LTRIM(a.ape2))+ ' '+RTRIM(LTRIM(a.nombre)),+' '+RTRIM(LTRIM(a.nombre2))) )) AS nombreAfiliado,
			SUBT.deno AS tipoPlan,
			RTRIM(p.deno) AS programa,
			RTRIM(a.contra) AS codigoContrato,
			CONVERT(VARCHAR, ap.vigen_desde, 23) AS fechaInicio,a.docu_nro
		FROM afiliados a
			INNER JOIN AFI_CREDENCIALES afc ON afc.contra=a.contra AND afc.inte=a.inte
			INNER JOIN AFI_PLANES ap ON ap.contra=a.contra
			INNER JOIN PLANES p ON p.plan_codi = ap.plan_codi
			INNER JOIN dbo.AFI_CLASE AC ON AC.contra=A.contra
			INNER JOIN dbo.SUBCTA_CONTRATO SUBC ON AC.cuenta = SUBC.CUENTA AND AC.SUBCTA = SUBC.SUBCTA
			INNER JOIN dbo.SUBCTA_TIPOS SUBT ON SUBC.SUBCTA_TIPO = SUBT.SUBCTA_TIPO
		WHERE 
			a.contra in (SELECT * FROM #tmp)
			AND a.docu_nro IN (SELECT * FROM #Documentos)
			AND ((CAST(a.realbaja_fecha AS DATE) > (CAST(GETDATE() AS DATE))) OR a.realbaja_fecha IS NULL)
			AND a.baja_fecha IS NULL
			AND a.inte IS NOT NULL
		GROUP BY 
		p.deno,
		a.contra,
		ap.vigen_desde,
		SUBT.deno,
		a.nombre, 
		a.nombre2,
		a.ape,
		a.ape2,
		a.docu_nro
		ORDER BY nombreAfiliado
		SET @coderror = 0
		SET @msgerror = 'Ok'
		
	DROP TABLE #tmp
	DROP TABLE #Documentos

	ERROR:
        SELECT @coderror AS codigo_error, @msgerror AS msg_error
        RETURN
GO

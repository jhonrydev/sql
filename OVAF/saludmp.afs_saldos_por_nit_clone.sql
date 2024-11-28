

ALTER PROCEDURE [saludmp].[afs_saldos_por_nit_clone] ( 
 @prm_docu_tipo CHAR (2) ,
 @prm_docu_nro CHAR(15) ,
 @prm_error TINYINT = NULL OUTPUT,
 @prm_error_deno VARCHAR(100) = NULL OUTPUT
 )
 
AS
SET NOCOUNT ON 
BEGIN
 --Registración en Log de Eventos
 DECLARE @var_cantidad INT,
 @var_fecha_proc DATETIME,
 @var_cod_unico_persona INT,
 --WS_LOG_EVENTOS
 @out_id_log_evento INTEGER,
 @con_sistema CHAR(20),
 @var_param_entrada VARCHAR(255),
 @var_param_salida VARCHAR(255)
 
 SET @var_fecha_proc = GETDATE()
 SET @con_sistema = 'CANALES_DIGITALES'
 SET @var_param_entrada = CONCAT('docu_tipo: ',RTRIM(@prm_docu_tipo) + ' docu_nro: ', RTRIM(@prm_docu_nro))
 
	CREATE TABLE #COMPROBANTES_TEMP
	( 
	valor_corriente DECIMAL(18,0),
	valor_vencido DECIMAL(18,0),
	valor_pagar DECIMAL(18,0),
	consecutivo INT ,
	sucur_deno VARCHAR (50) ,
	subcta_tipo_deno VARCHAR (100) ,
	plan_codi CHAR (10) ,
	fecha_vto DATETIME ,
	contra CHAR (15) ,
	factu_concep CHAR (3) ,
	saldo DECIMAL(18,0) ,
	valor_base_saldo DECIMAL(18,0) ,
	iva_saldo DECIMAL(18,0) , 
	linea_negocio CHAR (5)
	)
		
	EXECUTE dbo.afu_ws_log_eventos @prm_id = @out_id_log_evento OUTPUT,
	@prm_sistema = @con_sistema,
	@prm_fecha_entrada = @var_fecha_proc,
	@prm_param_entrada = @var_param_entrada
	/****Validación de los parámetros de entrada****/
 
 SELECT @var_cod_unico_persona = codigo_unico_persona 
 FROM REGISTRO_UNICO_DOCUMENTO (NOLOCK)
 WHERE docu_tipo = @prm_docu_tipo
 AND docu_nro = @prm_docu_nro
	
	IF @var_cod_unico_persona IS NULL
		BEGIN 
		SET @prm_error = 1
		SET @prm_error_deno = 'El contratante no existe.'
		
		EXECUTE dbo.afu_ws_log_eventos @prm_id = @out_id_log_evento,
		@prm_codigo_error = @prm_error,
		@prm_descripcion_error = @prm_error_deno
		RETURN
	END
 /****Validación de los parámetros de entrada****/
 /*CONTRATOS INDIVIDUALES O ACUERDOS CORPORATIVOS*/
 INSERT INTO #COMPROBANTES_TEMP
	(
	valor_corriente,
	valor_vencido,
	valor_pagar,
	consecutivo ,
	sucur_deno ,
	subcta_tipo_deno ,
	plan_codi ,
	fecha_vto ,
	contra ,
	factu_concep ,
	saldo ,
	valor_base_saldo ,
	iva_saldo ,
	linea_negocio
	)
 SELECT DISTINCT
	A.valor_corriente,
	A.valor_vencido,
	A.valor_pagar,
	MAX(A.consecutivo) AS consecutivo,
	A.sucur_deno,
	subcta_tipo_deno ,
	A.plan_codi,
	(SELECT TOP 1
		CASE 
		--	WHEN C2.fecha_vto < GETDATE() 
			WHEN FORMAT(C2.fecha_vto,'yyyy-MM-dd') <= FORMAT(GETDATE(),'yyyy-MM-dd')
				THEN   MAX(C2.fecha_vto) 
				ELSE MAX(C2.fecha_vto) 
		END
	FROM COMPROBANTES C2  (NOLOCK)
	WHERE C2.contra = A.contra
	GROUP BY C2.fecha_vto
	ORDER BY C2.fecha_vto DESC) AS fecha_vto,
	A.contra, 
	A.factu_concep ,
	(SELECT  SUM(CI1.saldo )
		FROM COMPROBANTES C3 (NOLOCK)
		INNER JOIN COMPRO_ITEMS CI1 (NOLOCK)
		ON C3.ente = CI1.ente
		AND C3.compro_tipo = CI1.compro_tipo
		AND C3.compro_nro = CI1.compro_nro
		WHERE C3.contra = A.contra) AS saldo ,
	(SELECT SUM(CONVERT(DECIMAL(18,0), CI1.saldo / (1+CI1.alicuota_iva/100)) )
		FROM COMPROBANTES C3 (NOLOCK)
		INNER JOIN COMPRO_ITEMS CI1 (NOLOCK)
		ON C3.ente = CI1.ente
		AND C3.compro_tipo = CI1.compro_tipo
		AND C3.compro_nro = CI1.compro_nro
		WHERE C3.contra = A.contra AND FORMAT(C3.fecha_vto,'yyyy-MM-dd') >= FORMAT(GETDATE(),'yyyy-MM-dd')) AS valor_base_saldo ,
	(SELECT SUM (CI1.saldo - CONVERT(DECIMAL(18,0), CI1.saldo / (1+CI1.alicuota_iva/100)) )
		FROM COMPROBANTES C3 (NOLOCK)
		INNER JOIN COMPRO_ITEMS CI1 (NOLOCK)
		ON C3.ente = CI1.ente
		AND C3.compro_tipo = CI1.compro_tipo
		AND C3.compro_nro = CI1.compro_nro
		WHERE C3.contra = A.contra
		AND FORMAT(C3.fecha_vto,'yyyy-MM-dd') < FORMAT(GETDATE(),'yyyy-MM-dd')) AS iva_saldo ,
		A.linea_negocio
FROM (
	SELECT
 		(select TOP 1 CONVERT(DECIMAL(18,0), CI.saldo / (1+CI.alicuota_iva/100))
			FROM COMPROBANTES C2 (NOLOCK)
			INNER JOIN COMPRO_ITEMS CI (NOLOCK)
			ON C2.ente = CI.ente
			AND C2.compro_tipo = CI.compro_tipo
			AND C2.compro_nro = CI.compro_nro
			AND C2.contra = C.contra
			INNER JOIN COMPRO_TIPOS CT (NOLOCK)
			ON C2.compro_tipo = CT.compro_tipo
			INNER JOIN PARTIDOS P (NOLOCK)
			ON P.partido = C2.suc_comercializable
			INNER JOIN SUBCTA_TIPOS ST (NOLOCK)
			ON ST.subcta_tipo = C2.subcta_tipo
			INNER JOIN PLANES PL (NOLOCK)
			ON C2.plan_codi = PL.plan_codi 
			INNER JOIN PLANES_GRUPOS PG (NOLOCK)
			ON PL.plan_grupo = PG.plan_grupo
			WHERE C2.id_contratante = @var_cod_unico_persona
			AND ST.subcta_tipo IN ('F', 'A')
			AND NOT EXISTS ( SELECT 1 --no es reversado
			FROM COMPRO_REVERSO_DET CRT  WITH (index(ndx_compro_reverso_det1)) 
			WHERE CRT.ente = C2.ente
			AND CRT.compro_tipo = C2.compro_tipo
			AND CRT.compro_nro = C2.compro_nro
			)
			AND NOT EXISTS ( SELECT 1 --no es reversado
			FROM COMPRO_REVERSO_DET CRT WITH (index(ndx_compro_reverso_det2))
			WHERE CRT.ente = C2.ente
			AND CRT.compro_tipo_rev = C2.compro_tipo
			AND CRT.compro_nro_rev = C2.compro_nro
			)
			AND C2.aplica = 1 
			AND CT.debi_credi = 1 --DÉBITO
			AND CT.usa_castigo_cartera = 'N'
			AND CT.uso_plan_anual = 'N'
			AND C2.saldo > 0
			AND C2.baja_fecha IS NULL
			ORDER BY C2.fecha_vto desc
		)  AS valor_corriente,
		CASE WHEN
		(select SUM(CONVERT(DECIMAL(18,0), CI.saldo / (1+CI.alicuota_iva/100)))
			FROM COMPROBANTES C2 (NOLOCK)
			INNER JOIN COMPRO_ITEMS CI (NOLOCK)
			ON C2.ente = CI.ente
			AND C2.compro_tipo = CI.compro_tipo
			AND C2.compro_nro = CI.compro_nro
			AND C2.contra = C.contra
			INNER JOIN COMPRO_TIPOS CT (NOLOCK)
			ON C2.compro_tipo = CT.compro_tipo
			INNER JOIN PARTIDOS P (NOLOCK)
			ON P.partido = C2.suc_comercializable
			INNER JOIN SUBCTA_TIPOS ST (NOLOCK)
			ON ST.subcta_tipo = C2.subcta_tipo
			INNER JOIN PLANES PL (NOLOCK)
			ON C2.plan_codi = PL.plan_codi 
			INNER JOIN PLANES_GRUPOS PG (NOLOCK)
			ON PL.plan_grupo = PG.plan_grupo
			WHERE C2.id_contratante = @var_cod_unico_persona
			AND ST.subcta_tipo IN ('F', 'A')
			AND NOT EXISTS ( SELECT 1 --no es reversado
			FROM COMPRO_REVERSO_DET CRT WITH (index(ndx_compro_reverso_det1))
			WHERE CRT.ente = C2.ente
			AND CRT.compro_tipo = C2.compro_tipo
			AND CRT.compro_nro = C2.compro_nro
			)
			AND NOT EXISTS ( SELECT 1 --no es reversado
			FROM COMPRO_REVERSO_DET CRT WITH (index(ndx_compro_reverso_det2))
			WHERE CRT.ente = C2.ente
			AND CRT.compro_tipo_rev = C2.compro_tipo
			AND 
			CRT.compro_nro_rev = C2.compro_nro
			)
			AND C2.aplica = 1 
			AND CT.debi_credi = 1 --DÉBITO
			AND CT.usa_castigo_cartera = 'N'
			AND CT.uso_plan_anual = 'N'
			AND C2.saldo > 0
			AND C2.baja_fecha IS NULL
			AND FORMAT(C2.fecha_vto,'yyyy-MM-dd') < FORMAT(GETDATE(),'yyyy-MM-dd')
		) IS NULL THEN 0 
		ELSE (
		SELECT SUM(CONVERT(DECIMAL(18,0), CI.saldo / (1+CI.alicuota_iva/100)))
			FROM COMPROBANTES C2 (NOLOCK)
			INNER JOIN COMPRO_ITEMS CI (NOLOCK)
			ON C2.ente = CI.ente
			AND C2.compro_tipo = CI.compro_tipo
			AND C2.compro_nro = CI.compro_nro
			AND C2.contra = C.contra
			INNER JOIN COMPRO_TIPOS CT (NOLOCK)
			ON C2.compro_tipo = CT.compro_tipo
			INNER JOIN PARTIDOS P (NOLOCK)
			ON P.partido = C2.suc_comercializable
			INNER JOIN SUBCTA_TIPOS ST (NOLOCK)
			ON ST.subcta_tipo = C2.subcta_tipo
			INNER JOIN PLANES PL (NOLOCK)
			ON C2.plan_codi = PL.plan_codi 
			INNER JOIN PLANES_GRUPOS PG (NOLOCK)
			ON PL.plan_grupo = PG.plan_grupo
			WHERE C2.id_contratante = @var_cod_unico_persona
			AND ST.subcta_tipo IN ('F', 'A')
			AND NOT EXISTS ( SELECT 1 --no es reversado
			FROM COMPRO_REVERSO_DET CRT WITH (index(ndx_compro_reverso_det1))
			WHERE CRT.ente = C2.ente
			AND CRT.compro_tipo = C2.compro_tipo
			AND CRT.compro_nro = C2.compro_nro
			)
			AND NOT EXISTS ( SELECT 1 --no es reversado
			FROM COMPRO_REVERSO_DET CRT WITH (index(ndx_compro_reverso_det2))
			WHERE CRT.ente = C2.ente
			AND CRT.compro_tipo_rev = C2.compro_tipo
			AND 
			CRT.compro_nro_rev = C2.compro_nro
			)
			AND C2.aplica = 1 
			AND CT.debi_credi = 1 --DÉBITO
			AND CT.usa_castigo_cartera = 'N'
			AND CT.uso_plan_anual = 'N'
			AND C2.saldo > 0
			AND C2.baja_fecha IS NULL
			AND FORMAT(C2.fecha_vto,'yyyy-MM-dd') < FORMAT(GETDATE(),'yyyy-MM-dd')
		) END AS valor_vencido,
		(SELECT SUM(CI.saldo)
			FROM COMPROBANTES C2 (NOLOCK)
			INNER JOIN COMPRO_ITEMS CI (NOLOCK)
			ON C2.ente = CI.ente
			AND C2.compro_tipo = CI.compro_tipo
			AND C2.compro_nro = CI.compro_nro
			AND C2.contra = C.contra
			INNER JOIN COMPRO_TIPOS CT (NOLOCK)
			ON C2.compro_tipo = CT.compro_tipo
			INNER JOIN PARTIDOS P (NOLOCK)
			ON P.partido = C2.suc_comercializable
			INNER JOIN SUBCTA_TIPOS ST (NOLOCK)
			ON ST.subcta_tipo = C2.subcta_tipo
			INNER JOIN PLANES PL (NOLOCK)
			ON C2.plan_codi = PL.plan_codi 
			INNER JOIN PLANES_GRUPOS PG (NOLOCK)
			ON PL.plan_grupo = PG.plan_grupo
			WHERE C2.id_contratante = @var_cod_unico_persona
			AND ST.subcta_tipo IN ('F', 'A')
			AND NOT EXISTS ( SELECT 1 --no es reversado
			FROM COMPRO_REVERSO_DET CRT WITH (index(ndx_compro_reverso_det1))
			WHERE CRT.ente = C2.ente
			AND CRT.compro_tipo = C2.compro_tipo
			AND CRT.compro_nro = C2.compro_nro
			)
			AND NOT EXISTS ( SELECT 1 --no es reversado
			FROM COMPRO_REVERSO_DET CRT WITH (index(ndx_compro_reverso_det2))
			WHERE CRT.ente = C2.ente
			AND CRT.compro_tipo_rev = C2.compro_tipo
			AND 
			CRT.compro_nro_rev = C2.compro_nro
			)
			AND C2.aplica = 1 
			AND CT.debi_credi = 1 --DÉBITO
			AND CT.usa_castigo_cartera = 'N'
			AND CT.uso_plan_anual = 'N'
			AND C2.saldo > 0
			AND C2.baja_fecha IS NULL
		) AS valor_pagar,
		consecutivo = C.cod_unico_comprobante ,
		sucur_deno = P.descripcion ,
		subcta_tipo_deno = ST.deno ,
		plan_codi = C.plan_codi ,
		fecha_vto = C.fecha_vto ,
		contra = C.contra,
		factu_concep = CI.factu_concep ,
		saldo = CI.saldo,
		valor_base_saldo = CONVERT(DECIMAL(18,0), CI.saldo / (1+CI.alicuota_iva/100)),
		iva_saldo = CI.saldo - CONVERT(DECIMAL(18,0), CI.saldo / (1+CI.alicuota_iva/100)),
		linea_negocio = PG.linea_negocio
		FROM COMPROBANTES C (NOLOCK)
		LEFT JOIN AFILIADOS AFD (NOLOCK)
		ON C.contra = AFD.contra
		INNER JOIN COMPRO_ITEMS CI (NOLOCK)
		ON C.ente = CI.ente
		AND C.compro_tipo = CI.compro_tipo
		AND C.compro_nro = CI.compro_nro
		INNER JOIN COMPRO_TIPOS CT (NOLOCK)
		ON C.compro_tipo = CT.compro_tipo
		INNER JOIN PARTIDOS P (NOLOCK)
		ON P.partido = C.suc_comercializable
		INNER JOIN SUBCTA_TIPOS ST (NOLOCK)
		ON ST.subcta_tipo = C.subcta_tipo
		INNER JOIN PLANES PL (NOLOCK)
		ON C.plan_codi = PL.plan_codi
		INNER JOIN PLANES_GRUPOS PG (NOLOCK)
		ON PL.plan_grupo = PG.plan_grupo
		WHERE C.id_contratante = @var_cod_unico_persona
		AND ST.subcta_tipo IN ('F', 'A')
		AND NOT EXISTS ( SELECT 1 --no es reversado
		FROM COMPRO_REVERSO_DET CRT WITH (index(ndx_compro_reverso_det1))
		WHERE CRT.ente = C.ente
		AND CRT.compro_tipo = C.compro_tipo
		AND CRT.compro_nro = C.compro_nro
		)
		AND NOT EXISTS ( SELECT 1 --no es reversado
		FROM COMPRO_REVERSO_DET CRT WITH (index(ndx_compro_reverso_det2))
		WHERE CRT.ente = C.ente
		AND CRT.compro_tipo_rev = C.compro_tipo
		AND 
		CRT.compro_nro_rev = C.compro_nro
		)
		AND C.aplica = 1 
		AND CT.debi_credi = 1 --DÉBITO
		AND CT.usa_castigo_cartera = 'N'
		AND CT.uso_plan_anual = 'N'
		AND C.saldo > 0
		AND C.baja_fecha IS NULL
		AND ((AFD.realbaja_fecha IS NOT NULL AND FORMAT(AFD.realbaja_fecha,'yyyy-MM-dd') >= FORMAT(GETDATE(),'yyyy-MM-dd')) OR AFD.realbaja_fecha IS NULL)
	) A
	where A.plan_codi not like'%CEM%'
	GROUP BY
	valor_corriente,
	valor_vencido,
	valor_pagar,
	sucur_deno ,
	subcta_tipo_deno ,
	plan_codi ,
	contra ,
	factu_concep ,
	linea_negocio
 
 SELECT 
 valor_corriente = valor_base_saldo,	
 valor_vencido = valor_vencido, 
 valor_pagar = valor_pagar,
 consecutivo = consecutivo ,
 descripcionSucursal = sucur_deno ,
 "plan" = subcta_tipo_deno ,
 programa = plan_codi ,
 fecha_vto = fecha_vto ,
 contra = contra , 
 saldo = saldo,
 valor_base_saldo = valor_base_saldo ,
 iva_saldo = iva_saldo ,
 linea_negocio = linea_negocio
 FROM #COMPROBANTES_TEMP
 GROUP BY 
 valor_corriente,
 valor_vencido,
 valor_pagar,
 consecutivo ,
 sucur_deno ,
 subcta_tipo_deno ,
 plan_codi ,
 fecha_vto ,
 contra ,
 saldo,
 iva_saldo,
 valor_base_saldo,
 linea_negocio order by fecha_vto DESC
 SET @var_cantidad = @@ROWCOUNT 
 SET @var_fecha_proc = GETDATE()
 SET @var_param_salida = CONVERT(VARCHAR,@var_cantidad) + ' Comprobantes'
 EXECUTE dbo.afu_ws_log_eventos @prm_id = @out_id_log_evento,
 @prm_param_salida = @var_param_salida,
 @prm_fecha_salida = @var_fecha_proc

END;

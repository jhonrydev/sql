USE [PreCoreMP]
GO
/****** Object:  StoredProcedure [saludmp].[afs_saldos_por_nit]    Script Date: 18/06/2024 9:53:00 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
 PROCEDURE : afs_saldos_por_nit
 Programmer : RS
 Parameters : 
 Description : 
 History :
 BUG DATE PROGRAMMER DESCRIPTION REFERENCE
 17763 20200515 RS Se creó el SP.
 R17892 20200528 NPAZ Crear sp para loguear en WS_LOG_EVENTOS
*/
ALTER PROCEDURE [saludmp].[afs_saldos_por_nit] ( 
 @prm_docu_tipo CHAR (2) ,
 @prm_docu_nro CHAR(15) ,
 @prm_error TINYINT = NULL OUTPUT,
 @prm_error_deno VARCHAR(100) = NULL OUTPUT
 )
 
AS
BEGIN
 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
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
 consecutivo INT ,
 sucur_deno VARCHAR (50) ,
 subcta_tipo_deno VARCHAR (100) ,
 plan_codi CHAR (10) ,
 contra CHAR (15) ,
 factu_concep CHAR (3) ,
 fecha_vto DATETIME ,
 saldo DECIMAL(18,0) ,
 valor_base_saldo DECIMAL(18,0) ,
 iva_saldo DECIMAL(18,0) , 
 linea_negocio CHAR (5),
 tipo_comprobante CHAR (5), --se agrego para identificar los comprobantesnjimb8316
 codigo_dian VARCHAR(100) NULL,
 saldo_seguro DECIMAL(18,0) NULL,
 saldo_sin_seguro DECIMAL(18,0) NULL,
 comprobante_ec INTEGER NULL
 )
 EXECUTE dbo.afu_ws_log_eventos @prm_id = @out_id_log_evento OUTPUT,
 @prm_sistema = @con_sistema,
 @prm_fecha_entrada = @var_fecha_proc,
 @prm_param_entrada = @var_param_entrada
 /****Validación de los parámetros de entrada****/
 
 SELECT @var_cod_unico_persona = codigo_unico_persona 
 FROM REGISTRO_UNICO_DOCUMENTO
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
 linea_negocio ,
 tipo_comprobante,  --se agrego para identificar los comprobantesnjimb8316
 codigo_dian ,
 saldo_seguro ,
 saldo_sin_seguro ,
 comprobante_ec 
 )
 SELECT consecutivo = C.cod_unico_comprobante ,
 sucur_deno = P.descripcion ,
 subcta_tipo_deno = ST.deno ,
 plan_codi = C.plan_codi ,
 fecha_vto = C.fecha_vto ,
 contra = C.contra ,
 factu_concep = CI.factu_concep ,
 saldo = CI.saldo ,
 valor_base_saldo = CONVERT(DECIMAL(18,0), CI.saldo / (1+CI.alicuota_iva/100)),
 iva_saldo = CI.saldo - CONVERT(DECIMAL(18,0), CI.saldo / (1+CI.alicuota_iva/100)),
 linea_negocio = PG.linea_negocio,
 tipo_comprobante = C.compro_tipo,  --se agrego para identificar los comprobantesnjimb8316
 codigo_dian = CASE WHEN CT.legal_inter = 'S' THEN SUBSTRING(C.compro_nro, 6, 8) ELSE NULL END,
 saldo_seguro = CASE WHEN CON.es_seguro = 'S' THEN CI.saldo ELSE 0 END,
 saldo_sin_seguro = CASE WHEN CON.es_seguro = 'N' THEN CI.saldo ELSE 0 END,
 comprobante_ec = EC.cod_unico_comprobante
 FROM COMPROBANTES C
 INNER JOIN COMPRO_ITEMS CI
 ON C.ente = CI.ente
 AND C.compro_tipo = CI.compro_tipo
 AND C.compro_nro = CI.compro_nro
 INNER JOIN COMPRO_TIPOS CT
 ON C.compro_tipo = CT.compro_tipo
 INNER JOIN PARTIDOS P
 ON P.partido = C.suc_comercializable
 INNER JOIN SUBCTA_TIPOS ST
 ON ST.subcta_tipo = C.subcta_tipo
 INNER JOIN PLANES PL
 ON C.plan_codi = PL.plan_codi
 
 INNER JOIN PLANES_GRUPOS PG
 ON PL.plan_grupo = PG.plan_grupo
 
 INNER JOIN AFI_CLASE AC
 ON C.prepaga = AC.prepaga
 AND C.contra = AC.contra
 AND AC.vigen_desde = (SELECT MAX(vigen_desde) 
 FROM AFI_CLASE
 WHERE AC.prepaga = prepaga
 AND AC.contra = contra
 AND (baja_fecha IS NULL OR baja_fecha > @var_fecha_proc)
 )
 INNER JOIN FACTU_CONCEPTOS AS CON
 ON CI.factu_concep = CON.factu_concep
 LEFT JOIN COMPRO_AGRUPADORES AS AG
 ON C.ente = AG.ente
 AND C.compro_tipo = AG.compro_tipo
 AND C.compro_nro = AG.compro_nro
 AND AG.compro_tipo_agrupador = 'EC'
 LEFT JOIN COMPROBANTES AS EC
 ON AG.ente = EC.ente
 AND AG.compro_tipo_agrupador = EC.compro_tipo
 AND AG.compro_nro_agrupador = EC.compro_nro
 WHERE C.id_contratante = @var_cod_unico_persona
 AND (AC.baja_fecha IS NULL OR AC.baja_fecha > @var_fecha_proc)
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
 UNION ALL
 SELECT consecutivo = C.cod_unico_comprobante ,
 sucur_deno = P.descripcion ,
 subcta_tipo_deno = ST.deno ,
 plan_codi = C2.plan_codi ,
 fecha_vto = C.fecha_vto ,
 contra = C2.contra ,
 factu_concep = CI.factu_concep ,
 saldo = CI.saldo ,
 valor_base_saldo = CONVERT(DECIMAL(18,0), CI.saldo / (1+CI.alicuota_iva/100)),
 iva_saldo = CI.saldo - CONVERT(DECIMAL(18,0), CI.saldo / (1+CI.alicuota_iva/100)),
 linea_negocio = PG.linea_negocio,
 tipo_comprobante = C.compro_tipo,  --se agrego para identificar los comprobantesnjimb8316
 codigo_dian = CASE WHEN CT.legal_inter = 'L' THEN SUBSTRING(C.compro_nro, 6, 8) ELSE NULL END,
 saldo_seguro = CASE WHEN CON.es_seguro = 'S' THEN CI.saldo ELSE 0 END,
 saldo_sin_seguro = CASE WHEN CON.es_seguro = 'N' THEN CI.saldo ELSE 0 END,
 comprobante_ec = NULL
 FROM COMPROBANTES C
 INNER JOIN COMPRO_TIPOS CT
 ON C.compro_tipo = CT.compro_tipo
 --INNER JOIN COMPRO_AGRUPADORES AS CAG
 --ON C.ente = CAG.ente 
 --AND C.compro_tipo = CAG.compro_tipo_agrupador
 --AND C.compro_nro = CAG.compro_nro_agrupador
 INNER JOIN COMPRO_AGRUPADORES AS CAG2
 ON C.ente = CAG2.ente 
 AND C.compro_tipo = CAG2.compro_tipo_agrupador
 AND C.compro_nro = CAG2.compro_nro_agrupador
 INNER JOIN COMPROBANTES AS C2
 ON CAG2.ente = C2.ente
 AND CAG2.compro_tipo = C2.compro_tipo
 AND CAG2.compro_nro = C2.compro_nro
 INNER JOIN COMPRO_ITEMS CI
 ON C2.ente = CI.ente
 AND C2.compro_tipo = CI.compro_tipo
 AND C2.compro_nro = CI.compro_nro
 
 INNER JOIN PARTIDOS P
 ON P.partido = C2.suc_comercializable
 INNER JOIN SUBCTA_TIPOS ST
 ON ST.subcta_tipo = C2.subcta_tipo
 INNER JOIN PLANES PL
 ON C2.plan_codi = PL.plan_codi
 
 INNER JOIN PLANES_GRUPOS PG
 ON PL.plan_grupo = PG.plan_grupo
 
 INNER JOIN AFI_CLASE AC
 ON C2.prepaga = AC.prepaga
 AND C2.contra = AC.contra
 AND AC.vigen_desde = (SELECT MAX(vigen_desde) 
 FROM AFI_CLASE
 WHERE AC.prepaga = prepaga
 AND AC.contra = contra
 AND (baja_fecha IS NULL OR baja_fecha > @var_fecha_proc)
 )
 
 INNER JOIN FACTU_CONCEPTOS AS CON
 ON CI.factu_concep = CON.factu_concep
 
 WHERE C2.id_contratante = @var_cod_unico_persona
 AND (AC.baja_fecha IS NULL OR AC.baja_fecha > @var_fecha_proc)
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
 AND CRT.compro_nro_rev = C2.compro_nro
 ) 
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
 AND CRT.compro_nro_rev = C.compro_nro
 ) 
 AND C2.saldo > 0
 AND C2.baja_fecha IS NULL
 AND C.compro_tipo IN ('FC', 'AP')
 
 SELECT consecutivo = consecutivo ,
 descripcionSucursal = sucur_deno ,
 "plan" = subcta_tipo_deno ,
 programa = plan_codi ,
 fecha_vto = fecha_vto ,
 contra = contra ,
 saldo = SUM(saldo) ,
 valor_base_saldo = SUM(valor_base_saldo) ,
 iva_saldo = SUM(iva_saldo) ,
 linea_negocio = linea_negocio ,
 tipo_comprobante,  --se agrego para identificar los comprobantesnjimb8316
 codigo_dian = codigo_dian ,
 saldo_seguro = SUM(saldo_seguro) ,
 saldo_sin_seguro = SUM(saldo_sin_seguro) ,
 comprobante_ec = comprobante_ec
 FROM #COMPROBANTES_TEMP
 GROUP BY consecutivo ,
 sucur_deno ,
 subcta_tipo_deno ,
 plan_codi ,
 fecha_vto ,
 contra ,
 linea_negocio ,
 tipo_comprobante,  --se agrego para identificar los comprobantesnjimb8316
 codigo_dian , 
 comprobante_ec
 SET @var_cantidad = @@ROWCOUNT 
 SET @var_fecha_proc = GETDATE()
 SET @var_param_salida = CONVERT(VARCHAR,@var_cantidad) + ' Comprobantes'
 EXECUTE dbo.afu_ws_log_eventos @prm_id = @out_id_log_evento,
 @prm_param_salida = @var_param_salida,
 @prm_fecha_salida = @var_fecha_proc
END 
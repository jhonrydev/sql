USE [PreCoreMP]
GO
/****** Object:  StoredProcedure [saludmp].[Sp_consultaAfiliadoCore]    Script Date: 3/02/2025 10:52:54 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [saludmp].[Sp_consultaAfiliadoCore]
       @coderror INTEGER  =0  output,
       @msgerror VARCHAR(500)  =0  output,
	   @tipo_id varchar(2),
       @id varchar(20)
AS  
BEGIN
/*QUERY PARA CONTRATOS DE RESPONSABLE PAGADOR CON SERVICIO*/
SELECT 
RTRIM(CONCAT(RTRIM(a.NOMBRE), ' ', ISNULL(RTRIM(a.NOMBRE2), ''), ' ', RTRIM(a.APE), ' ', ISNULL(RTRIM(a.APE2), ''))) AS nombreAfiliado,
RTRIM(a.DOCU_NRO) AS numIdentificacion,
RTRIM(a.docu_tipo) AS tipoIdentificacion,
RTRIM(PLA.plan_codi) AS programa,
RTRIM(PLA.DENO) AS nomPrograma,
RTRIM(PLA.carti) AS numCartilla ,
CONVERT(varchar, a.NACI_FECHA, 112) AS fechaNacimiento,
RTRIM(CASE WHEN HISTO.paren='T' AND HISTO.paren_real = 'T' THEN 'Titular' ELSE 'Beneficiario' END) AS parentesco,
F.loca AS ciudad, G.provin AS departamento,
RTRIM(AFICR.linea_negocio) AS lineaNegocio, RTRIM(PLA.plan_grupo) AS planGrupo,
(CASE 
 WHEN(SELECT TOP 1 RTRIM(TELE) FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='F' ORDER BY MODI_FECHA DESC) IS NOT NULL THEN(SELECT TOP 1 RTRIM(TELE) FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='F' ORDER BY MODI_FECHA DESC) 
 WHEN(SELECT TOP 1 RTRIM(TELE) FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='P' ORDER BY MODI_FECHA DESC) IS NOT NULL THEN(SELECT TOP 1 RTRIM(TELE) FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='P' ORDER BY MODI_FECHA DESC) ELSE '' END) AS telefono_f, 
 (SELECT TOP(1) RTRIM(RUT.tele)
 FROM [dbo].[REGISTRO_UNICO_TELEFONOS] RUT 
 WHERE RUT.codigo_unico_persona = A.codigo_unico_persona 
 AND RUT.tipo_tele = 'C' 
 AND (RUT.baja_fecha IS NULL OR CURRENT_TIMESTAMP <= RUT.baja_fecha) 
 AND CURRENT_TIMESTAMP >= RUT.vigencia
 ORDER BY vigencia DESC) telefono_c,
  (SELECT TOP(1) RUE.email
 FROM [dbo].[REGISTRO_UNICO_EMAILS] RUE 
 WHERE RUE.codigo_unico_persona = A.codigo_unico_persona 
 AND (RUE.baja_fecha IS NULL OR CURRENT_TIMESTAMP <= RUE.baja_fecha) 
 AND CURRENT_TIMESTAMP >= RUE.vigencia
 ORDER BY vigencia DESC) email,
 DATEDIFF(YEAR,A.naci_fecha ,GETDATE()) edad,
 RTRIM(CASE WHEN HISTO.paren='T' AND HISTO.paren_real = 'T' THEN 'Titular' ELSE pt.deno  END) AS tipo_usuario
FROM afiliados	 A (NOLOCK)
LEFT JOIN AFI_CREDENCIALES AFICR (NOLOCK) ON A.CONTRA=AFICR.CONTRA AND A.INTE=AFICR.INTE /*5*/
LEFT JOIN dbo.AFI_CLASE AC (NOLOCK) ON A.contra=AC.contra /*3*/
LEFT JOIN dbo.SUBCTA_CONTRATO SUBC (NOLOCK) ON AC.CUENTA = SUBC.CUENTA AND AC.SUBCTA = SUBC.SUBCTA /*4*/
LEFT JOIN dbo.SUBCTA_TIPOS SUBT ON SUBC.SUBCTA_TIPO = SUBT.SUBCTA_TIPO 
LEFT JOIN dbo.CUENTAS CUEN ON SUBC.CUENTA = CUEN.CUENTA 
LEFT JOIN dbo.AFI_PLANES AFIP (NOLOCK) ON A.PREPAGA = AFIP.PREPAGA AND A.CONTRA = AFIP.CONTRA /*1*/
LEFT JOIN dbo.PLANES PLA ON AFIP.PLAN_CODI = PLA.PLAN_CODI
LEFT JOIN dbo.PLANES_GRUPOS PLAG ON PLAG.PLAN_GRUPO = PLA.PLAN_GRUPO
LEFT JOIN (SELECT PLAN_CODI, PAGO_COPA FROM dbo.COBER_COPA_GRUPOS WHERE BAJA_FECHA IS NULL GROUP BY PLAN_CODI, PAGO_COPA) FRAN ON FRAN.PLAN_CODI = PLA.PLAN_CODI
LEFT JOIN AFI_HISTO_PAREN HISTO (NOLOCK) ON HISTO.inte=A.inte AND HISTO.contra=A.contra /*2*/
LEFT JOIN REGISTRO_UNICO_DOMICILIOS F (NOLOCK) ON F.codigo_unico_persona=A.codigo_unico_persona
LEFT JOIN PARTIDOS G ON G.partido=F.loca
LEFT JOIN parentescos pt ON pt.paren = HISTO.paren_real
WHERE 
 /*1*/AFIP.vigen_desde = (SELECT max(AFIPF.vigen_desde) FROM dbo.AFI_PLANES AFIPF (NOLOCK) WHERE AFIPF.contra = AFIP.contra AND AFIPF.vigen_desde <= CONVERT (date, GETDATE()) AND ( AFIPF.baja_fecha IS NULL OR AFIPF.baja_fecha > CONVERT (date, GETDATE()) OR a.realbaja_fecha > CONVERT (date, GETDATE()) ) AND AFIPF.tari NOT LIKE '%SEOR%' ) AND
/*2*/HISTO.vigen_desde = (SELECT max(ahp.vigen_desde) FROM AFI_HISTO_PAREN ahp (NOLOCK) WHERE HISTO.contra = ahp.contra AND HISTO.inte = ahp.inte AND ahp.vigen_desde <= CONVERT (date, GETDATE()) AND (ahp.baja_fecha IS NULL OR a.realbaja_fecha > CONVERT (date, GETDATE()) )) AND
/*3*/AC.vigen_desde = (SELECT max(acf.vigen_desde) FROM AFI_CLASE acf (NOLOCK) WHERE AC.CONTRA = acf.CONTRA AND acf.vigen_desde <= GETDATE() AND (acf.baja_fecha IS NULL OR acf.baja_fecha > CONVERT (date, GETDATE()) OR a.realbaja_fecha > CONVERT (date, GETDATE()))) AND
/*4*/SUBC.vigen_desde = (SELECT max(scf.vigen_desde) FROM subcta_contrato scf (NOLOCK) WHERE AC.cuenta = scf.cuenta AND AC.subcta = scf.subcta AND scf.vigen_desde <= CONVERT (date, GETDATE()) AND (scf.baja_Fecha IS NULL OR scf.baja_fecha > GETDATE() AND scf.subcta_tipo not in ('EN', 'EI'))) AND
/*5*/AFICR.vigen_desde = ((SELECT max(afc.vigen_desde) FROM dbo.AFI_CREDENCIALES afc (NOLOCK) WHERE afc.contra=AFICR.contra AND afc.inte=AFICR.inte AND afc.vigen_desde <= CONVERT (DATE, GETDATE()) AND (afc.baja_fecha IS NULL OR a.realbaja_fecha > CONVERT (date, GETDATE())))) 
AND (a.baja_fecha IS NULL AND SUBT.baja_fecha IS NULL AND CUEN.baja_fecha IS NULL AND PLA.baja_fecha IS NULL AND PLAG.baja_fecha IS NULL OR a.realbaja_fecha > CONVERT (date, GETDATE()) ) AND
  A.CONTRA IN 
 (SELECT a.CONTRA FROM AFILIADOS (NOLOCK) a LEFT JOIN afi_histo_paren b (NOLOCK) on a.contra=b.contra AND a.inte=b.inte 
 WHERE a.docu_nro = @id AND a.docu_tipo = @tipo_id AND b.paren_real='T' AND (a.baja_fecha IS NULL AND b.baja_fecha IS NULL OR a.realbaja_fecha > CONVERT (date, GETDATE())) /*AND b.vigen_desde=AFIP.vigen_desde*/)
 AND f.modi_fecha =  (SELECT max(F1.modi_fecha) FROM REGISTRO_UNICO_DOMICILIOS F1 (NOLOCK) WHERE F1.codigo_unico_persona=A.codigo_unico_persona) --25O12022 -trae el dato mas actual de la ciudad

UNION
 
/*QUERY - BENEFICIARIOS DE CONTRATOS CON RESPONSABLE PAGADOR SIN SERVICIO*/
SELECT
RTRIM(CONCAT(RTRIM(a.NOMBRE), ' ', ISNULL(RTRIM(a.NOMBRE2), ''), ' ', RTRIM(a.APE), ' ', ISNULL(RTRIM(a.APE2), ''))) AS nombreAfiliado,
RTRIM(a.DOCU_NRO) AS numIdentificacion,
RTRIM(a.docu_tipo) AS tipoIdentificacion,
RTRIM(PLA.plan_codi) AS programa,
RTRIM(PLA.DENO) AS nomPrograma,
RTRIM(PLA.carti) AS numCartilla,
CONVERT(varchar, a.NACI_FECHA, 112) AS fechaNacimiento,
RTRIM(CASE WHEN HISTO.paren='T' AND HISTO.paren_real = 'T' THEN 'Titular' ELSE 'Beneficiario' END) AS parentesco,
F.loca AS ciudad, G.provin AS departamento,
RTRIM(AFICR.linea_negocio) AS lineaNegocio, RTRIM(PLA.plan_grupo) AS planGrupo, 
(CASE 
 WHEN(SELECT TOP 1 RTRIM(TELE) FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='F' ORDER BY MODI_FECHA DESC) IS NOT NULL THEN(SELECT TOP 1 RTRIM(TELE) FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='F' ORDER BY MODI_FECHA DESC) 
 WHEN(SELECT TOP 1 RTRIM(TELE) FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='P' ORDER BY MODI_FECHA DESC) IS NOT NULL THEN(SELECT TOP 1 RTRIM(TELE) FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='P' ORDER BY MODI_FECHA DESC) ELSE '' END) AS telefono_f, 
 (SELECT TOP(1) RTRIM(RUT.tele)
 FROM [dbo].[REGISTRO_UNICO_TELEFONOS] RUT 
 WHERE RUT.codigo_unico_persona = A.codigo_unico_persona 
 AND RUT.tipo_tele = 'C' 
 AND (RUT.baja_fecha IS NULL OR CURRENT_TIMESTAMP <= RUT.baja_fecha) 
 AND CURRENT_TIMESTAMP >= RUT.vigencia
 ORDER BY vigencia DESC) telefono_c,
  (SELECT TOP(1) RUE.email
 FROM [dbo].[REGISTRO_UNICO_EMAILS] RUE 
 WHERE RUE.codigo_unico_persona = A.codigo_unico_persona 
 AND (RUE.baja_fecha IS NULL OR CURRENT_TIMESTAMP <= RUE.baja_fecha) 
 AND CURRENT_TIMESTAMP >= RUE.vigencia
 ORDER BY vigencia DESC) email,
DATEDIFF(YEAR,A.naci_fecha ,GETDATE()) edad,
RTRIM(CASE WHEN HISTO.paren='T' AND HISTO.paren_real = 'T' THEN 'Titular' ELSE pt.deno  END) AS tipo_usuario 
FROM afiliados A (NOLOCK)
LEFT JOIN AFI_CREDENCIALES AFICR (NOLOCK) ON A.CONTRA=AFICR.CONTRA AND A.INTE=AFICR.INTE /*5*/
LEFT JOIN dbo.AFI_CLASE AC (NOLOCK) ON A.contra=AC.contra /*3*/
LEFT JOIN dbo.SUBCTA_CONTRATO SUBC (NOLOCK) ON AC.CUENTA = SUBC.CUENTA AND AC.SUBCTA = SUBC.SUBCTA /*4*/
LEFT JOIN dbo.SUBCTA_TIPOS SUBT ON SUBC.SUBCTA_TIPO = SUBT.SUBCTA_TIPO 
LEFT JOIN dbo.CUENTAS CUEN ON SUBC.CUENTA = CUEN.CUENTA 
LEFT JOIN dbo.AFI_PLANES AFIP (NOLOCK) ON A.PREPAGA = AFIP.PREPAGA AND A.CONTRA = AFIP.CONTRA /*1*/
LEFT JOIN dbo.PLANES PLA ON AFIP.PLAN_CODI = PLA.PLAN_CODI
LEFT JOIN dbo.PLANES_GRUPOS PLAG ON PLAG.PLAN_GRUPO = PLA.PLAN_GRUPO
LEFT JOIN (SELECT PLAN_CODI, PAGO_COPA FROM dbo.COBER_COPA_GRUPOS WHERE BAJA_FECHA IS NULL GROUP BY PLAN_CODI, PAGO_COPA) FRAN ON FRAN.PLAN_CODI = PLA.PLAN_CODI
LEFT JOIN AFI_HISTO_PAREN HISTO (NOLOCK) ON HISTO.inte=A.inte AND HISTO.contra=A.contra /*2*/
LEFT JOIN REGISTRO_UNICO_DOMICILIOS F (NOLOCK) ON F.codigo_unico_persona=A.codigo_unico_persona
LEFT JOIN PARTIDOS G ON G.partido=F.loca
LEFT JOIN parentescos pt ON pt.paren = HISTO.paren_real
WHERE 
/*1*/AFIP.vigen_desde = (SELECT max(AFIPF.vigen_desde) FROM dbo.AFI_PLANES AFIPF (NOLOCK) WHERE AFIPF.contra = AFIP.contra AND AFIPF.vigen_desde <= CONVERT (date, GETDATE()) AND ( AFIPF.baja_fecha IS NULL OR AFIPF.baja_fecha > CONVERT (date, GETDATE()) ) AND AFIPF.tari NOT LIKE '%SEOR%' ) AND
/*2*/HISTO.vigen_desde = (SELECT max(ahp.vigen_desde) FROM AFI_HISTO_PAREN ahp (NOLOCK) WHERE HISTO.contra = ahp.contra AND HISTO.inte = ahp.inte AND ahp.vigen_desde <= CONVERT (date, GETDATE()) AND ahp.baja_fecha IS NULL ) AND
/*3*/AC.vigen_desde = (SELECT max(acf.vigen_desde) FROM AFI_CLASE acf (NOLOCK) WHERE AC.CONTRA = acf.CONTRA AND acf.vigen_desde <= GETDATE() AND (acf.baja_fecha IS NULL OR acf.baja_fecha > CONVERT (date, GETDATE()))) AND
/*4*/SUBC.vigen_desde = (SELECT max(scf.vigen_desde) FROM subcta_contrato scf (NOLOCK) WHERE AC.cuenta = scf.cuenta AND AC.subcta = scf.subcta AND scf.vigen_desde <= CONVERT (date, GETDATE()) AND (scf.baja_Fecha IS NULL OR scf.baja_fecha > GETDATE() AND scf.subcta_tipo not in ('EN', 'EI'))) AND
/*5*/AFICR.vigen_desde = ((SELECT max(afc.vigen_desde) FROM dbo.AFI_CREDENCIALES afc (NOLOCK) WHERE afc.contra=AFICR.contra AND afc.inte=AFICR.inte AND afc.vigen_desde <= CONVERT (DATE, GETDATE()) AND afc.baja_fecha IS NULL )) AND
A.contra in(SELECT contra FROM afi_resp_pagador (NOLOCK) WHERE docu_nro = @id AND docu_tipo = @tipo_id AND baja_fecha IS NULL AND vigen_hasta IS NULL AND moti_ret_resp_pag IS NULL) AND A.baja_fecha IS NULL AND AFICR.BAJA_FECHA IS NULL

UNION 

/*beneficiarios*/
SELECT
RTRIM(CONCAT(RTRIM(a.NOMBRE), ' ', ISNULL(RTRIM(a.NOMBRE2), ''), ' ', RTRIM(a.APE), ' ', ISNULL(RTRIM(a.APE2), ''))) AS nombreAfiliado,
RTRIM(a.DOCU_NRO) AS numIdentificacion,
RTRIM(a.docu_tipo) AS tipoIdentificacion,
RTRIM(PLA.plan_codi) AS programa,
RTRIM(PLA.DENO) AS nomPrograma,
RTRIM(PLA.carti) AS numCartilla,
CONVERT(varchar, a.NACI_FECHA, 112) AS fechaNacimiento,
RTRIM(CASE WHEN hp.paren='T' AND hp.paren = 'T' THEN 'Titular' ELSE 'Beneficiario' END) AS parentesco,
F.loca AS ciudad, G.provin AS departamento,
RTRIM(AFICR.linea_negocio) AS lineaNegocio, RTRIM(PLA.plan_grupo) AS planGrupo,
(CASE 
 WHEN(SELECT TOP 1 RTRIM(TELE) FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='F' ORDER BY MODI_FECHA DESC) IS NOT NULL THEN(SELECT TOP 1 RTRIM(TELE) FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='F' ORDER BY MODI_FECHA DESC) 
 WHEN(SELECT TOP 1 RTRIM(TELE) FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='P' ORDER BY MODI_FECHA DESC) IS NOT NULL THEN(SELECT TOP 1 RTRIM(TELE) FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='P' ORDER BY MODI_FECHA DESC) ELSE '' END) AS telefono_f, 
 (SELECT TOP(1) RTRIM(RUT.tele)
 FROM [dbo].[REGISTRO_UNICO_TELEFONOS] RUT 
 WHERE RUT.codigo_unico_persona = A.codigo_unico_persona 
 AND RUT.tipo_tele = 'C' 
 AND (RUT.baja_fecha IS NULL OR CURRENT_TIMESTAMP <= RUT.baja_fecha) 
 AND CURRENT_TIMESTAMP >= RUT.vigencia
 ORDER BY vigencia DESC) telefono_c,
  (SELECT TOP(1) RUE.email
 FROM [dbo].[REGISTRO_UNICO_EMAILS] RUE 
 WHERE RUE.codigo_unico_persona = A.codigo_unico_persona 
 AND (RUE.baja_fecha IS NULL OR CURRENT_TIMESTAMP <= RUE.baja_fecha) 
 AND CURRENT_TIMESTAMP >= RUE.vigencia
 ORDER BY vigencia DESC) email,
DATEDIFF(YEAR,A.naci_fecha ,GETDATE()) edad,
RTRIM(CASE WHEN hp.paren='T' AND hp.paren_real = 'T' THEN 'Titular' ELSE pt.deno  END) AS tipo_usuario 
FROM afiliados A (NOLOCK)
LEFT JOIN AFI_CREDENCIALES AFICR (NOLOCK) ON A.CONTRA=AFICR.CONTRA AND A.INTE=AFICR.INTE /*5*/
LEFT JOIN dbo.AFI_CLASE AC (NOLOCK) ON A.contra=AC.contra /*3*/
LEFT JOIN dbo.SUBCTA_CONTRATO SUBC (NOLOCK) ON AC.CUENTA = SUBC.CUENTA AND AC.SUBCTA = SUBC.SUBCTA /*4*/
LEFT JOIN dbo.SUBCTA_TIPOS SUBT ON SUBC.SUBCTA_TIPO = SUBT.SUBCTA_TIPO 
LEFT JOIN dbo.CUENTAS CUEN ON SUBC.CUENTA = CUEN.CUENTA 
LEFT JOIN dbo.AFI_PLANES AFIP (NOLOCK) ON A.PREPAGA = AFIP.PREPAGA AND A.CONTRA = AFIP.CONTRA /*1*/
LEFT JOIN dbo.PLANES PLA ON AFIP.PLAN_CODI = PLA.PLAN_CODI
LEFT JOIN dbo.PLANES_GRUPOS PLAG ON PLAG.PLAN_GRUPO = PLA.PLAN_GRUPO
LEFT JOIN AFI_HISTO_PAREN hp (NOLOCK) ON hp.inte=A.inte AND hp.contra=A.contra /*2*/
LEFT JOIN (SELECT PLAN_CODI, PAGO_COPA FROM dbo.COBER_COPA_GRUPOS WHERE BAJA_FECHA IS NULL GROUP BY PLAN_CODI, PAGO_COPA) FRAN ON FRAN.PLAN_CODI = PLA.PLAN_CODI
LEFT JOIN REGISTRO_UNICO_DOMICILIOS F (NOLOCK) ON F.codigo_unico_persona=A.codigo_unico_persona
LEFT JOIN PARTIDOS G ON G.partido=F.loca
LEFT JOIN parentescos pt ON pt.paren = hp.paren_real
WHERE 
/*1*/AFIP.vigen_desde = (SELECT max(AFIPF.vigen_desde) FROM dbo.AFI_PLANES AFIPF (NOLOCK) WHERE AFIPF.contra = AFIP.contra AND AFIPF.vigen_desde <= CONVERT (date, GETDATE()) AND ( AFIPF.baja_fecha IS NULL OR AFIPF.baja_fecha > CONVERT (date, GETDATE()) OR a.realbaja_fecha > CONVERT (date, GETDATE())) AND AFIPF.tari NOT LIKE '%SEOR%' ) AND
/*2*/hp.vigen_desde = (SELECT max(ahp.vigen_desde) FROM AFI_HISTO_PAREN ahp (NOLOCK) WHERE hp.contra = ahp.contra AND hp.inte = ahp.inte AND ahp.vigen_desde <= CONVERT (date, GETDATE()) AND (ahp.baja_fecha IS NULL OR a.realbaja_fecha > CONVERT (date, GETDATE())) ) AND
/*3*/AC.vigen_desde = (SELECT max(acf.vigen_desde) FROM AFI_CLASE acf (NOLOCK) WHERE AC.CONTRA = acf.CONTRA AND acf.vigen_desde <= GETDATE() AND (acf.baja_fecha IS NULL OR acf.baja_fecha > CONVERT (date, GETDATE()) OR a.realbaja_fecha > CONVERT (date, GETDATE()))) AND
/*4*/SUBC.vigen_desde = (SELECT max(scf.vigen_desde) FROM subcta_contrato scf (NOLOCK) WHERE AC.cuenta = scf.cuenta AND AC.subcta = scf.subcta AND scf.vigen_desde <= CONVERT (date, GETDATE()) AND ((scf.baja_Fecha IS NULL OR a.realbaja_fecha > CONVERT (date, GETDATE())) OR scf.baja_fecha > GETDATE() AND scf.subcta_tipo not in ('EN', 'EI'))) AND
/*5*/AFICR.vigen_desde = ((SELECT max(afc.vigen_desde) FROM dbo.AFI_CREDENCIALES afc (NOLOCK) WHERE afc.contra=AFICR.contra AND afc.inte=AFICR.inte AND afc.vigen_desde <= CONVERT (DATE, GETDATE()) AND (afc.baja_fecha IS NULL OR a.realbaja_fecha > CONVERT (date, GETDATE()) ))) AND
(a.baja_fecha IS NULL OR a.realbaja_fecha > CONVERT (date, GETDATE())) AND SUBT.baja_fecha IS NULL AND CUEN.baja_fecha IS NULL AND PLA.baja_fecha IS NULL AND PLAG.baja_fecha IS NULL 
AND hp.paren_real <> 'T' 
AND a.docu_nro = @id 
AND a.docu_tipo = @tipo_id
ORDER BY parentesco DESC

END





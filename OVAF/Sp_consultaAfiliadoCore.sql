USE [PreCoreMP]
GO
/****** Object:  StoredProcedure [saludmp].[Sp_consultaAfiliadoCore]    Script Date: 30/01/2025 3:09:35 p. m. ******/
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
RTRIM(CONCAT(TRIM(a.NOMBRE), ' ', ISNULL(TRIM(a.NOMBRE2), ''), ' ', TRIM(a.APE), ' ', ISNULL(TRIM(a.APE2), ''))) AS nombreAfiliado,
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
 WHEN(SELECT TOP 1 TELE FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='F' ORDER BY MODI_FECHA DESC) IS NOT NULL THEN(SELECT TOP 1 TELE FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='F' ORDER BY MODI_FECHA DESC) 
 WHEN(SELECT TOP 1 TELE FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='P' ORDER BY MODI_FECHA DESC) IS NOT NULL THEN(SELECT TOP 1 TELE FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='P' ORDER BY MODI_FECHA DESC) ELSE '' END) AS telefono_f, 
 (SELECT TOP(1) RUT.tele
 FROM [dbo].[REGISTRO_UNICO_TELEFONOS] RUT 
 WHERE RUT.codigo_unico_persona = A.codigo_unico_persona 
 AND RUT.tipo_tele = 'C' 
 AND (RUT.baja_fecha is null or CURRENT_TIMESTAMP <= RUT.baja_fecha) 
 and CURRENT_TIMESTAMP >= RUT.vigencia
 ORDER BY vigencia DESC) telefono_c,
  (SELECT TOP(1) RUE.email
 FROM [dbo].[REGISTRO_UNICO_EMAILS] RUE 
 WHERE RUE.codigo_unico_persona = A.codigo_unico_persona 
 AND (RUE.baja_fecha is null or CURRENT_TIMESTAMP <= RUE.baja_fecha) 
 and CURRENT_TIMESTAMP >= RUE.vigencia
 ORDER BY vigencia DESC) email,
 DATEDIFF(YEAR,A.naci_fecha ,GETDATE()) edad,
 RTRIM(CASE WHEN HISTO.paren='T' AND HISTO.paren_real = 'T' THEN 'Titular' ELSE pt.deno  END) AS tipo_usuario
from afiliados	 A (NOLOCK)
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
LEFT JOIN parentescos pt ON pt.paren = HISTO.paren
where 
 /*1*/AFIP.vigen_desde = (select max(AFIPF.vigen_desde) from dbo.AFI_PLANES AFIPF (NOLOCK) where AFIPF.contra = AFIP.contra and AFIPF.vigen_desde <= CONVERT (date, GETDATE()) and ( AFIPF.baja_fecha is null or AFIPF.baja_fecha > CONVERT (date, GETDATE()) or a.realbaja_fecha > CONVERT (date, GETDATE()) ) AND AFIPF.tari NOT LIKE '%SEOR%' ) AND
/*2*/HISTO.vigen_desde = (select max(ahp.vigen_desde) from AFI_HISTO_PAREN ahp (NOLOCK) where HISTO.contra = ahp.contra and HISTO.inte = ahp.inte and ahp.vigen_desde <= CONVERT (date, GETDATE()) and (ahp.baja_fecha is null or a.realbaja_fecha > CONVERT (date, GETDATE()) )) AND
/*3*/AC.vigen_desde = (select max(acf.vigen_desde) from AFI_CLASE acf (NOLOCK) where AC.CONTRA = acf.CONTRA and acf.vigen_desde <= GETDATE() and (acf.baja_fecha is null or acf.baja_fecha > CONVERT (date, GETDATE()) or a.realbaja_fecha > CONVERT (date, GETDATE()))) AND
/*4*/SUBC.vigen_desde = (select max(scf.vigen_desde) from subcta_contrato scf (NOLOCK) where AC.cuenta = scf.cuenta and AC.subcta = scf.subcta and scf.vigen_desde <= CONVERT (date, GETDATE()) and (scf.baja_Fecha is null or scf.baja_fecha > GETDATE() and scf.subcta_tipo not in ('EN', 'EI'))) AND
/*5*/AFICR.vigen_desde = ((select max(afc.vigen_desde) from dbo.AFI_CREDENCIALES afc (NOLOCK) where afc.contra=AFICR.contra and afc.inte=AFICR.inte and afc.vigen_desde <= CONVERT (DATE, GETDATE()) and (afc.baja_fecha is null or a.realbaja_fecha > CONVERT (date, GETDATE())))) 
AND (a.baja_fecha is null AND SUBT.baja_fecha is null AND CUEN.baja_fecha is null and PLA.baja_fecha is null and PLAG.baja_fecha is null or a.realbaja_fecha > CONVERT (date, GETDATE()) ) AND
  A.CONTRA IN 
 (SELECT a.CONTRA FROM AFILIADOS (NOLOCK) a left join afi_histo_paren b (NOLOCK) on a.contra=b.contra and a.inte=b.inte 
 WHERE a.docu_nro = @id and a.docu_tipo = @tipo_id and b.paren_real='T' and (a.baja_fecha is null and b.baja_fecha is null or a.realbaja_fecha > CONVERT (date, GETDATE())) /*and b.vigen_desde=AFIP.vigen_desde*/)
 and f.modi_fecha =  (select max(F1.modi_fecha) from REGISTRO_UNICO_DOMICILIOS F1 (NOLOCK) where F1.codigo_unico_persona=A.codigo_unico_persona) --25O12022 -trae el dato mas actual de la ciudad
UNION
 
/*QUERY - BENEFICIARIOS DE CONTRATOS CON RESPONSABLE PAGADOR SIN SERVICIO*/
SELECT
--RTRIM((CASE WHEN CUEN.CUENTA_TIPO = 'C' THEN CUEN.RAZON ELSE '' END)) AS nombreColectivo,
-- RTRIM(CONCAT(a.NOMBRE, ' ', ISNULL(a.NOMBRE2, ''), ' ', a.APE, ' ', ISNULL(a.APE2, ''))) AS nombreAfiliado,
RTRIM(CONCAT(TRIM(a.NOMBRE), ' ', ISNULL(TRIM(a.NOMBRE2), ''), ' ', TRIM(a.APE), ' ', ISNULL(TRIM(a.APE2), ''))) AS nombreAfiliado,
RTRIM(a.DOCU_NRO) AS numIdentificacion,
RTRIM(a.docu_tipo) AS tipoIdentificacion,
--RTRIM(AFICR.ASESOR) AS codigoAsesor,
--RTRIM(CASE WHEN PLAG.PLAN_GRUPO = 'TRD' THEN '70' ELSE '100' END) AS cobertura,
--RTRIM(SUBT.DENO) AS tipoPlan,
RTRIM(PLA.plan_codi) AS programa,
RTRIM(PLA.DENO) AS nomPrograma,
RTRIM(PLA.carti) AS numCartilla,
--RTRIM(AFICR.PLAN_CODI) AS codigo_programa,
--RTRIM(CASE WHEN FRAN.PAGO_COPA = 'P' THEN 'DIRE' WHEN FRAN.PAGO_COPA = 'C' THEN 'NOMI' ELSE '' END) AS franquicia,
--RTRIM(a.CONTRA) AS codigoContrato,
--RTRIM(a.INTE) AS numeroUsuario,
--RTRIM(AFICR.NRO_EMISION) AS numeroConsecutivo,
CONVERT(varchar, a.NACI_FECHA, 112) AS fechaNacimiento,
--CONVERT(NVARCHAR(MAX), a.antig_FECHA, 112) AS fechaInicio,
--RTRIM(LTRIM(AFICR.CREDEN)) AS numeroCredencial,
RTRIM(CASE WHEN HISTO.paren='T' AND HISTO.paren_real = 'T' THEN 'Titular' ELSE 'Beneficiario' END) AS parentesco,
F.loca AS ciudad, G.provin AS departamento,
--RTRIM(CASE WHEN PLA.plan_grupo IN ('ORO', 'OPL','PJV','ASO') THEN '1' ELSE '0' END) AS asist_internal 
RTRIM(AFICR.linea_negocio) AS lineaNegocio, RTRIM(PLA.plan_grupo) AS planGrupo, 
(CASE 
 WHEN(SELECT TOP 1 TELE FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='F' ORDER BY MODI_FECHA DESC) IS NOT NULL THEN(SELECT TOP 1 TELE FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='F' ORDER BY MODI_FECHA DESC) 
 WHEN(SELECT TOP 1 TELE FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='P' ORDER BY MODI_FECHA DESC) IS NOT NULL THEN(SELECT TOP 1 TELE FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='P' ORDER BY MODI_FECHA DESC) ELSE '' END) AS telefono_f, 
 (SELECT TOP(1) RUT.tele
 FROM [dbo].[REGISTRO_UNICO_TELEFONOS] RUT 
 WHERE RUT.codigo_unico_persona = A.codigo_unico_persona 
 AND RUT.tipo_tele = 'C' 
 AND (RUT.baja_fecha is null or CURRENT_TIMESTAMP <= RUT.baja_fecha) 
 and CURRENT_TIMESTAMP >= RUT.vigencia
 ORDER BY vigencia DESC) telefono_c,
  (SELECT TOP(1) RUE.email
 FROM [dbo].[REGISTRO_UNICO_EMAILS] RUE 
 WHERE RUE.codigo_unico_persona = A.codigo_unico_persona 
 AND (RUE.baja_fecha is null or CURRENT_TIMESTAMP <= RUE.baja_fecha) 
 and CURRENT_TIMESTAMP >= RUE.vigencia
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
LEFT JOIN parentescos pt ON pt.paren = HISTO.paren
where 
/*1*/AFIP.vigen_desde = (select max(AFIPF.vigen_desde) from dbo.AFI_PLANES AFIPF (NOLOCK) where AFIPF.contra = AFIP.contra and AFIPF.vigen_desde <= CONVERT (date, GETDATE()) and ( AFIPF.baja_fecha is null or AFIPF.baja_fecha > CONVERT (date, GETDATE()) ) AND AFIPF.tari NOT LIKE '%SEOR%' ) AND
/*2*/HISTO.vigen_desde = (select max(ahp.vigen_desde) from AFI_HISTO_PAREN ahp (NOLOCK) where HISTO.contra = ahp.contra and HISTO.inte = ahp.inte and ahp.vigen_desde <= CONVERT (date, GETDATE()) and ahp.baja_fecha is null ) AND
/*3*/AC.vigen_desde = (select max(acf.vigen_desde) from AFI_CLASE acf (NOLOCK) where AC.CONTRA = acf.CONTRA and acf.vigen_desde <= GETDATE() and (acf.baja_fecha is null or acf.baja_fecha > CONVERT (date, GETDATE()))) AND
/*4*/SUBC.vigen_desde = (select max(scf.vigen_desde) from subcta_contrato scf (NOLOCK) where AC.cuenta = scf.cuenta and AC.subcta = scf.subcta and scf.vigen_desde <= CONVERT (date, GETDATE()) and (scf.baja_Fecha is null or scf.baja_fecha > GETDATE() and scf.subcta_tipo not in ('EN', 'EI'))) AND
/*5*/AFICR.vigen_desde = ((select max(afc.vigen_desde) from dbo.AFI_CREDENCIALES afc (NOLOCK) where afc.contra=AFICR.contra and afc.inte=AFICR.inte and afc.vigen_desde <= CONVERT (DATE, GETDATE()) and afc.baja_fecha is null )) AND
A.contra in(select contra from afi_resp_pagador (NOLOCK) where docu_nro = @id and docu_tipo = @tipo_id and baja_fecha is null AND vigen_hasta IS NULL AND moti_ret_resp_pag IS NULL) and A.baja_fecha is null AND AFICR.BAJA_FECHA IS NULL
UNION 
/*beneficiarios*/
SELECT
--RTRIM((CASE WHEN CUEN.CUENTA_TIPO = 'C' THEN CUEN.RAZON ELSE '' END)) AS nombreColectivo,
-- RTRIM(CONCAT(a.NOMBRE, ' ', ISNULL(a.NOMBRE2, ''), ' ', a.APE, ' ', ISNULL(a.APE2, '') )) AS nombreAfiliado,
RTRIM(CONCAT(TRIM(a.NOMBRE), ' ', ISNULL(TRIM(a.NOMBRE2), ''), ' ', TRIM(a.APE), ' ', ISNULL(TRIM(a.APE2), ''))) AS nombreAfiliado,
RTRIM(a.DOCU_NRO) AS numIdentificacion,
RTRIM(a.docu_tipo) AS tipoIdentificacion,
--RTRIM(AFICR.ASESOR) AS codigoAsesor,
--RTRIM(CASE WHEN PLAG.PLAN_GRUPO = 'TRD' THEN '70' ELSE '100' END) AS cobertura,
--RTRIM(SUBT.DENO) AS tipoPlan,
RTRIM(PLA.plan_codi) AS programa,
RTRIM(PLA.DENO) AS nomPrograma,
RTRIM(PLA.carti) AS numCartilla,
--RTRIM(AFICR.PLAN_CODI) AS codigo_programa,
--RTRIM(CASE WHEN FRAN.PAGO_COPA = 'P' THEN 'DIRE' WHEN FRAN.PAGO_COPA = 'C' THEN 'NOMI' ELSE '' END) AS franquicia,
--RTRIM(a.CONTRA) AS codigoContrato,
--RTRIM(a.INTE) AS numeroUsuario,
--RTRIM(AFICR.NRO_EMISION) AS numeroConsecutivo,
CONVERT(varchar, a.NACI_FECHA, 112) AS fechaNacimiento,
--CONVERT(NVARCHAR(MAX), a.antig_FECHA, 112) AS fechaInicio,
--RTRIM(LTRIM(AFICR.CREDEN)) AS numeroCredencial,
RTRIM(CASE WHEN hp.paren='T' AND hp.paren_real = 'T' THEN 'Titular' ELSE 'Beneficiario' END) AS parentesco,
F.loca AS ciudad, G.provin AS departamento,
--RTRIM(CASE WHEN PLA.plan_grupo IN ('ORO', 'OPL','PJV','ASO') THEN '1' ELSE '0' END) AS asist_internal
RTRIM(AFICR.linea_negocio) AS lineaNegocio, RTRIM(PLA.plan_grupo) AS planGrupo,
(CASE 
 WHEN(SELECT TOP 1 TELE FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='F' ORDER BY MODI_FECHA DESC) IS NOT NULL THEN(SELECT TOP 1 TELE FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='F' ORDER BY MODI_FECHA DESC) 
 WHEN(SELECT TOP 1 TELE FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='P' ORDER BY MODI_FECHA DESC) IS NOT NULL THEN(SELECT TOP 1 TELE FROM REGISTRO_UNICO_TELEFONOS WHERE CODIGO_UNICO_PERSONA=A.CODIGO_UNICO_PERSONA AND TIPO_TELE='P' ORDER BY MODI_FECHA DESC) ELSE '' END) AS telefono_f, 
 (SELECT TOP(1) RUT.tele
 FROM [dbo].[REGISTRO_UNICO_TELEFONOS] RUT 
 WHERE RUT.codigo_unico_persona = A.codigo_unico_persona 
 AND RUT.tipo_tele = 'C' 
 AND (RUT.baja_fecha is null or CURRENT_TIMESTAMP <= RUT.baja_fecha) 
 and CURRENT_TIMESTAMP >= RUT.vigencia
 ORDER BY vigencia DESC) telefono_c,
  (SELECT TOP(1) RUE.email
 FROM [dbo].[REGISTRO_UNICO_EMAILS] RUE 
 WHERE RUE.codigo_unico_persona = A.codigo_unico_persona 
 AND (RUE.baja_fecha is null or CURRENT_TIMESTAMP <= RUE.baja_fecha) 
 and CURRENT_TIMESTAMP >= RUE.vigencia
 ORDER BY vigencia DESC) email,
DATEDIFF(YEAR,A.naci_fecha ,GETDATE()) edad,
RTRIM(CASE WHEN hp.paren='T' AND hp.paren_real = 'T' THEN 'Titular' ELSE pt.deno  END) AS tipo_usuario 
from afiliados A (NOLOCK)
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
LEFT JOIN parentescos pt ON pt.paren = hp.paren
where 
/*1*/AFIP.vigen_desde = (select max(AFIPF.vigen_desde) from dbo.AFI_PLANES AFIPF (NOLOCK) where AFIPF.contra = AFIP.contra and AFIPF.vigen_desde <= CONVERT (date, GETDATE()) and ( AFIPF.baja_fecha is null or AFIPF.baja_fecha > CONVERT (date, GETDATE()) or a.realbaja_fecha > CONVERT (date, GETDATE())) AND AFIPF.tari NOT LIKE '%SEOR%' ) AND
/*2*/hp.vigen_desde = (select max(ahp.vigen_desde) from AFI_HISTO_PAREN ahp (NOLOCK) where hp.contra = ahp.contra and hp.inte = ahp.inte and ahp.vigen_desde <= CONVERT (date, GETDATE()) and (ahp.baja_fecha is null or a.realbaja_fecha > CONVERT (date, GETDATE())) ) AND
/*3*/AC.vigen_desde = (select max(acf.vigen_desde) from AFI_CLASE acf (NOLOCK) where AC.CONTRA = acf.CONTRA and acf.vigen_desde <= GETDATE() and (acf.baja_fecha is null or acf.baja_fecha > CONVERT (date, GETDATE()) or a.realbaja_fecha > CONVERT (date, GETDATE()))) AND
/*4*/SUBC.vigen_desde = (select max(scf.vigen_desde) from subcta_contrato scf (NOLOCK) where AC.cuenta = scf.cuenta and AC.subcta = scf.subcta and scf.vigen_desde <= CONVERT (date, GETDATE()) and ((scf.baja_Fecha is null or a.realbaja_fecha > CONVERT (date, GETDATE())) or scf.baja_fecha > GETDATE() and scf.subcta_tipo not in ('EN', 'EI'))) AND
/*5*/AFICR.vigen_desde = ((select max(afc.vigen_desde) from dbo.AFI_CREDENCIALES afc (NOLOCK) where afc.contra=AFICR.contra and afc.inte=AFICR.inte and afc.vigen_desde <= CONVERT (DATE, GETDATE()) and (afc.baja_fecha is null or a.realbaja_fecha > CONVERT (date, GETDATE()) ))) AND
(a.baja_fecha is null or a.realbaja_fecha > CONVERT (date, GETDATE())) and SUBT.baja_fecha is null and CUEN.baja_fecha is null and PLA.baja_fecha is null and PLAG.baja_fecha is null 
and hp.paren_real <> 'T' 
 and a.docu_nro = @id and a.docu_tipo = @tipo_id
order by parentesco desc

end





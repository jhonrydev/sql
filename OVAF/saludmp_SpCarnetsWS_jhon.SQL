USE [PreCoreMP]
GO
/****** Object:  StoredProcedure [saludmp].[SpCarnetsWS_jhon]    Script Date: 17/05/2024 5:51:16 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [saludmp].[SpCarnetsWS_jhon]  
    @tipo_id varchar(100),
    @id varchar(100)
AS
BEGIN

DECLARE DEFINE_PROGRAMA_PRICIPAL CURSOR FOR
    SELECT plan_codi,deno
    FROM PLANES;

CREATE TABLE PROGRAMAS_PRINCIPALES
(
    plan_codi VARCHAR,
    programa_principañl VARCHAR
)

 

/*QUERY PARA CONTRATOS DE RESPONSABLE PAGADOR CON SERVICIO*/
PRINT 'ENTRO 1'
SELECT 
RTRIM((CASE WHEN CUEN.CUENTA_TIPO = 'C' THEN CUEN.RAZON ELSE '' END)) AS nombreColectivo,
RTRIM(CONCAT(a.APE, ' ', ISNULL(a.APE2, ''), ' ', a.NOMBRE, ' ', ISNULL(a.NOMBRE2, ''))) AS nombreAfiliado,
RTRIM(a.DOCU_NRO) AS numIdentificacion,
RTRIM(a.docu_tipo) AS tipoIdentificacion,
RTRIM(AFICR.ASESOR) AS codigoAsesor,
RTRIM(CASE WHEN PLAG.PLAN_GRUPO = 'TRD' THEN '70' ELSE '100' END) AS cobertura,
RTRIM(SUBT.DENO) AS tipoPlan,
RTRIM(PLA.DENO) AS programa,
RTRIM(AFICR.PLAN_CODI) AS codigo_programa,
RTRIM(CASE WHEN FRAN.PAGO_COPA = 'P' THEN 'DIRE' WHEN FRAN.PAGO_COPA = 'C' THEN 'NOMI' ELSE '' END) AS franquicia,
RTRIM(a.CONTRA) AS codigoContrato,
RTRIM(a.INTE) AS numeroUsuario,
RTRIM(AFICR.NRO_EMISION) AS numeroConsecutivo,
CONVERT(NVARCHAR(MAX), a.NACI_FECHA, 112)  AS fechaNacimiento,
CONVERT(NVARCHAR(MAX), a.antig_FECHA, 112) AS fechaInicio,
RTRIM(LTRIM(AFICR.CREDEN)) AS numeroCredencial,
RTRIM(CASE WHEN HISTO.paren='T'  THEN 'Titular' ELSE 'Beneficiario' END) AS parentesco,
RTRIM(CASE WHEN PLA.plan_grupo IN ('ORO', 'OPL','PJV','ASO') THEN '1' ELSE '0' END) AS asist_internal
from afiliados A 
LEFT JOIN AFI_CREDENCIALES AFICR ON A.CONTRA=AFICR.CONTRA AND A.INTE=AFICR.INTE /*5*/
LEFT JOIN dbo.AFI_CLASE AC ON A.contra=AC.contra /*3*/
LEFT JOIN dbo.SUBCTA_CONTRATO SUBC ON AC.CUENTA = SUBC.CUENTA AND AC.SUBCTA = SUBC.SUBCTA /*4*/
LEFT JOIN dbo.SUBCTA_TIPOS SUBT ON SUBC.SUBCTA_TIPO = SUBT.SUBCTA_TIPO 
LEFT JOIN dbo.CUENTAS CUEN ON SUBC.CUENTA = CUEN.CUENTA 
LEFT JOIN dbo.AFI_PLANES AFIP ON A.PREPAGA = AFIP.PREPAGA AND A.CONTRA = AFIP.CONTRA /*1*/
LEFT JOIN dbo.PLANES PLA ON AFIP.PLAN_CODI = PLA.PLAN_CODI
LEFT JOIN dbo.PLANES_GRUPOS PLAG ON PLAG.PLAN_GRUPO = PLA.PLAN_GRUPO
LEFT JOIN (SELECT PLAN_CODI, PAGO_COPA FROM dbo.COBER_COPA_GRUPOS WHERE BAJA_FECHA IS NULL GROUP BY PLAN_CODI, PAGO_COPA) FRAN ON FRAN.PLAN_CODI = PLA.PLAN_CODI
LEFT JOIN AFI_HISTO_PAREN HISTO ON  HISTO.inte=A.inte AND HISTO.contra=A.contra  /*2*/
where 
/*1*/AFIP.vigen_desde = (select max(AFIPF.vigen_desde) from dbo.AFI_PLANES AFIPF where AFIPF.contra = AFIP.contra and AFIPF.vigen_desde <= CONVERT (date, GETDATE()) and ( AFIPF.baja_fecha is null or AFIPF.baja_fecha > CONVERT (date, GETDATE()) ) AND AFIPF.tari NOT LIKE '%SEOR%' ) AND
/*2*/HISTO.vigen_desde = (select max(ahp.vigen_desde) from AFI_HISTO_PAREN ahp where HISTO.contra = ahp.contra and HISTO.inte = ahp.inte and ahp.vigen_desde <= CONVERT (date, GETDATE()) /*and ahp.baja_fecha is null*/ ) AND
/*3*/AC.vigen_desde =  (select max(acf.vigen_desde) from AFI_CLASE acf  where AC.CONTRA = acf.CONTRA and acf.vigen_desde <= GETDATE() and (acf.baja_fecha is null or acf.baja_fecha > CONVERT (date, GETDATE()))) AND
/*4*/SUBC.vigen_desde = (select max(scf.vigen_desde) from subcta_contrato scf where AC.cuenta = scf.cuenta and AC.subcta = scf.subcta and scf.vigen_desde <= CONVERT (date, GETDATE()) and (scf.baja_Fecha is null or scf.baja_fecha > GETDATE() and scf.subcta_tipo not in ('EN', 'EI'))) AND
/*5*/AFICR.vigen_desde = ((select max(afc.vigen_desde) from dbo.AFI_CREDENCIALES afc where afc.contra=AFICR.contra and afc.inte=AFICR.inte and afc.vigen_desde <= CONVERT (DATE, GETDATE()) /*and afc.baja_fecha is null*/ )) AND
--/*6*/AFICR.nro_emision = ((select max(afc.nro_emision) from dbo.AFI_CREDENCIALES afc where afc.contra=AFICR.contra and afc.inte=AFICR.inte and afc.vigen_desde <= CONVERT (DATE, GETDATE()) /*and afc.baja_fecha is null*/ )) AND
a.baja_fecha is null AND  SUBT.baja_fecha is null AND  CUEN.baja_fecha is null and PLA.baja_fecha is null and PLAG.baja_fecha is null  
AND A.CONTRA IN  
(SELECT a.CONTRA FROM AFILIADOS a left join afi_histo_paren b on a.contra=b.contra and a.inte=b.inte  
WHERE a.docu_nro = @id and a.docu_tipo = @tipo_id and b.paren='T' and (a.baja_fecha is null or a.realbaja_fecha >= dbo.afn_fecha_sin_hora(GETDATE())) and b.baja_fecha is null /*and b.vigen_desde=AFIP.vigen_desde*/)

 

UNION

/*QUERY  - BENEFICIARIOS DE CONTRATOS CON RESPONSABLE PAGADOR SIN SERVICIO*/

 

SELECT

 

RTRIM((CASE WHEN CUEN.CUENTA_TIPO = 'C' THEN CUEN.RAZON ELSE '' END)) AS nombreColectivo,
RTRIM(CONCAT(a.APE, ' ', ISNULL(a.APE2, ''), ' ', a.NOMBRE, ' ', ISNULL(a.NOMBRE2, ''))) AS nombreAfiliado,
RTRIM(a.DOCU_NRO) AS numIdentificacion,
RTRIM(a.docu_tipo) AS tipoIdentificacion,
RTRIM(AFICR.ASESOR) AS codigoAsesor,
RTRIM(CASE WHEN PLAG.PLAN_GRUPO = 'TRD' THEN '70' ELSE '100' END) AS cobertura,
RTRIM(SUBT.DENO) AS tipoPlan,
RTRIM(PLA.DENO) AS programa,
RTRIM(AFICR.PLAN_CODI) AS codigo_programa,
RTRIM(CASE WHEN FRAN.PAGO_COPA = 'P' THEN 'DIRE' WHEN FRAN.PAGO_COPA = 'C' THEN 'NOMI' ELSE '' END) AS franquicia,
RTRIM(a.CONTRA) AS codigoContrato,
RTRIM(a.INTE) AS numeroUsuario,
RTRIM(AFICR.NRO_EMISION) AS numeroConsecutivo,
CONVERT(NVARCHAR(MAX), a.NACI_FECHA, 112)  AS fechaNacimiento,
CONVERT(NVARCHAR(MAX), a.antig_FECHA, 112) AS fechaInicio,
RTRIM(LTRIM(AFICR.CREDEN)) AS numeroCredencial,
RTRIM(CASE WHEN HISTO.paren='T' AND HISTO.paren_real = 'T' THEN 'Titular' ELSE 'Beneficiario' END) AS parentesco,
RTRIM(CASE WHEN PLA.plan_grupo IN ('ORO', 'OPL','PJV','ASO') THEN '1' ELSE '0' END) AS asist_internal
FROM afiliados A 
LEFT JOIN AFI_CREDENCIALES AFICR ON A.CONTRA=AFICR.CONTRA AND A.INTE=AFICR.INTE /*5*/
LEFT JOIN dbo.AFI_CLASE AC ON A.contra=AC.contra /*3*/
LEFT JOIN dbo.SUBCTA_CONTRATO SUBC ON AC.CUENTA = SUBC.CUENTA AND AC.SUBCTA = SUBC.SUBCTA /*4*/
LEFT JOIN dbo.SUBCTA_TIPOS SUBT ON SUBC.SUBCTA_TIPO = SUBT.SUBCTA_TIPO 
LEFT JOIN dbo.CUENTAS CUEN ON SUBC.CUENTA = CUEN.CUENTA 
LEFT JOIN dbo.AFI_PLANES AFIP ON A.PREPAGA = AFIP.PREPAGA AND A.CONTRA = AFIP.CONTRA /*1*/
LEFT JOIN dbo.PLANES PLA ON AFIP.PLAN_CODI = PLA.PLAN_CODI
LEFT JOIN dbo.PLANES_GRUPOS PLAG ON PLAG.PLAN_GRUPO = PLA.PLAN_GRUPO
LEFT JOIN (SELECT PLAN_CODI, PAGO_COPA FROM dbo.COBER_COPA_GRUPOS WHERE BAJA_FECHA IS NULL GROUP BY PLAN_CODI, PAGO_COPA) FRAN ON FRAN.PLAN_CODI = PLA.PLAN_CODI
LEFT JOIN AFI_HISTO_PAREN HISTO ON  HISTO.inte=A.inte AND HISTO.contra=A.contra  /*2*/
where 
/*1*/AFIP.vigen_desde = (select max(AFIPF.vigen_desde) from dbo.AFI_PLANES AFIPF where AFIPF.contra = AFIP.contra and AFIPF.vigen_desde <= CONVERT (date, GETDATE()) and ( AFIPF.baja_fecha is null or AFIPF.baja_fecha > CONVERT (date, GETDATE()) ) AND AFIPF.tari NOT LIKE '%SEOR%' ) AND
/*2*/HISTO.vigen_desde = (select max(ahp.vigen_desde) from AFI_HISTO_PAREN ahp where HISTO.contra = ahp.contra and HISTO.inte = ahp.inte and ahp.vigen_desde <= CONVERT (date, GETDATE()) /*and ahp.baja_fecha is null*/ ) AND
/*3*/AC.vigen_desde =  (select max(acf.vigen_desde) from AFI_CLASE acf  where AC.CONTRA = acf.CONTRA and acf.vigen_desde <= GETDATE() and (acf.baja_fecha is null or acf.baja_fecha > CONVERT (date, GETDATE()))) AND
/*4*/SUBC.vigen_desde = (select max(scf.vigen_desde) from subcta_contrato scf where AC.cuenta = scf.cuenta and AC.subcta = scf.subcta and scf.vigen_desde <= CONVERT (date, GETDATE()) and (scf.baja_Fecha is null or scf.baja_fecha > GETDATE() and scf.subcta_tipo not in ('EN', 'EI'))) AND
/*5*/AFICR.vigen_desde = ((select max(afc.vigen_desde) from dbo.AFI_CREDENCIALES afc where afc.contra=AFICR.contra and afc.inte=AFICR.inte and afc.vigen_desde <= CONVERT (DATE, GETDATE()) /*and afc.baja_fecha is null */ )) AND
--/*6*/AFICR.nro_emision = ((select max(afc.nro_emision) from dbo.AFI_CREDENCIALES afc where afc.contra=AFICR.contra and afc.inte=AFICR.inte and afc.vigen_desde <= CONVERT (DATE, GETDATE()) /*and afc.baja_fecha is null */ )) AND
A.contra in(select contra from afi_resp_pagador where docu_nro = @id and docu_tipo = @tipo_id and baja_fecha is null AND vigen_hasta IS NULL AND moti_ret_resp_pag IS NULL) and (a.baja_fecha is null or a.realbaja_fecha >= dbo.afn_fecha_sin_hora(GETDATE())) AND AFICR.BAJA_FECHA IS NULL

 

UNION

 

/*beneficiarios*/
SELECT

 

RTRIM((CASE WHEN CUEN.CUENTA_TIPO = 'C' THEN CUEN.RAZON ELSE '' END)) AS nombreColectivo,
RTRIM(CONCAT(a.APE, ' ', ISNULL(a.APE2, ''), ' ', a.NOMBRE, ' ', ISNULL(a.NOMBRE2, ''))) AS nombreAfiliado,
RTRIM(a.DOCU_NRO) AS numIdentificacion,
RTRIM(a.docu_tipo) AS tipoIdentificacion,
RTRIM(AFICR.ASESOR) AS codigoAsesor,
RTRIM(CASE WHEN PLAG.PLAN_GRUPO = 'TRD' THEN '70' ELSE '100' END) AS cobertura,
RTRIM(SUBT.DENO) AS tipoPlan,
RTRIM(PLA.DENO) AS programa,
RTRIM(AFICR.PLAN_CODI) AS codigo_programa,
RTRIM(CASE WHEN FRAN.PAGO_COPA = 'P' THEN 'DIRE' WHEN FRAN.PAGO_COPA = 'C' THEN 'NOMI' ELSE '' END) AS franquicia,
RTRIM(a.CONTRA) AS codigoContrato,
RTRIM(a.INTE) AS numeroUsuario,
RTRIM(AFICR.NRO_EMISION) AS numeroConsecutivo,
CONVERT(NVARCHAR(MAX), a.NACI_FECHA, 112)  AS fechaNacimiento,
CONVERT(NVARCHAR(MAX), a.antig_FECHA, 112) AS fechaInicio,
RTRIM(LTRIM(AFICR.CREDEN)) AS numeroCredencial,
RTRIM(CASE WHEN hp.paren='T' AND hp.paren_real = 'T' THEN 'Titular' ELSE 'Beneficiario' END) AS parentesco,
RTRIM(CASE WHEN PLA.plan_grupo IN ('ORO', 'OPL','PJV','ASO') THEN '1' ELSE '0' END) AS asist_internal
from afiliados A 
LEFT JOIN AFI_CREDENCIALES AFICR ON A.CONTRA=AFICR.CONTRA AND A.INTE=AFICR.INTE /*5*/
LEFT JOIN dbo.AFI_CLASE AC ON A.contra=AC.contra /*3*/
LEFT JOIN dbo.SUBCTA_CONTRATO SUBC ON AC.CUENTA = SUBC.CUENTA AND AC.SUBCTA = SUBC.SUBCTA /*4*/
LEFT JOIN dbo.SUBCTA_TIPOS SUBT ON SUBC.SUBCTA_TIPO = SUBT.SUBCTA_TIPO 
LEFT JOIN dbo.CUENTAS CUEN ON SUBC.CUENTA = CUEN.CUENTA 
LEFT JOIN dbo.AFI_PLANES AFIP ON A.PREPAGA = AFIP.PREPAGA AND A.CONTRA = AFIP.CONTRA /*1*/
LEFT JOIN dbo.PLANES PLA ON AFIP.PLAN_CODI = PLA.PLAN_CODI
LEFT JOIN dbo.PLANES_GRUPOS PLAG ON PLAG.PLAN_GRUPO = PLA.PLAN_GRUPO
LEFT JOIN AFI_HISTO_PAREN hp ON  hp.inte=A.inte AND hp.contra=A.contra  /*2*/
LEFT JOIN (SELECT PLAN_CODI, PAGO_COPA FROM dbo.COBER_COPA_GRUPOS WHERE BAJA_FECHA IS NULL GROUP BY PLAN_CODI, PAGO_COPA) FRAN ON FRAN.PLAN_CODI = PLA.PLAN_CODI
where 
/*1*/AFIP.vigen_desde = (select max(AFIPF.vigen_desde) from dbo.AFI_PLANES AFIPF where AFIPF.contra = AFIP.contra and AFIPF.vigen_desde <= CONVERT (date, GETDATE()) and ( AFIPF.baja_fecha is null or AFIPF.baja_fecha > CONVERT (date, GETDATE()) ) AND AFIPF.tari NOT LIKE '%SEOR%' ) AND
/*2*/hp.vigen_desde = (select max(ahp.vigen_desde) from AFI_HISTO_PAREN ahp where hp.contra = ahp.contra and hp.inte = ahp.inte and ahp.vigen_desde <= CONVERT (date, GETDATE()) /*and ahp.baja_fecha is null*/ ) AND
/*3*/AC.vigen_desde =  (select max(acf.vigen_desde) from AFI_CLASE acf  where AC.CONTRA = acf.CONTRA and acf.vigen_desde <= GETDATE() and (acf.baja_fecha is null or acf.baja_fecha > CONVERT (date, GETDATE()))) AND
/*4*/SUBC.vigen_desde = (select max(scf.vigen_desde) from subcta_contrato scf where AC.cuenta = scf.cuenta and AC.subcta = scf.subcta and scf.vigen_desde <= CONVERT (date, GETDATE()) and (scf.baja_Fecha is null or scf.baja_fecha > GETDATE() and scf.subcta_tipo not in ('EN', 'EI'))) AND
--/*5*/AFICR.vigen_desde = ((select max(afc.vigen_desde) from dbo.AFI_CREDENCIALES afc where afc.contra=AFICR.contra and afc.inte=AFICR.inte and afc.vigen_desde <= CONVERT (DATE, GETDATE()) /* and afc.baja_fecha is null*/ )) AND

 

-- se ajusta el filtro 5 para solucion mantis 7433
/*5*/AFICR.modi_fecha in ((select max(afc.modi_fecha) from dbo.AFI_CREDENCIALES afc where afc.contra=AFICR.contra and afc.inte=AFICR.inte  /* and afc.baja_fecha is null*/ )) AND

 


--/*6*/AFICR.nro_emision = ((select max(afc.nro_emision) from dbo.AFI_CREDENCIALES afc where afc.contra=AFICR.contra and afc.inte=AFICR.inte and afc.vigen_desde <= CONVERT (DATE, GETDATE()) /* and afc.baja_fecha is null*/ )) AND
(a.baja_fecha is null or a.realbaja_fecha >= dbo.afn_fecha_sin_hora(GETDATE())) and SUBT.baja_fecha is null and CUEN.baja_fecha is null and PLA.baja_fecha is null and PLAG.baja_fecha is null 
and  hp.paren_real <> 'T'
and a.docu_nro = @id and a.docu_tipo = @tipo_id
order by parentesco desc

 

END
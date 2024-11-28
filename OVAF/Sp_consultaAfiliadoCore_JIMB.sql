SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [saludmp].[Sp_consultaAfiliadoCore]
       @coderror INTEGER  =0  OUTPUT,
       @msgerror VARCHAR(500)  =0  OUTPUT,
	   @tipo_id VARCHAR(2),
       @id VARCHAR(20)
AS  
BEGIN
    /*QUERY PARA CONTRATOS DE RESPONSABLE PAGADOR CON SERVICIO*/
      SELECT 
        CONCAT(RTRIM(LTRIM(a.NOMBRE)), ' ', RTRIM(LTRIM(ISNULL(a.NOMBRE2, ''))), ' ', RTRIM(LTRIM(a.APE)), ' ', RTRIM(LTRIM(ISNULL(a.APE2, '')))) AS nombreAfiliado,
        RTRIM(a.DOCU_NRO) AS numIdentificacion,
        RTRIM(a.docu_tipo) AS tipoIdentificacion,
        RTRIM(PLA.plan_codi) AS programa,
        RTRIM(PLA.DENO) AS nomPrograma,
        RTRIM(PLA.carti) AS numCartilla ,
        CONVERT(VARCHAR, a.NACI_FECHA, 112) AS fechaNacimiento,
        RTRIM(CASE WHEN HISTO.paren='T' AND HISTO.paren_real = 'T' THEN 'Titular' ELSE 'Beneficiario' END) AS parentesco,
        RTRIM(CASE WHEN HISTO.paren='T' AND HISTO.paren_real = 'T' THEN 'Titular' ELSE 'Beneficiario' END) AS tipoPersona,
        RTRIM(LTRIM(P.paren)) AS codPariente,
        RTRIM(LTRIM(P.deno)) AS pariente,
        DATEDIFF(YEAR,A.naci_fecha,GETDATE()) AS edad,
        F.loca AS ciudad, G.provin AS departamento,
        RTRIM(AFICR.linea_negocio) AS lineaNegocio, RTRIM(PLA.plan_grupo) AS planGrupo 
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
        LEFT JOIN PARENTESCOS P ON A.paren=P.paren 
    WHERE 
        /*1*/AFIP.vigen_desde = (SELECT MAX(AFIPF.vigen_desde) FROM dbo.AFI_PLANES AFIPF (NOLOCK) WHERE AFIPF.contra = AFIP.contra AND AFIPF.vigen_desde <= CONVERT (DATE, GETDATE()) AND ( AFIPF.baja_fecha IS NULL or AFIPF.baja_fecha > CONVERT (DATE, GETDATE()) or a.realbaja_fecha > CONVERT (DATE, GETDATE()) ) AND AFIPF.tari NOT LIKE '%SEOR%' ) AND
        /*2*/HISTO.vigen_desde = (SELECT MAX(ahp.vigen_desde) FROM AFI_HISTO_PAREN ahp (NOLOCK) WHERE HISTO.contra = ahp.contra AND HISTO.inte = ahp.inte AND ahp.vigen_desde <= CONVERT (DATE, GETDATE()) AND (ahp.baja_fecha IS NULL or a.realbaja_fecha > CONVERT (DATE, GETDATE()) )) AND
        /*3*/AC.vigen_desde = (SELECT MAX(acf.vigen_desde) FROM AFI_CLASE acf (NOLOCK) WHERE AC.CONTRA = acf.CONTRA AND acf.vigen_desde <= GETDATE() AND (acf.baja_fecha IS NULL or acf.baja_fecha > CONVERT (DATE, GETDATE()) or a.realbaja_fecha > CONVERT (DATE, GETDATE()))) AND
        /*4*/SUBC.vigen_desde = (SELECT MAX(scf.vigen_desde) FROM subcta_contrato scf (NOLOCK) WHERE AC.cuenta = scf.cuenta AND AC.subcta = scf.subcta AND scf.vigen_desde <= CONVERT (DATE, GETDATE()) AND (scf.baja_Fecha IS NULL or scf.baja_fecha > GETDATE() AND scf.subcta_tipo not in ('EN', 'EI'))) AND
        /*5*/AFICR.vigen_desde = ((SELECT MAX(afc.vigen_desde) FROM dbo.AFI_CREDENCIALES afc (NOLOCK) WHERE afc.contra=AFICR.contra AND afc.inte=AFICR.inte AND afc.vigen_desde <= CONVERT (DATE, GETDATE()) AND (afc.baja_fecha IS NULL or a.realbaja_fecha > CONVERT (DATE, GETDATE())))) 
        AND (a.baja_fecha IS NULL AND SUBT.baja_fecha IS NULL AND CUEN.baja_fecha IS NULL AND PLA.baja_fecha IS NULL AND PLAG.baja_fecha IS NULL or a.realbaja_fecha > CONVERT (DATE, GETDATE()) ) AND
        A.CONTRA IN 
        (SELECT a.CONTRA FROM AFILIADOS (NOLOCK) a left join afi_histo_paren b (NOLOCK) ON a.contra=b.contra AND a.inte=b.inte 
        WHERE a.docu_nro = '94449309' AND a.docu_tipo = 'CC' AND b.paren_real='T' AND (a.baja_fecha IS NULL AND b.baja_fecha IS NULL or a.realbaja_fecha > CONVERT (DATE, GETDATE())) /*and b.vigen_desde=AFIP.vigen_desde*/)
        AND f.modi_fecha =  (SELECT MAX(F1.modi_fecha) FROM REGISTRO_UNICO_DOMICILIOS F1 (NOLOCK) WHERE F1.codigo_unico_persona=A.codigo_unico_persona) --25O12022 -trae el dato mas actual de la ciudad


    UNION
    
    /*QUERY - BENEFICIARIOS DE CONTRATOS CON RESPONSABLE PAGADOR SIN SERVICIO*/
    SELECT
        CONCAT(RTRIM(LTRIM(a.NOMBRE)), ' ', RTRIM(LTRIM(ISNULL(a.NOMBRE2, ''))), ' ', RTRIM(LTRIM(a.APE)), ' ', RTRIM(LTRIM(ISNULL(a.APE2, '')))) AS nombreAfiliado,
        RTRIM(a.DOCU_NRO) AS numIdentificacion,
        RTRIM(a.docu_tipo) AS tipoIdentificacion,
        RTRIM(PLA.plan_codi) AS programa,
        RTRIM(PLA.DENO) AS nomPrograma,
        RTRIM(PLA.carti) AS numCartilla,
        CONVERT(VARCHAR, a.NACI_FECHA, 112) AS fechaNacimiento,
        RTRIM(CASE WHEN HISTO.paren='T' AND HISTO.paren_real = 'T' THEN 'Titular' ELSE 'Beneficiario' END) AS parentesco,
        RTRIM(CASE WHEN HISTO.paren='T' AND HISTO.paren_real = 'T' THEN 'Titular' ELSE 'Beneficiario' END) AS tipoPersona,
        RTRIM(LTRIM(P.paren)) AS codPariente,
        RTRIM(LTRIM(P.deno)) AS pariente,
        DATEDIFF(YEAR,A.naci_fecha,GETDATE()) AS edad,
        F.loca AS ciudad, G.provin AS departamento,
        RTRIM(AFICR.linea_negocio) AS lineaNegocio, RTRIM(PLA.plan_grupo) AS planGrupo 
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
        LEFT JOIN PARENTESCOS P ON A.paren=P.paren 
    WHERE 
        /*1*/AFIP.vigen_desde = (SELECT MAX(AFIPF.vigen_desde) FROM dbo.AFI_PLANES AFIPF (NOLOCK) WHERE AFIPF.contra = AFIP.contra AND AFIPF.vigen_desde <= CONVERT (DATE, GETDATE()) AND ( AFIPF.baja_fecha IS NULL or AFIPF.baja_fecha > CONVERT (DATE, GETDATE()) ) AND AFIPF.tari NOT LIKE '%SEOR%' ) AND
        /*2*/HISTO.vigen_desde = (SELECT MAX(ahp.vigen_desde) FROM AFI_HISTO_PAREN ahp (NOLOCK) WHERE HISTO.contra = ahp.contra AND HISTO.inte = ahp.inte AND ahp.vigen_desde <= CONVERT (DATE, GETDATE()) AND ahp.baja_fecha IS NULL ) AND
        /*3*/AC.vigen_desde = (SELECT MAX(acf.vigen_desde) FROM AFI_CLASE acf (NOLOCK) WHERE AC.CONTRA = acf.CONTRA AND acf.vigen_desde <= GETDATE() AND (acf.baja_fecha IS NULL or acf.baja_fecha > CONVERT (DATE, GETDATE()))) AND
        /*4*/SUBC.vigen_desde = (SELECT MAX(scf.vigen_desde) FROM subcta_contrato scf (NOLOCK) WHERE AC.cuenta = scf.cuenta AND AC.subcta = scf.subcta AND scf.vigen_desde <= CONVERT (DATE, GETDATE()) AND (scf.baja_Fecha IS NULL or scf.baja_fecha > GETDATE() AND scf.subcta_tipo not in ('EN', 'EI'))) AND
        /*5*/AFICR.vigen_desde = ((SELECT MAX(afc.vigen_desde) FROM dbo.AFI_CREDENCIALES afc (NOLOCK) WHERE afc.contra=AFICR.contra AND afc.inte=AFICR.inte AND afc.vigen_desde <= CONVERT (DATE, GETDATE()) AND afc.baja_fecha IS NULL )) AND
        A.contra in(SELECT contra FROM afi_resp_pagador (NOLOCK) WHERE docu_nro = '94449309' AND docu_tipo = 'CC' AND baja_fecha IS NULL AND vigen_hasta IS NULL AND moti_ret_resp_pag IS NULL) AND A.baja_fecha IS NULL AND AFICR.BAJA_FECHA IS NULL
    
    UNION 

    /*beneficiarios*/
    SELECT
        CONCAT(RTRIM(LTRIM(a.NOMBRE)), ' ', RTRIM(LTRIM(ISNULL(a.NOMBRE2, ''))), ' ', RTRIM(LTRIM(a.APE)), ' ', RTRIM(LTRIM(ISNULL(a.APE2, '')))) AS nombreAfiliado,
        RTRIM(a.DOCU_NRO) AS numIdentificacion,
        RTRIM(a.docu_tipo) AS tipoIdentificacion,
        RTRIM(PLA.plan_codi) AS programa,
        RTRIM(PLA.DENO) AS nomPrograma,
        RTRIM(PLA.carti) AS numCartilla,
        CONVERT(VARCHAR, a.NACI_FECHA, 112) AS fechaNacimiento,
        RTRIM(CASE WHEN hp.paren='T' AND hp.paren_real = 'T' THEN 'Titular' ELSE 'Beneficiario' END) AS parentesco,
        RTRIM(CASE WHEN hp.paren='T' AND hp.paren_real = 'T' THEN 'Titular' ELSE 'Beneficiario' END) AS tipoPersona,
        RTRIM(LTRIM(P.paren)) AS codPariente,
        RTRIM(LTRIM(P.deno)) AS pariente,
        DATEDIFF(YEAR,A.naci_fecha,GETDATE()) AS edad,
        F.loca AS ciudad, G.provin AS departamento,
        RTRIM(AFICR.linea_negocio) AS lineaNegocio, RTRIM(PLA.plan_grupo) AS planGrupo 
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
        LEFT JOIN PARENTESCOS P ON A.paren=P.paren 
    WHERE 
        /*1*/AFIP.vigen_desde = (SELECT MAX(AFIPF.vigen_desde) FROM dbo.AFI_PLANES AFIPF (NOLOCK) WHERE AFIPF.contra = AFIP.contra AND AFIPF.vigen_desde <= CONVERT (DATE, GETDATE()) AND ( AFIPF.baja_fecha IS NULL or AFIPF.baja_fecha > CONVERT (DATE, GETDATE()) or a.realbaja_fecha > CONVERT (DATE, GETDATE())) AND AFIPF.tari NOT LIKE '%SEOR%' ) AND
        /*2*/hp.vigen_desde = (SELECT MAX(ahp.vigen_desde) FROM AFI_HISTO_PAREN ahp (NOLOCK) WHERE hp.contra = ahp.contra AND hp.inte = ahp.inte AND ahp.vigen_desde <= CONVERT (DATE, GETDATE()) AND (ahp.baja_fecha IS NULL or a.realbaja_fecha > CONVERT (DATE, GETDATE())) ) AND
        /*3*/AC.vigen_desde = (SELECT MAX(acf.vigen_desde) FROM AFI_CLASE acf (NOLOCK) WHERE AC.CONTRA = acf.CONTRA AND acf.vigen_desde <= GETDATE() AND (acf.baja_fecha IS NULL or acf.baja_fecha > CONVERT (DATE, GETDATE()) or a.realbaja_fecha > CONVERT (DATE, GETDATE()))) AND
        /*4*/SUBC.vigen_desde = (SELECT MAX(scf.vigen_desde) FROM subcta_contrato scf (NOLOCK) WHERE AC.cuenta = scf.cuenta AND AC.subcta = scf.subcta AND scf.vigen_desde <= CONVERT (DATE, GETDATE()) AND ((scf.baja_Fecha IS NULL or a.realbaja_fecha > CONVERT (DATE, GETDATE())) or scf.baja_fecha > GETDATE() AND scf.subcta_tipo not in ('EN', 'EI'))) AND
        /*5*/AFICR.vigen_desde = ((SELECT MAX(afc.vigen_desde) FROM dbo.AFI_CREDENCIALES afc (NOLOCK) WHERE afc.contra=AFICR.contra AND afc.inte=AFICR.inte AND afc.vigen_desde <= CONVERT (DATE, GETDATE()) AND (afc.baja_fecha IS NULL or a.realbaja_fecha > CONVERT (DATE, GETDATE()) ))) AND
        (a.baja_fecha IS NULL or a.realbaja_fecha > CONVERT (DATE, GETDATE())) AND SUBT.baja_fecha IS NULL AND CUEN.baja_fecha IS NULL AND PLA.baja_fecha IS NULL AND PLAG.baja_fecha IS NULL 
        AND hp.paren_real <> 'T' 
        AND a.docu_nro = '94449309' AND a.docu_tipo = 'CC'
        ORDER BY nombreAfiliado,numIdentificacion,tipoPersona DESC
END
GO

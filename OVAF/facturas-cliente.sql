USE [PreCoreMP]
GO
/****** Object:  StoredProcedure [saludmp].[Sp_InfoRespPagador]    Script Date: 16/02/2024 11:57:31 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [saludmp].[Sp_InfoRespPagador] (@prn_tipoDocu CHAR(2), @prm_nit char(15)) 
AS
BEGIN
DECLARE @documento_arp varchar (15) = (SELECT top 1 docu_nro FROM AFI_RESP_PAGADOR 
    WHERE docu_nro=@prm_nit AND docu_tipo = @prn_tipoDocu AND baja_fecha IS NULL)

 

IF ( @documento_arp IS NOT NULL)

DECLARE @telefijo_pagador varchar (50) =   (SELECT top 1   rtrim(tele) FROM AFI_RESP_PAGADOR A INNER JOIN REGISTRO_UNICO_TELEFONOS RUT ON RUT.codigo_unico_persona=A.codigo_unico_persona
    WHERE docu_nro = @prm_nit AND  (RUT.tipo_tele = 'C' AND A.baja_fecha IS NULL ) ORDER BY RUT.modi_fecha DESC)

 

DECLARE @tele_pagador varchar (50) =   (SELECT top 1 rtrim(tele) FROM AFI_RESP_PAGADOR A INNER JOIN REGISTRO_UNICO_TELEFONOS RUT ON RUT.codigo_unico_persona=A.codigo_unico_persona
    WHERE docu_nro = @prm_nit AND  (RUT.tipo_tele = 'C' AND A.baja_fecha IS NULL ) ORDER BY RUT.modi_fecha DESC)
        IF @tele_pagador IS NULL
        set @tele_pagador =  (SELECT top 1 rtrim(tele)+'000' FROM AFI_RESP_PAGADOR A INNER JOIN REGISTRO_UNICO_TELEFONOS RUT ON RUT.codigo_unico_persona=A.codigo_unico_persona
        WHERE docu_nro = @prm_nit AND  ( RUT.tipo_tele = 'F'AND A.baja_fecha IS NULL ) ORDER BY RUT.modi_fecha DESC)
        ELSE
        DECLARE @tele_afiliado varchar (50) =  (SELECT top 1 rtrim(tele) FROM AFILIADOS A INNER JOIN REGISTRO_UNICO_TELEFONOS RUT ON RUT.codigo_unico_persona=A.codigo_unico_persona
        WHERE docu_nro = @prm_nit AND  (RUT.tipo_tele = 'C'  ) ORDER BY RUT.modi_fecha DESC)

        IF @tele_afiliado IS NULL
        set @tele_afiliado = (SELECT top 1 rtrim(tele)+'000'  FROM AFILIADOS A INNER JOIN REGISTRO_UNICO_TELEFONOS RUT ON RUT.codigo_unico_persona=A.codigo_unico_persona
        WHERE docu_nro = @prm_nit AND  (RUT.tipo_tele = 'F'  ) ORDER BY RUT.modi_fecha DESC)
        IF( @documento_arp IS NOT NULL)
BEGIN
/*QUERY PARA RESPONSABLE PAGADOR SIN SERVICIO*/
SELECT top 1 ARP.docu_tipo AS TIPOID,
ARP.docu_nro AS ID,
ARP.nombre AS AFINOMBRE01,
ARP.nombre2 AS AFINOMBRE02,
ARP.ape AS AFIAPELLIDO01,
ARP.ape2 AS AFIAPELLIDO02,
ARP.sexo AS GENERO,
ltrim(rtrim(convert(char, ARP.naci_fecha,112))) AS NACIMIENTO,
(SELECT top 1 ARPE.email FROM REGISTRO_UNICO_EMAILS ARPE WHERE ARPE.codigo_unico_persona = ARP.codigo_unico_persona ORDER BY ARPE.email_tipo desc) AS AFIEMAIL,


@telefijo_pagador AFITELE,-- fin del case

@tele_pagador AS AFIMOVIL,

 

 

(CASE
WHEN SC.subcta_tipo = 'C' THEN (SELECT TOP 1 P.partido FROM SUBCTA_DOMICILIOS SD, LOCALIDADES lo, PARTIDOS P
WHERE SD.cuenta = SC.cuenta 
AND SD.subcta = SC.subcta 
AND SD.domi_tipo = '1'
AND SD.loca = lo.loca
AND lo.loca = p.partido)
ELSE (SELECT TOP 1 P.partido FROM REGISTRO_UNICO_DOMICILIOS ARPD, LOCALIDADES lo, PARTIDOS P
WHERE ARP.codigo_unico_persona = ARPD.codigo_unico_persona
AND ARPD.loca = lo.loca
AND lo.partido = p.partido
AND ARPD.domi_tipo = '2' ) END ) AS AFIMUNICIPIO, --Fin case
(SELECT TOP 1 CONCAT(ARPD.tipo_via,' ',ARPD.calle,' ',ARPD.nro,' ',ARPD.complemento) FROM REGISTRO_UNICO_DOMICILIOS ARPD 
WHERE ARP.codigo_unico_persona = ARPD.codigo_unico_persona AND ARPD.domi_tipo = '2') AS AFIDIRECCION, 

(CASE 
WHEN SC.subcta_tipo = 'C' THEN (SELECT TOP 1 p.provin FROM SUBCTA_DOMICILIOS SD, LOCALIDADES lo, PARTIDOS P, PROVINCIAS prov
WHERE SD.cuenta = SC.cuenta 
AND SD.subcta = SC.subcta 
AND SD.domi_tipo = '1'
AND SD.loca = lo.loca
AND lo.loca = p.partido AND PROV.provin=p.provin
)
ELSE (SELECT TOP 1 p.provin FROM REGISTRO_UNICO_DOMICILIOS ARPD, LOCALIDADES lo, PARTIDOS P, PROVINCIAS prov
WHERE ARP.codigo_unico_persona = ARPD.codigo_unico_persona
AND ARPD.loca = lo.loca
AND lo.partido = p.partido AND PROV.provin=p.provin
AND ARPD.domi_tipo = '2' ) END ) AS AFIDEPARTAMENTO, --Fin case 

STUFF((
SELECT DISTINCT ',' + K.linea_negocio FROM(
SELECT DISTINCT A.linea_negocio FROM AFI_CREDENCIALES A INNER JOIN AFI_RESP_PAGADOR ARP ON A.CONTRA=ARP.contra 
WHERE ARP.docu_tipo = @prn_tipoDocu AND ARP.docu_nro=@prm_nit AND A.baja_fecha IS NULL AND ARP.baja_fecha IS NULL 
UNION ALL
SELECT DISTINCT B.linea_negocio FROM AFI_CREDENCIALES B INNER JOIN AFILIADOS C ON C.CONTRA=B.contra 
WHERE C.docu_tipo = @prn_tipoDocu AND C.docu_nro=@prm_nit AND C.baja_fecha IS NULL AND B.baja_fecha IS NULL 
) as K FOR XML PATH('')),1,0,'') AS LINEA_NEGOCIO

FROM AFI_RESP_PAGADOR ARP, AFI_CLASE AC, SUBCTA_CONTRATO SC
WHERE ARP.contra = AC.contra
AND AC.cuenta = SC.cuenta
AND AC.subcta = SC.subcta
--AND rtrim(ltrim(ARP.docu_nro)) = @prm_nit
AND ARP.docu_nro = @prm_nit
AND ARP.docu_tipo = @prn_tipoDocu
AND (ARP.baja_fecha IS NULL OR CURRENT_TIMESTAMP <= ARP.baja_fecha);
END

ELSE

SELECT top 1 A.docu_tipo AS TIPOID,
A.docu_nro AS ID,
A.nombre AS AFINOMBRE01,
A.nombre2 AS AFINOMBRE02,
A.ape AS AFIAPELLIDO01,
A.ape2 AS AFIAPELLIDO02,
A.sexo AS GENERO,
ltrim(rtrim(convert(char, A.naci_fecha,112))) AS NACIMIENTO,
(SELECT top 1 AE.email FROM REGISTRO_UNICO_EMAILS AE WHERE AE.codigo_unico_persona = A.codigo_unico_persona ORDER BY AE.email_tipo desc ) AS AFIEMAIL,
(SELECT top 1 ATS.tele FROM REGISTRO_UNICO_TELEFONOS ATS WHERE ATS.codigo_unico_persona = A.codigo_unico_persona AND ATS.tipo_tele = 'F') AS AFITELE,
@tele_afiliado AS AFIMOVIL,

 


(SELECT top 1 P.partido FROM LOCALIDADES lo, PARTIDOS P WHERE AD.loca = lo.loca AND lo.partido = p.partido) AS AFIMUNICIPIO,
(SELECT top 1 concat(AD.tipo_via,' ',AD.calle,' ',AD.nro,' ',AD.complemento) FROM REGISTRO_UNICO_DOMICILIOS AFID WHERE AFID.codigo_unico_persona=A.codigo_unico_persona) AS AFIDIRECCION,
(SELECT top 1 p.provin FROM LOCALIDADES lo, PARTIDOS P, PROVINCIAS prov WHERE AD.loca = lo.loca AND lo.partido = p.partido AND p.provin=prov.provin) AS AFIDEPARTAMENTO,

STUFF((SELECT DISTINCT CAST(',' AS varchar(MAX)) + B.linea_negocio FROM AFI_CREDENCIALES B INNER JOIN AFILIADOS A ON A.CONTRA=B.contra
WHERE A.docu_tipo = @prn_tipoDocu AND A.docu_nro=@prm_nit AND a.baja_fecha IS NULL AND b.baja_fecha IS NULL
FOR XML PATH('') ), 1, 1, '') AS LINEA_NEGOCIO
FROM AFILIADOS A, REGISTRO_UNICO_DOMICILIOS AD
WHERE AD.codigo_unico_persona = A.codigo_unico_persona
AND AD.domi_tipo = '2'
--AND rtrim(ltrim(A.docu_nro)) = @prm_nit
AND A.docu_nro = @prm_nit
AND A.docu_tipo = @prn_tipoDocu
AND (A.baja_fecha IS NULL OR CURRENT_TIMESTAMP <= A.baja_fecha)

END
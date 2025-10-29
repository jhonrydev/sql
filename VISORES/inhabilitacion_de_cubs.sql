



SELECT DISTINCT prestad, PRESTADOR,cod_ciudad,ciudad,carti 
FROM Visor_directorios_5 
WHERE UPPER(prestador) like UPPER('%ALVARADO SOCARRAS JORGE LUIS%')


SELECT TOP 10 * 
FROM saludmp.DIR_AGRUPA_CUPS
WHERE cod_agrupador IN (
    SELECT cod_agrupador--top 5 *
    FROM saludmp.DIR_AGRUPADORES
    WHERE tipoAgrupa='AMB' AND UPPER(descripcion) LIKE UPPER('%Fenilalanina Cualitativa%')
)


-- 1. identificar el codigo del servicio a inhabilitar

SELECT *--top 5 *
FROM saludmp.DIR_AGRUPADORES
WHERE tipoAgrupa='AMB' AND UPPER(descripcion) LIKE UPPER('%Electroencefalograma computarizado%')
ORDER BY descripcion

-- Rta 1//
-- cod_agrupador    descripcion         nivel_auditoria     tipoAgrupa
-- 7117	            NASOLARINGOSCOPIA	    0           	AMB

-- Rta 2//
-- cod_agrupador    descripcion         nivel_auditoria     tipoAgrupa
-- 8008	            FENILALANINA CUALITATIVA    0           	AMB

-- 2. Identificar el codigo del cubs
SELECT TOP 10 * FROM saludmp.DIR_AGRUPA_CUPS 
WHERE cod_agrupador=8622;
-- Rta 1: 306001
-- Rta 2: 903202

-- 3. Identificar el nomen 
SELECT TOP 10 * FROM PRESTACIONES WHERE prestac='891402'
-- Rta 1: 16
-- Rta 2: 6

-- 4. Identificar los convenios prestacionales 
SELECT * FROM CONVE_PRESTACIONES WHERE nomen=6
-- Rta: 

SELECT DISTINCT  conve_prestac, deshab, des_desde, des_hasta, baja_fecha 
FROM CONVE_PRESTAC_DESHAB
WHERE conve_prestac IN (
    SELECT conve_prestac FROM CONVE_PRESTACIONES WHERE nomen=6
) AND des_desde IN (
    SELECT TOP 1 des_desde
    FROM CONVE_PRESTAC_DESHAB
    WHERE conve_prestac IN (
        SELECT conve_prestac FROM CONVE_PRESTACIONES WHERE nomen=6
    )
);

-- 5. identificar los conve de CARTI_CONVENIOS del prestador

    SELECT DISTinct conve 
    FROM CARTI_CONVENIOS
    WHERE conve IN (
        SELECT  conve FROM CONVE_PRESTACIONES WHERE nomen=6
    ) AND prestad ='4107'

-- 6. identificar los conve de CONVENIOS

SELECT *-- conve 
FROM CONVENIOS
WHERE conve IN (
    SELECT DISTinct conve 
    FROM CARTI_CONVENIOS
    WHERE conve IN (
        SELECT  conve FROM CONVE_PRESTACIONES WHERE nomen=16
    ) AND prestad ='3467'
) AND baja_fecha IS NULL


-- solución del caso
UPDATE convenios
SET fecha_terminacion = CAST('2025-10-01 00:00:00.000' AS DATETIME)
WHERE conve IN (2150);
-- WHERE conve IN (907, 5587);
-- WHERE conve IN (1237, 1239, 5415);


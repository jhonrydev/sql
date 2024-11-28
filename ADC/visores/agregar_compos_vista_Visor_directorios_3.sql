SELECT DISTINCT
    dbo.CARTI_PRESTADORES.carti,
    dbo.CARTILLAS.deno AS cartilla_deno,
    dbo.CARTI_PRESTADORES.espe,
    dbo.ESPECIALIDADES.exten_deno AS especialidades_exten_deno,
    dbo.SERVI_TIPOS.servi_tipo AS servi_tipos,
    dbo.SERVI_TIPOS.deno AS servi_tipos_deno,
    dbo.PROVINCIAS.provin AS cod_departamento,
    dbo.PROVINCIAS.deno AS provincias_deno,
    dbo.PARTIDOS.partido AS cod_ciudad,
    dbo.PARTIDOS.descripcion AS ciudad,
    dbo.CARTI_PRESTADORES.subespe AS codsubespecialidad,
    dbo.SUBESPECIALIDADES.exten_deno AS sub_especialidades_exten_deno,
    RTRIM(
        ISNULL (UPPER(dbo.TIPO_VIAS.deno), '') + ' ' + ISNULL (dbo.PRESTAD_LUGARES.num_nomb, '') + ' ' + RTRIM(
            ISNULL (dbo.PRESTAD_LUGARES.num_placa, '') + ' ' + ISNULL (dbo.PRESTAD_LUGARES.complemento, '')
        )
    ) AS direccion_lugar_atencion,
    dbo.PRESTAD_LUGARES.tele AS prestad_lugares_tele1,
    dbo.PRESTAD_LUGARES.telcelu_1 AS prestad_lugares_celu1,
    dbo.PRESTAD_LUGARES.tele_2 AS prestad_lugares_tele2,
    dbo.PRESTAD_LUGARES.telcelu_2 AS prestad_lugares_celu2,
    dbo.PRESTADORES.refe AS prestadores_refe,
    dbo.PRESTADORES.tipo AS prestadores_tipo,
    dbo.PRESTADORES.ape_razon AS prestadores_ape_razon,
    dbo.PRESTADORES.nombre_abre,
    dbo.PRESTAD_SERVICIOS.afinidad AS codafinidad,
    dbo.ESPECIALIDADES_AFINIDAD.deno AS Nombre_Afinidad,
    dbo.PRESTAD_LUGARES.loca,
    dbo.PRESTAD_SERVICIOS.prestad,
    CASE
        WHEN (PRESTADORES.tipo = 'I') THEN LTRIM(PRESTADORES.ape_razon)
        ELSE concat(
            LTRIM(PRESTADORES.ape_razon),
            ' ',
            PRESTADORES.apellido_2,
            ' ',
            PRESTADORES.nombre_abre,
            ' ',
            PRESTADORES.nombre_2
        )
    END AS PRESTADOR,
    dbo.PRESTAD_LUGARES.vto_habi_sani,
    dbo.PRESTAD_LUGARES.lugar,
    dbo.PRESTAD_LUGARES.ext_1 AS ext1,
    dbo.PRESTAD_LUGARES.ext_2 AS ext2,
    dbo.PRESTAD_LUGARES.latitud,
    dbo.PRESTAD_LUGARES.longitud,
    dbo.PRESTAD_LUGARES.email_citas,
    CASE
        WHEN (PRESTADORES.tipo = 'I') THEN LTRIM(PRESTADORES.ape_razon)
        ELSE concat(
            LTRIM(PRESTADORES.ape_razon),
            ' ',
            PRESTADORES.apellido_2,
            ' ',
            PRESTADORES.nombre_abre,
            ' ',
            PRESTADORES.nombre_2
        )
    END AS nombre_completo,
    saludmp.ESPECIALIDADES_DIRMEDICO.codigo AS cod_funcionalidad,
    saludmp.ESPECIALIDADES_DIRMEDICO.funcionalidad,
    dbo.PRESTAD_LUGARES.tele_nacional,
    dbo.PRESTAD_LUGARES.telcelu_wp
FROM
    dbo.PRESTAD_SERVICIOS
    INNER JOIN dbo.SERVI_TIPOS ON dbo.PRESTAD_SERVICIOS.servi_tipo = dbo.SERVI_TIPOS.servi_tipo
    AND dbo.PRESTAD_SERVICIOS.servi_tipo = dbo.SERVI_TIPOS.servi_tipo
    INNER JOIN dbo.SUBESPECIALIDADES ON dbo.PRESTAD_SERVICIOS.subespe = dbo.SUBESPECIALIDADES.subespe
    RIGHT OUTER JOIN dbo.CARTILLAS
    INNER JOIN dbo.CARTI_PRESTADORES
    INNER JOIN dbo.PRESTAD_LUGARES ON dbo.CARTI_PRESTADORES.prestad = dbo.PRESTAD_LUGARES.prestad
    AND dbo.CARTI_PRESTADORES.lugar = dbo.PRESTAD_LUGARES.lugar ON dbo.CARTILLAS.carti = dbo.CARTI_PRESTADORES.carti
    AND dbo.CARTILLAS.carti = dbo.CARTI_PRESTADORES.carti
    INNER JOIN dbo.ESPECIALIDADES ON dbo.CARTI_PRESTADORES.espe = dbo.ESPECIALIDADES.espe
    INNER JOIN dbo.TIPO_VIAS ON dbo.PRESTAD_LUGARES.tipo_via = dbo.TIPO_VIAS.tipo_via
    INNER JOIN dbo.PRESTADORES ON dbo.PRESTAD_LUGARES.prestad = dbo.PRESTADORES.prestad
    INNER JOIN dbo.LOCALIDADES
    INNER JOIN dbo.PARTIDOS ON dbo.LOCALIDADES.partido = dbo.PARTIDOS.partido
    AND dbo.LOCALIDADES.partido = dbo.PARTIDOS.partido
    INNER JOIN dbo.PROVINCIAS ON dbo.PARTIDOS.provin = dbo.PROVINCIAS.provin ON dbo.PRESTAD_LUGARES.loca = dbo.LOCALIDADES.loca
    INNER JOIN saludmp.ESPECIALIDADES_DIRMEDICO ON dbo.ESPECIALIDADES.espe = saludmp.ESPECIALIDADES_DIRMEDICO.cod_espe
    INNER JOIN dbo.LINEA_NEGOCIO_PRESTAD ON dbo.PRESTADORES.prestad = dbo.LINEA_NEGOCIO_PRESTAD.prestad ON dbo.PRESTAD_SERVICIOS.subespe = dbo.CARTI_PRESTADORES.subespe
    AND dbo.PRESTAD_SERVICIOS.servi_tipo = dbo.CARTI_PRESTADORES.servi_tipo
    AND dbo.PRESTAD_SERVICIOS.lugar = dbo.CARTI_PRESTADORES.lugar
    AND dbo.PRESTAD_SERVICIOS.prestad = dbo.CARTI_PRESTADORES.prestad
    AND dbo.PRESTAD_SERVICIOS.espe = dbo.CARTI_PRESTADORES.espe
    AND dbo.SUBESPECIALIDADES.subespe = dbo.CARTI_PRESTADORES.subespe
    LEFT OUTER JOIN dbo.ESPECIALIDADES_AFINIDAD ON dbo.PRESTAD_SERVICIOS.afinidad = dbo.ESPECIALIDADES_AFINIDAD.codigo
WHERE
    (dbo.PRESTAD_LUGARES.baja_fecha IS NULL)
    AND (dbo.CARTI_PRESTADORES.baja_fecha IS NULL)
    AND (dbo.LOCALIDADES.baja_fecha IS NULL)
    AND (dbo.TIPO_VIAS.baja_fecha IS NULL)
    AND (dbo.PARTIDOS.baja_fecha IS NULL)
    AND (dbo.PROVINCIAS.baja_fecha IS NULL)
    AND (dbo.PRESTAD_SERVICIOS.baja_fecha IS NULL)
    AND (dbo.PRESTADORES.baja_fecha IS NULL)
    AND (dbo.SERVI_TIPOS.baja_fecha IS NULL)
    AND (dbo.CARTILLAS.baja_fecha IS NULL)
    AND (dbo.CARTI_PRESTADORES.impre = 'S')
    AND (dbo.ESPECIALIDADES.baja_fecha IS NULL)
    AND (dbo.ESPECIALIDADES_AFINIDAD.baja_fecha IS NULL)
    AND (dbo.SUBESPECIALIDADES.baja_fecha IS NULL)
    AND (dbo.PRESTADORES.prestad IS NOT NULL)
    AND (dbo.PRESTAD_SERVICIOS.afinidad IS NOT NULL)
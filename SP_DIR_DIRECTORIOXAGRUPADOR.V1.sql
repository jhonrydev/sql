USE [CoreMP]
GO
/****** Object:  StoredProcedure [saludmp].[SP_DIR_DIRECTORIOXAGRUPADOR]    Script Date: 23/08/2024 2:35:15 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE [saludmp].[SP_DIR_DIRECTORIOXAGRUPADOR]
    @coderror INTEGER  =0  output,
    @msgerror VARCHAR(500)  =0  output,
    @ciudad VARCHAR(50),   
    @codAgrupa nvarchar(50),
	@cartilla VARCHAR(50) = NULL,
	@grupoPrograma VARCHAR(50) = NULL,
	@plan_codi VARCHAR(500) = NULL,
    @consulta_ciudad nvarchar(2)  = NULL,
    @consulta_agrupador nvarchar(2)  = NULL,
	@setplan_codi nvarchar(50)  = NULL

    AS   
	SET NOCOUNT ON
	select @consulta_ciudad = count(*) from  PARTIDOS 
        where partido  = @ciudad
	IF (@consulta_ciudad <= 0) BEGIN
	SELECT @coderror = 4;
	SELECT @msgerror = 'La ciudad no existe';
	END
	select @consulta_agrupador = count(*) from saludmp.DIR_AGRUPADORES 
        where cod_agrupador  = @codAgrupa
	IF (@consulta_agrupador <= 0) BEGIN
	SELECT @coderror = 5;
	SELECT @msgerror = 'El agrupador no existe';
	END
	IF (@plan_codi is null and @grupoPrograma is not null) BEGIN
	CREATE TABLE #tmp (plan_codi varchar(50))
	INSERT INTO #tmp
	select plan_codi from PLANES where plan_grupo = @grupoPrograma AND baja_fecha is null
	--select @plan_codi = plan_codi from  #tmp;
	END
	ELSE
	
	set @setplan_codi =  @plan_codi;
	
	
	

 
    SET NOCOUNT ON
	IF (@cartilla is not null and @plan_codi is not null  ) BEGIN
	select DISTINCT AG.cod_agrupador,
                    AG.descripcion as des_agrupador,
					AG.nivel_auditoria,
                    PAR.partido COD_CIUDAD,
                    PAR.descripcion AS CIUDAD, 
                    PRE.prestad AS COD_PRESTADOR, 
                    CONCAT(tv.deno, ' ' ,PL.num_nomb, ' ' ,PL.num_placa, ' ' , PL.complemento) AS DIRECCION, --NULA
                    PL.tele AS TELEFONO_1, 
                    PL.tele_2 AS TELEFONO_2, 
                    PL.telcelu_1 AS MOVIL_1, 
                    PL.telcelu_2 AS MOVIL_2, --REVISAR
                    PL.email_citas AS email,
                    PRE.email_2,
					PL.latitud,
					PL.longitud,
					PL.telcelu_wp,
					CASE WHEN (PRE.tipo = 'I' AND PRE.nombre_abre IS NULL)  
						THEN LTRIM(PRE.ape_razon) 
					WHEN (PRE.tipo = 'I' AND PRE.nombre_abre IS NOT NULL)  
						THEN LTRIM(PRE.nombre_abre) 
					ELSE 
					concat(LTRIM(PRE.ape_razon), ' ', PRE.apellido_2, ' ', PRE.nombre_abre, ' ', PRE.nombre_2) 
					END AS PRESTADOR,
					PRE.tipo as tipo_prestador,
					PRE.nombre_abre,
					PRE.ape_razon
    from  saludmp.DIR_AGRUPADORES AG
    inner join saludmp.DIR_AGRUPA_CUPS ac on ac.cod_agrupador = AG.cod_agrupador 
   	join PRESTACIONES PR on PR.prestac = ac.cod_cups      
    inner join CONVE_PRESTACIONES CV on CV.nomen = PR.nomen
    inner join CARTI_CONVENIOS CC on CC.conve = CV.conve
	left join CONVE_PRESTAC_DESHAB CD on CD.conve_prestac = CV.conve_prestac
	inner join CONVENIOS C on C.conve = CV.conve
    inner join PRESTADORES PRE on PRE.prestad = CC.prestad
	inner join PRESTAD_LUGARES PL on PL.prestad = PRE.prestad
    inner join PARTIDOS PAR on PAR.partido = PL.loca
	inner join TIPO_VIAS TV on tv.tipo_via=PL.tipo_via
	inner join COBERTURAS CB on cb.prestac = ac.cod_cups
 
    where PRE.baja_fecha IS NULL
    and PL.loca = @ciudad
    and AG.cod_agrupador = @codAgrupa
	and cc.carti = @cartilla
    and ac.estado = 'A'
	--and cd.des_desde is null
	and (cd.des_desde is null or cd.baja_fecha is not null) 
	and pl.baja_fecha is null
	and cv.baja_fecha is null
	and pr.baja_fecha is null
	and cc.baja_fecha is null
	and cc.lugar = pl.lugar
	and cc.conve = cv.conve
	and cc.prestad = pl.prestad
	and CV.prestac = ac.cod_cups
	and CB.ambu_inter = 'A'
	and CB.plan_codi IN (@setplan_codi)
 
	END
	/*IF (@cartilla is not null and @grupoPrograma is not null) BEGIN
	select DISTINCT AG.cod_agrupador,
                    AG.descripcion as des_agrupador,
					AG.nivel_auditoria,
                    PAR.partido COD_CIUDAD,
                    PAR.descripcion AS CIUDAD, 
                    PRE.prestad AS COD_PRESTADOR, 
                    CONCAT(tv.deno, ' ' ,PL.num_nomb, ' ' ,PL.num_placa, ' ' , PL.complemento) AS DIRECCION, --NULA
                    PL.tele AS TELEFONO_1, 
                    PL.tele_2 AS TELEFONO_2, 
                    PL.telcelu_1 AS MOVIL_1, 
                    PL.telcelu_2 AS MOVIL_2, --REVISAR
                    PL.email_citas AS email,
                    PRE.email_2,
					PL.latitud,
					PL.longitud,
					PL.telcelu_wp,
					CASE WHEN (PRE.tipo = 'I' AND PRE.nombre_abre IS NULL)  
						THEN LTRIM(PRE.ape_razon) 
					WHEN (PRE.tipo = 'I' AND PRE.nombre_abre IS NOT NULL)  
						THEN LTRIM(PRE.nombre_abre) 
					ELSE 
					concat(LTRIM(PRE.ape_razon), ' ', PRE.apellido_2, ' ', PRE.nombre_abre, ' ', PRE.nombre_2) 
					END AS PRESTADOR,
					PRE.tipo as tipo_prestador,
					PRE.nombre_abre,
					PRE.ape_razon
    from  saludmp.DIR_AGRUPADORES AG
    inner join saludmp.DIR_AGRUPA_CUPS ac on ac.cod_agrupador = AG.cod_agrupador 
   	join PRESTACIONES PR on PR.prestac = ac.cod_cups      
    inner join CONVE_PRESTACIONES CV on CV.nomen = PR.nomen
    inner join CARTI_CONVENIOS CC on CC.conve = CV.conve
	left join CONVE_PRESTAC_DESHAB CD on CD.conve_prestac = CV.conve_prestac
	inner join CONVENIOS C on C.conve = CV.conve
    inner join PRESTADORES PRE on PRE.prestad = CC.prestad
	inner join PRESTAD_LUGARES PL on PL.prestad = PRE.prestad
    inner join PARTIDOS PAR on PAR.partido = PL.loca
	inner join TIPO_VIAS TV on tv.tipo_via=PL.tipo_via
	inner join COBERTURAS CB on cb.prestac = ac.cod_cups
 
    where PRE.baja_fecha IS NULL
    and PL.loca = @ciudad
    and AG.cod_agrupador = @codAgrupa
	and cc.carti = @cartilla
    and ac.estado = 'A'
	--and cd.des_desde is null
	and (cd.des_desde is null or cd.baja_fecha is not null) 
	and pl.baja_fecha is null
	and cv.baja_fecha is null
	and pr.baja_fecha is null
	and cc.baja_fecha is null
	and cc.lugar = pl.lugar
	and cc.conve = cv.conve
	and cc.prestad = pl.prestad
	and CV.prestac = ac.cod_cups
	and CB.ambu_inter = 'A'
	and CB.plan_codi IN (select * from #tmp)
	IF (@plan_codi = '' and @grupoPrograma is not null) BEGIN
 
	DROP TABLE #tmp
	end
	*/
	

	IF (@cartilla is not null AND @plan_codi IS NULL) BEGIN
 
	select DISTINCT AG.cod_agrupador,
                    AG.descripcion as des_agrupador,
					AG.nivel_auditoria,
                    PAR.partido COD_CIUDAD,
                    PAR.descripcion AS CIUDAD, 
                    PRE.prestad AS COD_PRESTADOR, 
                    CONCAT(tv.deno, ' ' ,PL.num_nomb, ' ' ,PL.num_placa, ' ' , PL.complemento) AS DIRECCION, --NULA
                    PL.tele AS TELEFONO_1, 
                    PL.tele_2 AS TELEFONO_2, 
                    PL.telcelu_1 AS MOVIL_1, 
                    PL.telcelu_2 AS MOVIL_2, --REVISAR
                    PL.email_citas AS email,
                    PRE.email_2,
					PL.latitud,
					PL.longitud,
					PL.telcelu_wp,
					CASE WHEN (PRE.tipo = 'I' AND PRE.nombre_abre IS NULL)  
						THEN LTRIM(PRE.ape_razon) 
					WHEN (PRE.tipo = 'I' AND PRE.nombre_abre IS NOT NULL)  
						THEN LTRIM(PRE.nombre_abre) 
					ELSE 
					concat(LTRIM(PRE.ape_razon), ' ', PRE.apellido_2, ' ', PRE.nombre_abre, ' ', PRE.nombre_2) 
					END AS PRESTADOR,
					PRE.tipo as tipo_prestador,
					PRE.nombre_abre,
					PRE.ape_razon
    from  saludmp.DIR_AGRUPADORES AG
    inner join saludmp.DIR_AGRUPA_CUPS ac on ac.cod_agrupador = AG.cod_agrupador 
   	join PRESTACIONES PR on PR.prestac = ac.cod_cups      
    inner join CONVE_PRESTACIONES CV on CV.nomen = PR.nomen
    inner join CARTI_CONVENIOS CC on CC.conve = CV.conve
	left join CONVE_PRESTAC_DESHAB CD on CD.conve_prestac = CV.conve_prestac
	inner join CONVENIOS C on C.conve = CV.conve
    inner join PRESTADORES PRE on PRE.prestad = CC.prestad
	inner join PRESTAD_LUGARES PL on PL.prestad = PRE.prestad
    inner join PARTIDOS PAR on PAR.partido = PL.loca
	inner join TIPO_VIAS TV on tv.tipo_via=PL.tipo_via
	inner join COBERTURAS CB on cb.prestac = ac.cod_cups
    where PRE.baja_fecha IS NULL
    and PL.loca = @ciudad
    and AG.cod_agrupador = @codAgrupa
	and cc.carti = @cartilla
    and ac.estado = 'A'
	and (cd.des_desde is null or cd.baja_fecha is not null) 
	--and cd.des_desde is null
	and pl.baja_fecha is null
	and cv.baja_fecha is null
	and pr.baja_fecha is null
	and cc.baja_fecha is null
	and cc.lugar = pl.lugar
	and cc.conve = cv.conve
	and cc.prestad = pl.prestad
	and CV.prestac = ac.cod_cups
	and CB.ambu_inter = 'A'
	--and CB.plan_codi IN (@setplan_codi)
	END
	--END
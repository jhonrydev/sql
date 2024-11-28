USE [CoreMP]
GO
/****** Object:  StoredProcedure [dbo].[prs_planes_anexos_adicionales_programa_principal]    Script Date: 8/06/2023 10:14:15 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jhon Medina>
-- Create date: <20230712>
-- Description:	<Permite obtener las tarifas del los Pramas principales que tienen anexos>
-- =============================================
ALTER PROCEDURE [dbo].[prs_planes_anexos_adicionales_programa_principal]
	@plan VARCHAR(20),
	@cuenta VARCHAR(10),
	@subCuenta VARCHAR(10)
	
AS
BEGIN
	DECLARE 
		@programa VARCHAR(15) = LEFT(@plan,LEN(@plan)-1);
		
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    SELECT SPAT.cuenta, SPAT.subcta, SPAT.plan_codi AS codigo_plan_principal, SPAT.plan_codi_adi AS codigo_plan_anexo,PLS.deno AS nombre_anexo, /*SPAT.tari AS tarifa,*/ TC.tari AS tarifia_anexo, TC.tope, TC.valor  
	FROM TARI_CAPITAS TC
	INNER JOIN SUBCTA_PLAN_ADI_TARI SPAT ON TC.tari = SPAT.tari
	INNER JOIN PLANES PLS ON SPAT.plan_codi_adi = PLS.plan_codi
	WHERE TC.baja_fecha IS NULL 
		AND TC.vigen_desde >= '2023-01-01 00:00:00.000'
		AND TC.valor <>'0'
		AND SPAT.baja_fecha IS NULL 
		AND SPAT.inhab_fecha IS NULL 
		AND SPAT.cuenta = @cuenta
		AND SPAT.subcta = @subCuenta
		AND SPAT.plan_codi_adi = @plan
		AND PLS.plan_grupo = @programa 
		AND PLS.princi = 'N' 
		AND PLS.baja_fecha IS NULL 
		AND PLS.fecha_inhab IS NULL
	ORDER BY codigo_plan_anexo;
END

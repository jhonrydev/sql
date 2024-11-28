CREATE PROCEDURE [saludmp].[afs_saldos_por_nit_mp] ( 
	@tipo_documento CHAR(2) ,
    @id_documento CHAR(15) ,
    @codError TINYINT OUTPUT,
    @msgError VARCHAR(100) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

	IF (@tipo_documento = ''  )
		BEGIN
			SET @coderror = 15;
            SET @msgerror = 'Debe ingresar el valor de "tipo_documento" es obligatorio.';
			RETURN;
		END

	IF (@id_documento ='')
		BEGIN
			SET @coderror = 15;
            SET @msgerror = 'Debe ingresar el valor de "id_documento" es obligatorio.';
            RETURN;
		END
	
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
		 codigo_dian VARCHAR(100) NULL,
		 saldo_seguro DECIMAL(18,0) NULL,
		 saldo_sin_seguro DECIMAL(18,0) NULL,
		 comprobante_ec INTEGER NULL
		 );

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
		 tipo_comprobante CHAR (5),
		 codigo_dian VARCHAR(100) NULL,
		 saldo_seguro DECIMAL(18,0) NULL,
		 saldo_sin_seguro DECIMAL(18,0) NULL,
		 comprobante_ec INTEGER NULL
		 );

	 INSERT INTO #COMPROBANTES_TEMP
		 (
		 consecutivo ,
		 sucur_deno ,
		 subcta_tipo_deno ,
		 plan_codi ,
		 fecha_vto ,
		 contra ,
		 saldo ,
		 valor_base_saldo ,
		 iva_saldo ,
		 linea_negocio ,
		 tipo_comprobante,
		 codigo_dian ,
		 saldo_seguro ,
		 saldo_sin_seguro ,
		 comprobante_ec 
		 )  
	 
	 EXEC [saludmp].[afs_saldos_por_nit]
        @prm_docu_tipo = @tipo_documento,
        @prm_docu_nro = @id_documento,
		@prm_error = @codError OUTPUT,
		@prm_error_deno = @msgError OUTPUT
      

	SELECT 
		consecutivo ,
		RTRIM(sucur_deno) AS sucursal,
		"plan" = subcta_tipo_deno ,
		PLANES.deno AS programa ,
		CONVERT(VARCHAR,fecha_vto,23) AS fecha_vencimiento,
		RTRIM(contra) AS contrato ,
		saldo  ,
		valor_base_saldo ,
		iva_saldo  ,
		RTRIM(linea_negocio) AS linea_negocio,
		tipo_comprobante,
		codigo_dian ,
		saldo_seguro  ,
		saldo_sin_seguro  ,
		comprobante_ec 
	FROM #COMPROBANTES_TEMP COMP INNER JOIN PLANES ON COMP.plan_codi=PLANES.plan_codi order by contrato, tipo_comprobante
	
	DROP TABLE #COMPROBANTES_TEMP
	
	SET @coderror = 0;
    SET @msgerror = 'OK';
	RETURN;

END;
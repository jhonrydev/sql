USE [PreCoreMP]
GO
/****** Object:  StoredProcedure [saludmp].[afs_consulta_saldos_efecty_bancoomeva]    Script Date: 17/10/2024 7:27:31 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
 PROCEDURE : afs_consulta_saldos_efecty_bancoomeva
 Programmer : LF
 Parameters : 
 Description : 
 History :
 BUG DATE PROGRAMMER DESCRIPTION REFERENCE
 3738 2018-02-14 LF Se creo el SP.
 R17892 20200528 NPAZ Crear sp para loguear en WS_LOG_EVENTOS
*/
ALTER PROCEDURE [saludmp].[afs_consulta_saldos_efecty_bancoomeva] (
    @coderror INTEGER = NULL OUTPUT,
    @msgerror VARCHAR(500) = NULL OUTPUT,
    @prm_nit_empresa CHAR(30),
    @prm_ref_oficina CHAR(15),
    @prm_documento CHAR(15),
    @prm_consecutivo_consulta VARCHAR(255) = NULL ,
    @prm_moneda CHAR(3) = NULL ,
    @prm_nombre_usuario VARCHAR(255) = NULL ,
    @prm_valor_adeudado DECIMAL(14,2) = NULL ,
    @prm_codigo_error TINYINT = NULL ,
    @prm_descripcion_error VARCHAR(255) = NULL 
   
 )
 
AS
BEGIN
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

    IF (@prm_nit_empresa = '' OR @prm_nit_empresa = 'NULL' OR @prm_nit_empresa IS NULL) 
        BEGIN 
            SET @coderror = 5;
            SET @msgerror = 'Debe ingresar el valor de "prm_nit_empresa" es obligatorio.';
            RETURN
        END;

    IF (@prm_ref_oficina = '' OR @prm_ref_oficina = 'NULL' OR @prm_ref_oficina IS NULL) 
        BEGIN 
            SET @coderror = 5;
            SET @msgerror = 'Debe ingresar el valor de "prm_ref_oficina" es obligatorio.';
            RETURN
        END;

    IF (@prm_documento = '' OR @prm_documento = 'NULL' OR @prm_documento IS NULL) 
        BEGIN 
            SET @coderror = 5;
            SET @msgerror = 'Debe ingresar el valor de "prm_documento" es obligatorio.';
            RETURN
        END;
    --Registración en Log de Eventos
    DECLARE 
    @var_cod_unico_persona INT,
    @valor_adeudado DECIMAL(14,2),
    @var_fecha_proc DATETIME,
    @out_id_log_evento INTEGER,
    @con_sistema CHAR(20),
    @var_param_entrada VARCHAR(255),
    @prm_nit_empresa2 VARCHAR(20), 
    @var_param_salida VARCHAR(255),
    @var_cuenta INTEGER,
    @con_destino_afiliado CHAR(1) = 'A',
    @con_destino_empresa CHAR(1) = 'E'
    SET @prm_codigo_error = NULL
    SET @var_fecha_proc = GETDATE()
    SET @prm_valor_adeudado = 0
    SET @con_sistema = 'WS_SALDOS'
    SET @prm_nit_empresa2 = (SELECT SUBSTRING(@prm_nit_empresa, 1, LEN(@prm_nit_empresa)-1)) 
    SET @var_param_entrada = CONCAT('nit_empresa:',RTRIM(@prm_nit_empresa2),', ref_Oficina:',RTRIM(@prm_ref_Oficina),', documento:',@prm_documento)
 
    EXECUTE dbo.afu_ws_log_eventos @prm_id = @out_id_log_evento OUTPUT,
    @prm_sistema = @con_sistema,
    @prm_fecha_entrada = @var_fecha_proc,
    @prm_param_entrada = @var_param_entrada

    CREATE TABLE #CONTRATOS_EFECTY
    (
        prepaga SMALLINT,
        contra CHAR(15)
    )

    CREATE TABLE #SUBCUENTAS_EFECTY
    (
        cuenta INTEGER,
        subcta CHAR(6)
    )

    CREATE TABLE #SUBCTA_TIPO_ENTE_REC
    (
        subcta_tipo CHAR(3)
    )
    
 /****Validación de los parámetros de entrada****/

    IF NOT EXISTS(SELECT 1 --Puede haber mas de uno
    FROM ENTE_RECAUDADOR 
    WHERE NIT = @prm_nit_empresa2
    AND baja_fecha IS NULL)
        BEGIN
            -- SET @prm_codigo_error = 1
            -- SET @prm_descripcion_error = 'El NitEmpresa no existe.'

            SET @coderror = 1
            SET @msgerror = 'El NitEmpresa no existe.'
        END
    ELSE
        BEGIN
            SELECT @var_cod_unico_persona = codigo_unico_persona 
            FROM REGISTRO_UNICO_DOCUMENTO
            WHERE docu_nro = @prm_documento
    
            IF @@ROWCOUNT > 1 
                BEGIN 
                    -- SET @prm_codigo_error = 1
                    -- SET @prm_descripcion_error = 'Existe más de una persona con ese documento.' 
                    
                    SET @coderror = 1
                    SET @msgerror = 'Existe más de una persona con ese documento.' 
                END
            
            ELSE
                BEGIN
                    INSERT INTO #SUBCTA_TIPO_ENTE_REC(subcta_tipo )
                        SELECT DISTINCT subcta_tipo = ERST.subcta_tipo
                        FROM ENTE_RECAUDADOR AS ER INNER JOIN ENTE_REC_SUBCTA_TIPO AS ERST ON ERST.ente_rec = ER.ente_rec
                        WHERE ER.NIT = @prm_nit_empresa2 
                        AND ER.baja_fecha IS NULL
                        AND ERST.baja_fecha IS NULL
        
                    INSERT INTO #CONTRATOS_EFECTY( prepaga , contra )
                        SELECT prepaga = CON.prepaga, contra = CON.contra
                        FROM dbo.afn_contratos_del_contratante(@var_cod_unico_persona,@var_fecha_proc) AS CON

                    INSERT INTO #SUBCUENTAS_EFECTY ( cuenta , subcta )
                        SELECT cuenta = SUB.cuenta, subcta = SUB.subcta
                        FROM CUENTAS AS CUE INNER JOIN SUBCUENTAS AS SUB ON SUB.cuenta = CUE.cuenta
                        WHERE CUE.docu_nro = @prm_documento
        
                    DELETE #CONTRATOS_EFECTY 

                    FROM #CONTRATOS_EFECTY AS CON INNER JOIN AFI_PLANES AS AP ON CON.prepaga = AP.prepaga
                    AND CON.contra = AP.contra
                    AND AP.vigen_desde = (SELECT MAX(vigen_desde)
                        FROM AFI_PLANES
                        WHERE prepaga = AP.prepaga
                        AND contra = AP.contra
                        AND vigen_desde <= @var_fecha_proc
                        AND (baja_fecha IS NULL OR baja_fecha > @var_fecha_proc)
                        )
                    INNER JOIN PLANES AS PLA ON AP.plan_codi = PLA.plan_codi
                    INNER JOIN PLANES_GRUPOS AS PG ON PLA.plan_grupo = PG.plan_grupo
                    WHERE PG.linea_negocio = 3


                    DELETE #CONTRATOS_EFECTY 
                    FROM #CONTRATOS_EFECTY AS CON
                    INNER JOIN AFI_CLASE AS AP ON CON.prepaga = AP.prepaga AND CON.contra = AP.contra 
                    AND AP.vigen_desde = (SELECT MAX(vigen_desde)
                        FROM AFI_CLASE
                        WHERE prepaga = AP.prepaga
                        AND contra = AP.contra
                        AND vigen_desde <= @var_fecha_proc
                        AND (baja_fecha IS NULL OR baja_fecha > @var_fecha_proc)
                    ) INNER JOIN SUBCTA_CONTRATO AS SC ON SC.cuenta = AP.cuenta  AND SC.subcta = AP.subcta
                    AND SC.vigen_desde = (SELECT MAX(vigen_desde) 
                        FROM SUBCTA_CONTRATO
                        WHERE cuenta = SC.cuenta
                        AND subcta = SC.subcta
                        AND vigen_desde <= @var_fecha_proc
                        AND (baja_fecha IS NULL OR baja_fecha > @var_fecha_proc)
                    )
                    LEFT JOIN #SUBCTA_TIPO_ENTE_REC AS ST ON ST.subcta_tipo = SC.subcta_tipo
                    WHERE ST.subcta_tipo IS NULL


                    DELETE #SUBCUENTAS_EFECTY
                    FROM #SUBCUENTAS_EFECTY AS SUB
                    INNER JOIN SUBCTA_PLANES AS SP ON SUB.cuenta = SP.cuenta AND SUB.subcta = SP.subcta
                    AND SP.plan_codi = (SELECT MIN(plan_codi)
                        FROM SUBCTA_PLANES
                        WHERE cuenta = SP.cuenta
                        AND subcta = SP.subcta
                        AND (baja_fecha IS NULL OR baja_fecha > @var_fecha_proc)
                        )
                    INNER JOIN PLANES AS PLA ON SP.plan_codi = PLA.plan_codi
                    INNER JOIN PLANES_GRUPOS AS PG ON PLA.plan_grupo = PG.plan_grupo
                    WHERE PG.linea_negocio = 3
        

                    DELETE #SUBCUENTAS_EFECTY
                    FROM #SUBCUENTAS_EFECTY AS SUB
                    INNER JOIN SUBCTA_CONTRATO AS SC ON SC.cuenta = SUB.cuenta AND SC.subcta = SUB.subcta
                    AND SC.vigen_desde = (SELECT MAX(vigen_desde) 
                        FROM SUBCTA_CONTRATO
                        WHERE cuenta = SC.cuenta
                        AND subcta = SC.subcta
                        AND vigen_desde <= @var_fecha_proc
                        AND (baja_fecha IS NULL OR baja_fecha > @var_fecha_proc)
                        )
                    LEFT JOIN #SUBCTA_TIPO_ENTE_REC AS ST
                    ON ST.subcta_tipo = SC.subcta_tipo
                    WHERE ST.subcta_tipo IS NULL

                    IF NOT( EXISTS (SELECT 1 FROM #CONTRATOS_EFECTY)  OR EXISTS(SELECT 1 FROM #SUBCUENTAS_EFECTY) ) 
                        BEGIN 
                            -- SET @prm_codigo_error = 1
                            -- SET @prm_descripcion_error = 'El contratante no existe.'
                            SET @coderror = 1
                            SET @msgerror = 'El contratante no existe.'
                        END
                END
        END

   

    -- IF @prm_codigo_error <> 0
    IF @coderror <> 0
        BEGIN
            EXECUTE dbo.afu_ws_log_eventos @prm_id = @out_id_log_evento,
            @prm_codigo_error = @coderror,
            @prm_descripcion_error = @msgerror
            -- @prm_codigo_error = @prm_codigo_error,
            -- @prm_descripcion_error = @prm_descripcion_error
        RETURN
    END
 
 /****Validación de los parámetros de entrada****/
 /*CONTRATOS INDIVIDUALES O ACUERDOS COLECTIVOS*/
    SELECT @valor_adeudado = sum(C.saldo)
    FROM #CONTRATOS_EFECTY AS CON INNER JOIN COMPROBANTES AS C ON C.aplica = 1
        AND C.factu_destino = @con_destino_afiliado
        AND C.contra = CON.contra
        AND C.prepaga = CON.prepaga
    INNER JOIN #SUBCTA_TIPO_ENTE_REC AS ERST ON ERST.subcta_tipo = C.subcta_tipo
    WHERE C.saldo <> 0 
 
    IF @valor_adeudado IS NOT NULL
        SET @prm_valor_adeudado = @valor_adeudado 
    
    DELETE #SUBCUENTAS_EFECTY
    FROM #SUBCUENTAS_EFECTY AS SUB
    WHERE EXISTS( SELECT 1 
        FROM SUBCTA_ESTADOS AS SE
        INNER JOIN HAB_INHAB_MOTIVOS AS HI
        ON SE.inhab_motivo = hi.hab_inhab_moti
        WHERE SE.cuenta = SUB.cuenta 
        AND SE.subcta = SUB.subcta
        AND SE.vigen_desde <= @var_fecha_proc
        AND (SE.vigen_hasta IS NULL OR SE.vigen_hasta > @var_fecha_proc)
        AND SE.baja_fecha IS NULL
        AND SE.ESTADO = 'I'
        AND HI.uso_depuracion = 'S'
        )
 
 /* CONTRATOS COLECTIVOS */
    SELECT @valor_adeudado = SUM(C.saldo)
    FROM #SUBCUENTAS_EFECTY AS SUB INNER JOIN COMPROBANTES AS C ON C.aplica = 1
        AND C.factu_destino = @con_destino_empresa
        AND C.cuenta = SUB.cuenta
        AND C.subcta = SUB.subcta
    INNER JOIN #SUBCTA_TIPO_ENTE_REC AS ERST ON ERST.subcta_tipo = C.subcta_tipo
    WHERE C.saldo <> 0 

    IF @valor_adeudado IS NOT NULL
        SELECT @prm_valor_adeudado = @prm_valor_adeudado + @valor_adeudado

    IF @prm_valor_adeudado < 0 
        SELECT @prm_valor_adeudado = 0
    
    IF @var_cod_unico_persona IS NOT NULL 
        SELECT @prm_nombre_usuario = ( SELECT CONCAT(nombre,isnull(' ' + nombre2,''),' ' + ape,isnull(' ' + ape2,'')) 
        FROM REGISTRO_UNICO 
        WHERE codigo_unico_persona = @var_cod_unico_persona )
    ELSE
        SELECT @prm_nombre_usuario = (SELECT razon FROM CUENTAS WHERE docu_nro = @prm_documento)
        SELECT @prm_consecutivo_consulta = @out_id_log_evento,
        @prm_moneda = 'COP',
        @coderror = 0,
        @msgerror = NULL
        -- @prm_codigo_error = 0,
        -- @prm_descripcion_error = NULL
 --Logueamos la salida
        SET @var_fecha_proc = GETDATE()
        SET @var_param_salida = concat(@prm_moneda,', ', @prm_nombre_usuario,', ',cast(@prm_valor_adeudado as varchar))
        EXECUTE dbo.afu_ws_log_eventos @prm_id = @out_id_log_evento,
        -- @prm_codigo_error = @prm_codigo_error,
        -- @prm_param_salida = @var_param_salida,
        @prm_codigo_error = @coderror,
        @prm_param_salida = @var_param_salida,
        @prm_fecha_salida = @var_fecha_proc

    SELECT @prm_consecutivo_consulta AS prm_consecutivo_consulta, @prm_moneda AS prm_moneda,  @prm_nombre_usuario AS prm_nombre_usuario, @prm_valor_adeudado AS prm_valor_adeudado
    SET @coderror = 0
    SET @msgerror = 'Ok'
    RETURN
END

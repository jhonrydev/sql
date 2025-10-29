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
    @prm_nit_empresa CHAR(30),
    @prm_ref_oficina CHAR(15),
    @prm_documento CHAR(15),
    @consecutivo_consulta VARCHAR(255) = NULL ,
    @moneda CHAR(3) = NULL ,
    @nombre_usuario VARCHAR(255) = NULL ,
    @valor_adeudado DECIMAL(14,2) = NULL ,
    @coderror INTEGER = NULL OUTPUT,
    @msgerror VARCHAR(500) = NULL OUTPUT
   
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

    DECLARE	@return_value int,
		@prm_consecutivo_consulta varchar(255),
		@prm_moneda char(3),
		@prm_nombre_usuario varchar(255),
		@prm_valor_adeudado decimal(14, 2),
		@prm_codigo_error tinyint,
		@prm_descripcion_error varchar(255)

        EXECUTE dbo.afs_consulta_saldos_efecty_bancoomeva
        @prm_nit_empresa = @prm_nit_empresa,
		@prm_ref_oficina = @prm_ref_oficina,
		@prm_documento = @prm_documento,
		@prm_consecutivo_consulta = @prm_consecutivo_consulta OUTPUT,
		@prm_moneda = @prm_moneda OUTPUT,
		@prm_nombre_usuario = @prm_nombre_usuario OUTPUT,
		@prm_valor_adeudado = @prm_valor_adeudado OUTPUT,
		@prm_codigo_error = @prm_codigo_error OUTPUT,
		@prm_descripcion_error = @prm_descripcion_error OUTPUT

        SET @consecutivo_consulta = @prm_consecutivo_consulta
        SET @moneda = @prm_moneda
        SET @nombre_usuario = @prm_nombre_usuario
        SET @valor_adeudado = @prm_valor_adeudado
        SET @coderror = @prm_codigo_error
        SET @msgerror = @prm_descripcion_error

        IF @coderror = 0
            BEGIN
                SELECT @prm_consecutivo_consulta AS prm_consecutivo_consulta, @prm_moneda AS prm_moneda,  @prm_nombre_usuario AS prm_nombre_usuario, @prm_valor_adeudado AS prm_valor_adeudado
                SET @coderror = 0
                SET @msgerror = 'Ok'
                RETURN
            END
        -- ELSE
        --     BEGIN
        --         RETURN 
        --         @coderror
        --         @msgerror
        --     END
END
GO

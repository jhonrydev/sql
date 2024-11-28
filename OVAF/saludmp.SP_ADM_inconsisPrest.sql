USE [PreCoreMP]
GO
CREATE PROCEDURE [saludmp].[SP_ADM_inconsisPrest2]
    @coderror INTEGER  =0  output,
    @msgerror VARCHAR(500)  =0  output,
    @cod_tipo_datopres VARCHAR(20),
    @observacion VARCHAR(4000),      
    @cod_prestador nvarchar(5),
    @app VARCHAR(20)  = NULL,
    @cod_inconsis_prestapp INTEGER  = NULL,
    @contarE  nvarchar(2)  = NULL,
    @contarC  nvarchar(2)  = NULL
AS  
    SET NOCOUNT ON

	IF (@app = '') 
        BEGIN 
            SET @coderror = 4;
            SET @msgerror = 'Debe ingresar la APP que presenta la inconsistencia.';
            GOTO ERROR
        END	
	
	SELECT @contarE=COUNT(*)  
    FROM dbo.fn_Split(@cod_tipo_datopres, ',')

	SELECT @contarC=COUNT(*)  
    FROM dbo.fn_Split(@cod_tipo_datopres, ',') a, saludmp.ADM_P_TIPO_DATOPRES b
    WHERE a.value = b.cod_tipo_datopres
	
	
	IF (@contarE <> @contarC) 
        BEGIN
            SELECT @coderror = 5; 
            SELECT @msgerror = 'Al menos uno de los tipos de datos inconsistentes ingresados NO EXISTE';
            GOTO ERROR
        END	
	
    BEGIN TRANSACTION 	
        INSERT INTO saludmp.ADM_INCONSIS_PRESTAPP (cod_tipo_datopres, observacion, cod_prestador, fecha_registro, app)
        VALUES ( @cod_tipo_datopres, @observacion, @cod_prestador, GETDATE(), @app)
	COMMIT TRANSACTION
	
    SET @coderror = 0;
	SET @msgerror = 'Se Registro Exitosamente';				

    SET @cod_inconsis_prestapp = scope_identity()
	
	SELECT cod_inconsis_prestapp
    FROM saludmp.ADM_INCONSIS_PRESTAPP
    WHERE cod_inconsis_prestapp = @cod_inconsis_prestapp   

 RETURN  
 ERROR:
 SELECT cod_inconsis_prestapp = NULL
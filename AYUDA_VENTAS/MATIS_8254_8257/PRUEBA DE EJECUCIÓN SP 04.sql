USE [PreCoreMP]
GO

DECLARE	@return_value int,
		@coderror int,
		@msgerror varchar(500)

EXEC	@return_value = [saludmp].[SP_ADM_inconsisPrest2]
		@coderror = @coderror OUTPUT,
		@msgerror = @msgerror OUTPUT,
		@cod_tipo_datopres = N'1,2,3,4',
		@observacion = N'prueba observación',
		@cod_prestador = N'7167',
        @cod_ciudad_prestador = N'50006',
		@app = N'APPMP',
		@ruta = N'ACACIAS - META / Urgencias',
		@tipo_id_usuario = N'PA',
		@id_usuario = N'123456789',
		@cod_inconsistencia = NULL,
		@cod_inconsis_prestapp = NULL,
		@contarE = NULL,
		@contarC = NULL,
		@separator = ',',
		@cadena = NULL,
		@individual = NULL

SELECT	@coderror as N'@coderror',
		@msgerror as N'@msgerror'

SELECT	'Return Value' = @return_value

GO

--======================================================================================
USE [PreCoreMP]
GO

DECLARE	@return_value int,
		@coderror int,
		@msgerror varchar(500)

EXEC	@return_value = [saludmp].[SP_ADM_inconsisPrest2]
		@coderror = @coderror OUTPUT,
		@msgerror = @msgerror OUTPUT,
		@cod_tipo_datopres = N'1,2,3,4',
		@observacion = N'prueba observación',
		@cod_prestador = N'4156',
        @cod_ciudad_prestador = N'76001',
		@app = N'APPMP',
		@ruta = N'ACACIAS - META / Urgencias',
		@tipo_id_usuario = N'RC',
		@id_usuario = N'000006102',
		@cod_inconsistencia = NULL,
		@cod_inconsis_prestapp = NULL,
		@contarE = NULL,
		@contarC = NULL,
		@separator = ',',
		@cadena = NULL,
		@individual = NULL

SELECT	@coderror as N'@coderror',
		@msgerror as N'@msgerror'

SELECT	'Return Value' = @return_value

GO
--======================================================================================
USE [PreCoreMP]
GO

DECLARE	@return_value int,
		@coderror int,
		@msgerror varchar(500)

EXEC	@return_value = [saludmp].[SP_ADM_inconsisPrest2]
		@coderror = @coderror OUTPUT,
		@msgerror = @msgerror OUTPUT,
		@cod_tipo_datopres = N'1,2,3,4',
		@observacion = N'prueba observación',
		@cod_prestador = N'5131',
        @cod_ciudad_prestador = N'05001',
		@app = N'APPMP',
		@ruta = N'ACACIAS - META / Urgencias',
		@tipo_id_usuario = N'CC',
		@id_usuario = N'007853262',
		@cod_inconsistencia = NULL,
		@cod_inconsis_prestapp = NULL,
		@contarE = NULL,
		@contarC = NULL,
		@separator = ',',
		@cadena = NULL,
		@individual = NULL

SELECT	@coderror as N'@coderror',
		@msgerror as N'@msgerror'

SELECT	'Return Value' = @return_value

GO
--======================================================================================
USE [PreCoreMP]
GO

DECLARE	@return_value int,
		@coderror int,
		@msgerror varchar(500)

EXEC	@return_value = [saludmp].[SP_ADM_inconsisPrest2]
		@coderror = @coderror OUTPUT,
		@msgerror = @msgerror OUTPUT,
		@cod_tipo_datopres = N'1,2,3,4',
		@observacion = N'prueba observación',
		@cod_prestador = N'6820',
        @cod_ciudad_prestador = N'18001',
		@app = N'APPMP',
		@ruta = N'ACACIAS - META / Urgencias',
		@tipo_id_usuario = N'PA',
		@id_usuario = N'0702203175',
		@cod_inconsistencia = NULL,
		@cod_inconsis_prestapp = NULL,
		@contarE = NULL,
		@contarC = NULL,
		@separator = ',',
		@cadena = NULL,
		@individual = NULL

SELECT	@coderror as N'@coderror',
		@msgerror as N'@msgerror'

SELECT	'Return Value' = @return_value

GO
--======================================================================================
USE [PreCoreMP]
GO

DECLARE	@return_value int,
		@coderror int,
		@msgerror varchar(500)

EXEC	@return_value = [saludmp].[SP_ADM_inconsisPrest2]
		@coderror = @coderror OUTPUT,
		@msgerror = @msgerror OUTPUT,
		@cod_tipo_datopres = N'1,2,3,4',
		@observacion = N'prueba observación',
		@cod_prestador = N'7649',
        @cod_ciudad_prestador = N'17174',
		@app = N'APPMP',
		@ruta = N'ACACIAS - META / Urgencias',
		@tipo_id_usuario = N'CE',
		@id_usuario = N'0818304',
		@cod_inconsistencia = NULL,
		@cod_inconsis_prestapp = NULL,
		@contarE = NULL,
		@contarC = NULL,
		@separator = ',',
		@cadena = NULL,
		@individual = NULL

SELECT	@coderror as N'@coderror',
		@msgerror as N'@msgerror'

SELECT	'Return Value' = @return_value

GO
--======================================================================================
USE [PreCoreMP]
GO

DECLARE	@return_value int,
		@coderror int,
		@msgerror varchar(500)

EXEC	@return_value = [saludmp].[SP_ADM_inconsisPrest2]
		@coderror = @coderror OUTPUT,
		@msgerror = @msgerror OUTPUT,
		@cod_tipo_datopres = N'1,2,3,4',
		@observacion = N'prueba observación',
		@cod_prestador = N'4130',
        @cod_ciudad_prestador = N'08001',
		@app = N'APPMP',
		@ruta = N'ACACIAS - META / Urgencias',
		@tipo_id_usuario = N'CC',
		@id_usuario = N'10000511',
		@cod_inconsistencia = NULL,
		@cod_inconsis_prestapp = NULL,
		@contarE = NULL,
		@contarC = NULL,
		@separator = ',',
		@cadena = NULL,
		@individual = NULL

SELECT	@coderror as N'@coderror',
		@msgerror as N'@msgerror'

SELECT	'Return Value' = @return_value

GO
--======================================================================================
USE [PreCoreMP]
GO

DECLARE	@return_value int,
		@coderror int,
		@msgerror varchar(500)

EXEC	@return_value = [saludmp].[SP_ADM_inconsisPrest2]
		@coderror = @coderror OUTPUT,
		@msgerror = @msgerror OUTPUT,
		@cod_tipo_datopres = N'1,2,3,4',
		@observacion = N'prueba observación',
		@cod_prestador = N'5214',
        @cod_ciudad_prestador = N'54001',
		@app = N'APPMP',
		@ruta = N'ACACIAS - META / Urgencias',
		@tipo_id_usuario = N'CC',
		@id_usuario = N'10000511',
		@cod_inconsistencia = NULL,
		@cod_inconsis_prestapp = NULL,
		@contarE = NULL,
		@contarC = NULL,
		@separator = ',',
		@cadena = NULL,
		@individual = NULL

SELECT	@coderror as N'@coderror',
		@msgerror as N'@msgerror'

SELECT	'Return Value' = @return_value

GO

-- =============================================================================================================================================
SELECT DISTINCT TOP 10 PRESTAD, regional FROM Visor_directorios_5 WHERE regional IN (SELECT ofi FROM LIQUI_OFICINAS);
-- =============================================================================================================================================
SELECT DISTINCT TOP 10 ASE.NumeroDocumento,ASE.IdTipoDocumento,ASEP.IdRegional FROM Asesor ASE INNER JOIN AsesorPlan ASEP ON ASE.IdAsesor=ASEP.IdAsesor
WHERE ASE.IdTipoDocumento  NOT IN ('NI','CC') AND ASEP.IdRegional = 10 ;--IN (SELECT ofi FROM LIQUI_OFICINAS);
-- =============================================================================================================================================
SELECT ofi,deno FROM LIQUI_OFICINAS



SELECT distinct TOP 1000 count(1),docu_tipo,docu_nro
FROM AFILIADOS where baja_fecha IS NULL
group by docu_tipo,docu_nro



select * from saludmp.ADM_INCONSIS_PRESTAPP_3;
select * from saludmp.ADM_GESTION_INCONSISTENCIA_PRESTADORES;
select * from Asesor;
select * from AsesorPlan

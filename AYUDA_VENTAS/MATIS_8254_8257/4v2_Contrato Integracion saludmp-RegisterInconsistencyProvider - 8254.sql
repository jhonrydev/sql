/*
  Nombre del Stored Procedure: SP_ADM_REGISTER_INCONSISTENCIES_PROVIDERS
  Autor: Jhon Medina
  Fecha de creación: Abril 2024
  Objetivo: Permite registrar los fallos encontrados por el usuario en un prestador
*/
CREATE PROCEDURE [saludmp].[SP_ADM_REGISTER_INCONSISTENCIES_PROVIDERS]
    @coderror INTEGER  =0  output,
    @msgerror VARCHAR(500)  =0  output,
    @cod_tipo_datopres VARCHAR(20),
    @observacion VARCHAR(4000)=NULL,      
    @cod_prestador VARCHAR(5),
	@cod_ciudad_prestador CHAR(6),
    @app VARCHAR(20)  = NULL,
	@ruta VARCHAR(400),
	@tipo_id_usuario VARCHAR(2),
	@id_usuario VARCHAR(15)
AS  

	SET NOCOUNT ON
	
	DECLARE @cod_inconsistencia VARCHAR(20)=NULL
    DECLARE @cod_inconsis_prestapp INTEGER  = NULL
	DECLARE @contarE  VARCHAR(MAX)  = NULL
	DECLARE @contarC  VARCHAR(MAX)  = NULL
	DECLARE @separator CHAR(1)=','
	DECLARE @cadena VARCHAR(MAX) = NULL
	DECLARE @individual VARCHAR(MAX) = NULL

	CREATE TABLE #ADM_INCONSISTENCIAS_PRESTADORES_X_APP( cod_tipo_datopres VARCHAR(20))

	DECLARE curso_tipo_inconsistencias_reportadas CURSOR FOR
		SELECT cod_tipo_datopres 
		FROM #ADM_INCONSISTENCIAS_PRESTADORES_X_APP;
		
	IF (@cod_tipo_datopres = '' OR @cod_tipo_datopres IS NULL) 
        BEGIN 
            SET @coderror = 5;
            SET @msgerror = 'Debe ingresar el valor de "cod_tipo_datopres" es obligatorio.';
            GOTO ERROR
        END	

	-- IF (@observacion = '' OR @observacion IS NULL) 
	-- 	BEGIN 
	-- 		SET @coderror = 5;
	-- 		SET @msgerror = 'Debe ingresar el valor de "observacion" es obligatorio.';
	-- 		GOTO ERROR
	-- 	END	

	IF (@cod_prestador = '' OR @cod_prestador IS NULL) 
		BEGIN 
			SET @coderror = 5;
			SET @msgerror = 'Debe ingresar el valor de "cod_prestador" es obligatorio.';
			GOTO ERROR
		END	

	IF (@cod_ciudad_prestador = '' OR @cod_ciudad_prestador IS NULL) 
		BEGIN 
			SET @coderror = 5;
			SET @msgerror = 'Debe ingresar el valor de "cod_ciudad_prestador" es obligatorio.';
			GOTO ERROR
		END	

	IF (@app = '' OR @app IS NULL) 
		BEGIN 
			SET @coderror = 5;
			SET @msgerror = 'Debe ingresar el valor de "app" es obligatorio.';
			GOTO ERROR
		END
		
	IF (@ruta = '' OR @ruta IS NULL) 
		BEGIN 
			SET @coderror = 5;
			SET @msgerror = 'Debe ingresar el valor de "ruta" es obligatorio.';
			GOTO ERROR
		END
	
	-- IF (@tipo_id_usuario = '' OR @tipo_id_usuario IS NULL) 
	-- 	BEGIN 
	-- 		SET @coderror = 5;
	-- 		SET @msgerror = 'Debe ingresar el valor de "tipo_id_usuario" es obligatorio.';
	-- 		GOTO ERROR
	-- 	END

	-- IF (@id_usuario = '' OR @id_usuario IS NULL) 
	-- 	BEGIN 
	-- 		SET @coderror = 5;
	-- 		SET @msgerror = 'Debe ingresar el valor de "id_usuario" es obligatorio.';
	-- 		GOTO ERROR
	-- 	END

	SELECT @contarE=COUNT(*)  
    FROM dbo.fn_Split(@cod_tipo_datopres, ',')

	SELECT @contarC=COUNT(*)  
    FROM dbo.fn_Split(@cod_tipo_datopres, ',') a, saludmp.ADM_P_TIPO_DATOPRES b
    WHERE a.value = b.cod_tipo_datopres
	
	
	IF (@contarE <> @contarC) 
        BEGIN
            SET @coderror = 5; 
            SET @msgerror = 'Al menos uno de los tipos de datos inconsistentes ingresados NO EXISTE';
            GOTO ERROR
        END	
	
	-- Toma las inconsistencias reportadas por el usuario y las inserta en la tabla #ADM_INCONSISTENCIAS_PRESTADORES_X_APP
	SET @cadena = @cod_tipo_datopres;

	WHILE LEN(@cadena) > 0
	   BEGIN
		  IF PATINDEX('%' + @separator + '%',@cadena) > 0
		  BEGIN
			 SET @individual = SUBSTRING(@cadena, 0, PATINDEX('%' + @separator + '%',@cadena))
			 INSERT INTO #ADM_INCONSISTENCIAS_PRESTADORES_X_APP values(@individual)
			 SET @cadena = SUBSTRING(@cadena, LEN(@individual + @separator) + 1, LEN(@cadena))
		  END
		  ELSE
		  BEGIN
			 SET @individual = @cadena
			 INSERT INTO #ADM_INCONSISTENCIAS_PRESTADORES_X_APP values(@individual)
			 SET @cadena = NULL
		  END
	   END;
	
    BEGIN TRANSACTION 	
        INSERT INTO saludmp.ADM_INCONSISTENCIAS_PRESTADORES_X_APP (fecha_registro, cod_tipo_datopres, cod_prestador,cod_ciudad_prestador, tipo_id_usuario, id_usuario, app, ruta, observacion )
        VALUES ( GETDATE(), @cod_tipo_datopres, @cod_prestador, @cod_ciudad_prestador, @tipo_id_usuario, @id_usuario, @app, @ruta,  @observacion )

		SET @cod_inconsis_prestapp = scope_identity()

		OPEN curso_tipo_inconsistencias_reportadas
			FETCH NEXT FROM curso_tipo_inconsistencias_reportadas INTO @cod_inconsistencia
				WHILE @@FETCH_STATUS=0
					BEGIN
						INSERT INTO saludmp.ADM_GESTION_INCONSISTENCIAS_PRESTADORES (cod_inconsis_prestapp,cod_tipo_datopres)
						VALUES (@cod_inconsis_prestapp, @cod_inconsistencia)
						FETCH NEXT FROM curso_tipo_inconsistencias_reportadas INTO @cod_inconsistencia
					END
		CLOSE curso_tipo_inconsistencias_reportadas

		DEALLOCATE curso_tipo_inconsistencias_reportadas

	IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION;
			SET @coderror = 5; 
            SET @msgerror = 'Ocurrió un error, se ha realizado un rollback.';
            GOTO ERROR
		END
		ELSE
		BEGIN
			COMMIT TRANSACTION;
			 SET @coderror = 0;
			 SET @msgerror = 'Se Registro Exitosamente';	
		END
	
   			
	
	SELECT cod_inconsis_prestapp
    FROM saludmp.ADM_INCONSISTENCIAS_PRESTADORES_X_APP
    WHERE cod_inconsis_prestapp = @cod_inconsis_prestapp   

	DROP TABLE #ADM_INCONSISTENCIAS_PRESTADORES_X_APP;

 RETURN  
 ERROR:
 SET @cod_inconsis_prestapp = NULL
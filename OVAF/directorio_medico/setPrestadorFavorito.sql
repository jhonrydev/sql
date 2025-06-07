SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
  Nombre del Stored Procedure: marcarPrestadorFavorito
  Autor: Jhon Medina
  Fecha de creación: diciembre 2024
  Objetivo: Permite marcar y desmarcar un prestador como favorito
*/
ALTER PROCEDURE [saludmp].[setPrestadorFavorito]
    @coderror INTEGER  = 0 OUTPUT,
    @msgerror VARCHAR(500)  = '' OUTPUT,
    @tipo_documento VARCHAR(3),
    @numero_identificacion VARCHAR(30),
    @codigo_plan VARCHAR(20),
    @nombre_plan VARCHAR(200),
    @codigo_prestador VARCHAR(10),
    @prestador VARCHAR(150),
    @direccion_prestador VARCHAR(50),
    @codigo_ciudad VARCHAR(10),
    @cartilla VARCHAR(5),
    @marcacion VARCHAR(1)
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @prestador_favorito VARCHAR(10);

    BEGIN TRY

        IF (@tipo_documento = '' OR @tipo_documento IS NULL) 
            BEGIN 
                SET @coderror = 5;
                SET @msgerror = 'Debe ingresar el valor de tipo_documento es obligatorio.';
                GOTO ERROR;
            END;

        IF (@numero_identificacion = '' OR @numero_identificacion IS NULL) 
            BEGIN 
                SET @coderror = 5;
                SET @msgerror = 'Debe ingresar el valor de numero_identificacion es obligatorio.';
                GOTO ERROR;
            END;

        IF (@codigo_plan = '' OR @codigo_plan IS NULL) 
            BEGIN 
                SET @coderror = 5;
                SET @msgerror = 'Debe ingresar el valor de codigo_plan es obligatorio.';
                GOTO ERROR;
            END;

        IF (@nombre_plan = '' OR @nombre_plan IS NULL) 
            BEGIN 
                SET @coderror = 5;
                SET @msgerror = 'Debe ingresar el valor de nombre_plan es obligatorio.';
                GOTO ERROR;
            END;

        IF (@codigo_prestador = '' OR @codigo_prestador IS NULL) 
            BEGIN 
                SET @coderror = 5;
                SET @msgerror = 'Debe ingresar el valor de codigo_prestador es obligatorio.';
                GOTO ERROR;
            END;

        IF (@prestador = '' OR @prestador IS NULL) 
            BEGIN 
                SET @coderror = 5;
                SET @msgerror = 'Debe ingresar el valor de prestador es obligatorio.';
                GOTO ERROR;
            END;

        IF (@direccion_prestador = '' OR @direccion_prestador IS NULL) 
            BEGIN 
                SET @coderror = 5;
                SET @msgerror = 'Debe ingresar el valor de direccion_prestador es obligatorio.';
                GOTO ERROR;
            END;

        IF (@codigo_ciudad = '' OR @codigo_ciudad IS NULL) 
            BEGIN 
                SET @coderror = 5;
                SET @msgerror = 'Debe ingresar el valor de codigo_ciudad es obligatorio.';
                GOTO ERROR;
            END;

        IF (@cartilla = '' OR @cartilla IS NULL) 
            BEGIN 
                SET @coderror = 5;
                SET @msgerror = 'Debe ingresar el valor de cartilla es obligatorio.';
                GOTO ERROR;
            END;

        IF (@marcacion = '' OR @marcacion IS NULL) 
            BEGIN 
                SET @coderror = 5;
                SET @msgerror = 'Debe ingresar el valor de marcacion es obligatorio.';
                GOTO ERROR;
            END;

        SELECT @prestador_favorito = codigo_prestador 
        FROM saludmp.PRESTADOR_FAVORITO
        WHERE numero_identificacion = LTRIM(RTRIM(@numero_identificacion))
          AND tipo_documento = LTRIM(RTRIM(@tipo_documento))
          AND codigo_plan = LTRIM(RTRIM(@codigo_plan))
          AND codigo_prestador = LTRIM(RTRIM(@codigo_prestador))
          AND direccion_prestador = LTRIM(RTRIM(@direccion_prestador))
          AND codigo_ciudad = LTRIM(RTRIM(@codigo_ciudad))
          AND cartilla = LTRIM(RTRIM(@cartilla));
        
        IF (@prestador_favorito IS NULL)
            BEGIN
                BEGIN TRANSACTION
                    INSERT INTO saludmp.PRESTADOR_FAVORITO VALUES
                    (
                        LTRIM(RTRIM(@tipo_documento)),
                        LTRIM(RTRIM(@numero_identificacion)),
                        LTRIM(RTRIM(@codigo_plan)),
                        LTRIM(RTRIM(@nombre_plan)),
                        LTRIM(RTRIM(@codigo_prestador)),
                        LTRIM(RTRIM(@prestador)),
                        LTRIM(RTRIM(@direccion_prestador)),
                        LTRIM(RTRIM(@codigo_ciudad)),
                        LTRIM(RTRIM(@cartilla)),
                        LTRIM(RTRIM(@marcacion)),
                        GETDATE(),
                        NULL
                    );
                COMMIT TRANSACTION;
                SET @coderror = 0;
                SET @msgerror = 'Consulta Exitosa';
            END
        ELSE
            BEGIN
                BEGIN TRANSACTION
                    UPDATE saludmp.PRESTADOR_FAVORITO 
                    SET marcacion = @marcacion, fecha_actualizacion = GETDATE()
                    WHERE codigo_prestador = @codigo_prestador 
                    AND numero_identificacion = @numero_identificacion;
                COMMIT TRANSACTION;
                SET @coderror = 0;
                SET @msgerror = 'Consulta Exitosa';
            END

        SELECT 
            codigo_prestador,
            prestador,
            codigo_plan,
            nombre_plan,
            direccion_prestador,
            codigo_ciudad,
            cartilla,
            marcacion,
            CONVERT(VARCHAR, fecha_actualizacion, 120) AS fecha_actualizacion
        FROM saludmp.PRESTADOR_FAVORITO
        WHERE numero_identificacion = LTRIM(RTRIM(@numero_identificacion))
        AND tipo_documento = LTRIM(RTRIM(@tipo_documento))
        AND codigo_plan = LTRIM(RTRIM(@codigo_plan))
        AND codigo_prestador = LTRIM(RTRIM(@codigo_prestador))
        AND direccion_prestador = LTRIM(RTRIM(@direccion_prestador))
        AND codigo_ciudad = LTRIM(RTRIM(@codigo_ciudad))
        AND cartilla = LTRIM(RTRIM(@cartilla));

    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
        SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY();
        ROLLBACK TRANSACTION;
        SET @coderror = @ErrSeverity;
        SET @msgerror = @ErrMsg;
    END CATCH

    ERROR:
        SELECT @coderror AS codigo_error, @msgerror AS msg_error
        RETURN
END;
GO

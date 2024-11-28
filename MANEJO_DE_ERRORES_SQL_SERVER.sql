/*
Manejo de Errores en Procedimientos Almacenados de SQL Server

1.  Uso de TRY...CATCH:
    El bloque TRY...CATCH permite capturar y manejar errores en los procedimientos almacenados. 
    Aquí tienes un ejemplo de cómo se utiliza:
*/


BEGIN TRY
    -- Código que puede generar un error
    -- Por ejemplo, una consulta que podría lanzar una excepción
END TRY
BEGIN CATCH
    -- Código para manejar el error
    -- Por ejemplo, registro de errores o envío de notificaciones
END CATCH

/*
2.  Funciones Importantes:
    ERROR_NUMBER(): Retorna el número del error que ocurrió.
    ERROR_MESSAGE(): Retorna el mensaje de error.
    ERROR_STATE(): Retorna el estado del error.
    ERROR_SEVERITY(): Retorna la gravedad del error.
    ERROR_LINE(): Retorna el número de línea donde ocurrió el error.
    ERROR_PROCEDURE(): Retorna el nombre del procedimiento almacenado donde ocurrió el error.
*/

BEGIN TRY
    -- Código que puede generar un error
    SELECT 1/0; -- División por cero para simular un error
END TRY
BEGIN CATCH
    -- Captura del error
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR);
    PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Error Procedure: ' + ERROR_PROCEDURE();
END CATCH

/*
4.  Mensajes de Error Personalizados:
    Puedes lanzar tus propios errores personalizados utilizando THROW dentro del bloque CATCH:
*/

BEGIN TRY
    -- Código que puede generar un error
    SELECT 1/0; -- División por cero para simular un error
END TRY
BEGIN CATCH
    -- Captura del error
    DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
    SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY();
    RAISEERROR(@ErrMsg, @ErrSeverity, 1);
END CATCH

-- Ejemplo 2

BEGIN TRY
    -- Código que puede generar un error
    SELECT 1/0; -- División por cero para simular un error
END TRY
BEGIN CATCH
    -- Captura del error y lanzamiento de un error personalizado
    DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
    SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY();
    THROW 50001, @ErrMsg, @ErrSeverity;
END CATCH

/*
5.  Manejo de Transacciones:
    Si estás utilizando transacciones en tu procedimiento almacenado, es importante manejar adecuadamente las transacciones en caso de un error. 
    Puedes usar BEGIN TRANSACTION, COMMIT y ROLLBACK para controlar el flujo de la transacción y garantizar la integridad de los datos.
*/


BEGIN TRY
    BEGIN TRANSACTION; -- Iniciar transacción

    -- Código que realiza operaciones en la base de datos

    -- Si todo está bien, confirmar la transacción
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    -- Si ocurre un error, revertir la transacción
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    -- Capturar y manejar el error
    DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
    SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY();
    THROW 50002, @ErrMsg, @ErrSeverity;
END CATCH




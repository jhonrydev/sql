SET SERVEROUTPUT ON;

/*
FUNDAMENTO DE ORACLE PL/SQL

BLOQUES PL/SQL: Son el �rea en donde se c�fica toda la informaci�n de un programa PL/SQL y consta de 4 partes:
                1. DECLERE: En esta sesi�n se declaran las normalmente variable, constantes y otras sentencias para ser usadas dentro del bloque.
                2. BEGIN: En esta sesi�n se declaran todas las sentencias que se van a ejecutar cuando se ejecute el bloque.
                3. EXCEPTION: En esta sesi�n se manejan todas las excepci�n que pueda arrojar el bloque podiendo atraparlas y gestionarlas
                4. END: Esta sesi�n indica la final de un bloque PL/SQL.       
                
NOTA: Es importante aclarar que un bloque PL/SQL. son obligatoria la sesi�n BEGIN y END las otras son opcionales
                
TIPOS DE BLOQUES: Existen varios tipos de bloques:
                1. BLOQUES ANONIMOS: Se construyen de forma dinamica y se ejecutan una sola vez, no tiene nombre.
                2. BLOQUES CON NOMBRES: Estos tienen un nombre y generalmente se contruyen de forma dinamica y se ejecutan una solo vez
                3. DISPORADORES O TRIGGERS: Son bloques con nombre que se almacenan en la DB, no suele cambiar despues de su creaci�n y se
                                            ejecutran varias veces.
                
*/

--DECLARE

BEGIN

SELECT * FROM ADM_PROGRAMA;
--EXCEPTION

END;



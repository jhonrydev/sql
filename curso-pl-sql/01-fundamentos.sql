SET SERVEROUTPUT ON;

/*
FUNDAMENTO DE ORACLE PL/SQL

BLOQUES PL/SQL: Son el área en donde se cófica toda la información de un programa PL/SQL y consta de 4 partes:
                1. DECLERE: En esta sesión se declaran las normalmente variable, constantes y otras sentencias para ser usadas dentro del bloque.
                2. BEGIN: En esta sesión se declaran todas las sentencias que se van a ejecutar cuando se ejecute el bloque.
                3. EXCEPTION: En esta sesión se manejan todas las excepción que pueda arrojar el bloque podiendo atraparlas y gestionarlas
                4. END: Esta sesión indica la final de un bloque PL/SQL.       
                
NOTA: Es importante aclarar que un bloque PL/SQL. son obligatoria la sesión BEGIN y END las otras son opcionales
                
TIPOS DE BLOQUES: Existen varios tipos de bloques:
                1. BLOQUES ANONIMOS: Se construyen de forma dinamica y se ejecutan una sola vez, no tiene nombre.
                2. BLOQUES CON NOMBRES: Estos tienen un nombre y generalmente se contruyen de forma dinamica y se ejecutan una solo vez
                3. DISPORADORES O TRIGGERS: Son bloques con nombre que se almacenan en la DB, no suele cambiar despues de su creación y se
                                            ejecutran varias veces.
                
*/

--DECLARE

BEGIN

SELECT * FROM ADM_PROGRAMA;
--EXCEPTION

END;



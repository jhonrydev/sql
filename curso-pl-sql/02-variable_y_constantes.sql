SET SERVEROUTPUT ON;

/*
VARIABLE: Son contenedores de información que tienen un tipo de dato definido que siempre hay que espeficar; los datos que almacenas pueden variar
        Ej: v_myVar varcha(25)´:= 'hola mundo';
        indica que esta variable es de tipo varchar con una longitud de 25 y tiene el valor de (hola mundo)
        

CONSTANTES: Son contenedores de información que tienen un tipo de dato definido que siempre hay que espeficar; los datos que almacenas nunca varian


*/
DECLARE
v_nombre VARCHAR(25) := 'jhon';
v_edad INTEGER := 34;
v_avatar CHAR(10) := 'jhonry';
v_estatura DECIMAL := 1.70;
v_hora DATE := (sysdate);
v_nacimiento DATE := to_date('2023-03-31','yyyy-mm-dd');
--v_saludo VARCHAR2(50) default 'hola mundo';

BEGIN


END;

select * from adm_programa;
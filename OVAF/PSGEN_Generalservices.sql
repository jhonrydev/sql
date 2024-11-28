create or replace PACKAGE           PSGEN_Generalservices AS
/* ---------------------------------------------------------------------
 CopyRight Coomeva EPS S.A. - Colombia
 Package    : PSGEN_Generalservices
 Caso de Uso     : Servicios Generales
 Descripci¿   : Contiene los metodos que prestan servicios
       generales a los paquetes del nivel de solucion
       de negocios.
 --------------------------------------------------------------------
 Autor : patricia_velez@coomeva.com.co
 Fecha : 23/10/17 
 --------------------------------------------------------------------
 Procedimiento :     Descripcion:
 --------------------------------------------------------------------
 Historia de Modificaciones
 ---------------------------------------------------------------------
 Fecha Autor Modificaci¿----------------------------------------------------------------- */

   TYPE type_cadena IS TABLE OF VARCHAR2(1000)
      INDEX BY BINARY_INTEGER;
 -- ---------------------------------------------------
 -- Declaracion Metodos privados 
 -- ---------------------------------------------------
 FUNCTION fn_ExistString
   (
   pvc_valor        IN    VARCHAR,
   pvc_cadena       IN    VARCHAR
   )
 RETURN NUMBER;

 FUNCTION fn_CadenatoArray
  (
  pvc_cadena       VARCHAR2 ,
  pch_separador CHAR DEFAULT ','
  )
 RETURN type_cadena;
	
 END PSGEN_Generalservices;
 /
 create or replace PACKAGE BODY           PSGEN_Generalservices AS

-- ------------------------
 -- fn_ExistCodeParameterString
 -- ------------------------
 FUNCTION fn_ExistString
   (
   pvc_valor        IN    VARCHAR,
   pvc_cadena       IN    VARCHAR
   )
 RETURN NUMBER
 IS
/* -------------------------------------------------------------------
 Copyright ¿Tecnolog¿Inform¿ca Coomeva - Colombia
 Procedimiento: fn_ExistString
 Descripci¿: Indica si un codigo(numero) existe en una cadena de codigos separados por comas 
 -------------------------------------------------------------------
 Par¿tros :    Descripci¿ pnu_codigo      Codigo a validar  
 pvc_cadena      Cadena de codigos separados por comas   
 -------------------------------------------------------------------
 Autor : 
 Fecha : 23/10/17 
 --------------------------------------------------------------------
 Historia de Modificaciones
 -------------------------------------------------------------------
 Fecha Autor Modificaci¿-----------------------------------------------------------------*/
 
    lnu_exist  NUMBER;
 
 BEGIN
 	
	  
    BEGIN
    EXECUTE IMMEDIATE 'SELECT 1 FROM  DUAL WHERE '''||pvc_valor||''' IN('||pvc_cadena||')' INTO lnu_exist;  
	
    EXCEPTION WHEN NO_DATA_FOUND THEN 
			  lnu_exist := 0; 
	END;
	RETURN (lnu_exist);
    
 END fn_ExistString;
 
     FUNCTION fn_CadenatoArray
    (
    pvc_cadena       VARCHAR2 ,
    pch_separador CHAR DEFAULT ','
    )
    RETURN type_cadena IS
    
    TYPE type_posicion IS TABLE OF INTEGER
      INDEX BY BINARY_INTEGER;
  
      ltb_posiciones type_posicion;
       ltb_datos        type_cadena;
    
    li_posicion_vector PLS_INTEGER;
    li_pos_simbolo        PLS_INTEGER;
    li_pos_simbolo_tmp PLS_INTEGER;
    li_nro_palabras       PLS_INTEGER;
    li_pos_inicial       PLS_INTEGER;
    li_limite           PLS_INTEGER;
    x                   PLS_INTEGER := 0;
    i                   PLS_INTEGER := 0;
      BEGIN
           -- Obtiene las Posiciones del S¿olo Separador de Datos
        li_posicion_vector := 1;
        li_pos_simbolo     := 1;
        LOOP
            li_pos_simbolo_tmp := INSTR(pvc_cadena,pch_separador,li_pos_simbolo);

            IF(li_pos_simbolo_tmp IS NULL) THEN
                li_pos_simbolo_tmp := 0;
            END IF;      
            
            IF li_pos_simbolo_tmp > 0 THEN
               ltb_posiciones(li_posicion_vector) := li_pos_simbolo_tmp;
               li_pos_simbolo := li_pos_simbolo_tmp + 1;
               li_posicion_vector := li_posicion_vector + 1;
            END IF;
          EXIT WHEN li_pos_simbolo_tmp = 0;
        END LOOP;
        -- Almacena las Palabras en un Arreglo
        li_nro_palabras := ltb_posiciones.COUNT + 1;
        li_pos_simbolo := 1;
        li_pos_inicial := 1;
        li_limite := li_nro_palabras - 1;
        

        FOR i IN 1..li_limite LOOP
            ltb_datos(i) := SUBSTR(pvc_cadena,li_pos_inicial,ltb_posiciones(i) - li_pos_inicial);    
            li_pos_inicial := ltb_posiciones(i) + 1;
            x:=i;
        END LOOP;
        x := x + 1;
        ltb_datos(x) := SUBSTR(pvc_cadena,li_pos_inicial,(LENGTH(pvc_Cadena) - li_pos_inicial) + 1);

        RETURN ltb_datos;
    END fn_CadenatoArray;

END PSGEN_Generalservices;
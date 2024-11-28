create or replace PACKAGE BODY VDIR_PACK_TARIFAS AS

  FUNCTION VDIR_FN_GET_DATOS_PROMO_IMG RETURN sys_refcursor AS
  
    vl_cursor sys_refcursor;
    vl_parametro_url VARCHAR2(200);
  BEGIN    

    SELECT    
        valor_parametro INTO  vl_parametro_url       
    FROM
        vdir_parametro
    WHERE
     cod_parametro = 3
     AND cod_estado = 1;    

    OPEN vl_cursor
  FOR 

      SELECT 
        cod_file AS CODIGO_FILE,
        ruta AS RUTA_FILE,
        des_file
      FROM
        VDIR_FILE 

      WHERE
         COD_TIPO_FILE = 5;

    RETURN vl_cursor;  

  END VDIR_FN_GET_DATOS_PROMO_IMG;

  -------------------- PROCEDIMIENTO PARA GUARDAR LAS IMAGNES DE LAS PROMOCIONES
 PROCEDURE VDIR_SP_SAVE_PROMO_IMG(p_name IN VARCHAR2,p_name_encript IN VARCHAR2,p_ruta IN VARCHAR2,p_respuesta OUT VARCHAR2)
 AS

 BEGIN

  p_respuesta := 'Operación realizada correctamente.'; 

   INSERT INTO vdir_file (
    cod_file,
    des_file,   
    ruta,
    cod_tipo_file,    
    url

    ) VALUES (
       VDIR_SEQ_FILE.NEXTVAL,
       p_name,
       p_ruta,
       5,
       p_ruta
    );

    COMMIT;

  EXCEPTION 
    WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20000, 'error.');
     p_respuesta := 'Ocurrio un error en la base de datos.';
     ROLLBACK;


 END VDIR_SP_SAVE_PROMO_IMG;

  -------------------- PROCEDIMIENTO PARA ELIMINAR UNA IMAGEN
 PROCEDURE VDIR_SP_DELETE_PROMO_IMG(p_codigo_imagen IN NUMBER,p_respuesta OUT VARCHAR2) 
 AS

 BEGIN
   p_respuesta := 'OK';


   DELETE FROM 
      vdir_file
   WHERE
    cod_file = p_codigo_imagen;


    EXCEPTION 
    WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20000, 'error.');
     p_respuesta := 'Ocurrio un error en la base de datos.';
     ROLLBACK;

 END VDIR_SP_DELETE_PROMO_IMG; 


END VDIR_PACK_TARIFAS;
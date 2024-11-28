create or replace PACKAGE BODY         VDIR_PACK_ENCUESTAS AS

 FUNCTION VDIR_FN_GET_LIST_MONEDA RETURN VARCHAR2 AS
 vl_option VARCHAR2(2000);

 BEGIN

    vl_option := ' <option value="-1">Seleccione una moneda</option>'; 

     FOR fila IN (SELECT
                    cod_moneda,
                    des_moneda                    
                  FROM
                        vdir_moneda
                    WHERE
                        cod_estado = 1) LOOP

      vl_option := vl_option||' <option value='||fila.cod_moneda||'>'||fila.des_moneda||'</option>';                 

     END LOOP; 

     RETURN '<select disabled id="moneda" name="moneda" class="form-control lista-vd">'||vl_option||'</select>';


 END VDIR_FN_GET_LIST_MONEDA;

--FUNCION PARA TRAER UNA LISTA DE PARENTESCOS-----------------------------------------------
   FUNCTION VDIR_FN_GET_LIST_PARENTESCO RETURN VARCHAR2 AS 

   vl_option VARCHAR2(2000);

   BEGIN

       vl_option := ' <option value="-1">Seleccione un parentesco</option>'; 

     FOR fila IN (SELECT
                    cod_parentesco,
                    des_parentesco                    
                  FROM
                        vdir_parentesco
                    WHERE
                        cod_estado = 1) LOOP

      vl_option := vl_option||' <option value='||fila.cod_parentesco||'>'||fila.des_parentesco||'</option>';                 

     END LOOP; 

     RETURN '<select disabled id="parentesco" name="parentesco" class="form-control lista-vd">'||vl_option||'</select>';


   END VDIR_FN_GET_LIST_PARENTESCO;

-----------------------------------------------------------------------------

 FUNCTION VDIR_FN_GET_ENCUESTA_SARLAF(p_codigo_afiliacion IN VDIR_AFILIACION.COD_AFILIACION%TYPE ,p_codigo_persona IN VDIR_PERSONA.COD_PERSONA%TYPE) RETURN CLOB AS
   vl_cadena CLOB;

   vl_form_ini VARCHAR2(100);
   vl_form_fin VARCHAR2(40);   
   vl_row_respuesta CLOB; 
   vl_row_pregunta CLOB; 
   vl_style VARCHAR2(50);
   vl_filset_ini VARCHAR2(50);
   vl_filset_fin VARCHAR2(50);
   vl_legend VARCHAR2(50);
   vl_cod_modulo NUMBER;   
   vl_filset_all CLOB;
   vl_nombre_ant_modulo VARCHAR2(100);
   vl_value_check VARCHAR2(5);
   vl_existe_encuesta NUMBER;
   lnu_index NUMBER(12) := 0;
   lnu_index_resp NUMBER(12) := 0;   

  BEGIN

     SELECT 
        COUNT(EP.COD_ENCUESTA_PERSONA) INTO vl_existe_encuesta
      FROM 
        VDIR_ENCUESTA_PERSONA EP

        INNER JOIN VDIR_PERSONA P
         ON P.COD_PERSONA = EP.COD_PERSONA    

        INNER JOIN VDIR_PERSONA_TIPOPER TIPOP
         ON TIPOP.COD_PERSONA = P.COD_PERSONA,
         (SELECT MAX(COD_AFILIACION) AS COD_AFILIADO FROM VDIR_ENCUESTA_PERSONA MEP WHERE MEP.COD_PERSONA = p_codigo_persona) MAXEP

      WHERE
        EP.COD_AFILIACION = MAXEP.COD_AFILIADO
        AND EP.COD_PERSONA = p_codigo_persona
        AND TIPOP.COD_TIPO_PERSONA = 1
		AND EP.COD_ENCUESTA = 1;        

  IF vl_existe_encuesta = 0 THEN

      vl_form_ini := '<div class="container" id="form_div" name="form_div">';
      vl_form_fin := '</div>';
      vl_filset_ini := '<fieldset class="fieldset-vd">';
      vl_filset_fin := '</fieldset>';
      vl_filset_all := '';      
      vl_cod_modulo := 0;
      vl_nombre_ant_modulo := '';

       FOR fila IN (SELECT
                        preg.cod_pregunta,
                        preg.des_pregunta,
                        modu.des_modulo,
                        modu.cod_modulo
                    FROM
                        vdir_pregunta preg

                        INNER JOIN vdir_modulo_encuesta modu
                         ON modu.cod_modulo = preg.cod_modulo
                    WHERE
                       preg.cod_encuesta = 1 ORDER BY preg.cod_modulo, preg.numero_pregunta)  LOOP 
         vl_row_respuesta := '';
         vl_style := '';         
          FOR fila2 IN(SELECT
                            cod_respuesta,
                            des_respuesta,
                            puntuacion,
                            cod_pregunta

                        FROM
                            vdir_respuesta
                        WHERE
                           cod_pregunta = fila.cod_pregunta  ORDER BY numero_respuesta) 
        LOOP
                IF fila2.cod_respuesta NOT IN(25,26,27,30,31,32,33,36,37,38,41,42,43,46,47,48,49,50,51) THEN  
                    vl_value_check := '0';              
                    
                  IF(fila2.des_respuesta = 'SI') THEN
                    vl_value_check := '1';                 
                  END IF;
                  
                  IF fila2.cod_respuesta IN(19,20,21,22,23,24) THEN
                  
                        vl_row_respuesta := vl_row_respuesta || '                        
                                                               <div class="form-check div_container_respuesta" data-respuesta = "'||CAST(fila2.cod_respuesta AS VARCHAR2)||'">
                                                                    <label class="form-check-label">
                                                                      <input class="form-check-input" type="checkbox" value="'||CAST(fila2.cod_respuesta AS VARCHAR2)||'" name="radio_respuesta_n_'||CAST(fila2.cod_respuesta AS VARCHAR2)||'" id="radio_respuesta_n_'||CAST(fila2.cod_respuesta AS VARCHAR2)||'" > '||fila2.des_respuesta||'
                                                                      <span class="form-check-sign">
                                                                        <span class="check"></span>
                                                                      </span>
                                                                    </label>
                                                                </div>
                                                            ';                  
                  
                  ELSE
                        
                    IF fila2.cod_pregunta IN(1,2,3) THEN
                        
                        null;
                        /*
                        vl_row_respuesta := vl_row_respuesta || '
                        <div class="form-check div_container_respuesta" data-respuesta = "'||CAST(fila2.cod_respuesta AS VARCHAR2)||'">                                                 
                            <label class="radio-inline form-check-label">
                              <input class="form-check-input"  type="radio" name="radio_respuesta_n_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" id="radio_respuesta_n_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" value="'||CAST(fila2.cod_respuesta AS VARCHAR2)||'"> '||fila2.des_respuesta||'
                               <span class="circle">
                                <span class="check"></span>
                              </span>
                            </label>
                        </div>';
                        */
                    ELSE
                        vl_row_respuesta := vl_row_respuesta || '
                                                                <div class="form-check div_container_respuesta" data-respuesta = "'||CAST(fila2.cod_respuesta AS VARCHAR2)||'">                                                 
                                                                    <label class="radio-inline form-check-label">
                                                                      <input class="form-check-input"  type="radio" name="radio_respuesta_n_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" id="radio_respuesta_n_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" value="'||CAST(fila2.cod_respuesta AS VARCHAR2)||'"> '||fila2.des_respuesta||'
                                                                       <span class="circle">
                                                                        <span class="check"></span>
                                                                      </span>
                                                                    </label>
                                                                </div>
                                                            ';
                    END IF;
                    
                 END IF;
                 
                 ELSIF fila2.cod_respuesta = 33 THEN
                      vl_row_respuesta := vl_row_respuesta || '<div class="col-lg-6 div_container_respuesta" data-respuesta = "'||CAST(fila2.cod_respuesta AS VARCHAR2)||'">' ||fila2.des_respuesta||VDIR_PACK_ENCUESTAS.VDIR_FN_GET_LIST_MONEDA||'</div>';                      
                 ELSIF fila2.cod_respuesta = 48 THEN
                     vl_row_respuesta := vl_row_respuesta || '<div class="col-lg-12 div_container_respuesta" data-respuesta = "'||CAST(fila2.cod_respuesta AS VARCHAR2)||'">' || fila2.des_respuesta||VDIR_PACK_ENCUESTAS.VDIR_FN_GET_LIST_PARENTESCO||'</div> <br>'; 
                 ELSIF fila2.cod_respuesta in(25,26) THEN
                    vl_row_respuesta := vl_row_respuesta || '<div class="col-lg-6 div_container_respuesta" data-respuesta = "'||CAST(fila2.cod_respuesta AS VARCHAR2)||'">' ||fila2.des_respuesta||'></div>';
                 ELSE   
                     IF lnu_index_resp = 0 THEN
					    vl_row_respuesta := vl_row_respuesta || '<div class="row">';
					END IF;				 
                   vl_row_respuesta := vl_row_respuesta || '<div class="col-lg-6 div_container_respuesta" data-respuesta = "'||CAST(fila2.cod_respuesta AS VARCHAR2)||'">' ||fila2.des_respuesta||'</div>';
                   lnu_index_resp := lnu_index_resp + 1;
				 END IF;
          END LOOP; 
		  IF lnu_index_resp <> 0 THEN
		     vl_row_respuesta := vl_row_respuesta || '</div>';
		  END IF;
		  lnu_index_resp := 0;

          IF vl_cod_modulo <> fila.cod_modulo AND vl_cod_modulo > 0 THEN
            -- vl_cod_modulo := fila.cod_modulo;           
             vl_filset_all := vl_filset_all || vl_filset_ini||'<legend class="legend-vd">'||vl_nombre_ant_modulo||'</legend>'||vl_row_pregunta||vl_filset_fin;
             vl_row_pregunta := '';
			 lnu_index := 0;
          END IF;

          vl_cod_modulo := fila.cod_modulo; 
          vl_nombre_ant_modulo := fila.des_modulo;

			IF lnu_index = 0 THEN

			    vl_row_pregunta := vl_row_pregunta || '<div class="row">'; 

            ELSIF MOD(lnu_index,3) = 0 THEN

			    vl_row_pregunta := vl_row_pregunta || '</div><div class="row">';  

			END IF;

          /*IF fila.cod_pregunta = 7  THEN          
                vl_style := 'style="display:none"';
          END IF;         


            vl_row_pregunta := vl_row_pregunta || '<div class="row">
                                                       <div '||vl_style||' class="col-lg-12 col-md-12 col-sm-12 div_container_pregunta" id="pregunta_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" data-pregunta = "'||CAST(fila.cod_pregunta AS VARCHAR2)||'">
                                                         <div class="title">
                                                                <h4 class="obligatorio">'||fila.des_pregunta||'</h4>
                                                         </div>                                                         
                                                           '||vl_row_respuesta||'
                                                        </div>
                                                    </div>'; */

           IF fila.cod_pregunta = 6 OR fila.cod_pregunta = 34 OR fila.cod_pregunta = 35 OR fila.cod_pregunta = 36 THEN

			    vl_row_pregunta := vl_row_pregunta || '<div class="col-lg-6 col-md-6 col-sm-12 div_container_pregunta" id="pregunta_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" data-pregunta = "'||CAST(fila.cod_pregunta AS VARCHAR2)||'">';

			ELSIF (fila.cod_pregunta = 38 OR fila.cod_pregunta = 37) THEN

			    vl_row_pregunta := vl_row_pregunta || '<div class="col-lg-12 col-md-12 col-sm-12 div_container_pregunta" id="pregunta_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" data-pregunta = "'||CAST(fila.cod_pregunta AS VARCHAR2)||'">';
			ELSE 

			    vl_row_pregunta := vl_row_pregunta || '<div class="col-lg-4 col-md-4 col-sm-12 div_container_pregunta" id="pregunta_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" data-pregunta = "'||CAST(fila.cod_pregunta AS VARCHAR2)||'">';
			END IF;
            vl_row_pregunta := vl_row_pregunta || '<div class="" style="min-height: 36px;">
														<p class="obligatorio text-muted text-justify"><strong>'||fila.des_pregunta||'</strong></p>
													 </div>                                                         
													   '||vl_row_respuesta||'
													</div>';          

            lnu_index := lnu_index + 1;

      END LOOP;
    IF vl_row_pregunta IS NOT NULL AND vl_row_pregunta <> ' ' THEN
        vl_filset_all := vl_filset_all || vl_filset_ini||'<legend class="legend-vd">'||vl_nombre_ant_modulo||'</legend>'||vl_row_pregunta||vl_filset_fin;
        lnu_index := 0;
	END IF;

     vl_cadena :=  vl_form_ini||vl_filset_all||vl_form_fin;
  ELSE 
     vl_cadena := VDIR_FN_GET_DATOS_ENCT(p_codigo_afiliacion,p_codigo_persona);
  END IF;

    RETURN vl_cadena;
  END VDIR_FN_GET_ENCUESTA_SARLAF;


/*
    Author: Intelecto
    Desc: Se actualiza el procedimiento para guardar información sin sobreescribir respuestas múltiples
*/
  ---------------------------------------------------------GUARDAR ENCUESTA

  --PROCEDIMIENTO PARA GUARDAR LA ENCUESTA
    PROCEDURE VDIR_FN_GUARDAR_ENCUESTA(p_codigo_encuesta IN VDIR_ENCUESTA.COD_ENCUESTA%TYPE,p_codigo_pregunta IN VDIR_PREGUNTA.COD_PREGUNTA%TYPE,p_codigo_respuesta IN VDIR_RESPUESTA.COD_RESPUESTA%TYPE,p_cod_afiliacion IN VDIR_AFILIACION.COD_AFILIACION%TYPE,p_valor_respuesta IN VDIR_RESPUESTAS_MARCADAS.VALOR_RESPUESTA%TYPE,p_codigo_persona IN VDIR_PERSONA.COD_PERSONA%TYPE,p_respuesta OUT VARCHAR2)

   AS
   vl_cod_encuesta_afiliacion vdir_encuesta_persona.cod_encuesta_persona%TYPE;

   BEGIN 

   p_respuesta := 'Operación realizada correctamente.';

   BEGIN 
    SELECT
        cod_encuesta_persona INTO  vl_cod_encuesta_afiliacion      
    FROM
        vdir_encuesta_persona
    WHERE 
       cod_encuesta = p_codigo_encuesta
       AND cod_afiliacion = p_cod_afiliacion
       AND cod_persona = p_codigo_persona;
   EXCEPTION WHEN OTHERS THEN
      vl_cod_encuesta_afiliacion := NULL;
   END;

   IF vl_cod_encuesta_afiliacion IS NULL THEN

        SELECT VDIR_SEQ_AFILIACION_ENCUESTA.NEXTVAL INTO vl_cod_encuesta_afiliacion  FROM DUAL;

        INSERT INTO vdir_encuesta_persona (
            cod_encuesta_persona,
            cod_afiliacion,
            cod_encuesta,
            cod_persona
        ) VALUES (
            vl_cod_encuesta_afiliacion,
            p_cod_afiliacion,
            p_codigo_encuesta,
            p_codigo_persona
        );

    END IF;

   MERGE INTO vdir_respuestas_marcadas resmar
   USING (
           SELECT
            vl_cod_encuesta_afiliacion AS cod_encuesta_afiliacion,
            p_codigo_pregunta  AS codigo_pregunta,
            p_codigo_respuesta  AS codigo_respuesta
          FROM
             DUAL   
      ) resmar2
   ON (resmar.cod_encuesta_persona = resmar2.cod_encuesta_afiliacion AND resmar.cod_pregunta = resmar2.codigo_pregunta AND resmar.cod_respuesta = resmar2.codigo_respuesta)   
   WHEN MATCHED THEN
   --UPDATE SET cod_respuesta = p_codigo_respuesta, valor_respuesta = p_valor_respuesta
   UPDATE SET valor_respuesta = p_valor_respuesta
    WHEN NOT MATCHED THEN 
    
    INSERT (
        cod_respuestas_marcadas,
        cod_encuesta_persona,
        cod_pregunta,
        cod_respuesta,
        valor_respuesta
    ) VALUES (
        VDIR_SEQ_RESPUESTAS_MARCADAS.NEXTVAL,
        vl_cod_encuesta_afiliacion,
        p_codigo_pregunta,
        p_codigo_respuesta,
        p_valor_respuesta
    );
   

    --COMMIT --El comit se hace en el php;

  EXCEPTION 
    WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'error al guardar la encuesta.');
    p_respuesta := '-1';
  ROLLBACK;


   END VDIR_FN_GUARDAR_ENCUESTA;

   --FUNCION PARA TRAER LA ENCUESTA SARLAF YA DILIGENCIADA-------------------------------
   FUNCTION VDIR_FN_GET_DATOS_ENCT(p_codigo_afiliacion IN VDIR_AFILIACION.COD_AFILIACION%TYPE,p_codigo_persona IN VDIR_PERSONA.COD_PERSONA%TYPE) RETURN CLOB

   AS
    vl_cadena CLOB;

    vl_form_ini VARCHAR2(100);
    vl_form_fin VARCHAR2(40);   
    vl_row_respuesta CLOB; 
    vl_row_pregunta CLOB; 
    vl_style VARCHAR2(50);
    vl_filset_ini VARCHAR2(50);
    vl_filset_fin VARCHAR2(50);
    vl_legend VARCHAR2(50);
    vl_cod_modulo NUMBER;    
    vl_filset_all CLOB;
    vl_nombre_ant_modulo VARCHAR2(100);
    vl_checked VARCHAR2(100);
    vl_value_check VARCHAR2(5);
	lnu_index NUMBER(12) := 0;
	lnu_index_resp NUMBER(12) := 0;
    vl_hide_pregunta VARCHAR2(20);

   BEGIN

      vl_form_ini := '<div class="container" id="form_div" name="form_div">';
      vl_form_fin := '</div>';
      vl_filset_ini := '<fieldset class="fieldset-vd">';
      vl_filset_fin := '</fieldset>';
      vl_filset_all := '';      
      vl_cod_modulo := 0;
      vl_nombre_ant_modulo := '';
      vl_checked := '';
      vl_hide_pregunta := '';

       FOR fila IN (SELECT                       
                        preg.cod_pregunta,
                        preg.des_pregunta,
                        modu.des_modulo,
                        modu.cod_modulo
                    FROM
                        vdir_pregunta preg                        

                        INNER JOIN vdir_modulo_encuesta modu
                         ON modu.cod_modulo = preg.cod_modulo                        

                    WHERE
                       preg.cod_encuesta = 1 ORDER BY preg.cod_modulo, preg.numero_pregunta)  LOOP 
         vl_row_respuesta := '';                
          FOR fila2 IN(SELECT
                            re.cod_pregunta,
                            re.cod_respuesta,
                            re.des_respuesta,
                            re.puntuacion,
                            (SELECT  
                              (CASE WHEN rm.cod_respuesta IS NOT NULL THEN 'checked' ELSE ' ' END)                          
                               FROM
                                 vdir_respuestas_marcadas rm 

                                 INNER JOIN vdir_encuesta_persona afe
                                  ON afe.COD_ENCUESTA_PERSONA = rm.COD_ENCUESTA_PERSONA

                                 INNER JOIN  vdir_persona_tipoper per
                                  ON per.cod_persona = afe.cod_persona,
         (SELECT MAX(COD_AFILIACION) AS COD_AFILIADO FROM VDIR_ENCUESTA_PERSONA MEP WHERE MEP.COD_PERSONA = p_codigo_persona) MAXEP

                                 WHERE
                                   rm.cod_respuesta = re.cod_respuesta
                                   AND afe.COD_AFILIACION = MAXEP.COD_AFILIADO
                                   AND rm.cod_pregunta = fila.cod_pregunta
                                   AND afe.cod_persona = p_codigo_persona
                                   AND per.cod_tipo_persona = 1) AS checked,
                            (SELECT  
                               rm.valor_respuesta                      
                               FROM
                                 vdir_respuestas_marcadas rm 

                                 INNER JOIN vdir_encuesta_persona afe
                                  ON afe.COD_ENCUESTA_PERSONA = rm.COD_ENCUESTA_PERSONA

                                 INNER JOIN  vdir_persona_tipoper per
                                  ON per.cod_persona = afe.cod_persona ,
         (SELECT MAX(COD_AFILIACION) AS COD_AFILIADO FROM VDIR_ENCUESTA_PERSONA MEP WHERE MEP.COD_PERSONA = p_codigo_persona) MAXEP

                                 WHERE
                                   rm.cod_respuesta = re.cod_respuesta
                                   AND afe.COD_AFILIACION = MAXEP.COD_AFILIADO
                                   AND rm.cod_pregunta = fila.cod_pregunta
                                   AND afe.cod_persona = p_codigo_persona
                                   AND per.cod_tipo_persona = 1) AS val_respuesta       


                        FROM
                            vdir_respuesta re                             

                        WHERE
                           re.cod_pregunta = fila.cod_pregunta  ORDER BY re.numero_respuesta) 
        LOOP       
                 
             /*IF fila2.cod_respuesta = 18 AND fila2.val_respuesta = 'NO' THEN  
                vl_hide_pregunta := 'style=''display:none''';
             END IF;*/
                 
                IF fila2.cod_respuesta NOT IN(25,26,27,30,31,32,33,36,37,38,41,42,43,46,47,48,49,50,51) THEN 
                    vl_value_check := '0';
                  IF(fila2.des_respuesta = 'SI') THEN
                    vl_value_check := '1';                 
                  END IF;
                   
                   IF fila2.cod_respuesta IN(19,20,21,22,23,24) THEN
                  
                        vl_row_respuesta := vl_row_respuesta || '                        
                                                               <div class="form-check div_container_respuesta" data-respuesta = "'||CAST(fila2.cod_respuesta AS VARCHAR2)||'">
                                                                    <label class="form-check-label">
                                                                      <input disabled class="form-check-input" '||fila2.checked||' type="checkbox" value="'||CAST(fila2.cod_respuesta AS VARCHAR2)||'" name="radio_respuesta_n_'||CAST(fila2.cod_respuesta AS VARCHAR2)||'" id="radio_respuesta_n_'||CAST(fila2.cod_respuesta AS VARCHAR2)||'" > '||fila2.des_respuesta||'
                                                                      <span class="form-check-sign">
                                                                        <span class="check"></span>
                                                                      </span>
                                                                    </label>
                                                                </div>
                                                            ';                  
                  
                  ELSE
                        vl_row_respuesta := vl_row_respuesta || '
                                                                <div class="form-check form-check-inline div_container_respuesta" data-respuesta = "'||CAST(fila2.cod_respuesta AS VARCHAR2)||'">                                                 
                                                                    <label class="radio-inline form-check-label">
                                                                      <input data-aux-resp="'||fila2.des_respuesta||'" disabled class="form-check-input" '||fila2.checked||' type="radio" name="radio_respuesta_n_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" id="radio_respuesta_n_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" value="'||CAST(fila2.cod_respuesta AS VARCHAR2)||'"> '||fila2.des_respuesta||'
                                                                       <span class="circle">
                                                                        <span class="check"></span>
                                                                      </span>
                                                                    </label>
                                                                </div>
                                                            ';
                  END IF;   
                    
                   
            
                   /*vl_row_respuesta := vl_row_respuesta || '
                                                                <div class="form-check form-check-inline div_container_respuesta" data-respuesta = "'||CAST(fila2.cod_respuesta AS VARCHAR2)||'">                                                 
                                                                    <label class="radio-inline form-check-label">
                                                                      <input disabled class="form-check-input" '||fila2.checked||' type="radio" name="radio_respuesta_n_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" id="radio_respuesta_n_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" value="'||CAST(fila2.cod_respuesta AS VARCHAR2)||'"> '||fila2.des_respuesta||'
                                                                       <span class="circle">
                                                                        <span class="check"></span>
                                                                      </span>
                                                                    </label>
                                                                </div>
                                                            ';*/
                 ELSIF fila2.cod_respuesta = 33 THEN
                      vl_row_respuesta := vl_row_respuesta || '<div class="col-lg-6 div_container_respuesta" data-val_respuesta = "'||fila2.val_respuesta||'" data-respuesta = "'||CAST(fila2.cod_respuesta AS VARCHAR2)||'">' ||fila2.des_respuesta||VDIR_PACK_ENCUESTAS.VDIR_FN_GET_LIST_MONEDA||'</div>';                      
                 ELSIF fila2.cod_respuesta = 48 THEN
                     vl_row_respuesta := vl_row_respuesta || '<div class="col-lg-12 div_container_respuesta" data-val_respuesta = "'||fila2.val_respuesta||'" data-respuesta = "'||CAST(fila2.cod_respuesta AS VARCHAR2)||'">' || fila2.des_respuesta||VDIR_PACK_ENCUESTAS.VDIR_FN_GET_LIST_PARENTESCO||'</div> <br>'; 
                 ELSIF fila2.cod_respuesta = 49 OR fila2.cod_respuesta = 50 OR fila2.cod_respuesta = 27 THEN
                     vl_row_respuesta := vl_row_respuesta || '<div class="col-lg-12 div_container_respuesta" data-respuesta = "'||CAST(fila2.cod_respuesta AS VARCHAR2)||'" data-val_respuesta = "'||fila2.val_respuesta||'">' ||fila2.des_respuesta||'</div>';      
                 ELSIF fila2.cod_respuesta in(51,25,26) THEN
                    vl_row_respuesta := vl_row_respuesta || '<div class="col-lg-6 div_container_respuesta" data-respuesta = "'||CAST(fila2.cod_respuesta AS VARCHAR2)||'" data-val_respuesta = "'||fila2.val_respuesta||'">' ||fila2.des_respuesta||' value= "'||fila2.val_respuesta||'" disabled></div>';          
				  ELSE 
                    IF lnu_index_resp = 0 THEN
					    vl_row_respuesta := vl_row_respuesta || '<div class="row">';
					END IF;
                   vl_row_respuesta := vl_row_respuesta || '<div class="col-lg-6 div_container_respuesta" data-respuesta = "'||CAST(fila2.cod_respuesta AS VARCHAR2)||'" data-val_respuesta = "'||fila2.val_respuesta||'">' ||fila2.des_respuesta||'</div>';
                    lnu_index_resp := lnu_index_resp + 1;
				END IF;
          END LOOP;
		  IF lnu_index_resp <> 0 THEN
		     vl_row_respuesta := vl_row_respuesta || '</div>';
		  END IF;
		  lnu_index_resp := 0;

          IF vl_cod_modulo <> fila.cod_modulo AND vl_cod_modulo > 0 THEN                      
             vl_filset_all := vl_filset_all || vl_filset_ini||'<legend class="legend-vd">'||vl_nombre_ant_modulo||'</legend>'||vl_row_pregunta||vl_filset_fin;
             vl_row_pregunta := '';
			 lnu_index := 0;
          END IF;

          vl_cod_modulo := fila.cod_modulo; 
          vl_nombre_ant_modulo := fila.des_modulo;        

            IF lnu_index = 0 THEN

			    vl_row_pregunta := vl_row_pregunta || '<div class="row">'; 

            ELSIF MOD(lnu_index,3) = 0 THEN

			    vl_row_pregunta := vl_row_pregunta || '</div><div class="row">';  

			END IF;

			IF fila.cod_pregunta = 6 OR fila.cod_pregunta = 34 OR fila.cod_pregunta = 35 OR fila.cod_pregunta = 36 THEN

			    vl_row_pregunta := vl_row_pregunta || '<div  class="col-lg-6 col-md-6 col-sm-12 div_container_pregunta" id="pregunta_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" data-pregunta = "'||CAST(fila.cod_pregunta AS VARCHAR2)||'">';

			ELSIF (fila.cod_pregunta = 38 OR fila.cod_pregunta = 37) THEN

			    vl_row_pregunta := vl_row_pregunta || '<div class="col-lg-12 col-md-12 col-sm-12 div_container_pregunta" id="pregunta_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" data-pregunta = "'||CAST(fila.cod_pregunta AS VARCHAR2)||'">';
			
            --ELSIF (fila.cod_pregunta = 7) THEN
                --vl_row_pregunta := vl_row_pregunta || '<div '||vl_hide_pregunta||' class="col-lg-4 col-md-4 col-sm-12 div_container_pregunta" id="pregunta_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" data-pregunta = "'||CAST(fila.cod_pregunta AS VARCHAR2)||'">';                
            ELSE 
               vl_row_pregunta := vl_row_pregunta || '<div class="col-lg-4 col-md-4 col-sm-12 div_container_pregunta" id="pregunta_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" data-pregunta = "'||CAST(fila.cod_pregunta AS VARCHAR2)||'">';
			END IF;
            vl_row_pregunta := vl_row_pregunta || '<div class="" style="min-height: 36px;">
														<p class="obligatorio text-muted text-justify"><strong>'||fila.des_pregunta||'</strong></p>
													 </div>                                                         
													   '||vl_row_respuesta||'
													</div>';          

            lnu_index := lnu_index + 1;
      END LOOP;
    IF vl_row_pregunta IS NOT NULL AND vl_row_pregunta <> ' ' THEN
        vl_filset_all := vl_filset_all || vl_filset_ini||'<legend class="legend-vd">'||vl_nombre_ant_modulo||'</legend>'||vl_row_pregunta||vl_filset_fin;
		lnu_index := 0;
    END IF;      

     vl_cadena :=  vl_form_ini||vl_filset_all||vl_form_fin;


    RETURN vl_cadena;


   END VDIR_FN_GET_DATOS_ENCT;

   -------------------------------FUNCION PARA  PINTAR LA ENCUESTA DE SALUD

 FUNCTION VDIR_FN_GET_ENCUESTA_DE_SALUD(p_edad IN NUMBER,p_sexo IN NUMBER,p_codigo_afiliacion IN VDIR_AFILIACION.COD_AFILIACION%TYPE ,p_codigo_persona IN VDIR_PERSONA.COD_PERSONA%TYPE) RETURN CLOB AS
   vl_cadena CLOB;

   vl_form_ini VARCHAR2(100);
   vl_form_fin VARCHAR2(40);   
   vl_row_respuesta CLOB; 
   vl_row_pregunta CLOB; 
   vl_style VARCHAR2(50);
   vl_filset_ini VARCHAR2(50);
   vl_filset_fin VARCHAR2(50);
   vl_legend VARCHAR2(50);
   vl_cod_modulo NUMBER; 
   vl_TipoRespuesta NUMBER;
   vl_filset_all CLOB;
   vl_nombre_ant_modulo VARCHAR2(100);
   vl_value_check VARCHAR2(4);
   vl_existe_encuesta NUMBER;
   lnu_index NUMBER(12) := 0;

  BEGIN      

      SELECT 
        COUNT(EP.COD_ENCUESTA_PERSONA) INTO vl_existe_encuesta
      FROM 
        VDIR_ENCUESTA_PERSONA EP

        INNER JOIN VDIR_PERSONA P
         ON P.COD_PERSONA = EP.COD_PERSONA    

        INNER JOIN VDIR_PERSONA_TIPOPER TIPOP
         ON TIPOP.COD_PERSONA = P.COD_PERSONA

      WHERE
        EP.COD_AFILIACION = p_codigo_afiliacion
        AND EP.COD_PERSONA = p_codigo_persona
        AND TIPOP.COD_TIPO_PERSONA = 2
		AND EP.COD_ENCUESTA = 2;

  IF  vl_existe_encuesta = 0 THEN

      vl_form_ini := '<div class="container" id="form_div_salud" name="form_div_salud">';
      vl_form_fin := '</div>';
      vl_filset_ini := '<fieldset class="fieldset-vd">';
      vl_filset_fin := '</fieldset>';
      vl_filset_all := '';      
      vl_cod_modulo := 0;
      vl_nombre_ant_modulo := '';

       FOR fila IN (SELECT
                        preg.cod_pregunta,
                        preg.des_pregunta,
                        modu.des_modulo,
                        modu.cod_modulo
                    FROM
                        vdir_pregunta preg

                        INNER JOIN vdir_modulo_encuesta modu
                         ON modu.cod_modulo = preg.cod_modulo
                    WHERE
                       preg.cod_encuesta = 2 ORDER BY preg.cod_modulo, preg.numero_pregunta)  LOOP 
         vl_row_respuesta := '';
         vl_TipoRespuesta := 1;
         vl_style := '';         

         IF fila.cod_pregunta = 10 THEN
               vl_style := 'style="display:none"';
          END IF;

          IF fila.cod_pregunta IN(8,9) AND p_sexo = 1  THEN          
                vl_style := 'style="display:none"';              
          END IF;   

          IF fila.cod_pregunta IN(29,30) AND p_edad > 6  THEN          
                vl_style := 'style="display:none"';              
          END IF;  
          FOR fila2 IN(SELECT
                            cod_respuesta,
                            des_respuesta,
                            puntuacion

                        FROM
                            vdir_respuesta
                        WHERE
                           cod_pregunta = fila.cod_pregunta  ORDER BY numero_respuesta) 
        LOOP

                IF fila2.cod_respuesta IN(52,53,55,56,57,58,59,61,62,64,65,67,68,70,71,73,74,76,77,79,80,82,83,85,86,88,89,91,92,94,95,97,98,100,101,103,104,106,107,109,110,112,113,115,116,120,121,123,124,125,126,127,128,129,130) THEN
                  vl_value_check := '0';
                  IF(fila2.des_respuesta = 'SI') THEN
                    vl_value_check := '1';                 
                  END IF;
                   vl_row_respuesta := vl_row_respuesta || '
                                                                <div class="form-check form-check-inline div_container_respuesta" data-respuesta = "'||CAST(fila2.cod_respuesta AS VARCHAR2)||'">                                                 
                                                                    <label class="radio-inline form-check-label">
                                                                      <input class="form-check-input"  type="radio" name="radio_respuesta_n_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" id="radio_respuesta_n_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" data-value="'||vl_value_check||'" value="'||CAST(fila2.cod_respuesta AS VARCHAR2)||'"> '||fila2.des_respuesta||'
                                                                       <span class="circle">
                                                                        <span class="check"></span>
                                                                      </span>
                                                                    </label>
                                                                </div>
                                                            ';
                 ELSIF fila2.cod_respuesta IN(118,119) THEN
                    vl_TipoRespuesta :=2;
                   vl_row_respuesta := vl_row_respuesta || '<div class="div_container_respuesta" data-respuesta = "'||CAST(fila2.cod_respuesta AS VARCHAR2)||'"><input type="text" id="inp_'||CAST(fila2.cod_respuesta AS VARCHAR2)||'" name="inp_'||CAST(fila2.cod_respuesta AS VARCHAR2)||'" class="form-control campo-vd col-sm-9" maxlength="4"></div>';
                 ELSE               
                   vl_row_respuesta := vl_row_respuesta || '<div class="div_container_respuesta d-none"  data-respuesta = "'||CAST(fila2.cod_respuesta AS VARCHAR2)||'"><label>Especificar</label><input type="text" id="inp_'||CAST(fila2.cod_respuesta AS VARCHAR2)||'" name="inp_'||CAST(fila2.cod_respuesta AS VARCHAR2)||'" class="form-control campo-vd col-sm-9" maxlength="400"></div>';                
                 END IF;
          END LOOP; 

          IF vl_cod_modulo <> fila.cod_modulo AND vl_cod_modulo > 0 THEN
            -- vl_cod_modulo := fila.cod_modulo;           
             vl_filset_all := vl_filset_all || vl_filset_ini||'<legend class="legend-vd">'||vl_nombre_ant_modulo||'</legend>'||vl_row_pregunta||vl_filset_fin;
             vl_row_pregunta := '';
			 lnu_index := 0;
          END IF;

          vl_cod_modulo := fila.cod_modulo; 
          vl_nombre_ant_modulo := fila.des_modulo; 

            IF lnu_index = 0 THEN

			    vl_row_pregunta := vl_row_pregunta || '<div class="row" >'; 

            ELSIF MOD(lnu_index,2) = 0 THEN

			    vl_row_pregunta := vl_row_pregunta || '</div><div class="row" style="min-height: 120px;">';  

			END IF;
            
            vl_row_respuesta:='';
            
            FOR filaUsuario IN(SELECT 
                                p.cod_persona codpersona,
                                p.nombre_1 nombre1,
                                p.apellido_1 apellido1
                              FROM 
                                VDIR_PERSONA P,
                                VDIR_PERSONA_TIPOPER TIPOP,
                                VDIR_CONTRATANTE_BENEFICIARIO cb
                              WHERE
                                cb.COD_AFILIACION = p_codigo_afiliacion
                                and P.COD_PERSONA = cb.cod_beneficiario
                                and TIPOP.COD_PERSONA = P.COD_PERSONA
                                AND TIPOP.COD_TIPO_PERSONA = 2) 
        
        LOOP
        
            IF vl_TipoRespuesta = 1 THEN

			    vl_row_respuesta :=vl_row_respuesta||'
                                                                <div class="form-check form-check-inline div_container_respuesta" data-pregunta = "'||CAST(fila.cod_pregunta AS VARCHAR2)||'">                                                 
                                                                    <label class="radio-inline form-check-label">
                                                                      <input class="form-check-input"  type="radio" name="radio_respuesta_n_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" id="rdPregunta'||CAST(fila.cod_pregunta AS VARCHAR2)||'-'||CAST(filaUsuario.codpersona AS VARCHAR2)||'" data-value="0" value="'||CAST(filaUsuario.codpersona AS VARCHAR2)||'"> '||filaUsuario.nombre1||' '||filaUsuario.apellido1||'
                                                                       <span class="circle">
                                                                        <span class="check"></span>
                                                                      </span>
                                                                    </label>
                                                                </div>
                                                            ';
 
            ELSIF vl_TipoRespuesta = 2 THEN
                
                    vl_row_respuesta := vl_row_respuesta||'<div class="div_container_respuesta" data-pregunta = "'||CAST(fila.cod_pregunta AS VARCHAR2)||'">'||filaUsuario.nombre1||' '||filaUsuario.apellido1||' '||fila.des_pregunta||' <input type="text" id="txtRespuesta'||CAST(fila.cod_pregunta AS VARCHAR2)||'-'||CAST(filaUsuario.codpersona AS VARCHAR2)||'" name="inp_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" class="form-control campo-vd col-sm-9" maxlength="4"></div>';

			END IF;
            
            END LOOP;
            
            IF vl_TipoRespuesta = 1 THEN
            
            vl_row_pregunta := vl_row_pregunta || '<div '||vl_style||' class=" col-lg-6 col-md-6 col-sm-12 div_container_pregunta" id="pregunta_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" data-pregunta = "'||CAST(fila.cod_pregunta AS VARCHAR2)||'">
                                                        <div class="" >
                                                                <p class="obligatorio text-muted text-justify">'||fila.des_pregunta||'</p>
                                                         </div>   
                                                         <div id="divRespuesta'||CAST(fila.cod_pregunta AS VARCHAR2)||'"> </div>
                                                        '||vl_row_respuesta||'
                                                        </div>'; 
             ELSE
             
             vl_row_pregunta := vl_row_pregunta || '<div '||vl_style||' class=" col-lg-6 col-md-6 col-sm-12 div_container_pregunta" id="pregunta_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" data-pregunta = "'||CAST(fila.cod_pregunta AS VARCHAR2)||'"> 
                                                         <div id="divRespuesta'||CAST(fila.cod_pregunta AS VARCHAR2)||'"> </div>
                                                        '||vl_row_respuesta||'
                                                        </div>';
             
             END IF;
             --'||vl_row_respuesta||'
            
            lnu_index := lnu_index + 1;

      END LOOP;
    IF vl_row_pregunta IS NOT NULL AND vl_row_pregunta <> ' ' THEN
        vl_filset_all := vl_filset_all || vl_filset_ini||'<legend class="legend-vd">'||vl_nombre_ant_modulo||'</legend>'||vl_row_pregunta||vl_filset_fin;
		lnu_index := 0;
    END IF;

     --vl_cadena :=  vl_form_ini||vl_row_pregunta||vl_form_fin;
     vl_cadena :=  vl_form_ini||vl_filset_all||vl_form_fin;

   ELSE
    vl_cadena := VDIR_FN_GET_DATOS_ENCT_SALUD(p_edad,p_sexo,p_codigo_afiliacion,p_codigo_persona);
   END IF;

    RETURN vl_cadena;
  END VDIR_FN_GET_ENCUESTA_DE_SALUD;

  --FUNCION PARA TRAER LA ENCUESTA DE SALUD YA DILIGENCIADA-------------------------------
   FUNCTION VDIR_FN_GET_DATOS_ENCT_SALUD(p_edad IN NUMBER,p_sexo IN NUMBER,p_codigo_afiliacion IN VDIR_AFILIACION.COD_AFILIACION%TYPE,p_codigo_persona IN VDIR_PERSONA.COD_PERSONA%TYPE) RETURN CLOB

   AS
    vl_cadena CLOB;

    vl_form_ini VARCHAR2(100);
    vl_form_fin VARCHAR2(40);   
    vl_row_respuesta CLOB; 
    vl_row_pregunta CLOB; 
    vl_style VARCHAR2(50);
    vl_filset_ini VARCHAR2(50);
    vl_filset_fin VARCHAR2(50);
    vl_legend VARCHAR2(50);
    vl_cod_modulo NUMBER;    
    vl_filset_all CLOB;
    vl_nombre_ant_modulo VARCHAR2(100);
    vl_checked VARCHAR2(100);
    vl_value_check VARCHAR2(5);
	lnu_index NUMBER(12) := 0;
    vl_style_preg_10 VARCHAR2(50);

   BEGIN

      vl_form_ini := '<div class="container" id="form_div_salud" name="form_div_salud">';
      vl_form_fin := '</div>';
      vl_filset_ini := '<fieldset class="fieldset-vd">';
      vl_filset_fin := '</fieldset>';
      vl_filset_all := '';      
      vl_cod_modulo := 0;
      vl_nombre_ant_modulo := '';
      vl_checked := '';

       FOR fila IN (SELECT                       
                        preg.cod_pregunta,
                        preg.des_pregunta,
                        modu.des_modulo,
                        modu.cod_modulo
                    FROM
                        vdir_pregunta preg                        

                        INNER JOIN vdir_modulo_encuesta modu
                         ON modu.cod_modulo = preg.cod_modulo                        

                    WHERE
                       preg.cod_encuesta = 2 ORDER BY preg.cod_modulo, preg.numero_pregunta)  LOOP 
         vl_row_respuesta := ''; 
          vl_style := ''; 

          IF fila.cod_pregunta IN(8,9,10) AND p_sexo = 1  THEN          
                vl_style := 'style="display:none"';              
          END IF;   

          IF fila.cod_pregunta IN(29,30) AND p_edad > 6  THEN          
                vl_style := 'style="display:none"';              
          END IF;  

          FOR fila2 IN(SELECT

                            re.cod_respuesta,
                            re.des_respuesta,
                            re.puntuacion,
                            (SELECT  
                              (CASE WHEN rm.cod_respuesta IS NOT NULL THEN 'checked' ELSE ' ' END)                          
                               FROM
                                 vdir_respuestas_marcadas rm 

                                 INNER JOIN vdir_encuesta_persona afe
                                  ON afe.COD_ENCUESTA_PERSONA = rm.COD_ENCUESTA_PERSONA

                                 INNER JOIN  vdir_persona_tipoper per
                                  ON per.cod_persona = afe.cod_persona 

                                 WHERE
                                   rm.cod_respuesta = re.cod_respuesta
                                   AND afe.COD_AFILIACION = p_codigo_afiliacion
                                   AND rm.cod_pregunta = fila.cod_pregunta
                                   AND afe.cod_persona = p_codigo_persona
                                   AND per.cod_tipo_persona = 2) AS checked,
                            (SELECT  
                               rm.valor_respuesta                      
                               FROM
                                 vdir_respuestas_marcadas rm 

                                 INNER JOIN vdir_encuesta_persona afe
                                  ON afe.COD_ENCUESTA_PERSONA = rm.COD_ENCUESTA_PERSONA

                                 INNER JOIN  vdir_persona_tipoper per
                                  ON per.cod_persona = afe.cod_persona 

                                 WHERE
                                   rm.cod_respuesta = re.cod_respuesta
                                   AND afe.COD_AFILIACION = p_codigo_afiliacion
                                   AND rm.cod_pregunta = fila.cod_pregunta
                                   AND afe.cod_persona = p_codigo_persona
                                   AND per.cod_tipo_persona = 2) AS val_respuesta       


                        FROM
                            vdir_respuesta re                             

                        WHERE
                           re.cod_pregunta = fila.cod_pregunta  ORDER BY re.numero_respuesta) 
        LOOP       


                IF fila2.cod_respuesta IN(52,53,55,56,57,58,59,61,62,64,65,67,68,70,71,73,74,76,77,79,80,82,83,85,86,88,89,91,92,94,95,97,98,100,101,103,104,106,107,109,110,112,113,115,116,120,121,123,124,125,126,127,128,129,130) THEN
                    vl_value_check := '0';
                  IF(fila2.des_respuesta = 'SI') THEN
                    vl_value_check := '1';                 
                  END IF;

                  IF  fila.cod_pregunta = 9 AND fila2.cod_respuesta = 55 THEN
                      vl_style_preg_10 := 'SI';
                  END IF;

                   vl_row_respuesta := vl_row_respuesta || '
                                                                <div class="form-check form-check-inline div_container_respuesta" data-respuesta = "'||CAST(fila2.cod_respuesta AS VARCHAR2)||'">                                                 
                                                                    <label class="radio-inline form-check-label">                                                                     
                                                                      <input disabled class="form-check-input" '||fila2.checked||' type="radio" name="radio_respuesta_n_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" id="radio_respuesta_n_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" data-value="'||vl_value_check||'" value="'||CAST(fila2.cod_respuesta AS VARCHAR2)||'"> '||fila2.des_respuesta||' 
                                                                       <span class="circle">
                                                                        <span class="check"></span>
                                                                      </span>
                                                                    </label>
                                                                </div>
                                                            ';
                ELSIF fila2.cod_respuesta IN(118,119) THEN
                   vl_row_respuesta := vl_row_respuesta || '<div class="div_container_respuesta" data-respuesta = "'||CAST(fila2.cod_respuesta AS VARCHAR2)||'"><input type="text" id="inp_'||CAST(fila2.cod_respuesta AS VARCHAR2)||'" name="inp_'||CAST(fila2.cod_respuesta AS VARCHAR2)||'" value="'||fila2.val_respuesta||'" class="form-control campo-vd col-sm-9" maxlength="4"></div>';
                 ELSE               
                   vl_row_respuesta := vl_row_respuesta || '<div class="div_container_respuesta d-none"  data-respuesta = "'||CAST(fila2.cod_respuesta AS VARCHAR2)||'"><label>Especificar</label><input type="text" id="inp_'||CAST(fila2.cod_respuesta AS VARCHAR2)||'" name="inp_'||CAST(fila2.cod_respuesta AS VARCHAR2)||'" value="'||fila2.val_respuesta||'" class="form-control campo-vd col-sm-9" maxlength="400"></div>';                
                 END IF;
          END LOOP;  

          IF vl_cod_modulo <> fila.cod_modulo AND vl_cod_modulo > 0 THEN                      
             vl_filset_all := vl_filset_all || vl_filset_ini||'<legend class="legend-vd">'||vl_nombre_ant_modulo||'</legend>'||vl_row_pregunta||vl_filset_fin;
             vl_row_pregunta := '';
			 lnu_index := 0;
          END IF;

          vl_cod_modulo := fila.cod_modulo; 
          vl_nombre_ant_modulo := fila.des_modulo;        

            IF lnu_index = 0 THEN

			    vl_row_pregunta := vl_row_pregunta || '<div class="row">'; 

            ELSIF MOD(lnu_index,2) = 0 THEN

			    vl_row_pregunta := vl_row_pregunta || '</div><div class="row">';  

			END IF;

             IF fila.cod_pregunta = 10 AND vl_style_preg_10 = 'SI' AND p_sexo = 2 THEN
                  vl_style := 'style="display:inline"';
             END IF;
            vl_row_pregunta := vl_row_pregunta || '<div '||vl_style||' class="col-lg-6 col-md-6 col-sm-12 div_container_pregunta" id="pregunta_'||CAST(fila.cod_pregunta AS VARCHAR2)||'" data-pregunta = "'||CAST(fila.cod_pregunta AS VARCHAR2)||'">
                                                         <div class="" style="min-height: 60px;">
                                                                <p class="obligatorio text-muted text-justify">'||fila.des_pregunta||'</p>
                                                         </div>                                                         
                                                           '||vl_row_respuesta||'
                                                        </div>';          

            lnu_index := lnu_index + 1;
      END LOOP;
    IF vl_row_pregunta IS NOT NULL AND vl_row_pregunta <> ' ' THEN
        vl_filset_all := vl_filset_all || vl_filset_ini||'<legend class="legend-vd">'||vl_nombre_ant_modulo||'</legend>'||vl_row_pregunta||vl_filset_fin;
		lnu_index := 0;
    END IF;      

     vl_cadena :=  vl_form_ini||vl_filset_all||vl_form_fin;


    RETURN vl_cadena;


   END VDIR_FN_GET_DATOS_ENCT_SALUD;

	-- ---------------------------------------------------------------------
    -- fnGetValidaEncuesta
    -- ---------------------------------------------------------------------
    FUNCTION fnGetValidaEncuesta
    (
        inu_codAfiliacion IN VDIR_ENCUESTA_PERSONA.COD_AFILIACION%TYPE,
		inu_codPersona    IN VDIR_ENCUESTA_PERSONA.COD_PERSONA%TYPE,
		inu_codEncuesta   IN VDIR_ENCUESTA_PERSONA.COD_ENCUESTA%TYPE
    )
	RETURN NUMBER IS

	/* ---------------------------------------------------------------------
	 Copyright   : TecnologÃ­a InformÃ¡tica Coomeva - Colombia
	 Package     : VDIR_PACK_ENCUESTAS
	 Caso de Uso : 
	 DescripciÃ³n : Retorna 1 = Si / 0 = No si la persona lleno la encuesta
	 ----------------------------------------------------------------------
	 Autor : katherine.latorre@kalettre.com
	 Fecha : 15-01-2019  
	 ----------------------------------------------------------------------
	 ParÃ¡metros :     DescripciÃ³n:
	 inu_codAfiliacion       CÃ³digo de la afiliaciÃ³n
	 inu_codPersona          CÃ³digo de la persona contratante / beneficiario
	 inu_codEncuesta         CÃ³digo de la encuesta
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor ModificaciÃ³n
	 ----------------------------------------------------------------- */

	    CURSOR cu_valida_encuesta IS
		SELECT COUNT(1)
		  FROM VDIR_ENCUESTA_PERSONA per,
		  (SELECT MAX(COD_AFILIACION) AS COD_AFILIADO FROM VDIR_ENCUESTA_PERSONA MEP WHERE MEP.COD_PERSONA = inu_codPersona) MAXEP
	     WHERE per.COD_AFILIACION = MAXEP.COD_AFILIADO
		   AND per.COD_PERSONA    = inu_codPersona
		   AND per.COD_ENCUESTA   = inu_codEncuesta;

		lnu_validaEncuesta NUMBER(1) := 0;

	BEGIN

		 OPEN cu_valida_encuesta; 
		FETCH cu_valida_encuesta INTO lnu_validaEncuesta; 
		CLOSE cu_valida_encuesta;

		RETURN lnu_validaEncuesta;

	END fnGetValidaEncuesta;


    -- ---------------------------------------------------------------------
    -- VDIR_FN_VALIDA_ENCUESTA_SALUD
    -- ---------------------------------------------------------------------
    FUNCTION VDIR_FN_VALIDA_ENCUESTA_SALUD
    (
        p_codigo_afiliacion IN VDIR_AFILIACION.COD_AFILIACION%TYPE        
    )
	RETURN sys_refcursor 
    AS

    vl_retorno VARCHAR2(500);
    vl_cursor sys_refcursor; 

	/* ---------------------------------------------------------------------
	 Copyright   : TecnologÃ­a InformÃ¡tica Coomeva - Colombia
	 Package     : VDIR_PACK_ENCUESTAS
	 Caso de Uso : 
	 DescripciÃ³n : Retorna -1 = No / el nombre del beneficiario
	 ----------------------------------------------------------------------
	 Autor : ever.orlando.hidalgo@kalettre.com
	 Fecha : 18-02-2019  
	 ----------------------------------------------------------------------
	 ParÃ¡metros :     DescripciÃ³n:
	 p_codigo_afiliacion       CÃ³digo de la afiliaciÃ³n		 
	 ----------------------------------------------------------------------
	 Historia de Modificaciones
	 ----------------------------------------------------------------------
	 Fecha Autor ModificaciÃ³n
	 ----------------------------------------------------------------- */
    BEGIN 
      OPEN vl_cursor
       FOR        
           SELECT DISTINCT
                persona.cod_persona AS CODIGO,
                COALESCE(persona.nombre_1,' ')||' '|| COALESCE(persona.nombre_2,' ')||' '|| COALESCE(persona.apellido_1,' ')||' '||COALESCE(persona.apellido_2,' ') AS BENEFICIARIO                                   
           FROM
             vdir_respuestas_marcadas rm 

             INNER JOIN vdir_encuesta_persona afe
              ON afe.COD_ENCUESTA_PERSONA = rm.COD_ENCUESTA_PERSONA

             INNER JOIN vdir_persona persona
              ON persona.cod_persona = afe.cod_persona 

             INNER JOIN  vdir_persona_tipoper per
              ON per.cod_persona = afe.cod_persona 

             INNER JOIN vdir_respuesta res
              ON res.cod_respuesta = rm.cod_respuesta 

             INNER JOIN vdir_contratante_beneficiario cb
              ON cb.COD_BENEFICIARIO = afe.cod_persona
              AND cb.COD_AFILIACION =  afe.COD_AFILIACION

             INNER JOIN vdir_beneficiario_programa bp
              ON bp.COD_BENEFICIARIO = persona.COD_PERSONA
			  AND bp.COD_AFILIACION =  afe.COD_AFILIACION

             INNER JOIN vdir_programa pg
              ON pg.COD_PROGRAMA = bp.COD_PROGRAMA			  

             WHERE                                       
               afe.COD_AFILIACION = p_codigo_afiliacion 
               AND per.cod_tipo_persona = 2
               AND afe.cod_encuesta = 2			   
               AND TRIM(res.des_respuesta) = 'SI'
               AND rm.COD_RESPUESTA <> 112 
			   AND pg.COD_PRODUCTO = 1;          


		RETURN vl_cursor;

	END VDIR_FN_VALIDA_ENCUESTA_SALUD;


END VDIR_PACK_ENCUESTAS;
create or replace PROCEDURE pr_envio_reporte_afi (codError OUT NUMBER, msgError OUT VARCHAR2) 

AS
  
    v_fecha DATE;
    v_mensaje VARCHAR2(400);
    v_afiliaciones_pendientes VARCHAR2(100);
    v_afiliaciones_grabadas VARCHAR2(100);
    v_lista_destinatarios VARCHAR2(500);

    v_telefono_actual VARCHAR2(20);
    v_posicion_inicio NUMBER := 1;
    v_posicion_fin NUMBER;
    v_asunto_sms VARCHAR2(50);

    BEGIN 

      -- Obtiene la fecha actual
      SELECT TO_CHAR(SYSDATE, 'DD-MM-YYYY') INTO v_fecha FROM dual;

      -- Obtiene el número de afiliaciones gabadas
      SELECT COUNT(*) INTO v_afiliaciones_grabadas FROM rpa_venta_general WHERE estado= 'GRABADO';

      -- Obtiene el número de afiliaciones pendientes
      SELECT COUNT(*) INTO v_afiliaciones_pendientes FROM rpa_venta_general WHERE estado= 'LISTO';

      -- Obtiene el mensaje a enviar
      SELECT valor INTO v_mensaje FROM app_config WHERE varkey='MSG_REPORT_AFE';

      v_mensaje:=REPLACE(v_mensaje,'{fecha}',v_fecha);
     
      IF v_afiliaciones_grabadas <= 1 THEN
        v_mensaje:=REPLACE(v_mensaje,'grabaron','grabó');
        v_mensaje:=REPLACE(v_mensaje,' afiliaciones ',' afiliación ');
        v_mensaje:=REPLACE(v_mensaje,'{num_grabados}',v_afiliaciones_grabadas);
      ELSE
        v_mensaje:=REPLACE(v_mensaje,'{num_grabados}',v_afiliaciones_grabadas);
      END IF;

      IF v_afiliaciones_pendientes <= 1 THEN
        v_mensaje:=REPLACE(v_mensaje,'quedaron pendientes','quedo pendiente');
        v_mensaje:=REPLACE(v_mensaje,'{num_pendientes}',v_afiliaciones_pendientes);
      ELSE
        v_mensaje:=REPLACE(v_mensaje,'{num_pendientes}',v_afiliaciones_pendientes);
      END IF;

      -- Obtiene la lista de destinatarios de mensajes SMS
      SELECT valor INTO v_lista_destinatarios FROM app_config WHERE varkey='SEND_REPORT_TO';

      -- Contar las afiliaciones pendientes
      SELECT COUNT(*) INTO v_afiliaciones_pendientes FROM rpa_venta_general WHERE estado = 'LISTO';

      -- Contar el asunto que va a tener el mensaje
      SELECT valor INTO v_asunto_sms FROM app_config WHERE varkey='ASUNTO_SMS_AFE';

      -- Iterar sobre la lista de teléfonos
      WHILE v_posicion_inicio < LENGTH(v_lista_destinatarios) LOOP
          -- Encontrar la posición de la coma
          v_posicion_fin := INSTR(v_lista_destinatarios, ',', v_posicion_inicio);

          -- Extraer el número de teléfono
          IF v_posicion_fin = 0 THEN
             v_telefono_actual := SUBSTR(v_lista_destinatarios, v_posicion_inicio);
             v_posicion_inicio:= LENGTH(v_lista_destinatarios)+1;
          ELSE
            v_telefono_actual := SUBSTR(v_lista_destinatarios, v_posicion_inicio, v_posicion_fin - v_posicion_inicio);
            v_posicion_inicio := v_posicion_fin + 1;
          END IF;

          -- Enviar mensaje SMS
          CORE_SEND_SMS_EMAIL(
              P_SMS_ORIGEN => 'BOT_AFE',
              P_EMAIL_ASUNTO => v_asunto_sms,
              P_SMS_CONTENIDO => v_mensaje,
              P_SMS_LARGO => 'false',
              P_SMS_NUM_DESTINO => v_telefono_actual,
              P_SMS_ESTADO => 'NOE',
              P_EMAIL_DESTINO => NULL,
              P_EMAIL_ESTADO => 'NOA',
              P_EMAIL_CONTENIDO => NULL,
              P_SMS_URL => NULL
          );

      END LOOP;

      codError := 0; -- Asignar un código de error, 0 si no hay errores
      msgError := 'Ok'; -- Asignar el mensaje de salida

     EXCEPTION
        WHEN OTHERS THEN
          codError := SQLCODE;
          msgError := SQLERRM;

  END pr_envio_reporte_afi;
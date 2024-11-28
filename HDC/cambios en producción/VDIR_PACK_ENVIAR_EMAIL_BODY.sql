create or replace PACKAGE BODY VDIR_PACK_ENVIAR_EMAIL AS

  FUNCTION send_email(REMITE IN VARCHAR2,DESTINO IN VARCHAR2, ASUNTO IN VARCHAR2, MENSAJE IN VARCHAR2,PUERTO IN NUMBER,SERVIDOR IN VARCHAR2,USUARIO IN VARCHAR2,CLAVE IN VARCHAR2)
RETURN VARCHAR2
AS                                                         
    remitente varchar2(100);                                                    
    conn_mail UTL_SMTP.connection;                                              
    l_boundary    VARCHAR2(50) := '----=*#abc1234321cba#*='; 
    varData BLOB;    
    
  BEGIN     
                                          
    if (remite is null) then                                                    
      remitente := 'noresponder@coomeva.com.co';                                   
    else
      remitente := remite;
    end if;                                                                     
                                                                                
    conn_mail := UTL_SMTP.open_connection(servidor, puerto);     
    UTL_SMTP.helo(conn_mail, servidor);                                         
    UTL_SMTP.mail(conn_mail, remitente);  
    add_destinatatios(conn_mail,destino);
   -- UTL_SMTP.rcpt(conn_mail, destino);                                          
                                                                                
    UTL_SMTP.open_data(conn_mail);                                              
                                                                                
    UTL_SMTP.write_data(conn_mail, 'Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || UTL_TCP.CRLF);                                                     
                                                                                
    UTL_SMTP.write_data(conn_mail, 'To: ' || destino || UTL_TCP.CRLF);          
    UTL_SMTP.write_data(conn_mail, 'From: ' || remitente || UTL_TCP.CRLF);      
    UTL_SMTP.write_data(conn_mail, 'Subject: ' || asunto || UTL_TCP.CRLF);      
    UTL_SMTP.write_data(conn_mail, 'Reply-To: ' || remitente || UTL_TCP.CRLF);  
    
    
    UTL_smtp.write_data(conn_mail, 'MIME-Version: ' || '1.0' || UTL_TCP.CRLF);
    UTL_smtp.write_data(conn_mail, 'Content-Type: ' || 'text/plain; charset=iso-8859-15' || UTL_TCP.CRLF);
    UTL_SMTP.write_data(conn_mail, 'Content-Type:'|| 'text/html; ' || UTL_TCP.crlf);
    UTL_smtp.write_data(conn_mail, 'Content-Transfer-Encoding: ' || '8bit' || UTL_TCP.CRLF);
    
    -- Deja un espacio para separar el cuerpo de la cabecera
    UTL_SMTP.write_data(conn_mail, UTL_TCP.CRLF);
    varData := utl_raw.cast_to_raw(MENSAJE); 
    UTL_smtp.write_raw_data(conn_mail, varData);
    UTL_SMTP.close_data(conn_mail);
    UTL_SMTP.quit(conn_mail);

  RETURN 'OK';
  
  END send_email;
  
  -----------------------------------------------------------
  
  FUNCTION send_email2(REMITE IN VARCHAR2,DESTINO IN VARCHAR2, ASUNTO IN VARCHAR2, MENSAJE IN CLOB,PUERTO IN NUMBER,SERVIDOR IN VARCHAR2,USUARIO IN VARCHAR2,CLAVE IN VARCHAR2,MENSAJE2 IN CLOB)
RETURN VARCHAR2
AS                                                         
    remitente varchar2(100);                                                    
    conn_mail UTL_SMTP.connection;                                              
    l_boundary    VARCHAR2(50) := '----=*#abc1234321cba#*='; 
    varData BLOB;    
    
  BEGIN       
                                          
    if (remite is null) then                                                    
      remitente := 'noresponder@coomeva.com.co';                                   
    else
      remitente := remite;
    end if;                                                                     
                                                                                
    conn_mail := UTL_SMTP.open_connection(servidor, puerto);     
    UTL_SMTP.helo(conn_mail, servidor);                                         
    UTL_SMTP.mail(conn_mail, remitente);  
    add_destinatatios(conn_mail,destino);
   -- UTL_SMTP.rcpt(conn_mail, destino);                                          
                                                                                
    UTL_SMTP.open_data(conn_mail);                                              
                                                                                
    UTL_SMTP.write_data(conn_mail, 'Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || UTL_TCP.CRLF);                                                     
                                                                                
    UTL_SMTP.write_data(conn_mail, 'To: ' || destino || UTL_TCP.CRLF);          
    UTL_SMTP.write_data(conn_mail, 'From: ' || remitente || UTL_TCP.CRLF);      
    UTL_SMTP.write_data(conn_mail, 'Subject: ' || asunto || UTL_TCP.CRLF);      
    UTL_SMTP.write_data(conn_mail, 'Reply-To: ' || remitente || UTL_TCP.CRLF);  
    
    
    UTL_smtp.write_data(conn_mail, 'MIME-Version: ' || '1.0' || UTL_TCP.CRLF);
    UTL_smtp.write_data(conn_mail, 'Content-Type: ' || 'text/plain; charset=iso-8859-15' || UTL_TCP.CRLF);
    UTL_SMTP.write_data(conn_mail, 'Content-Type:'|| 'text/html; ' || UTL_TCP.crlf);
    UTL_smtp.write_data(conn_mail, 'Content-Transfer-Encoding: ' || '8bit' || UTL_TCP.CRLF);
    
    -- Deja un espacio para separar el cuerpo de la cabecera
    UTL_SMTP.write_data(conn_mail, UTL_TCP.CRLF);
    varData := utl_raw.cast_to_raw(MENSAJE||MENSAJE2); 
    UTL_smtp.write_raw_data(conn_mail, varData);
    UTL_SMTP.close_data(conn_mail);
    UTL_SMTP.quit(conn_mail);

  RETURN 'OK';
  
  END send_email2;
 --------------------------------------------------------------------------------------------------------- 
  
  PROCEDURE add_destinatatios(P_MAIL_CONN IN OUT UTL_SMTP.CONNECTION,P_LIST IN VARCHAR2) 
  AS 
  
  l_tab NEXOS_string_api.t_split_array;
  BEGIN
  
   IF (TRIM(p_list) IS NOT NULL) THEN
      l_tab := NEXOS_string_api.split_text(p_list);
      FOR i IN 1 .. l_tab.COUNT LOOP
        UTL_SMTP.rcpt(p_mail_conn, TRIM(l_tab(i)));
      END LOOP;
   END IF;  
  
  END;
  
END VDIR_PACK_ENVIAR_EMAIL;
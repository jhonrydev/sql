create or replace PACKAGE BODY PCMED_SNPCENTROSMEDICOS AS
-- INSERTA CIUDADES EN LA TABLE POR_CIUDAD
    PROCEDURE INSERT_POR_CIUDAD(V_CODE IN VARCHAR2,V_NAME IN VARCHAR2, V_STATUS IN VARCHAR2, V_ID OUT NUMBER)
    
    IS

        BEGIN

            SELECT SEQ_POR_CIUDAD.NEXTVAL INTO V_ID FROM DUAL;

            INSERT INTO POR_CIUDAD VALUES (V_ID,V_CODE,V_NAME,V_STATUS);

            COMMIT;

        END INSERT_POR_CIUDAD;


-- ACTUALIZA UNA CIUDAD POR EL ID EN LA TABLA POR_CIUDAD     
    PROCEDURE UPDATE_POR_CIUDAD(V_ID IN INTEGER, V_CODE IN VARCHAR2,V_NAME IN VARCHAR2, V_STATUS IN VARCHAR2)IS

        BEGIN

            UPDATE POR_CIUDAD SET CODE=V_CODE, NAME=V_NAME,STATUS=V_STATUS WHERE ID=V_ID;

            COMMIT;

        END UPDATE_POR_CIUDAD;


-- INHABILITA UNA CIUDAD POR SU ID DE LA TABLE POR_CIUDAD         
    PROCEDURE DELETE_POR_CIUDAD(V_ID IN INTEGER) IS 

        BEGIN

            UPDATE POR_CIUDAD SET STATUS=0 WHERE ID=V_ID;

            COMMIT;

        END DELETE_POR_CIUDAD;


-- INSERTA ESPECIALIDAD EN LA TABLE POR_ESPECIALIDAD
    PROCEDURE INSERT_POR_ESPECIALIDAD(V_CODE IN VARCHAR2,V_NAME IN VARCHAR2,V_SUBSPECIALTY IN VARCHAR2 DEFAULT 'NULL', V_STATUS IN VARCHAR2, V_ID OUT NUMBER) IS

        BEGIN

            SELECT SEQ_POR_ESPECIALIDAD.NEXTVAL INTO V_ID FROM DUAL;

            INSERT INTO POR_ESPECIALIDAD VALUES (V_ID, V_CODE, V_NAME,V_SUBSPECIALTY,V_STATUS);

            COMMIT;

        END INSERT_POR_ESPECIALIDAD;


-- ACTUALIZA UNA ESPECIALIDAD POR EL ID EN LA TABLA POR_ESPECIALIDAD      
    PROCEDURE UPDATE_POR_ESPECIALIDAD(V_ID IN INTEGER, V_CODE IN VARCHAR2,V_NAME IN VARCHAR2,V_SUBSPECIALTY IN VARCHAR2 DEFAULT 'NULL', V_STATUS IN VARCHAR2)IS

    BEGIN

        UPDATE POR_ESPECIALIDAD SET CODE=V_CODE,NAME=V_NAME,SUBSPECIALTY=V_SUBSPECIALTY,STATUS=V_STATUS WHERE ID=V_ID;

        COMMIT;

    END UPDATE_POR_ESPECIALIDAD; 


-- INHABILITA UNA ESPECIALIDAD POR SU ID DE LA TABLE POR_ESPECIALIDAD     
    PROCEDURE DELETE_POR_ESPECIALIDAD(V_ID IN INTEGER) IS

        BEGIN

            UPDATE POR_ESPECIALIDAD SET STATUS=0 WHERE ID=V_ID;

            COMMIT;

        END DELETE_POR_ESPECIALIDAD;


-- INSERTA CENTRO MEDICO EN LA TABLA POR_CENTRO_MEDICO     
    PROCEDURE INSERT_POR_CMEDICOS(V_NAME IN VARCHAR2,V_CITY IN VARCHAR2,V_ADDRESS IN VARCHAR2,V_LAT IN VARCHAR2,V_LON IN VARCHAR2,V_HOUR_INI IN VARCHAR2,V_HOUR_FIN IN VARCHAR2 DEFAULT 'NULL',V_PHONE IN VARCHAR2,V_IMAGE IN VARCHAR2,V_STATUS IN VARCHAR2,V_ADDRESS_2 IN VARCHAR2,V_ID OUT NUMBER) IS

    BEGIN 

        SELECT SEQ_POR_CENTROS_MEDICOS.NEXTVAL INTO V_ID FROM DUAL;

        INSERT INTO POR_CENTROS_MEDICOS
        VALUES (V_ID,V_NAME,V_CITY,V_ADDRESS,V_LAT,V_LON,V_HOUR_INI,V_HOUR_FIN,V_PHONE,V_IMAGE,V_STATUS,V_ADDRESS_2);

        COMMIT;

        END INSERT_POR_CMEDICOS;


-- ACTUALIZA CENTRO MEDICO POR SU ID EN LA TABLA POR_CENTRO_MEDICO      
    PROCEDURE UPDATE_POR_CMEDICOS(V_ID IN INTEGER,V_NAME IN VARCHAR2,V_CITY IN VARCHAR2,V_ADDRESS IN VARCHAR2,V_LAT IN VARCHAR2,V_LON IN VARCHAR2,V_HOUR_INI IN VARCHAR2,V_HOUR_FIN IN VARCHAR2 DEFAULT 'NULL',V_PHONE IN VARCHAR2,V_IMAGE IN VARCHAR2,V_STATUS IN VARCHAR2,V_ADDRESS_2 IN VARCHAR2) IS

    BEGIN

        UPDATE POR_CENTROS_MEDICOS
        SET NAME=V_NAME,CITY=V_CITY,ADDRESS=V_ADDRESS,LAT=V_LAT,LON=V_LON,HOUR_INI=V_HOUR_INI,HOUR_FIN=V_HOUR_FIN,PHONE=V_PHONE,IMAGE=V_IMAGE,STATUS=V_STATUS,ADDRESS_2=V_ADDRESS_2
        WHERE ID=V_ID;

        COMMIT;

        END UPDATE_POR_CMEDICOS;


-- INHABILITA UN CENTRO MEDICO POR SU ID EN LA TABLE POR_CENTROS_MEDICOS 
     PROCEDURE DELETE_POR_CMEDICOS(V_ID IN INTEGER) IS
        BEGIN

            UPDATE POR_CENTROS_MEDICOS SET STATUS=0 WHERE ID=V_ID;
        END DELETE_POR_CMEDICOS;


-- CREA LA RELACIÓN ENTRE ESPECIALIDAD Y CIUDAD
    PROCEDURE INSERT_POR_ESP_X_CIUDAD(V_ID_CIU IN INTEGER, V_ID_ESP IN INTEGER) IS

        V_ID INTEGER;

        BEGIN

            SELECT SEQ_POR_ESPECIALIDAD_X_CIUDAD.NEXTVAL INTO V_ID FROM DUAL;

            INSERT INTO POR_ESPECIALIDAD_X_CIUDAD VALUES (V_ID,V_ID_CIU,V_ID_ESP);

            COMMIT;

        END INSERT_POR_ESP_X_CIUDAD;

-- ACTUALIZA LA RELACIÓN ENTRE ESPECIALIDAD Y CIUDAD
        PROCEDURE UPDATE_POR_ESP_X_CIUDAD(V_ID IN INTEGER,V_ID_CIU IN INTEGER, V_ID_ESP IN INTEGER) IS

            BEGIN 

                UPDATE POR_ESPECIALIDAD_X_CIUDAD SET ID_CIUDAD=V_ID_CIU,ID_ESPECIALIDAD=V_ID_ESP WHERE ID=V_ID;

                COMMIT;

            END UPDATE_POR_ESP_X_CIUDAD;
            
-- ELIMINA LA RELACIÓN ENTRE ESPECIALIDAD POR CIUDAD
        PROCEDURE DELETE_POR_ESP_X_CIUDAD(V_IDCIUDAD IN INTEGER) IS
        
            BEGIN 
                
                DELETE FROM POR_ESPECIALIDAD_X_CIUDAD WHERE ID_CIUDAD=V_IDCIUDAD;
                
                COMMIT;
                
            END DELETE_POR_ESP_X_CIUDAD;
            
-- CREA LA REALACION ENTRE ESPECIALIDAD Y CENTRO MEDICO 
        PROCEDURE INSERT_POR_SPECIALTIES(V_SPECIALTY IN VARCHAR2,V_SUBSPECIALTY IN VARCHAR2 DEFAULT 'NULL',V_MEDICAL_C_ID IN INTEGER, V_STATUS IN VARCHAR2 DEFAULT '1'  )IS
            V_ID INTEGER;
            STATUS CHAR;
            BEGIN 
                
                IF V_STATUS IS NULL THEN 
                    STATUS:='1'; 
                END IF;
                
                 SELECT SEQ_POR_SPECIALTIES.NEXTVAL INTO V_ID FROM DUAL;
                
                 INSERT INTO POR_SPECIALTIES VALUES (V_ID,V_SPECIALTY,V_SUBSPECIALTY,V_MEDICAL_C_ID,STATUS);
                 
                 COMMIT;
                
            END;
            
-- ACTUALIZA LA RELACION ENTRE ESPECIALIDAD Y CENTROS MEDICOS
        PROCEDURE UPDATE_POR_SPECIALTIES(V_ID IN INTEGER,V_SPECIALTY IN VARCHAR2,V_SUBSPECIALTY IN VARCHAR2 DEFAULT 'NULL',V_MEDICAL_C_ID IN INTEGER, V_STATUS IN VARCHAR2 DEFAULT '1') IS
                STATUS CHAR;
            BEGIN
            
                IF V_STATUS IS NULL THEN 
                    STATUS:='1'; 
                END IF;
                
                UPDATE POR_SPECIALTIES SET SPECIALTY=V_SPECIALTY,SUBSPECIALTY=V_SUBSPECIALTY,MEDICAL_CENTER_ID=V_MEDICAL_C_ID,STATUS=STATUS
                WHERE ID=V_ID;
                
                COMMIT;
                
            END;
            
-- ELIMINA LA RELACIÓN ENTRE ESPECIALIDAD Y CENTROS MEDICOS
        PROCEDURE DELETE_POR_SPECIALTIES(ID_CENTRO_M IN INTEGER) IS
            BEGIN
                
                DELETE POR_SPECIALTIES WHERE MEDICAL_CENTER_ID=ID_CENTRO_M;
                
                COMMIT;
            END;
            

END PCMED_SNPCENTROSMEDICOS;
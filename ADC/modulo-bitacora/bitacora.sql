select count(*), numero_documento from ACEPTA_TERMINOS_INFOMEDICA where numero_documento = '16849299' GROUP by numero_documento;
select * from ACEPTA_TERMINOS_INFOMEDICA where numero_documento = '805023021' order BY nombre_aplicacion;


select count(*), numero_documento from ACEPTA_TERMINOS_HD where numero_documento = '16849299' GROUP by numero_documento;
select * from ACEPTA_TERMINOS_HD where numero_documento = '805023021' order BY nombre_aplicacion;

SELECT ACEPTA_TERMINOS_HD.tipo_usuario, ACEPTA_TERMINOS_HD.tipo_documento, ACEPTA_TERMINOS_HD.numero_documento,ACEPTA_TERMINOS_HD.nombre_completo,ACEPTA_TERMINOS_HD.fecha,ACEPTA_TERMINOS_HD.hora
FROM ACEPTA_TERMINOS_HD 
INNER JOIN ACEPTA_TERMINOS_INFOMEDICA 
ON ACEPTA_TERMINOS_INFOMEDICA.numero_documento = ACEPTA_TERMINOS_HD.numero_documento
WHERE ACEPTA_TERMINOS_INFOMEDICA.numero_documento = '3745386';

select * from ADM_VERSION_DOCUMENTOS;
select * from ADM_VERSION_TERMS_COND_SEQ;

SELECT ADM_VERSION_TERMS_COND_SEQ.nextval FROM dual

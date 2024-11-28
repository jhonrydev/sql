select count(*), numero_documento from ACEPTA_TERMINOS_INFOMEDICA where numero_documento = '16849299' GROUP by numero_documento;
select * from ACEPTA_TERMINOS_INFOMEDICA where numero_documento = '3745386' order BY nombre_aplicacion;
delete acepta_terminos_infomedica where numero_documento = '3745386';
commit;

select count(*), numero_documento from ACEPTA_TERMINOS_HD where numero_documento = '16849299' GROUP by numero_documento;
select * from ACEPTA_TERMINOS_HD where numero_documento = '3745386' order BY nombre_aplicacion;
delete acepta_terminos_hd where numero_documento = '3745386';
commit;

select * from aut_aplicaciones_info;

SELECT *
from ACEPTA_TERMINOS_HD 
INNER JOIN ACEPTA_TERMINOS_INFOMEDICA 
ON ACEPTA_TERMINOS_INFOMEDICA.numero_documento = ACEPTA_TERMINOS_HD.numero_documento
WHERE ACEPTA_TERMINOS_INFOMEDICA.numero_documento = '3745386';

select * from ADM_VERSION_DOCUMENTOS;
select * from ADM_VERSION_TERMS_COND_SEQ;



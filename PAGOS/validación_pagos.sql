




SELECT depo_fecha,autorizacion,lote,item
FROM pe_compro_importacion
where autorizacion IN ()




SELECT depo_fecha,cod_unico_comprobante,lote,item
FROM pe_compro_importacion
where cod_unico_comprobante IN ()





SELECT id_compro_importacion,depo_fecha,autorizacion,cod_unico_comprobante,estado_proceso
FROM PE_COMPRO_IMPORTACION 
WHERE depo_fecha >= '2024-11-01 00:00:00.000' 
AND estado_proceso='E'
ORDER BY depo_fecha DESC; 


UPDATE PE_COMPRO_IMPORTACION SET  depo_fecha='2024-11-01 00:00:00.000', estado_proceso = null, proce_fecha= null, error= null   
WHERE id_compro_importacion IN(''); 
CREATE TABLE saludmp.ADM_ESTADOS (
	id INT IDENTITY(1,1) NOT NULL,
	descripcion VARCHAR(100)
);

INSERT INTO saludmp.ADM_ESTADOS VALUES ('RECIBIDO');
INSERT INTO saludmp.ADM_ESTADOS VALUES ('ASIGNADO');
INSERT INTO saludmp.ADM_ESTADOS VALUES ('RESUELTO');

DROP TABLE saludmp.ADM_GESTION_INCONSISTENCIA_PRESTADORES;
DROP TABLE saludmp.ADM_INCONSIS_PRESTAPP_3;

CREATE TABLE
	saludmp.ADM_INCONSIS_PRESTAPP_3 (
		cod_inconsis_prestapp INT IDENTITY (1, 1) NOT NULL,
		fecha_registro DATE DEFAULT GETDATE(),
		cod_tipo_datopres VARCHAR(20),
		cod_prestador INT,
		cod_ciudad_prestador CHAR(5),
		tipo_id_usuario CHAR(2),
		id_usuario CHAR(15),
		app VARCHAR(20),
		ruta VARCHAR(400),
		cod_estado INT DEFAULT 1,
		observacion VARCHAR(400),
		CONSTRAINT PK_ADM_INCONSIS_PRESTAPP_COD_INCONSIS_PRESTAPP PRIMARY KEY (cod_inconsis_prestapp)
	);

CREATE TABLE
	saludmp.ADM_GESTION_INCONSISTENCIA_PRESTADORES (
		cod_inconsis_prestapp INT NOT NULL,
		cod_tipo_datopres INT NOT NULL,
		id_asesor CHAR(15),
		fecha_asignacion DATE,
		fecha_resuelto DATE,
		cod_estado INT DEFAULT 1,
		observaciones_gestion VARCHAR(4000),

		CONSTRAINT FK_ADM_GESTION_INCONSISTENCIA_PRESTADORES_ON_cod_inconsis_prestapp FOREIGN KEY(cod_inconsis_prestapp) REFERENCES saludmp.ADM_INCONSIS_PRESTAPP_3(cod_inconsis_prestapp) ,
		CONSTRAINT FK_ADM_GESTION_INCONSISTENCIA_PRESTADORES_ON_cod_tipo_datopres FOREIGN KEY(cod_tipo_datopres) REFERENCES saludmp.ADM_P_TIPO_DATOPRES(cod_tipo_datopres), 
		CONSTRAINT PK_SALUDMP_ADM_GESTION_INCONSISTENCIA_PRESTADORES PRIMARY KEY(cod_inconsis_prestapp,cod_tipo_datopres)
	);


INSERT INTO saludmp.ADM_INCONSIS_PRESTAPP_3 VALUES (GETDATE(),'1,3,4','7167','CC','123456789','APPMP','ACACIAS - META / Urgencias','esto es una prueba visorU esto es una prueba visorU','2')
-- insert into saludmp.ADM_INCONSIS_PRESTAPP_3 values (GETDATE(),1,'2','7167','CC','123456789','APPMP','ACACIAS - META / Urgencias','esto es una prueba visorU esto es una prueba visorU','2')

select * from saludmp.ADM_INCONSIS_PRESTAPP;
select * from saludmp.ADM_P_TIPO_DATOPRES;

-- =============================================================================================================================================
SELECT DISTINCT TOP 10 PRESTAD, regional FROM Visor_directorios_5 WHERE regional IN (SELECT ofi FROM LIQUI_OFICINAS);
-- =============================================================================================================================================
SELECT DISTINCT TOP 10 ASE.NumeroDocumento,ASE.IdTipoDocumento,ASEP.IdRegional FROM Asesor ASE INNER JOIN AsesorPlan ASEP ON ASE.IdAsesor=ASEP.IdAsesor
WHERE ASE.IdTipoDocumento  NOT IN ('NI','CC') AND ASEP.IdRegional = 10 ;--IN (SELECT ofi FROM LIQUI_OFICINAS);
-- =============================================================================================================================================
SELECT DISTINCT ADM_IP.cod_inconsis_prestapp,ADM_IP.cod_tipo_datopres,ADM_IP.observacion,ADM_IP.cod_prestador,ADM_IP.fecha_registro,ADM_IP.app,
	ADM_TIP.descripcion AS descripcion_fallo,
	VISOR_5.PRESTADOR AS nombre_prestador, 
	ADM_IP.tipo_id_usuario,
	ADM_IP.id_usuario,
	CONCAT(LTRIM(RTRIM(AFI.nombre)),' ',LTRIM(RTRIM(AFI.ape)),' ',LTRIM(RTRIM(AFI.nombre2)),' ',LTRIM(RTRIM(AFI.ape2))) AS nombre_usuario,
	ADM_IP.ruta,
	ADM_IP.cod_estado
FROM saludmp.ADM_INCONSISTENCIAS_PRESTADORES_X_APP ADM_IP 
	INNER JOIN saludmp.ADM_GESTION_INCONSISTENCIAS_PRESTADORES ADM_GIP ON ADM_IP.cod_inconsis_prestapp = ADM_GIP.cod_inconsis_prestapp
	INNER JOIN saludmp.ADM_TIPO_INCONSISTENCIAS_PRESTADOR ADM_TIP ON ADM_GIP.cod_tipo_datopres=ADM_TIP.cod_tipo_datopres
	INNER JOIN Visor_directorios_5 VISOR_5 ON VISOR_5.prestad=ADM_IP.cod_prestador AND VISOR_5.cod_ciudad=ADM_IP.cod_ciudad_prestador
	INNER JOIN AFILIADOS AFI ON AFI.docu_tipo=ADM_IP.tipo_id_usuario AND ADM_IP.id_usuario=AFI.docu_nro
WHERE 
	 VISOR_5.regional = 1--@id_regional_asesor
-- =============================================================================================================================================
	
SELECT ofi FROM LIQUI_OFICINAS




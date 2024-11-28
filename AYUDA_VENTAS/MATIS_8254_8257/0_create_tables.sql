
CREATE TABLE saludmp.ADM_ESTADOS (
	id INT IDENTITY(1,1) NOT NULL,
	descripcion VARCHAR(100)

	CONSTRAINT PK_ADM_ESTADOS_ID PRIMARY KEY (id)
);

INSERT INTO saludmp.ADM_ESTADOS VALUES ('RADICADO');
INSERT INTO saludmp.ADM_ESTADOS VALUES ('ASIGNADO');
INSERT INTO saludmp.ADM_ESTADOS VALUES ('RESUELTO');


CREATE TABLE
	saludmp.ADM_INCONSISTENCIAS_PRESTADORES_X_APP (
		cod_inconsis_prestapp INT IDENTITY (1, 1) NOT NULL,
		fecha_registro DATE NOT NULL,
		cod_tipo_datopres VARCHAR(20) NOT NULL,
		cod_prestador INT NOT NULL,
		cod_ciudad_prestador CHAR(5) NOT NULL,
		tipo_id_usuario CHAR(2) NOT NULL,
		id_usuario CHAR(15) NOT NULL,
		app VARCHAR(20),
		ruta VARCHAR(400),
		cod_estado INT DEFAULT 1,
		observacion VARCHAR(4000),
		CONSTRAINT PK_ADM_INCONSISTENCIAS_PPRESTADORES_X_APP_COD_INCONSIS_PRESTAPP PRIMARY KEY (cod_inconsis_prestapp)
	);


CREATE TABLE
	saludmp.ADM_GESTION_INCONSISTENCIAS_PRESTADORES (
		cod_inconsis_prestapp INT NOT NULL,
		cod_tipo_datopres INT NOT NULL,
		id_asesor CHAR(15),
		fecha_asignacion DATE,
		fecha_resuelto DATE,
		cod_estado INT DEFAULT 1,
		observaciones_gestion VARCHAR(4000),

		CONSTRAINT FK_ADM_GESTION_INCONSISTENCIAS_PRESTADORES_ON_cod_inconsis_prestapp FOREIGN KEY(cod_inconsis_prestapp) REFERENCES saludmp.ADM_INCONSISTENCIAS_PRESTADORES_X_APP(cod_inconsis_prestapp) ,
		CONSTRAINT FK_ADM_GESTION_INCONSISTENCIAS_PRESTADORES_ON_cod_tipo_datopres FOREIGN KEY(cod_tipo_datopres) REFERENCES saludmp.ADM_P_TIPO_DATOPRES(cod_tipo_datopres), 
		CONSTRAINT PK_ADM_GESTION_INCONSISTENCIAS_PRESTADORES PRIMARY KEY(cod_inconsis_prestapp,cod_tipo_datopres)
	);


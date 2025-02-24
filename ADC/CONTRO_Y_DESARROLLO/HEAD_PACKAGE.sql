create or replace PACKAGE             PKG_ADM AS
				  
			PROCEDURE SP_GET_IMAGES(
					 pnu_id IN NUMBER DEFAULT NULL, 
					pcl_json_result OUT CLOB, 
					pnu_indconsulta OUT NUMBER, 
					pva_error_msg OUT VARCHAR2
    );

			PROCEDURE SP_GET_IMAGES_BY_TYPE(
					pva_device IN VARCHAR2,
					pva_size_image IN VARCHAR2,
					pva_arquetipo IN VARCHAR2,
					pcur_generica OUT SYS_REFCURSOR,
					pcur_arquetipo OUT SYS_REFCURSOR,
					pva_error_msg OUT VARCHAR2
			);

			PROCEDURE SP_INSERT_IMAGES_HOME (
					 p_json IN VARCHAR2
			);

			 PROCEDURE SP_UPDATE_IMAGES_HOME(
					p_id IN NUMBER,
					p_json IN VARCHAR2
			);

			PROCEDURE PR_GUARDAR_SKILL(
				num_id IN NUMBER,
				var_nombre_completo IN VARCHAR2,
				var_foto IN VARCHAR2,				
				var_url_chat IN VARCHAR2,
				var_numero_whatsapp IN VARCHAR2,
				dat_fecha_alta IN VARCHAR2,
				dat_fecha_baja IN VARCHAR2,
				dat_fecha_actualizacion IN VARCHAR2,
				var_observaciones IN VARCHAR2,
				num_estado IN NUMBER,
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			);

			PROCEDURE PR_LIST_SKILL(
				num_id NUMBER,
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			);

				PROCEDURE PR_GET_SKILL_BY_ID(
				num_id NUMBER,
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			);

			PROCEDURE PR_CAMBIAR_ESTADO_SKILL(
					var_id IN VARCHAR2,
					num_estado IN NUMBER,
					var_observaciones IN VARCHAR2,
					codError OUT NUMBER,
					msgError OUT VARCHAR2,
					registros OUT SYS_REFCURSOR
				);

			PROCEDURE PR_GUARDAR_USUARIO(
				num_id IN NUMBER,
				var_nombre_completo IN VARCHAR2,
				num_id_tipo_identificacion IN NUMBER,				
				var_numero_identificacion IN VARCHAR2,
				num_id_agente_asignado IN NUMBER,
				dat_fecha_alta IN VARCHAR2,
				dat_fecha_baja IN VARCHAR2,
				dat_fecha_actualizacion IN VARCHAR2,

				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			);

			PROCEDURE PR_CAMBIAR_ESTADO_USUARIO(
					var_id IN VARCHAR2,
					num_estado IN NUMBER,
					codError OUT NUMBER,
					msgError OUT VARCHAR2,
					registros OUT SYS_REFCURSOR
				);

			PROCEDURE PR_GUARDAR_HORARIO(
				num_id IN NUMBER,
				var_lun_vie_inicio IN VARCHAR2,
				var_lun_vie_fin IN VARCHAR2,
				var_sabado_inicio IN VARCHAR2,
				var_sabado_fin IN VARCHAR2,
				var_domingo_inicio IN VARCHAR2,
				var_domingo_fin IN VARCHAR2,
				var_festivo_inicio IN VARCHAR2,
				var_festivo_fin IN VARCHAR2,
				var_mensaje IN VARCHAR2,
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			);

			PROCEDURE PR_GET_HORARIO(
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			);


			PROCEDURE PR_GET_USER_POR_DOCUMENTO(
				num_documento NUMBER,
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			);

			PROCEDURE PR_GET_USER_POR_ID(
				num_id NUMBER,
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			);


			PROCEDURE PR_LISTARUSUARIO(
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			);

			PROCEDURE PR_LISTARTIPOSDOCUMENTOS(
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			);

				PROCEDURE PR_GUARDAR_USUARIOS_MASIVOS(
				p_users IN T_TABLA_USUARIOS,
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			);
			PROCEDURE PR_REASIGNARAGENTE(
				pvar_idusuarios IN VARCHAR2,
				pnum_idskill IN NUMBER,
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			);
            
             PROCEDURE PR_getfuncionalidadesinactivas(
                codError OUT NUMBER,
                msgError OUT VARCHAR2,
                registros OUT SYS_REFCURSOR
            );
            
             PROCEDURE PR_GET_AFILIADOS_CONTROL_Y_DESARROLLO(
				codError OUT NUMBER,
				msgError OUT VARCHAR2,
				registros OUT SYS_REFCURSOR
			);


	END PKG_ADM;
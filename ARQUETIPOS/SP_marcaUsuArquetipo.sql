SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    ALTER PROCEDURE [saludmp].[SP_marcaUsuArquetipo]
		@coderror INTEGER  =0  output,
		@msgerror VARCHAR(500)  =0  output,
		@prm_docu_tipo nvarchar(50),  
		@prm_docu_nro nvarchar(50),
		@contar  nvarchar(2)  = NULL
	AS   
		SET NOCOUNT ON

		SELECT @contar=COUNT(1)
		  FROM [dbo].[AFILIADOS] AF  
		  INNER JOIN [dbo].[REGISTRO_UNICO_PERFILAMIENTO] RUP ON RUP.codigo_unico_persona = AF.codigo_unico_persona AND (CURRENT_TIMESTAMP >= RUP.vigen_desde AND (RUP.vigen_hasta is null OR  CURRENT_TIMESTAMP <= RUP.vigen_hasta))
		 WHERE AF.docu_nro= @prm_docu_nro
   		   AND AF.docu_tipo= @prm_docu_tipo
	
		IF (@contar =0) BEGIN
			SELECT @coderror = 5;
			SELECT @msgerror = 'El usuario no cuenta con marcaciones vigentes';
		END	
	
		 SELECT DISTINCT AF.docu_tipo ,
				RTRIM (AF.docu_nro) docu_nro,
				CONCAT(RTRIM (AF.nombre), ' ', RTRIM (AF.nombre2), ' ', RTRIM (AF.ape), ' ', RTRIM (AF.ape2)) nombre_afi  ,
			   (SELECT TOP(1) RUE.email
				  FROM [dbo].[REGISTRO_UNICO_EMAILS] RUE 
				 WHERE RUE.codigo_unico_persona = AF.codigo_unico_persona 
				   AND (RUE.baja_fecha is null or CURRENT_TIMESTAMP <= RUE.baja_fecha) 
				   and CURRENT_TIMESTAMP >= RUE.vigencia
				   ORDER BY vigencia DESC) email,           
			   (SELECT TOP(1) RUT.tele
				  FROM [dbo].[REGISTRO_UNICO_TELEFONOS] RUT 
				 WHERE RUT.codigo_unico_persona = AF.codigo_unico_persona 
				   AND RUT.tipo_tele = 'C' 
				   AND (RUT.baja_fecha is null or CURRENT_TIMESTAMP <= RUT.baja_fecha) 
				   and CURRENT_TIMESTAMP >= RUT.vigencia
				   ORDER BY vigencia DESC) celular,                 
			   (SELECT TOP(1) RTRIM (RUT.tele)
				  FROM [dbo].[REGISTRO_UNICO_TELEFONOS] RUT 
				 WHERE RUT.codigo_unico_persona = AF.codigo_unico_persona 
				   AND RUT.tipo_tele = 'P' 
				   AND (RUT.baja_fecha is null or CURRENT_TIMESTAMP <= RUT.baja_fecha) 
				   and CURRENT_TIMESTAMP >= RUT.vigencia
				   ORDER BY vigencia DESC) tele_fijo,        
				PT.tipo_perfil  cod_arquetipo,
				PT.deno arquetipo  ,
				PC.deno marcacion ,
				PCS.deno sub_marcacion ,
				CONVERT(varchar,RUP.vigen_desde,105)vigen_desde 	,
				CONVERT(varchar,RUP.vigen_hasta,105)vigen_hasta ,
				LNG.linea_negocio  
		   FROM [dbo].[AFILIADOS] AF 
			 LEFT JOIN [dbo].[REGISTRO_UNICO_PERFILAMIENTO] RUP ON RUP.codigo_unico_persona = AF.codigo_unico_persona AND (CURRENT_TIMESTAMP >= RUP.vigen_desde AND (RUP.vigen_hasta is null OR  CURRENT_TIMESTAMP <= RUP.vigen_hasta))
			 LEFT JOIN [dbo].[PERFILES_TIPO] PT ON PT.tipo_perfil = RUP.tipo_perfil  
			 LEFT JOIN [dbo].[PERFILES_CONFIG] PC ON PC.cod_perfil = RUP.cod_perfil 
			 LEFT JOIN [dbo].[LINEA_NEGOCIO] LNG ON LNG.cod = PC.linea_negocio  
			 LEFT JOIN [dbo].[PERFILES_CONFIG_SUB] PCS ON PCS.cod_perfil_sub  = RUP.cod_perfil_sub 
		  WHERE AF.docu_nro= @prm_docu_nro
			AND AF.docu_tipo= @prm_docu_tipo

		--SET @coderror = 0;
		--SET @msgerror = 'Consulta Exitosa';
GO

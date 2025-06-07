SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [saludmp].[SP_DIR_AGRUPADORES]
       @coderror INTEGER  =0  output,
       @msgerror VARCHAR(500)  =0  output, 
       @desAgrupa nvarchar(50),
       @tipoAgrupa nvarchar(3),
       @ciudad VARCHAR(50),   
       @conteo INTEGER = NULL,
	   @desAgrupaNuevo nvarchar(50) =  NULL,
       @cantidad nvarchar(100) = NULL
AS   

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON

	create table #agrupadores
	([cod_agrupador] [int] not null,
	 [descripcion] [varchar](400) NULL,
	 [nivel_auditoria] [int] NULL,
	 [tipoAgrupa] [varchar](3) not NULL,
	 [partido][char](5) not NULL
	);

	create table #agrupadores2
	 	([cod_agrupador] [int] not null,
	 	[descripcion] [varchar](400) NULL,
	 	[nivel_auditoria] [int] NULL,
	 	[tipoAgrupa] [varchar](3) not NULL,
	 	[partido][char](5) not NULL
	 	);


	SELECT @desAgrupaNuevo = REPLACE(REPLACE(REPLACE(REPLACE(@desagrupa, ' y ',' '), ' de ', ' '),', ',' '), ' ', '|')

	SELECT @cantidad = COUNT(*) from dbo.SplitString(@desAgrupaNuevo, '|')		

	INSERT INTO #agrupadores
	SELECT *
	  FROM(SELECT d.cod_agrupador, d.descripcion, d.nivel_auditoria, d.tipoAgrupa, COUNT(1) cant
		 	 FROM dbo.SplitString(@desAgrupaNuevo, '|') t, saludmp.DIR_AGRUPADORES d
		    WHERE d.descripcion like '%'+t.String+'%'
			  and d.tipoAgrupa = @tipoAgrupa 
		 group by d.cod_agrupador, d.descripcion,d.nivel_auditoria, d.tipoAgrupa) t2
	  where t2.cant=@cantidad


	select @conteo = count(*) from #agrupadores;
	
	
	 IF (@conteo <= 0) BEGIN
	 	BEGIN
	 	
			INSERT INTO saludmp.DIR_HOMOLOGACION_NE (des_busqueda,fecha_busqueda,cod_estado) VALUES ( @desAgrupa, GETDATE(),1);
			
			SELECT cod_agrupador,
					descripcion ,
					nivel_auditoria ,
					tipoAgrupa,
					partido 
			FROM #agrupadores2

				DROP TABLE 	#agrupadores;			
				DROP TABLE 	#agrupadores2;		
	 	END
	 END
	 ELSE
	 	BEGIN		

			
		
			
	 	INSERT INTO #agrupadores2	
	 	select AG.cod_agrupador,
	 		AG.descripcion ,
	 		AG.nivel_auditoria ,
	 		AG.tipoAgrupa,
	 		PAR.partido
	 	from  #agrupadores AG
	 	inner join saludmp.DIR_AGRUPA_CUPS ac on ac.cod_agrupador = AG.cod_agrupador 
	 	inner join PRESTACIONES PR on PR.prestac = ac.cod_cups      
	 	inner join CONVE_PRESTACIONES CV on CV.nomen = PR.nomen and CV.prestac = ac.cod_cups
	 	inner join CARTI_CONVENIOS CC on CC.conve = CV.conve
	 	inner join PRESTADORES PRE on PRE.prestad = CC.prestad
	 	inner join PRESTAD_LUGARES PL on PL.prestad = PRE.prestad
	 	inner join PARTIDOS PAR on PAR.partido = PL.loca
	 	where PRE.baja_fecha IS NULL    
	 	and ac.estado = 'A'
	 	and par.partido = @ciudad
	 	GROUP BY AG.cod_agrupador,
	 		AG.descripcion,
	 		AG.nivel_auditoria,
	 		AG.tipoAgrupa,
	 		PAR.partido

	 	select a.cod_agrupador, a.descripcion,a.nivel_auditoria,a.tipoAgrupa from #agrupadores2 a;
		
	
		
				
	 	drop table #agrupadores;
	 	drop table #agrupadores2;	
	 END			
GO

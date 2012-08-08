DECLARE @FechaIni	AS DATETIME,
		@FechaFin	AS DATETIME,
		@CodIni		AS VARCHAR(300),
		@CodFin		AS VARCHAR(300),
		@TipoSuscripcion	AS VARCHAR(100),
		@MesIni		AS INT,
		@MesFin		AS INT,
		@Mes 		AS INT,
		@Anyo		AS INT,
		@AnyoAct        AS VARCHAR(4),
		@Campos 	AS VARCHAR(300),
		@Agrupa		AS VARCHAR (300),
		@iInDesign as int

create table #ttSuscripciones
		(
			code varchar(100)
		)

set @iInDesign = 1

if (@iInDesign=1)
	begin
		SET @FechaIni= '01/01/2012 00:00:00'
		SET @FechaFin= '04/30/2012 00:00:00'
		SET @TipoSuscripcion = ''
		SET @CodIni = 'Buen Hogar'
		SET @CodFin = 'Women''s Health'
	end
else
	begin
		/* SELECT FROM [icsv].[DBO].[OINV] T0 */
		SET @FechaIni= /* T0.DocDate */ '[%0]'
		/* SELECT FROM [ICSV].[DBO].[OINV] T0 */
		SET @FechaFin= /* T0.DocDate */ '[%1]'
		/* SELECT FROM [ICSV].[DBO].[@TipoSuscripciones] T1 */
		SET @TipoSuscripcion= /* T1.Code */ '[%2]'
		/* SELECT FROM [icsv].[DBO].[@suscripciones] T2 */
		SET @CodIni = /* T2.Name */ '[%4]'
		/* SELECT FROM [icsv].[DBO].[@suscripciones] T2 */
		SET @CodFin = /* T2.Name */ '[%5]'
	end

if (@TipoSuscripcion='')
	begin
		insert into #ttSuscripciones (code)
					SELECT code FROM [@TipoSuscripciones]
	end
else
	begin
		insert into #ttSuscripciones (code)
					SELECT code FROM [@TipoSuscripciones] T0 where T0.code =@TipoSuscripcion
	end


select Grupo,Factura,Cliente,Nombre,Rubro,[Tipo Suscripción],[Fecha Inicio],[Fecha Fin],[Valor Suscrip.]
from
	(
		SELECT	T5.GroupName AS Grupo,t1.docnum as Factura,T1.CardCode aS Cliente,T1.CardName AS Nombre,
				t4.name as Rubro,t2.u_tipoSuscrip as [Tipo Suscripción],t2.u_desde as [Fecha Inicio],t2.u_hasta as [Fecha Fin],t2.price as [Valor Suscrip.]
		FROM	OINV T1 INNER JOIN INV1 T2 ON T2.DocEntry  = T1.DocEntry
				LEFT  JOIN dbo.[@suscripciones] T4 ON ISNULL(T2.u_rubro,'') = T4.Code
				LEFT JOIN OCRD T3  ON T1.CardCode   = T3.CardCode
				LEFT JOIN OCRG T5 ON T3.GroupCode = T5.GroupCode
		WHERE	T1.DocDate >= @FechaIni
				AND T1.DocDate <= @FechaFin
				AND T5.GroupCode=109 
				AND T4.Name >=@CodIni 
				AND T4.Name <=@CodFin
				and t2.u_tiposuscrip in (select code collate Latin1_General_CI_AI from [#ttSuscripciones])

		union all 

		SELECT	T5.GroupName AS Grupo,t1.docnum,T1.CardCode AS Cliente,T3.CardName AS Nombre,
				t4.name,t2.u_tipoSuscrip,t2.u_desde,t2.u_hasta,t2.price
		FROM    ORIN T1 INNER JOIN RIN1 T2 ON T2.DocEntry  = T1.DocEntry
				LEFT  JOIN dbo.[@suscripciones] T4 ON ISNULL(T2.U_Rubro,'') = T4.Code
				LEFT JOIN OCRD T3  ON T1.CardCode   = T3.CardCode
				LEFT JOIN OCRG T5 ON T3.GroupCode = T5.GroupCode
		WHERE	T1.DocDate >= @FechaIni
				AND T1.DocDate <= @FechaFin
				AND T5.GroupCode = 109
				AND T4.Name >=@CodIni 
				AND T4.Name <=@CodFin
	) Dt0
order by dt0.Factura

---select * from oinv where month(docdate)=4 and year(docdate)=2012 and docnum =110017
---select * from inv1 where docentry = 8977
---select * from [@suscripciones]
---select * from ocrg
---select * from [@TipoSuscripciones]
---select * from inv1 where u_TipoSuscrip is not null
drop table #ttSuscripciones
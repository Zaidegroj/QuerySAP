DECLARE @FechaIni	AS DATETIME
DECLARE @FechaFin	AS DATETIME
DECLARE @CodIni		AS VARCHAR(300)
DECLARE @CodFin		AS VARCHAR(300)
DECLARE @GrupIni	AS VARCHAR(100)
DECLARE @GrupFin	AS VARCHAR(100)
DECLARE @MesIni		AS INT
DECLARE @MesFin		AS INT
DECLARE @Mes 		AS INT
DECLARE @Anyo		AS INT
DECLARE @AnyoAct        AS VARCHAR(4)
DECLARE @Campos 	AS VARCHAR(300)
DECLARE @Agrupa		AS VARCHAR (300),
		@iInDesign as int

set @iInDesign = 1

if (@iInDesign=1)
	begin
		SET @FechaIni= '01/01/2012 00:00:00'
		SET @FechaFin= '04/30/2012 00:00:00'
		SET @GrupIni= 'Acreedores Exterior'
		SET @GrupFin = 'Theatrical'
		SET @CodIni = 'Buen Hogar'
		SET @CodFin = 'Women''s Health'
	end
else
	begin
		/* SELECT FROM [icsv].[DBO].[OINV] T0 */
		SET @FechaIni= /* T0.DocDate */ '[%0]'
		/* SELECT FROM [ICSV].[DBO].[OINV] T0 */
		SET @FechaFin= /* T0.DocDate */ '[%1]'
		/* SELECT FROM [ICSV].[DBO].[OCRG] T1 */
		SET @GrupIni= /* T1.GroupName */ '[%2]'
		/* SELECT FROM [icsv].[DBO].[OCRG] T1 */
		SET @GrupFin = /* T1.GroupName */ '[%3]'
		/* SELECT FROM [icsv].[DBO].[@suscripciones] T2 */
		SET @CodIni = /* T2.Name */ '[%4]'
		/* SELECT FROM [icsv].[DBO].[@suscripciones] T2 */
		SET @CodFin = /* T2.Name */ '[%5]'
	end


select Cliente,Nombre,Rubro,Tipo_Suscripcion,Fecha_Inicio,Fecha_Fin
from
	(
		SELECT	T5.GroupName AS Grupo,t1.docnum as Factura,T1.CardCode aS Cliente,T1.CardName AS Nombre,
				t4.name as Rubro,t2.u_tipoSuscrip as [Tipo_Suscripcion],t2.u_desde as Fecha_Inicio,
				t2.u_hasta as Fecha_Fin,t2.price as [Valor Suscrip.]
		FROM	OINV T1 INNER JOIN INV1 T2 ON T2.DocEntry  = T1.DocEntry
				LEFT  JOIN dbo.[@suscripciones] T4 ON ISNULL(T2.u_rubro,'') = T4.Code
				LEFT JOIN OCRD T3  ON T1.CardCode   = T3.CardCode
				LEFT JOIN OCRG T5 ON T3.GroupCode = T5.GroupCode
		WHERE	T1.DocDate >= @FechaIni
				AND T1.DocDate <= @FechaFin
				AND T4.Name >=@CodIni 
				AND T4.Name <=@CodFin

		union all 

		SELECT	T5.GroupName AS Grupo,t1.docnum,T1.CardCode AS Cliente,T3.CardName AS Nombre,
				t4.name,t2.u_tipoSuscrip,t2.u_desde,t2.u_hasta,t2.price
		FROM    ORIN T1 INNER JOIN RIN1 T2 ON T2.DocEntry  = T1.DocEntry
				LEFT  JOIN dbo.[@suscripciones] T4 ON ISNULL(T2.U_Rubro,'') = T4.Code
				LEFT JOIN OCRD T3  ON T1.CardCode   = T3.CardCode
				LEFT JOIN OCRG T5 ON T3.GroupCode = T5.GroupCode
		WHERE	T1.DocDate >= @FechaIni
				AND T1.DocDate <= @FechaFin
				AND T4.Name >=@CodIni 
				AND T4.Name <=@CodFin
	) Dt0
group by dt0.cliente,dt0.nombre,dt0.rubro,dt0.Tipo_Suscripcion,dt0.fecha_Inicio,dt0.fecha_fin


---select * from oinv where month(docdate)=4 and year(docdate)=2012 and docnum =110017
---select * from inv1 where docentry = 8977
---select * from [@suscripciones]
---select * from [@periodosactivos]
---select * from [@tiposuscripciones]
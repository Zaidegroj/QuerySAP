declare @dFechaIni as datetime,
		@dFechaFin as datetime,
		@sGrupoIni	as varchar(100),
		@sGrupoFin as varchar(100),
		@iInDesign as int


set @iInDesign = 1

if (@iInDesign = 1)
	begin
		set @dFechaIni = '05/01/2011 00:00:00'
		set @dFechaFin = '05/31/2011 00:00:00'
		set @sGrupoIni	= 'ALBUMES Y TARJETAS'
		set @sGrupoFin	= 'VIDEOJUEGOS'

	end
else
	begin
		/* SELECT FROM VMSV.DBO.INV1 T0 */
		SET @dFechaIni = /* T0.DocDate */ '[%0]'
		SET @dFechaFin = /* T0.DocDate */ '[%1]'
		/* SELECT FROM vmsv.dbo.OITB T2 */
		set @sGrupoIni = /* T2.ItmsGrpNam */ '[%2]'
		SET @sGrupoFin = /* T2.ItmsGrpNam */ '[%3]'

	end
		
CREATE TABLE #Tmp_Ven
(
 Grupo     NCHAR(10)     NULL,
 Nombre    NCHAR(36)     NULL,
 ItemCode  nchar(20)     null,
 DescripCode nchar(100)  null,
 Bruto     NUMERIC(19,6) NULL,
 Descuento NUMERIC(19,6) NULL,
 Neto      NUMERIC(19,6) NULL,
 Cantidad  NUMERIC(19,6) NULL,
 PrecioPromedio NUMERIC(19,6) NULL,
 CostoTotal numeric(19,6) null,
 CostoPromedio numeric(19,6) null
)

CREATE TABLE #Tmp_Conso
(
 Grupo     NCHAR(10)     NULL,
 Nombre    NCHAR(36)     NULL, 
 ItemCode  nchar(20)     null,
 DescripCode varchar(100) null,
 Bruto     NUMERIC(19,6) NULL,
 Descuento NUMERIC(19,6) NULL,
 Neto      NUMERIC(19,6) NULL,
 Cantidad  NUMERIC(19,6) NULL,
 PrecioPromedio NUMERIC(19,6) NULL,
 CostoTotal numeric(19,6) null,
 CostoPromedio numeric(19,6) null
)


INSERT INTO #Tmp_Conso
SELECT Grupo,Nombre,ItemCode,DescripCode,SUM(Bruto),SUM(Descuento),SUM(Neto),SUM(Cantidad),SUM(PrecioPromedio),
		sum(CostoTotal) as CostoTotal,sum(CostoPromedio) as CostoPromedio
FROM
	(
		SELECT	T3.ItmsGrpCod                                   AS Grupo    ,
				T4.ItmsGrpNam                                   AS Nombre   ,
                t3.ItemCode										as ItemCode,
				t3.ItemName										as DescripCode,
				SUM(T2.Quantity * T2.PriceBefDi)                AS Bruto    ,
				SUM(T2.Quantity * T2.PriceBefDi - T2.StockSum)  AS Descuento,
				SUM(T2.StockSum)                                AS Neto     ,
				SUM(T2.Quantity)                                AS Cantidad,
				(SUM(T2.StockSum)/ SUM(T2.Quantity))			AS PrecioPromedio,
			    sum(t2.GrossBuyPr*t2.quantity)								as CostoTotal,
				sum(t2.GrossBuyPr*t2.quantity) / sum(t2.Quantity)			as CostoPromedio
		FROM    OINV T1
				INNER JOIN INV1 T2 ON T1.DocEntry   = T2.DocEntry
				LEFT JOIN OITM T3 ON T2.ItemCode   = T3.ItemCode
				LEFT JOIN OITB T4 ON T3.ItmsGrpCod = T4.ItmsGrpCod
				LEFT JOIN OCRD T5 ON T1.CardCode   = T5.CardCode
		WHERE	T1.DocDate   >= @dFechaIni
				AND T1.DocDate   <= @dFechaFin
				AND T1.DocType    = 'I'
				AND T5.GroupCode <> '104' 
		GROUP BY T3.ItmsGrpCod,
				T4.ItmsGrpNam,
                t3.ItemCode,
				t3.ItemName



	) T0 GROUP BY Grupo,Nombre,ItemCode,DescripCode
		ORDER BY Grupo

INSERT INTO #Tmp_Ven
SELECT * FROM #Tmp_Conso
DELETE  FROM #Tmp_Conso


INSERT INTO #Tmp_Conso
SELECT	T3.ItmsGrpCod                                   AS Grupo    ,
		T4.ItmsGrpNam                                   AS Nombre   ,
		t3.ItemCode as itemcode,
		t3.Itemname as DescripCode,
		SUM(T2.Quantity * T2.PriceBefDi)                AS Bruto    ,
		SUM(T2.Quantity * T2.PriceBefDi - T2.StockSum)  AS Descuento,
		SUM(T2.StockSum)                                AS Neto     ,
		SUM(T2.Quantity)                                AS Cantidad ,
		(SUM(T2.StockSum)/ SUM(T2.Quantity))            AS PrecioPromedio,
		sum(t2.GrossBuyPr*t2.quantity)								as CostoTotal,
		sum(t2.GrossBuyPr*t2.quantity) / sum(t2.Quantity)			as CostoPromedio					
FROM	OINV T1
		INNER JOIN INV1 T2 ON T1.DocEntry   = T2.DocEntry
		LEFT JOIN OITM T3 ON T2.ItemCode   = T3.ItemCode
		LEFT JOIN OITB T4 ON T3.ItmsGrpCod = T4.ItmsGrpCod
		LEFT JOIN OCRD T5 ON T1.CardCode   = T5.CardCode
WHERE	T1.DocDate   >= @dFechaIni
		AND T1.DocDate   <= @dFechaFin
		AND T1.DocType    = 'I'
		AND T5.GroupCode  = '104'
GROUP BY T3.ItmsGrpCod,
          T4.ItmsGrpNam,t3.ItemCode,t3.ItemName
ORDER BY T3.ItmsGrpCod

--
INSERT INTO #Tmp_Ven
SELECT * FROM #Tmp_Conso

DELETE  FROM #Tmp_Conso


INSERT INTO #Tmp_Conso

SELECT Grupo,Nombre,ItemCode,DescripCode,SUM(Bruto),SUM(Descuento),SUM(Neto),SUM(Cantidad),SUM(PrecioPromedio) ,
		sum(CostoTotal),sum(CostoPromedio)
FROM
	(

	SELECT	T3.ItmsGrpCod											AS Grupo    ,
			T4.ItmsGrpNam											AS Nombre   ,
			t3.ItemCode as itemcode,
			t3.itemname as DescripCode,
			SUM(T2.Quantity * T2.PriceBefDi)*-1                    AS Bruto    ,
			SUM(T2.Quantity * T2.PriceBefDi - T2.StockSum)*-1      AS Descuento,
			SUM(T2.StockSum)*-1                                    AS Neto     ,
			SUM(T2.Quantity) *-1                                   AS Cantidad,
			(SUM(T2.StockSum)/ SUM(T2.Quantity))*-1				AS PrecioPromedio,
			sum(t2.GrossBuyPr* t2.Quantity) * -1				as CostoTotal,
			sum(t2.GrossBuyPr*t2.quantity) / sum(t2.Quantity)*-1			as CostoPromedio					

	FROM    ORIN T1
			INNER JOIN RIN1 T2 ON T1.DocEntry   = T2.DocEntry
			LEFT JOIN OITM T3 ON T2.ItemCode   = T3.ItemCode
			LEFT JOIN OITB T4 ON T3.ItmsGrpCod = T4.ItmsGrpCod
			LEFT JOIN OCRD T5 ON T1.CardCode   = T5.CardCode
	WHERE	T1.DocDate   >= @dFechaIni
			AND T1.DocDate   <= @dFechaFin
			AND T1.DocType    = 'I'
			AND T5.GroupCode <> '104'
	GROUP BY T3.ItmsGrpCod,
			T4.ItmsGrpNam,t3.ItemCode,t3.ItemName

	) T0 GROUP BY Grupo, Nombre,itemCOde,descripcode
		ORDER BY Grupo



INSERT INTO #Tmp_Ven
SELECT * FROM #Tmp_Conso
DELETE  FROM #Tmp_Conso

INSERT INTO #Tmp_Conso

SELECT T3.ItmsGrpCod                                   AS Grupo    ,
       T4.ItmsGrpNam                                   AS Nombre   ,
		t3.ItemCode as itemcode,
		t3.itemname as DescripCode	,
   SUM(T2.Quantity * T2.PriceBefDi)               * -1 AS Bruto    ,
   SUM(T2.Quantity * T2.PriceBefDi - T2.StockSum) * -1 AS Descuento,
   SUM(T2.StockSum)                               * -1 AS Neto     ,
   SUM(T2.Quantity)                               * -1 AS Cantidad ,
(SUM(T2.StockSum)/ SUM(T2.Quantity))      		AS PrecioPromedio,
		sum(t2.GrossBuyPr*t2.quantity)	 * -1					as CostoTotal,
		sum(t2.GrossBuyPr*t2.quantity) / sum(t2.Quantity) * -1		as CostoPromedio					

  FROM      ORIN T1
 INNER JOIN RIN1 T2 ON T1.DocEntry   = T2.DocEntry
  LEFT JOIN OITM T3 ON T2.ItemCode   = T3.ItemCode
  LEFT JOIN OITB T4 ON T3.ItmsGrpCod = T4.ItmsGrpCod
  LEFT JOIN OCRD T5 ON T1.CardCode   = T5.CardCode
 WHERE T1.DocDate   >= @dFechaIni
   AND T1.DocDate   <= @dFechaFin
   AND T1.DocType    = 'I'
   AND T5.GroupCode  = '104'
 GROUP BY T3.ItmsGrpCod,
          T4.ItmsGrpNam,t3.ItemCode,t3.ItemName
 ORDER BY T3.ItmsGrpCod

INSERT INTO #Tmp_Ven
SELECT * FROM #Tmp_Conso
DELETE  FROM #Tmp_Conso

SELECT Grupo,nombre as Nombre,ItemCode,DescripCode as Descripcion,sum(Bruto) as Bruto,sum(Descuento) as Descuento,sum(Neto) as Neto,
		sum(Cantidad) as Cantidad,sum(PrecioPromedio) as PrecioPromedio,sum(CostoTotal) as CostoTotal,
	   sum(costopromedio) as CostoPromedio
FROM #Tmp_Ven
group by grupo,nombre,itemcode,descripcode
HAVING	Nombre >= @sGrupoIni and nombre <=@sGrupoFin 
order by  Grupo,ItemCode


DROP TABLE #Tmp_Ven
DROP TABLE #Tmp_Conso
--select * from oitm where itmsGrpCod = '100'
--select * from oitb
/*
select * from inv1 
*/
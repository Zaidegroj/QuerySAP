
declare @dFechaIni as datetime,
		@dFechaFin as datetime,
		@sGrupoIni	as varchar(100),
		@sGrupoFin as varchar(100),
		@iInDesign as int

set @iInDesign = 1

if (@iInDesign = 1)
	begin
		set @dFechaIni = '07/01/2011 00:00:00'
		set @dFechaFin = '08/31/2011 00:00:00'
		set @sGrupoIni	= 'ALBUMES Y TARJETAS'
		set @sGrupoFin	= 'VIDEOJEGOS'
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
 Neto      NUMERIC(19,6) NULL,
 Cantidad  NUMERIC(19,6) NULL,
 PrecioPromedio NUMERIC(19,6) NULL, 
 DevCant numeric (19,6) null,
 DevValor numeric (19,6) null,
 AfilCant numeric (19,6) null,
 AfilValor numeric(19,6) null,
 AfilDevCant numeric(19,6) null,
 AfilDevValor numeric(19,6) null,
 CostoTotal numeric(19,6) null,
 CostoPromedio numeric(19,6) null
)

CREATE TABLE #Tmp_Conso
(
 Grupo     NCHAR(10)     NULL,
 Nombre    NCHAR(36)     NULL, 
 ItemCode  nchar(20)     null,
 DescripCode varchar(100) null,
 Neto      NUMERIC(19,6) NULL,
 Cantidad  NUMERIC(19,6) NULL,
 PrecioPromedio NUMERIC(19,6) NULL,
 DevCant numeric(19,6) null,
 DevValor numeric(19,6) null,
 AfilCant numeric(19,6) null,
 AfilValor numeric(19,6) null,
 AfilDevCant numeric(19,6) null,
 AfilDevValor numeric(19,6) null,
 CostoTotal numeric(19,6) null,
 CostoPromedio numeric(19,6) null
)


INSERT INTO #Tmp_Conso
SELECT Grupo,
		Nombre,
		ItemCode,
		DescripCode,
		SUM(Neto),
		SUM(Cantidad),
		SUM(PrecioPromedio),
		sum(DevCant) as DevCant,
		sum(DevValor) as DevValor,
		sum(AfilCant) as AfilCant,
		sum(AfilValor) as AfilValor,
        sum(AfilDevCant) as AfilDevCant,
	    sum(AfilDevValor) as AfilDevValor,
		sum(CostoTotal) as CostoTotal,
		sum(CostoPromedio) as CostoPromedio
FROM
	(
		SELECT	T3.ItmsGrpCod                                   AS Grupo    ,
				T4.ItmsGrpNam                                   AS Nombre   ,
                t3.ItemCode										as ItemCode,
				t3.ItemName										as DescripCode,
				SUM(T2.StockSum)                                AS Neto     ,
				SUM(T2.Quantity)                                AS Cantidad,
				(SUM(T2.StockSum)/ SUM(T2.Quantity))			AS PrecioPromedio,
                 0 as DevCant,
				 0 as DevValor,
				 0 as AfilCant,
				 0 as AfilValor,
                 0 as AfilDevCant,
				0 as AfilDevValor,
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


-- Afiliadas

INSERT INTO #Tmp_Conso
SELECT	T3.ItmsGrpCod                                   AS Grupo    ,
		T4.ItmsGrpNam                                   AS Nombre   ,
		t3.ItemCode as itemcode,
		t3.Itemname as DescripCode,
		0                                AS Neto     ,
		0                                AS Cantidad ,
		(SUM(T2.StockSum)/ SUM(T2.Quantity))            AS PrecioPromedio,
        0 as DevCant, 
		0 as DevValor,
		sum(t2.quantity) as AfilCant,
		sum(t2.stocksum) as AfilValor,
		0 as AfilDevCant,
		0 as AfilDevValor,
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

---

INSERT INTO #Tmp_Ven
SELECT * FROM #Tmp_Conso
DELETE  FROM #Tmp_Conso
--

--Devoluciones Clientes

INSERT INTO #Tmp_Conso
SELECT Grupo,
		Nombre,
		ItemCode,
		DescripCode,
		SUM(Neto),
		SUM(Cantidad),
		SUM(PrecioPromedio) ,
		sum(DevCant) as DevCant,
		sum(DevValor) as DevValor,
		sum(AfilCant) as AfilCant,
		sum(AfilValor) as AfilValor,
		sum(AfilDevCant) as AfilDevCant,
		sum(AfilDevValor) as AfilDevValor,
		sum(CostoTotal),sum(CostoPromedio)
FROM
	(

	SELECT	T3.ItmsGrpCod											AS Grupo    ,
			T4.ItmsGrpNam											AS Nombre   ,
			t3.ItemCode as itemcode,
			t3.itemname as DescripCode,
			0                                   AS Neto     ,
			0                                   AS Cantidad,
			(SUM(T2.StockSum)/ SUM(T2.Quantity))*-1				AS PrecioPromedio,
			SUM(T2.Quantity) *-1                                   AS DevCant,
			SUM(T2.StockSum)*-1 as					DevValor,
			0 as AfilCant, 
			0 as AfilValor,
			0 as AfilDevCant,
			0 as afilDevValor,
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

-- Devoluciones Afiliadas

INSERT INTO #Tmp_Conso
SELECT T3.ItmsGrpCod                                   AS Grupo    ,
       T4.ItmsGrpNam                                   AS Nombre   ,
		t3.ItemCode as itemcode,
		t3.itemname,
   0                               * -1 AS Neto     ,
   0                               * -1 AS Cantidad ,
(SUM(T2.StockSum)/ SUM(T2.Quantity))      		AS PrecioPromedio,
   0 as DevCant,
	0 as DevValor,
	0 as AfilCant,
    0 as AfilValor,
SUM(T2.Quantity)                               * -1 AS AfilDevCant ,
	SUM(T2.StockSum)               * -1 AS AfilDevValor    ,
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

INSERT INTO #Tmp_Ven
SELECT * FROM #Tmp_Conso
DELETE  FROM #Tmp_Conso

---

SELECT Grupo,
		nombre as Nombre,
		ItemCode,
		DescripCode as Descripcion,
		sum(Neto) as [Venta Cliente],
		sum(Cantidad) as [Cant. Cliente],
		sum(PrecioPromedio) as PrecioPromedio,
		sum(DevCant) as [Dev. Cant. Cliente],
		sum(DevValor) as [Dev. Valor Cliente],
		sum(AfilCant) as [Cant. Afiliada],
		sum(AfilValor) as [Valor Afiliada],
        sum(AfilDevCant) as [Dev. Cant. Afiliada],
		sum(AfilDevValor) as [Dev. Valor Afiliada],
		sum(cantidad)+sum(DevCant*-1)+ sum(AfilCant)+sum(AfilDevCant*-1) as [Cant. Neta],
		sum(neto) + sum(devValor*-1) +sum(AfilDevValor*-1) as [Valor Neto],
		sum(CostoTotal) as [Costo Total],
		sum(costopromedio) as [Costo Promedio]
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

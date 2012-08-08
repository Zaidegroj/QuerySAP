declare @dFechaIni as datetime,
		@dFechaFin as datetime,
		@nTc as numeric(10,2),
		@iInDesign as int


set @iInDesign = 1

if (@iInDesign = 1)
	begin
		set @dFechaIni = '03/01/2011 00:00:00'
		set @dFechaFin = '03/31/2011 00:00:00'
		set @nTc		= 8.03
	end
else
	begin
		/* SELECT FROM VMSV.DBO.INV1 T0 */
		SET @dFechaIni = /* T0.DocDate */ '[%0]'
		SET @dFechaFin = /* T0.DocDate */ '[%1]'
		/* select Rate from ortt T1*/
		set @nTc = /* t1.rate */ '[%2]'
	end
		
CREATE TABLE #Tmp_Ven

(Grupo     NCHAR(10)     NULL,
 Nombre    NCHAR(36)     NULL,
 Bruto     NUMERIC(19,6) NULL,
 Descuento NUMERIC(19,6) NULL,
 Neto      NUMERIC(19,6) NULL,
 Cantidad  NUMERIC(19,6) NULL,
PrecioPromedio NUMERIC(19,6) NULL)

CREATE TABLE #Tmp_Conso

(Grupo     NCHAR(10)     NULL,
 Nombre    NCHAR(36)     NULL,
 Bruto     NUMERIC(19,6) NULL,
 Descuento NUMERIC(19,6) NULL,
 Neto      NUMERIC(19,6) NULL,
 Cantidad  NUMERIC(19,6) NULL,
PrecioPromedio NUMERIC(19,6) NULL)


INSERT INTO #Tmp_Ven (Grupo, Nombre) VALUES (' ', '--VENTA CLIENTES--                  ')

INSERT INTO #Tmp_Conso
SELECT Grupo,Nombre,Round(SUM(Bruto)/@nTc,2),round(SUM(Descuento)/@nTc,2),Round(SUM(Neto)/@nTc,2),SUM(Cantidad),
		Round(SUM(PrecioPromedio)/@nTc,2) 
FROM
	(
		SELECT	T3.ItmsGrpCod                                   AS Grupo    ,
				T4.ItmsGrpNam                                   AS Nombre   ,
				SUM(T2.Quantity * T2.PriceBefDi)                    AS Bruto    ,
				SUM(T2.Quantity * T2.PriceBefDi - T2.StockSum)      AS Descuento,
				SUM(T2.StockSum)                                    AS Neto     ,
				SUM(T2.Quantity)                                    AS Cantidad,
				(SUM(T2.StockSum)/ SUM(T2.Quantity))      AS PrecioPromedio
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
				T4.ItmsGrpNam


		UNION ALL
		/*NOTAS DE DEBITO SOLO DE LOS CLIENTES DE ARTICULOS*/
		SELECT	'100'                                         AS Grupo    ,
				'DVD DISNEY'                                  AS Nombre   ,
				(T1.Max1099 - T1.VatSum + T1.DiscSum)            AS Bruto    ,
				(T1.DiscSum)                                     AS Descuento,
				(T1.Max1099 - T1.VatSum)                         AS Neto     ,
				0                                               AS Cantidad ,
				0      					       AS PrecioPromedio
		FROM	OINV T1
				LEFT JOIN OCRD T5 ON T1.CardCode   = T5.CardCode
		WHERE	T1.DocDate   >= @dFechaIni
				AND T1.DocDate   <= @dFechaFin
				AND T1.DocType    = 'S'
				AND T5.GroupCode <> '104' 
				AND T1.U_FacSerie LIKE 'ND'


	) T0 GROUP BY Grupo,Nombre
		ORDER BY Grupo


INSERT INTO #Tmp_Conso
SELECT ' '                                             AS Grupo    ,
       'POR SERVICIO'                                  AS Nombre   ,
		SUM(T1.Max1099 - T1.VatSum + T1.DiscSum)            AS Bruto    ,
		SUM(T1.DiscSum)                                     AS Descuento,
		SUM(T1.Max1099 - T1.VatSum)                         AS Neto     ,
		0                                               AS Cantidad ,
		0      					       AS PrecioPromedio
FROM    OINV T1
		LEFT JOIN OCRD T5 ON T1.CardCode   = T5.CardCode
WHERE	T1.DocDate   >= @dFechaIni
		AND T1.DocDate   <= @dFechaFin
		AND T1.DocType    = 'S'
		AND T5.GroupCode <> '104' and t5.GroupCode <> 107
		AND T1.U_FacSerie NOT LIKE 'ND' 

-- Ventas Theatrical
INSERT INTO #Tmp_Conso
SELECT ' '                                             AS Grupo    ,
       'THEATRICAL'                                  AS Nombre   ,
		SUM(T1.Max1099 - T1.VatSum + T1.DiscSum)            AS Bruto    ,
		SUM(T1.DiscSum)                                     AS Descuento,
		SUM(T1.Max1099 - T1.VatSum)                         AS Neto     ,
		0                                               AS Cantidad ,
		0      					       AS PrecioPromedio
FROM    OINV T1
		LEFT JOIN OCRD T5 ON T1.CardCode   = T5.CardCode
WHERE	T1.DocDate   >= @dFechaIni
		AND T1.DocDate   <= @dFechaFin
		AND T1.DocType    = 'S'
		AND T5.GroupCode = 107
		AND T1.U_FacSerie NOT LIKE 'ND'


INSERT INTO #Tmp_Ven
SELECT * FROM #Tmp_Conso
INSERT INTO #Tmp_Ven
SELECT	' '           AS Grupo  ,
		'---TOTALES ...' AS Nombre ,
		SUM(Bruto     ),
		SUM (Descuento ),
		SUM(Neto      ),
		SUM(Cantidad  ),
		0 		AS PrecioPromedio
FROM #Tmp_Conso

DELETE  FROM #Tmp_Conso

INSERT INTO #Tmp_Ven (Grupo)         VALUES (' ')
INSERT INTO #Tmp_Ven (Grupo, Nombre) VALUES (' ', '--VENTA AFILIADAS--                 ')

INSERT INTO #Tmp_Conso
SELECT	T3.ItmsGrpCod                                   AS Grupo    ,
		T4.ItmsGrpNam                                   AS Nombre   ,
		SUM(T2.Quantity * T2.PriceBefDi)                    AS Bruto    ,
		SUM(T2.Quantity * T2.PriceBefDi - T2.StockSum)      AS Descuento,
		SUM(T2.StockSum)                                    AS Neto     ,
		SUM(T2.Quantity)                                    AS Cantidad ,
		(SUM(T2.StockSum)/ SUM(T2.Quantity))                 AS PrecioPromedio
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
          T4.ItmsGrpNam
ORDER BY T3.ItmsGrpCod

INSERT INTO #Tmp_Conso
SELECT	' '                                             AS Grupo    ,
		'POR SERVICIO'                                  AS Nombre   ,
		SUM(T1.Max1099 - T1.VatSum + T1.DiscSum)            AS Bruto    ,
		SUM(T1.DiscSum)                                     AS Descuento,
		SUM(T1.Max1099 - T1.VatSum)                         AS Neto     ,
		0													AS Cantidad ,
		0     												AS PrecioPromedio
FROM   OINV T1
		LEFT JOIN OCRD T5 ON T1.CardCode   = T5.CardCode
WHERE T1.DocDate   >= @dFechaIni
		AND T1.DocDate   <= @dFechaFin
		AND T1.DocType    = 'S'
		AND T5.GroupCode  = '104'

INSERT INTO #Tmp_Ven
SELECT * FROM #Tmp_Conso

INSERT INTO #Tmp_Ven
SELECT	
	' '           AS Grupo  ,
       '---TOTALES ...' AS Nombre ,
	SUM(Bruto     ),
	SUM (Descuento ),
	SUM(Neto      ),
	SUM(Cantidad  ),
	0 		AS PrecioPromedio
FROM #Tmp_Conso

DELETE  FROM #Tmp_Conso


INSERT INTO #Tmp_Ven (Grupo)         VALUES (' ')
INSERT INTO #Tmp_Ven (Grupo, Nombre) VALUES (' ', '--DEVOLUCION CLIENTES--             ')

INSERT INTO #Tmp_Conso

SELECT Grupo,Nombre,SUM(Bruto),SUM(Descuento),SUM(Neto),SUM(Cantidad),SUM(PrecioPromedio) 
FROM
	(

	SELECT	T3.ItmsGrpCod                                   AS Grupo    ,
			T4.ItmsGrpNam                                   AS Nombre   ,
			SUM(T2.Quantity * T2.PriceBefDi)*-1                    AS Bruto    ,
			SUM(T2.Quantity * T2.PriceBefDi - T2.StockSum)*-1      AS Descuento,
			SUM(T2.StockSum)*-1                                    AS Neto     ,
			SUM(T2.Quantity) *-1                                   AS Cantidad,
			(SUM(T2.StockSum)/ SUM(T2.Quantity))*-1      AS PrecioPromedio
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
			T4.ItmsGrpNam

	UNION ALL
	/*NOTAS DE CREDITO EN VALORES SOLO DE LOS CLIENTES DE ARTICULOS*/

	SELECT	'100'                                             AS Grupo    ,
			'DVD DISNEY'                                  AS Nombre   ,
			(T1.Max1099 - T1.VatSum + T1.DiscSum)*-1           AS Bruto    ,
			(T1.DiscSum) *-1                                    AS Descuento,
			(T1.Max1099 - T1.VatSum) *-1                        AS Neto     ,
			0                                               AS Cantidad ,
			0      					       AS PrecioPromedio
	FROM    ORIN T1
			LEFT JOIN OCRD T5 ON T1.CardCode   = T5.CardCode
	WHERE	T1.DocDate   >= @dFechaIni
			AND T1.DocDate   <= @dFechaFin
			AND T1.DocType    = 'S'
			AND T5.GroupCode <> '104' 
	/*AND T1.Comments LIKE 'DVD DISNEY%'*/


	) T0 GROUP BY Grupo, Nombre
		ORDER BY Grupo


INSERT INTO #Tmp_Conso
SELECT	' '                                             AS Grupo    ,
		'POR SERVICIO'                                  AS Nombre   ,
		SUM(T1.Max1099 - T1.VatSum + T1.DiscSum) *-1           AS Bruto    ,
		SUM(T1.DiscSum)  *-1                                   AS Descuento,
		SUM(T1.Max1099 - T1.VatSum)  *-1                       AS Neto     ,
		0                                               AS Cantidad ,
		0      					       AS PrecioPromedio
FROM	ORIN T1
		LEFT JOIN OCRD T5 ON T1.CardCode   = T5.CardCode
WHERE T1.DocDate   >= @dFechaIni
		AND T1.DocDate   <= @dFechaFin
		AND T1.DocType    = 'S'
		AND T5.GroupCode = '104' 

INSERT INTO #Tmp_Ven
SELECT * FROM #Tmp_Conso
INSERT INTO #Tmp_Ven
SELECT		' '           AS Grupo  ,
       '---TOTALES ...' AS Nombre ,
	SUM(Bruto     ),
	SUM (Descuento ),
	SUM(Neto      ),
	SUM(Cantidad  ),
	0 		AS PrecioPromedio
FROM #Tmp_Conso
DELETE  FROM #Tmp_Conso



INSERT INTO #Tmp_Ven (Grupo)         VALUES (' ')
INSERT INTO #Tmp_Ven (Grupo, Nombre) VALUES (' ', '--DEVOLUCION AFILIADAS--            ')

INSERT INTO #Tmp_Conso

SELECT T3.ItmsGrpCod                                   AS Grupo    ,
       T4.ItmsGrpNam                                   AS Nombre   ,
   SUM(T2.Quantity * T2.PriceBefDi)               * -1 AS Bruto    ,
   SUM(T2.Quantity * T2.PriceBefDi - T2.StockSum) * -1 AS Descuento,
   SUM(T2.StockSum)                               * -1 AS Neto     ,
   SUM(T2.Quantity)                               * -1 AS Cantidad ,
(SUM(T2.StockSum)/ SUM(T2.Quantity))      		AS PrecioPromedio
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
          T4.ItmsGrpNam
 ORDER BY T3.ItmsGrpCod

INSERT INTO #Tmp_Conso

SELECT ' '                                             AS Grupo    ,
       'POR SERVICIO'                                  AS Nombre   ,
   SUM(T1.Max1099 - T1.VatSum + T1.DiscSum)       * -1 AS Bruto    ,
   SUM(T1.DiscSum)                                * -1 AS Descuento,
   SUM(T1.Max1099 - T1.VatSum)                    * -1 AS Neto     ,
       0                                               AS Cantidad ,
	0      					AS PrecioPromedio
  FROM      ORIN T1
  LEFT JOIN OCRD T5 ON T1.CardCode   = T5.CardCode
 WHERE T1.DocDate   >= @dFechaIni
   AND T1.DocDate   <= @dFechaFin
   AND T1.DocType    = 'S'
   AND T5.GroupCode  = '104'

INSERT INTO #Tmp_Ven
SELECT * FROM #Tmp_Conso
INSERT INTO #Tmp_Ven
SELECT
	' '           AS Grupo  ,
       '---TOTALES ...' AS Nombre ,
	SUM(Bruto     ),
	SUM (Descuento ),
	SUM(Neto      ),
	SUM(Cantidad  ),
	0 		AS PrecioPromedio
FROM #Tmp_Conso
DELETE  FROM #Tmp_Conso

INSERT INTO #Tmp_Ven (Grupo)         VALUES (' ')
INSERT INTO #Tmp_Ven (Grupo, Nombre) VALUES (' ', '--VENTA POR TIPO DE DOCUMENTO--     ')

INSERT INTO #Tmp_Ven

SELECT T1.Series                                       AS Grupo    ,
       T2.SeriesName                                   AS Nombre   ,
   SUM(T1.Max1099 - T1.VatSum + T1.DiscSum)            AS Bruto    ,
   SUM(T1.DiscSum)                                     AS Descuento,
   SUM(T1.Max1099 - T1.VatSum)                         AS Neto     ,
       0                                               AS Cantidad,
	0      						AS PrecioPromedio
  FROM      OINV T1
  LEFT JOIN NNM1 T2 ON T1.Series     = T2.Series
 WHERE T1.DocDate  >= @dFechaIni
   AND T1.DocDate  <= @dFechaFin
 GROUP BY T1.Series,
          T2.SeriesName
 ORDER BY T1.Series

INSERT INTO #Tmp_Ven (Grupo)         VALUES (' ')
INSERT INTO #Tmp_Ven (Grupo, Nombre) VALUES (' ', '--DEVOLUCION POR TIPO DE DOCUMENTO--')

INSERT INTO #Tmp_Ven

SELECT T1.Series                                       AS Grupo    ,
       T2.SeriesName                                   AS Nombre   ,
   SUM(T1.Max1099 - T1.VatSum + T1.DiscSum)       * -1 AS Bruto    ,
   SUM(T1.DiscSum)                                * -1 AS Descuento,
   SUM(T1.Max1099 - T1.VatSum)                    * -1 AS Neto     ,
       0                                               AS Cantidad,
	0     						 AS PrecioPromedio
  FROM      ORIN T1
  LEFT JOIN NNM1 T2 ON T1.Series     = T2.Series
 WHERE T1.DocDate  >= @dFechaIni
   AND T1.DocDate  <= @dFechaFin
 GROUP BY T1.Series,
          T2.SeriesName
 ORDER BY T1.Series

SELECT * FROM #Tmp_Ven

DROP TABLE #Tmp_Ven
DROP TABLE #Tmp_Conso
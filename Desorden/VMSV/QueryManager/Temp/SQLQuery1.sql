declare @dFechaIni as datetime,
		@dFechaFin as datetime,
		@iInDesign as int


set @iInDesign = 1

if (@iInDesign = 1) 
	begin
		set @dFechaIni = '01/01/2012 00:00:00'
		set @dFechaFin = '05/31/2012 00:00:00'
	end
else
	begin
		/* SELECT FROM VMSV.DBO.INV1 T0 */
		SET @dFechaIni = /* T0.DocDate */ '[%0]'
		SET @dFechaFin = /* T0.DocDate */ '[%1]'
	end
		

SELECT	
		--T3.ItmsGrpCod                                   AS Grupo    ,
		--T4.ItmsGrpNam                                   AS Nombre   ,
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
		AND (T5.GroupCode <>104)
--GROUP BY T3.ItmsGrpCod,
--		T4.ItmsGrpNam

union all 


	SELECT	
			--T3.ItmsGrpCod                                   AS Grupo    ,
			--T4.ItmsGrpNam                                   AS Nombre   ,
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
			AND (T5.GroupCode <>104)
--	GROUP BY T3.ItmsGrpCod,
--			T4.ItmsGrpNam


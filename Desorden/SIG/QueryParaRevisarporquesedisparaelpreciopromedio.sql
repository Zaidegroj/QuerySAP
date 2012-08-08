DECLARE @GT AS NUMERIC(19,4),
		@CR AS NUMERIC(19,4),
		@DO AS NUMERIC(19,4),
		@HN AS NUMERIC(19,4),
		@fecha1 as datetime,
		@fecha2 as datetime,
		@iInDesign as int

		set @Fecha1 = '01/03/2011 00:00:00'
		set @Fecha2 = '03/31/2011 00:00:00'



		/* Honduras */
		/* Unidades vendidas como paquete */

--		SELECT GRUPO,NOMBRE+' '+' PAQUETES ', 0 as GT,0 as sv,SUM(VENTA)/SUM(CANT) AS hn,0 AS CR,0 AS PA, 0 AS DO 
--		FROM
--			(
				SELECT	t1.docentry,t1.docnum,
						T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						(T0.StockSum)   	AS VENTA,
						(T0.Quantity)	AS CANT
				FROM    prhn.dbo.INV1 T0
						INNER JOIN prhn.dbo.OINV T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN prhn.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN prhn.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN prhn.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 
						AND T4.GroupCode<>104
						AND T1.DocType    = 'I'
						AND T0.ItemCode IN (SELECT T5.U_Codigo FROM prhn.dbo.[@PAQUETES] T5)
--				GROUP	BY T2.ItmsGrpCod, T3.ItmsGrpNam

--				UNION ALL
	
				SELECT  T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						SUM(T0.StockSum)*-1   	AS VENTA,
						SUM(T0.Quantity)*-1	AS CANT    
				FROM    prhn.dbo.RIN1 T0
						INNER JOIN prhn.dbo.ORIN T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN prhn.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN prhn.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN prhn.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 AND   T4.GroupCode<>104
						AND T1.DocType    = 'I'
						AND T0.ItemCode IN (SELECT T5.U_Codigo FROM prhn.dbo.[@PAQUETES] T5)
				GROUP BY T2.ItmsGrpCod,T3.ItmsGrpNam
--			) T0 GROUP BY GRUPO,NOMBRE HAVING GRUPO IS NOT NULL AND SUM(CANT)<>0

---select * from oinv
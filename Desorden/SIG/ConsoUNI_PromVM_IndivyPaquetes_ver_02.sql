set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go



ALTER PROCEDURE [dbo].[ConsoUNI_PROMVM_IndivyPaquetes_Test2]

@fecha1 AS DATETIME,
@fecha2 AS DATETIME,
@GT	AS NUMERIC (19,4),
@HN	AS NUMERIC (19,4),
@CR	AS NUMERIC (19,4),
@DO	AS NUMERIC (19,4)

AS

INSERT INTO  #Conso_VTAVIDEOMARK
	SELECT	grupo,NOMBRE,SUM(GT)/@GT,SUM(SV),SUM(HN)/@HN,SUM(CR)/@CR,SUM(PA),SUM(DO)/@DO,
			AVG(GT/@GT + SV + HN/@HN + CR/@CR + PA + DO/@DO) AS TOTAL  
	FROM (
			/* GuatePior */
			/* Unidades Vendidas sin Paquetes */
			SELECT null as grupo,NOMBRE, SUM(VENTA)/SUM(CANT) AS GT,0 AS SV,0 AS HN,0 AS CR,0 AS PA, 0 AS DO 
			FROM
				(
					SELECT	T2.ItmsGrpCod		AS GRUPO,
							T3.ItmsGrpNam		AS NOMBRE,
   							SUM(T0.StockSum)   	AS VENTA,
							SUM(T0.Quantity)	AS CANT
					FROM    prgt.dbo.INV1 T0
							INNER JOIN prgt.dbo.OINV T1 ON T0.DocEntry   = T1.DocEntry
							LEFT JOIN prgt.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
							LEFT JOIN prgt.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
							INNER JOIN prgt.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
					WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 
							AND T4.GroupCode<>104
							AND T1.DocType    = 'I'
							AND T0.ItemCode NOT IN (SELECT T5.U_Codigo FROM prgt.dbo.[@PAQUETES] T5)
					GROUP	BY T2.ItmsGrpCod, T3.ItmsGrpNam

					UNION ALL
	
					SELECT  T2.ItmsGrpCod		AS GRUPO,
							T3.ItmsGrpNam		AS NOMBRE,
   							SUM(T0.StockSum)*-1   	AS VENTA,
							SUM(T0.Quantity)*-1	AS CANT    
					FROM    prgt.dbo.RIN1 T0
							INNER JOIN prgt.dbo.ORIN T1 ON T0.DocEntry   = T1.DocEntry
							LEFT JOIN prgt.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
							LEFT JOIN prgt.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
							INNER JOIN prgt.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
					WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 AND   T4.GroupCode<>104
							AND T1.DocType    = 'I'
							AND T0.ItemCode NOT IN (SELECT T5.U_Codigo FROM prgt.dbo.[@PAQUETES] T5)
					GROUP BY T2.ItmsGrpCod,T3.ItmsGrpNam
				) T0 GROUP BY GRUPO,NOMBRE HAVING GRUPO IS NOT NULL AND SUM(CANT)<>0

		UNION ALL

		/* Guatepior */
		/* Unidades Vendidas como paquetes */

		SELECT null as grupo,NOMBRE+' '+' PAQUETES ', SUM(VENTA)/SUM(CANT) AS GT,0 AS SV,0 AS HN,0 AS CR,0 AS PA, 0 AS DO 
		FROM
			(
				SELECT	T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						SUM(T0.StockSum)   	AS VENTA,
						SUM(T0.Quantity)	AS CANT
				FROM    prgt.dbo.INV1 T0
						INNER JOIN prgt.dbo.OINV T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN prgt.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN prgt.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN prgt.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 
						AND T4.GroupCode<>104
						AND T1.DocType    = 'I'
						AND T0.ItemCode IN (SELECT T5.U_Codigo FROM prgt.dbo.[@PAQUETES] T5)
				GROUP	BY T2.ItmsGrpCod, T3.ItmsGrpNam

				UNION ALL
	
				SELECT  T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						SUM(T0.StockSum)*-1   	AS VENTA,
						SUM(T0.Quantity)*-1	AS CANT    
				FROM    prgt.dbo.RIN1 T0
						INNER JOIN prgt.dbo.ORIN T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN prgt.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN prgt.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN prgt.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 AND   T4.GroupCode<>104
						AND T1.DocType    = 'I'
						AND T0.ItemCode IN (SELECT T5.U_Codigo FROM prgt.dbo.[@PAQUETES] T5)
				GROUP BY T2.ItmsGrpCod,T3.ItmsGrpNam
			) T0 GROUP BY GRUPO,NOMBRE HAVING GRUPO IS NOT NULL AND SUM(CANT)<>0

			/*EL SALVADOR*/
			/* Unidades vendidas individualmente */

		union all 

		SELECT null as grupo,NOMBRE,0 AS GT, SUM(VENTA)/SUM(CANT) AS SV,0 AS HN,0 AS CR,0 AS PA, 0 AS DO 
		FROM
			(
				SELECT	T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						SUM(T0.StockSum)   	AS VENTA,
						SUM(T0.Quantity)	AS CANT
				FROM	vmsv.dbo.INV1 T0
						INNER JOIN vmsv.dbo.OINV T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN vmsv.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN vmsv.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN vmsv.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 
						AND T4.GroupCode<>104
						AND T1.DocType    = 'I'
						AND T0.ItemCode NOT IN (SELECT T5.U_Codigo FROM vmsv.dbo.[@PAQUETES] T5)
				GROUP	BY T2.ItmsGrpCod, T3.ItmsGrpNam

				UNION ALL

				SELECT  T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						SUM(T0.StockSum)*-1   	AS VENTA,
						SUM(T0.Quantity)*-1	AS CANT
				FROM    vmsv.dbo.RIN1 T0
						INNER JOIN vmsv.dbo.ORIN T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN vmsv.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN vmsv.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN vmsv.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 AND   T4.GroupCode<>104
						AND T1.DocType    = 'I'
						AND T0.ItemCode NOT IN (SELECT T5.U_Codigo FROM vmsv.dbo.[@PAQUETES] T5)
				GROUP	BY T2.ItmsGrpCod,T3.ItmsGrpNam
			) T0 GROUP BY GRUPO,NOMBRE HAVING GRUPO IS NOT NULL  AND SUM(CANT)<>0

		UNION ALL

		/* El Salvador */
		/* Unidades Vendidas como paquetes */

		SELECT null as grupo,NOMBRE+' '+' PAQUETES ', 0 as GT,SUM(VENTA)/SUM(CANT) AS SV,0 AS HN,0 AS CR,0 AS PA, 0 AS DO 
		FROM
			(
				SELECT	T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						SUM(T0.StockSum)   	AS VENTA,
						SUM(T0.Quantity)	AS CANT
				FROM    vmsv.dbo.INV1 T0
						INNER JOIN vmsv.dbo.OINV T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN vmsv.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN vmsv.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN vmsv.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 
						AND T4.GroupCode<>104
						AND T1.DocType    = 'I'
						AND T0.ItemCode IN (SELECT T5.U_Codigo FROM vmsv.dbo.[@PAQUETES] T5)
				GROUP	BY T2.ItmsGrpCod, T3.ItmsGrpNam

				UNION ALL
	
				SELECT  T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						SUM(T0.StockSum)*-1   	AS VENTA,
						SUM(T0.Quantity)*-1	AS CANT    
				FROM    vmsv.dbo.RIN1 T0
						INNER JOIN vmsv.dbo.ORIN T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN vmsv.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN vmsv.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN vmsv.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 AND   T4.GroupCode<>104
						AND T1.DocType    = 'I'
						AND T0.ItemCode IN (SELECT T5.U_Codigo FROM vmsv.dbo.[@PAQUETES] T5)
				GROUP BY T2.ItmsGrpCod,T3.ItmsGrpNam
			) T0 GROUP BY GRUPO,NOMBRE HAVING GRUPO IS NOT NULL AND SUM(CANT)<>0

		union all
	
		/* HONDURAS */
		/* Unidades Vendidas Individualmente */

		SELECT null as grupo,NOMBRE,0 AS GT, 0 AS SV,SUM(VENTA)/SUM(CANT) AS HN,0 AS CR,0 AS PA, 0 AS DO 
		FROM
			(
				SELECT	T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						SUM(T0.StockSum)   	AS VENTA,
						SUM(T0.Quantity)	AS CANT
				FROM    prhn.dbo.INV1 T0
						INNER JOIN prhn.dbo.OINV T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN prhn.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN prhn.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN prhn.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 
						AND T4.GroupCode<>104
						AND T1.DocType    = 'I'
						AND T0.ItemCode NOT IN (SELECT T5.U_Codigo FROM prhn.dbo.[@PAQUETES] T5)
				GROUP BY T2.ItmsGrpCod, T3.ItmsGrpNam

				UNION ALL

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
						AND T0.ItemCode NOT IN (SELECT T5.U_Codigo FROM prhn.dbo.[@PAQUETES] T5)
				GROUP BY T2.ItmsGrpCod,T3.ItmsGrpNam

			) T0 GROUP BY GRUPO,NOMBRE HAVING GRUPO IS NOT NULL  AND SUM(CANT)<>0

		union all 

		/* Honduras */
		/* Unidades vendidas como paquete */

		SELECT null as grupo,NOMBRE+' '+' PAQUETES ', 0 as GT,0 as sv,SUM(VENTA)/SUM(CANT) AS hn,0 AS CR,0 AS PA, 0 AS DO 
		FROM
			(
				SELECT	T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						SUM(T0.StockSum)   	AS VENTA,
						SUM(T0.Quantity)	AS CANT
				FROM    prhn.dbo.INV1 T0
						INNER JOIN prhn.dbo.OINV T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN prhn.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN prhn.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN prhn.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 
						AND T4.GroupCode<>104
						AND T1.DocType    = 'I'
						AND T0.ItemCode IN (SELECT T5.U_Codigo FROM prhn.dbo.[@PAQUETES] T5)
				GROUP	BY T2.ItmsGrpCod, T3.ItmsGrpNam

				UNION ALL
	
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
			) T0 GROUP BY GRUPO,NOMBRE HAVING GRUPO IS NOT NULL AND SUM(CANT)<>0
		
		UNION ALL

		/* Costa Rica */
		/* Artículos vendidos individualmente */

		SELECT null as grupo,NOMBRE,0 AS GT,0 AS SV,0 AS HN,SUM(VENTA)/SUM(CANT) AS CR,0 AS PA, 0 AS DO 
		FROM
			(
				SELECT	T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						SUM(T0.StockSum)   	AS VENTA,
						SUM(T0.Quantity)	AS CANT 
				FROM    vmcr.dbo.INV1 T0
						INNER JOIN vmcr.dbo.OINV T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN vmcr.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN vmcr.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN vmcr.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 
						AND T4.GroupCode<>103
						AND T1.DocType    = 'I'
						AND T0.ItemCode NOT IN (SELECT T5.U_Codigo FROM vmcr.dbo.[@PAQUETES] T5)
				GROUP BY T2.ItmsGrpCod, T3.ItmsGrpNam

				UNION ALL

				SELECT  T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						SUM(T0.StockSum)*-1   	AS VENTA,
						SUM(T0.Quantity)*-1	AS CANT
				FROM    vmcr.dbo.RIN1 T0
						INNER JOIN vmcr.dbo.ORIN T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN vmcr.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN vmcr.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN vmcr.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 AND   T4.GroupCode<>103
						AND T1.DocType    = 'I'
						AND T0.ItemCode NOT IN (SELECT T5.U_Codigo FROM vmcr.dbo.[@PAQUETES] T5)
				GROUP BY T2.ItmsGrpCod,T3.ItmsGrpNam
			) T0 GROUP BY GRUPO,NOMBRE HAVING GRUPO IS NOT NULL  AND SUM(CANT)<>0

		union all 

		/* Costa Rica */
		/* Artículos vendidos como paquetes */

		SELECT null as grupo,NOMBRE+' '+' PAQUETES ', 0 as GT,0 as sv,0 as hn,SUM(VENTA)/SUM(CANT) AS cr,0 AS PA, 0 AS DO 
		FROM
			(
				SELECT	T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						SUM(T0.StockSum)   	AS VENTA,
						SUM(T0.Quantity)	AS CANT
				FROM    vmcr.dbo.INV1 T0
						INNER JOIN vmcr.dbo.OINV T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN vmcr.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN vmcr.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN vmcr.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 
						AND T4.GroupCode<>103
						AND T1.DocType    = 'I'
						AND T0.ItemCode IN (SELECT T5.U_Codigo FROM vmcr.dbo.[@PAQUETES] T5)
				GROUP	BY T2.ItmsGrpCod, T3.ItmsGrpNam

				UNION ALL
	
				SELECT  T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						SUM(T0.StockSum)*-1   	AS VENTA,
						SUM(T0.Quantity)*-1	AS CANT    
				FROM    vmcr.dbo.RIN1 T0
						INNER JOIN vmcr.dbo.ORIN T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN vmcr.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN vmcr.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN vmcr.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 AND   T4.GroupCode<>104
						AND T1.DocType    = 'I' AND T4.GroupCode<>103
						AND T0.ItemCode IN (SELECT T5.U_Codigo FROM vmcr.dbo.[@PAQUETES] T5)
				GROUP BY T2.ItmsGrpCod,T3.ItmsGrpNam
			) T0 GROUP BY GRUPO,NOMBRE HAVING GRUPO IS NOT NULL AND SUM(CANT)<>0
		
		UNION ALL

		/*PANAMA*/
		/* Artículos vendidos individualmente */

		SELECT null as grupo,NOMBRE,0 AS GT,0 AS SV,0 AS HN,0 AS CR,SUM(VENTA)/SUM(CANT) AS PA, 0 AS DO 
		FROM
			(
				SELECT	T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						SUM(T0.StockSum)   	AS VENTA,
						SUM(T0.Quantity)	AS CANT 
				FROM    vmpa.dbo.INV1 T0
						INNER JOIN vmpa.dbo.OINV T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN vmpa.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN vmpa.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN vmpa.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 
						AND T4.GroupCode<>104
						AND T1.DocType    = 'I'
						AND T0.ItemCode NOT IN (SELECT T5.U_Codigo FROM vmpa.dbo.[@PAQUETES] T5)
				GROUP BY T2.ItmsGrpCod, T3.ItmsGrpNam

				UNION ALL
			
				SELECT  T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						SUM(T0.StockSum)*-1   	AS VENTA,
						SUM(T0.Quantity)*-1	AS CANT 
				FROM    vmpa.dbo.RIN1 T0
						INNER JOIN vmpa.dbo.ORIN T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN vmpa.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN vmpa.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN vmpa.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 AND   T4.GroupCode<>104
						AND T1.DocType    = 'I'
						AND T0.ItemCode NOT IN (SELECT T5.U_Codigo FROM vmpa.dbo.[@PAQUETES] T5)
				GROUP BY T2.ItmsGrpCod,T3.ItmsGrpNam
			) T0 GROUP BY GRUPO,NOMBRE HAVING GRUPO IS NOT NULL  AND SUM(CANT)<>0


		UNION ALL
		
		/* Panamá */
		/* Artículos vendidos como paquetes */
		SELECT null as grupo,NOMBRE+' '+' PAQUETES ', 0 as GT,0 as sv,0 as hn,0 as cr,SUM(VENTA)/SUM(CANT) AS pa, 0 AS DO 
		FROM
			(
				SELECT	T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						SUM(T0.StockSum)   	AS VENTA,
						SUM(T0.Quantity)	AS CANT
				FROM    vmpa.dbo.INV1 T0
						INNER JOIN vmpa.dbo.OINV T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN vmpa.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN vmpa.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN vmpa.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 
						AND T4.GroupCode<>104
						AND T1.DocType    = 'I'
						AND T0.ItemCode IN (SELECT T5.U_Codigo FROM vmpa.dbo.[@PAQUETES] T5)
				GROUP	BY T2.ItmsGrpCod, T3.ItmsGrpNam

				UNION ALL
	
				SELECT  T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						SUM(T0.StockSum)*-1   	AS VENTA,
						SUM(T0.Quantity)*-1	AS CANT    
				FROM    vmpa.dbo.RIN1 T0
						INNER JOIN vmpa.dbo.ORIN T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN vmpa.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN vmpa.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN vmpa.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 AND   T4.GroupCode<>104
						AND T1.DocType    = 'I'
						AND T0.ItemCode IN (SELECT T5.U_Codigo FROM vmpa.dbo.[@PAQUETES] T5)
				GROUP BY T2.ItmsGrpCod,T3.ItmsGrpNam
			) T0 GROUP BY GRUPO,NOMBRE HAVING GRUPO IS NOT NULL AND SUM(CANT)<>0

		union all

		/*DOMINICANA*/
		/* Artículos vendidos individualmente */
		SELECT null as grupo,NOMBRE,0 AS GT,0 AS SV,0 AS HN,0 AS CR,0 AS PA, SUM(VENTA)/SUM(CANT) AS DO 
		FROM
			(
				SELECT	T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						SUM(T0.StockSum)   	AS VENTA,
						SUM(T0.Quantity)	AS CANT
				FROM    vmdo.dbo.INV1 T0
						INNER JOIN vmdo.dbo.OINV T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN vmdo.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN vmdo.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN vmdo.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 
						AND T4.GroupCode<>104
						AND T1.DocType    = 'I'
						AND T0.ItemCode NOT IN (SELECT T5.U_Codigo FROM vmdo.dbo.[@PAQUETES] T5)
				GROUP BY T2.ItmsGrpCod, T3.ItmsGrpNam

				UNION ALL

				SELECT  T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						SUM(T0.StockSum)*-1   	AS VENTA,
						SUM(T0.Quantity)*-1	AS CANT
				FROM    vmdo.dbo.RIN1 T0
						INNER JOIN vmdo.dbo.ORIN T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN vmdo.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN vmdo.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN vmdo.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 AND   T4.GroupCode<>104
						AND T1.DocType    = 'I'
						AND T0.ItemCode NOT IN (SELECT T5.U_Codigo FROM vmdo.dbo.[@PAQUETES] T5)
				GROUP BY T2.ItmsGrpCod,T3.ItmsGrpNam
			) T0 GROUP BY GRUPO,NOMBRE HAVING GRUPO IS NOT NULL  AND SUM(CANT)<>0
	
		union all 
	
		/* Domicana */
		/* Artículos vendidos como paquete */

		SELECT null as grupo,NOMBRE+' '+' PAQUETES ', 0 as GT,0 as sv,0 as hn,0 as cr,0 as pa,SUM(VENTA)/SUM(CANT) AS do 
		FROM
			(
				SELECT	T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						SUM(T0.StockSum)   	AS VENTA,
						SUM(T0.Quantity)	AS CANT
				FROM    vmdo.dbo.INV1 T0
						INNER JOIN vmdo.dbo.OINV T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN vmdo.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN vmdo.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN vmdo.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 
						AND T4.GroupCode<>104
						AND T1.DocType    = 'I'
						AND T0.ItemCode IN (SELECT T5.U_Codigo FROM vmdo.dbo.[@PAQUETES] T5)
				GROUP	BY T2.ItmsGrpCod, T3.ItmsGrpNam

				UNION ALL
	
				SELECT  T2.ItmsGrpCod		AS GRUPO,
						T3.ItmsGrpNam		AS NOMBRE,
   						SUM(T0.StockSum)*-1   	AS VENTA,
						SUM(T0.Quantity)*-1	AS CANT    
				FROM    vmdo.dbo.RIN1 T0
						INNER JOIN vmdo.dbo.ORIN T1 ON T0.DocEntry   = T1.DocEntry
						LEFT JOIN vmdo.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
						LEFT JOIN vmdo.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
						INNER JOIN vmdo.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
				WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 AND   T4.GroupCode<>104
						AND T1.DocType    = 'I'
						AND T0.ItemCode IN (SELECT T5.U_Codigo FROM vmdo.dbo.[@PAQUETES] T5)
				GROUP BY T2.ItmsGrpCod,T3.ItmsGrpNam
			) T0 GROUP BY GRUPO,NOMBRE HAVING GRUPO IS NOT NULL AND SUM(CANT)<>0

) T0 GROUP BY grupo,NOMBRE ---order by Grupo 


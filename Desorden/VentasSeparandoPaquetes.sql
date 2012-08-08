DECLARE @fecha1 as datetime,
		@fecha2 as datetime,
		@sClienteIni as varchar(100),
		@sClienteFin as varchar(100),
		@sGrupoIni	as varchar(100),
		@sGrupoFin as varchar(100),
		@iInDesign as int,
		@nTc as numeric(18,4)

		set @fecha1	= '01/01/2011 00:00:00'
		set @fecha2	= '03/31/2011 00:00:00'
		set @sClienteIni = ''---'CORPORACION DE TIENDAS INTERNACIONALES, S.A. DE C.V.'
		set @sClienteFin =''--- 'CORPORACION DE TIENDAS INTERNACIONALES, S.A. DE C.V.'
		set @sGrupoIni	= 'ALBUMES Y TARJETAS'
		set @sGrupoFin	= 'VIDEOJUEGOS'
		set @nTc		= 8

SELECT GRUPO,NOMBRE,0 AS GT,0 AS SV,0 AS HN,0 AS CR,0 AS PA, SUM(VENTA) AS DO 
FROM
(
	SELECT	T2.ItmsGrpCod		AS GRUPO,
			T3.ItmsGrpNam		AS NOMBRE,
			SUM(T0.LineTotal) 	AS VENTA
	FROM    VMDO.DBO.INV1 T0
			INNER JOIN VMDO.DBO.OINV T1 ON T0.DocEntry   = T1.DocEntry
			LEFT JOIN VMDO.DBO.OITM T2 ON T0.ItemCode   = T2.ItemCode
			LEFT JOIN VMDO.DBO.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
			INNER JOIN VMDO.DBO.OCRD T4 ON T1.CardCode   = T4.CardCode
	WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 
			AND T4.GroupCode<>104
			AND T1.DocType    = 'I' and T0.ItemCode not in (select t5.u_Codigo from vmdo.dbo.[@paquetes] T5)
	GROUP BY T2.ItmsGrpCod, T3.ItmsGrpNam

	UNION ALL

	SELECT  T2.ItmsGrpCod		AS GRUPO,
			T3.ItmsGrpNam		AS NOMBRE,
			SUM(T0.LineTotal)*-1 	AS VENTA
	FROM    VMDO.DBO.RIN1 T0
			INNER JOIN VMDO.DBO.ORIN T1 ON T0.DocEntry   = T1.DocEntry
			LEFT JOIN VMDO.DBO.OITM T2 ON T0.ItemCode   = T2.ItemCode
			LEFT JOIN VMDO.DBO.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
			INNER JOIN VMDO.DBO.OCRD T4 ON T1.CardCode   = T4.CardCode
	WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 AND   T4.GroupCode<>104
			AND T1.DocType    = 'I' and T0.ItemCode  not in (select t5.u_Codigo from vmpa.dbo.[@paquetes] T5)
	GROUP BY T2.ItmsGrpCod,T3.ItmsGrpNam

	UNION ALL

	/* Unidades vendidas como paquetes */

	SELECT	T2.ItmsGrpCod		AS GRUPO,
			T3.ItmsGrpNam+' '+' PAQUETE '		AS NOMBRE,
			SUM(T0.LineTotal) 	AS VENTA
	FROM    VMDO.DBO.INV1 T0
			INNER JOIN VMDO.DBO.OINV T1 ON T0.DocEntry   = T1.DocEntry
			LEFT JOIN VMDO.DBO.OITM T2 ON T0.ItemCode   = T2.ItemCode
			LEFT JOIN VMDO.DBO.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
			INNER JOIN VMDO.DBO.OCRD T4 ON T1.CardCode   = T4.CardCode
	WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 
			AND T4.GroupCode<>104
			AND T1.DocType    = 'I' and T0.ItemCode in (select t5.u_Codigo from vmdo.dbo.[@paquetes] T5)
	GROUP BY T2.ItmsGrpCod, T3.ItmsGrpNam

	UNION ALL

	SELECT  T2.ItmsGrpCod		AS GRUPO,
			T3.ItmsGrpNam+' '+' PAQUETE '		AS NOMBRE,
			SUM(T0.LineTotal)*-1 	AS VENTA
	FROM    VMDO.DBO.RIN1 T0
			INNER JOIN VMDO.DBO.ORIN T1 ON T0.DocEntry   = T1.DocEntry
			LEFT JOIN VMDO.DBO.OITM T2 ON T0.ItemCode   = T2.ItemCode
			LEFT JOIN VMDO.DBO.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
			INNER JOIN VMDO.DBO.OCRD T4 ON T1.CardCode   = T4.CardCode
	WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 AND   T4.GroupCode<>104
			AND T1.DocType    = 'I' and T0.ItemCode in (select t5.u_Codigo from vmdo.dbo.[@paquetes] T5)
	GROUP BY T2.ItmsGrpCod,T3.ItmsGrpNam

	union all 

	/*AGREGANDO LAS ND EN VALORES Q SON DE CLIENTE DE VTA DE ARTICULOS*/

	SELECT	'100'			AS GRUPO,
			'DVD DISNEY'		AS NOMBRE,
			(T0.LineTotal) 	AS VENTA
	FROM    VMDO.DBO.INV1 T0
			INNER JOIN VMDO.DBO.OINV T1 ON T0.DocEntry   = T1.DocEntry
			LEFT JOIN VMDO.DBO.OITM T2 ON T0.ItemCode   = T2.ItemCode
			LEFT JOIN VMDO.DBO.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
			INNER JOIN VMDO.DBO.OCRD T4 ON T1.CardCode   = T4.CardCode
	WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 
			AND T4.GroupCode<>104
			AND T1.DocType    = 'S'
			AND T1.U_FacSerie LIKE 'ND'

	UNION ALL

	/*AGREGANDO LAS NC EN VALORES Q SON  Q SON DE CLIENTE DE VTA DE ARTICULOS */

	SELECT  '100'			AS GRUPO,
			'DVD DISNEY'		AS NOMBRE,
			SUM(T0.LineTotal)*-1 	AS VENTA
	FROM    VMDO.DBO.RIN1 T0
			INNER JOIN VMDO.DBO.ORIN T1 ON T0.DocEntry   = T1.DocEntry
			LEFT JOIN VMDO.DBO.OITM T2 ON T0.ItemCode   = T2.ItemCode
			LEFT JOIN VMDO.DBO.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
			INNER JOIN VMDO.DBO.OCRD T4 ON T1.CardCode   = T4.CardCode
	WHERE	T1.DocDate BETWEEN @fecha1 AND @fecha2 AND 
			T4.GroupCode<>104 AND T1.DocType    = 'S'
) T0 GROUP BY GRUPO,NOMBRE HAVING GRUPO IS NOT NULL
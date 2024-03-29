set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROCEDURE [dbo].[LlenaPaisCV_Ventas_Conso_v11]

@Fecha1 AS DATETIME,
@Fecha2 AS DATETIME,
@gt as numeric(19,6),
@CR AS Numeric(19,6),
@HN AS Numeric(19,6),
@NI AS Numeric(19,6),
@CO AS Numeric(19,6)

AS 

INSERT INTO #Tmp_1 
	SELECT  Rubro,
			ISNULL(Descripcion,'Sin Clasificacion de Rubro')	AS Descrip,
			/*Descripcion	AS Descrip,*/
			SUM(Facturado) 	AS Factu	,
			SUM(Factu_AFI)	AS Fac_Afi	,
			SUM(NC)		AS NC		,
			SUM(NCI)	AS NCI		,
			SUM(Facturado + Factu_AFI - NC - NCI) AS NetoF
	FROM (
	SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
	       T2.Name               AS Descripcion,
			SUM(T0.LineTotal)/@gt          AS Facturado,
	       0 		     AS Factu_AFI,
		   0 		     AS NC,
			0			 		     AS NCI
	FROM	[cvgt].[dbo].[INV1]    T0
			INNER JOIN [cvgt].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
			LEFT JOIN [cvgt].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
			LEFT JOIN [cvsv].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
	WHERE T1.DocDate   >= @Fecha1
			AND T1.DocDate   <= @Fecha2
			AND T0.LineTotal <> 0
	GROUP BY isnull(T0.U_Rubro,''),T2.Name

	UNION ALL

	SELECT ISNULL(T0.U_Rubro,'')			 AS Rubro      ,
			T2.Name							 AS Descripcion,
			(SUM(T0.LineTotal)/@gt)*-1 		     AS Facturado,
			0    AS Factu_AFI,
			0 		     AS NC,
			0 		     AS NCI
	FROM    [CVgt].[dbo].[INV1]    T0
			INNER JOIN [CVgt].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
			LEFT  JOIN [CVgt].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
			LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
			LEFT  JOIN [CVgt].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
	WHERE T1.DocDate   >= @Fecha1
			AND T1.DocDate   <= @Fecha2
			AND T0.LineTotal <> 0
			AND T4.Groupcode = '103'
	GROUP BY isnull(T0.U_Rubro,''),T2.Name

	UNION ALL

	SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
			T2.Name               AS Descripcion,
			0		     AS Facturado,
			SUM(T0.LineTotal)/@gt    AS Factu_AFI,
			0 		     AS NC,
			0 		     AS NCI
	FROM    [CVgt].[dbo].[INV1]    T0
			INNER JOIN [CVgt].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
			LEFT  JOIN [CVgt].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
			LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
			LEFT  JOIN [CVgt].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
	WHERE T1.DocDate   >= @Fecha1
			AND T1.DocDate   <= @Fecha2
			AND T0.LineTotal <> 0
			AND T4.Groupcode = '103'
	GROUP BY T0.U_Rubro,
	  T2.Name

	UNION ALL

	/* NCI Y NC CLIENTES*/

	SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
			T2.Name               		AS Descripcion,
			0				AS Facturado,
			0		   		AS Factu_AFI,
			0 		    	 	AS NC,
			SUM(T0.LineTotal)/@gt     	AS NCI
	FROM    [CVgt]. [dbo].[RIN1]    T0
			INNER JOIN [CVgt].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
			LEFT JOIN [CVgt].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
			LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
			LEFT  JOIN [CVgt].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
	WHERE T1.DocDate   >= @Fecha1
			AND T1.DocDate   <= @Fecha2
			AND T4.Groupcode <> '103'
			AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
	 GROUP BY T0.U_Rubro      ,
			T2.Name

	UNION ALL

	SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
			T2.Name               		AS Descripcion,
			0				AS Facturado,
			0		   		AS Factu_AFI,
			SUM(T0.LineTotal)/@gt     		AS NC,
			0 				AS NCI
	FROM    [CVgt].[dbo].[RIN1]    T0
			INNER JOIN [CVgt].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
			LEFT JOIN [CVgt].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
			LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
			LEFT  JOIN [CVgt].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
	WHERE T1.DocDate   >= @Fecha1
			AND T1.DocDate   <= @Fecha2
			AND T4.Groupcode <> '103'
			AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
	GROUP BY T0.U_Rubro      ,
	  T2.Name

	UNION ALL

	/*********NC Y NCI CASOS ESPECIALES***************/
	/*OPEN CASO ESPECIAL*/
	SELECT '111' 						AS Rubro      ,
			'PEP Spots - 35 mm'               		AS Descripcion,
			0				AS Facturado,
			0		   		AS Factu_AFI,
			0 		    	 	AS NC,
			SUM(T0.LineTotal)/@gt       	AS NCI
	FROM    [CVgt].[dbo].[RIN1]    T0
			INNER JOIN [CVgt].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
			LEFT JOIN [CVgt].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
			LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
			LEFT  JOIN [CVgt].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
	WHERE T1.DocDate   >= @Fecha1
			AND T1.DocDate   <= @Fecha2
			AND T4.Groupcode <> '103'
			AND T1.Comments LIKE 'PEP Spots - 35 mm%'
			AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
			AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

	UNION ALL	

	SELECT '112' 						AS Rubro      ,
			'PEP Spots - Cine Spots'               		AS Descripcion,
			0				AS Facturado,
			0		   		AS Factu_AFI,
			0 		    	 	AS NC,
			SUM(T0.LineTotal)/@gt       	AS NCI
	FROM    [CVgt].[dbo].[RIN1]    T0
			INNER JOIN [CVgt].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
			LEFT JOIN [CVgt].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
			LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
			LEFT  JOIN [CVgt].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
	WHERE T1.DocDate   >= @Fecha1
			AND T1.DocDate   <= @Fecha2
			AND T4.Groupcode <> '103'
			AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
			AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
			AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

	UNION ALL

	SELECT '113' 						AS Rubro      ,
			'PEP Spots - Slides Digital'               		AS Descripcion,
			0				AS Facturado,
			0		   		AS Factu_AFI,
			0 		    	 	AS NC,
			SUM(T0.LineTotal)/@gt    	AS NCI
	FROM    [CVgt].[dbo].[RIN1]    T0
			INNER JOIN [CVgt].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
			LEFT JOIN [CVgt].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
			LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
			LEFT  JOIN [CVgt].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
	WHERE T1.DocDate   >= @Fecha1
			AND T1.DocDate   <= @Fecha2
			AND T4.Groupcode <> '103'
			AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
			AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
			AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

	/*CLOSE SEGMENTO DE CASOS ESPECIALES*/
	/*para RESTAR*/
	
	UNION ALL

	SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
			T2.Name               		AS Descripcion,
			0				AS Facturado,
			0		   		AS Factu_AFI,
			0 		    	 	AS NC,
			SUM(T0.LineTotal)/@gt*-1     	AS NCI
	FROM    [CVgt].[dbo].[RIN1]    T0
			INNER JOIN [CVgt].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
			LEFT JOIN [CVgt].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
			LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
			LEFT  JOIN [CVgt].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
	WHERE T1.DocDate   >= @Fecha1
			AND T1.DocDate   <= @Fecha2
			AND T4.Groupcode <> '103'
			AND T1.Comments LIKE 'PEP Spots - 35 mm%'
			AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
			AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
	GROUP BY T0.U_Rubro      ,
	  T2.Name

	UNION ALL

	SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
			T2.Name               		AS Descripcion,
			0				AS Facturado,
			0		   		AS Factu_AFI,
			0 		    	 	AS NC,
			SUM(T0.LineTotal)/@gt*-1     	AS NCI
	FROM    [CVgt].[dbo].[RIN1]    T0
			INNER JOIN [CVgt].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
			LEFT JOIN [CVgt].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
			LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
			LEFT  JOIN [CVgt].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
	WHERE T1.DocDate   >= @Fecha1
			AND T1.DocDate   <= @Fecha2
			AND T4.Groupcode <> '103'
			AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
			AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
			AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
	GROUP BY T0.U_Rubro      ,
		T2.Name

	UNION ALL

	SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
			T2.Name               		AS Descripcion,
			0				AS Facturado,
			0		   		AS Factu_AFI,
			0 		    	 	AS NC,
			SUM(T0.LineTotal)/@gt*-1     	AS NCI
	FROM    [CVgt].[dbo].[RIN1]    T0
			INNER JOIN [CVgt].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
			LEFT JOIN [CVgt].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
			LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
			LEFT  JOIN [CVgt].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
	WHERE T1.DocDate   >= @Fecha1
			AND T1.DocDate   <= @Fecha2
			AND T4.Groupcode <> '103'
			AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
			AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
			AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
	GROUP BY T0.U_Rubro      ,
			T2.Name

	/*CLOSE SEGMENTO DE CASOS ESPECIALES RESTANDO NCI*/

	UNION ALL

/********OPEN CASO PARA NC*********/

	SELECT '111' 						AS Rubro      ,
			'PEP Spots - 35 mm'               		AS Descripcion,
			0				AS Facturado,
			0		   		AS Factu_AFI,
			SUM(T0.LineTotal)/@gt  		    	 	AS NC,
			0    	AS NCI
	FROM    [CVgt].[dbo].[RIN1]    T0
			INNER JOIN [CVgt].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
			LEFT JOIN [CVgt].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
			LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
			LEFT  JOIN [CVgt].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
	WHERE T1.DocDate   >= @Fecha1
			AND T1.DocDate   <= @Fecha2
			AND T4.Groupcode <> '103'
			AND T1.Comments LIKE 'PEP Spots - 35 mm%'
			AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
			AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

	UNION ALL

	SELECT '112' 						AS Rubro      ,
			'PEP Spots - Cine Spots'               		AS Descripcion,
			0				AS Facturado,
			0		   		AS Factu_AFI,
			SUM(T0.LineTotal)/@gt 		    	 	AS NC,
			0     	AS NCI
	FROM    [CVgt].[dbo].[RIN1]    T0
			INNER JOIN [CVgt].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
			LEFT JOIN [CVgt].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
			LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
			LEFT  JOIN [CVgt].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
	WHERE T1.DocDate   >= @Fecha1
			AND T1.DocDate   <= @Fecha2
			AND T4.Groupcode <> '103'
			AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
			AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
			AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

	UNION ALL

	SELECT '113' 						AS Rubro      ,
			'PEP Spots - Slides Digital'               		AS Descripcion,
			0				AS Facturado,
			0		   		AS Factu_AFI,
			SUM(T0.LineTotal)/@gt  		    	 	AS NC,
			0    	AS NCI
	FROM    [CVgt].[dbo].[RIN1]    T0
			INNER JOIN [CVgt].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
			LEFT JOIN [CVgt].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
			LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
			LEFT  JOIN [CVgt].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
	WHERE T1.DocDate   >= @Fecha1
			AND T1.DocDate   <= @Fecha2
			AND T4.Groupcode <> '103'
			AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
			AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
			AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

	/*CLOSE SEGMENTO DE CASOS ESPECIALES*/
	/*para RESTAR*/
	
	UNION ALL

	SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
			T2.Name               		AS Descripcion,
			0				AS Facturado,
			0		   		AS Factu_AFI,
			SUM(T0.LineTotal)/@gt*-1 		    	 	AS NC,
			0     	AS NCI
	FROM    [CVgt].[dbo].[RIN1]    T0
			INNER JOIN [CVgt].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
			LEFT JOIN [CVgt].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
			LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
			LEFT  JOIN [CVgt].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
	WHERE T1.DocDate   >= @Fecha1
			AND T1.DocDate   <= @Fecha2
			AND T4.Groupcode <> '103'
			AND T1.Comments LIKE 'PEP Spots - 35 mm%'
			AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
			AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
	GROUP BY T0.U_Rubro      ,
			T2.Name

	UNION ALL

	SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
			T2.Name               		AS Descripcion,
			0								AS Facturado,
			0		   					AS Factu_AFI,
			SUM(T0.LineTotal)/@gt*-1 		AS NC,
			0     	AS NCI
	FROM    [CVgt].[dbo].[RIN1]    T0
			INNER JOIN [CVgt].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
			LEFT JOIN [CVgt].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
			LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
			LEFT  JOIN [CVgt].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
	WHERE T1.DocDate   >= @Fecha1
			AND T1.DocDate   <= @Fecha2
			AND T4.Groupcode <> '103'
			AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
			AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
			AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
	GROUP BY T0.U_Rubro      ,
		T2.Name

	UNION ALL

	SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
			T2.Name               		AS Descripcion,
			0				AS Facturado,
			0		   		AS Factu_AFI,
			SUM(T0.LineTotal)/@gt*-1   		    	 	AS NC,
			0   	AS NCI
	FROM    [CVgt].[dbo].[RIN1]    T0
			INNER JOIN [CVgt].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
			LEFT JOIN [CVgt].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
			LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
			LEFT  JOIN [CVgt].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
	WHERE T1.DocDate   >= @Fecha1
			AND T1.DocDate   <= @Fecha2
			AND T4.Groupcode <> '103'
			AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
			AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
			AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
	GROUP BY T0.U_Rubro      ,
			T2.Name

	/*CLOSE SEGMENTO DE CASOS ESPECIALES RESTANDO*/

	/*********CLOSE CASO PARA NC*************/
	
	/************CLOSE NC Y NCI CASOS ESPECIALES********/


	UNION ALL

	/* NCI Y NC AFILIADAS*/

	SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
			T2.Name               		AS Descripcion,
			0				AS Facturado,
			(SUM(T0.LineTotal)/@gt )*-1	AS Factu_AFI,
			0 		    	 	AS NC,
			0    	AS NCI
	FROM    [CVgt]. [dbo].[RIN1]    T0
			INNER JOIN [CVgt].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
			LEFT JOIN [CVgt].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
			LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
			LEFT  JOIN [CVgt].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
	WHERE T1.DocDate   >= @Fecha1
			AND T1.DocDate   <= @Fecha2
			AND T4.Groupcode = '103'
			AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
	GROUP BY T0.U_Rubro      ,
			T2.Name

	UNION ALL

	SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
			T2.Name               		AS Descripcion,
			0				AS Facturado,
			(SUM(T0.LineTotal)/@gt )*-1	AS Factu_AFI,
			0   				AS NC,
			0 				AS NCI
	FROM    [CVgt].[dbo].[RIN1]    T0
			INNER JOIN [CVgt].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
			LEFT JOIN [CVgt].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
			LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
			LEFT  JOIN [CVgt].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
	WHERE T1.DocDate   >= @Fecha1
			AND T1.DocDate   <= @Fecha2
			AND T4.Groupcode = '103'
			AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
	GROUP BY T0.U_Rubro      ,
			T2.Name
	) T0 GROUP BY Rubro,Descripcion ORDER BY Rubro

	INSERT INTO #Tmp_3 (Descripcion) VALUES ('Guatemala')
	INSERT INTO #Tmp_3 SELECT * FROM #Tmp_1 
	INSERT INTO #Tmp_2 SELECT * FROM #Tmp_1 

	INSERT INTO #Tmp_3 
		SELECT 		''  		AS Rubro,
				' TOTALES'	AS Descripcion,
				SUM(P_VENTA),
				SUM(P_AFIL),
				SUM(P_NC),
				SUM(P_NCI),
				SUM(P_NetoF) 
		FROM #Tmp_1
		INSERT INTO #Tmp_3 (Descripcion) VALUES ('')

	/*EL SALVADOR*/

	DELETE FROM #Tmp_1
	INSERT INTO #Tmp_1 
		SELECT  Rubro,
				ISNULL(Descripcion,'Sin Clasificacion de Rubro')	AS Descrip,
				/*Descripcion	AS Descrip,*/
				SUM(Facturado) 	AS Factu	,
				SUM(Factu_AFI)	AS Fac_Afi	,
				SUM(NC)		AS NC		,
				SUM(NCI)	AS NCI		,
				SUM(Facturado + Factu_AFI - NC - NCI) AS NetoF
		FROM (
				SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
						T2.Name               AS Descripcion,
						SUM(T0.LineTotal)          AS Facturado,
						0 		     AS Factu_AFI,
						0 		     AS NC,
						0 		     AS NCI
				FROM    [CVSV].[dbo].[INV1]    T0
						INNER JOIN [CVSV].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
						LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
				WHERE	T1.DocDate   >= @Fecha1
						AND T1.DocDate   <= @Fecha2
						AND T0.LineTotal <> 0
						AND (T0.U_Rubro<>'311' or T0.U_Rubro is null)
				GROUP BY isnull(T0.U_Rubro,''),T2.Name     ---- le agregué is null al group by en u_rubro

				UNION ALL

				SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
						T2.Name               AS Descripcion,
						SUM(T0.LineTotal) *-1		     AS Facturado,
						0    		 AS Factu_AFI,
						0 		     AS NC,
						0 		     AS NCI
				FROM    [CVSV].[dbo].[INV1]    T0
						INNER JOIN [CVSV].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
						LEFT  JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
						LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
				WHERE	T1.DocDate   >= @Fecha1
						AND T1.DocDate   <= @Fecha2
						AND T0.LineTotal <> 0
						AND (T0.U_Rubro<>'311' or T0.u_rubro is null)
						AND T3.Groupcode = '103'
				GROUP BY isnull(T0.U_Rubro,''),T2.Name    ---- le agregué is null al group by en u_rubro

				UNION ALL
				/*vta afi*/
				SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
						T2.Name               AS Descripcion,
						0		     AS Facturado,
						SUM(T0.LineTotal)     AS Factu_AFI,
						0 		     AS NC,
						0 		     AS NCI
				FROM    [CVSV].[dbo].[INV1]    T0
						INNER JOIN [CVSV].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
						LEFT  JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
						LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
				WHERE	T1.DocDate   >= @Fecha1
						AND T1.DocDate   <= @Fecha2
						AND T0.LineTotal <> 0
						AND (T0.U_Rubro<>'311' or t0.u_rubro is null)
						AND T3.Groupcode = '103'
				GROUP BY isnull(T0.U_Rubro,''),T2.Name    ---- le agregué is null al group by en u_rubro

				UNION ALL
				
				/*NCI Y NC CLIENTES*/
				SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
						T2.Name               		AS Descripcion,
						0				AS Facturado,
						0		   		AS Factu_AFI,
						0 		    	 	AS NC,
						SUM(T0.LineTotal)     	AS NCI
				FROM    [CVSV]. [dbo].[RIN1]    T0
						INNER JOIN [CVSV].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
						LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
						LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
				WHERE	T1.DocDate   >= @Fecha1
						AND T1.DocDate   <= @Fecha2
						AND T3.Groupcode <> '103'
						AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
						AND (T0.U_Rubro<>'311' or t0.u_rubro is null)
				GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

/*OPEN CASO ESPECIAL*/
SELECT '111' 						AS Rubro      ,
       'PEP Spots - 35 mm'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)     	AS NCI
   FROM      [CVSV]. [dbo].[RIN1]    T0
 INNER JOIN [CVSV].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T3.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

UNION ALL

SELECT '112' 						AS Rubro      ,
       'PEP Spots - Cine Spots'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)     	AS NCI
  FROM      [CVSV]. [dbo].[RIN1]    T0
 INNER JOIN [CVSV].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T3.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

UNION ALL

				SELECT '113' 						AS Rubro      ,
						'PEP Spots - Slides Digital'               		AS Descripcion,
						0				AS Facturado,
						0		   		AS Factu_AFI,
						0		    	 	AS NC,
						SUM(T0.LineTotal)    	AS NCI
				FROM    [CVSV]. [dbo].[RIN1]    T0
						INNER JOIN [CVSV].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
						LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
						LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
				WHERE T1.DocDate   >= @Fecha1
						AND T1.DocDate   <= @Fecha2
						AND T3.Groupcode <> '103'
						/*AND T1.Comments LIKE 'PICARO'*/
						AND (T1.Comments LIKE 'PEP Spots - Slides Digital%') /*or T1.Comments Like 'PEPSpots-SlidesDigital')*/
						AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
						AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

/*CLOSE SEGMENTO DE CASOS ESPECIALES*/
/*para RESTAR*/
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)*-1     	AS NCI
   FROM      [CVSV]. [dbo].[RIN1]    T0
 INNER JOIN [CVSV].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T3.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)*-1     	AS NCI
  FROM      [CVSV]. [dbo].[RIN1]    T0
 INNER JOIN [CVSV].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T3.Groupcode <> '103'
AND (T1.Comments LIKE 'PEP Spots - Cine Spots%') 
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name
UNION ALL

				SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
						T2.Name               		AS Descripcion,
						0					AS Facturado,
						0		   		AS Factu_AFI,
						0 		    	 	AS NC,
						SUM(T0.LineTotal)*-1     	AS NCI
				FROM    [CVSV]. [dbo].[RIN1]    T0
						INNER JOIN [CVSV].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
						LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
						LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
				WHERE	T1.DocDate   >= @Fecha1
						AND T1.DocDate   <= @Fecha2
						AND T3.Groupcode <> '103'
						AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
						AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
						AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
				GROUP BY isnull(T0.U_Rubro,''),T2.Name     ---- le agregué is null al group by en u_rubro

/*CLOSE SEGMENTO DE CASOS ESPECIALES RESTANDO*/
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
       SUM(T0.LineTotal)     		AS NC,
	0 				AS NCI
  FROM      [CVSV].[dbo].[RIN1]    T0
 INNER JOIN [CVSV].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T3.Groupcode <> '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
   AND T0.U_Rubro<>'311'
 GROUP BY T0.U_Rubro      ,
	  T2.Name

/*CASO ESPECIAL PARA NC*/
UNION ALL

/*OPEN CASO ESPECIAL*/
SELECT '111' 						AS Rubro      ,
       'PEP Spots - 35 mm'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	  SUM(T0.LineTotal) 		    	 	AS NC,
     0     	AS NCI
   FROM      [CVSV]. [dbo].[RIN1]    T0
 INNER JOIN [CVSV].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T3.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

UNION ALL

SELECT '112' 						AS Rubro      ,
       'PEP Spots - Cine Spots'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)  		    	 	AS NC,
       0    	AS NCI
  FROM      [CVSV]. [dbo].[RIN1]    T0
 INNER JOIN [CVSV].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T3.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

UNION ALL

SELECT '113' 						AS Rubro      ,
       'PEP Spots - Slides Digital'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal) 		    	 	AS NC,
        0    	AS NCI
   FROM      [CVSV]. [dbo].[RIN1]    T0
 INNER JOIN [CVSV].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T3.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL


/* RESTAR NC*/
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)*-1   		    	 	AS NC,
       0   	AS NCI
   FROM      [CVSV]. [dbo].[RIN1]    T0
 INNER JOIN [CVSV].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T3.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)*-1  		    	 	AS NC,
       0    	AS NCI
  FROM      [CVSV]. [dbo].[RIN1]    T0
 INNER JOIN [CVSV].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T3.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)*-1 		    	 	AS NC,
       0     	AS NCI
  FROM      [CVSV]. [dbo].[RIN1]    T0
 INNER JOIN [CVSV].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T3.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name

/*CLOSE SEGMENTO DE CASOS ESPECIALES RESTANDO  NC*/


/*NCI Y NC AFI*/

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        SUM(T0.LineTotal) *-1  		AS Factu_AFI,
	0 		    	 	AS NC,
        0 			    	AS NCI
  FROM      [CVSV]. [dbo].[RIN1]    T0
 INNER JOIN [CVSV].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T3.Groupcode = '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
   AND T0.U_Rubro<>'311'
 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        SUM(T0.LineTotal) *-1		AS Factu_AFI,
       0    				AS NC,
	0 				AS NCI
  FROM      [CVSV].[dbo].[RIN1]    T0
 INNER JOIN [CVSV].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T3.Groupcode = '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
   AND T0.U_Rubro<>'311'
 GROUP BY T0.U_Rubro      ,
	  T2.Name

) T0 GROUP BY Rubro,Descripcion ORDER BY Rubro

INSERT INTO #Tmp_3 (Descripcion) VALUES ('El Salvador')
INSERT INTO #Tmp_3 SELECT * FROM #Tmp_1 
INSERT INTO #Tmp_2 SELECT * FROM #Tmp_1 

INSERT INTO #Tmp_3 
SELECT 		''  		AS Rubro,
		' TOTALES'	AS Descripcion,
		SUM(P_VENTA),
		SUM(P_AFIL),
		SUM(P_NC),
		SUM(P_NCI),
		SUM(P_NetoF) 
FROM #Tmp_1
INSERT INTO #Tmp_3 (Descripcion) VALUES ('')

 /*HONDURAS*/

DELETE FROM #Tmp_1
INSERT INTO #Tmp_1 

SELECT  Rubro,
	ISNULL(Descripcion,'Sin Clasificacion de Rubro')	AS Descrip,
        SUM(Facturado) 	AS Factu	,
        SUM(Factu_AFI)	AS Fac_Afi	,
	SUM(NC)		AS NC		,
	SUM(NCI)	AS NCI		,
	SUM(Facturado + Factu_AFI - NC - NCI) AS NetoF
FROM (

SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
       SUM(T0.LineTotal)/@HN          AS Facturado,
       0 		     AS Factu_AFI,
       0 		     AS NC,
       0 		     AS NCI
  FROM      [CVHN].[dbo].[INV1]    T0
 INNER JOIN [CVHN].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
 GROUP BY T0.U_Rubro,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'')		AS Rubro      ,
       T2.Name				AS Descripcion,
	   (SUM(T0.LineTotal)/@HN)*-1	AS Facturado,
       0     AS Factu_AFI,
       0 		     AS NC,
       0 		     AS NCI
  FROM      [CVHN].[dbo].[INV1]    T0
 INNER JOIN [CVHN].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
 LEFT  JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T4.Groupcode = '103'
 GROUP BY T0.U_Rubro,
	  T2.Name


UNION ALL
/* Vta Afi*/
SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
	0		     AS Facturado,
       SUM(T0.LineTotal)/@HN     AS Factu_AFI,
       0 		     AS NC,
       0 		     AS NCI
  FROM      [CVHN].[dbo].[INV1]    T0
 INNER JOIN [CVHN].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
 LEFT  JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T4.Groupcode = '103'
 GROUP BY T0.U_Rubro,
	  T2.Name

UNION ALL

/* NCI Y NC CLIENTES*/

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@HN     	AS NCI
  FROM      [CVHN]. [dbo].[RIN1]    T0
 INNER JOIN [CVHN].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode <> '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
       SUM(T0.LineTotal) /@HN    		AS NC,
	0 				AS NCI
  FROM      [CVHN].[dbo].[RIN1]    T0
 INNER JOIN [CVHN].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode <> '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name
UNION ALL
/*********NC Y NCI CASOS ESPECIALES***************/
/*OPEN CASO ESPECIAL*/
SELECT '111' 						AS Rubro      ,
       'PEP Spots - 35 mm'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@HN       	AS NCI
  FROM      [CVHN].[dbo].[RIN1]    T0
 INNER JOIN [CVHN].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

UNION ALL

SELECT '112' 						AS Rubro      ,
       'PEP Spots - Cine Spots'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@HN       	AS NCI
  FROM      [CVHN].[dbo].[RIN1]    T0
 INNER JOIN [CVHN].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

UNION ALL

SELECT '113' 						AS Rubro      ,
       'PEP Spots - Slides Digital'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@HN    	AS NCI
  FROM      [CVHN].[dbo].[RIN1]    T0
 INNER JOIN [CVHN].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

/*CLOSE SEGMENTO DE CASOS ESPECIALES*/
/*para RESTAR*/
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@HN*-1     	AS NCI
  FROM      [CVHN].[dbo].[RIN1]    T0
 INNER JOIN [CVHN].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@HN*-1     	AS NCI
  FROM      [CVHN].[dbo].[RIN1]    T0
 INNER JOIN [CVHN].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@HN*-1     	AS NCI
  FROM      [CVHN].[dbo].[RIN1]    T0
 INNER JOIN [CVHN].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name

/*CLOSE SEGMENTO DE CASOS ESPECIALES RESTANDO NCI*/
UNION ALL
/********OPEN CASO PARA NC*********/
SELECT '111' 						AS Rubro      ,
       'PEP Spots - 35 mm'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)/@HN  		    	 	AS NC,
       0    	AS NCI
  FROM      [CVHN].[dbo].[RIN1]    T0
 INNER JOIN [CVHN].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

UNION ALL

SELECT '112' 						AS Rubro      ,
       'PEP Spots - Cine Spots'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)/@HN 		    	 	AS NC,
       0     	AS NCI
  FROM      [CVHN].[dbo].[RIN1]    T0
 INNER JOIN [CVHN].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

UNION ALL

SELECT '113' 						AS Rubro      ,
       'PEP Spots - Slides Digital'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)/@HN  		    	 	AS NC,
       0    	AS NCI
  FROM      [CVHN].[dbo].[RIN1]    T0
 INNER JOIN [CVHN].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

/*CLOSE SEGMENTO DE CASOS ESPECIALES*/
/*para RESTAR*/
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	 SUM(T0.LineTotal)/@HN*-1 		    	 	AS NC,
      0     	AS NCI
  FROM      [CVHN].[dbo].[RIN1]    T0
 INNER JOIN [CVHN].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0								AS Facturado,
        0		   					AS Factu_AFI,
	SUM(T0.LineTotal)/@HN*-1 		AS NC,
       0     	AS NCI
  FROM      [CVHN].[dbo].[RIN1]    T0
 INNER JOIN [CVHN].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)/@HN*-1   		    	 	AS NC,
       0   	AS NCI
  FROM      [CVHN].[dbo].[RIN1]    T0
 INNER JOIN [CVHN].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name

/*CLOSE SEGMENTO DE CASOS ESPECIALES RESTANDO*/

/*********CLOSE CASO PARA NC*************/

/************CLOSE NC Y NCI CASOS ESPECIALES********/
UNION ALL
/* NCI Y NC AFILIADAS*/

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        (SUM(T0.LineTotal)/@HN )*-1	AS Factu_AFI,
	0 		    	 	AS NC,
       0    	AS NCI
  FROM      [CVHN]. [dbo].[RIN1]    T0
 INNER JOIN [CVHN].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode = '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        (SUM(T0.LineTotal) /@HN )*-1    AS Factu_AFI,
       0   		AS NC,
	0 				AS NCI
  FROM      [CVHN].[dbo].[RIN1]    T0
 INNER JOIN [CVHN].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode = '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name

) T0 GROUP BY Rubro,Descripcion ORDER BY Rubro

INSERT INTO #Tmp_3 (Descripcion) VALUES ('Honduras')
/*AQUI se puede AGREG EL TIPOCAMBIO*/
/*INSERT INTO #Tmp_3 (Descripcion,P_VENTA) VALUES ('Tipo Cambio a la Fecha Final de Selección',@HN)*/

INSERT INTO #Tmp_3 SELECT * FROM #Tmp_1 
INSERT INTO #Tmp_2 SELECT * FROM #Tmp_1 

INSERT INTO #Tmp_3 
SELECT 		''  		AS Rubro,
		' TOTALES'	AS Descripcion,
		SUM(P_VENTA),
		SUM(P_AFIL),
		SUM(P_NC),
		SUM(P_NCI),
		SUM(P_NetoF) 
FROM #Tmp_1
INSERT INTO #Tmp_3 (Descripcion) VALUES ('')


/*NICARAGUA*/

DELETE FROM #Tmp_1

INSERT INTO #Tmp_1 

SELECT  Rubro,
	ISNULL(Descripcion,'Sin Clasificacion de Rubro')	AS Descrip,
        SUM(Facturado) 	AS Factu	,
        SUM(Factu_AFI)	AS Fac_Afi	,
	SUM(NC)		AS NC		,
	SUM(NCI)	AS NCI		,
	SUM(Facturado + Factu_AFI - NC - NCI) AS NetoF
FROM (

SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
       SUM(T0.LineTotal)/@NI          AS Facturado,
       0 		     AS Factu_AFI,
       0 		     AS NC,
       0 		     AS NCI
  FROM      [CVNI].[dbo].[INV1]    T0
 INNER JOIN [CVNI].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
 GROUP BY T0.U_Rubro,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'')			 AS Rubro      ,
       T2.Name							 AS Descripcion,
		(SUM(T0.LineTotal)/@NI)*-1 		     AS Facturado,
       0    AS Factu_AFI,
       0 		     AS NC,
       0 		     AS NCI
  FROM      [CVNI].[dbo].[INV1]    T0
 INNER JOIN [CVNI].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
 LEFT  JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T4.Groupcode = '103'
 GROUP BY T0.U_Rubro,
	  T2.Name
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
	0		     AS Facturado,
       SUM(T0.LineTotal)/@NI     AS Factu_AFI,
       0 		     AS NC,
       0 		     AS NCI
  FROM      [CVNI].[dbo].[INV1]    T0
 INNER JOIN [CVNI].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
 LEFT  JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T4.Groupcode = '103'
 GROUP BY T0.U_Rubro,
	  T2.Name

UNION ALL

/* NCI Y NC CLIENTES*/

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@NI     	AS NCI
  FROM      [CVNI]. [dbo].[RIN1]    T0
 INNER JOIN [CVNI].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode <> '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
       SUM(T0.LineTotal)/@NI     		AS NC,
	0 				AS NCI
  FROM      [CVNI].[dbo].[RIN1]    T0
 INNER JOIN [CVNI].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode <> '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL
/*********NC Y NCI CASOS ESPECIALES***************/
/*OPEN CASO ESPECIAL*/
SELECT '111' 						AS Rubro      ,
       'PEP Spots - 35 mm'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@NI       	AS NCI
  FROM      [CVNI].[dbo].[RIN1]    T0
 INNER JOIN [CVNI].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

UNION ALL

SELECT '112' 						AS Rubro      ,
       'PEP Spots - Cine Spots'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@NI       	AS NCI
  FROM      [CVNI].[dbo].[RIN1]    T0
 INNER JOIN [CVNI].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

UNION ALL

SELECT '113' 						AS Rubro      ,
       'PEP Spots - Slides Digital'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@NI    	AS NCI
  FROM      [CVNI].[dbo].[RIN1]    T0
 INNER JOIN [CVNI].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

/*CLOSE SEGMENTO DE CASOS ESPECIALES*/
/*para RESTAR*/
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@NI*-1     	AS NCI
  FROM      [CVNI].[dbo].[RIN1]    T0
 INNER JOIN [CVNI].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@NI*-1     	AS NCI
  FROM      [CVNI].[dbo].[RIN1]    T0
 INNER JOIN [CVNI].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@NI*-1     	AS NCI
  FROM      [CVNI].[dbo].[RIN1]    T0
 INNER JOIN [CVNI].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name

/*CLOSE SEGMENTO DE CASOS ESPECIALES RESTANDO NCI*/
UNION ALL
/********OPEN CASO PARA NC*********/
SELECT '111' 						AS Rubro      ,
       'PEP Spots - 35 mm'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)/@NI  		    	 	AS NC,
       0    	AS NCI
  FROM      [CVNI].[dbo].[RIN1]    T0
 INNER JOIN [CVNI].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

UNION ALL

SELECT '112' 						AS Rubro      ,
       'PEP Spots - Cine Spots'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)/@NI 		    	 	AS NC,
       0     	AS NCI
  FROM      [CVNI].[dbo].[RIN1]    T0
 INNER JOIN [CVNI].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

UNION ALL

SELECT '113' 						AS Rubro      ,
       'PEP Spots - Slides Digital'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)/@NI  		    	 	AS NC,
       0    	AS NCI
  FROM      [CVNI].[dbo].[RIN1]    T0
 INNER JOIN [CVNI].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

/*CLOSE SEGMENTO DE CASOS ESPECIALES*/
/*para RESTAR*/
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	 SUM(T0.LineTotal)/@NI*-1 		    	 	AS NC,
      0     	AS NCI
  FROM      [CVNI].[dbo].[RIN1]    T0
 INNER JOIN [CVNI].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0								AS Facturado,
        0		   					AS Factu_AFI,
	SUM(T0.LineTotal)/@NI*-1 		AS NC,
       0     	AS NCI
  FROM      [CVNI].[dbo].[RIN1]    T0
 INNER JOIN [CVNI].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)/@NI*-1   		    	 	AS NC,
       0   	AS NCI
  FROM      [CVNI].[dbo].[RIN1]    T0
 INNER JOIN [CVNI].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name

/*CLOSE SEGMENTO DE CASOS ESPECIALES RESTANDO*/

/*********CLOSE CASO PARA NC*************/

/************CLOSE NC Y NCI CASOS ESPECIALES********/


UNION ALL

/* NCI Y NC AFILIADAS*/

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
       (SUM(T0.LineTotal)/@NI )*-1	AS Factu_AFI,
	0 		    	 	AS NC,
       0    	AS NCI
  FROM      [CVNI]. [dbo].[RIN1]    T0
 INNER JOIN [CVNI].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode = '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
       (SUM(T0.LineTotal)/@NI )*-1	AS Factu_AFI,
	0   				AS NC,
	0 				AS NCI
  FROM      [CVNI].[dbo].[RIN1]    T0
 INNER JOIN [CVNI].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode = '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name

) T0 GROUP BY Rubro,Descripcion ORDER BY Rubro

INSERT INTO #Tmp_3 (Descripcion) VALUES ('Nicaragua')
INSERT INTO #Tmp_3 SELECT * FROM #Tmp_1 
INSERT INTO #Tmp_2 SELECT * FROM #Tmp_1 

INSERT INTO #Tmp_3 
SELECT 		''  		AS Rubro,
		' TOTALES'	AS Descripcion,
		SUM(P_VENTA),
		SUM(P_AFIL),
		SUM(P_NC),
		SUM(P_NCI),
		SUM(P_NetoF) 
FROM #Tmp_1
INSERT INTO #Tmp_3 (Descripcion) VALUES ('')

/*COSTA RICA*/ 
DELETE FROM #Tmp_1
INSERT INTO #Tmp_1 

SELECT  Rubro,
	ISNULL(Descripcion,'Sin Clasificacion de Rubro')	AS Descrip,
        SUM(Facturado) 	AS Factu	,
        SUM(Factu_AFI)	AS Fac_Afi	,
	SUM(NC)		AS NC		,
	SUM(NCI)	AS NCI		,
	SUM(Facturado + Factu_AFI - NC - NCI) AS NetoF
FROM (

SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
       SUM(T0.LineTotal)/@CR          AS Facturado,
       0 		     AS Factu_AFI,
       0 		     AS NC,
       0 		     AS NCI
  FROM      [CVCR].[dbo].[INV1]    T0
 INNER JOIN [CVCR].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
 GROUP BY T0.U_Rubro,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'')				AS Rubro      ,
       T2.Name						AS Descripcion,
	   (SUM(T0.LineTotal)/@CR)*-1		    	AS Facturado,
       0     AS Factu_AFI,
       0 		     AS NC,
       0 		     AS NCI
  FROM      [CVCR].[dbo].[INV1]    T0
 INNER JOIN [CVCR].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
 LEFT  JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T4.Groupcode = '103'
 GROUP BY T0.U_Rubro,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
	0		     AS Facturado,
       SUM(T0.LineTotal)/@CR     AS Factu_AFI,
       0 		     AS NC,
       0 		     AS NCI
  FROM      [CVCR].[dbo].[INV1]    T0
 INNER JOIN [CVCR].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
 LEFT  JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T4.Groupcode = '103'
 GROUP BY T0.U_Rubro,
	  T2.Name

UNION ALL

/*NC Y NCI CLIENTES*/

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CR     	AS NCI
  FROM      [CVCR]. [dbo].[RIN1]    T0
 INNER JOIN [CVCR].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
  AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
  AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
       SUM(T0.LineTotal) /@CR    	AS NC,
	0 				AS NCI
  FROM      [CVCR].[dbo].[RIN1]    T0
 INNER JOIN [CVCR].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL
/*OPEN CASO ESPECIAL*/
SELECT '111' 						AS Rubro      ,
       'PEP Spots - 35 mm'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CR     	AS NCI
  FROM      [CVCR].[dbo].[RIN1]    T0
 INNER JOIN [CVCR].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
/*AND  T0.U_Rubro IS NULL*/ AND T2.Name IS NULL

UNION ALL

SELECT '112' 						AS Rubro      ,
       'PEP Spots - Cine Spots'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CR     	AS NCI
  FROM      [CVCR].[dbo].[RIN1]    T0
 INNER JOIN [CVCR].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

UNION ALL

SELECT '113' 						AS Rubro      ,
       'PEP Spots - Slides Digital'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CR     	AS NCI
  FROM      [CVCR].[dbo].[RIN1]    T0
 INNER JOIN [CVCR].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

/*CLOSE SEGMENTO DE CASOS ESPECIALES*/
/*para RESTAR*/
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CR*-1     	AS NCI
  FROM      [CVCR].[dbo].[RIN1]    T0
 INNER JOIN [CVCR].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
/*AND  T0.U_Rubro IS NULL */ AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CR*-1     	AS NCI
  FROM      [CVCR].[dbo].[RIN1]    T0
 INNER JOIN [CVCR].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CR*-1     	AS NCI
  FROM      [CVCR].[dbo].[RIN1]    T0
 INNER JOIN [CVCR].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name

/*CLOSE SEGMENTO DE CASOS ESPECIALES RESTANDO NCI*/
UNION ALL
/********OPEN CASO PARA NC*********/
SELECT '111' 						AS Rubro      ,
       'PEP Spots - 35 mm'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)/@CR  		    	 	AS NC,
       0    	AS NCI
  FROM      [CVCR].[dbo].[RIN1]    T0
 INNER JOIN [CVCR].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

UNION ALL

SELECT '112' 						AS Rubro      ,
       'PEP Spots - Cine Spots'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)/@CR 		    	 	AS NC,
       0     	AS NCI
  FROM      [CVCR].[dbo].[RIN1]    T0
 INNER JOIN [CVCR].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

UNION ALL

SELECT '113' 						AS Rubro      ,
       'PEP Spots - Slides Digital'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)/@CR  		    	 	AS NC,
       0    	AS NCI
  FROM      [CVCR].[dbo].[RIN1]    T0
 INNER JOIN [CVCR].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

/*CLOSE SEGMENTO DE CASOS ESPECIALES*/
/*para RESTAR*/
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	 SUM(T0.LineTotal)/@CR*-1 		    	 	AS NC,
      0     	AS NCI
  FROM      [CVCR].[dbo].[RIN1]    T0
 INNER JOIN [CVCR].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0								AS Facturado,
        0		   					AS Factu_AFI,
	SUM(T0.LineTotal)/@CR*-1 		AS NC,
       0     	AS NCI
  FROM      [CVCR].[dbo].[RIN1]    T0
 INNER JOIN [CVCR].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)/@CR*-1   		    	 	AS NC,
       0   	AS NCI
  FROM      [CVCR].[dbo].[RIN1]    T0
 INNER JOIN [CVCR].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name

/*CLOSE SEGMENTO DE CASOS ESPECIALES RESTANDO*/

/*********CLOSE CASO PARA NC*************/

/**/
UNION ALL
/*NC Y NCI AFILIADAS*/

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        (SUM(T0.LineTotal)/@CR)*-1 	AS Factu_AFI,
	0 		    	 	AS NC,
       0    	AS NCI
  FROM      [CVCR]. [dbo].[RIN1]    T0
 INNER JOIN [CVCR].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
  AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode = '103'
  AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        (SUM(T0.LineTotal)/@CR)*-1 	AS Factu_AFI,
       0   		AS NC,
	0 				AS NCI
  FROM      [CVCR].[dbo].[RIN1]    T0
 INNER JOIN [CVCR].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode = '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name
) T0 GROUP BY Rubro,Descripcion ORDER BY Rubro

INSERT INTO #Tmp_3 (Descripcion) VALUES ('Costa Rica')
INSERT INTO #Tmp_3 SELECT * FROM #Tmp_1 
INSERT INTO #Tmp_2 SELECT * FROM #Tmp_1 

INSERT INTO #Tmp_3 
SELECT 		''  		AS Rubro,
		' TOTALES'	AS Descripcion,
		SUM(P_VENTA),
		SUM(P_AFIL),
		SUM(P_NC),
		SUM(P_NCI),
		SUM(P_NetoF) 
FROM #Tmp_1
INSERT INTO #Tmp_3 (Descripcion) VALUES ('')


 /*PANAMA*/

DELETE FROM #Tmp_1		
INSERT INTO #Tmp_1 

SELECT  Rubro,
	ISNULL(Descripcion,'Sin Clasificacion de Rubro')	AS Descrip,
        SUM(Facturado) 	AS Factu	,
        SUM(Factu_AFI)	AS Fac_Afi	,
	SUM(NC)		AS NC		,
	SUM(NCI)	AS NCI		,
	SUM(Facturado + Factu_AFI - NC - NCI) AS NetoF
FROM (

SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
       SUM(T0.LineTotal)          AS Facturado,
       0 		     AS Factu_AFI,
       0 		     AS NC,
       0 		     AS NCI
  FROM      [CVPA].[dbo].[INV1]    T0
 INNER JOIN [CVPA].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
 GROUP BY T0.U_Rubro,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
	SUM(T0.LineTotal)*-1 AS Facturado,
       0		     AS Factu_AFI,
       0 		     AS NC,
       0 		     AS NCI
  FROM      [CVPA].[dbo].[INV1]    T0
 INNER JOIN [CVPA].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
 LEFT  JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T4.Groupcode = '103' 
 GROUP BY T0.U_Rubro,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
	0		     AS Facturado,
       SUM(T0.LineTotal)     AS Factu_AFI,
       0 		     AS NC,
       0 		     AS NCI
  FROM      [CVPA].[dbo].[INV1]    T0
 INNER JOIN [CVPA].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
 LEFT  JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T4.Groupcode = '103' 
 GROUP BY T0.U_Rubro,
	  T2.Name


/* NCI Y NC CLIENTES */
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)     	AS NCI
  FROM      [CVPA]. [dbo].[RIN1]    T0
 INNER JOIN [CVPA].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode <> '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
       SUM(T0.LineTotal)     		AS NC,
	0 				AS NCI
  FROM      [CVPA].[dbo].[RIN1]    T0
 INNER JOIN [CVPA].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode <> '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL
/*********NC Y NCI CASOS ESPECIALES***************/
/*OPEN CASO ESPECIAL*/
SELECT '111' 						AS Rubro      ,
       'PEP Spots - 35 mm'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)       	AS NCI
  FROM      [CVPA].[dbo].[RIN1]    T0
 INNER JOIN [CVPA].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

UNION ALL

SELECT '112' 						AS Rubro      ,
       'PEP Spots - Cine Spots'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)       	AS NCI
  FROM      [CVPA].[dbo].[RIN1]    T0
 INNER JOIN [CVPA].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

UNION ALL

SELECT '113' 						AS Rubro      ,
       'PEP Spots - Slides Digital'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)    	AS NCI
  FROM      [CVPA].[dbo].[RIN1]    T0
 INNER JOIN [CVPA].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

/*CLOSE SEGMENTO DE CASOS ESPECIALES*/
/*para RESTAR*/
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)*-1     	AS NCI
  FROM      [CVPA].[dbo].[RIN1]    T0
 INNER JOIN [CVPA].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)*-1     	AS NCI
  FROM      [CVPA].[dbo].[RIN1]    T0
 INNER JOIN [CVPA].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)*-1     	AS NCI
  FROM      [CVPA].[dbo].[RIN1]    T0
 INNER JOIN [CVPA].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name

/*CLOSE SEGMENTO DE CASOS ESPECIALES RESTANDO NCI*/
UNION ALL
/********OPEN CASO PARA NC*********/
SELECT '111' 						AS Rubro      ,
       'PEP Spots - 35 mm'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)  		    	 	AS NC,
       0    	AS NCI
  FROM      [CVPA].[dbo].[RIN1]    T0
 INNER JOIN [CVPA].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

UNION ALL

SELECT '112' 						AS Rubro      ,
       'PEP Spots - Cine Spots'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal) 		    	 	AS NC,
       0     	AS NCI
  FROM      [CVPA].[dbo].[RIN1]    T0
 INNER JOIN [CVPA].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

UNION ALL

SELECT '113' 						AS Rubro      ,
       'PEP Spots - Slides Digital'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)  		    	 	AS NC,
       0    	AS NCI
  FROM      [CVPA].[dbo].[RIN1]    T0
 INNER JOIN [CVPA].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL

/*CLOSE SEGMENTO DE CASOS ESPECIALES*/
/*para RESTAR*/
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	 SUM(T0.LineTotal)*-1 		    	 	AS NC,
      0     	AS NCI
  FROM      [CVPA].[dbo].[RIN1]    T0
 INNER JOIN [CVPA].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0								AS Facturado,
        0		   					AS Factu_AFI,
	SUM(T0.LineTotal)*-1 		AS NC,
       0     	AS NCI
  FROM      [CVPA].[dbo].[RIN1]    T0
 INNER JOIN [CVPA].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Cine Spots%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)*-1   		    	 	AS NC,
       0   	AS NCI
  FROM      [CVPA].[dbo].[RIN1]    T0
 INNER JOIN [CVPA].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - Slides Digital%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name

/*CLOSE SEGMENTO DE CASOS ESPECIALES RESTANDO*/

/*********CLOSE CASO PARA NC*************/

/************CLOSE NC Y NCI CASOS ESPECIALES********/


/* NCI Y NC AFILIADAS */
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        SUM(T0.LineTotal) *-1  		AS Factu_AFI,
	0 		    	 	AS NC,
       0    	AS NCI
  FROM      [CVPA].[dbo].[RIN1]    T0
 INNER JOIN [CVPA].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode = '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        SUM(T0.LineTotal) *-1  		AS Factu_AFI,
       0   		AS NC,
	0 				AS NCI
  FROM      [CVPA].[dbo].[RIN1]    T0
 INNER JOIN [CVPA].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode = '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name


) T0 GROUP BY Rubro,Descripcion ORDER BY Rubro

INSERT INTO #Tmp_3 (Descripcion) VALUES ('Panama')
INSERT INTO #Tmp_3 SELECT * FROM #Tmp_1 
INSERT INTO #Tmp_2 SELECT * FROM #Tmp_1 

INSERT INTO #Tmp_3 
SELECT 		''  		AS Rubro,
		' TOTALES'	AS Descripcion,
		SUM(P_VENTA),
		SUM(P_AFIL),
		SUM(P_NC),
		SUM(P_NCI),
		SUM(P_NetoF) 
FROM #Tmp_1
INSERT INTO #Tmp_3 (Descripcion) VALUES ('')

/* COLOMBIA*/

DELETE FROM #Tmp_1
INSERT INTO #Tmp_1 

SELECT  Rubro,
	ISNULL(Descripcion,'Sin Clasificacion de Rubro')	AS Descrip,
        SUM(Facturado) 	AS Factu	,
        SUM(Factu_AFI)	AS Fac_Afi	,
	SUM(NC)		AS NC		,
	SUM(NCI)	AS NCI		,
	SUM(Facturado + Factu_AFI - NC - NCI) AS NetoF
FROM (

SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
       SUM(T0.LineTotal)/@CO          AS Facturado,
       0 		     AS Factu_AFI,
       0 		     AS NC,
       0 		     AS NCI
  FROM      [CVCO].[dbo].[INV1]    T0
 INNER JOIN [CVCO].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
 GROUP BY T0.U_Rubro,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'')				AS Rubro      ,
       T2.Name								AS Descripcion,
	   (SUM(T0.LineTotal)/@CO)*-1		    AS Facturado,
       0									AS Factu_AFI,
       0 									AS NC,
       0 									AS NCI
  FROM      [CVCO].[dbo].[INV1]    T0
 INNER JOIN [CVCO].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
 LEFT  JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T4.Groupcode = '103'
 GROUP BY T0.U_Rubro,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
	0		     AS Facturado,
       SUM(T0.LineTotal)/@CO     AS Factu_AFI,
       0 		     AS NC,
       0 		     AS NCI
  FROM      [CVCO].[dbo].[INV1]    T0
 INNER JOIN [CVCO].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
 LEFT  JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T4.Groupcode = '103'
 GROUP BY T0.U_Rubro,
	  T2.Name

UNION ALL
/*NC Y NCI CLIENTES*/
SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO     	AS NCI
  FROM      [CVCO]. [dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode <> '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
       SUM(T0.LineTotal) /@CO    		AS NC,
	0 				AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode <> '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

/*********NC Y NCI CASOS ESPECIALES***************/
/*OPEN CASO ESPECIAL*/
SELECT '101' 						AS Rubro      ,
       'PEP Spots - 35 mm CineColombia'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO       	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0

UNION ALL
SELECT '111' 						AS Rubro      ,
       'PEP Spots - 35 mm  Cinemark'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO       	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0

UNION ALL

SELECT '112' 						AS Rubro      ,
       'PEP Spots - DVD  Cinemark'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO       	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - DVD Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0

UNION ALL

SELECT '102' 						AS Rubro      ,
       'PEP Spots - DVD  CineColombia'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO       	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - DVD CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0

UNION ALL

SELECT '113' 						AS Rubro      ,
       'PEP Spots - SD  Cinemark'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO    	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - SD Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0

UNION ALL

SELECT '103' 						AS Rubro      ,
       'PEP Spots - SD  CineColombia'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO    	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - SD CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0

/*CLOSE SEGMENTO DE CASOS ESPECIALES*/
/*para RESTAR */
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO*-1     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO*-1     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO*-1     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - DVD Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO*-1     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - DVD CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO*-1     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - SD Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0

UNION ALL
SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO*-1     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - SD CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0
/*CLOSE SEGMENTO DE CASOS ESPECIALES RESTANDO NCI*/

UNION ALL
/********OPEN CASO PARA NC*********/
SELECT '101' 						AS Rubro      ,
       'PEP Spots - 35 mm CineColombia'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO       	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0

UNION ALL
SELECT '111' 						AS Rubro      ,
       'PEP Spots - 35 mm  Cinemark'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO       	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0

UNION ALL

SELECT '112' 						AS Rubro      ,
       'PEP Spots - DVD  Cinemark'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO       	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - DVD Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0

UNION ALL

SELECT '102' 						AS Rubro      ,
       'PEP Spots - DVD  CineColombia'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO       	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - DVD CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0

UNION ALL

SELECT '113' 						AS Rubro      ,
       'PEP Spots - SD  Cinemark'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO    	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - SD Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0

UNION ALL

SELECT '103' 						AS Rubro      ,
       'PEP Spots - SD  CineColombia'               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO    	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - SD CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0

/*CLOSE SEGMENTO DE CASOS ESPECIALES*/
/*para RESTAR */
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO*-1     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO*-1     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO*-1     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - DVD Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO*-1     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - DVD CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO*-1     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - SD Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0

UNION ALL
SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO*-1     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - SD CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY T0.U_Rubro      ,
	  T2.Name,T0.LineTotal HAVING T0.LineTotal<>0

/*CLOSE SEGMENTO DE CASOS ESPECIALES RESTANDO*/

/*********CLOSE CASO PARA NC*************/

/************CLOSE NC Y NCI CASOS ESPECIALES********/
UNION ALL 

/*NC Y NCI AFILIADAS*/
SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        (SUM(T0.LineTotal) /@CO) *-1    AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)/@CO     	AS NCI
  FROM      [CVCO]. [dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode = '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS Facturado,
        (SUM(T0.LineTotal) /@CO) *-1	AS Factu_AFI,
       0   		AS NC,
	0 				AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode = '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name
) T0 GROUP BY Rubro,Descripcion ORDER BY Rubro

INSERT INTO #Tmp_3 (Descripcion) VALUES ('Colombia')
INSERT INTO #Tmp_3 SELECT * FROM #Tmp_1 
INSERT INTO #Tmp_2 SELECT * FROM #Tmp_1 

INSERT INTO #Tmp_3 
SELECT 		''  		AS Rubro,
		' TOTALES'	AS Descripcion,
		SUM(P_VENTA),
		SUM(P_AFIL),
		SUM(P_NC),
		SUM(P_NCI),
		SUM(P_NetoF) 
FROM #Tmp_1
INSERT INTO #Tmp_3 (Descripcion) VALUES ('')










--select cvgt.dbo.ortt 

--select * from cvsv.dbo.oinv
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[SIG_VtaPEP35mmSCO_v11] 
@Fecha1 AS DATETIME,
@Fecha2 AS DATETIME,
@gt as numeric(19,4),
@HN AS NUMERIC(19,4),
@NI AS NUMERIC(19,4),
@CR AS NUMERIC(19,4),
@CO as numeric(19,4) = null


AS
INSERT INTO #SIGConso_VENTA
SELECT  
	'PEP Spots - 35 mm'	AS Descrip,
        SUM(GT)/@gt 	AS GT	,
        SUM(SV) 	AS SV	,
       SUM(HN)/@HN        	AS HN   ,
       SUM(NI)/@NI        	AS NI   ,	   
       SUM(CR)/@CR        	AS CR   ,
       SUM(PA)        		AS PA   ,
	SUM(GT)/@gt+ SUM(SV)+ SUM(HN)/@HN + SUM(NI)/@NI + SUM(CR)/@CR + SUM(PA) AS NetoF
FROM (
	/* GUATEMALA */
SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
      SUM(T0.LineTotal)      AS gt,
		0 AS SV,
       0 		     AS HN,
       0 		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      cvgt.[dbo].[INV1]    T0
 INNER JOIN cvgt.[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN cvgt.[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T0.U_Rubro<>'311'
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
 GROUP BY T0.U_Rubro,
	  T2.Name

UNION ALL
/*restando AFI*/
SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
       SUM(T0.LineTotal) *-1		     AS GT,
	0 as sv,
	 0 		     AS HN,
       0 		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      cvgt.[dbo].[INV1]    T0
 INNER JOIN cvgt.[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
 LEFT  JOIN cvgt.[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN cvgt.[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T0.U_Rubro<>'311'
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
   AND T3.Groupcode = '103'
 GROUP BY T0.U_Rubro,
	  T2.Name


UNION ALL

/*NCI Y NC CLIENTES*/
SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	SUM(T0.LineTotal) *-1				AS gt,
		0 as sv,
       0 		     AS HN,
       0 		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      cvgt. [dbo].[RIN1]    T0
 INNER JOIN cvgt.[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN cvgt.[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN cvgt.[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T3.Groupcode <> '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
   AND T0.U_Rubro<>'311'
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	SUM(T0.LineTotal) *-1				AS gt,
	0 as sv,
      0 		     AS HN,
       0 		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      cvgt. [dbo].[RIN1]    T0
 INNER JOIN cvgt.[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN cvgt.[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN cvgt.[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T3.Groupcode <> '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
   AND T0.U_Rubro<>'311'
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL
/*OPEN CASO ESPECIAL*/
SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	SUM(T0.LineTotal) *-1				AS gt,
	0 as sv,
       0 		     AS HN,
       0 		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      cvgt. [dbo].[RIN1]    T0
 INNER JOIN cvgt.[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN cvgt.[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN cvgt.[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T3.Groupcode <> '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
   AND T0.U_Rubro<>'311'
   AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
 GROUP BY T0.U_Rubro      ,
	  T2.Name


UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	SUM(T0.LineTotal) *-1				AS gt,
	0 as sv,
       0 		     AS HN,
       0 		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      cvgt. [dbo].[RIN1]    T0
 INNER JOIN cvgt.[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN cvgt.[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN cvgt.[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T3.Groupcode <> '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
   AND T0.U_Rubro<>'311'
   AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
 GROUP BY T0.U_Rubro ,
	  T2.Name
 
	/* CLOSE ESPECIAL*/

	UNION ALL

	/* EL SALVADOR */
SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
	0			AS GT,
      SUM(T0.LineTotal)      AS SV,
       0 		     AS HN,
       0 		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      [CVSV].[dbo].[INV1]    T0
 INNER JOIN [CVSV].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T0.U_Rubro<>'311'
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
 GROUP BY T0.U_Rubro,
	  T2.Name

UNION ALL
/*restando AFI*/
SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
	0			AS GT,
       SUM(T0.LineTotal) *-1		     AS SV,
	 0 		     AS HN,
       0 		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      [CVSV].[dbo].[INV1]    T0
 INNER JOIN [CVSV].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
 LEFT  JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T0.U_Rubro<>'311'
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
   AND T3.Groupcode = '103'
 GROUP BY T0.U_Rubro,
	  T2.Name


UNION ALL

/*NCI Y NC CLIENTES*/
SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0			AS GT,
	SUM(T0.LineTotal) *-1				AS SV,
       0 		     AS HN,
       0 		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      [CVSV]. [dbo].[RIN1]    T0
 INNER JOIN [CVSV].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T3.Groupcode <> '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
   AND T0.U_Rubro<>'311'
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0			AS GT,
	SUM(T0.LineTotal) *-1				AS SV,
      0 		     AS HN,
       0 		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      [CVSV]. [dbo].[RIN1]    T0
 INNER JOIN [CVSV].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T3.Groupcode <> '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
   AND T0.U_Rubro<>'311'
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL
/*OPEN CASO ESPECIAL*/
SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0			AS GT,
	SUM(T0.LineTotal) *-1				AS SV,
       0 		     AS HN,
       0 		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      [CVSV]. [dbo].[RIN1]    T0
 INNER JOIN [CVSV].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T3.Groupcode <> '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
   AND T0.U_Rubro<>'311'
   AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
 GROUP BY T0.U_Rubro      ,
	  T2.Name


UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0			AS GT,
	SUM(T0.LineTotal) *-1				AS SV,
       0 		     AS HN,
       0 		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      [CVSV]. [dbo].[RIN1]    T0
 INNER JOIN [CVSV].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT  JOIN [CVSV].[dbo].[OCRD] T3 ON T1.CardCode = T3.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T3.Groupcode <> '103'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
   AND T0.U_Rubro<>'311'
   AND T1.Comments LIKE 'PEP Spots - 35 mm%'
   AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
 GROUP BY T0.U_Rubro ,
	  T2.Name
 
/* CLOSE ESPECIAL*/

UNION ALL
/*HONDURAS*/

SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
	0			AS GT,
      0			     AS SV,
       SUM(T0.LineTotal)      AS HN,
       0 		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      [CVHN].[dbo].[INV1]    T0
 INNER JOIN [CVHN].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
 GROUP BY T0.U_Rubro,
	  T2.Name

UNION ALL

/*restando AFI*/
SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
	0			AS GT,
       0		     AS SV,
	SUM(T0.LineTotal) *-1 	AS HN,
       0 		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      [CVHN].[dbo].[INV1]    T0
 INNER JOIN [CVHN].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
 LEFT  JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
   AND T4.Groupcode = '103'
 GROUP BY T0.U_Rubro,
	  T2.Name


UNION ALL

/* NCI Y NC CLIENTES*/

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS GT,
	0				AS SV,
       SUM(T0.LineTotal) *-1 		     AS HN,
       0 		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      [CVHN]. [dbo].[RIN1]    T0
 INNER JOIN [CVHN].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode <> '103'
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0			AS GT,
	0				AS SV,
      SUM(T0.LineTotal) *-1 		     AS HN,
       0 		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      [CVHN].[dbo].[RIN1]    T0
 INNER JOIN [CVHN].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode <> '103'
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL
/*OPEN CASO ESPECIAL */
SELECT '111' 						AS Rubro      ,
       'PEP Spots - 35 mm'               		AS Descripcion,
	0				AS GT,
	0				AS SV,
       SUM(T0.LineTotal) *-1 		     AS HN,
       0 		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      [CVHN].[dbo].[RIN1]    T0
 INNER JOIN [CVHN].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'

UNION ALL

SELECT '111' 						AS Rubro      ,
       'PEP Spots - 35 mm'               		AS Descripcion,
	0				AS GT,
	0				AS SV,
       SUM(T0.LineTotal) *-1 		     AS HN,
       0 		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      [CVHN].[dbo].[RIN1]    T0
 INNER JOIN [CVHN].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVHN].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVHN].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'

/*CLOSE CASO ESPECIAL*/
/**/

/*NICARAGUA*/
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
	0		     AS GT,
      0			     AS SV,
      0    			AS HN,
        SUM(T0.LineTotal)     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      [CVNI].[dbo].[INV1]    T0
 INNER JOIN [CVNI].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
 GROUP BY T0.U_Rubro,
	  T2.Name

UNION ALL

/*restando AFI*/
SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
	0			AS GT,
       0		     AS SV,
	0 	AS HN,
       SUM(T0.LineTotal) *-1     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      [CVNI].[dbo].[INV1]    T0
 INNER JOIN [CVNI].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
 LEFT  JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
   AND T4.Groupcode = '103'
 GROUP BY T0.U_Rubro,
	  T2.Name


UNION ALL

/* NCI Y NC CLIENTES*/

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS GT,
	0				AS SV,
       0		     AS HN,
       SUM(T0.LineTotal) *-1  		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      [CVNI]. [dbo].[RIN1]    T0
 INNER JOIN [CVNI].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode <> '103'
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0			AS GT,
	0				AS SV,
     0 		     			AS HN,
        SUM(T0.LineTotal) *-1 		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      [CVNI].[dbo].[RIN1]    T0
 INNER JOIN [CVNI].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode <> '103'
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL
/*OPEN CASO ESPECIAL */
SELECT '111' 						AS Rubro      ,
       'PEP Spots - 35 mm'               		AS Descripcion,
	0				AS GT,
	0				AS SV,
       0		     AS HN,
       SUM(T0.LineTotal) *-1  		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      [CVNI].[dbo].[RIN1]    T0
 INNER JOIN [CVNI].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'

UNION ALL

SELECT '111' 						AS Rubro      ,
       'PEP Spots - 35 mm'               		AS Descripcion,
	0				AS GT,
	0				AS SV,
       0 		     AS HN,
       SUM(T0.LineTotal) *-1 		     AS NI,
       0 		     AS CR,
       0 		     AS PA
  FROM      [CVNI].[dbo].[RIN1]    T0
 INNER JOIN [CVNI].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVNI].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVNI].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'

/*CLOSE CASO ESPECIAL*/
/**/
/*COSTARICA*/
UNION ALL
SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
	0		     AS GT,
      0			     AS SV,
      0    			AS HN,
       0    AS NI,
        SUM(T0.LineTotal)  		     AS CR,
       0 		     AS PA
  FROM      [CVCR].[dbo].[INV1]    T0
 INNER JOIN [CVCR].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
 GROUP BY T0.U_Rubro,
	  T2.Name

UNION ALL

/*restando AFI*/
SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
	0			AS GT,
       0		     AS SV,
	0 	AS HN,
       0    AS NI,
       SUM(T0.LineTotal) *-1      AS CR,
       0 		     AS PA
  FROM      [CVCR].[dbo].[INV1]    T0
 INNER JOIN [CVCR].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
 LEFT  JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
   AND T4.Groupcode = '103'
 GROUP BY T0.U_Rubro,
	  T2.Name


UNION ALL

/* NCI Y NC CLIENTES*/

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS GT,
	0				AS SV,
       0		     AS HN,
       0 		     AS NI,
       SUM(T0.LineTotal) *-1  		     AS CR,
       0 		     AS PA
  FROM      [CVCR]. [dbo].[RIN1]    T0
 INNER JOIN [CVCR].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode <> '103'
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

/**/
/*OPEN CASO ESPECIAL */
SELECT '111' 						AS Rubro      ,
       'PEP Spots - 35 mm'               		AS Descripcion,
	0				AS GT,
	0				AS SV,
       0		     AS HN,
       0 		     AS NI,
       SUM(T0.LineTotal) *-1  		     AS CR,
       0 		     AS PA
  FROM      [CVCR].[dbo].[RIN1]    T0
 INNER JOIN [CVCR].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
/*AND  T0.U_Rubro IS NULL */AND T2.Name IS NULL
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'

UNION ALL

SELECT '111' 						AS Rubro      ,
       'PEP Spots - 35 mm'               		AS Descripcion,
	0				AS GT,
	0				AS SV,
       0		     AS HN,
       0 		     AS NI,
       SUM(T0.LineTotal) *-1  		     AS CR,
       0 		     AS PA
  FROM      [CVCR].[dbo].[RIN1]    T0
 INNER JOIN [CVCR].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
/*AND  T0.U_Rubro IS NULL*/ AND T2.Name IS NULL
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'

/*CLOSE CASO ESPECIAL*/
/**/
UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0			AS GT,
	0				AS SV,
     0 		     			AS HN,
       0 		     AS NI,
        SUM(T0.LineTotal) *-1 		     AS CR,
       0 		     AS PA
  FROM      [CVCR].[dbo].[RIN1]    T0
 INNER JOIN [CVCR].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCR].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT  JOIN [CVCR].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode <> '103'
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
 GROUP BY T0.U_Rubro      ,
	  T2.Name

/*PANAMA*/

UNION ALL
SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
	0		     AS GT,
      0			     AS SV,
      0    			AS HN,
       0    AS NI,
0  		     AS CR,
        SUM(T0.LineTotal) 		     AS PA
  FROM      [CVPA].[dbo].[INV1]    T0
 INNER JOIN [CVPA].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
 GROUP BY T0.U_Rubro,
	  T2.Name

UNION ALL

/*restando AFI*/
SELECT ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
	0			AS GT,
       0		     AS SV,
	0 	AS HN,
       0    AS NI,
       0      AS CR,
       SUM(T0.LineTotal) *-1 		     AS PA
  FROM      [CVPA].[dbo].[INV1]    T0
 INNER JOIN [CVPA].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
 LEFT  JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
   AND T4.Groupcode = '103'
 GROUP BY T0.U_Rubro,
	  T2.Name


UNION ALL

/* NCI Y NC CLIENTES*/

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0				AS GT,
	0				AS SV,
       0		     AS HN,
       0 		     AS NI,
       0  		     AS CR,
       SUM(T0.LineTotal) *-1 		     AS PA
  FROM      [CVPA]. [dbo].[RIN1]    T0
 INNER JOIN [CVPA].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode <> '103'
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'

 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL

SELECT ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	0			AS GT,
	0				AS SV,
     0 		     			AS HN,
       0 		     AS NI,
        0 		     AS CR,
       SUM(T0.LineTotal) *-1 		     AS PA
  FROM      [CVPA].[dbo].[RIN1]    T0
 INNER JOIN [CVPA].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T4.Groupcode <> '103'
   AND T2.Name LIKE 'PEP Spots - 35 mm%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
 GROUP BY T0.U_Rubro      ,
	  T2.Name

UNION ALL
/*OPEN CASO ESPECIAL */
SELECT '111' 						AS Rubro      ,
       'PEP Spots - 35 mm'               		AS Descripcion,
	0				AS GT,
	0				AS SV,
      0 		     AS HN,
       0 		     AS NI,
       0 		     AS CR,
        SUM(T0.LineTotal) *-1 		     AS PA
  FROM      [CVPA].[dbo].[RIN1]    T0
 INNER JOIN [CVPA].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'

UNION ALL

SELECT '111' 						AS Rubro      ,
       'PEP Spots - 35 mm'               		AS Descripcion,
	0				AS GT,
	0				AS SV,
       0		     AS HN,
       0 		     AS NI,
       0 		     AS CR,
       SUM(T0.LineTotal) *-1  		     AS PA
  FROM      [CVPA].[dbo].[RIN1]    T0
 INNER JOIN [CVPA].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVPA].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVPA].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
  AND T4.Groupcode <> '103'
AND T1.Comments LIKE 'PEP Spots - 35 mm%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'

/*CLOSE CASO ESPECIAL*/
/**/
/*COLOMBIA	SE QUITO PARA CUMPLIR REQ*/

) T0 
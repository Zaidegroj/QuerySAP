set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


/*
		Release History:
						r01	-	Se delimita que no muestre las ventas de Theatrical para todos los países
*/

ALTER  PROCEDURE [dbo].[CxCA60SIN_AFIACTUAL]

@Fecha AS DATETIME,
@GT AS NUMERIC(19,4),
@HN AS NUMERIC(19,4),
@CR AS NUMERIC(19,4),
@DO AS NUMERIC(19,4)
AS
INSERT INTO #SIGConso_CxC
	SELECT 
       /*NORMAL   	AS CARTERA  , */
		A60		AS CARTERA ,
       SUM(GT)/@GT	AS 'GT',    
       SUM(SV)      AS 'SV'  ,   
       SUM(HN)/@HN  AS 'HN'   ,
       SUM(CR)/@CR  AS 'CR'   ,
       SUM(PA)      AS 'PA'   ,
       SUM(DO)/@DO  AS 'DO'  ,
	SUM(GT)/@GT + SUM(SV)+ SUM(HN)/@HN + SUM(CR)/@CR +SUM(PA)+SUM(DO)/@DO AS TOTAL
FROM (

/*GUATEMALA*/
SELECT 
   'A 60 Dias'                                 AS A60 ,  
	CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >=   31 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <=  60
       THEN (T0.DocTotal - T0.PaidToDate) END        AS GT,
	0 AS SV,    
	0 AS HN,
	0 AS CR,
	0 AS PA,
	0 AS DO
   FROM  PRGT.DBO.OINV T0
LEFT JOIN PRGT.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
 WHERE  T0.TaxDate                   <= @Fecha
   AND (T0.DocTotal - T0.PaidToDate) <> 0
   AND T1.GroupCode <> '104' AND T1.GroupCode <> '107' AND T1.GroupCode <> '108'


UNION ALL


SELECT 
  'A 60 Dias'                                 AS A60 ,  
	CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >=   31 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <=  60
       THEN (T0.DocTotal - T0.PaidToDate)*-1 END          AS GT,
	0 AS SV, 
	0 AS HN,   
	0 AS CR,
	0 AS PA,
	0 AS DO
   FROM  PRGT.DBO.ORIN T0
LEFT JOIN PRGT.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
 WHERE  T0.TaxDate                   <= @Fecha
   AND (T0.DocTotal - T0.PaidToDate) <> 0
    AND  T0.DocStatus                  = 'O'
    AND  T0.BaseAmnt                   =  0
   AND T1.GroupCode <> '104' AND T1.GroupCode <> '107' AND T1.GroupCode <> '108'


UNION ALL

/*EL SALVADOR*/
SELECT 
  'A 60 Dias'                                 AS A60 ,  
 	0 AS GT,  
  CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >=   31 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <=  60
       THEN (T0.DocTotal - T0.PaidToDate) END         AS SV,
	0 AS HN,
	0 AS CR,
	0 AS PA,
	0 AS DO
   FROM  VMSV.DBO.OINV T0
LEFT JOIN VMSV.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
 WHERE  T0.TaxDate                   <= @Fecha
   AND (T0.DocTotal - T0.PaidToDate) <> 0
   AND T1.GroupCode <> '104' AND  T0.CardCode<>'c60018' and T1.GroupCode <> 108


UNION ALL

SELECT 
  'A 60 Dias'                                 AS A60 ,  
 	0 AS GT,  
  CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >=   31 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <=  60
       THEN (T0.DocTotal - T0.PaidToDate)*-1 END       AS SV,
	0 AS HN,
	0 AS CR,
	0 AS PA,
	0 AS DO
   FROM  VMSV.DBO.ORIN T0
LEFT JOIN VMSV.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
 WHERE  T0.TaxDate                   <= @Fecha
   AND (T0.DocTotal - T0.PaidToDate) <> 0
 AND  T0.DocStatus                  = 'O'
    AND  T0.BaseAmnt                   =  0
   AND T1.GroupCode <> '104'   AND  T0.CardCode<>'c60018' and T1.GroupCode <> 108



UNION ALL
/*HONDURAS*/
SELECT 
  'A 60 Dias'                                 AS A60 ,  
 	0 AS GT,  
	0      AS SV,
  CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >=   31 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <=  60
       THEN (T0.DocTotal - T0.PaidToDate) END   AS HN,	
	0 AS CR,
	0 AS PA,
	0 AS DO
   FROM  PRHN.DBO.OINV T0
LEFT JOIN PRHN.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
 WHERE  T0.TaxDate                   <= @Fecha
   AND (T0.DocTotal - T0.PaidToDate) <> 0
   AND T1.GroupCode <> '104' and T1.GroupCode <> 107


UNION ALL

SELECT 
  'A 60 Dias'                                 AS A60 ,  
 	0 AS GT,  
	0    AS SV,
	CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >=   31 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <=  60
       THEN (T0.DocTotal - T0.PaidToDate)*-1 END       AS HN,	
	0 AS CR,
	0 AS PA,
	0 AS DO
   FROM  PRHN.DBO.ORIN T0
LEFT JOIN PRHN.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
 WHERE  T0.TaxDate                   <= @Fecha
   AND (T0.DocTotal - T0.PaidToDate) <> 0
 AND  T0.DocStatus                  = 'O'
    AND  T0.BaseAmnt                   =  0
   AND T1.GroupCode <> '104' and T1.GroupCode <> 107



UNION ALL

/*COSTA RICA*/

SELECT 
	'A 60 Dias'                                 AS A60 ,  
	0 AS GT,
	0 AS SV,    
	0 AS HN,
 CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >=   31 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <=  60
       THEN (T0.DocTotal - T0.PaidToDate) END         AS CR,
	0 AS PA,
	0 AS DO
   FROM  VMCR.DBO.OINV T0
LEFT JOIN VMCR.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
 WHERE  T0.TaxDate                   <= @Fecha
   AND (T0.DocTotal - T0.PaidToDate) <> 0
   AND T1.GroupCode <> '103' AND T1.GroupCode <> '107'

UNION ALL

SELECT 
	'A 60 Dias'                                 AS A60 ,  
	0 AS GT,
	0 AS SV,   
	0 AS HN, 
  CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >=   31 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <=  60
       THEN (T0.DocTotal - T0.PaidToDate)*-1 END         AS CR,
	0 AS PA,
	0 AS DO
   FROM  VMCR.DBO.ORIN T0
LEFT JOIN VMCR.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
 WHERE  T0.TaxDate                   <= @Fecha
   AND (T0.DocTotal - T0.PaidToDate) <> 0
 AND  T0.DocStatus                  = 'O'
    AND  T0.BaseAmnt               =  0
   AND T1.GroupCode <> '103' AND T1.GroupCode <> '107'

UNION ALL

/* PANAMA */
SELECT 
	'A 60 Dias'                                 AS A60 ,  
	0 AS GT,
	0 AS SV,  
	0 AS HN,  
	0 AS CR,
  CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >=   31 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <=  60
       THEN (T0.DocTotal - T0.PaidToDate) END      AS PA,
	0 AS DO
   FROM  VMPA.DBO.OINV T0
LEFT JOIN VMPA.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
 WHERE  T0.TaxDate                   <= @Fecha
   AND (T0.DocTotal - T0.PaidToDate) <> 0
   AND T1.GroupCode <> '104' AND T1.GroupCode <> '107' 

UNION ALL

SELECT 
	'A 60 Dias'                                 AS A60 ,  
	0 AS GT,
	0 AS SV,  
	0 AS HN,  
	0 AS CR,
 CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >=   31 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <=  60
       THEN (T0.DocTotal - T0.PaidToDate)*-1 END        AS PA,
	0 AS DO
   FROM  VMPA.DBO.ORIN T0
LEFT JOIN VMPA.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
 WHERE  T0.TaxDate                   <= @Fecha
   AND (T0.DocTotal - T0.PaidToDate) <> 0
    AND  T0.DocStatus                  = 'O'
    AND  T0.BaseAmnt               =  0
   AND T1.GroupCode <> '104' AND T1.GroupCode <> '107' 

UNION ALL

/* DOMINICANA*/

SELECT 
	'A 60 Dias'                                 AS A60 ,  
	0 AS GT,
	0 AS SV,
	0 AS HN,    
	0 AS CR,
	0 AS PA,
  CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >=   31 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <=  60
       THEN (T0.DocTotal - T0.PaidToDate) END       AS DO
   FROM  VMDO.DBO.OINV T0
LEFT JOIN VMDO.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
 WHERE  T0.TaxDate                   <= @Fecha
   AND (T0.DocTotal - T0.PaidToDate) <> 0
   AND T1.GroupCode <> '104' and T1.GroupCode <> 107

UNION ALL

SELECT 
	'A 60 Dias'                                 AS A60 ,  
	0 AS GT,
	0 AS SV, 
	0 AS HN,   
	0 AS CR,
	0 AS PA,
  CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >=   31 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <=  60
       THEN (T0.DocTotal - T0.PaidToDate)*-1 END        AS DO
   FROM  VMDO.DBO.ORIN T0
LEFT JOIN VMDO.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
 WHERE  T0.TaxDate                   <= @Fecha
   AND (T0.DocTotal - T0.PaidToDate) <> 0
	AND  T0.DocStatus                  = 'O'
    AND  T0.BaseAmnt               =  0
   AND T1.GroupCode <> '104' and T1.GroupCode <> 107

) T0 GROUP BY A60











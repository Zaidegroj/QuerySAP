set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go





ALTER PROCEDURE [dbo].[SIG_CxCM120SAFI]

@Fecha as datetime,
@gt as  numeric (19,4),
@HN AS NUMERIC(19,4),
@NI AS NUMERIC(19,4),
@CR AS NUMERIC(19,4),
@CO AS NUMERIC(19,4)

AS
INSERT INTO #SIGConso_CxC
SELECT 
       M120   	AS CARTERA  , 
       SUM(GT)/@gt	as 'GT'			,    
       SUM(SV)      	AS 'SV'  ,
       SUM(HN)/@HN        	AS 'HN'   ,
       SUM(NI)/@NI        	AS 'NI'   ,	   
       SUM(CR)/@CR        	AS 'CR'   ,
       SUM(PA)        		AS 'PA'   ,
       SUM(CO)/@CO        	AS 'CO'  ,
	SUM(GT)/@gt+ SUM(SV)+ SUM(HN)/@HN + SUM(NI)/@NI + SUM(CR)/@CR + SUM(PA)+ SUM(CO)/@CO AS TOTAL
FROM (

	/*Guatemala*/	

	SELECT 
		'Mas de 120 Dias'                                 AS M120 ,  
		CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 121
			THEN (T0.DocTotal - T0.PaidToDate) END     AS gt,
		0 as sv,
		0 AS HN,
		0 AS NI,
		0 AS CR,
		0 AS PA,
		0 AS CO
	FROM  CVgt.DBO.OINV T0
		LEFT JOIN CVgt.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
	WHERE  T0.TaxDate                   <= @Fecha
		AND (T0.DocTotal - T0.PaidToDate) <> 0
		AND T1.GroupCode <> '103'

	UNION ALL

	SELECT 
		'Mas de 120 Dias'                                 AS M120 ,  
  		CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 121
			THEN (T0.DocTotal - T0.PaidToDate)*-1 END AS gt     ,
		0 as sv,
		0 AS HN,
		0 AS NI,
		0 AS CR,
		0 AS PA,
		0 AS CO
	FROM CVgt.DBO.ORIN T0
		LEFT JOIN CVgt.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
	WHERE  T0.TaxDate                   <= @Fecha
		AND (T0.DocTotal - T0.PaidToDate) <>  0
		AND  T0.DocStatus                  = 'O'
		AND  T0.BaseAmnt                   =  0
		AND T1.GroupCode <> '103'

	union all 

	/*El Salvador*/

	SELECT 
		'Mas de 120 Dias'                                 AS M120 ,  
	 	0 AS GT,  
		CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 121
			THEN (T0.DocTotal - T0.PaidToDate) END     AS SV,
		0 AS HN,
		0 AS NI,
		0 AS CR,
		0 AS PA,
		0 AS CO
	FROM  CVSV.DBO.OINV T0
		LEFT JOIN CVSV.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
	WHERE  T0.TaxDate                   <= @Fecha
		AND (T0.DocTotal - T0.PaidToDate) <> 0
		AND T1.GroupCode <> '103'

	UNION ALL

	SELECT 
		'Mas de 120 Dias'                                 AS M120 ,  
		0 AS GT,   
  		CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 121
			THEN (T0.DocTotal - T0.PaidToDate)*-1 END AS SV     ,
		0 AS HN,
		0 AS NI,
		0 AS CR,
		0 AS PA,
		0 AS CO
	FROM CVSV.DBO.ORIN T0
		LEFT JOIN CVSV.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
	WHERE  T0.TaxDate                   <= @Fecha
		AND (T0.DocTotal - T0.PaidToDate) <>  0
		AND  T0.DocStatus                  = 'O'
		AND  T0.BaseAmnt                   =  0
		AND T1.GroupCode <> '103'

	UNION ALL

	/*HONDURAS*/

	SELECT 
		'Mas de 120 Dias'                                 AS M120 ,  
		0 AS GT,
		0 AS SV,    
		CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 121
			THEN (T0.DocTotal - T0.PaidToDate) END      AS HN,
		0 AS NI,
		0 AS CR,
		0 AS PA,
		0 AS CO
	FROM  CVHN.DBO.OINV T0
		LEFT JOIN CVHN.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
	WHERE  T0.TaxDate                   <= @Fecha
		AND (T0.DocTotal - T0.PaidToDate) <> 0
		AND T1.GroupCode <> '103'

	UNION ALL

	SELECT 
		'Mas de 120 Dias'                                 AS M120 ,  
		0 AS GT,
		0 AS SV,
		CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 121
			THEN (T0.DocTotal - T0.PaidToDate)*-1 END    AS HN,
		0 AS NI,
		0 AS CR,
		0 AS PA,
		0 AS CO
	FROM CVHN.DBO.ORIN T0
		LEFT JOIN CVHN.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
	WHERE  T0.TaxDate                   <= @Fecha
		AND (T0.DocTotal - T0.PaidToDate) <>  0
		AND  T0.DocStatus                  = 'O'
		AND  T0.BaseAmnt                   =  0
		AND T1.GroupCode <> '103'

	UNION ALL

	/*NICARAGUA*/

	SELECT 
		'Mas de 120 Dias'                                 AS M120 ,  
		0 AS GT,
		0 AS SV,    
		0 AS HN,
		CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 121
			THEN (T0.DocTotal - T0.PaidToDate) END      AS NI,
		0 AS CR,
		0 AS PA,
		0 AS CO
	FROM  CVNI.DBO.OINV T0
		LEFT JOIN CVNI.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
	WHERE  T0.TaxDate                   <= @Fecha
		AND (T0.DocTotal - T0.PaidToDate) <> 0
		AND T1.GroupCode <> '103'

	UNION ALL

	SELECT 
		'Mas de 120 Dias'                                 AS M120 ,  
		0 AS GT,
		0 AS SV,
		0 AS HN,
		CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 121
			THEN (T0.DocTotal - T0.PaidToDate)*-1 END  AS NI,
		0 AS CR,
		0 AS PA,
		0 AS CO
	FROM CVNI.DBO.ORIN T0
		LEFT JOIN CVNI.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
	WHERE  T0.TaxDate                   <= @Fecha
		AND (T0.DocTotal - T0.PaidToDate) <>  0
		AND  T0.DocStatus                  = 'O'
		AND  T0.BaseAmnt                   =  0
		AND T1.GroupCode <> '103'

	UNION ALL
	
	/*COSTA RICA*/

	SELECT 
		'Mas de 120 Dias'                                 AS M120 ,  
		0 AS GT,
		0 AS SV,    
		0 AS HN,
		0 AS NI,
		CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 121
			THEN (T0.DocTotal - T0.PaidToDate) END           AS CR,
		0 AS PA,
		0 AS CO
	FROM  CVCR.DBO.OINV T0
		LEFT JOIN CVCR.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
	WHERE  T0.TaxDate                   <= @Fecha
		AND (T0.DocTotal - T0.PaidToDate) <> 0
		AND T1.GroupCode <> '103'

	UNION ALL

	SELECT 
		'Mas de 120 Dias'                                 AS M120 ,  
		0 AS GT,
		0 AS SV,
		0 AS HN,
		0 AS NI,
		CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 121
			THEN (T0.DocTotal - T0.PaidToDate)*-1 END      AS CR,
		0 AS PA,
		0 AS CO
	FROM CVCR.DBO.ORIN T0
		LEFT JOIN CVCR.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
	WHERE  T0.TaxDate                   <= @Fecha
		AND (T0.DocTotal - T0.PaidToDate) <>  0
		AND  T0.DocStatus                  = 'O'
		AND  T0.BaseAmnt                   =  0
		AND T1.GroupCode <> '103'

	UNION ALL

	/* PANAMA */

	SELECT 
		'Mas de 120 Dias'                                 AS M120 ,  
		0 AS GT,
		0 AS SV,    
		0 AS HN,
		0 AS NI,
		0 AS CR,
	    CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 121
		   THEN (T0.DocTotal - T0.PaidToDate) END          AS PA,
		0 AS CO
	FROM  CVPA.DBO.OINV T0
		LEFT JOIN CVPA.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
		WHERE  T0.TaxDate                   <= @Fecha
		AND (T0.DocTotal - T0.PaidToDate) <> 0
		AND T1.GroupCode <> '103'

	UNION ALL

	SELECT 
		'Mas de 120 Dias'                                 AS M120 ,  
		0 AS GT,
		0 AS SV,
		0 AS HN,
		0 AS NI,
		0 AS CR,
		CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 121
			THEN (T0.DocTotal - T0.PaidToDate)*-1 END      AS PA,
		0 AS CO
	FROM CVPA.DBO.ORIN T0
		LEFT JOIN CVPA.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
	WHERE  T0.TaxDate                   <= @Fecha
		AND (T0.DocTotal - T0.PaidToDate) <>  0
		AND  T0.DocStatus                  = 'O'
		AND  T0.BaseAmnt                   =  0
		AND T1.GroupCode <> '103'

	UNION ALL

	/* COLOMBIA*/

	SELECT 
		'Mas de 120 Dias'                                 AS M120 ,  
		0 AS GT,
		0 AS SV,    
		0 AS HN,
		0 AS NI,
		0 AS CR,
		0 AS PA,
		CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 121
			THEN (T0.DocTotal - T0.PaidToDate) END      AS CO
	FROM  CVCO.DBO.OINV T0
		LEFT JOIN CVCO.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
	WHERE  T0.TaxDate                   <= @Fecha
		AND (T0.DocTotal - T0.PaidToDate) <> 0
		AND T1.GroupCode <> '103'
	
	UNION ALL

	SELECT 
		'Mas de 120 Dias'                                 AS M120 ,  
		0 AS GT,
		0 AS SV,
		0 AS HN,
		0 AS NI,
		0 AS CR,
		0 AS PA,
		  CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 121
		   THEN (T0.DocTotal - T0.PaidToDate)*-1 END    AS CO
	  FROM CVCO.DBO.ORIN T0
		LEFT JOIN CVCO.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
	 WHERE  T0.TaxDate                   <= @Fecha
	   AND (T0.DocTotal - T0.PaidToDate) <>  0
	   AND  T0.DocStatus            
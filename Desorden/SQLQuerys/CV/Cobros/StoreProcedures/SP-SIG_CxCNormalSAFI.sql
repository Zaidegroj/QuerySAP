set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go






ALTER PROCEDURE [dbo].[SIG_CxCNormalSAFI]

@Fecha AS DATETIME,
@gt as numeric(19,4),
@HN AS NUMERIC(19,4),
@NI AS NUMERIC(19,4),
@CR AS NUMERIC(19,4),
@CO AS NUMERIC(19,4)
AS
INSERT INTO #SIGConso_CxC
	SELECT 
       /*NORMAL   	AS CARTERA  , */
		'Normal'		AS NORMAL,
		SUM(GT)/@gt			AS 'GT',    
		SUM(SV)      	AS 'SV'  ,
		SUM(HN)/@HN        	AS 'HN'   ,
		SUM(NI)/@NI        	AS 'NI'   ,	   
		SUM(CR)/@CR        	AS 'CR'   ,
		SUM(PA)        	AS 'PA'   ,
		SUM(CO)/@CO        	AS 'CO'  ,
		SUM(GT)/@gt+ SUM(SV)+ SUM(HN)/@HN+ SUM(NI)/@NI+ SUM(CR)/@CR+SUM(PA)+SUM(CO)/@CO AS TOTAL
	FROM (

		SELECT 
			'NORMAL'                                 AS NORMAL ,  
			CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) <=   0
				THEN (T0.DocTotal - T0.PaidToDate) END      AS GT,
			0 as SV,
			0 AS HN,
			0 AS NI,
			0 AS CR,
			0 AS PA,
			0 AS CO
		FROM  cvgt.DBO.OINV T0
			LEFT JOIN cvgt.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
		WHERE  T0.TaxDate                   <= @Fecha
			AND (T0.DocTotal - T0.PaidToDate) <> 0
			AND T1.GroupCode <> '103'

		UNION ALL

		SELECT 
 			'NORMAL'                                 AS NORMAL , 
			CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) <=   0
				THEN (T0.DocTotal - T0.PaidToDate) * -1 END AS GT,
			0 as SV,
			0 AS HN,
			0 AS NI,
			0 AS CR,
			0 AS PA,
			0 AS CO
		FROM cvgt.DBO.ORIN T0
			LEFT JOIN cvgt.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
		WHERE  T0.TaxDate                   <= @Fecha
			AND (T0.DocTotal - T0.PaidToDate) <>  0
			AND  T0.DocStatus                  = 'O'
			AND  T0.BaseAmnt                   =  0
			AND T1.GroupCode <> '103'

		union all 

	/* El Salvador*/

		SELECT 
			'NORMAL'                                 AS NORMAL ,  
 			0 AS GT,  
			CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) <=   0
				THEN (T0.DocTotal - T0.PaidToDate) END      AS SV,
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
 			'NORMAL'                                 AS NORMAL , 
			0 AS GT,   
			CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) <=   0
				THEN (T0.DocTotal - T0.PaidToDate) * -1 END AS SV,
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
			'NORMAL'                                 AS NORMAL , 
			0 AS GT,
			0 AS SV,    
			CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) <=   0
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
			'NORMAL'                                 AS NORMAL ,    
			0 AS GT,
			0 AS SV,
			CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) <=   0
				THEN (T0.DocTotal - T0.PaidToDate) * -1 END AS HN,
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
			'NORMAL'                                 AS NORMAL , 
			0 AS GT,
			0 AS SV,    
			0 AS HN,
			CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) <=   0
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
			'NORMAL'                                 AS NORMAL ,    
			0 AS GT,
			0 AS SV,
			0 AS HN,
			CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) <=   0
				THEN (T0.DocTotal - T0.PaidToDate) * -1 END AS NI,
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
			'NORMAL'                                 AS NORMAL , 
			0 AS GT,
			0 AS SV,    
			0 AS HN,
			0 AS NI,
			CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) <=   0
				THEN (T0.DocTotal - T0.PaidToDate) END      AS CR,
			0 AS PA,
			0 AS CO
		FROM  CVCR.DBO.OINV T0
			LEFT JOIN CVCR.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
		WHERE  T0.TaxDate                   <= @Fecha
			AND (T0.DocTotal - T0.PaidToDate) <> 0
			AND T1.GroupCode <> '103'

		UNION ALL

		SELECT 
			'NORMAL'                                 AS NORMAL ,    
			0 AS GT,
			0 AS SV,
			0 AS HN,
			0 AS NI,
			CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) <=   0
				THEN (T0.DocTotal - T0.PaidToDate) * -1 END AS CR,
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
			'NORMAL'                                 AS NORMAL , 
			0 AS GT,
			0 AS SV,    
			0 AS HN,
			0 AS NI,
			0 AS CR,
			CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) <=   0
				THEN (T0.DocTotal - T0.PaidToDate) END      AS PA,
			0 AS CO
		FROM  CVPA.DBO.OINV T0
			LEFT JOIN CVPA.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
		WHERE  T0.TaxDate                   <= @Fecha
			AND (T0.DocTotal - T0.PaidToDate) <> 0
			AND T1.GroupCode <> '103'

		UNION ALL
	
		SELECT 
			'NORMAL'                                 AS NORMAL ,    
			0 AS GT,
			0 AS SV,
			0 AS HN,
			0 AS NI,
			0 AS CR,
			CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) <=   0
				THEN (T0.DocTotal - T0.PaidToDate) * -1 END AS PA,
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
			'NORMAL'                                 AS NORMAL , 
			0 AS GT,
			0 AS SV,    
			0 AS HN,
			0 AS NI,
			0 AS CR,
			0 AS PA,
			CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) <=   0
				THEN (T0.DocTotal - T0.PaidToDate) END      AS CO
		FROM  CVCO.DBO.OINV T0
			LEFT JOIN CVCO.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
		WHERE  T0.TaxDate                   <= @Fecha
			AND (T0.DocTotal - T0.PaidToDate) <> 0
			AND T1.GroupCode <> '103'

		UNION ALL

		SELECT 
			'NORMAL'                                 AS NORMAL ,    
			0 AS GT,
			0 AS SV,
			0 AS HN,
			0 AS NI,
			0 AS CR,
			0 AS PA,
			CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) <=   0
				THEN (T0.DocTotal - T0.PaidToDate) * -1 END AS CO
		FROM CVCO.DBO.ORIN T0
			LEFT JOIN CVCO.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
		WHERE  T0.TaxDate                   <= @Fecha
			AND (T0.DocTotal - T0.PaidToDate) <>  0
			AND  T0.DocStatus                  = 'O'
			AND  T0.BaseAmnt                   =  0
			AND T1.GroupCode <> '103'

) T0 GROUP BY NORMAL


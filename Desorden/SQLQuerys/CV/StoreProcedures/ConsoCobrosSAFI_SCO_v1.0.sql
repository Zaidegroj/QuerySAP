set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER  PROCEDURE [dbo].[ConsoCobrosSAFI_SCO_v11] 
@GT AS NUMERIC(19,4),
@HN AS NUMERIC(19,4),
@NI AS NUMERIC(19,4),
@CR AS NUMERIC(19,4),
@CO AS NUMERIC(19,4) = null,
@fecha1 as datetime,
@fecha2 as datetime
AS
INSERT INTO #SIGConso_CV
SELECT 'TOTAL COBROS (- Comisión Agencia)' AS Abono   ,
	/*MAX(No) AS No,*/
    ROUND(SUM(GT),0)	    AS GT,
	ROUND(SUM(SV),0)		AS SV,
	ROUND(SUM(HN),0)		AS HN,
	ROUND(SUM(NI),0)		AS NI,
	ROUND(SUM(CR),0)		AS CR,
	ROUND(SUM(PA),0)     AS PA,
	ROUND(SUM(GT),0) + ROUND(SUM(SV),0) + ROUND(SUM(HN),0) + ROUND(SUM(NI),0) + ROUND(SUM(CR),0) + ROUND(SUM(PA),0) AS TOTAL, ' ' AS PORCENT
         FROM (

	/*Guatemala*/

	SELECT  'Abonos'  Abono,
		0	AS No,
		SUM(T0.DocTotal/@gt) * 0.8 AS GT,
		0 as sv,
		0	AS HN,
		0	AS NI,
		0	AS CR,
		0	AS PA
	FROM CVgt.DBO.ORCT T0
		LEFT JOIN CVgt.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
	WHERE T0.DocDate >= @fecha1
		 AND T0.DocDate <= @fecha2
		AND T1.GroupCode <> '103'

	union all 

	/*El Salvador*/
	
	SELECT  'Abonos'  Abono,
		1	AS No,
		0 	AS GT,
		SUM(T0.DocTotal) * 0.8 AS SV,
		0	AS HN,
		0	AS NI,
		0	AS CR,
		0	AS PA
	FROM CVSV.DBO.ORCT T0
		LEFT JOIN CVSV.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
	WHERE T0.DocDate >= @fecha1
		 AND T0.DocDate <= @fecha2
		AND T1.GroupCode <> '103'

	UNION

SELECT  'Abonos'  AS Abono,
	2	AS No,
	0 	AS GT,
	0	AS SV,
	(SUM(T0.DocTotal)/@HN) * 0.8 AS HN,
	0	AS NI,
	0	AS CR,
	0	AS PA
	  FROM CVHN.DBO.ORCT T0
LEFT JOIN CVHN.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
	 WHERE T0.DocDate >= @fecha1
	 AND T0.DocDate <= @fecha2
 AND T1.GroupCode <> '103'

UNION

SELECT  'Abonos'  AS Abono,
	3	AS No,
	0 	AS GT,
	0	AS SV,
	0 	AS HN,
	(SUM(T0.DocTotal)/@NI)* 0.8	AS NI,
	0	AS CR,
	0	AS PA	 
	  FROM CVNI.DBO.ORCT T0
LEFT JOIN CVNI.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
	 WHERE T0.DocDate >= @fecha1
	 AND T0.DocDate <= @fecha2
 AND T1.GroupCode <> '103'

UNION
SELECT  'Abonos'  AS Abono,
	4	AS No,
	0 	AS GT,
	0	AS SV,
	0 	AS HN,
	0	AS NI,
	(SUM(T0.DocTotal)/@CR)* 0.8	AS CR,
	0	AS PA	 	
	  FROM CVCR.DBO.ORCT T0
LEFT JOIN CVCR.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
	 WHERE T0.DocDate >= @fecha1
	 AND T0.DocDate <= @fecha2
 AND T1.GroupCode <> '103'

UNION
SELECT  'Abonos'  AS Abono,
	5	AS No,
	0 	AS GT,
	0	AS SV,
	0 	AS HN,
	0	AS NI,
	0	AS CR,
	SUM(T0.DocTotal)* 0.8	AS PA
	  FROM CVPA.DBO.ORCT T0
LEFT JOIN CVPA.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
	 WHERE T0.DocDate >= @fecha1
	 AND T0.DocDate <= @fecha2
 AND T1.GroupCode <> '103'

UNION
SELECT  'Abonos'  AS Abono,
	6	AS No,
	0 	AS GT,
	0	AS SV,
	0 	AS HN,
	0	AS NI,
	0	AS CR,
	0	AS PA
	  FROM CVCO.DBO.ORCT T0
LEFT JOIN CVCO.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
	 WHERE T0.DocDate >= @fecha1
	 AND T0.DocDate <= @fecha2
 AND T1.GroupCode <> '103'

) T0 GROUP BY Abono

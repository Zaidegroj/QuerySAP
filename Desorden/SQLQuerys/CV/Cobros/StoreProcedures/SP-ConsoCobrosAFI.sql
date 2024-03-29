set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go





ALTER  PROCEDURE [dbo].[ConsoCobrosAFI]
/*CONSO UTILIZADO PARA EL SIG CV COBROS SOLO AFILIADAS*/
@GT AS NUMERIC(19,4),
@HN AS NUMERIC(19,4),
@NI AS NUMERIC(19,4),
@CR AS NUMERIC(19,4),
@CO AS NUMERIC(19,4),
@fecha1 as datetime,
@fecha2 as datetime
AS
INSERT INTO #SIGConsoCobros_CV
SELECT 'AFILIADAS' AS Abono   ,
	/*MAX(No) AS No,*/
    MAX(GT) AS GT,
	MAX(SV)		AS SV,
	MAX(HN)		AS HN,
	MAX(NI)		AS NI,
	MAX(CR)		AS CR,
	MAX(PA)     AS PA,
	MAX(CO)		AS CO,
	SUM(GT) + SUM(SV) + SUM(HN) + SUM(NI) + SUM(CR) + SUM(PA) + SUM(CO) AS TOTAL
         FROM (
			SELECT  'Abonos'  Abono,
				0	AS No,
				sum(T0.DocTotal)/@GT as GT,
				0   AS SV,
				0	AS HN,
				0	AS NI,
				0	AS CR,
				0	AS PA,
				0	AS CO
			FROM cvgt.DBO.ORCT T0
				LEFT JOIN cvgt.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
			WHERE T0.DocDate >= @fecha1
				AND T0.DocDate <= @fecha2
				AND T1.GroupCode = '103'
			
			union

			SELECT  'Abonos'  Abono,
				1	AS No,
				0 	AS GT,
				SUM(T0.DocTotal) AS SV,
				0	AS HN,
				0	AS NI,
				0	AS CR,
				0	AS PA,
				0	AS CO
			FROM CVSV.DBO.ORCT T0
				LEFT JOIN CVSV.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
			WHERE T0.DocDate >= @fecha1
				AND T0.DocDate <= @fecha2
				AND T1.GroupCode = '103'

			UNION
	
			SELECT  'Abonos'  AS Abono,
				2	AS No,
				0 	AS GT,
				0	AS SV,
				SUM(T0.DocTotal)/@HN AS HN,
				0	AS NI,
				0	AS CR,
				0	AS PA,
				0	AS CO	 
			FROM CVHN.DBO.ORCT T0
				LEFT JOIN CVHN.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
			WHERE T0.DocDate >= @fecha1
				AND T0.DocDate <= @fecha2
				AND T1.GroupCode = '103'

			UNION

			SELECT  'Abonos'  AS Abono,
				3	AS No,
				0 	AS GT,
				0	AS SV,
				0 	AS HN,
				SUM(T0.DocTotal)/@NI	AS NI,
				0	AS CR,
				0	AS PA,
				0	AS CO	 
			FROM CVNI.DBO.ORCT T0
				LEFT JOIN CVNI.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
			WHERE T0.DocDate >= @fecha1
				AND T0.DocDate <= @fecha2
				AND T1.GroupCode = '103'

			UNION	

			SELECT  'Abonos'  AS Abono,
				4	AS No,
				0 	AS GT,
				0	AS SV,
				0 	AS HN,
				0	AS NI,
				SUM(T0.DocTotal)/@CR	AS CR,
				0	AS PA,
				0	AS CO	 	
			FROM CVCR.DBO.ORCT T0
				LEFT JOIN CVCR.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
			WHERE T0.DocDate >= @fecha1
				AND T0.DocDate <= @fecha2
				AND T1.GroupCode = '103'

			UNION

			SELECT  'Abonos'  AS Abono,
				5	AS No,
				0 	AS GT,
				0	AS SV,
				0 	AS HN,
				0	AS NI,
				0	AS CR,
				SUM(T0.DocTotal)	AS PA,
				0	AS CO
			FROM CVPA.DBO.ORCT T0
				LEFT JOIN CVPA.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
			WHERE T0.DocDate >= @fecha1
				AND T0.DocDate <= @fecha2
			AND T1.GroupCode = '103'

			UNION

			SELECT  'Abonos'  AS Abono,
				6	AS No,
				0 	AS GT,
				0	AS SV,
				0 	AS HN,
				0	AS NI,
				0	AS CR,
				0	AS PA,
				SUM(T0.DocTotal)/ @CO AS CO
			FROM CVCO.DBO.ORCT T0
				LEFT JOIN CVCO.DBO.OCRD T1 ON T0.CardCode=T1.CardCode
			WHERE T0.DocDate >= @fecha1
				AND T0.DocDate <= @fecha2
				AND T1.GroupCode = '103'
) T0 GROUP BY Abono










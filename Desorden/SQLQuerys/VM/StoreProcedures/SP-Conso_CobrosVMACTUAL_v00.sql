set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go



ALTER  PROCEDURE [dbo].[Conso_CobrosVMACTUAL]

@fecha1 AS DATETIME,
@fecha2 AS DATETIME,
@GT	AS NUMERIC (19,4),
@HN	AS NUMERIC (19,4),
@CR	AS NUMERIC (19,4),
@DO	AS NUMERIC (19,4)

AS

INSERT INTO  #Conso_VIDEOMARK
SELECT Descrip,ROUND(SUM(GT),0),ROUND(SUM(SV),0),ROUND(SUM(HN),0),ROUND(SUM(CR),0),ROUND(SUM(PA),0),ROUND(SUM(DO),0),ROUND(SUM(GT),0)+ ROUND(SUM(SV),0)+ ROUND(SUM(CR),0)+ ROUND(SUM(PA),0)+ ROUND(SUM(DO),0) AS TOTAL,' ' AS PORCENT

FROM(

SELECT  'TOTAL COBROS'  AS Descrip,
	SUM(T0.DocTotal)/@GT AS GT,
 	0 AS SV,
	0 AS HN,
	0 AS CR,
	0 AS PA,
	0 AS DO
 FROM PRGT.DBO.ORCT T0 LEFT JOIN PRGT.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
	 WHERE T0.DocDate >= @fecha1
	 AND T0.DocDate <= @fecha2
	AND T1.GroupCode <> 104 AND T1.GroupCode <> 107 AND T1.GroupCode <> 108

UNION ALL

SELECT  'TOTAL COBROS'  AS Descrip,
	0 AS GT,
	SUM(T0.DocTotal) AS SV,
	0 AS HN,
	0 AS CR,
	0 AS PA,
	0 AS DO
 FROM VMSV.DBO.ORCT T0 LEFT JOIN VMSV.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
	 WHERE T0.DocDate >= @fecha1
	 AND T0.DocDate <= @fecha2
	AND T1.GroupCode <> 104

UNION ALL

SELECT  'TOTAL COBROS'  AS Descrip,
	0 AS GT,
	0 AS SV,
	SUM(T0.DocTotal)/@HN AS HN,
	0 AS CR,
	0 AS PA,
	0 AS DO
	 FROM PRHN.DBO.ORCT T0 LEFT JOIN PRHN.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
	 WHERE T0.DocDate >= @fecha1
	 AND T0.DocDate <= @fecha2
	AND T1.GroupCode <> 104 and T1.GroupCode <> 107


UNION ALL

SELECT  'TOTAL COBROS'  AS Descrip,
	0 AS GT,
 	0 AS SV,
	0 AS HN,
	SUM(T0.DocTotal)/@CR AS CR,
	0 AS PA,
	0 AS DO
 FROM VMCR.DBO.ORCT T0 LEFT JOIN VMCR.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
	 WHERE T0.DocDate >= @fecha1
	 AND T0.DocDate <= @fecha2
	AND T1.GroupCode <> 103 AND T1.GroupCode <> 107

UNION ALL


SELECT  'TOTAL COBROS'  AS Descrip,
	0 AS GT,
 	0 AS SV,
	0 AS HN,
	0 AS CR,
	SUM(T0.DocTotal) AS PA,
	0 AS DO
 FROM VMPA.DBO.ORCT T0 LEFT JOIN VMPA.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
	 WHERE T0.DocDate >= @fecha1
	 AND T0.DocDate <= @fecha2
	AND T1.GroupCode <> 104 AND T1.GroupCode <> 107

UNION ALL

SELECT  'TOTAL COBROS'  AS Descrip,
	0 AS GT,
 	0 AS SV,
	0 AS HN,
	0 AS CR,
	0 AS PA,
	SUM(T0.DocTotal)/@DO AS DO
 FROM VMDO.DBO.ORCT T0 LEFT JOIN VMDO.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
	 WHERE T0.DocDate >= @fecha1
	 AND T0.DocDate <= @fecha2
	AND T1.GroupCode <> 104 and T1.GroupCode <> 107

) T0 GROUP BY Descrip









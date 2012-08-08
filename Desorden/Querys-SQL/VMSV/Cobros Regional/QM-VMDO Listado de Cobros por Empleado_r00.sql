DECLARE @codIni as Varchar(100)
DECLARE @codFin as Varchar(100)
DECLARE @FechaIni AS DATETIME
DECLARE @FechaFin AS DATETIME,
		@DO AS NUMERIC(18,4)

/* SELECT FROM VMDO.DBO.ORCT T0*/
SET @FechaIni= /* T0.DocDate*/ '[%0]'

/* SELECT FROM VMDO.DBO.ORCT T0*/
SET @FechaFin= /* T0.DocDate*/ '[%1]'

/*SELECT FROM VMDO.DBO.OCRG T1*/
SET @codIni= /* T1.GroupName */ '[%2]'
/*SELECT FROM VMDO.DBO.OCRG T1*/
SET @codFin= /* T1.GroupName */ '[%3]'

/*SELECT FROM VMDO.DBO.ORTT T2*/
SET @DO= /* T2.Rate */ '[%4]'



SELECT T3.GroupName,
       T0.DocDate    AS Fecha,
       T0.CardCode   AS Cliente,
       T0.CardName   AS Nombre,
       T0.DocNum     AS Correl,
       T0.CounterRef AS Referencia,
       T0.Comments   AS Comentarios,
       T2.SlpName    AS Empleado,
       T0.DocTotal/@DO   AS Total
  FROM      VMDO.DBO.ORCT T0
 INNER JOIN VMDO.DBO.OCRD T1 ON T0.CardCode = T1.CardCode
 INNER JOIN VMDO.DBO.OSLP T2 ON T1.SlpCode  = T2.SlpCode
 INNER JOIN VMDO.DBO.OCRG T3 ON T1.GroupCode = T3.GroupCode
WHERE T0.DocDate >=@FechaIni
   AND T0.DocDate <=@FechaFin
 AND T3.GroupName>=@codIni
 AND T3.GroupName<=@codFin
 ORDER BY T3.GroupName,
	  T2.SlpName,
          T0.DocNum
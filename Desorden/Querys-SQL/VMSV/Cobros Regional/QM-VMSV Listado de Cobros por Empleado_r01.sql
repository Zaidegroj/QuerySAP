DECLARE @codIni as Varchar(100),
		@codFin as Varchar(100),
		@FechaIni AS DATETIME,
		@FechaFin AS DATETIME,
		@iInDesign as int

set @iInDesign = 1

if (@iInDesign=1)
	begin
		SET @FechaIni= '01/01/2011 00:00:00'
		sET @FechaFin= '01/31/2011 00:00:00'
		SET @codIni= 'Acreedores Exterior'
		SET @codFin= 'Proveedores Locales'
	end
else
	begin
		/* SELECT FROM VMSV.DBO.ORCT T0*/
		SET @FechaIni= /* T0.DocDate*/ '[%0]'
		/* SELECT FROM VMSV.DBO.ORCT T0*/
		SET @FechaFin= /* T0.DocDate*/ '[%1]'
		/*SELECT FROM VMSV.DBO.OCRG T1*/
		SET @codIni= /* T1.GroupName */ '[%2]'
		/*SELECT FROM VMSV.DBO.OCRG T1*/
		SET @codFin= /* T1.GroupName */ '[%3]'
	end

SELECT T3.GroupName,
       T0.DocDate    AS Fecha,
       T0.CardCode   AS Cliente,
       T0.CardName   AS Nombre,
       T0.DocNum     AS Correl,
       T0.CounterRef AS Referencia,
       T0.Comments   AS Comentarios,
       T2.SlpName    AS Empleado,
       T0.DocTotal   AS Total
  FROM   VMSV.DBO.ORCT T0
 INNER JOIN VMSV.DBO.OCRD T1 ON T0.CardCode = T1.CardCode
 INNER JOIN VMSV.DBO.OSLP T2 ON T1.SlpCode  = T2.SlpCode
 INNER JOIN VMSV.DBO.OCRG T3 ON T1.GroupCode = T3.GroupCode
WHERE T0.DocDate >=@FechaIni
   AND T0.DocDate <=@FechaFin
 AND T3.GroupName>=@codIni
 AND T3.GroupName<=@codFin
 ORDER BY T3.GroupName,
	  T2.SlpName,
          T0.DocNum
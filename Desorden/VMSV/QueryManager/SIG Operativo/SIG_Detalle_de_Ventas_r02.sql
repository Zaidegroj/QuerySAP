declare @dFechaIni as datetime,
		@dFechafin as datetime,
		@iInDesign as int,
		@GrupoIni as varchar(150),
		@GrupoFin as varchar(150)

set @iInDesign = 1

if (@iInDesign =1)
	begin
		set @dFechaIni = '01/01/2012 00:00:00'
		set @dFechaFin = '04/30/2012 00:00:00'
		set @GrupoIni	= 'Acreedores Exterior'
		set @GrupoFin	= 'Proveedores Locales'
	end
else
	begin
		/* SELECT FROM prgt.DBO.OINV T1 */
		SET @dFechaIni = /* T1.DocDate */ '[%0]'
		/* SELECT FROM prgt.DBO.OINV T1 */
		SET @dFechaFin = /* T1.DocDate */ '[%1]'
		/* SELECT FROM prgt.DBO.OCRG T2 */
		SET @GrupoIni = /* T2.GroupName */ '[%2]'
		/* SELECT FROM prgt.DBO.OCRG T2 */
		SET @GrupoFin = /* T2.GroupName */ '[%3]'
	end


SELECT T0.Series     AS Ser,
       T0.DocNum     AS Doc,
       T0.U_FacSerie AS Ser_U,
       T0.U_FacNum   AS Doc_U,
       T0.DocType    AS Tipo,
       T0.DocDate    AS Fecha,
      (T0.DocTotal + T0.WTSum - T0.VatSum) AS 'Neto',
       T0.VatSum     AS IVA,
       T0.WTSum      AS Reten,
       T0.DocTotal   AS 'A Pagar',
       T0.Max1099    AS Total,
       ' ',
       T4.ItmsGrpCod AS Grupo,
       T5.ItmsGrpNam AS Nombre,
       T3.ItemCode   AS Codigo,
       T3.Dscription AS Descripcion,
       T3.Quantity   AS Cant,
       T3.Price      AS 'P. Unit',
       T3.LineTotal  AS 'P. Total'
  FROM      OINV T0
	 INNER JOIN OCRD T1 ON T0.CardCode=T1.CardCode
	 INNER JOIN OCRG T2 ON T2.GroupCode=T1.GroupCode
	 INNER JOIN INV1 T3 ON T0.DocEntry   = T3.DocEntry
	 LEFT JOIN OITM T4 ON T3.ItemCode   = T4.ItemCode
	 LEFT JOIN OITB T5 ON T4.ItmsGrpCod = T5.ItmsGrpCod
 WHERE T0.DocDate >= @dFechaIni
   AND T0.DocDate <= @dFechaFin
   AND  T2.GroupName>=@GrupoIni
   AND  T2.GroupName<=@GrupoFin
   and t0.paidtodate <> t0.doctotal
 ORDER BY T0.Series,
          T0.DocNum

--select * from oinv where year(docdate)=2012 
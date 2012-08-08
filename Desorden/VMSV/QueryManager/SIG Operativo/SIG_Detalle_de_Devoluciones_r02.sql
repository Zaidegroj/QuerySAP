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


		SELECT T4.Series     AS Ser,
			   T4.DocNum     AS Doc,
			   T4.U_FacSerie AS Ser_U,
			   T4.U_FacNum   AS Doc_U,
			   T4.DocType    AS Tipo,
			   T4.DocDate    AS Fecha,
			   t8.cardname as Cliente,
			  (T4.DocTotal + T4.WTSum - T4.VatSum) AS 'Neto',
			   T4.VatSum     AS IVA,
			   T4.WTSum      AS Reten,
			   T4.DocTotal   AS 'A Pagar',
			   T4.Max1099    AS Total,
			   ' ',
			   T6.ItmsGrpCod AS Grupo,
			   T7.ItmsGrpNam AS Nombre,
			   T5.ItemCode   AS Codigo,
			   T5.Dscription AS Descripcion,
			   T5.Quantity   AS Cant,
			   T5.Price      AS 'P. Unit',
			   T5.LineTotal 'P. Total'
		  FROM      ORIN T4
			 INNER JOIN OCRD T8 ON T4.CardCode=T8.CardCode
			 INNER JOIN OCRG T9 ON T9.GroupCode=T8.GroupCode
		 INNER JOIN RIN1 T5 ON T4.DocEntry   = T5.DocEntry
		  LEFT JOIN OITM T6 ON T5.ItemCode   = T6.ItemCode
		  LEFT JOIN OITB T7 ON T6.ItmsGrpCod = T7.ItmsGrpCod

		 WHERE T4.DocDate >= @dFechaIni
		   AND T4.DocDate <= @dFechaFin
		   AND  T9.GroupName>=@GrupoIni
		   AND  T9.GroupName<=@GrupoFin
 ORDER BY T4.Series,
          T4.DocNum

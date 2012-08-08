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


SELECT Ser,
       Doc,
       Ser_U,
       Doc_U,
       Tipo,
       Fecha,
		Cliente as [Nombre del Cliente],
      Neto,
       IVA,
       Reten,
       [A Pagar],
       Total,
	   Saldo,
       col0 as ' ',
       Grupo,
       Nombre,
       Codigo,
       Descripcion,
       Cant,
       [P. Unit],
       [P. Total]
from 
		(

		SELECT T0.Series     AS Ser,
			   T0.DocNum     AS Doc,
			   T0.U_FacSerie AS Ser_U,
			   T0.U_FacNum   AS Doc_U,
			   T0.DocType    AS Tipo,
			   T0.DocDate    AS Fecha,
			   t1.CardName as Cliente,
			  (T0.DocTotal + T0.WTSum - T0.VatSum) AS 'Neto',
			   T0.VatSum     AS IVA,
			   T0.WTSum      AS Reten,
			   T0.DocTotal   AS 'A Pagar',
			   T0.Max1099    AS Total,
			   ' ' as col0,
			   T4.ItmsGrpCod AS Grupo,
			   T5.ItmsGrpNam AS Nombre,
			   T3.ItemCode   AS Codigo,
			   T3.Dscription AS Descripcion,
			   T3.Quantity   AS Cant,
			   T3.Price      AS 'P. Unit',
			   T3.LineTotal  AS 'P. Total',
			   (t0.doctotal - t0.paidtodate) as 'Saldo'
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
           and t0.doctotal <> t0.paidtodate

		union all 

		SELECT T4.Series     AS Ser,
			   T4.DocNum     AS Doc,
			   T4.U_FacSerie AS Ser_U,
			   T4.U_FacNum   AS Doc_U,
			   T4.DocType    AS Tipo,
			   T4.DocDate    AS Fecha,
			   t8.cardname as Cliente,
			  (T4.DocTotal + T4.WTSum - T4.VatSum)*-1 AS 'Neto',
			   T4.VatSum  *-1   AS IVA,
			   T4.WTSum  *-1    AS Reten,
			   T4.DocTotal  *-1 AS 'A Pagar',
			   T4.Max1099  *-1  AS Total,
			   ' ',
			   T6.ItmsGrpCod AS Grupo,
			   T7.ItmsGrpNam AS Nombre,
			   T5.ItemCode   AS Codigo,
			   T5.Dscription AS Descripcion,
			   T5.Quantity   *-1 AS Cant,
			   T5.Price      *-1 AS 'P. Unit',
			   T5.LineTotal *-1 'P. Total',
			   (t4.doctotal - t4.paidtodate) *-1 as 'Saldo'
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
                               and t4.doctotal <> t4.paidtodate
		) Dt0


--select * from oinv where year(docdate)=2012 
--select * from ocrd
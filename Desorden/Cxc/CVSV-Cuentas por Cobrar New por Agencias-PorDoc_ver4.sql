
---- Antiguedad de Saldos CXC (Por Doc)

DECLARE @Fecha AS DATETIME,
		@GrupoIni AS VARCHAR(100),
		@GrupoFin AS VARCHAR(100),
		@iInDesign as int,
		@Tc as numeric(19,6)

set @iInDesign = 1

set @Tc = 1

if (@iInDesign)=1
	begin
		set @Fecha = '10/11/2011 00:00:00'
		set @GrupoIni = 'Acreedores Exterior'
		set @GrupoFin = 'Proveedores Locales'
	end
else
	begin
		/* SELECT FROM cvsv.DBO.OINV T1 */
		SET @Fecha = /* T1.DocDate */ '[%0]'
		/* SELECT FROM cvsv.DBO.OCRG T2 */
		SET @GrupoIni = /* T2.GroupName */ '[%1]'
		/* SELECT FROM cvsv.DBO.OCRG T2 */
		SET @GrupoFin = /* T2.GroupName */ '[%2]'

	end


SELECT GRUPO AS Grupo,
	Cliente            ,
       Nombre             ,
		Agencia,
       Serie              ,
       Documento          ,
	---ExtraMonth,
	---	ExtraDays,
		--u_VttoAgencia,
       Fecha              ,
       Vence              ,
       Hasta              ,
       Total/@Tc as Total              ,
       Menos/@Tc AS 'Abono/NC',
       Saldo/@Tc as Saldo              ,
       Normal/@Tc as Normal             ,
       M030/@Tc   AS ' 1-30'   ,
       M060/@Tc  AS '31-60'   ,
       M090/@Tc  AS '61-90'   ,
       M120/@Tc  AS '91-120'  ,
       Mas/@Tc   AS 'Mas 120'
FROM (

SELECT     T0.CardCode	AS Cliente, T0.CardName AS Nombre, T2.CntctPrsn AS agencia, T1.SeriesName AS Serie, T0.DocNum AS Documento,t4.ExtraMonth,t4.ExtraDays, t0.u_VttoAgencia,
						T0.DocDate AS Fecha, 
						case 
							when T2.CntctPrsn like '%DIRECTO%' then T0.DocDueDate
							when T2.CntctPrsn not like '%DIRECTO%' and u_diasAgencia is null then cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,t0.DocDate))) 
							when T2.CntctPrsn not like '%DIRECTO%' and u_diasAgencia is not null then cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t0.u_DiasAgencia,t0.DocDate)) end AS Vence,
						@Fecha AS Hasta, T0.DocTotal AS Total, T0.PaidToDate AS Menos, 
						T0.DocTotal - T0.PaidToDate AS Saldo, 
						case 
							when T2.CntctPrsn like '%DIRECTO%' and DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 0 THEN (T0.DocTotal - T0.PaidToDate) 
							when T2.CntctPrsn not like '%DIRECTO%' and T0.u_diasAgencia is null and DATEDIFF(DD, cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.DocDate))),@Fecha) <= 0 then (T0.DocTotal - T0.PaidToDate) 
							when T2.CntctPrsn not like '%DIRECTO%' and T0.u_diasAgencia is not null and DATEDIFF(DD, cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t0.u_DiasAgencia,T0.DocDate)),@Fecha) <= 0 then (T0.DocTotal - T0.PaidToDate) end as Normal,
						case 
							when T2.CntctPrsn like '%DIRECTO%' and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 1 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 30 THEN (T0.DocTotal - T0.PaidToDate) 
							when T2.CntctPrsn not like '%DIRECTO%' and u_diasAgencia is null and DATEDIFF(DD,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.DocDate))), @Fecha) >= 1 AND DATEDIFF(DD,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.DocDate))), @Fecha) <= 30 THEN (T0.DocTotal - T0.PaidToDate) 
							when t2.CntctPrsn not like '%DIRECTO%' and t0.u_DiasAgencia is not null and datediff(dd,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t0.u_DiasAgencia,t0.DocDate)),@fecha) >=1 and datediff(dd,dateadd(dd,t0.u_DiasAgencia,t0.DocDate),@fecha) <= 30 THEN (T0.DocTotal - T0.PaidToDate) end as M030,
						case 
							when T2.CntctPrsn like '%DIRECTO%' and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 31 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 60 THEN (T0.DocTotal - T0.PaidToDate) 
							when T2.CntctPrsn not like '%DIRECTO%' and u_diasAgencia is null and DATEDIFF(DD, cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.DocDate))), @Fecha) >= 31 AND DATEDIFF(DD, cvsv.dbo.ObtenerFechafinal(dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.DocDate))), @Fecha) <= 60 THEN (T0.DocTotal - T0.PaidToDate)
							when t2.cntctPrsn not like '%DIRECTO%' and t0.u_DiasAgencia is not null and datediff(dd,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t0.u_DiasAgencia,t0.DocDate)),@Fecha)>=31 and datediff(dd,dateadd(dd,t0.u_DiasAgencia,T0.DocDate),@Fecha) <=60 then (T0.DocTotal - T0.PaidToDate) END AS M060,
						case 
							when T2.CntctPrsn like '%DIRECTO%' and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 61 AND DATEDIFF(DD,T0.DocDueDate, @Fecha) <= 90 THEN (T0.DocTotal - T0.PaidToDate) 
							when T2.CntctPrsn not like '%DIRECTO%' and u_diasAgencia is null and DATEDIFF(DD, cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.DocDate))), @Fecha) >= 61 AND DATEDIFF(DD,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.DocDate))), @Fecha) <= 90 THEN (T0.DocTotal - T0.PaidToDate)  					
							when t2.cntctPrsn not like '%DIRECTO%' and t0.u_DiasAgencia is not null and datediff(dd,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t0.u_DiasAgencia,t0.DocDate)),@Fecha)>=61 and datediff(dd,dateadd(dd,t0.u_DiasAgencia,T0.DocDate),@Fecha) <=90 then (T0.DocTotal - T0.PaidToDate) END AS M090,
						case 
							when T2.CntctPrsn like '%DIRECTO%' and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 91 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 120 THEN (T0.DocTotal - T0.PaidToDate) 
							when T2.CntctPrsn not like '%DIRECTO%' and u_diasAgencia is null and DATEDIFF(DD, cvsv.dbo.obtenerFechafinal(dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.DocDate))), @Fecha) >= 91 AND DATEDIFF(DD,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.DocDate))), @Fecha) <= 120 THEN (T0.DocTotal - T0.PaidToDate) 
							when t2.cntctPrsn not like '%DIRECTO%' and t0.u_DiasAgencia is not null and datediff(dd,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t0.u_DiasAgencia,t0.DocDate)),@Fecha)>=91 and datediff(dd,dateadd(dd,t0.u_DiasAgencia,T0.DocDate),@Fecha) <=120 then (T0.DocTotal - T0.PaidToDate) END AS M120,
						case 
							when T2.CntctPrsn like '%DIRECTO%' and DATEDIFF(DD, T0.DocDueDate,@Fecha) >= 121 THEN (T0.DocTotal - T0.PaidToDate) 
							when T2.CntctPrsn not like '%DIRECTO%' and u_diasAgencia is null and DATEDIFF(DD, cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.DocDate))),@Fecha) >= 121 THEN (T0.DocTotal - T0.PaidToDate)
							when t2.CntCtPrsn not like '%DIRECTO%' and T0.u_DiasAgencia is not null and datediff(dd,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t0.u_DiasAgencia,t0.DocDate)),@Fecha) >=121 then (T0.DocTotal - T0.PaidToDate) end as Mas,
						 T3.GroupName AS GRUPO
FROM         cvsv.dbo.OINV AS T0 INNER JOIN
             cvsv.dbo.NNM1 AS T1 ON T0.Series = T1.Series INNER JOIN
             cvsv.dbo.OCRD AS T2 ON T0.CardCode = T2.CardCode INNER JOIN
             cvsv.dbo.OCTG AS t4 ON T2.GroupNum = t4.GroupNum INNER JOIN
             cvsv.dbo.OCRG AS T3 ON T3.GroupCode = T2.GroupCode
WHERE     (T0.TaxDate <= @Fecha) AND (T0.DocTotal - T0.PaidToDate <> 0) AND (T3.GroupName >= @GrupoIni) AND (T3.GroupName <= @GrupoFin)

) T0
ORDER BY Grupo,Cliente  ,
         Serie    ,
         Documento



---select * from ocrd
---SELECT * FROM octg
---select * from oinv where docnum = '101155'    /// Facturas
---select * from ocrd
---select cvsv.dbo.ObtenerFechaFinal(getdate())
---select dateadd(dd,u_DiasAgencia,DocDate) from oinv where u_diasagencia is not null

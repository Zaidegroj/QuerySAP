

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
		set @Fecha = '08/31/2011 00:00:00'
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
		--ExtraMonth,
		--ExtraDays,
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
						isnull(T0.u_vttoAgencia,T0.TaxDate) AS Fecha, 
						case 
							when t0.u_VttoAgencia is null then T0.DocDueDate
							when t0.u_VttoAgencia is not null then dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,t0.u_VttoAgencia)) end AS Vence,
						@Fecha AS Hasta, T0.DocTotal AS Total, T0.PaidToDate AS Menos, 
						T0.DocTotal - T0.PaidToDate AS Saldo, 
						case 
							when T0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 0 THEN (T0.DocTotal - T0.PaidToDate) 
							when T0.u_VttoAgencia is not null and DATEDIFF(DD, dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.u_Vttoagencia)),@Fecha) <= 0 then (T0.DocTotal - T0.PaidToDate) end as Normal,
						case 
							when T0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 1 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 30 THEN (T0.DocTotal - T0.PaidToDate) 
							when T0.u_VttoAgencia is not null and DATEDIFF(DD,dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia)), @Fecha) >= 1 AND DATEDIFF(DD, dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia)), @Fecha) <= 30 THEN (T0.DocTotal - T0.PaidToDate) END AS M030,
						case 
							when T0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 31 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 60 THEN (T0.DocTotal - T0.PaidToDate) 
							when T0.u_VttoAgencia is not null and DATEDIFF(DD, dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia)), @Fecha) >= 31 AND DATEDIFF(DD, dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia)), @Fecha) <= 60 THEN (T0.DocTotal - T0.PaidToDate) END AS M060,
						case 
							when t0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 61 AND DATEDIFF(DD,T0.DocDueDate, @Fecha) <= 90 THEN (T0.DocTotal - T0.PaidToDate) 
							when t0.u_VttoAgencia is not null and DATEDIFF(DD, dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia)), @Fecha) >= 61 AND DATEDIFF(DD,dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia)), @Fecha) <= 90 THEN (T0.DocTotal - T0.PaidToDate) END AS M090, 					
						case 
							when t0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 91 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 120 THEN (T0.DocTotal - T0.PaidToDate) 
							when t0.u_VttoAgencia is not null and DATEDIFF(DD, dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia)), @Fecha) >= 91 AND DATEDIFF(DD,dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia)), @Fecha) <= 120 THEN (T0.DocTotal - T0.PaidToDate) END AS M120, 
						case 
							when t0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate,@Fecha) >= 121 THEN (T0.DocTotal - T0.PaidToDate) 
							when t0.u_VttoAgencia is not null and DATEDIFF(DD, dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia)),@Fecha) >= 121 THEN (T0.DocTotal - T0.PaidToDate) END AS Mas,
						 T3.GroupName AS GRUPO
FROM         cvsv.dbo.OINV AS T0 INNER JOIN
             cvsv.dbo.NNM1 AS T1 ON T0.Series = T1.Series INNER JOIN
             cvsv.dbo.OCRD AS T2 ON T0.CardCode = T2.CardCode INNER JOIN
             cvsv.dbo.OCTG AS t4 ON T0.GroupNum = t4.GroupNum INNER JOIN
             cvsv.dbo.OCRG AS T3 ON T3.GroupCode = T2.GroupCode
WHERE     (T0.TaxDate <= @Fecha) AND (T0.DocTotal - T0.PaidToDate <> 0) AND (T3.GroupName >= @GrupoIni) AND (T3.GroupName <= @GrupoFin)
UNION ALL
SELECT     T0.CardCode AS Cliente, T0.CardName AS Nombre, T2.CntctPrsn AS agencia, T1.SeriesName AS Serie, T0.DocNum AS Documento, t4.ExtraMonth,t4.ExtraDays, t0.u_VttoAgencia,
           isnull(t0.u_vttoAgencia,T0.TaxDate) AS Fecha, 
			isnull(dateadd(mm,2,T0.u_vttoAgencia),DocDueDate) AS Vence, @Fecha AS Hasta, T0.DocTotal * - 1 AS Total, T0.PaidToDate * - 1 AS Menos, 
           (T0.DocTotal - T0.PaidToDate) * - 1 AS Saldo,
				case 
						when T0.u_VttoAgencia is null  and DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 0 THEN (T0.DocTotal - T0.PaidToDate)* - 1 
						when T0.u_VttoAgencia is not null and datediff(dd,dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia),@Fecha)<=0 then (T0.DocTotal - T0.PaidToDate)* - 1 END AS Normal,
				case 
						when T0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 1 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 30 THEN (T0.DocTotal - T0.PaidToDate) * - 1 
						when t0.u_VttoAgencia is not null and datediff(dd,dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia),@Fecha) >=1 AND DATEDIFF(DD, dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia), @Fecha) <= 30 THEN (T0.DocTotal - T0.PaidToDate) * - 1 END AS M030, 
				case 
						when t0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 31 AND DATEDIFF(DD,T0.DocDueDate, @Fecha) <= 60 THEN (T0.DocTotal - T0.PaidToDate) * - 1 
						when t0.u_VttoAgencia is not null and DATEDIFF(DD, dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia), @Fecha) >= 31 AND DATEDIFF(DD,dateadd(mm,t4.ExtraMonth,T0.u_vttoAgencia), @Fecha) <= 60 THEN (T0.DocTotal - T0.PaidToDate) * - 1 END AS M060, 
				case 
						when t0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 61 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 90 THEN (T0.DocTotal - T0.PaidToDate) * - 1 
						when t0.u_VttoAgencia is not null and DATEDIFF(DD, dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia), @Fecha) >= 61 AND DATEDIFF(DD, dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia), @Fecha) <= 90 THEN (T0.DocTotal - T0.PaidToDate) * - 1 END AS M090, 
				case 
						when t0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 91 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 120 THEN (T0.DocTotal - T0.PaidToDate) * - 1 
						when t0.u_VttoAgencia is not null and DATEDIFF(DD, dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia), @Fecha) >= 91 AND DATEDIFF(DD, dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia), @Fecha) <= 120 THEN (T0.DocTotal - T0.PaidToDate) * - 1 END AS M120,
				case
						when t0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 121 THEN (T0.DocTotal - T0.PaidToDate) * - 1 
						when t0.u_VttoAgencia is not null and DATEDIFF(DD, dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia), @Fecha) >= 121 THEN (T0.DocTotal - T0.PaidToDate) * - 1 END AS Mas, 
			T3.GroupName AS GRUPO
FROM         cvsv.dbo.ORIN AS T0 INNER JOIN
             cvsv.dbo.NNM1 AS T1 ON T0.Series = T1.Series INNER JOIN
             cvsv.dbo.OCRD AS T2 ON T0.CardCode = T2.CardCode INNER JOIN
             cvsv.dbo.OCTG AS t4 ON T0.GroupNum = t4.GroupNum INNER JOIN
             cvsv.dbo.OCRG AS T3 ON T3.GroupCode = T2.GroupCode
WHERE     (T0.TaxDate <= @Fecha) AND (T0.DocTotal - T0.PaidToDate <> 0) AND (T0.DocStatus = 'O') AND (T0.BaseAmnt = 0) AND (T3.GroupName >= @GrupoIni) 
                      AND (T3.GroupName <= @GrupoFin)
) T0
ORDER BY Grupo,Cliente  ,
         Serie    ,
         Documento



---select * from ocrd
---SELECT * FROM octg
---select * from oinv where docnum = '101155'

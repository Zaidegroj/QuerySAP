
----- Antiguedad de Saldos CXC (Por Cliente)

DECLARE @Fecha AS DATETIME,
		@GrupoIni AS VARCHAR(100),
		@GrupoFin AS VARCHAR(100),
		@iInDesign as int,
		@Tc as numeric(19,6)

set @Tc = 1

set @iInDesign = 1

if (@iInDesign)=1
	begin
		set @Fecha = '05/31/2011 00:00:00'
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
		/* SELECT FROM cvsv.DBO.ORTT T0 */
		SET @tc    = /* T0.Rate    */ '[%3]'
	end

SELECT Grupo,
	Cliente                       ,
       Nombre                        ,
Agencia,
       COUNT(Documento) AS Docs      ,
       Hasta                         ,
       SUM(Total )/@Tc      AS 'Total'   ,
       SUM(Menos )/@Tc      AS 'Abono/NC',
       SUM(Saldo )/@Tc      AS 'Saldo'   ,
       SUM(Normal)/@Tc      AS 'Normal'  ,
       SUM(M030  )/@Tc      AS ' 1-30'   ,
       SUM(M060  )/@Tc      AS '31-60'   ,
       SUM(M090  )/@Tc      AS '61-90'   ,
       SUM(M120  )/@Tc      AS '91-120'  ,
       SUM(Mas   )/@Tc      AS 'Mas 120'

FROM (

SELECT T3.GroupName AS Grupo,
	T0.CardCode                                 AS Cliente  ,
       T0.CardName                                 AS Nombre   ,
		T2.CntctPrsn								as Agencia,
       T0.DocNum                                   AS Documento,
       @Fecha                                      AS Hasta    ,
       T0.DocTotal                                 AS Total    ,
       T0.PaidToDate                               AS Menos    ,
      (T0.DocTotal   - T0.PaidToDate)              AS Saldo    ,

						case 
							when T0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 0 THEN (T0.DocTotal - T0.PaidToDate) 
							when T0.u_VttoAgencia is not null and DATEDIFF(DD, dateadd(mm,t4.ExtraMonth,T0.u_Vttoagencia),@Fecha) <= 0 then (T0.DocTotal - T0.PaidToDate) end as Normal,
							--when T0.u_VttoAgencia is not null and DATEDIFF(DD, dateadd(mm,t4.ExtraMonth,T0.u_Vttoagencia),@Fecha) <= 0 then (T0.DocTotal - T0.PaidToDate) end as Normal,
						case 
							when T0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 1 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 30 THEN (T0.DocTotal - T0.PaidToDate) 
							when T0.u_VttoAgencia is not null and DATEDIFF(DD, dateadd(mm,T4.ExtraMonth,t0.u_VttoAgencia), @Fecha) >= 1 AND DATEDIFF(DD, dateadd(mm,T4.ExtraMonth,t0.u_VttoAgencia), @Fecha) <= 30 THEN (T0.DocTotal - T0.PaidToDate) END AS M030,
						case 
							when T0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 31 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 60 THEN (T0.DocTotal - T0.PaidToDate) 
							when T0.u_VttoAgencia is not null and DATEDIFF(DD, dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia), @Fecha) >= 31 AND DATEDIFF(DD, dateadd(mm,t4.ExtraMonth,t0.u_VttoAgencia),@Fecha) <= 60 THEN (T0.DocTotal - T0.PaidToDate) END AS M060,
						case 
							when t0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 61 AND DATEDIFF(DD,T0.DocDueDate, @Fecha) <= 90 THEN (T0.DocTotal - T0.PaidToDate) 
							when t0.u_VttoAgencia is not null and DATEDIFF(DD, dateadd(mm,t4.ExtraMonth,t0.u_VttoAgencia), @Fecha) >= 61 AND DATEDIFF(DD,dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia), @Fecha) <= 90 THEN (T0.DocTotal - T0.PaidToDate) END AS M090, 					
						case 
							when t0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 91 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 120 THEN (T0.DocTotal - T0.PaidToDate) 
							when t0.u_VttoAgencia is not null and DATEDIFF(DD, dateadd(mm,t4.ExtraMonth,t0.u_VttoAgencia), @Fecha) >= 91 AND DATEDIFF(DD, dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia), @Fecha) <= 120 THEN (T0.DocTotal - T0.PaidToDate) END AS M120, 
						case 
							when t0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate,@Fecha) >= 121 THEN (T0.DocTotal - T0.PaidToDate) 
							when t0.u_VttoAgencia is not null and DATEDIFF(DD, dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia),@Fecha) >= 121 THEN (T0.DocTotal - T0.PaidToDate) END AS Mas

  FROM  cvsv.dbo.OINV T0
		INNER JOIN cvsv.dbo.OCRD T2 ON T0.CardCode=T2.CardCode
		INNER JOIN cvsv.dbo.OCRG T3 ON T3.GroupCode=T2.GroupCode
		inner join cvsv.dbo.OCTG AS t4 ON T0.GroupNum = t4.GroupNum 
 WHERE  T0.TaxDate                   <= @Fecha
   AND (T0.DocTotal - T0.PaidToDate) <> 0
   AND  T3.GroupName>=@GrupoIni
   AND  T3.GroupName<=@GrupoFin

UNION ALL

SELECT T3.GroupName AS Grupo,
	T0.CardCode                                 AS Cliente  ,
       T0.CardName                                 AS Nombre   ,
		T2.CntctPrsn								as Agencia,
       T0.DocNum                                   AS Documento,
       @Fecha                                      AS Hasta    ,
       T0.DocTotal                        * -1     AS Total    ,
       T0.PaidToDate                      * -1     AS Menos    ,
      (T0.DocTotal - T0.PaidToDate)       * -1     AS Saldo    ,

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
						when t0.u_VttoAgencia is not null and DATEDIFF(DD, dateadd(mm,t4.ExtraMonth,T0.u_VttoAgencia), @Fecha) >= 121 THEN (T0.DocTotal - T0.PaidToDate) * - 1 END AS Mas
  FROM  cvsv.dbo.ORIN T0
		INNER JOIN cvsv.dbo.OCRD T2 ON T0.CardCode=T2.CardCode
		INNER JOIN cvsv.dbo.OCRG T3 ON T3.GroupCode=T2.GroupCode
		inner join cvsv.dbo.OCTG AS t4 ON T0.GroupNum = t4.GroupNum 
 WHERE  T0.TaxDate                   <= @Fecha
   AND (T0.DocTotal - T0.PaidToDate) <>  0
   AND  T0.DocStatus                  = 'O'
   AND  T0.BaseAmnt                   =  0
   AND  T3.GroupName>=@GrupoIni
   AND  T3.GroupName<=@GrupoFin

) T0

GROUP BY Grupo,Cliente,
         Nombre ,Agencia,
         Hasta
ORDER BY Grupo,Cliente



---select cntctcode,* from oinv where u_facnum = '53'
---select * from ocrd

---select * from vmsv.dbo.oitm where  itemname like '%furi%'
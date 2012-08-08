DECLARE @Fecha AS DATETIME,
		@GrupoIni AS VARCHAR(100),
		@GrupoFin AS VARCHAR(100),
		@iInDesign as int,
		@Tc as numeric(18,2)

set @tc = 1 

set @iInDesign = 1

if (@iInDesign)=1
	begin
		set @Fecha = '10/17/2011 00:00:00'
		set @GrupoIni = 'Acreedores Exterior'
		set @GrupoFin = 'Proveedores Locales'
	end
else
	begin
		/* SELECT FROM CVPA.DBO.OINV T1 */
		SET @Fecha = /* T1.DocDate */ '[%0]'
		/* SELECT FROM CVPA.DBO.OCRG T2 */
		SET @GrupoIni = /* T2.GroupName */ '[%1]'
		/* SELECT FROM CVPA.DBO.OCRG T2 */
		SET @GrupoFin = /* T2.GroupName */ '[%2]'


	end

SELECT Grupo,
	Cliente                       ,
       Nombre                        ,
Agencia,
       COUNT(Documento) AS Docs      ,
       Hasta                         ,
       Round(SUM(Total/@tc ),2)      AS 'Total'   ,
       Round(SUM(Menos )/@Tc,2)      AS 'Abono/NC',
       Round(SUM(Saldo )/@tc,2)      AS 'Saldo'   ,
       Round(SUM(Normal)/@Tc,2)      AS 'Normal'  ,
       Round(SUM(M030  )/@Tc,2)      AS ' 1-30'   ,
       Round(SUM(M060  )/@Tc,2)      AS '31-60'   ,
       Round(SUM(M090  )/@Tc,2)      AS '61-90'   ,
       Round(SUM(M120  )/@Tc,2)      AS '91-120'  ,
       Round(SUM(Mas   )/@Tc,2)      AS 'Mas 120'

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
							when T2.CntctPrsn like '%DIRECTO%' and DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 0 THEN (T0.DocTotal - T0.PaidToDate) 
							when T2.CntctPrsn not like '%DIRECTO%' and t0.u_DiasAgencia is null and DATEDIFF(DD, cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.DocDate))),@Fecha) <= 0 then (T0.DocTotal - T0.PaidToDate) 
							when T2.CntctPrsn not like '%DIRECTO%' and T0.u_diasAgencia is not null and DATEDIFF(DD, cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t0.u_DiasAgencia,T0.DocDate)),@Fecha) <= 0 then (T0.DocTotal - T0.PaidToDate) end as Normal,
						case 
							when T2.CntctPrsn like '%DIRECTO%'  and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 1 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 30 THEN (T0.DocTotal - T0.PaidToDate) 
							when T2.CntctPrsn not like '%DIRECTO%' and t0.u_DiasAgencia is null and DATEDIFF(DD,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.DocDate))), @Fecha) >= 1 AND DATEDIFF(DD,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.DocDate))), @Fecha) <= 30 THEN (T0.DocTotal - T0.PaidToDate) 
							when t2.CntctPrsn not like '%DIRECTO%' and t0.u_DiasAgencia is not null and datediff(dd,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t0.u_DiasAgencia,t0.DocDate)),@fecha) >=1 and datediff(dd,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t0.u_DiasAgencia,t0.DocDate)),@fecha) <= 30 THEN (T0.DocTotal - T0.PaidToDate) end as M030,
						case 
							when T2.CntctPrsn like '%DIRECTO%' and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 31 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 60 THEN (T0.DocTotal - T0.PaidToDate) 
							when T2.CntctPrsn not like '%DIRECTO%' and t0.u_DiasAgencia is null and DATEDIFF(DD, cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.DocDate))), @Fecha) >= 31 AND DATEDIFF(DD, cvsv.dbo.ObtenerFechafinal(dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.DocDate))), @Fecha) <= 60 THEN (T0.DocTotal - T0.PaidToDate) 
							when t2.cntctPrsn not like '%DIRECTO%' and t0.u_DiasAgencia is not null and datediff(dd,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t0.u_DiasAgencia,t0.DocDate)),@Fecha)>=31 and datediff(dd,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t0.u_DiasAgencia,T0.DocDate)),@Fecha) <=60 then (T0.DocTotal - T0.PaidToDate) END AS M060,
						case 
							when T2.CntctPrsn like '%DIRECTO%' and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 61 AND DATEDIFF(DD,T0.DocDueDate, @Fecha) <= 90 THEN (T0.DocTotal - T0.PaidToDate) 
							when T2.CntctPrsn not like '%DIRECTO%' and t0.u_DiasAgencia is null and DATEDIFF(DD, cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.DocDate))), @Fecha) >= 61 AND DATEDIFF(DD,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.DocDate))), @Fecha) <= 90 THEN (T0.DocTotal - T0.PaidToDate)
							when t2.cntctPrsn not like '%DIRECTO%' and t0.u_DiasAgencia is not null and datediff(dd,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t0.u_DiasAgencia,t0.DocDate)),@Fecha)>=61 and datediff(dd,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t0.u_DiasAgencia,T0.DocDate)),@Fecha) <=90 then (T0.DocTotal - T0.PaidToDate) END AS M090,
						case 
							when T2.CntctPrsn like '%DIRECTO%' and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 91 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 120 THEN (T0.DocTotal - T0.PaidToDate) 
							when T2.CntctPrsn not like '%DIRECTO%' and t0.u_DiasAgencia is null and DATEDIFF(DD, cvsv.dbo.obtenerFechafinal(dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.DocDate))), @Fecha) >= 91 AND DATEDIFF(DD,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.DocDate))), @Fecha) <= 120 THEN (T0.DocTotal - T0.PaidToDate) 
							when t2.cntctPrsn not like '%DIRECTO%' and t0.u_DiasAgencia is not null and datediff(dd,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t0.u_DiasAgencia,t0.DocDate)),@Fecha)>=91 and datediff(dd,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t0.u_DiasAgencia,T0.DocDate)),@Fecha) <=120 then (T0.DocTotal - T0.PaidToDate) END AS M120,
						case 
							when T2.CntctPrsn like '%DIRECTO%' and DATEDIFF(DD, T0.DocDueDate,@Fecha) >= 121 THEN (T0.DocTotal - T0.PaidToDate) 
							when T2.CntctPrsn not like '%DIRECTO%' and t0.u_DiasAgencia is null and DATEDIFF(DD, cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t4.ExtraDays,dateadd(mm,t4.ExtraMonth,T0.DocDate))),@Fecha) >= 121 THEN (T0.DocTotal - T0.PaidToDate) 
							when t2.CntCtPrsn not like '%DIRECTO%' and T0.u_DiasAgencia is not null and datediff(dd,cvsv.dbo.ObtenerFechaFinal(dateadd(dd,t0.u_DiasAgencia,t0.DocDate)),@Fecha) >=121 then (T0.DocTotal - T0.PaidToDate) end as Mas

  FROM  CVPA.dbo.OINV T0
 INNER JOIN CVPA.dbo.OCRD T2 ON T0.CardCode=T2.CardCode
 INNER JOIN CVPA.dbo.OCRG T3 ON T3.GroupCode=T2.GroupCode
 inner join CVPA.dbo.OCTG AS t4 ON T2.GroupNum = t4.GroupNum 
 WHERE  T0.TaxDate                   <= @Fecha
   AND (T0.DocTotal - T0.PaidToDate) <> 0
   AND  T3.GroupName>=@GrupoIni
   AND  T3.GroupName<=@GrupoFin

--UNION ALL
--
--SELECT T3.GroupName AS Grupo,
--	T0.CardCode                                 AS Cliente  ,
--       T0.CardName                                 AS Nombre   ,
--		T2.CntctPrsn								as Agencia,
--       T0.DocNum                                   AS Documento,
--       @Fecha                                      AS Hasta    ,
--       T0.DocTotal                        * -1     AS Total    ,
--       T0.PaidToDate                      * -1     AS Menos    ,
--      (T0.DocTotal - T0.PaidToDate)       * -1     AS Saldo    ,
--
--				case 
--						when T0.u_VttoAgencia is null  and DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 0 THEN (T0.DocTotal - T0.PaidToDate)* - 1 
--						when T0.u_VttoAgencia is not null and datediff(dd,T0.u_VttoAgencia+60,@Fecha)<=0 then (T0.DocTotal - T0.PaidToDate)* - 1 END AS Normal,
--				case 
--						when T0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 1 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 30 THEN (T0.DocTotal - T0.PaidToDate) * - 1 
--						when t0.u_VttoAgencia is not null and datediff(dd,T0.u_VttoAgencia+60,@Fecha) >=1 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 30 THEN (T0.DocTotal - T0.PaidToDate) * - 1 END AS M030, 
--				case 
--						when t0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 31 AND DATEDIFF(DD,T0.DocDueDate, @Fecha) <= 60 THEN (T0.DocTotal - T0.PaidToDate) * - 1 
--						when t0.u_VttoAgencia is not null and DATEDIFF(DD, T0.u_VttoAgencia+60, @Fecha) >= 31 AND DATEDIFF(DD,T0.u_vttoAgencia+60, @Fecha) <= 60 THEN (T0.DocTotal - T0.PaidToDate) * - 1 END AS M060, 
--				case 
--						when t0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 61 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 90 THEN (T0.DocTotal - T0.PaidToDate) * - 1 
--						when t0.u_VttoAgencia is not null and DATEDIFF(DD, T0.u_VttoAgencia+60, @Fecha) >= 61 AND DATEDIFF(DD, T0.u_VttoAgencia+60, @Fecha) <= 90 THEN (T0.DocTotal - T0.PaidToDate) * - 1 END AS M090, 
--				case 
--						when t0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 91 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 120 THEN (T0.DocTotal - T0.PaidToDate) * - 1 
--						when t0.u_VttoAgencia is not null and DATEDIFF(DD, T0.u_VttoAgencia+60, @Fecha) >= 91 AND DATEDIFF(DD, T0.u_VttoAgencia+60, @Fecha) <= 120 THEN (T0.DocTotal - T0.PaidToDate) * - 1 END AS M120,
--				case
--						when t0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 121 THEN (T0.DocTotal - T0.PaidToDate) * - 1 
--						when t0.u_VttoAgencia is not null and DATEDIFF(DD, T0.u_VttoAgencia+60, @Fecha) >= 121 THEN (T0.DocTotal - T0.PaidToDate) * - 1 END AS Mas
--  FROM  ORIN T0
-- INNER JOIN OCRD T2 ON T0.CardCode=T2.CardCode
-- INNER JOIN OCRG T3 ON T3.GroupCode=T2.GroupCode
-- inner join OCTG AS t4 ON T0.GroupNum = t4.GroupNum 
-- WHERE  T0.TaxDate                   <= @Fecha
--   AND (T0.DocTotal - T0.PaidToDate) <>  0
--   AND  T0.DocStatus                  = 'O'
--   AND  T0.BaseAmnt                   =  0
--   AND  T3.GroupName>=@GrupoIni
--   AND  T3.GroupName<=@GrupoFin

) T0

GROUP BY Grupo,Cliente,
         Nombre ,Agencia,
         Hasta
ORDER BY Grupo,Cliente



---select cntctcode,* from oinv where u_facnum = '53'
---select * from ocrd

---select * from vmsv.dbo.oitm where  itemname like '%furi%'
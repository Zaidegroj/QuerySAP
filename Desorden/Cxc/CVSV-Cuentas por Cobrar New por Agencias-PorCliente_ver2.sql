DECLARE @Fecha AS DATETIME,
		@GrupoIni AS VARCHAR(100),
		@GrupoFin AS VARCHAR(100),
		@iInDesign as int

set @iInDesign = 0

if (@iInDesign)=0
	begin
		set @Fecha = '08/31/2011 00:00:00'
		set @GrupoIni = 'Acreedores Exterior'
		set @GrupoFin = 'Proveedores Locales'
	end
else
	begin
		/* SELECT FROM CVSV.DBO.OINV T1 */
		SET @Fecha = /* T1.DocDate */ '[%0]'
		/* SELECT FROM CVSV.DBO.OCRG T2 */
		SET @GrupoIni = /* T2.GroupName */ '[%1]'
		/* SELECT FROM CVSV.DBO.OCRG T2 */
		SET @GrupoFin = /* T2.GroupName */ '[%2]'
	end

SELECT Grupo,
	Cliente                       ,
       Nombre                        ,
Agencia,
       COUNT(Documento) AS Docs      ,
       Hasta                         ,
       SUM(Total )      AS 'Total'   ,
       SUM(Menos )      AS 'Abono/NC',
       SUM(Saldo )      AS 'Saldo'   ,
       SUM(Normal)      AS 'Normal'  ,
       SUM(M030  )      AS ' 1-30'   ,
       SUM(M060  )      AS '31-60'   ,
       SUM(M090  )      AS '61-90'   ,
       SUM(M120  )      AS '91-120'  ,
       SUM(Mas   )      AS 'Mas 120'

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
							when T0.u_VttoAgencia is not null and DATEDIFF(DD, @Fecha,T0.u_VttoAgencia) <= 0 then (T0.DocTotal - T0.PaidToDate) end as Normal,
						case 
							when T0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 1 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 30 THEN (T0.DocTotal - T0.PaidToDate) 
							when T0.u_VttoAgencia is not null and DATEDIFF(DD, @Fecha,T0.u_VttoAgencia) >= 1 AND DATEDIFF(DD,@Fecha,T0.u_VttoAgencia) <= 30 THEN (T0.DocTotal - T0.PaidToDate) END AS M030,
						case 
							when T0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 31 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 60 THEN (T0.DocTotal - T0.PaidToDate) 
							when T0.u_VttoAgencia is not null and DATEDIFF(DD, @Fecha,T0.u_VttoAgencia) >= 31 AND DATEDIFF(DD,@Fecha, T0.u_VttoAgencia) <= 60 THEN (T0.DocTotal - T0.PaidToDate) END AS M060,
						case 
							when t0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 61 AND DATEDIFF(DD,T0.DocDueDate, @Fecha) <= 90 THEN (T0.DocTotal - T0.PaidToDate) 
							when t0.u_VttoAgencia is not null and DATEDIFF(DD, @Fecha,T0.u_VttoAgencia) >= 61 AND DATEDIFF(DD,@Fecha,T0.u_VttoAgencia) <= 90 THEN (T0.DocTotal - T0.PaidToDate) END AS M090, 					
						case 
							when t0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 91 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 120 THEN (T0.DocTotal - T0.PaidToDate) 
							when t0.u_VttoAgencia is not null and DATEDIFF(DD, @Fecha,T0.u_VttoAgencia) >= 91 AND DATEDIFF(DD,@Fecha,T0.u_VttoAgencia) <= 120 THEN (T0.DocTotal - T0.PaidToDate) END AS M120, 
						case 
							when t0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate,@Fecha) >= 121 THEN (T0.DocTotal - T0.PaidToDate) 
							when t0.u_VttoAgencia is not null and DATEDIFF(DD, @Fecha,T0.u_VttoAgencia) >= 121 THEN (T0.DocTotal - T0.PaidToDate) END AS Mas

  FROM  OINV T0
 INNER JOIN OCRD T2 ON T0.CardCode=T2.CardCode
 INNER JOIN OCRG T3 ON T3.GroupCode=T2.GroupCode
 inner join OCTG AS t4 ON T0.GroupNum = t4.GroupNum 
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
						when T0.u_VttoAgencia is not null and datediff(dd,T0.u_VttoAgencia+60,@Fecha)<=0 then (T0.DocTotal - T0.PaidToDate)* - 1 END AS Normal,
				case 
						when T0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 1 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 30 THEN (T0.DocTotal - T0.PaidToDate) * - 1 
						when t0.u_VttoAgencia is not null and datediff(dd,T0.u_VttoAgencia+60,@Fecha) >=1 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 30 THEN (T0.DocTotal - T0.PaidToDate) * - 1 END AS M030, 
				case 
						when t0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 31 AND DATEDIFF(DD,T0.DocDueDate, @Fecha) <= 60 THEN (T0.DocTotal - T0.PaidToDate) * - 1 
						when t0.u_VttoAgencia is not null and DATEDIFF(DD, T0.u_VttoAgencia+60, @Fecha) >= 31 AND DATEDIFF(DD,T0.u_vttoAgencia+60, @Fecha) <= 60 THEN (T0.DocTotal - T0.PaidToDate) * - 1 END AS M060, 
				case 
						when t0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 61 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 90 THEN (T0.DocTotal - T0.PaidToDate) * - 1 
						when t0.u_VttoAgencia is not null and DATEDIFF(DD, T0.u_VttoAgencia+60, @Fecha) >= 61 AND DATEDIFF(DD, T0.u_VttoAgencia+60, @Fecha) <= 90 THEN (T0.DocTotal - T0.PaidToDate) * - 1 END AS M090, 
				case 
						when t0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 91 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 120 THEN (T0.DocTotal - T0.PaidToDate) * - 1 
						when t0.u_VttoAgencia is not null and DATEDIFF(DD, T0.u_VttoAgencia+60, @Fecha) >= 91 AND DATEDIFF(DD, T0.u_VttoAgencia+60, @Fecha) <= 120 THEN (T0.DocTotal - T0.PaidToDate) * - 1 END AS M120,
				case
						when t0.u_VttoAgencia is null and DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 121 THEN (T0.DocTotal - T0.PaidToDate) * - 1 
						when t0.u_VttoAgencia is not null and DATEDIFF(DD, T0.u_VttoAgencia+60, @Fecha) >= 121 THEN (T0.DocTotal - T0.PaidToDate) * - 1 END AS Mas
  FROM  ORIN T0
 INNER JOIN OCRD T2 ON T0.CardCode=T2.CardCode
 INNER JOIN OCRG T3 ON T3.GroupCode=T2.GroupCode
 inner join OCTG AS t4 ON T0.GroupNum = t4.GroupNum 
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
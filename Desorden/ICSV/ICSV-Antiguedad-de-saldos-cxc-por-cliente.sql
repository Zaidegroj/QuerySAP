/* Por Cliente*/

DECLARE @Fecha AS DATETIME,
		@GrupoIni AS VARCHAR(100),
		@GrupoFin AS VARCHAR(100),
		@Tc    AS NUMERIC(19,6),
		@iInDesign as int 

set @iInDesign = 1

if (@iInDesign = 1)
	begin
		set @Fecha		= '10/31/2011 00:00:00'
		set @GrupoIni	= 'Acreedores Exterior'
		set @GrupoFin	= 'Proveedores Locales'
		set @Tc			= 8.04
	end
else
	begin
		/* SELECT FROM vmsv.DBO.OINV T1 */
		SET @Fecha = /* T1.DocDate */ '[%0]'
		/* SELECT FROM vmsv.DBO.OCRG T2 */
		SET @GrupoIni = /* T2.GroupName */ '[%1]'
		/* SELECT FROM vmsv.DBO.OCRG T2 */
		SET @GrupoFin = /* T2.GroupName */ '[%2]'
		/* SELECT FROM vmsv.DBO.ORTT T0 */
		SET @Tc    =  1 
	end


SELECT Grupo,
	Cliente                       ,
       Nombre                        ,
       COUNT(Documento) AS Docs      , 
       Hasta                         ,
       /*max(Cambio) as Cambio,*/
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

SELECT T3.GroupName			AS Grupo,
	T0.CardCode                                 AS Cliente  ,
       T0.CardName                                 AS Nombre   ,
       T0.DocNum                                   AS Documento,
       @Fecha                                      AS Hasta    ,
       T0.DocTotal                                 AS Total    ,
       T0.PaidToDate                               AS Menos    ,
      (T0.DocTotal   - T0.PaidToDate)              AS Saldo    ,

  CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) <=   0
       THEN (T0.DocTotal - T0.PaidToDate) END      AS Normal   ,

  CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >=   1 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <=  30
       THEN (T0.DocTotal - T0.PaidToDate) END      AS M030     ,

  CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >=  31 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <=  60
       THEN (T0.DocTotal - T0.PaidToDate) END      AS M060     ,

  CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >=  61 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <=  90
       THEN (T0.DocTotal - T0.PaidToDate) END      AS M090     ,

  CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >=  91 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 120
       THEN (T0.DocTotal - T0.PaidToDate) END      AS M120     ,

  CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 121
       THEN (T0.DocTotal - T0.PaidToDate) END      AS Mas,
  @Tc                                               AS Cambio
  FROM  icsv.dbo.OINV T0
 INNER JOIN icsv.dbo.OCRD T2 ON T0.CardCode=T2.CardCode
 INNER JOIN icsv.dbo.OCRG T3 ON T3.GroupCode=T2.GroupCode
 WHERE  T0.TaxDate                   <= @Fecha
   AND (T0.DocTotal - T0.PaidToDate) <> 0
   AND  T3.GroupName>=@GrupoIni
   AND  T3.GroupName<=@GrupoFin

UNION ALL

SELECT T3.GroupName			AS Grupo,
	T0.CardCode                                 AS Cliente  ,
       T0.CardName                                 AS Nombre   ,
       T0.DocNum                                   AS Documento,
       @Fecha                                      AS Hasta    ,
       T0.DocTotal                        * -1     AS Total    ,
       T0.PaidToDate                      * -1     AS Menos    ,
      (T0.DocTotal - T0.PaidToDate)       * -1     AS Saldo    ,

  CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) <=   0
       THEN (T0.DocTotal - T0.PaidToDate) * -1 END AS Normal   ,

  CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >=   1 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <=  30
       THEN (T0.DocTotal - T0.PaidToDate) * -1 END AS M030     ,

  CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >=  31 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <=  60
       THEN (T0.DocTotal - T0.PaidToDate) * -1 END AS M060     ,

  CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >=  61 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <=  90
       THEN (T0.DocTotal - T0.PaidToDate) * -1 END AS M090     ,

  CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >=  91 AND DATEDIFF(DD, T0.DocDueDate, @Fecha) <= 120
       THEN (T0.DocTotal - T0.PaidToDate) * -1 END AS M120     ,

  CASE WHEN DATEDIFF(DD, T0.DocDueDate, @Fecha) >= 121
       THEN (T0.DocTotal - T0.PaidToDate) * -1 END AS Mas,
   @Tc                                               AS Cambio
  FROM  icsv.dbo.ORIN T0
 INNER JOIN icsv.dbo.OCRD T2 ON T0.CardCode=T2.CardCode
 INNER JOIN icsv.dbo.OCRG T3 ON T3.GroupCode=T2.GroupCode
 WHERE  T0.TaxDate                   <= @Fecha
   AND (T0.DocTotal - T0.PaidToDate) <>  0
   AND  T0.DocStatus                  = 'O'
   AND  T0.BaseAmnt                   =  0
   AND  T3.GroupName>=@GrupoIni
   AND  T3.GroupName<=@GrupoFin

) T0

GROUP BY Grupo,Cliente,
         Nombre ,
         Hasta
ORDER BY Grupo,Cliente



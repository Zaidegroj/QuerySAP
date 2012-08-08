DECLARE @Fecha AS DATETIME,
		@GrupoIni AS VARCHAR(100),
		@GrupoFin AS VARCHAR(100),
		@iInDesign as numeric

set @iInDesign = 1

if (@iInDesign)=1
	begin
		SET @Fecha = '2012-04-30 00:00:00'
		SET @GrupoIni = 'Acreedores Exterior'
		SET @GrupoFin = 'Theatrical'
	end
else
	begin
		/* SELECT FROM ICSV.DBO.OINV T1 */
		SET @Fecha = /* T1.DocDate */ '[%0]'
		/* SELECT FROM ICSV.DBO.OCRG T2 */
		SET @GrupoIni = /* T2.GroupName */ '[%1]'
		/* SELECT FROM ICSV.DBO.OCRG T2 */
		SET @GrupoFin = /* T2.GroupName */ '[%2]'
	end

SELECT Cliente            ,
       Nombre             ,
       Serie              ,
		u_Suc_Distribuidor as [Codigo Sucursal],
		name as [Sucursal],
       Documento          ,
       Fecha              ,
       Vence              ,
       Hasta              ,
       Total              ,
       Menos AS 'Abono/NC',
       Saldo              ,
       Normal             ,
       M030  AS ' 1-30'   ,
       M060  AS '31-60'   ,
       M090  AS '61-90'   ,
       M120  AS '91-120'  ,
       Mas   AS 'Mas 120'
FROM (

		SELECT T0.CardCode                                 AS Cliente  ,
			   --T0.CardName                                 AS Nombre   ,
			   t0.u_Facnom as	Nombre,
			   T1.SeriesName                               AS Serie    ,
			   T0.DocNum                                   AS Documento,
			   T0.TaxDate                                  AS Fecha    ,
			   T0.DocDueDate                               AS Vence    ,
			   @Fecha                                      AS Hasta    ,
				t0.u_Suc_Distribuidor						,
				t4.Name							,
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
		  T3.GroupName AS GRUPO

		  FROM	OINV T0 INNER JOIN NNM1 T1 ON T0.Series = T1.Series
				INNER JOIN OCRD T2 ON T0.CardCode=T2.CardCode
				INNER JOIN OCRG T3 ON T3.GroupCode=T2.GroupCode
				left join [@detallesucursales] t4 on t4.code = t0.u_Suc_Distribuidor
		 WHERE  T0.TaxDate                   <= @Fecha
				AND (T0.DocTotal - T0.PaidToDate) <> 0
				AND  T3.GroupName>=@GrupoIni
				AND  T3.GroupName<=@GrupoFin

		UNION ALL

		SELECT T0.CardCode                                 AS Cliente  ,
			   --T0.CardName                                 AS Nombre   ,
			   t0.u_FacNom 							   as Nombre,
			   T1.SeriesName                               AS Serie    ,
			   T0.DocNum                                   AS Documento,
			   T0.TaxDate                                  AS Fecha    ,
			   T0.DocDueDate                               AS Vence    ,
			   @Fecha                                      AS Hasta    ,
				t0.u_Suc_Distribuidor						,
				t4.Name							,
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
		  T3.GroupName AS GRUPO

		FROM	ORIN T0 INNER JOIN NNM1 T1 ON T0.Series = T1.Series
				INNER JOIN OCRD T2 ON T0.CardCode=T2.CardCode
				INNER JOIN OCRG T3 ON T3.GroupCode=T2.GroupCode
				left join [@detallesucursales] t4 on t4.code = t0.u_Suc_Distribuidor 
		WHERE	T0.TaxDate                   <= @Fecha
				AND (T0.DocTotal - T0.PaidToDate) <>  0
				AND  T0.DocStatus                  = 'O'
				AND  T0.BaseAmnt                   =  0
				AND  T3.GroupName>=@GrupoIni
				AND  T3.GroupName<=@GrupoFin
	) T0

ORDER BY Cliente  ,
         Serie    ,
         Documento


---select * from oinv where u_Suc_Distribuidor = '1020011'
---select * from [@detallesucursales]
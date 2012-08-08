DECLARE @FechaIni	AS DATETIME,
		@FechaFin	AS DATETIME,
		@CodIni		AS VARCHAR(100),
		@CodFin		AS VARCHAR(100),
		@iInDesign as int 


set @iInDesign = 1 

if (@iInDesign=1)
	begin
		SET @FechaIni	= '01/01/2010 00:00:00'
		set @FechaFin	= '05/31/2010 00:00:00'
		SET @CodIni		= 'Acreedores Exterior' 
		SET @CodFin		= 'Theatrical'
	end
else
	begin
		/* SELECT FROM ICSV.DBO.OINV T0 */
		SET @FechaIni= /* T0.DocDate */ '[%0]'
		/* SELECT FROM ICSV.DBO.OINV T0 */
		SET @FechaFin= /* T0.DocDate */ '[%1]'
		/* SELECT FROM ICSV.DBO.OCRG T1 */
		SET @CodIni= /* T1.GroupName */ '[%3]'
		/* SELECT FROM ICSV.DBO.OCRG T1 */
		SET @CodFin = /* T1.GroupName */ '[%4]'
	end

SELECT T0.U_FacFecha                             AS Fecha    ,
       T0.U_FacSerie                             AS Tipo     ,
       T0.U_FacNum                               AS Numero   ,
       T0.Series                                 AS SAPSerie ,
       T0.DocNum                                 AS SAPNum   ,
       T4.GroupName				 AS Grupo,
       T0.CardCode                               AS Cliente  ,
       t2.u_nrc as [Registro],
		t0.u_Suc_Distribuidor as [Distribuidor],
       T0.U_FacNom                               AS Nombre   ,
       T0.SlpCode                                AS Vendedor ,
      (T0.Max1099 - T0.VatSum + T0.DiscSum)      AS Base     ,
       T0.DiscSum                                AS Descuento,
       T0.VatSum                                 AS IVA      ,
       T0.Max1099                                AS Total    ,
       T0.WTSum                                  AS Retención,
       T0.DocTotal                               AS 'A Pagar'
 FROM OINV T0 LEFT JOIN OCRD T2 ON T0.CardCode =T2.CardCode 
		LEFT JOIN OCRG T4 ON T2.GroupCode = T4.GroupCode
		
 WHERE T0.DocDate >= @FechaIni
   AND T0.DocDate <= @FechaFin
   AND T4.GroupName >=@CodIni 
   AND T4.GroupName <=@CodFin

UNION

SELECT T1.U_FacFecha                             AS Fecha    ,
       T1.U_FacSerie                             AS Tipo     ,
       T1.U_FacNum                               AS Numero   ,
       T1.Series                                 AS SAPSerie ,
       T1.DocNum                                 AS SAPNum   ,
       T5.GroupName				 AS Grupo    ,
       T1.CardCode                               AS Cliente  ,
       t3.u_nrc as [Registro],
	   t1.u_Suc_Distribuidor as [Distribuidor],
       T1.U_FacNom                               AS Nombre   ,
       T1.SlpCode                                AS Vendedor ,
      (T1.Max1099 - T1.VatSum + T1.DiscSum) * -1 AS Base     ,
       T1.DiscSum                           * -1 AS Descuento,
       T1.VatSum                            * -1 AS IVA      ,
       T1.Max1099                           * -1 AS Total    ,
       T1.WTSum                             * -1 AS Retención,
       T1.DocTotal                          * -1 AS 'A Pagar'
 FROM ORIN T1 LEFT JOIN OCRD T3 ON T1.CardCode =T3.CardCode LEFT JOIN OCRG T5 ON T3.GroupCode = T5.GroupCode
 WHERE T1.DocDate >= @FechaIni
   AND T1.DocDate <= @FechaFin
   AND T5.GroupName >=@CodIni 
   AND T5.GroupName <=@CodFin


--select * from oinv
--select * from [@Detallesucursales]
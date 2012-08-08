/*DOC X SERVICIO */
DECLARE @FechaIni	AS DATETIME,
		@FechaFin	AS DATETIME,
		@CodIni		AS VARCHAR(100),
		@CodFin		AS VARCHAR(100),
		@iInDesign as int


set @iInDesign = 1

if (@iInDesign=1)
	begin
		set @FechaIni = '01/01/2012 00:00:00'
		set @FechaFin = '01/31/2012 00:00:00'
		set @CodIni = 'Acreedores Exterior'
		set @CodFin = 'Proveedores Locales'
	end
else
	begin
		/* SELECT FROM VMCR.DBO.OINV T0 */
		SET @FechaIni= /* T0.DocDate */ '[%0]'
		/* SELECT FROM VMCR.DBO.OINV T0 */
		SET @FechaFin= /* T0.DocDate */ '[%1]'
		/* SELECT FROM VMCR.DBO.OCRG T1 */
		SET @CodIni= /* T1.GroupName */ '[%2]'
		/* SELECT FROM VMCR.DBO.OCRG T1 */
		SET @CodFin = /* T1.GroupName */ '[%3]'
	end


SELECT T1.U_FacFecha                             AS Fecha    ,
       T1.U_FacSerie                             AS Tipo     ,
       T1.U_FacNum                               AS Numero   ,
       T1.Series                                 AS SAPSerie ,
       T1.DocNum                                 AS SAPNum   ,
	T1.CardCode                              AS Cliente    ,  
	 T1.U_FacNom         			 AS Nombre,  
   --T1.Max1099 - T1.VatSum + T1.DiscSum           AS Bruto    ,
	t2.price							as Bruto,
   T1.DiscSum                                    AS Descuento,
   --T1.Max1099 - T1.VatSum                        AS Neto,
	t2.price as Neto,
   T2.Dscription			  ,
   T1.Comments                              AS Comentario 

  FROM      OINV T1 
	INNER JOIN INV1 T2 ON T2.DocEntry   = T1.DocEntry
  LEFT JOIN OCRD T3 ON T1.CardCode   = T3.CardCode
 LEFT JOIN OCRG T4 ON T4.GroupCode = T3.GroupCode
 WHERE T1.DocDate   >= @FechaIni
   AND T1.DocDate   <= @FechaFin
   AND T1.DocType    = 'S'
   AND T4.GroupName  >=@CodIni
   AND T4.GroupName <=@CodFin


UNION ALL

SELECT T1.U_FacFecha                             AS Fecha    ,
       T1.U_FacSerie                             AS Tipo     ,
       T1.U_FacNum                               AS Numero   ,
       T1.Series                                 AS SAPSerie ,
       T1.DocNum                                 AS SAPNum   ,
	T1.CardCode                              AS Cliente    ,  
	 T1.U_FacNom         			 AS Nombre,  
   --(T1.Max1099 - T1.VatSum + T1.DiscSum) *-1          AS Bruto    ,
	t2.Price * -1 as Bruto,
   (T1.DiscSum)     *-1                               AS Descuento,
   --(T1.Max1099 - T1.VatSum) *-1                       AS Neto,
	t2.Price * -1 as Neto,
   T2.Dscription			  ,
   T1.Comments                              AS Comentario 

  FROM      ORIN T1 
	INNER JOIN RIN1 T2 ON T2.DocEntry   = T1.DocEntry
  LEFT JOIN OCRD T3 ON T1.CardCode   = T3.CardCode
 LEFT JOIN OCRG T4 ON T4.GroupCode = T3.GroupCode
 WHERE T1.DocDate   >= @FechaIni
   AND T1.DocDate   <= @FechaFin
   AND T1.DocType    = 'S'
   AND T4.GroupName >=@CodIni
   AND T4.GroupName <=@CodFin


---select * from inv1
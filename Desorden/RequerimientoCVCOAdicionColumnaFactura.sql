DECLARE @Fecha1 AS DATETIME
DECLARE @Fecha2 AS DATETIME,
		@iInDesign as int



set @iInDesign = 1

if (@iInDesign=1)
	begin
		set @fecha1 = '01/01/2011 00:00:00'
		set @fecha2 = '01/31/2011 00:00:00'
	end
else
	begin
		/* SELECT FROM CVCO.DBO.OINV T0 */
		SET @Fecha1 = /* T0.DocDate */ '[%0]'
		/* SELECT FROM CVCO.DBO.OINV T0 */
		SET @Fecha2 = /* T0.DocDate */ '[%1]'
	end




SELECT  Factura,NombreCliente as [Nombre de Cliente],Rubro,
	ISNULL(Descripcion,'Sin Clasificacion de Rubro')	AS DESCRIPCION,
	Cod_Complejo 						AS COMPLEJO,
	Complejo						AS DESCRIPCION,
        SUM(Facturado) 						AS '(+) VTA CLIENTE'	,
        SUM(Factu_AFI)						AS '(+) VTA AFI'	,
	SUM(NC)							AS '(-) NC'		,
	SUM(NCI)						AS '(-) NCI'		,
	SUM(Facturado + Factu_AFI - NC - NCI) 			AS 'NETO'
FROM (

SELECT t1.u_facnum as Factura,t1.u_facNom as NombreCliente,ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
        T2.Name              		AS Descripcion,
	T0.U_complejo 			AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
       SUM(T0.LineTotal)          AS Facturado,
       0 		     AS Factu_AFI,
       0 		     AS NC,
       0 		     AS NCI
  FROM      [CVCO].[dbo].[INV1]    T0
 INNER JOIN [CVCO].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
 GROUP BY t1.u_facnum,t1.u_facnom,T0.U_Rubro,
	  T2.Name,
          T0.U_complejo,
	  T4.name


 
UNION ALL

SELECT t1.u_facnum,t1.u_facnom,ISNULL(T0.U_Rubro,'')				AS Rubro      ,
       T2.Name						AS Descripcion,
	T0.U_complejo 			AS Cod_Complejo,
	ISNULL(T5.name,'Sin Complejo')  		AS Complejo,
	SUM(T0.LineTotal)*-1		    	AS Facturado,
       0						AS Factu_AFI,
       0 						AS NC,
       0 						AS NCI
  FROM      [CVCO].[dbo].[INV1]    T0
 INNER JOIN [CVCO].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
 LEFT  JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T5 ON T0.U_complejo = T5.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T4.Groupcode = '103'
 GROUP BY t1.u_facnum,t1.u_facnom,T0.U_Rubro,
	  T2.Name,
	  T0.U_complejo,
	  T5.name


UNION ALL

SELECT t1.u_facnum,t1.u_facnom,ISNULL(T0.U_Rubro,'') AS Rubro      ,
       T2.Name               AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T5.name,'Sin Complejo')  AS Complejo,
	0		     AS Facturado,
       SUM(T0.LineTotal)     AS Factu_AFI,
       0 		     AS NC,
       0 		     AS NCI
  FROM      [CVCO].[dbo].[INV1]    T0
 INNER JOIN [CVCO].[dbo].[OINV]    T1 ON T0.DocEntry           = T1.DocEntry
 LEFT  JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
 LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
 LEFT  JOIN [CVCO].[dbo].[OCRD] T4 ON T1.CardCode = T4.CardCode
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T5 ON T0.U_complejo = T5.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0
   AND T4.Groupcode = '103'
 GROUP BY t1.u_facnum,t1.u_facnom,T0.U_Rubro,
	  T2.Name,
	  T0.U_complejo,
	  T5.name


UNION ALL

SELECT t1.u_facnum,t1.u_facnom,ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	T0.U_complejo   	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)     	AS NCI
  FROM      [CVCO]. [dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'

 GROUP BY t1.u_facnum,t1.u_facnom,T0.U_Rubro      ,
	  T2.Name,
	  T0.U_complejo,
	  T4.name


UNION ALL

SELECT t1.u_facnum,t1.u_facnom,ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
       SUM(T0.LineTotal)     		AS NC,
	0 				AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'

 GROUP BY t1.u_facnum,t1.u_facnom,T0.U_Rubro      ,
	  T2.Name,
  	  T0.U_complejo,
	  T4.name

UNION ALL
/*******OPEN SEG CASOS ESPECIALES*******/

SELECT t1.u_facnum,t1.u_facnom,'101' 						AS Rubro      ,
       'PEP Spots - 35 mm Ci0eColombia'               		AS Descripcion,
	T0.U_complejo  					AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)    	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - 35 mm CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_complejo ,T4.name

union all

SELECT t1.u_facnum,t1.u_facnom,'111' 						AS Rubro      ,
       'PEP Spots - 35 mm  Cinemark'               		AS Descripcion,
	T0.U_complejo  					AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)    	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - 35 mm  Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,t0.U_complejo ,T4.name

UNION ALL

SELECT t1.u_facnum,t1.u_facnom,'112' 						AS Rubro      ,
       'PEP Spots - DVD  Cinemark'               		AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - DVD  Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_complejo ,T4.name

union all

SELECT t1.u_facnum,t1.u_facnom,'102' 						AS Rubro      ,
       'PEP Spots - DVD  CineColombia'               		AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - DVD  CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_complejo ,T4.name

UNION ALL

SELECT t1.u_facnum,t1.u_facnom,'113' 						AS Rubro      ,
       'PEP Spots - SD  Cinemark'               		AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - SD  Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_complejo ,T4.name

 union all

SELECT t1.u_facnum,t1.u_facnom,'103' 						AS Rubro      ,
       'PEP Spots - SD  CineColombia'               		AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - SD  CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_complejo ,T4.name

/*CLOSE SEGMENTO DE CASOS ESPECIALES*/
/*para RESTAR*/
UNION ALL

SELECT t1.u_facnum,t1.u_facnom,ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)*-1     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - 35 mm CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_Rubro,T0.U_complejo ,T2.Name,T4.name

UNION ALL

SELECT t1.u_facnum,t1.u_facnom,ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)*-1     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - 35 mm  Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_Rubro,T0.U_complejo ,T2.Name,T4.name


UNION ALL

SELECT t1.u_facnum,t1.u_facnom,ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)*-1     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - DVD  Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_Rubro,T0.U_complejo ,T2.Name,T4.name

union all

SELECT t1.u_facnum,t1.u_facnom,ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)*-1     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - DVD  CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_Rubro,T0.U_complejo ,T2.Name,T4.name

union all

SELECT t1.u_facnum,t1.u_facnom,ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)*-1     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - SD  Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_Rubro,T0.U_complejo ,T2.Name,T4.name

union all

SELECT t1.u_facnum,t1.u_facnom,ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	0 		    	 	AS NC,
       SUM(T0.LineTotal)*-1     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - SD  CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_Rubro,T0.U_complejo ,T2.Name,T4.name


/*CLOSE SEGMENTO DE CASOS ESPECIALES RESTANDO NCI*/
UNION ALL
/********OPEN CASO PARA NC*********/

SELECT t1.u_facnum,t1.u_facnom,'101' 						AS Rubro      ,
       'PEP Spots - 35 mm CineColombia'               		AS Descripcion,
	T0.U_complejo  					AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal) 		    	 	AS NC,
        0   	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - 35 mm CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_complejo ,T4.name

union all

SELECT t1.u_facnum,t1.u_facnom,'111' 						AS Rubro      ,
       'PEP Spots - 35 mm  Cinemark'               		AS Descripcion,
	T0.U_complejo  					AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)    	 	AS NC,
       0    	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - 35 mm  Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_complejo ,T4.name

UNION ALL

SELECT t1.u_facnum,t1.u_facnom,'112' 						AS Rubro      ,
       'PEP Spots - DVD  Cinemark'               		AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)  		    	 	AS NC,
       0    	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - DVD  Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_complejo ,T4.name

union all

SELECT t1.u_facnum,t1.u_facnom,'102' 						AS Rubro      ,
       'PEP Spots - DVD  CineColombia'               		AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)     	 	AS NC,
       0    	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - DVD  CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT  LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_complejo ,T4.name

UNION ALL

SELECT t1.u_facnum,t1.u_facnom,'113' 						AS Rubro      ,
       'PEP Spots - SD  Cinemark'               		AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)    	 	AS NC,
       0    	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - SD  Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_complejo ,T4.name

 union all

SELECT t1.u_facnum,t1.u_facnom,'103' 						AS Rubro      ,
       'PEP Spots - SD  CineColombia'               		AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)    	 	AS NC,
       0     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - SD  CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_complejo ,T4.name

/*CLOSE SEGMENTO DE CASOS ESPECIALES*/
/*para RESTAR*/
UNION ALL

SELECT t1.u_facnum,t1.u_facnom,ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)*-1    	 	AS NC,
       0     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - 35 mm CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_Rubro,T0.U_complejo ,T2.Name,T4.name

UNION ALL

SELECT t1.u_facnum,t1.u_facnom,ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	 SUM(T0.LineTotal)*-1  	 	AS NC,
      0     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - 35 mm  Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_Rubro,T0.U_complejo ,T2.Name,T4.name


UNION ALL

SELECT t1.u_facnum,t1.u_facnom,ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)*-1	    	 	AS NC,
       0     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - DVD  Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_Rubro,T0.U_complejo ,T2.Name,T4.name

union all

SELECT t1.u_facnum,t1.u_facnom,ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)*-1 		    	 	AS NC,
         0    	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - DVD  CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT  LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_Rubro,T0.U_complejo ,T2.Name,T4.name

union all

SELECT t1.u_facnum,t1.u_facnom,ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	 SUM(T0.LineTotal)*-1 		    	 	AS NC,
      0     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - SD  Cinemark%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie NOT  LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_Rubro,T0.U_complejo ,T2.Name,T4.name

union all

SELECT t1.u_facnum,t1.u_facnom,ISNULL(T0.U_Rubro,'') 		AS Rubro      ,
       T2.Name               		AS Descripcion,
	T0.U_complejo  	AS Cod_Complejo,
	ISNULL(T4.name,'Sin Complejo')  AS Complejo,
	0				AS Facturado,
        0		   		AS Factu_AFI,
	SUM(T0.LineTotal)*-1   	 	AS NC,
       0     	AS NCI
  FROM      [CVCO].[dbo].[RIN1]    T0
 INNER JOIN [CVCO].[dbo].[ORIN]    T1 ON T0.DocEntry           = T1.DocEntry
  LEFT JOIN [CVCO].[dbo].[@RUBROS] T2 ON ISNULL(T0.U_Rubro,'') = T2.Code
  LEFT JOIN [CVSV].[dbo].[@RUBROS] T3 ON ISNULL(T0.U_Rubro,'') = T3.Code
  LEFT JOIN [CVCO].[dbo].[@COMPLEJOS] T4 ON T0.U_complejo = T4.code
 WHERE T1.DocDate   >= @Fecha1
   AND T1.DocDate   <= @Fecha2
AND T1.Comments LIKE 'PEP Spots - SD  CineColombia%'
   AND T0.LineTotal <> 0  AND T1.U_FacSerie LIKE 'NCI%'
AND  T0.U_Rubro IS NULL AND T2.Name IS NULL
GROUP BY t1.u_facnum,t1.u_facnom,T0.U_Rubro,T0.U_complejo ,T2.Name,T4.name


/*CLOSE SEGMENTO DE CASOS ESPECIALES RESTANDO*/
) T0 GROUP BY Factura,NombreCliente,Rubro, Descripcion,Cod_Complejo,Complejo HAVING SUM(Facturado + Factu_AFI - NC - NCI)<>0.00 ORDER BY Rubro


--select * from oinv
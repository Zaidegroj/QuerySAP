DECLARE @FechaIni AS DATETIME,
		@FechaFin AS DATETIME,
		@GT AS NUMERIC(19,4),
		@Tc as numeric(10,4),
		@InDesign as int 

set @InDesign = 1 

if (@InDesign = 1)
	begin
		set @FechaIni	= '11/01/2010 00:00:00'
		set @FechaFin	= '11/19/2010 00:00:00'
		set @Tc			= 8.04
	end
else
	begin
		/* SELECT FROM PRGT.DBO.OINV T0*/
		SET @FechaIni	= /* T0.DocDate*/ '[%0]'
		SET @FechaFin	= /* T0.DocDate*/ '[%1]'
		/* select from prgt.dbo.ortt T1 */
		SET @Tc			= /* T1.rate */'[%2]'
	end


CREATE TABLE #VENTAS (
GRUPO  VARCHAR(200) NULL,
CODIGO VARCHAR(20)  NULL,
NOMBRE VARCHAR(200) NULL,
CANT   SMALLINT  NULL,
PRECIO NUMERIC(19,4) NULL,
COSTO  NUMERIC(19,4) NULL) 

CREATE TABLE #VENT_AFI_CLI (
GRUPO  VARCHAR(200) NULL,
CODIGO VARCHAR(20)  NULL,
NOMBRE VARCHAR(200) NULL,
CANT   SMALLINT NULL,
PRECIO NUMERIC(19,4) NULL,
COSTO  NUMERIC(19,4) NULL) 



INSERT #VENT_AFI_CLI
SELECT Grupo ,
       Codigo  ,
       Nombre   ,
       SUM(Cant_V)	AS NETO, /*Calc neto y prom del costo segun lo neto/distinto precios*/
        Precio_V	,	
      AVG(Costo_V) AS COSTO
  FROM(

SELECT  
	T3.ItmsGrpNam                	AS Grupo   ,
	T0.ItemCode                 	AS Codigo ,
        T2.ItemName                  	AS Nombre  ,
       	T0.Quantity                 	AS Cant_V  ,
     	T0.Price                       	AS Precio_V,
   	/*T0.GrossBuyPr -->se cambio x el costo q tiene en el maestro d articulos*/
	T2.AvgPrice		 	AS Costo_V       
  FROM      INV1 T0
  LEFT JOIN OINV T1 ON T0.DocEntry   = T1.DocEntry
  LEFT JOIN OITM T2 ON T0.ItemCode   = T2.ItemCode
  LEFT JOIN OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
  LEFT JOIN OCRD T4 ON T1.CardCode   = T4.CardCode
  LEFT JOIN OCRG T5 ON T4.GroupCode = T5.GroupCode
	
 WHERE T1.DocDate >= @FechaIni
   AND T1.DocDate <= @FechaFin
   AND T4.GroupCode <>104
 /*ORDER BY T3.ItmsGrpNam,
	 T0.ItemCode,
          T2.ItemName ,
          T3.ItmsGrpCod,
          T0.Quantity,T0.Price,T0.GrossBuyPr*/

UNION ALL

SELECT 	
	T3.ItmsGrpNam               	 AS Grupo,
	T0.ItemCode                 	 AS Codigo,
       	T2.ItemName                	 AS Nombre,
	T0.Quantity*-1                      AS Cant_V  ,
        T0.Price 	                 AS Precio_V,
       	T2.AvgPrice                   AS Costo_V 
        
  FROM      RIN1 T0
  LEFT JOIN ORIN T1 ON T0.DocEntry   = T1.DocEntry
  LEFT JOIN OITM T2 ON T0.ItemCode   = T2.ItemCode
  LEFT JOIN OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
  LEFT JOIN OCRD T4 ON T1.CardCode   = T4.CardCode
  LEFT JOIN OCRG T5 ON T4.GroupCode = T5.GroupCode
 WHERE T1.DocDate >= @FechaIni
   AND T1.DocDate <= @FechaFin
   AND T4.GroupCode <>104
 /*ORDER BY T0.ItemCode,
          T2.ItemName ,
          T3.ItmsGrpCod,
          T3.ItmsGrpNam,T0.Quantity,T0.Price,T0.GrossBuyPr*/

) T0 GROUP BY 
       Codigo  ,
       Nombre   ,
       Grupo,
	Precio_V /*descartando el costo para calc prom SOLO de precios EN EL SIG PASO*/
        /*Costo_V */
HAVING SUM(Cant_V)<>0
 ORDER BY 
          Grupo,Codigo  



/*PARA EL DESPLIEGE*/

INSERT INTO #VENTAS
SELECT GRUPO,CODIGO,NOMBRE,SUM(CANT),SUM(PRECIO*CANT),AVG(COSTO) 
FROM #VENT_AFI_CLI 
GROUP BY GRUPO,CODIGO,NOMBRE

-- Aplica la conversión al tipo de cambio seleccionado

update #Ventas set precio = Round(precio/@Tc,2),Costo = Round(Costo/@Tc,2)
---select * from #Ventas

SELECT GRUPO AS Grupo,CODIGO AS Codigo,NOMBRE AS Nombre,CANT AS 'Cant. Neta',PRECIO/CANT AS 'P. Promedio',
		COSTO AS 'Costo',(PRECIO/CANT)-COSTO AS Utilidad 
FROM #VENTAS GROUP BY GRUPO,CODIGO,NOMBRE,CANT,PRECIO/CANT,COSTO,PRECIO-COSTO HAVING CANT <>0



DROP TABLE #VENTAS
DROP TABLE #VENT_AFI_CLI
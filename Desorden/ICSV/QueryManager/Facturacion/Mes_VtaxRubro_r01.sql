set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go




ALTER PROCEDURE [dbo].[Mes_VtaxRubro_r01]
	
@FechaIni	AS DATETIME,
@FechaFin	AS DATETIME,
@CodIni		AS VARCHAR(100),
@CodFin		AS VARCHAR(100),
@GrupIni	AS VARCHAR(100),
@GrupFin	AS VARCHAR(100)


AS
INSERT INTO #TmpGeneMes
SELECT Grupo,Cliente,Nombre,SUM(Valor) AS Venta FROM(
SELECT      
       T5.GroupName                          AS Grupo,
       T1.CardCode                           AS Cliente          ,
       T3.CardName                           AS Nombre           ,      
       T2.LineTotal                          AS Valor            

 FROM      OINV T1
INNER JOIN INV1 T2 ON T2.DocEntry  = T1.DocEntry
 LEFT  JOIN dbo.[@suscripciones] T4 ON ISNULL(T2.u_rubro,'') = T4.Code
LEFT JOIN OCRD T3  ON T1.CardCode   = T3.CardCode
LEFT JOIN OCRG T5 ON T3.GroupCode = T5.GroupCode
WHERE T1.DocDate >= @FechaIni
   AND T1.DocDate <= @FechaFin
 AND T5.GroupName >=@GrupIni 
   AND T5.GroupName <=@GrupFin
   AND T4.Name >=@CodIni 
   AND T4.Name <=@CodFin



union all

SELECT 
       T5.GroupName                          AS Grupo,
       T1.CardCode                           AS Cliente          ,
       T3.CardName                           AS Nombre           ,      
       T2.LineTotal *-1                      AS Valor            

 FROM      ORIN T1
INNER JOIN RIN1 T2 ON T2.DocEntry  = T1.DocEntry
 LEFT  JOIN dbo.[@suscripciones] T4 ON ISNULL(T2.U_Rubro,'') = T4.Code
 LEFT JOIN OCRD T3  ON T1.CardCode   = T3.CardCode
LEFT JOIN OCRG T5 ON T3.GroupCode = T5.GroupCode
WHERE T1.DocDate >= @FechaIni
   AND T1.DocDate <= @FechaFin
   AND T5.GroupName >=@GrupIni 
   AND T5.GroupName <=@GrupFin
   AND T4.Name >=@CodIni 
   AND T4.Name <=@CodFin


) T0 GROUP BY Grupo,Cliente,Nombre HAVING SUM(Valor)<>0


--select * from [@suscripciones] order by name
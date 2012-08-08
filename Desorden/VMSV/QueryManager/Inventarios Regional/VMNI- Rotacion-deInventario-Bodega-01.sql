DECLARE @FechaInicio as datetime,
		@FechaFinal as datetime,
		@InDesign as int,
		@GrupoIni AS VARCHAR(100),
		@GrupoFin AS VARCHAR(100),
		@sBodega as varchar(2),
		@dComparativeDate datetime

set @InDesign = 0

if (@InDesign=1)
	begin
		set @FechaInicio = '01/01/2010 00:00:00'
		set @FechaFinal  = '12/31/2010 00:00:00'
		set @GrupoIni = 'ALBUMES Y TARJETAS'
		SET @GrupoFin = 'VIDEOJUEGOS'
		set @sBodega = '01'
	end
else
	begin
		/* SELECT FROM [DBO].[OPDN] T6 */	
		set @FechaInicio = /* T6.DocDate */'[%0]'
		set @FechaFinal  = /* T6.DocDate */'[%1]'
		/* select from [dbo].[oitb] T7 */
		set @GrupoIni = /* T7.ItmsGrpNam */'[%2]'
		set @GrupoFin = /* T7.ItmsGrpNam */'[%3]'
	end		

set @sBodega			= '01'
set @dComparativeDate	= @FechaInicio - 1


create table #Temp
		(
			Grupo varchar(10),
			Nombre_Grupo varchar(50),
			Codigo varchar(100),
			Description varchar(300),
			Inicial numeric(18,4),
			Compras_Proveedores  numeric(18,4),
			Compras_Afiliadas numeric(18,4),
			Ajustes_Entradas numeric(18,4),
			Ventas	 numeric(18,4),
			Afiliada numeric(18,4),
			Ajustes_Salidas numeric(18,4),
			Saldo numeric(18,4),
			porc_rotacion numeric(18,4),
			rotacion_inv numeric(18,4)
		)

create table #RepositoryTable
		(
			Grupo varchar(10),
			Nombre_Grupo varchar(50),
			Codigo varchar(100),
			Description varchar(300),
			Inicial numeric(18,4),
			Compras_Proveedores  numeric(18,4),
			Compras_Afiliadas numeric(18,4),
			Ajustes_Entradas numeric(18,4),
			Ventas	 numeric(18,4),
			Afiliada numeric(18,4),
			Ajustes_Salidas numeric(18,4),
			Saldo numeric(18,4),
			porc_rotacion numeric(18,4),
			rotacion_inv numeric(18,4)
		)

-- Saldo Inicial
insert into #Temp
SELECT	T1.ItmsGrpCod, T2.ItmsGrpNam,T0.ItemCode, T1.ItemName,  
		CASE WHEN T0.InQty = 0 OR T0.InQty IS NULL THEN T0.OutQty * - 1 ELSE T0.InQty END AS Cantidad_TRX,0,0,0,0,0,0,0,0,0
FROM    prhn.dbo.OITB AS T2 INNER JOIN
        prhn.dbo.OITM AS T1 ON T2.ItmsGrpCod = T1.ItmsGrpCod INNER JOIN
        prhn.dbo.OACT AS T3 ON T2.BalInvntAc = T3.AcctCode INNER JOIN
        prhn.dbo.OINM AS T0 ON T1.ItemCode = T0.ItemCode
WHERE   (T0.DocDate <= @dComparativeDate) and (t0.WareHouse like @sBodega) and 
		(T2.ItmsGrpNam  BETWEEN @GrupoIni AND @GrupoFin)

-- Compras Proveedores - Notas de Créditos por Compras Proveedores
insert into #Temp
	SELECT	T2.	ItmsGrpCod AS Grupo, T3.ItmsGrpNam AS Nombre, T1.ItemCode AS Articulo, T2.ItemName AS Descripcion, 
			0,T1.InQty AS Cantidad,0,0,0,0,0,0,0,0
	FROM	prhn.dbo.OINM AS T1 INNER JOIN
			prhn.dbo.OITM AS T2 ON T1.ItemCode = T2.ItemCode INNER JOIN
			prhn.dbo.OITB AS T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod LEFT OUTER JOIN
			prhn.dbo.OCRD AS T5 ON T1.CardCode = T5.CardCode LEFT OUTER JOIN
			prhn.dbo.[@TIPOSTRANSACCIONES] AS T4 ON STR(T1.TransType) = STR(T4.Code)
	WHERE	(T1.DocDate >= @FechaInicio) AND (T1.DocDate <= @FechaFinal) AND (T1.InQty <> 0) AND (T1.TransType IN (20, 59,18)) AND (T1.Warehouse = '01') AND 
			(T5.GroupCode <> 108) and 
			(T3.ItmsGrpNam  BETWEEN @GrupoIni AND @GrupoFin)
	union all 
	SELECT	T2.ItmsGrpCod AS Grupo, T3.ItmsGrpNam AS Nombre, T1.ItemCode AS Articulo, T2.ItemName AS Descripcion, 
			0,T1.OutQty *-1 AS Cantidad,0,0,0,0,0,0,0,0
	FROM	prhn.dbo.OINM AS T1 INNER JOIN
			prhn.dbo.OITM AS T2 ON T1.ItemCode = T2.ItemCode INNER JOIN
			prhn.dbo.OITB AS T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod LEFT OUTER JOIN
			prhn.dbo.OCRD AS T5 ON T1.CardCode = T5.CardCode LEFT OUTER JOIN
			prhn.dbo.[@TIPOSTRANSACCIONES] AS T4 ON STR(T1.TransType) = STR(T4.Code)
	WHERE	(T1.DocDate >= @FechaInicio) AND (T1.DocDate <= @FechaFinal) AND (T1.OutQty <> 0) AND (T1.TransType IN (19)) AND (T1.Warehouse = '01') AND 
			(T5.GroupCode <> 108) and 
			(T3.ItmsGrpNam  BETWEEN @GrupoIni AND @GrupoFin)

-- Compras a Afiliadas - Notas de Crédito por Compras Afiliadas
insert into #Temp
	SELECT	T2.ItmsGrpCod AS Grupo, T3.ItmsGrpNam AS Nombre, T1.ItemCode AS Articulo, T2.ItemName AS Descripcion, 
			0,0,T1.InQty AS Cantidad,0,0,0,0,0,0,0
	FROM	prhn.dbo.OINM AS T1 INNER JOIN
			prhn.dbo.OITM AS T2 ON T1.ItemCode = T2.ItemCode INNER JOIN
			prhn.dbo.OITB AS T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod LEFT OUTER JOIN
			prhn.dbo.OCRD AS T5 ON T1.CardCode = T5.CardCode LEFT OUTER JOIN
			prhn.dbo.[@TIPOSTRANSACCIONES] AS T4 ON STR(T1.TransType) = STR(T4.Code)
	WHERE  (T1.DocDate >= @FechaInicio) AND (T1.DocDate <= @FechaFinal) AND (T1.InQty <> 0) 
			AND (T1.TransType IN (20, 59,18)) AND (T1.Warehouse = '01') AND 
			(T5.GroupCode = 108) and	
			(T3.ItmsGrpNam  BETWEEN @GrupoIni AND @GrupoFin)
	union all 
	SELECT	T2.ItmsGrpCod AS Grupo, T3.ItmsGrpNam AS Nombre, T1.ItemCode AS Articulo, T2.ItemName AS Descripcion, 
			0,0,T1.OutQty *-1 AS Cantidad,0,0,0,0,0,0,0
	FROM	prhn.dbo.OINM AS T1 INNER JOIN
			prhn.dbo.OITM AS T2 ON T1.ItemCode = T2.ItemCode INNER JOIN
			prhn.dbo.OITB AS T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod LEFT OUTER JOIN
			prhn.dbo.OCRD AS T5 ON T1.CardCode = T5.CardCode LEFT OUTER JOIN
			prhn.dbo.[@TIPOSTRANSACCIONES] AS T4 ON STR(T1.TransType) = STR(T4.Code)
	WHERE	(T1.DocDate >= @FechaInicio) AND (T1.DocDate <= @FechaFinal) AND (T1.OutQty <> 0) AND (T1.TransType IN (19)) 
			AND (T1.Warehouse = '01') AND 
			(T5.GroupCode = 108) and 
			(T3.ItmsGrpNam  BETWEEN @GrupoIni AND @GrupoFin)

--Ajustes Entradas
insert into #Temp
SELECT T2.ItmsGrpCod AS Grupo, T3.ItmsGrpNam AS Nombre, T1.ItemCode AS Articulo, T2.ItemName AS Descripcion, 
		0,0,0,T1.InQty AS Cantidad,0,0,0,0,0,0
FROM   prhn.dbo.OINM AS T1 INNER JOIN
       prhn.dbo.OITM AS T2 ON T1.ItemCode = T2.ItemCode INNER JOIN
       prhn.dbo.OITB AS T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod LEFT OUTER JOIN
       prhn.dbo.OCRD AS T5 ON T1.CardCode = T5.CardCode LEFT OUTER JOIN
       prhn.dbo.[@TIPOSTRANSACCIONES] AS T4 ON STR(T1.TransType) = STR(T4.Code)
WHERE  (T1.DocDate >= @FechaInicio) AND (T1.DocDate <= @FechaFinal) AND (T1.InQty <> 0) AND (T1.TransType IN (67,59)) AND (T1.Warehouse = '01') AND 
	   (T5.GroupCode <> '104' or T5.GroupCode is null) and 
		(T3.ItmsGrpNam  BETWEEN @GrupoIni AND @GrupoFin)

-- Ventas - Devoluciones por Notas de Crédito a Clientes

insert into #Temp
SELECT itmsgrpcod,
		Grupo ,
       Codigo  ,
       Nombre   ,
		0,
		0,
		0,0,
       SUM(Cant_V)	AS NETO,
		0,
		0,0,0,0
  FROM(

SELECT  t3.itmsgrpcod,
	T3.ItmsGrpNam                	AS Grupo   ,
	T0.ItemCode                 	AS Codigo ,
        T2.ItemName                  	AS Nombre  ,
       	T0.Quantity                 	AS Cant_V  ,
     	T0.Price                       	AS Precio_V,
	T2.AvgPrice		 	AS Costo_V       
  FROM      prhn.dbo.INV1 T0
  LEFT JOIN prhn.dbo.OINV T1 ON T0.DocEntry   = T1.DocEntry
  LEFT JOIN prhn.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
  LEFT JOIN prhn.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
  LEFT JOIN prhn.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
  LEFT JOIN prhn.dbo.OCRG T5 ON T4.GroupCode = T5.GroupCode
 WHERE T1.DocDate >= @FechaInicio
   AND T1.DocDate <= @FechaFinal
   AND (T4.GroupCode <>104 and T4.GroupCode is  not null) and 
	(T0.WhsCode like @sBodega)
	and (T3.ItmsGrpNam  BETWEEN @GrupoIni AND @GrupoFin)

UNION ALL

SELECT 	t3.itmsgrpcod,
	T3.ItmsGrpNam               	 AS Grupo,
	T0.ItemCode                 	 AS Codigo,
       	T2.ItemName                	 AS Nombre,
	T0.Quantity*-1                      AS Cant_V  ,
        T0.Price 	                 AS Precio_V,
       	T2.AvgPrice                   AS Costo_V 
        
  FROM     prhn.dbo.RIN1 T0
  LEFT JOIN prhn.dbo.ORIN T1 ON T0.DocEntry   = T1.DocEntry
  LEFT JOIN prhn.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
  LEFT JOIN prhn.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
  LEFT JOIN prhn.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
  LEFT JOIN prhn.dbo.OCRG T5 ON T4.GroupCode = T5.GroupCode
 WHERE T1.DocDate >= @FechaInicio
   AND T1.DocDate <= @FechaFinal and 
	(T0.WhsCode like @sBodega)
   AND (T4.GroupCode <>104 and T4.GroupCode is not null)
	AND  (T3.ItmsGrpNam  BETWEEN @GrupoIni AND @GrupoFin)
) T0 GROUP BY 
	itmsgrpcod,
       Codigo  ,
       Nombre   ,
       Grupo

-- Ventas - Devoluciones por Notas de Crédito CON AFILIADA

insert into #Temp
SELECT itmsgrpcod,
		Grupo ,
       Codigo  ,
       Nombre   ,
		0,
		0,
		0,
		0,0,
       SUM(Cant_V)	AS NETO,
		0,0,0,0
  FROM(

SELECT  t3.itmsgrpcod,
	T3.ItmsGrpNam                	AS Grupo   ,
	T0.ItemCode                 	AS Codigo ,
        T2.ItemName                  	AS Nombre  ,
       	T0.Quantity                 	AS Cant_V  ,
     	T0.Price                       	AS Precio_V,
	T2.AvgPrice		 	AS Costo_V       
  FROM      prhn.dbo.INV1 T0
  LEFT JOIN prhn.dbo.OINV T1 ON T0.DocEntry   = T1.DocEntry
  LEFT JOIN prhn.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
  LEFT JOIN prhn.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
  LEFT JOIN prhn.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
  LEFT JOIN prhn.dbo.OCRG T5 ON T4.GroupCode = T5.GroupCode
 WHERE T1.DocDate >= @FechaInicio
   AND T1.DocDate <= @FechaFinal
   AND T4.GroupCode =104
	AND  (T3.ItmsGrpNam  BETWEEN @GrupoIni AND @GrupoFin)

UNION ALL

SELECT 	t3.itmsgrpcod,
	T3.ItmsGrpNam               	 AS Grupo,
	T0.ItemCode                 	 AS Codigo,
       	T2.ItemName                	 AS Nombre,
	T0.Quantity*-1                      AS Cant_V  ,
        T0.Price 	                 AS Precio_V,
       	T2.AvgPrice                   AS Costo_V 
        
  FROM      prhn.dbo.RIN1 T0
  LEFT JOIN prhn.dbo.ORIN T1 ON T0.DocEntry   = T1.DocEntry
  LEFT JOIN prhn.dbo.OITM T2 ON T0.ItemCode   = T2.ItemCode
  LEFT JOIN prhn.dbo.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
  LEFT JOIN prhn.dbo.OCRD T4 ON T1.CardCode   = T4.CardCode
  LEFT JOIN prhn.dbo.OCRG T5 ON T4.GroupCode = T5.GroupCode
 WHERE T1.DocDate >= @FechaInicio
   AND T1.DocDate <= @FechaFinal
   AND T4.GroupCode = 104
	AND  (T3.ItmsGrpNam  BETWEEN @GrupoIni AND @GrupoFin)
) T0 GROUP BY 
	itmsgrpcod,
       Codigo  ,
       Nombre   ,
       Grupo

--Ajustes Salidas
insert into #Temp
SELECT T2.ItmsGrpCod AS Grupo, T3.ItmsGrpNam AS Nombre, T1.ItemCode AS Articulo, T2.ItemName AS Descripcion, 
		0,0,0,0,0,0,T1.OutQty AS Cantidad,0,0,0
FROM   prhn.dbo.OINM AS T1 INNER JOIN
       prhn.dbo.OITM AS T2 ON T1.ItemCode = T2.ItemCode INNER JOIN
       prhn.dbo.OITB AS T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod LEFT OUTER JOIN
       prhn.dbo.OCRD AS T5 ON T1.CardCode = T5.CardCode LEFT OUTER JOIN
       prhn.dbo.[@TIPOSTRANSACCIONES] AS T4 ON STR(T1.TransType) = STR(T4.Code)
WHERE  (T1.DocDate >= @FechaInicio) AND (T1.DocDate <= @FechaFinal) AND (T1.OutQty <> 0) AND (T1.TransType IN (60,67)) AND (T1.Warehouse = '01') AND 
       (T5.GroupCode <> '104' or T5.GroupCode is null) 
		AND  T3.ItmsGrpNam  BETWEEN @GrupoIni AND @GrupoFin

-- Actualizo el saldo del inventario

update #Temp set saldo = (inicial+Compras_Proveedores+Compras_Afiliadas+Ajustes_Entradas-Ventas-Afiliada-Ajustes_Salidas)


insert into #RepositoryTable																
select	grupo,nombre_Grupo,Codigo,description,sum(inicial) as 'Saldo Inicial',
		sum(compras_Proveedores) as 'Compras Proveedores',
		sum(Compras_Afiliadas) as 'Compras a Afiliadas',
		sum(Ajustes_Entradas) as 'Ajustes por Entrada',
		sum(ventas) as 'Ventas a Clientes',
		sum(afiliada) as 'Venta a Afiliada',
		sum(Ajustes_Salidas) as 'Ajustes por Salidas',
		sum(saldo) as 'Saldo Final',
		sum(porc_rotacion) as '(%) Rotacion]',
		sum(rotacion_inv) as 'Rotacion Inventario'
from #Temp
group by grupo,nombre_grupo,codigo,description
having ( sum(inicial)<>0 or sum(Compras_Proveedores)<>0 or sum(Compras_Afiliadas)<>0 or sum(Ajustes_Entradas)<>0 or sum(Ventas)<>0 or sum(Afiliada)<>0 or sum(Ajustes_Salidas)<>0 or sum(saldo) <>0)
/*having ( sum(inicial)=0 and sum(saldo) =0)*/
order by grupo,Codigo

-- Actualizo rotación de inventario

update #RepositoryTable set porc_rotacion = case Compras_Proveedores 
												when 0 then 0 
												else 1 - (ventas / Compras_Proveedores) end 

update #RepositoryTable set rotacion_inv = case (Compras_Proveedores + inicial)
												when  0 then 0
												else 1 -(saldo / (Compras_Proveedores + Inicial)) end

--select * from #RepositoryTable where codigo = '7509656210083'

select	grupo as [Grupo],nombre_Grupo as [Descripción Grupo],Codigo as [Código],description as [Descripción Artículo],(inicial) as 'Saldo Inicial',
		(compras_Proveedores) as 'Compras Proveedores',
		(Compras_Afiliadas) as 'Compras a Afiliadas',
		(Ajustes_Entradas) as 'Ajustes por Entrada',
		(ventas) as 'Ventas a Clientes',
		(afiliada) as 'Venta a Afiliada',
		(Ajustes_Salidas) as 'Ajustes por Salidas',
		(saldo) as 'Saldo Final',
		/*(porc_rotacion) as '(%) Rotacion]',*/
		(rotacion_inv) as '(%) Rotacion'
from #RepositoryTable


drop table #Temp
drop table #RepositoryTable


--7509656210083
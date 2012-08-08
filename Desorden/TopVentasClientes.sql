/* SIG Unidades */

DECLARE @dFechaIni as datetime,
		@dFechaFin as datetime,
		@sClienteIni as varchar(100),
		@sClienteFin as varchar(100),
		@sGrupoIni	as varchar(100),
		@sGrupoFin as varchar(100),
		@iInDesign as int




set @iInDesign = 1

if (@iInDesign = 1)
	begin
		set @dFechaIni	= '01/01/2011 00:00:00'
		set @dFechaFin	= '01/31/2011 00:00:00'
		set @sClienteIni = ''---'CORPORACION DE TIENDAS INTERNACIONALES, S.A. DE C.V.'
		set @sClienteFin =''--- 'CORPORACION DE TIENDAS INTERNACIONALES, S.A. DE C.V.'
		set @sGrupoIni	= 'ALBUMES Y TARJETAS'
		set @sGrupoFin	= 'VIDEOJUEGOS'
	end
else
	begin
		/* SELECT FROM VMSV.DBO.OINV T0 */
		SET @dFechaIni = /* T0.DocDate */'[%0]'
        /* SELECT FROM VMSV.DBO.OINV T1 */
		SET @dFechaFin = /* T1.DocDate */'[%1]'
        /* SELECT FROM VMSV.DBO.OCRD T2 */
		set @sClienteIni = /* T2.CardName */'[%2]'
		/* SELECT FROM vmsv.dbo.OITB T4 */
		set @sGrupoIni = /* T4.ItmsGrpNam */ '[%3]'
		SET @sGrupoFin = /* T4.ItmsGrpNam */ '[%4]'
	end

if (@sClienteIni = '' or @sClienteIni is null)
	begin
		set @sClienteIni = (select top 1 CardName from ocrd order by CardName asc)
		set @sClienteFin = (select top 1 CardName from ocrd order by CardName desc)
	end
else
	begin
		set @sClienteFin = @sClienteIni
	end


SELECT Nombrecliente as [Nombre del Cliente],NOMBRE, SUM(cantidad) AS Cantidad,sum(valor) as [Venta Neta]
FROM
	(
		SELECT	t1.CardCode			as Cliente,
				T1.CardName			as NombreCliente,
				T2.ItmsGrpCod		AS GRUPO,
				T3.ItmsGrpNam		AS NOMBRE,
   				SUM(T0.Quantity)  	AS cantidad,
				sum(T0.LineTotal)	as Valor
		FROM    VMSV.DBO.INV1 T0
				INNER JOIN VMSV.DBO.OINV T1 ON T0.DocEntry   = T1.DocEntry
				LEFT JOIN VMSV.DBO.OITM T2 ON T0.ItemCode   = T2.ItemCode
				LEFT JOIN VMSV.DBO.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
				INNER JOIN VMSV.DBO.OCRD T4 ON T1.CardCode   = T4.CardCode
		WHERE	T1.DocDate BETWEEN @dFechaIni AND @dFechaFin 
				AND T4.GroupCode<>104
		GROUP BY t1.CardCode,t1.CardName,T2.ItmsGrpCod, T3.ItmsGrpNam

	UNION ALL

	SELECT  t1.CardCode as Cliente,
			t1.CardName as NombreCliente,
			T2.ItmsGrpCod		AS GRUPO,
			T3.ItmsGrpNam		AS NOMBRE,
   			SUM(T0.Quantity) *-1 	AS cantidad,
			sum(t0.LineTotal) * -1 as valor
	FROM    VMSV.DBO.RIN1 T0
			INNER JOIN VMSV.DBO.ORIN T1 ON T0.DocEntry   = T1.DocEntry
			LEFT JOIN VMSV.DBO.OITM T2 ON T0.ItemCode   = T2.ItemCode
			LEFT JOIN VMSV.DBO.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
			INNER JOIN VMSV.DBO.OCRD T4 ON T1.CardCode   = T4.CardCode
	WHERE	T1.DocDate BETWEEN @dFechaIni AND @dFechaFin AND   T4.GroupCode<>104
	GROUP	BY t1.Cardcode,t1.CardName,T2.ItmsGrpCod,T3.ItmsGrpNam

	union all 

	SELECT  t1.CardCode,
			t1.CardName,
			'100'			AS GRUPO,
			'DVD DISNEY'		AS NOMBRE,
			0,
   			(T0.LineTotal) 	AS VENTA
	FROM    VMSV.DBO.INV1 T0
			INNER JOIN VMSV.DBO.OINV T1 ON T0.DocEntry   = T1.DocEntry
			LEFT JOIN VMSV.DBO.OITM T2 ON T0.ItemCode   = T2.ItemCode
			LEFT JOIN VMSV.DBO.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
			INNER JOIN VMSV.DBO.OCRD T4 ON T1.CardCode   = T4.CardCode
	WHERE	T1.DocDate BETWEEN @dFechaIni AND @dFechaFin 
			AND T4.GroupCode<>104
			AND T1.DocType    = 'S'
			AND T1.U_FacSerie LIKE 'ND'
	
	UNION ALL

	/*LAS NC EN VALORES Q SON SOLO DE CLIENTES DE ARTICULOS*/

	SELECT  t1.CardCode,
			t1.CardName,
			'100'			AS GRUPO,
			'DVD DISNEY'		AS NOMBRE,
			0,
   			(T0.LineTotal)*-1 	AS VENTA      
	FROM    VMSV.DBO.RIN1 T0
			INNER JOIN VMSV.DBO.ORIN T1 ON T0.DocEntry   = T1.DocEntry
			LEFT JOIN VMSV.DBO.OITM T2 ON T0.ItemCode   = T2.ItemCode
			LEFT JOIN VMSV.DBO.OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
			INNER JOIN VMSV.DBO.OCRD T4 ON T1.CardCode   = T4.CardCode
	WHERE	T1.DocDate BETWEEN @dFechaIni AND @dFechaFin AND 
			T4.GroupCode<>104
			AND T1.DocType    = 'S'
	) T0 
GROUP	BY NombreCliente,NOMBRE 
HAVING	NombreCliente >= @sClienteIni and NombreCliente <= @sClienteFin and 
		Nombre >= @sGrupoIni and nombre <=@sGrupoFin and nombre is not null
order by Cantidad desc


--select * from oinv
--select top 1 CardName from ocrd order by CardName asc
--SELECT * FROM cvsv.dbo.OITB T4
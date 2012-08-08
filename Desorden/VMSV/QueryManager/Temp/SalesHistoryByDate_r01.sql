set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go





ALTER PROCEDURE [dbo].[SalesHistoryByDate_r01]
			@dFechaIni AS DATETIME,
			@dFechaFin as datetime,
			@sGroupIni as varchar(100),
			@sGroupFin as varchar(100)

AS

		SELECT	t1.CardCode,t1.CardName,T3.ItmsGrpNam,T0.ItemCode ,T2.ItemName,isnull(T0.Quantity,0),isnull(T0.Price,0)                       
		FROM    INV1 T0 LEFT JOIN OINV T1 ON T0.DocEntry   = T1.DocEntry
				LEFT JOIN OITM T2 ON T0.ItemCode   = T2.ItemCode
				LEFT JOIN OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
				LEFT JOIN OCRD T4 ON T1.CardCode   = T4.CardCode
				LEFT JOIN OCRG T5 ON T4.GroupCode = T5.GroupCode
		WHERE	(T1.DocDate >= @dFechaIni
				AND T1.DocDate <= @dFechaFin)
				AND (T4.GroupCode <>104)
				and (t0.ItemCode is not null)
				and (t3.itmsGrpNam>=@sGroupIni)
				and (t3.itmsGrpNam<=@sGroupFin)

		UNION ALL

		SELECT	t1.CardCode,t1.CardName,T3.ItmsGrpNam,T0.ItemCode,T2.ItemName,isnull(T0.Quantity*-1,0) ,isnull(T0.Price * -1,0)
		FROM    RIN1 T0 LEFT JOIN ORIN T1 ON T0.DocEntry   = T1.DocEntry
				LEFT JOIN OITM T2 ON T0.ItemCode   = T2.ItemCode
				LEFT JOIN OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
				LEFT JOIN OCRD T4 ON T1.CardCode   = T4.CardCode
				LEFT JOIN OCRG T5 ON T4.GroupCode = T5.GroupCode
		WHERE	(T1.DocDate >= @dFechaIni)
				AND (T1.DocDate <= @dFechaFin)
				AND (T4.GroupCode <>104)	
				and (t0.ItemCode is not null)
				and (t3.itmsGrpNam>=@sGroupIni)
				and (t3.itmsGrpNam<=@sGroupFin)

--select * from oitb
--select * from oinv
--select * from orin
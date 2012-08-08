set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER procedure [dbo].[SalesHisssstoryByDate_r01] (@dFechaIni as datetime,
												@dFechaFin as datetime,
												@sCodIni as varchar(100),
												@sCodFin as varchar(100))
as 

declare @iMonthFirst int,
		@iMonthLast int,
		@iFlag int,
		@nUtilidad numeric(18,4)

set @iMonthFirst	= month(@dFechaIni)
set @iMonthLast		= month(@dFechaFin)
set @iFlag			= 1
set @dFechaIni		= convert(char(10),@dFechaIni,121)+' 00:00:00'
set @dFechaFin		= convert(char(10),DateAdd(ms,-2,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'

while (@iMonthFirst <=@iMonthLast)
	begin
		if (@iMonthFirst=1)
			begin
				insert into #SalesMonth (GroupName,ItemId,ProductName,QJanuary,VJanuary)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin
			end
		if (@iMonthFirst=2)
			begin
				insert into #SalesMonth (GroupName,ItemId,ProductName,QFebruary,VFebruary)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin
			end
		if (@iMonthFirst=3)
			begin
				insert into #SalesMonth (GroupName,ItemId,ProductName,QMarch,VMarch)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin
			end
		if (@iMonthFirst=4)
			begin
				insert into #SalesMonth (GroupName,ItemId,ProductName,QApril,VApril)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin
			end
		if (@iMonthFirst=5)
			begin
				insert into #SalesMonth (GroupName,ItemId,ProductName,QMay,VMay)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin
			end
		if (@iMonthFirst=6)
			begin
				insert into #SalesMonth (GroupName,ItemId,ProductName,QJune,VJune)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin
			end
		if (@iMonthFirst=7)
			begin
				insert into #SalesMonth (GroupName,ItemId,ProductName,QJuly,VJuly)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin
			end
		if (@iMonthFirst=8)
			begin
				insert into #SalesMonth (GroupName,ItemId,ProductName,QAugust,VAugust)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin
			end
		if (@iMonthFirst=9)
			begin
				insert into #SalesMonth (GroupName,ItemId,ProductName,QSeptember,VSeptember)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin
			end
		if (@iMonthFirst=10)
			begin
				insert into #SalesMonth (GroupName,ItemId,ProductName,QOctober,VOctober)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin
			end
		if (@iMonthFirst=11)
			begin
				insert into #SalesMonth (GroupName,ItemId,ProductName,QNovember,VNovember)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin			
			end
		if (@iMonthFirst=12)
			begin
				insert into #SalesMonth (GroupName,ItemId,ProductName,QDecember,VDecember)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin		
			end
		set @dFechaIni = convert(char(10),DateAdd(ms,-1,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'
		set @dFechaFin = convert(char(10),DateAdd(ms,-2,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'
		set @iMonthFirst = @iMonthFirst + 1
	end


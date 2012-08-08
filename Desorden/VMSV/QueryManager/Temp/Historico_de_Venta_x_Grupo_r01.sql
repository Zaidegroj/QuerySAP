DECLARE @dFechaIni	AS DATETIME,
		@dFechaFin	AS DATETIME,
		@sGroupIni		AS VARCHAR(100),
		@sGroupFin		AS VARCHAR(100),
		@InDesign as int,
		@nTc as int

set @InDesign = 1

if (@InDesign = 1) 
	begin
		set @dFechaIni = '10/01/2011 00:00:00'
		set @dFechaFin = '10/31/2011 00:00:00'
		set @sGroupIni ='ALBUMES Y TARJETAS'
		set @sGroupFin = 'VIDEOJUEGOS'
		set @nTc = 1
	end
else
	begin 
		/* SELECT FROM VMSV.DBO.OINV T0 */
		SET @dFechaIni= /* T0.DocDate */ '[%0]'
		/* SELECT FROM VMSV.DBO.OINV T0 */
		SET @dFechaFin= /* T0.DocDate */ '[%1]'
		/* SELECT FROM VMSV.DBO.OITB T1 */
		SET @sGroupIni= /* T1.ItmsGrpNam  */ '[%3]'
		/* SELECT FROM VMSV.DBO.OITB T1 */
		SET @sGroupFin = /* T1.ItmsGrpNam  */ '[%4]'
	end

--Tables Creation

create table #GlobalSales
		(
			GroupName varchar(100),
			ItemId varchar(100),
			ProductName varchar(150),
			Quantity numeric(14,2),
			Price numeric(14,2)
		)

create table #SalesMonth
		(
			CardCode varchar(50),
			CardName varchar(150),
			GroupName varchar(100),
			ItemId varchar(100),
			ProductName varchar(150),
			QJanuary numeric(14,2) default 0,
			VJanuary numeric(14,2) default 0,
			QFebruary numeric(14,2) default 0,
			VFebruary numeric(14,2) default 0,
			QMarch numeric(14,2) default 0,
			VMarch numeric(14,2) default 0,
			QApril numeric(14,2) default 0,
			VApril numeric(14,2) default 0,
			QMay numeric(14,2) default 0,
			VMay numeric(14,2) default 0,
			QJune numeric(14,2) default 0,
			VJune numeric(14,2) default 0,
			QJuly numeric(14,2) default 0,
			VJuly numeric(14,2) default 0,
			QAugust numeric(14,2) default 0,
			VAugust numeric(14,2) default 0,
			QSeptember numeric(14,2) default 0,
			VSeptember numeric(14,2) default 0,
			QOctober numeric(14,2) default 0,
			VOctober numeric(14,2) default 0,
			QNovember numeric(14,2) default 0,
			VNovember numeric(14,2) default 0,
			QDecember numeric(14,2) default 0,
			VDecember numeric(14,2) default 0
		)



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
		print @dFechaIni
		print @dFechaFin
		if (@iMonthFirst=1)
			begin
				insert into #SalesMonth (CardCode,CardName,GroupName,ItemId,ProductName,QJanuary,VJanuary)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin,@sGroupIni,@sGroupFin
			end
		if (@iMonthFirst=2)
			begin
				insert into #SalesMonth (CardCode,CardName,GroupName,ItemId,ProductName,QFebruary,VFebruary)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin,@sGroupIni,@sGroupFin
			end
		if (@iMonthFirst=3)
			begin
				insert into #SalesMonth (CardCode,CardName,GroupName,ItemId,ProductName,QMarch,VMarch)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin,@sGroupIni,@sGroupFin
			end
		if (@iMonthFirst=4)
			begin
				insert into #SalesMonth (CardCode,CardName,GroupName,ItemId,ProductName,QApril,VApril)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin,@sGroupIni,@sGroupFin
			end
		if (@iMonthFirst=5)
			begin
				insert into #SalesMonth (CardCode,CardName,GroupName,ItemId,ProductName,QMay,VMay)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin,@sGroupIni,@sGroupFin
			end
		if (@iMonthFirst=6)
			begin
				insert into #SalesMonth (CardCode,CardName,GroupName,ItemId,ProductName,QJune,VJune)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin,@sGroupIni,@sGroupFin
			end
		if (@iMonthFirst=7)
			begin
				insert into #SalesMonth (CardCode,CardName,GroupName,ItemId,ProductName,QJuly,VJuly)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin,@sGroupIni,@sGroupFin
			end
		if (@iMonthFirst=8)
			begin
				insert into #SalesMonth (CardCode,CardName,GroupName,ItemId,ProductName,QAugust,VAugust)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin,@sGroupIni,@sGroupFin
			end
		if (@iMonthFirst=9)
			begin
				insert into #SalesMonth (CardCode,CardName,GroupName,ItemId,ProductName,QSeptember,VSeptember)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin,@sGroupIni,@sGroupFin
			end
		if (@iMonthFirst=10)
			begin
				insert into #SalesMonth (CardCode,CardName,GroupName,ItemId,ProductName,QOctober,VOctober)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin,@sGroupIni,@sGroupFin
			end
		if (@iMonthFirst=11)
			begin
				insert into #SalesMonth (CardCode,CardName,GroupName,ItemId,ProductName,QNovember,VNovember)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin,@sGroupIni,@sGroupFin			
			end
		if (@iMonthFirst=12)
			begin
				insert into #SalesMonth (CardCode,CardName,GroupName,ItemId,ProductName,QDecember,VDecember)
						exec SalesHistoryByDate_r01 @dFechaIni,@dFechaFin,@sGroupIni,@sGroupFin		
			end
		set @dFechaIni = convert(char(10),DateAdd(ms,-1,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'
		set @dFechaFin = convert(char(10),DateAdd(ms,-2,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'
		set @iMonthFirst = @iMonthFirst + 1
	end


select GroupName,ItemId,ProductName,sum(QJanuary+QFebruary+QMarch+QApril+QMay+QJune+QJuly+QAugust+QSeptember+QOctober+QNovember+QDecember) as [Unidades Venta Anual],
									sum(VJanuary+VFebruary+VMarch+VApril+VMay+VJune+VJuly+VAugust+VSeptember+VOctober+VNovember+VDecember) as [Venta Anual],
									sum(QJanuary) as [Total Unid. Enero],sum(VJanuary) as [Total Venta Enero],
									sum(QFebruary) as [Total Unid. Febrero],sum(VFebruary) as [Total Venta Febrero],
									sum(QMarch) as [Total Unid. Marzo],sum(VMarch) as [Total Venta Marzo],
									sum(QApril) as [Total Unid. Abril],sum(VApril) as [Total Venta Abril],
									sum(QMay) as [Total Unid. Mayo],sum(VMay) as [Total Venta Mayo],
									sum(QJune) as [Total Unid. Junio],sum(VJune) as [Total Venta Junio],
									sum(QJuly) as [Total Unid. Julio],sum(VJuly) as [Total Venta July],
									sum(QAugust) as [Total Unid. Agosto],sum(VAugust) as [Total Venta Agosto],
									sum(QSeptember) as [Total Unid. Septiembre],sum(VSeptember) as [Total Venta Septiembre],
									sum(QOctober) as [Total Unid. Octubre],sum(VOctober) as [Total Venta Octubre],
									sum(QNovember) as [Total Unid. Noviembre],sum(VNovember) as [Total Venta Noviembre],
									sum(QDecember) as [Total Unid. Diciembre],sum(VDecember) as [Total Venta Diciembre]
from #SalesMonth
group by GroupName,ItemId,ProductName

drop table #GlobalSales
drop table #SalesMonth

--select * from ocrg
--select * from ocrd where GroupCode = 104
--select * from inv1 where price = 9.67
--select * from oitb
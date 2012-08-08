
declare @nSaldo numeric (18,4),
		@dFechaIni datetime,
		@dFechaFin datetime,
		@cCuenta varchar(20),
		@cCuentaProceso varchar(20),
		@sDescripcion varchar(100),
		@dUltimoDiaMes		as datetime,
		@dFechaIniReal as datetime,
		@nMes		as int,
		@nSemanaInicial as int,
		@nSemanaFinal as int,
		@iContador as int,
		@WeekNum INT,
        @YearNum char(4)


set @nMes = 5 
set @dFechaIni = convert(datetime,convert(char,@nMes)+'01/'+'/2011')
set @dFechaIniReal = @dFechaIni
set @nSemanaInicial = datepart(wk,@dFechaIni)
set @dUltimoDiaMes = dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,@dFechaIni)+1, 0))
set @nSemanaFinal  = datepart(wk,@dUltimoDiaMes)
set @WeekNum = DATEPART(WK, @dFechaIni)
set @YearNum = CAST(DATEPART(YY, @dFechaIni) AS CHAR(4))
set @dFechaIni = (SELECT DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @YearNum) + (@WeekNum-1), 6) AS StartOfWeek)
set @dFechaFin = (SELECT DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @YearNum) + (@WeekNum-1), 5) AS EndOfWeek)

set @iContador		= 0

create table #FlujoEfectivoTemp
			(
				Cuenta		varchar(20),
				Concepto	varchar(100),
				Semana1		numeric(18,2),
				Semana2		numeric(18,2),
				Semana3		numeric(18,2),
				Semana4		numeric(18,2),
				Semana5		numeric(18,2)
			 )
while (@nSemanaInicial <=@nSemanaFinal)
begin
	set @iContador	=  @iContador + 1
	if (month(@dFechaIni)!=month(@dFechaIniReal))
		begin
			set @dFechaIni = @dFechaIniReal
		end
	if (month(@dFechaFin)!=month(@dUltimoDiaMes))
		begin
			set @dFechaFin = @dUltimoDiaMes
		end
	
		if (@iContador = 1)
		begin
			insert into #FlujoEfectivoTemp
					(Concepto,semana1)
					select t2.U_descripcion,isnull(case	substring(t2.u_cuenta,1,1)
							when '1' then isnull(sum(T0.Debit),0)-isnull(sum(T0.Credit),0)
							when '2' then isnull(SUM(T0.Credit),0)-isnull(SUM(T0.Debit),0) 
							when '3' then isnull(SUM(T0.Credit),0)-isnull(SUM(T0.Debit),0)
							when '4' then isnull(SUM(T0.Credit),0)-isnull(SUM(T0.Debit),0)
							when '5' then isnull(sum(T0.Debit),0)-isnull(sum(T0.Credit),0)
							when '6' then isnull(sum(T0.Debit),0)-isnull(sum(T0.Credit),0)
							end ,0)
					FROM	DBO.JDT1 T0  INNER JOIN DBO.OACT T1 ON T0.Account = T1.AcctCode	
							inner join [@FlujoEfectivo] T2 on T1.FormatCode = T2.U_Cuenta
					WHERE	T0.[RefDate] >=@dFechaIni AND T0.[RefDate] <=@dFechaFin 
					group by t2.u_Descripcion,t2.u_cuenta		---
		end
--
		if (@iContador = 2)
		begin
			insert into #FlujoEfectivoTemp
					(Concepto,semana2)
					select t2.U_descripcion,isnull(case	substring(t2.u_cuenta,1,1)
							when '1' then isnull(sum(T0.Debit),0)-isnull(sum(T0.Credit),0)
							when '2' then isnull(SUM(T0.Credit),0)-isnull(SUM(T0.Debit),0) 
							when '3' then isnull(SUM(T0.Credit),0)-isnull(SUM(T0.Debit),0)
							when '4' then isnull(SUM(T0.Credit),0)-isnull(SUM(T0.Debit),0)
							when '5' then isnull(sum(T0.Debit),0)-isnull(sum(T0.Credit),0)
							when '6' then isnull(sum(T0.Debit),0)-isnull(sum(T0.Credit),0)
							end ,0)
					FROM	DBO.JDT1 T0  INNER JOIN DBO.OACT T1 ON T0.Account = T1.AcctCode	
							inner join [@FlujoEfectivo] T2 on T1.FormatCode = T2.U_Cuenta
					WHERE	T0.[RefDate] >=@dFechaIni AND T0.[RefDate] <=@dFechaFin 
					group by t2.u_Descripcion,t2.u_cuenta		---
		end
--
		if (@iContador = 3)
		begin
			insert into #FlujoEfectivoTemp
					(Concepto,semana3)
					select t2.U_descripcion,isnull(case	substring(t2.u_cuenta,1,1)
							when '1' then isnull(sum(T0.Debit),0)-isnull(sum(T0.Credit),0)
							when '2' then isnull(SUM(T0.Credit),0)-isnull(SUM(T0.Debit),0) 
							when '3' then isnull(SUM(T0.Credit),0)-isnull(SUM(T0.Debit),0)
							when '4' then isnull(SUM(T0.Credit),0)-isnull(SUM(T0.Debit),0)
							when '5' then isnull(sum(T0.Debit),0)-isnull(sum(T0.Credit),0)
							when '6' then isnull(sum(T0.Debit),0)-isnull(sum(T0.Credit),0)
							end ,0)
					FROM	DBO.JDT1 T0  INNER JOIN DBO.OACT T1 ON T0.Account = T1.AcctCode	
							inner join [@FlujoEfectivo] T2 on T1.FormatCode = T2.U_Cuenta
					WHERE	T0.[RefDate] >=@dFechaIni AND T0.[RefDate] <=@dFechaFin 
					group by t2.u_Descripcion,t2.u_cuenta		---
		end
---
		if (@iContador = 4)
		begin
			insert into #FlujoEfectivoTemp
					(Concepto,semana4)
					select t2.U_descripcion,isnull(case	substring(t2.u_cuenta,1,1)
							when '1' then isnull(sum(T0.Debit),0)-isnull(sum(T0.Credit),0)
							when '2' then isnull(SUM(T0.Credit),0)-isnull(SUM(T0.Debit),0) 
							when '3' then isnull(SUM(T0.Credit),0)-isnull(SUM(T0.Debit),0)
							when '4' then isnull(SUM(T0.Credit),0)-isnull(SUM(T0.Debit),0)
							when '5' then isnull(sum(T0.Debit),0)-isnull(sum(T0.Credit),0)
							when '6' then isnull(sum(T0.Debit),0)-isnull(sum(T0.Credit),0)
							end ,0)
					FROM	DBO.JDT1 T0  INNER JOIN DBO.OACT T1 ON T0.Account = T1.AcctCode	
							inner join [@FlujoEfectivo] T2 on T1.FormatCode = T2.U_Cuenta
					WHERE	T0.[RefDate] >=@dFechaIni AND T0.[RefDate] <=@dFechaFin 
					group by t2.u_Descripcion,t2.u_cuenta		---
		end
		if (@iContador = 5)
		begin
			insert into #FlujoEfectivoTemp
					(Concepto,semana5)
					select t2.U_descripcion,isnull(case	substring(t2.u_cuenta,1,1)
							when '1' then isnull(sum(T0.Debit),0)-isnull(sum(T0.Credit),0)
							when '2' then isnull(SUM(T0.Credit),0)-isnull(SUM(T0.Debit),0) 
							when '3' then isnull(SUM(T0.Credit),0)-isnull(SUM(T0.Debit),0)
							when '4' then isnull(SUM(T0.Credit),0)-isnull(SUM(T0.Debit),0)
							when '5' then isnull(sum(T0.Debit),0)-isnull(sum(T0.Credit),0)
							when '6' then isnull(sum(T0.Debit),0)-isnull(sum(T0.Credit),0)
							end ,0)
					FROM	DBO.JDT1 T0  INNER JOIN DBO.OACT T1 ON T0.Account = T1.AcctCode	
							inner join [@FlujoEfectivo] T2 on T1.FormatCode = T2.U_Cuenta
					WHERE	T0.[RefDate] >=@dFechaIni AND T0.[RefDate] <=@dFechaFin 
					group by t2.u_Descripcion,t2.u_cuenta		---
		end
		--
		print @dFechaIni
		print @dFechaFin
		--

		--- Se crea la nueva semana
		set @dFechaIni = @dFechaFin + 1
		set @WeekNum = DATEPART(WK, @dFechaIni)
		set @YearNum = CAST(DATEPART(YY, @dFechaIni) AS CHAR(4))
		set @dFechaIni = (SELECT DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @YearNum) + (@WeekNum-1), 6) AS StartOfWeek)
		set @dFechaFin = (SELECT DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @YearNum) + (@WeekNum-1), 5) AS EndOfWeek)
		set @nSemanaInicial = @nSemanaInicial + 1
end

		--
		---print @dFechaIni
		---print @dFechaFin
		--


select Concepto,
		sum(semana1) as ' Semana1 ',
		sum(semana2) as semana2,
		sum(semana3) as semana3,
		sum(semana4) as semana4,
		sum(semana5) as semana5
from #FlujoEfectivoTemp 
group by concepto

--close tcFlujoEfectivo
drop table #FlujoEfectivoTemp


/*
SELECT DATEADD(wk, DATEDIFF(wk, 6, DueDate), 6), SUM(Credit)
FROM ajd1
GROUP BY DATEADD(wk, DATEDIFF(wk, 6, DueDate), 6)
ORDER BY DATEADD(wk, DATEDIFF(wk, 6, DueDate), 6)
*/
---select * from ajd1
---select FormatCode,acctName from oact where AcctName like '%isss%' or acctname like '%social%'

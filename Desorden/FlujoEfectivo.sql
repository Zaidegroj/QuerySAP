declare @nSaldo numeric (18,4),
		@dFechaIni datetime,
		@dFechaFin datetime,
		@cCuenta varchar(20),
		@cCuentaProceso varchar(20),
		@sDescripcion varchar(100),
		@nNivel		as int,
		@nSemanaInicial as int,
		@nSemanaFinal as int,
		@iContador as int

		
set @dFechaIni		= '05/01/2011 00:00:00'
set @dFechaFin		= '05/31/2011 00:00:00'
set @cCuentaProceso = '5'
set @nNivel			= 5

set @nSemanaInicial = datepart(week,@dFechaIni)
set @nSemanaFinal   = datepart(week,@dFechaFin)
set @iContador		= 0

create table #FlujoEfectivoTemp
			(
				Cuenta		varchar(20),
				Concepto	varchar(100),
				Semana1		numeric(18,2),
				Semana2		numeric(18,2),
				Semana3		numeric(18,2),
				Semana4		numeric(18,2)
			 )

declare tcFlujoEfectivo cursor scroll for
						select u_Cuenta,u_Descripcion from [@FlujoEfectivo]

while (@nSemanaInicial <=@nSemanaFinal)
begin
	set @iContador	=  @iContador + 1
	open tcFlujoEfectivo
	Fetch Next from tcFlujoEfectivo into @cCuenta,@sDescripcion
	while (@@FETCH_STATUS=0) 
		begin
			set @cCuentaProceso = @cCuenta;
			exec ObtenerSaldoCuenta @dFechaIni,@dFechaFin,@cCuentaProceso,@nSaldo output 
			insert into #FlujoEfectivoTemp (cuenta,concepto,saldo1) values (@cCuenta,@sDescripcion,@nSaldo)
		--
			Fetch Next From tcFlujoEfectivo into @cCuenta,@sDescripcion
		end
	set @nSemanaInicial = @nSemanaInicial + 1
end


select Concepto,sum(Saldo1) as saldo1 
from #FlujoEfectivoTemp 
group by concepto

close tcFlujoEfectivo
deallocate tcFlujoEfectivo
drop table #FlujoEfectivoTemp


/*
SELECT DATEADD(wk, DATEDIFF(wk, 6, DueDate), 6), SUM(Credit)
FROM ajd1
GROUP BY DATEADD(wk, DATEDIFF(wk, 6, DueDate), 6)
ORDER BY DATEADD(wk, DATEDIFF(wk, 6, DueDate), 6)
*/
---select * from ajd1


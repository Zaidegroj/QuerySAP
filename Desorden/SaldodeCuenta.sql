declare @nSaldo numeric (18,4),
		@dFechaIni datetime,
		@dFechaFin datetime,
		@cCuentaProceso varchar(20),
		@nNivel		as int

		
set @dFechaIni		= '01/01/2011 00:00:00'
set @dFechaFin		= '05/31/2011 00:00:00'
set @cCuentaProceso = '5'
set @nNivel			= 5

--110301001000101 - Clientes Locales

exec ObtenerSaldoCuenta @dFechaIni,@dFechaFin,@cCuentaProceso,@nSaldo output 


--create table #BalanceTemp
--(
--	Cuenta		varchar(20),
--	Descripcion	varchar(100),
--	CuentaPadre	varchar(20),
--	Nivel		int,
----	Enero		numeric(18,4),
----	Febrero		numeric(18,4),
----	Marzo		numeric(18,4),
----	Abril		numeric(18,4),
----	Mayo		numeric(18,4),
----	Junio		numeric(18,4),
----	Julio		numeric(18,4),
----	Agosto		numeric(18,4),
----	Septiembre	numeric(18,4),
----	Octubre		numeric(18,4),
----	Noviembre	numeric(18,4),
----	Diciembre	numeric(18,4),
--	Total		numeric(18,4)
--)


-- Obtengo el catálogo general y lo deposito en una tabla temporal para actualizar saldos
;

with c
as 
(
	select AcctCode,AcctName,FatherNum,Segment_0,FormatCode,2 as Nivel,'0' as esta
	from dbo.oact b left join [@FlujoEfectivo] FE on b.FormatCode = fe.u_cuenta
	where AcctCode like '1%' or AcctCode like '2%' or AcctCode like '3%' or AcctCode like '4%' or AcctCode like '5%' or AcctCode like '6%'
	union all
	select t0.AcctCode,t0.AcctName,t0.FatherNum,t0.Segment_0,t0.FormatCode,Nivel + 1 , t0.esta
	from (
		select b.AcctCode as AcctCode,b.AcctName,b.FatherNum,b.Segment_0,b.FormatCode ,'1' as esta
		from dbo.oact b inner join [@FlujoEfectivo] FE on b.FormatCode = fe.u_Cuenta
		where Levels=5
         ) T0 join c on t0.FatherNum = c.AcctCode
)
---insert into #BalanceTemp
select isnull(c.FormatCode,c.AcctCode) as Cuenta,c.AcctName,c.FatherNum,e.Levels,
--		0 as Enero,0 as Febrero,0 as Marzo,0 as Abril, 0 as Mayo,
--		0 as Junio,0 as Julio,0 as Agosto,0 as Septiembre,0 as Octubre,0 as Noviembre,0 as Diciembre, 
		0 as Total,esta
from c inner join oact e on c.FatherNum = e.AcctCode 
where e.Levels < @nNivel
--group by c.FormatCode,c.AcctName,c.FatherNum,e.Levels
order by isnull(c.FormatCode,c.AcctCode)


---select * from #BalanceTemp

--drop table #BalanceTemp

select @nSaldo
--select * from [@flujoefectivo]
--select formatcode,acctName from zvmpaprueba.dbo.oact where acctname like '%sueldo%'
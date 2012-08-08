--Query para SAP
--Declaración de Variables

declare @dFechaIni	as datetime,
		@dFechaFin	as datetime,
		@nNivel		as int,
		@Tc			as numeric(18,4),
		@nInDesign	as int,
		@cCuenta	as varchar(30),
		@UtilGT		as numeric(18,4),
		@UtilSV		as numeric(18,4),
		@UtilHN		as numeric(18,4),
		@UtilNI		as numeric(18,4),
		@UtilCR		as numeric(18,4),
		@UtilPA		as numeric(18,4),
		@UtilDO		as numeric(18,4),
		@TcGT		as numeric(18,4),
		@TcSV		as numeric(18,4),
		@TcHN		as numeric(18,4),
		@TcNI		as numeric(18,4),
		@TcCR		as numeric(18,4),
		@TcPA		as numeric(18,4),
		@tcDO		as numeric(18,4)

set @nInDesign = 1

if (@nInDesign = 1)
	begin
		set @dFechaIni		= '01/01/2012 00:00:00'
		set @dFechaFin		= '03/31/2012 00:00:00'
		set @nNivel			= 4
	end
else
	begin
		/* SELECT FROM DBO.JDT1 T0*/
		SET @dFechaIni = /* T0.RefDate */'[%0]'
		SET @dFechaFin = /* T0.RefDate*/'[%1]'
		/* select Levels from dbo.oact T1 */
		set @nNivel	= /* T1.Levels */'[%2]'
	end

--Tabla temporal del Balance por Meses

create table #BalanceTempWithTitles
(
	Cuenta		varchar(20),
	Descripcion	varchar(100),
	CuentaPadre	varchar(20),
	Nivel		int,
	Enero		numeric(18,4),
	Febrero		numeric(18,4),
	Marzo		numeric(18,4),
	Abril		numeric(18,4),
	Mayo		numeric(18,4),
	Junio		numeric(18,4),
	Julio		numeric(18,4),
	Agosto		numeric(18,4),
	Septiembre	numeric(18,4),
	Octubre		numeric(18,4),
	Noviembre	numeric(18,4),
	Diciembre	numeric(18,4),
	Total		numeric(18,4)
)

create table #BalancePais
(
	Cuenta		varchar(20),
	descripcion	varchar(100),
	guatemala	numeric(18,4) default 0,
	ElSalvador	numeric(18,4) default 0,
	Honduras	numeric(18,4) default 0,
	Nicaragua   numeric(18,4) default 0,
	CostaRica	numeric(18,4) default 0,
	Panama		numeric(18,4) default 0,
	Dominicana	numeric(18,4) default 0,
	Total		numeric(18,4) default 0
)

create table #BalanceTemp
(
	Cuenta		varchar(20),
	Descripcion	varchar(100),
	CuentaPadre	varchar(20),
	Nivel		int,
	Enero		numeric(18,4),
	Febrero		numeric(18,4),
	Marzo		numeric(18,4),
	Abril		numeric(18,4),
	Mayo		numeric(18,4),
	Junio		numeric(18,4),
	Julio		numeric(18,4),
	Agosto		numeric(18,4),
	Septiembre	numeric(18,4),
	Octubre		numeric(18,4),
	Noviembre	numeric(18,4),
	Diciembre	numeric(18,4),
	Total		numeric(18,4)
)


-- Guatemala

with c
as 
(
	select top 100 percent AcctCode,AcctName,FatherNum,Segment_0,FormatCode,2 as Nivel
	from prgt.dbo.oact b 
	where AcctCode like '1%' or AcctCode like '2%' or AcctCode like '3%'
	union all
	select top 100 percent t0.AcctCode,t0.AcctName,t0.FatherNum,t0.Segment_0,t0.FormatCode,Nivel + 1 
	from (
		select top 100 percent b.AcctCode as AcctCode,b.AcctName,b.FatherNum,b.Segment_0,b.FormatCode from prgt.dbo.oact b where Levels=5
         ) T0 join c on t0.FatherNum = c.AcctCode
)
insert into #BalanceTemp
select top 100 percent isnull(c.FormatCode,c.AcctCode) as Cuenta,c.AcctName,c.FatherNum,e.Levels,0 as Enero,0 as Febrero,0 as Marzo,0 as Abril, 0 as Mayo,
		0 as Junio,0 as Julio,0 as Agosto,0 as Septiembre,0 as Octubre,0 as Noviembre,0 as Diciembre, 0 as Total
from c inner join prgt.dbo.oact e on c.FatherNum = e.AcctCode
where e.Levels < @nNivel
order by isnull(c.FormatCode,c.AcctCode)

-- Ejecuto el procedimiento almacenado para llenar el balance
exec prgt.dbo.BalanceGeneral 'PRGT',@dFechaIni,@dFechaFin,@nNivel,2,0

--Inserto los datos de Guatemala en la tabla temporal
insert into #BalancePais (cuenta,descripcion,guatemala)
	select top 100 percent cuenta,descripcion,isnull(Total,0) from #BalanceTemp 
	where descripcion <> 'UTILIDAD EJERCICIO' and descripcion <>'TIPO DE CAMBIO'

set @UtilGT = (select total from #BalanceTemp where descripcion = 'UTILIDAD EJERCICIO')
set @TcGT	= (select vmsv.dbo.GetTCCountries('PRGT',@dFechaFin))

delete from #BalanceTemp;

-- El Salvador

with c
as 
(
	select top 100 percent AcctCode,AcctName,FatherNum,Segment_0,FormatCode,2 as Nivel
	from vmsv.dbo.oact b 
	where AcctCode like '1%' or AcctCode like '2%' or AcctCode like '3%'
	union all
	select top 100 percent t0.AcctCode,t0.AcctName,t0.FatherNum,t0.Segment_0,t0.FormatCode,Nivel + 1 
	from (
		select b.AcctCode as AcctCode,b.AcctName,b.FatherNum,b.Segment_0,b.FormatCode from vmsv.dbo.oact b where Levels=5
         ) T0 join c on t0.FatherNum = c.AcctCode
)
insert into #BalanceTemp
select top 100 percent isnull(c.FormatCode,c.AcctCode) as Cuenta,c.AcctName,c.FatherNum,e.Levels,0 as Enero,0 as Febrero,0 as Marzo,0 as Abril, 0 as Mayo,
		0 as Junio,0 as Julio,0 as Agosto,0 as Septiembre,0 as Octubre,0 as Noviembre,0 as Diciembre, 0 as Total
from c inner join vmsv.dbo.oact e on c.FatherNum = e.AcctCode
where e.Levels < @nNivel
order by isnull(c.FormatCode,c.AcctCode)

-- Ejecuto el procedimiento almacenado para llenar el balance
exec vmsv.dbo.BalanceGeneral 'VMSV',@dFechaIni,@dFechaFin,@nNivel,2,0

--Inserto los datos de Guatemala en la tabla temporal
insert into #BalancePais (cuenta,descripcion,elsalvador)
	select top 100 percent cuenta,descripcion,isnull(Total,0) from #BalanceTemp 
	where descripcion <> 'UTILIDAD EJERCICIO' and descripcion <> 'TIPO DE CAMBIO'

set @UtilSV = (select total from #BalanceTemp where descripcion = 'UTILIDAD EJERCICIO')
set @TcSV	= (select vmsv.dbo.GetTCCountries('VMSV',@dFechaFin))

delete from #BalanceTemp;

-- Honduras

with c
as 
(
	select top 100 percent AcctCode,AcctName,FatherNum,Segment_0,FormatCode,2 as Nivel
	from prhn.dbo.oact b 
	where AcctCode like '1%' or AcctCode like '2%' or AcctCode like '3%'
	union all
	select top 100 percent t0.AcctCode,t0.AcctName,t0.FatherNum,t0.Segment_0,t0.FormatCode,Nivel + 1 
	from (
		select top 100 percent b.AcctCode as AcctCode,b.AcctName,b.FatherNum,b.Segment_0,b.FormatCode from prhn.dbo.oact b where Levels=5
         ) T0 join c on t0.FatherNum = c.AcctCode
)
insert into #BalanceTemp
select top 100 percent isnull(c.FormatCode,c.AcctCode) as Cuenta,c.AcctName,c.FatherNum,e.Levels,0 as Enero,0 as Febrero,0 as Marzo,0 as Abril, 0 as Mayo,
		0 as Junio,0 as Julio,0 as Agosto,0 as Septiembre,0 as Octubre,0 as Noviembre,0 as Diciembre, 0 as Total
from c inner join prhn.dbo.oact e on c.FatherNum = e.AcctCode
where e.Levels < @nNivel
order by isnull(c.FormatCode,c.AcctCode)

-- Ejecuto el procedimiento almacenado para llenar el balance
exec prhn.dbo.BalanceGeneral 'PRHN',@dFechaIni,@dFechaFin,@nNivel,2,0

--Inserto los datos de Guatemala en la tabla temporal
insert into #BalancePais (cuenta,descripcion,honduras)
	select top 100 percent cuenta,descripcion,isnull(Total,0) from #BalanceTemp 
	where descripcion <> 'UTILIDAD EJERCICIO' and descripcion <> 'TIPO DE CAMBIO'

set @UtilHN = (select total from #BalanceTemp where descripcion = 'UTILIDAD EJERCICIO')
set @TcHN	= (select vmsv.dbo.GetTCCountries('PRHN',@dFechaFin))

delete from #BalanceTemp;

-- Nicaragua

with c
as 
(
	select top 100 percent AcctCode,AcctName,FatherNum,Segment_0,FormatCode,2 as Nivel
	from vmni.dbo.oact b 
	where AcctCode like '1%' or AcctCode like '2%' or AcctCode like '3%'
	union all
	select top 100 percent t0.AcctCode,t0.AcctName,t0.FatherNum,t0.Segment_0,t0.FormatCode,Nivel + 1 
	from (
		select top 100 percent b.AcctCode as AcctCode,b.AcctName,b.FatherNum,b.Segment_0,b.FormatCode from vmni.dbo.oact b where Levels=5
         ) T0 join c on t0.FatherNum = c.AcctCode
)
insert into #BalanceTemp
select top 100 percent isnull(c.FormatCode,c.AcctCode) as Cuenta,c.AcctName,c.FatherNum,e.Levels,0 as Enero,0 as Febrero,0 as Marzo,0 as Abril, 0 as Mayo,
		0 as Junio,0 as Julio,0 as Agosto,0 as Septiembre,0 as Octubre,0 as Noviembre,0 as Diciembre, 0 as Total
from c inner join vmni.dbo.oact e on c.FatherNum = e.AcctCode
where e.Levels < @nNivel
order by isnull(c.FormatCode,c.AcctCode)

-- Ejecuto el procedimiento almacenado para llenar el balance
exec vmni.dbo.BalanceGeneral 'VMNI',@dFechaIni,@dFechaFin,@nNivel,2,0


--Inserto los datos de Guatemala en la tabla temporal
insert into #BalancePais (cuenta,descripcion,nicaragua)
	select top 100 percent cuenta,descripcion,isnull(Total,0) from #BalanceTemp 
	where descripcion <> 'UTILIDAD EJERCICIO' and descripcion <> 'TIPO DE CAMBIO'

set @UtilNI = (select total from #BalanceTemp where descripcion = 'UTILIDAD EJERCICIO')
set @TcNI	= (select vmsv.dbo.GetTCCountries('VMNI',@dFechaFin))

delete from #BalanceTemp;

--Costa Rica

with c
as 
(
	select top 100 percent AcctCode,AcctName,FatherNum,Segment_0,FormatCode,2 as Nivel
	from vmcr.dbo.oact b 
	where AcctCode like '1%' or AcctCode like '2%' or AcctCode like '3%'
	union all
	select top 100 percent t0.AcctCode,t0.AcctName,t0.FatherNum,t0.Segment_0,t0.FormatCode,Nivel + 1 
	from (
		select top 100 percent b.AcctCode as AcctCode,b.AcctName,b.FatherNum,b.Segment_0,b.FormatCode from vmcr.dbo.oact b where Levels=5
         ) T0 join c on t0.FatherNum = c.AcctCode
)
insert into #BalanceTemp
select top 100 percent isnull(c.FormatCode,c.AcctCode) as Cuenta,c.AcctName,c.FatherNum,e.Levels,0 as Enero,0 as Febrero,0 as Marzo,0 as Abril, 0 as Mayo,
		0 as Junio,0 as Julio,0 as Agosto,0 as Septiembre,0 as Octubre,0 as Noviembre,0 as Diciembre, 0 as Total
from c inner join vmcr.dbo.oact e on c.FatherNum = e.AcctCode
where e.Levels < @nNivel
order by isnull(c.FormatCode,c.AcctCode)

-- Ejecuto el procedimiento almacenado para llenar el balance
exec vmcr.dbo.BalanceGeneral 'VMCR',@dFechaIni,@dFechaFin,@nNivel,2,0


--Inserto los datos de Guatemala en la tabla temporal
insert into #BalancePais (cuenta,descripcion,costarica)
	select top 100 percent cuenta,descripcion,isnull(Total,0) from #BalanceTemp 
	where descripcion <> 'UTILIDAD EJERCICIO' and descripcion <> 'TIPO DE CAMBIO'

set @UtilCR = (select total from #BalanceTemp where descripcion = 'UTILIDAD EJERCICIO')
set @TcCR	= (select vmsv.dbo.GetTCCountries('VMCR',@dFechaFin))


delete from #BalanceTemp;

-- Panamá

with c
as 
(
	select top 100 percent AcctCode,AcctName,FatherNum,Segment_0,FormatCode,2 as Nivel
	from vmpa.dbo.oact b 
	where AcctCode like '1%' or AcctCode like '2%' or AcctCode like '3%'
	union all
	select top 100 percent t0.AcctCode,t0.AcctName,t0.FatherNum,t0.Segment_0,t0.FormatCode,Nivel + 1 
	from (
		select top 100 percent b.AcctCode as AcctCode,b.AcctName,b.FatherNum,b.Segment_0,b.FormatCode from vmpa.dbo.oact b where Levels=5
         ) T0 join c on t0.FatherNum = c.AcctCode
)
insert into #BalanceTemp
select top 100 percent isnull(c.FormatCode,c.AcctCode) as Cuenta,c.AcctName,c.FatherNum,e.Levels,0 as Enero,0 as Febrero,0 as Marzo,0 as Abril, 0 as Mayo,
		0 as Junio,0 as Julio,0 as Agosto,0 as Septiembre,0 as Octubre,0 as Noviembre,0 as Diciembre, 0 as Total
from c inner join vmpa.dbo.oact e on c.FatherNum = e.AcctCode
where e.Levels < @nNivel
order by isnull(c.FormatCode,c.AcctCode)

-- Ejecuto el procedimiento almacenado para llenar el balance
exec vmpa.dbo.BalanceGeneral 'VMPA',@dFechaIni,@dFechaFin,@nNivel,2,0

--Inserto los datos de Guatemala en la tabla temporal
insert into #BalancePais (cuenta,descripcion,panama)
	select top 100 percent cuenta,descripcion,isnull(Total,0) from #BalanceTemp 
	where descripcion <> 'UTILIDAD EJERCICIO' and descripcion <> 'TIPO DE CAMBIO'

set @UtilPA = (select total from #BalanceTemp where descripcion = 'UTILIDAD EJERCICIO')
set @TcPa	= (select vmsv.dbo.GetTCCountries('VMPA',@dFechaFin))

delete from #BalanceTemp;

--Dominicana

with c
as 
(
	select top 100 percent AcctCode,AcctName,FatherNum,Segment_0,FormatCode,2 as Nivel
	from vmdo.dbo.oact b 
	where AcctCode like '1%' or AcctCode like '2%' or AcctCode like '3%'
	union all
	select top 100 percent t0.AcctCode,t0.AcctName,t0.FatherNum,t0.Segment_0,t0.FormatCode,Nivel + 1 
	from (
		select top 100 percent b.AcctCode as AcctCode,b.AcctName,b.FatherNum,b.Segment_0,b.FormatCode from vmdo.dbo.oact b where Levels=5
         ) T0 join c on t0.FatherNum = c.AcctCode
)
insert into #BalanceTemp
select top 100 percent isnull(c.FormatCode,c.AcctCode) as Cuenta,c.AcctName,c.FatherNum,e.Levels,0 as Enero,0 as Febrero,0 as Marzo,0 as Abril, 0 as Mayo,
		0 as Junio,0 as Julio,0 as Agosto,0 as Septiembre,0 as Octubre,0 as Noviembre,0 as Diciembre, 0 as Total
from c inner join vmdo.dbo.oact e on c.FatherNum = e.AcctCode
where e.Levels < @nNivel
order by isnull(c.FormatCode,c.AcctCode)

-- Ejecuto el procedimiento almacenado para llenar el balance
exec vmdo.dbo.BalanceGeneral 'VMDO',@dFechaIni,@dFechaFin,@nNivel,2,0

--Inserto los datos de Guatemala en la tabla temporal
insert into #BalancePais (cuenta,descripcion,dominicana)
	select top 100 percent cuenta,descripcion,isnull(Total,0) from #BalanceTemp 
	where descripcion <> 'UTILIDAD EJERCICIO' and descripcion <> 'TIPO DE CAMBIO'

set @UtilDO = (select total from #BalanceTemp where descripcion = 'UTILIDAD EJERCICIO')
set @TcDO	= (select vmsv.dbo.GetTCCountries('VMDO',@dFechaFin))

delete from #BalanceTemp;

-- inserto las utilidades
--insert into #BalancePais (cuenta, descripcion) values ('  ','  ')
--insert into #BalancePais (cuenta,descripcion,guatemala,elsalvador,honduras,costarica,panama,dominicana) 
--			values (' ','UTILIDAD EJERCICIO',@UtilGT,@UtilSV,@UtilHN,@UtilCR,@UtilPA,@UtilDO)

--Actualizo totales generales

update #BalancePais set total = (guatemala+elsalvador+honduras+nicaragua+costarica+panama+dominicana)

--Elimino registros con total a cero 

delete from #BalancePais where total = 0

--
SELECT * 
from 
(
select top 2500 substring(cuenta,1,9) as Cuenta,Descripcion,sum(guatemala) as Guatemala,sum(ElSalvador) as [El Salvador],sum(honduras) as Honduras,
		sum(Nicaragua) as Nicaragua,sum(Costarica) as [Costa Rica],sum(Panama) as [Panamá],sum(dominicana) as Dominicana,sum(total) as Total
from #BalancePais
group by substring(Cuenta,1,9),descripcion
order by substring(Cuenta,1,9)
) T0
union all 
select '' as cuenta,'UTILIDAD EJERCICIO' AS descripcion,@UtilGT,@UtilSV,@UtilHN,@UtilNI,@UtilCR,@UtilPA,@UtilDO,
		(@UtilGT+@UtilSV+@UtilHN+@UtilNI+@UtilCR+@UtilPA+@UtilDO) as Total
union all 
select '' as cuenta,'TIPO DE CAMBIO' as descripcion,@TcGT,@TcSV,@TcHN,@TcNI,@TcCR,@TcPA,@TcDO,0


drop table #BalanceTemp
drop Table #BalancePais
drop table #BalanceTempWithTitles
--Query para SAP
--Declaración de Variables

declare @dFechaIni	as datetime,
		@dFechaFin	as datetime,
		@nNivel		as int,
		@Tc			as numeric(18,4),
		@nInDesign	as int,
		@cCuenta	as varchar(30),
		@UtilSV		as numeric(18,4),
		@UtilHN		as numeric(18,4),
		@UtilNI		as numeric(18,4),
		@UtilCR		as numeric(18,4),
		@UtilPA		as numeric(18,4),
		@TcSV		as numeric(18,4),
		@TcHN		as numeric(18,4),
		@TcNI		as numeric(18,4),
		@TcCR		as numeric(18,4),
		@TcPA		as numeric(18,4)


set @nInDesign = 1

if (@nInDesign = 1)
	begin
		set @dFechaIni		= '01/01/2010 00:00:00'
		set @dFechaFin		= '06/30/2010 00:00:00'
		set @nNivel			= 5
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

create table #BalancePais
(
	Cuenta		varchar(20),
	descripcion	varchar(100),
	ElSalvador	numeric(18,4) default 0,
	Honduras	numeric(18,4) default 0,
	Nicaragua	numeric(18,4) default 0,
	CostaRica	numeric(18,4) default 0,
	Panama		numeric(18,4) default 0,
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


-- El Salvador

with c
as 
(
	select top 100 percent AcctCode,AcctName,FatherNum,Segment_0,FormatCode,2 as Nivel
	from cvsv.dbo.oact b 
	where AcctCode like '1%' or AcctCode like '2%' or AcctCode like '3%'
	union all
	select top 100 percent t0.AcctCode,t0.AcctName,t0.FatherNum,t0.Segment_0,t0.FormatCode,Nivel + 1 
	from (
		select top 100 percent b.AcctCode as AcctCode,b.AcctName,b.FatherNum,b.Segment_0,b.FormatCode from cvsv.dbo.oact b where Levels=5
         ) T0 join c on t0.FatherNum = c.AcctCode
)
insert into #BalanceTemp
select top 100 percent isnull(c.FormatCode,c.AcctCode) as Cuenta,c.AcctName,c.FatherNum,e.Levels,0 as Enero,0 as Febrero,0 as Marzo,0 as Abril, 0 as Mayo,
		0 as Junio,0 as Julio,0 as Agosto,0 as Septiembre,0 as Octubre,0 as Noviembre,0 as Diciembre, 0 as Total
from c inner join cvsv.dbo.oact e on c.FatherNum = e.AcctCode
where e.Levels < @nNivel
order by isnull(c.FormatCode,c.AcctCode)

-- Ejecuto el procedimiento almacenado para llenar el balance
exec cvsv.dbo.BalanceGeneral 'CVSV',@dFechaIni,@dFechaFin,@nNivel,2,1

--Inserto los datos de El Salvador en la tabla temporal
insert into #BalancePais (cuenta,descripcion,ElSalvador)
	select top 100 percent cuenta,descripcion,isnull(Total,0) from #BalanceTemp 
	where descripcion <> 'UTILIDAD EJERCICIO' and descripcion <>'TIPO DE CAMBIO'

set @UtilSV = (select total from #BalanceTemp where descripcion = 'UTILIDAD EJERCICIO')
set @TcSV	= (select cvsv.dbo.GetTCCountries('CVSV',@dFechaFin))

delete from #BalanceTemp;

-- Honduras

with c
as 
(
	select top 100 percent AcctCode,AcctName,FatherNum,Segment_0,FormatCode,2 as Nivel
	from cvhn.dbo.oact b 
	where AcctCode like '1%' or AcctCode like '2%' or AcctCode like '3%'
	union all
	select top 100 percent t0.AcctCode,t0.AcctName,t0.FatherNum,t0.Segment_0,t0.FormatCode,Nivel + 1 
	from (
		select b.AcctCode as AcctCode,b.AcctName,b.FatherNum,b.Segment_0,b.FormatCode from cvhn.dbo.oact b where Levels=5
         ) T0 join c on t0.FatherNum = c.AcctCode
)
insert into #BalanceTemp
select top 100 percent isnull(c.FormatCode,c.AcctCode) as Cuenta,c.AcctName,c.FatherNum,e.Levels,0 as Enero,0 as Febrero,0 as Marzo,0 as Abril, 0 as Mayo,
		0 as Junio,0 as Julio,0 as Agosto,0 as Septiembre,0 as Octubre,0 as Noviembre,0 as Diciembre, 0 as Total
from c inner join cvhn.dbo.oact e on c.FatherNum = e.AcctCode
where e.Levels < @nNivel
order by isnull(c.FormatCode,c.AcctCode)

-- Ejecuto el procedimiento almacenado para llenar el balance
exec cvhn.dbo.BalanceGeneral 'CVHN',@dFechaIni,@dFechaFin,@nNivel,2,1

--Inserto los datos de Honduras en la tabla temporal
insert into #BalancePais (cuenta,descripcion,honduras)
	select top 100 percent cuenta,descripcion,isnull(Total,0) from #BalanceTemp 
	where descripcion <> 'UTILIDAD EJERCICIO' and descripcion <> 'TIPO DE CAMBIO'

set @UtilHN = (select total from #BalanceTemp where descripcion = 'UTILIDAD EJERCICIO')
set @TcHN	= (select cvsv.dbo.GetTCCountries('CVHN',@dFechaFin))

delete from #BalanceTemp;

-- Nicaragua

with c
as 
(
	select top 100 percent AcctCode,AcctName,FatherNum,Segment_0,FormatCode,2 as Nivel
	from cvni.dbo.oact b 
	where AcctCode like '1%' or AcctCode like '2%' or AcctCode like '3%'
	union all
	select top 100 percent t0.AcctCode,t0.AcctName,t0.FatherNum,t0.Segment_0,t0.FormatCode,Nivel + 1 
	from (
		select top 100 percent b.AcctCode as AcctCode,b.AcctName,b.FatherNum,b.Segment_0,b.FormatCode from cvni.dbo.oact b where Levels=5
         ) T0 join c on t0.FatherNum = c.AcctCode
)
insert into #BalanceTemp
select top 100 percent isnull(c.FormatCode,c.AcctCode) as Cuenta,c.AcctName,c.FatherNum,e.Levels,0 as Enero,0 as Febrero,0 as Marzo,0 as Abril, 0 as Mayo,
		0 as Junio,0 as Julio,0 as Agosto,0 as Septiembre,0 as Octubre,0 as Noviembre,0 as Diciembre, 0 as Total
from c inner join cvni.dbo.oact e on c.FatherNum = e.AcctCode
where e.Levels < @nNivel
order by isnull(c.FormatCode,c.AcctCode)

-- Ejecuto el procedimiento almacenado para llenar el balance
exec cvni.dbo.BalanceGeneral 'CVNI',@dFechaIni,@dFechaFin,@nNivel,2,1

--Inserto los datos de Nicaragua en la tabla temporal
insert into #BalancePais (cuenta,descripcion,nicaragua)
	select top 100 percent cuenta,descripcion,isnull(Total,0) from #BalanceTemp 
	where descripcion <> 'UTILIDAD EJERCICIO' and descripcion <> 'TIPO DE CAMBIO'

set @UtilNI = (select total from #BalanceTemp where descripcion = 'UTILIDAD EJERCICIO')
set @TcNi	= (select cvsv.dbo.GetTCCountries('CVNI',@dFechaFin))

delete from #BalanceTemp;

--Costa Rica

with c
as 
(
	select top 100 percent AcctCode,AcctName,FatherNum,Segment_0,FormatCode,2 as Nivel
	from cvcr.dbo.oact b 
	where AcctCode like '1%' or AcctCode like '2%' or AcctCode like '3%'
	union all
	select top 100 percent t0.AcctCode,t0.AcctName,t0.FatherNum,t0.Segment_0,t0.FormatCode,Nivel + 1 
	from (
		select top 100 percent b.AcctCode as AcctCode,b.AcctName,b.FatherNum,b.Segment_0,b.FormatCode from cvcr.dbo.oact b where Levels=5
         ) T0 join c on t0.FatherNum = c.AcctCode
)
insert into #BalanceTemp
select top 100 percent isnull(c.FormatCode,c.AcctCode) as Cuenta,c.AcctName,c.FatherNum,e.Levels,0 as Enero,0 as Febrero,0 as Marzo,0 as Abril, 0 as Mayo,
		0 as Junio,0 as Julio,0 as Agosto,0 as Septiembre,0 as Octubre,0 as Noviembre,0 as Diciembre, 0 as Total
from c inner join cvcr.dbo.oact e on c.FatherNum = e.AcctCode
where e.Levels < @nNivel
order by isnull(c.FormatCode,c.AcctCode)

-- Ejecuto el procedimiento almacenado para llenar el balance
exec cvcr.dbo.BalanceGeneral 'CVCR',@dFechaIni,@dFechaFin,@nNivel,2,1

--Inserto los datos de Costa Rica en la tabla temporal
insert into #BalancePais (cuenta,descripcion,costarica)
	select top 100 percent cuenta,descripcion,isnull(Total,0) from #BalanceTemp 
	where descripcion <> 'UTILIDAD EJERCICIO' and descripcion <> 'TIPO DE CAMBIO'

set @UtilCR = (select total from #BalanceTemp where descripcion = 'UTILIDAD EJERCICIO')
set @TcCR	= (select cvsv.dbo.GetTCCountries('CVCR',@dFechaFin))


delete from #BalanceTemp;

-- Panamá

with c
as 
(
	select top 100 percent AcctCode,AcctName,FatherNum,Segment_0,FormatCode,2 as Nivel
	from cvpa.dbo.oact b 
	where AcctCode like '1%' or AcctCode like '2%' or AcctCode like '3%'
	union all
	select top 100 percent t0.AcctCode,t0.AcctName,t0.FatherNum,t0.Segment_0,t0.FormatCode,Nivel + 1 
	from (
		select top 100 percent b.AcctCode as AcctCode,b.AcctName,b.FatherNum,b.Segment_0,b.FormatCode from cvpa.dbo.oact b where Levels=5
         ) T0 join c on t0.FatherNum = c.AcctCode
)
insert into #BalanceTemp
select top 100 percent isnull(c.FormatCode,c.AcctCode) as Cuenta,c.AcctName,c.FatherNum,e.Levels,0 as Enero,0 as Febrero,0 as Marzo,0 as Abril, 0 as Mayo,
		0 as Junio,0 as Julio,0 as Agosto,0 as Septiembre,0 as Octubre,0 as Noviembre,0 as Diciembre, 0 as Total
from c inner join cvpa.dbo.oact e on c.FatherNum = e.AcctCode
where e.Levels < @nNivel
order by isnull(c.FormatCode,c.AcctCode)

-- Ejecuto el procedimiento almacenado para llenar el balance
exec cvpa.dbo.BalanceGeneral 'CVPA',@dFechaIni,@dFechaFin,@nNivel,2,1

--Inserto los datos de Panamá en la tabla temporal
insert into #BalancePais (cuenta,descripcion,panama)
	select top 100 percent cuenta,descripcion,isnull(Total,0) from #BalanceTemp 
	where descripcion <> 'UTILIDAD EJERCICIO' and descripcion <> 'TIPO DE CAMBIO'

set @UtilPA = (select total from #BalanceTemp where descripcion = 'UTILIDAD EJERCICIO')
set @TcPa	= (select cvsv.dbo.GetTCCountries('CVPA',@dFechaFin))

delete from #BalanceTemp;

--Actualizo totales generales

update #BalancePais set total = (elsalvador+honduras+nicaragua+costarica+panama)

--Elimino registros con total a cero 

delete from #BalancePais where total = 0

--
SELECT * 
from 
(
select top 2500 substring(cuenta,1,9) as Cuenta,Descripcion,sum(elsalvador) as [El Salvador],
		sum(honduras) as [Honduras],sum(nicaragua) as Nicaragua,
		sum(Costarica) as [Costa Rica],sum(Panama) as [Panamá],sum(total) as Total
from #BalancePais
group by substring(Cuenta,1,9),descripcion
order by substring(Cuenta,1,9)
) T0
union all 
select '' as cuenta,'UTILIDAD EJERCICIO' AS descripcion,@UtilSV,@UtilHN,@UtilNI,@UtilCR,@UtilPA,
		(@UtilSV+@UtilHN+@UtilNI+@UtilCR+@UtilPA) as Total
union all 
select '' as cuenta,'TIPO DE CAMBIO' as descripcion,@TcSV,@TcHN,@TcNI,@TcCR,@TcPA,null


drop table #BalanceTemp
drop Table #BalancePais
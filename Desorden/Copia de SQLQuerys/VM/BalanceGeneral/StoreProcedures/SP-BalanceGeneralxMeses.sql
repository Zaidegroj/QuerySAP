set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER procedure [dbo].[BalanceGeneralxMeses] (@DBPais as varchar(4),
										@dFechaIni as datetime,
										@dFechaFin as datetime,
										@nNivel as int,
										@Tc as numeric(18,2))
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

		exec BalanceGeneral @DBPais , @dFechaIni , @dFechaFin, @nNivel,@Tc

		if (@iMonthFirst=1)
			begin
				insert into #ESMeses (codigo,nombre,enero)
					select codigo,nombre, saldo from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,Enero,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
			end
		if (@iMonthFirst=2)
			begin
				insert into #ESMeses (codigo,nombre,febrero)
					select codigo,nombre, saldo from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,Febrero,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
				--delete From #TmpConso
			end
		if (@iMonthFirst=3)
			begin
				insert into #ESMeses (codigo,nombre,marzo)
					select codigo,nombre, saldo from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,marzo,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
				--delete From #TmpConso
			end
		if (@iMonthFirst=4)
			begin
				insert into #ESMeses (codigo,nombre,abril)
					select codigo,nombre, saldo from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,abril,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
				--delete From #TmpConso
			end
		if (@iMonthFirst=5)
			begin
				insert into #ESMeses (codigo,nombre,mayo)
					select codigo,nombre, saldo from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,mayo,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
				--delete From #TmpConso
			end
		if (@iMonthFirst=6)
			begin
				insert into #ESMeses (codigo,nombre,junio)
					select codigo,nombre, saldo from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,junio,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
				--delete From #TmpConso
			end
		if (@iMonthFirst=7)
			begin
				insert into #ESMeses (codigo,nombre,julio)
					select codigo,nombre, saldo from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,julio,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
				--delete From #TmpConso
			end
		if (@iMonthFirst=8)
			begin
				insert into #ESMeses (codigo,nombre,agosto)
					select codigo,nombre, saldo from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,agosto,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
				--delete From #TmpConso
			end
		if (@iMonthFirst=9)
			begin
				insert into #ESMeses (codigo,nombre,septiembre)
					select codigo,nombre, saldo from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,septiembre,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
				--delete From #TmpConso
			end
		if (@iMonthFirst=10)
			begin
				insert into #ESMeses (codigo,nombre,octubre)
					select codigo,nombre, saldo from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,octubre,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
				---delete From #TmpConso
			end
		if (@iMonthFirst=11)
			begin
				insert into #ESMeses (codigo,nombre,noviembre)
					select codigo,nombre, saldo from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,noviembre,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
				--delete From #TmpConso
			end
		if (@iMonthFirst=12)
			begin
				insert into #ESMeses (codigo,nombre,diciembre)
					select codigo,nombre, saldo from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,diciembre,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
				--delete From #TmpConso
			end
		set @dFechaIni = convert(char(10),DateAdd(ms,-1,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'
		set @dFechaFin = convert(char(10),DateAdd(ms,-2,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'
		set @iMonthFirst = @iMonthFirst + 1
	end

-- Si el Nivel de la cuenta es diferente de 3 entonces agrego las cuentas de mayor
if (@nNivel = 4)
	begin
		insert into #ESMeses
		select  AcctCode,AcctName,0,0,0,0,0,0,0,0,0,0,0,0,0,'AE' as TipoCol
		from oact where len(AcctCode)= 4 and substring(AcctCode,1,4) like '11%'
		order by AcctCode
	end

insert into #ESMeses
select codigo,nombre,isnull(sum(enero),0)*-1,isnull(sum(febrero),0)*-1,isnull(sum(marzo),0)*-1,isnull(sum(abril),0)*-1,
		isnull(sum(mayo),0)*-1,isnull(sum(junio),0)*-1,isnull(sum(julio),0)*-1,isnull(sum(agosto),0)*-1,
		isnull(sum(septiembre),0)*-1,isnull(sum(octubre),0)*-1,isnull(sum(noviembre),0)*-1,isnull(sum(diciembre),0)*-1,0,
		'A11' as TipoCol
from #ESMeses
where codigo like '11%'
group by codigo,nombre
order by codigo

---- Inserto total

insert into #ESMeses 
			select '' as codigo,'  TOTAL  ' as nombre,isnull(sum(enero),0),isnull(sum(febrero),0),isnull(sum(marzo),0),
					isnull(sum(abril),0),isnull(sum(mayo),0),isnull(sum(junio),0),
					isnull(sum(julio),0),isnull(sum(agosto),0),isnull(sum(septiembre),0),isnull(sum(octubre),0),
					isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,'TA11' as TipoCol
			from   #ESMeses
			where TipoCol = 'A11'

---- inserto Activos no Corrientes

insert into #ESMeses
select codigo,nombre,isnull(sum(enero),0)*-1,isnull(sum(febrero),0)*-1,isnull(sum(marzo),0)*-1,
		isnull(sum(abril),0)*-1,isnull(sum(mayo),0)*-1,isnull(sum(junio),0)*-1,isnull(sum(julio),0)*-1,
		isnull(sum(agosto),0)*-1,isnull(sum(septiembre),0)*-1,isnull(sum(octubre),0)*-1,isnull(sum(noviembre),0)*-1,
		isnull(sum(diciembre),0)*-1,0,'A12' as TipoCol
from #ESMeses
where codigo like '12%'
group by codigo,nombre
order by codigo

-----select * from #ESMeses where tipocol = 'A12'

insert into #ESMeses
		select '' as codigo,'  TOTAL  ' as nombre,isnull(sum(enero),0),isnull(sum(febrero),0),isnull(sum(marzo),0),
				isnull(sum(abril),0),isnull(sum(mayo),0),isnull(sum(junio),0),isnull(sum(julio),0),isnull(sum(agosto),0),
				isnull(sum(septiembre),0),isnull(sum(octubre),0),isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,
				'TA12' as TipoCol
		from   #ESMeses
		where TipoCol = 'A12'
		group by left(codigo,2)

--Inserto el Total del Activo

insert into #ESMeses
			select '' as codigo,'     TOTAL  ACTIVO    ' as nombre,isnull(sum(enero),0),isnull(sum(febrero),0),
					isnull(sum(marzo),0),isnull(sum(abril),0),isnull(sum(mayo),0),isnull(sum(junio),0),
					isnull(sum(julio),0),isnull(sum(agosto),0),isnull(sum(septiembre),0),isnull(sum(octubre),0),
					isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,'TA' as TipoCol
			from   #ESMeses
			where TipoCol in ('A11','A12')

-- Inserto el Pasivo

insert into #ESMeses
select codigo,nombre,isnull(sum(enero),0)*-1,isnull(sum(febrero),0)*-1,isnull(sum(marzo),0)*-1,
		isnull(sum(abril),0)*-1,isnull(sum(mayo),0)*-1,isnull(sum(junio),0)*-1,isnull(sum(julio),0)*-1,
		isnull(sum(agosto),0)*-1,isnull(sum(septiembre),0)*-1,isnull(sum(octubre),0)*-1,isnull(sum(noviembre),0)*-1,
		isnull(sum(diciembre),0)*-1,0,'P21' as TipoCol
from #ESMeses
where codigo like '21%'
group by codigo,nombre
order by codigo

insert into #ESMeses
		select '' as codigo,'  TOTAL  ' as nombre,isnull(sum(enero),0),isnull(sum(febrero),0),isnull(sum(marzo),0),
				isnull(sum(abril),0),isnull(sum(mayo),0),isnull(sum(junio),0),isnull(sum(julio),0),isnull(sum(agosto),0),
				isnull(sum(septiembre),0),isnull(sum(octubre),0),isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,
				'TP21' as TipoCol
		from   #ESMeses
		where TipoCol = 'P21'
		group by left(codigo,2)

-- Inserto el Pasivo no Corrientes
if ((select count(codigo)
		from #ESMeses
		where codigo like '22%') >0) 
	begin

		insert into #ESMeses
		select codigo,nombre,isnull(sum(enero),0)*-1,isnull(sum(febrero),0)*-1,isnull(sum(marzo),0)*-1,
				isnull(sum(abril),0)*-1,isnull(sum(mayo),0)*-1,isnull(sum(junio),0)*-1,isnull(sum(julio),0)*-1,
				isnull(sum(agosto),0)*-1,isnull(sum(septiembre),0)*-1,isnull(sum(octubre),0)*-1,isnull(sum(noviembre),0)*-1,
				isnull(sum(diciembre),0)*-1,0,'P22' as TipoCol
		from #ESMeses
		where codigo like '22%'
		group by codigo,nombre
		order by codigo
	
	insert into #ESMeses
		select '' as codigo,'  TOTAL  ' as nombre,isnull(sum(enero),0),isnull(sum(febrero),0),isnull(sum(marzo),0),
				isnull(sum(abril),0),isnull(sum(mayo),0),isnull(sum(junio),0),isnull(sum(julio),0),isnull(sum(agosto),0),
				isnull(sum(septiembre),0),isnull(sum(octubre),0),isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,
				'TP22' as TipoCol
		from   #ESMeses
		where TipoCol = 'P22'
		group by left(codigo,2)
	end

--Inserto el Total del Pasivo

insert into #ESMeses
			select '' as codigo,'     TOTAL  PASIVO    ' as nombre,isnull(sum(enero),0),isnull(sum(febrero),0),
					isnull(sum(marzo),0),isnull(sum(abril),0),isnull(sum(mayo),0),isnull(sum(junio),0),
					isnull(sum(julio),0),isnull(sum(agosto),0),isnull(sum(septiembre),0),isnull(sum(octubre),0),
					isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,'TP' as TipoCol
			from   #ESMeses
			where TipoCol in ('P21','P22')


-- Inserto Capital y Reserva

if ((select count(codigo)
		from #ESMeses
		where codigo like '31%') >0) 
	begin
		insert into #ESMeses
			select codigo,nombre,isnull(sum(enero),0),isnull(sum(febrero),0),isnull(sum(marzo),0),
					isnull(sum(abril),0),isnull(sum(mayo),0),isnull(sum(junio),0),isnull(sum(julio),0),
					isnull(sum(agosto),0),isnull(sum(septiembre),0),isnull(sum(octubre),0),isnull(sum(noviembre),0),
					isnull(sum(diciembre),0),0,'C31' as TipoCol
			from #ESMeses
			where codigo like '31%'
			group by codigo,nombre
			order by codigo
	end

-- Insertando la utilidad o pérdida del mes
insert into #ESMESES
	select codigo,nombre,sum(enero),sum(febrero),sum(marzo),sum(abril),sum(mayo),sum(junio),sum(julio),
			sum(agosto),sum(septiembre),sum(octubre),sum(noviembre),sum(diciembre),sum(total),TipoCol
	from
		(
			select '' as codigo,'     PERIODO GANANCIAS    ' as nombre,
				case TipoCol
					when 'TA' then isnull(sum(enero),0) else isnull(sum(enero),0) end as enero,
				case TipoCol
					when 'TA' then isnull(sum(febrero),0) else isnull(sum(febrero),0) end as febrero,
				case TipoCol
					when 'TA' then isnull(sum(marzo),0) else isnull(sum(marzo),0) end as marzo,
				case TipoCol
					when 'TA' then isnull(sum(abril),0) else isnull(sum(abril),0) end as abril,
				case TipoCol
					when 'TA' then isnull(sum(mayo),0) else isnull(sum(mayo),0) end as mayo,
				case TipoCol
					when 'TA' then isnull(sum(junio),0) else isnull(sum(junio),0) end as junio,
				case TipoCol
					when 'TA' then isnull(sum(julio),0) else isnull(sum(julio),0) end as julio,
				case TipoCol
					when 'TA' then isnull(sum(agosto),0) else isnull(sum(agosto),0) end as agosto,
				case TipoCol
					when 'TA' then isnull(sum(septiembre),0) else isnull(sum(septiembre),0) end as septiembre,
				case TipoCol
					when 'TA' then isnull(sum(octubre),0) else isnull(sum(octubre),0) end as octubre,
				case TipoCol
					when 'TA' then isnull(sum(noviembre),0) else isnull(sum(noviembre),0) end as noviembre,
				case TipoCol
					when 'TA' then isnull(sum(diciembre),0) else isnull(sum(diciembre),0) end as diciembre,
				0 as total,'PG31' as TipoCol
			from   #ESMeses
			where TipoCol in ('TA','TP')
			group by TipoCol) T0
	group by t0.codigo,t0.nombre,t0.Tipocol

-- Total Capital 

insert into #ESMeses
		select '' as codigo,'     TOTAL  CAPITAL Y RESERVA    ' as nombre,isnull(sum(enero),0),isnull(sum(febrero),0),
				isnull(sum(marzo),0),isnull(sum(abril),0),isnull(sum(mayo),0),isnull(sum(junio),0),
				isnull(sum(julio),0),isnull(sum(agosto),0),isnull(sum(septiembre),0),isnull(sum(octubre),0),
				isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,'TC31' as TipoCol
		from   #ESMeses
		where TipoCol in ('C31','PG31')

-- Insertando Pasivo mas Capital 
insert into #ESMESES
select '' as codigo,'     TOTAL PASIVO MAS CAPITAL    ' as nombre,isnull(sum(enero),0),isnull(sum(febrero),0),
		isnull(sum(marzo),0),isnull(sum(abril),0),isnull(sum(mayo),0),isnull(sum(junio),0),
		isnull(sum(julio),0),isnull(sum(agosto),0),isnull(sum(septiembre),0),isnull(sum(octubre),0),
		isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,'TPC' as TipoCol
from   #ESMeses
where TipoCol in ('TP','TC31','PG31')

update #ESMeses set total = (isnull(enero,0)+isnull(febrero,0)+isnull(marzo,0)+isnull(abril,0)+isnull(mayo,0) +isnull(junio,0) +
							isnull(julio,0)+isnull(agosto,0)+isnull(septiembre,0)+isnull(octubre,0)+isnull(noviembre,0)+
							isnull(diciembre,0)) where TipoCol <> 'TTC'

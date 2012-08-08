alter procedure EstadoResultadoxMeses (@DBPais as varchar(4),
										@dFechaIni as datetime,
										@dFechaFin as datetime,
										@dFechaIniAcum as datetime,
										@nNivel as int,
										@Tc as numeric(18,2))

as 

declare @iMonthFirst int,
		@iMonthLast int,
		@iFlag int

set @iMonthFirst	= month(@dFechaIni)
set @iMonthLast		= month(@dFechaFin)
set @iFlag			= 1
set @dFechaIni		= convert(char(10),@dFechaIni,121)+' 00:00:00'
set @dFechaFin		= convert(char(10),DateAdd(ms,-2,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'

while (@iMonthFirst <=@iMonthLast)
	begin

		exec EstadoResultadoConsolidado_R1 @DBPais , @dFechaIni , @dFechaFin, @dFechaIniAcum,@nNivel,@Tc

		if (@iMonthFirst=1)
			begin
				insert into #ESMeses (codigo,nombre,enero)
					select codigo,nombre, sv from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						--set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
						set @Tc = (select dbo.ObtenerTcOficial(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,Enero,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
			end
		if (@iMonthFirst=2)
			begin
				insert into #ESMeses (codigo,nombre,febrero)
					select codigo,nombre, sv from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						--set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
						set @Tc = (select dbo.ObtenerTcOficial(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,Febrero,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
				--delete From #TmpConso
			end
		if (@iMonthFirst=3)
			begin
				insert into #ESMeses (codigo,nombre,marzo)
					select codigo,nombre, sv from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						--set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
						set @Tc = (select dbo.ObtenerTcOficial(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,marzo,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
				--delete From #TmpConso
			end
		if (@iMonthFirst=4)
			begin
				insert into #ESMeses (codigo,nombre,abril)
					select codigo,nombre, sv from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						--set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
						set @Tc = (select dbo.ObtenerTcOficial(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,abril,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
				--delete From #TmpConso
			end
		if (@iMonthFirst=5)
			begin
				insert into #ESMeses (codigo,nombre,mayo)
					select codigo,nombre, sv from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						--set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
						set @Tc = (select dbo.ObtenerTcOficial(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,mayo,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
				--delete From #TmpConso
			end
		if (@iMonthFirst=6)
			begin
				insert into #ESMeses (codigo,nombre,junio)
					select codigo,nombre, sv from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						--set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
						set @Tc = (select dbo.ObtenerTcOficial(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,junio,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
				--delete From #TmpConso
			end
		if (@iMonthFirst=7)
			begin
				insert into #ESMeses (codigo,nombre,julio)
					select codigo,nombre, sv from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						--set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
						set @Tc = (select dbo.ObtenerTcOficial(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,julio,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
				--delete From #TmpConso
			end
		if (@iMonthFirst=8)
			begin
				insert into #ESMeses (codigo,nombre,agosto)
					select codigo,nombre, sv from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						--set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
						set @Tc = (select dbo.ObtenerTcOficial(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,agosto,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
				--delete From #TmpConso
			end
		if (@iMonthFirst=9)
			begin
				insert into #ESMeses (codigo,nombre,septiembre)
					select codigo,nombre, sv from #Tmp where codigo is not null
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
					select codigo,nombre, sv from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						--set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
						set @Tc = (select dbo.ObtenerTcOficial(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,octubre,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
				---delete From #TmpConso
			end
		if (@iMonthFirst=11)
			begin
				insert into #ESMeses (codigo,nombre,noviembre)
					select codigo,nombre, sv from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						--set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
						set @Tc = (select dbo.ObtenerTcOficial(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,noviembre,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
				--delete From #TmpConso
			end
		if (@iMonthFirst=12)
			begin
				insert into #ESMeses (codigo,nombre,diciembre)
					select codigo,nombre, sv from #Tmp where codigo is not null
				if (@Tc is null) or (@Tc <>1)
					begin
						--set @Tc = (select dbo.GetTCCountries(@DBPais,@dFechaFin))
						set @Tc = (select dbo.ObtenerTcOficial(@DBPais,@dFechaFin))
					end
				insert into #ESMeses (nombre,diciembre,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				delete from #Tmp
				--delete From #TmpConso
			end
		set @dFechaIni = convert(char(10),DateAdd(ms,-1,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'
		set @dFechaFin = convert(char(10),DateAdd(ms,-2,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'
		set @iMonthFirst = @iMonthFirst + 1
	end

insert into #ESMeses
select codigo,nombre,isnull(sum(enero),0),isnull(sum(febrero),0),isnull(sum(marzo),0),isnull(sum(abril),0),
		isnull(sum(mayo),0),isnull(sum(junio),0),isnull(sum(julio),0),isnull(sum(agosto),0),
		isnull(sum(septiembre),0),isnull(sum(octubre),0),isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,
		'I4101' as TipoCol
from #ESMeses
where codigo like '4101%'
group by codigo,nombre
---- inserto total de ingresos de productos 
insert into #ESMeses 
			select '' as codigo,'  TOTAL  ' as nombre,isnull(sum(enero),0),isnull(sum(febrero),0),isnull(sum(marzo),0),
					isnull(sum(abril),0),isnull(sum(mayo),0),isnull(sum(junio),0),
					isnull(sum(julio),0),isnull(sum(agosto),0),isnull(sum(septiembre),0),isnull(sum(octubre),0),
					isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,'T4101' as TipoCol
			from   #ESMeses
			where TipoCol = 'I4101'
---- inserto ingresos por servicios
insert into #ESMeses
select codigo,nombre,isnull(sum(enero),0),isnull(sum(febrero),0),isnull(sum(marzo),0),
		isnull(sum(abril),0),isnull(sum(mayo),0),isnull(sum(junio),0),isnull(sum(julio),0),
		isnull(sum(agosto),0),isnull(sum(septiembre),0),isnull(sum(octubre),0),isnull(sum(noviembre),0),
		isnull(sum(diciembre),0),0,'I4102' as TipoCol
from #ESMeses
where codigo like '4102%'
group by codigo,nombre

insert into #ESMeses
		select '' as codigo,'  TOTAL  ' as nombre,isnull(sum(enero),0),isnull(sum(febrero),0),isnull(sum(marzo),0),
				isnull(sum(abril),0),isnull(sum(mayo),0),isnull(sum(junio),0),isnull(sum(julio),0),isnull(sum(agosto),0),
				isnull(sum(septiembre),0),isnull(sum(octubre),0),isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,
				'T4102' as TipoCol
		from   #ESMeses
		where TipoCol = 'I4102'
		group by left(codigo,4)
----
----inserto ingresos por prestación de servicios
insert into #ESMeses
select codigo,nombre,isnull(sum(enero),0),isnull(sum(febrero),0),isnull(sum(marzo),0),isnull(sum(abril),0),
		isnull(sum(mayo),0),isnull(sum(junio),0),isnull(sum(julio),0),isnull(sum(agosto),0),isnull(sum(septiembre),0),
		isnull(sum(octubre),0),isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,'I4103' as TipoCol
from #ESMeses
where codigo like '4103%'
group by codigo,nombre
-- inserto total de ingresos financieros
insert into #ESMeses
select '' as codigo,'  TOTAL  ' as nombre,isnull(sum(enero),0),isnull(sum(febrero),0),isnull(sum(marzo),0),
		isnull(sum(abril),0),isnull(sum(mayo),0),isnull(sum(junio),0),isnull(sum(julio),0),isnull(sum(agosto),0),
		isnull(sum(septiembre),0),isnull(sum(octubre),0),isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,
		'T4103' as TipoCol
from   #ESMeses
where TipoCol = 'I4103'
group by left(codigo,4)
---- Ingresos no operacionales
if ((select count(codigo)
		from #ESMeses
		where codigo like '4104%') >0) 
	begin
		insert into #ESMeses
		select codigo,nombre,isnull(sum(enero),0),isnull(sum(febrero),0),isnull(sum(marzo),0),
				isnull(sum(abril),0),isnull(sum(mayo),0),isnull(sum(junio),0),isnull(sum(julio),0),isnull(sum(agosto),0),
				isnull(sum(septiembre),0),isnull(sum(octubre),0),isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,
				'I4104' as TipoCol
		from #ESMeses
		where codigo like '4104%'
		group by codigo,nombre
	end
	-- inserto total 
	insert into #ESMeses 
			select '' as codigo,'  TOTAL  ' as nombre,isnull(sum(enero),0),isnull(sum(febrero),0),isnull(sum(marzo),0),
					isnull(sum(abril),0),isnull(sum(mayo),0),isnull(sum(junio),0),isnull(sum(julio),0),
					isnull(sum(agosto),0),isnull(sum(septiembre),0),isnull(sum(octubre),0),
					isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,'T4104' as TipoCol
			from   #ESMeses
			where TipoCol = 'I4104'
	--

-- inserto las devoluciones y rebajas sobre ventas
if ((select count(codigo)
		from #ESMeses
		where codigo like '6104%') >0) 
	begin
		insert into #ESMeses (codigo,nombre) values ('','	REBAJAS Y DEVOLUCIONES SOBRE VENTAS		')
		insert into #ESMeses
		select codigo,nombre,sum(enero) ,sum(febrero) ,sum(marzo) ,sum(abril),sum(mayo),sum(junio),sum(julio),
				sum(agosto),sum(septiembre),sum(octubre),sum(noviembre),sum(diciembre) ,0,'I6104' as TipoCol
		from #ESMeses
		where codigo like '6104%'
		group by codigo,nombre
		-- total de devoluciones y rebajas sobre ventas
		insert into #ESMeses
					select '' as codigo,'  TOTAL  ' as nombre,sum(enero),sum(febrero),sum(marzo),sum(abril),sum(mayo),
							sum(junio),sum(julio),sum(agosto),sum(septiembre),sum(octubre),sum(noviembre),
							sum(diciembre),0,'T6104' as TipoCol
					from   #ESMeses
					where TipoCol =  'I6104'
	end
---- insertando total de los ingresos
insert into #ESMeses
			select '' as codigo,'  TOTAL  INGRESOS ' as nombre,isnull(sum(enero),0),isnull(sum(febrero),0),
					isnull(sum(marzo),0),isnull(sum(abril),0),isnull(sum(mayo),0),isnull(sum(junio),0),
					isnull(sum(julio),0),isnull(sum(agosto),0),isnull(sum(septiembre),0),isnull(sum(octubre),0),
					isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,'TI' as TipoCol
			from   #ESMeses
			where TipoCol in ('I4101','I4102','I4103','I4104','I6104')
---- Insertando Costos de Venta
if ((select count(codigo)
		from #ESMeses
		where codigo like '51%') >0) 
	begin	
		insert into #ESMeses
		select codigo,nombre,isnull(sum(enero),0)*-1,isnull(sum(febrero),0)*-1,isnull(sum(marzo),0)*-1,
				isnull(sum(abril),0)*-1 ,isnull(sum(mayo),0)*-1,isnull(sum(junio),0)*-1,
				isnull(sum(julio),0)*-1,isnull(sum(agosto),0)*-1,isnull(sum(septiembre),0)*-1,
				isnull(sum(octubre),0)*-1,isnull(sum(noviembre),0)*-1,isnull(sum(diciembre),0)*-1,0,
				'C5101' as TipoCol
		from #ESMeses
		where codigo like '5101%'
		group by codigo,nombre
		order by codigo
		-- Total de Costo de Venta por Productos 
		insert into #ESMeses 
		select ' ' as codigo,'  TOTAL COSTO DE VENTA POR PRODUCTOS ' as nombre,isnull(sum(enero),0),
				isnull(sum(febrero),0),isnull(sum(marzo),0),
				isnull(sum(abril),0) ,isnull(sum(mayo),0),isnull(sum(junio),0),
				isnull(sum(julio),0),isnull(sum(agosto),0),isnull(sum(septiembre),0),
				isnull(sum(octubre),0),isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,
				'T5101' as TipoCol
		from #ESMeses
		where TipoCol = 'C5101'
		group by left(codigo,4)
		-- Costo de Ventas por Servicios
		insert into #ESMeses
		select codigo,nombre,isnull(sum(enero),0)*-1,isnull(sum(febrero),0)*-1,isnull(sum(marzo),0)*-1,
				isnull(sum(abril),0)*-1 ,isnull(sum(mayo),0)*-1,isnull(sum(junio),0)*-1,isnull(sum(julio),0)*-1,
				isnull(sum(agosto),0)*-1,isnull(sum(septiembre),0)*-1,isnull(sum(octubre),0),
				isnull(sum(noviembre),0)*-1,isnull(sum(diciembre),0)*-1,0,'C5201' as TipoCol
		from #ESMeses
		where codigo like '5201%'
		group by codigo,nombre
		-- Total Costo de Venta por servicios
		insert into #ESMeses 
		select ' ' as codigo,'  TOTAL COSTO DE VENTA POR SERVICIOS ' as nombre,isnull(sum(enero),0),
				isnull(sum(febrero),0),isnull(sum(marzo),0),
				isnull(sum(abril),0) ,isnull(sum(mayo),0),isnull(sum(junio),0),
				isnull(sum(julio),0),isnull(sum(agosto),0),isnull(sum(septiembre),0),
				isnull(sum(octubre),0),isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,
				'T5201' as TipoCol
		from #ESMeses
		where TipoCol = 'C5201'
		group by left(codigo,4)
		-- Insertando total de Costo de Ventas
		insert into #ESMeses
					select '' as codigo,'  TOTAL COSTO DE VENTAS ' as nombre,isnull(sum(enero),0),isnull(sum(febrero),0),
							isnull(sum(marzo),0),isnull(sum(abril),0),isnull(sum(mayo),0),isnull(sum(junio),0),
							isnull(sum(julio),0),isnull(sum(agosto),0),isnull(sum(septiembre),0),isnull(sum(octubre),0),
							isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,'TC' as TipoCol
					from   #ESMeses
					where TipoCol in ('C5101','C5201')
	end
-- Insertando utilidad bruta
insert into #ESMeses
			select codigo,nombre,sum(enero),sum(febrero),sum(marzo),sum(abril),sum(mayo),sum(junio),
					sum(julio),sum(agosto),sum(septiembre),sum(octubre),sum(noviembre),sum(diciembre),sum(total),TipoCol
			from 
				(
					select '' as codigo,'  UTILIDAD BRUTA ' as nombre,
						case TipoCol
							when 'TI' then isnull(sum(enero),0) else isnull(sum(enero),0) *-1 end as enero,
						case TipoCol 
							when 'TI' then isnull(sum(febrero),0) else isnull(sum(febrero),0)*-1 end as febrero,
						case TipoCol
							when 'TI' then isnull(sum(marzo),0) else isnull(sum(marzo),0)*-1 end as marzo,
						case TipoCol
							when 'TI' then isnull(sum(abril),0) else isnull(sum(abril),0)*-1 end as abril,
						case TipoCol
							when 'TI' then isnull(sum(mayo),0) else isnull(sum(mayo),0)*-1 end as mayo,
						case TipoCol
							when 'TI' then isnull(sum(junio),0) else isnull(sum(junio),0)*-1 end as junio,
						case TipoCol
							when 'TI' then isnull(sum(julio),0) else isnull(sum(julio),0)*-1 end as julio,
						case TipoCol
							when 'TI' then isnull(sum(agosto),0) else isnull(sum(agosto),0)*-1 end as agosto,
						case TipoCol
							when 'TI' then isnull(sum(septiembre),0) else isnull(sum(septiembre),0)*-1 end as septiembre,
						case TipoCol
							when 'TI' then isnull(sum(octubre),0) else isnull(sum(octubre),0)*-1 end as octubre,
						case TipoCol
							when 'TI' then isnull(sum(noviembre),0) else isnull(sum(noviembre),0)  *-1 end as noviembre,
						case TipoCol
							when 'TI' then isnull(sum(diciembre),0) else isnull(sum(diciembre),0)  *-1 end as diciembre,
						0 as total,'UB' as TipoCol
					from   #ESMeses
					where TipoCol in ('TI','TC')
					group by Tipocol
				) T0
			group by T0.codigo,T0.nombre,T0.TipoCol
---- Insertando Gastos Operativos
insert into #ESMeses 
select codigo,nombre,isnull(sum(enero),0)*-1,isnull(sum(febrero),0)*-1 ,isnull(sum(marzo),0)*-1,
		isnull(sum(abril),0)*-1,isnull(sum(mayo),0)*-1,isnull(sum(junio),0)*-1,isnull(sum(julio),0)*-1,
		isnull(sum(agosto),0)*-1,isnull(sum(septiembre),0)*-1,isnull(sum(octubre),0)*-1,isnull(sum(noviembre),0)*-1,
		isnull(sum(diciembre),0)*-1,0,'G6101' as TipoCol
from #ESMeses
where codigo like '6101%' AND codigo NOT LIKE '6104%'
group by codigo,nombre
order by codigo
if (@nNivel<>3)
	begin
		insert into #ESMeses (codigo,nombre,enero,febrero,marzo,abril,mayo,junio,julio,agosto,septiembre,octubre,noviembre,diciembre,total,TipoCol) 
				select '', 'TOTAL GASTOS DE ADMINISTRACION',isnull(sum(enero),0),isnull(sum(febrero),0),
						isnull(sum(marzo),0),isnull(sum(abril),0),isnull(sum(mayo),0),
						isnull(sum(junio),0),isnull(sum(julio),0),isnull(sum(agosto),0),isnull(sum(septiembre),0),
						isnull(sum(octubre),0),isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,
						'T6101'
				from #ESMeses
				where TipoCol = 'G6101'
				group by left(codigo,4)
	end
--/* GASTOS DE VENTA */ 
insert into #ESMeses
select codigo,nombre,isnull(sum(enero),0)*-1,isnull(sum(febrero),0)*-1,isnull(sum(marzo),0)*-1,
		isnull(sum(abril),0)*-1,isnull(sum(mayo),0)*-1,isnull(sum(junio),0)*-1,isnull(sum(julio),0)*-1,isnull(sum(agosto),0)*-1,
		isnull(sum(septiembre),0)*-1,isnull(sum(octubre),0)*-1,isnull(sum(noviembre),0)*-1,
		isnull(sum(diciembre),0)*-1,0,'G6102' as TipoCol
from #ESMeses
where codigo like '6102%' AND codigo NOT LIKE '6104%'
group by codigo,nombre
order by codigo

if (@nNivel<>3)
	begin
		insert into #ESMeses (codigo,nombre,enero,febrero,marzo,abril,mayo,junio,julio,agosto,septiembre,octubre,noviembre,diciembre,total,TipoCol) 
				select '', 'TOTAL GASTOS DE VENTA',isnull(sum(enero),0),isnull(sum(febrero),0),
						isnull(sum(marzo),0),isnull(sum(abril),0),isnull(sum(mayo),0),isnull(sum(junio),0),
						isnull(sum(julio),0),isnull(sum(agosto),0),isnull(sum(septiembre),0),
						isnull(sum(octubre),0),isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,
						'T6102' as TipoCol
				from #ESMeses
				where TipoCol = 'G6102'
				group by left(codigo,4)
	end
--/* GASTOS FINANCIEROS */
insert into #ESMeses 
select codigo,nombre,isnull(sum(enero),0)*-1 ,isnull(sum(febrero),0)*-1,isnull(sum(marzo),0)*-1,isnull(sum(abril),0)*-1,isnull(sum(mayo),0)*-1,
		isnull(sum(junio),0)*-1,isnull(sum(julio),0)*-1,isnull(sum(agosto),0)*-1,isnull(sum(septiembre),0)*-1,
		isnull(sum(octubre),0)*-1,isnull(sum(noviembre),0)*-1,isnull(sum(diciembre),0)*-1,0,'G6103' as TipoCol
from #ESMeses
where codigo like '6103%' AND codigo NOT LIKE '6104%'
group by codigo,nombre

if (@nNivel<>3)
	begin
		insert into #ESMeses (codigo,nombre,enero,febrero,marzo,abril,mayo,junio,julio,agosto,septiembre,octubre,noviembre,diciembre,total,TipoCol) 
				select '', 'TOTAL GASTOS FINANCIEROS',isnull(sum(enero),0),isnull(sum(febrero),0),
						isnull(sum(marzo),0),isnull(sum(abril),0),isnull(sum(mayo),0),
						isnull(sum(junio),0),isnull(sum(julio),0),isnull(sum(agosto),0),isnull(sum(septiembre),0),
						isnull(sum(octubre),0),isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,
						'T6103' as TipoCol
				from #ESMeses
				where TipoCol = 'G6103'
				group by left(codigo,4)
	end
--/* GASTOS MISCELANEOS */
--select count(codigo)
--		from #ESMeses
--		where codigo like '6105%'

if ((select count(codigo)
		from #ESMeses
		where codigo like '6105%') >0) 
	begin
		insert into #ESMeses 
		select codigo,nombre,isnull(sum(enero),0)*-1 ,isnull(sum(febrero),0)*-1,isnull(sum(marzo),0)*-1,isnull(sum(abril),0)*-1,isnull(sum(mayo),0)*-1,
				isnull(sum(junio),0)*-1,isnull(sum(julio),0)*-1,isnull(sum(agosto),0)*-1,isnull(sum(septiembre),0)*-1,
				isnull(sum(octubre),0)*-1,isnull(sum(noviembre),0)*-1,isnull(sum(diciembre),0)*-1,0,'G6105' as TipoCol
		from #ESMeses
		where codigo like '6105%' AND codigo NOT LIKE '6104%'
		group by codigo,nombre

		if (@nNivel<>3)
			begin
				insert into #ESMeses  
						select '', 'TOTAL GASTOS MISCELANEOS',isnull(sum(enero),0),isnull(sum(febrero),0),
								isnull(sum(marzo),0),isnull(sum(abril),0),isnull(sum(mayo),0),
								isnull(sum(junio),0),isnull(sum(julio),0),isnull(sum(agosto),0),isnull(sum(septiembre),0),
								isnull(sum(octubre),0),isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,'T6105'
						from #ESMeses
						where TipoCol = 'G6105'
						group by left(codigo,4)
			end
	end

-- Insertando Gastos de No operación

if ((select count(codigo)
	from #ESMeses
	where codigo like '62%') >0) 
	begin
		insert into #ESMeses
			select codigo,nombre,isnull(sum(enero),0)*-1,isnull(sum(febrero),0)*-1,isnull(sum(marzo),0)*-1,
					isnull(sum(abril),0)*-1,isnull(sum(mayo),0)*-1,isnull(sum(junio),0)*-1,
					isnull(sum(julio),0)*-1,isnull(sum(agosto),0)*-1,isnull(sum(septiembre),0)*-1,
					isnull(sum(octubre),0)*-1,isnull(sum(noviembre),0)*-1,isnull(sum(diciembre),0)*-1,0,
					'G6201' as TipoCol
			from #ESMeses
			where codigo like '62%' AND codigo NOT LIKE '6104%'
			group by codigo,nombre
		insert into #ESMeses
				select '' as codigo,'  TOTAL GASTOS DE NO OPERACION ' as nombre,isnull(sum(enero),0)*-1,
					isnull(sum(febrero),0)*-1,isnull(sum(marzo),0)*-1,isnull(sum(abril)*-1,0),
						isnull(sum(mayo),0)*-1,isnull(sum(junio),0)*-1,isnull(sum(julio),0)*-1,
						isnull(sum(agosto),0)*-1,isnull(sum(septiembre),0)*-1,isnull(sum(octubre),0)*-1,
						isnull(sum(noviembre),0)*-1,isnull(sum(diciembre),0)*-1,0,'T6201' as TipoCol
				from  #ESMeses
				where TipoCol = 'G6201'
	end

-- Inserto total de Gastos

insert into #ESMeses
		select '' as codigo,'	TOTAL GASTOS	' as nombre,isnull(sum(enero),0),isnull(sum(febrero),0),
				isnull(sum(marzo),0),isnull(sum(abril),0),isnull(sum(mayo),0),isnull(sum(junio),0),
				isnull(sum(julio),0),isnull(sum(agosto),0),isnull(sum(septiembre),0),isnull(sum(octubre),0),
				isnull(sum(noviembre),0),isnull(sum(diciembre),0),0,'TG' as TipoCol
		from  #ESMeses
		where TipoCol in ('G6101','G6102','G6103','G6105','G6201')

-- Insertando utilidad antes de impuestos
insert into #ESMeses 
select codigo,nombre,sum(enero),sum(febrero),sum(marzo),sum(abril),sum(mayo),sum(junio),sum(julio),sum(agosto),
		sum(septiembre),sum(octubre),sum(noviembre),sum(diciembre),0,TipoCol
from (
		select '' as codigo,'  UTILIDAD AI ' as nombre,
			case TipoCol
				when 'UB' then isnull(sum(enero),0) else isnull(sum(enero),0) *-1 end as enero,
			case TipoCol
				when 'UB' then isnull(sum(febrero),0) else isnull(sum(febrero)  ,0) *-1 end as febrero,
			case TipoCol
				when 'UB' then isnull(sum(marzo),0) else isnull(sum(marzo),0) *-1 end as marzo,
			case TipoCol
				when 'UB' then isnull(sum(abril),0) else isnull(sum(abril),0) *-1 end as abril,
			case TipoCol
				when 'UB' then isnull(sum(mayo),0) else isnull(sum(mayo),0) *-1 end as mayo,
			case TipoCol
				when 'UB' then isnull(sum(junio),0) else isnull(sum(junio),0) *-1 end as junio,
			case TipoCol
				when 'UB' then isnull(sum(julio),0) else isnull(sum(julio),0) *-1 end as julio,
			case TipoCol
				when 'UB' then isnull(sum(agosto),0) else isnull(sum(agosto),0) *-1 end as agosto,
			case TipoCol
				when 'UB' then isnull(sum(septiembre),0) else isnull(sum(septiembre),0) *-1 end as septiembre,
			case TipoCol
				when 'UB' then isnull(sum(octubre),0) else isnull(sum(octubre),0) *-1 end as octubre,
			case TipoCol
				when 'UB' then isnull(sum(noviembre),0) else isnull(sum(noviembre),0) *-1 end as noviembre,
			case TipoCol
				when 'UB' then isnull(sum(diciembre),0) else isnull(sum(diciembre),0) *-1 end as diciembre,
			0 as Total,	'UI' as TipoCol
		from   #ESMeses
		where TipoCol IN ('UB','TG')
		group by TipoCol
	) T0
group by t0.codigo,t0.nombre,t0.TipoCol

-- Inserto el tipo de Cambio utilizado en el proceso

insert into #ESMeses 
		select '','Tipo de Cambio' , isnull(sum(enero),0),sum(isnull(febrero,0)),isnull(sum(marzo),0),
			isnull(sum(abril),0),isnull(sum(mayo),0),sum(junio),sum(julio),
			sum(agosto),sum(septiembre),sum(octubre),sum(noviembre),sum(diciembre),0,'TTC'
		from #ESMeses where TipoCol = 'TT'
		

update #ESMeses set total = (isnull(enero,0)+isnull(febrero,0)+isnull(marzo,0)+isnull(abril,0)+isnull(mayo,0) +isnull(junio,0) +
							isnull(julio,0)+isnull(agosto,0)+isnull(septiembre,0)+isnull(octubre,0)+isnull(noviembre,0)+
							isnull(diciembre,0)) where TipoCol <> 'TTC'


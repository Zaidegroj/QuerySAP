set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER procedure [dbo].[EstadoResultadoRealvrsPresupuesto] (@DBPais as varchar(4),
										@dFechaIni as datetime,
										@dFechaFin as datetime,
										@dFechaIniAcum as datetime,
										@nNivel as int,
										@Tc as numeric(18,2) = null )

as 

declare @iMonthFirst int,
		@iMonthLast int,
		@iFlag int,
		@dFechaIniReal datetime,
		@dFechaFinReal datetime,
		@nYear numeric(4,0)

--
set @nYear = year(getdate())
set @dFechaIniReal	= @dFechaIni
set @dFechaFinReal	= @dFechaFin
--
set @dFechaIni		= '01/01/'+convert(char(4),@nYear)
set @dFechaFin		= '12/31/'+convert(char(4),@nYear)
--
set @iMonthFirst	= 1  --month(@dFechaIni)
set @iMonthLast		= 12 --month(@dFechaFin)
--
set @iFlag			= 1
set @dFechaIni		= convert(char(10),@dFechaIni,121)+' 00:00:00'
set @dFechaFin		= convert(char(10),DateAdd(ms,-2,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'

while (@iMonthFirst <=@iMonthLast)
	begin
		exec EstResulConsolRealvrsPresupAnual @DBPais , @dFechaIni , @dFechaFin, @dFechaIniAcum,@nNivel ---,@Tc

		if (@iMonthFirst=1)
			begin
				--set @Tc  = (select dbo.GetTCCountries(@DBPais,'01/31/'+convert(char(4),@nYear)))
				-- si no encuentra el tipo de cambio entonces se va a la tabla de usuario
				-- que se creó para controlar los tipos de cambio de fechas que no existen aún
				-- procesadas en SAP
				set @Tc = (dbo.ObtenerTCOficial(@DBPais,'01/31/'+convert(char(4),@nYear)))
				-- si en ninguna de las dos tablas se encuentra el tipo de cambio
				-- entonces asignamos el valor de uno para que use el valor de la moneda local
				if (@Tc is null)
					begin
						set @Tc = 1 
					end
				insert into #ESMeses (nombre,Enero,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				--
				insert into #ESMeses (codigo,nombre,enero,Enero_Presup)
					select codigo,nombre, round(sv/@Tc,2),round(presup_Mens/@Tc,2) from #Tmp where codigo is not null
				delete from #Tmp
			end
		if (@iMonthFirst=2)
			begin
				--set @Tc  = (select dbo.GetTCCountries(@DBPais,'02/28/'+convert(char(4),@nYear)))
				-- si no encuentra el tipo de cambio entonces se va a la tabla de usuario
				-- que se creó para controlar los tipos de cambio de fechas que no existen aún
				-- procesadas en SAP
				set @Tc = (dbo.ObtenerTCOficial(@DBPais,'02/28/'+convert(char(4),@nYear)))
				-- si en ninguna de las dos tablas se encuentra el tipo de cambio
				-- entonces asignamos el valor de uno para que use el valor de la moneda local
				if (@Tc is null)
					begin
						set @Tc = 1 
					end
				insert into #ESMeses (nombre,Febrero,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				--
				insert into #ESMeses (codigo,nombre,Febrero,Febrero_Presup)
					select codigo,nombre, round(sv/@Tc,2),round(presup_Mens/@Tc,2) from #Tmp where codigo is not null
				delete from #Tmp
			end
		if (@iMonthFirst=3)
			begin
				--set @Tc  = (select dbo.GetTCCountries(@DBPais,'03/31/'+convert(char(4),@nYear)))
				-- si no encuentra el tipo de cambio entonces se va a la tabla de usuario
				-- que se creó para controlar los tipos de cambio de fechas que no existen aún
				-- procesadas en SAP
				set @Tc = (dbo.ObtenerTCOficial(@DBPais,'03/31/'+convert(char(4),@nYear)))
				-- si en ninguna de las dos tablas se encuentra el tipo de cambio
				-- entonces asignamos el valor de uno para que use el valor de la moneda local
				if (@Tc is null)
					begin
						set @Tc = 1 
					end
				insert into #ESMeses (nombre,Marzo,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				--
				insert into #ESMeses (codigo,nombre,Marzo,Marzo_Presup)
					select codigo,nombre, round(sv/@Tc,2),round(presup_Mens/@Tc,2) from #Tmp where codigo is not null
				delete from #Tmp
			end
		if (@iMonthFirst=4)
			begin
				--set @Tc  = (select dbo.GetTCCountries(@DBPais,'04/30/'+convert(char(4),@nYear)))
				-- si no encuentra el tipo de cambio entonces se va a la tabla de usuario
				-- que se creó para controlar los tipos de cambio de fechas que no existen aún
				-- procesadas en SAP
				set @Tc = (dbo.ObtenerTCOficial(@DBPais,'04/30/'+convert(char(4),@nYear)))
				-- si en ninguna de las dos tablas se encuentra el tipo de cambio
				-- entonces asignamos el valor de uno para que use el valor de la moneda local
				if (@Tc is null)
					begin
						set @Tc = 1 
					end
				insert into #ESMeses (nombre,Abril,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				--
				insert into #ESMeses (codigo,nombre,Abril,Abril_Presup)
					select codigo,nombre, round(sv/@Tc,2),round(presup_Mens/@Tc,2) from #Tmp where codigo is not null
				delete from #Tmp
			end
		if (@iMonthFirst=5)
			begin
				--set @Tc  = (select dbo.GetTCCountries(@DBPais,'05/31/'+convert(char(4),@nYear)))
				-- si no encuentra el tipo de cambio entonces se va a la tabla de usuario
				-- que se creó para controlar los tipos de cambio de fechas que no existen aún
				-- procesadas en SAP
				set @Tc = (dbo.ObtenerTCOficial(@DBPais,'05/31/'+convert(char(4),@nYear)))
				-- si en ninguna de las dos tablas se encuentra el tipo de cambio
				-- entonces asignamos el valor de uno para que use el valor de la moneda local
				if (@Tc is null)
					begin
						set @Tc = 1 
					end
				insert into #ESMeses (nombre,Mayo,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				--
				insert into #ESMeses (codigo,nombre,Mayo,Mayo_Presup)
					select codigo,nombre, round(sv/@Tc,2),round(presup_Mens/@Tc,2) from #Tmp where codigo is not null
				delete from #Tmp
			end
		if (@iMonthFirst=6)
			begin
				--set @Tc  = (select dbo.GetTCCountries(@DBPais,'06/30/'+convert(char(4),@nYear)))
				-- si no encuentra el tipo de cambio entonces se va a la tabla de usuario
				-- que se creó para controlar los tipos de cambio de fechas que no existen aún
				-- procesadas en SAP
				set @Tc = (dbo.ObtenerTCOficial(@DBPais,'06/30/'+convert(char(4),@nYear)))
				-- si en ninguna de las dos tablas se encuentra el tipo de cambio
				-- entonces asignamos el valor de uno para que use el valor de la moneda local
				if (@Tc is null)
					begin
						set @Tc = 1 
					end
				insert into #ESMeses (nombre,Junio,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				--
				insert into #ESMeses (codigo,nombre,Junio,Junio_Presup)
					select codigo,nombre, round(sv/@Tc,2),round(presup_Mens/@Tc,2) from #Tmp where codigo is not null
				delete from #Tmp
			end
		if (@iMonthFirst=7)
			begin
				--set @Tc  = (select dbo.GetTCCountries(@DBPais,'07/31/'+convert(char(4),@nYear)))
				-- si no encuentra el tipo de cambio entonces se va a la tabla de usuario
				-- que se creó para controlar los tipos de cambio de fechas que no existen aún
				-- procesadas en SAP
				set @Tc = (dbo.ObtenerTCOficial(@DBPais,'07/31/'+convert(char(4),@nYear)))
				-- si en ninguna de las dos tablas se encuentra el tipo de cambio
				-- entonces asignamos el valor de uno para que use el valor de la moneda local
				if (@Tc is null)
					begin
						set @Tc = 1 
					end
				insert into #ESMeses (nombre,Julio,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				--
				insert into #ESMeses (codigo,nombre,Julio,Julio_Presup)
					select codigo,nombre, round(sv/@Tc,2),round(presup_Mens/@Tc,2) from #Tmp where codigo is not null
				delete from #Tmp
			end
		if (@iMonthFirst=8)
			begin
				--set @Tc  = (select dbo.GetTCCountries(@DBPais,'08/31/'+convert(char(4),@nYear)))
				-- si no encuentra el tipo de cambio entonces se va a la tabla de usuario
				-- que se creó para controlar los tipos de cambio de fechas que no existen aún
				-- procesadas en SAP
				set @Tc = (dbo.ObtenerTCOficial(@DBPais,'08/31/'+convert(char(4),@nYear)))
				-- si en ninguna de las dos tablas se encuentra el tipo de cambio
				-- entonces asignamos el valor de uno para que use el valor de la moneda local
				if (@Tc is null)
					begin
						set @Tc = 1 
					end
				insert into #ESMeses (nombre,Agosto,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				--
				insert into #ESMeses (codigo,nombre,Agosto,Agosto_Presup)
					select codigo,nombre, round(sv/@Tc,2),round(presup_Mens/@Tc,2) from #Tmp where codigo is not null
				delete from #Tmp
			end
		if (@iMonthFirst=9)
			begin
				--set @Tc  = (select dbo.GetTCCountries(@DBPais,'09/30/'+convert(char(4),@nYear)))
				-- si no encuentra el tipo de cambio entonces se va a la tabla de usuario
				-- que se creó para controlar los tipos de cambio de fechas que no existen aún
				-- procesadas en SAP
				set @Tc = (dbo.ObtenerTCOficial(@DBPais,'09/30/'+convert(char(4),@nYear)))
				-- si en ninguna de las dos tablas se encuentra el tipo de cambio
				-- entonces asignamos el valor de uno para que use el valor de la moneda local
				if (@Tc is null)
					begin
						set @Tc = 1 
					end
				insert into #ESMeses (nombre,Septiembre,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				--
				insert into #ESMeses (codigo,nombre,Septiembre,Septiembre_Presup)
					select codigo,nombre, round(sv/@Tc,2),round(presup_Mens/@Tc,2) from #Tmp where codigo is not null
				delete from #Tmp
			end
		if (@iMonthFirst=10)
			begin
				--set @Tc  = (select dbo.GetTCCountries(@DBPais,'10/31/'+convert(char(4),@nYear)))
				-- si no encuentra el tipo de cambio entonces se va a la tabla de usuario
				-- que se creó para controlar los tipos de cambio de fechas que no existen aún
				-- procesadas en SAP
				set @Tc = (dbo.ObtenerTCOficial(@DBPais,'10/31/'+convert(char(4),@nYear)))
				-- si en ninguna de las dos tablas se encuentra el tipo de cambio
				-- entonces asignamos el valor de uno para que use el valor de la moneda local
				if (@Tc is null)
					begin
						set @Tc = 1 
					end
				insert into #ESMeses (nombre,Octubre,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				--
				insert into #ESMeses (codigo,nombre,Octubre,Octubre_Presup)
					select codigo,nombre, round(sv/@Tc,2),round(presup_Mens/@Tc,2) from #Tmp where codigo is not null
				delete from #Tmp
			end
		if (@iMonthFirst=11)
			begin
				--set @Tc  = (select dbo.GetTCCountries(@DBPais,'11/30/'+convert(char(4),@nYear)))
				-- si no encuentra el tipo de cambio entonces se va a la tabla de usuario
				-- que se creó para controlar los tipos de cambio de fechas que no existen aún
				-- procesadas en SAP
				set @Tc = (dbo.ObtenerTCOficial(@DBPais,'11/30/'+convert(char(4),@nYear)))
				-- si en ninguna de las dos tablas se encuentra el tipo de cambio
				-- entonces asignamos el valor de uno para que use el valor de la moneda local
				if (@Tc is null)
					begin
						set @Tc = 1 
					end
				insert into #ESMeses (nombre,Noviembre,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				--
				insert into #ESMeses (codigo,nombre,Noviembre,Noviembre_Presup)
					select codigo,nombre, round(sv/@Tc,2),round(presup_Mens/@Tc,2) from #Tmp where codigo is not null
				delete from #Tmp
			end
		if (@iMonthFirst=12)
			begin
				--set @Tc  = (select dbo.GetTCCountries(@DBPais,'12/31/'+convert(char(4),@nYear)))
				-- si no encuentra el tipo de cambio entonces se va a la tabla de usuario
				-- que se creó para controlar los tipos de cambio de fechas que no existen aún
				-- procesadas en SAP
				set @Tc = (dbo.ObtenerTCOficial(@DBPais,'12/31/'+convert(char(4),@nYear)))
				-- si en ninguna de las dos tablas se encuentra el tipo de cambio
				-- entonces asignamos el valor de uno para que use el valor de la moneda local
				if (@Tc is null)
					begin
						set @Tc = 1 
					end
				insert into #ESMeses (nombre,Diciembre,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
				--
				insert into #ESMeses (codigo,nombre,Diciembre,Diciembre_Presup)
					select codigo,nombre, round(sv/@Tc,2),round(presup_Mens/@Tc,2) from #Tmp where codigo is not null
				delete from #Tmp
			end

		set @dFechaIni = convert(char(10),DateAdd(ms,-1,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'
		set @dFechaFin = convert(char(10),DateAdd(ms,-2,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'
		set @iMonthFirst = @iMonthFirst + 1
	end

-- Genero el total del presupuesto Anual

update #ESMeses set Presup_Anual = (Enero_Presup+Febrero_Presup+Marzo_Presup+Abril_Presup+Mayo_Presup+
										Junio_Presup+Julio_Presup+Agosto_Presup+Septiembre_Presup+Octubre_Presup+
										Noviembre_Presup+Diciembre_Presup)

-- Borro los meses que no se han solicitado en el informe, 
-- si el mes es diferente de Diciembre

set @iMonthLast = month(@dFechaFinReal)

if (@iMonthLast<12)
	begin
		set @dFechaIni		= convert(char(10),DATEADD(dd,1 , @dFechaFinReal),121)+' 00:00:00'
		set @iMonthFirst	= month(@dFechaIni)
		set @iMonthLast		= 12  --month(@dFechaFin)
		set @iFlag			= 1
		set @dFechaIni		= convert(char(10),@dFechaIni,121)+' 00:00:00'
		set @dFechaFin		= convert(char(10),DateAdd(ms,-2,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'
		
		while (@iMonthFirst <=@iMonthLast)
			begin
				print @dFechaIni
				print @dFechaFin
				if (@iMonthFirst=1)
					begin
						update #ESMeses set Enero=0,Enero_Presup = 0 
					end
				if (@iMonthFirst=2)
					begin
						update #ESMeses set Febrero=0,Febrero_Presup = 0
					end
				if (@iMonthFirst=3)
					begin
						update #ESMeses set Marzo=0,Marzo_Presup = 0
					end
				if (@iMonthFirst=4)
					begin
						update #ESMeses set Abril=0,Abril_Presup = 0
					end
				if (@iMonthFirst=5)
					begin
						update #ESMeses set Mayo=0,Mayo_Presup = 0
					end
				if (@iMonthFirst=6)
					begin
						update #ESMeses set Junio=0,Junio_Presup = 0
					end
				if (@iMonthFirst=7)
					begin
						update #ESMeses set Julio=0,Julio_Presup = 0
					end
				if (@iMonthFirst=8)
					begin
						update #ESMeses set Agosto=0,Agosto_Presup = 0
					end
				if (@iMonthFirst=9)
					begin
						update #ESMeses set Septiembre=0,Septiembre_Presup = 0
					end
				if (@iMonthFirst=10)
					begin
						update #ESMeses set Octubre=0,Octubre_Presup = 0
					end
				if (@iMonthFirst=11)
					begin
						update #ESMeses set Noviembre=0,Noviembre_Presup = 0
					end
				if (@iMonthFirst=12)
					begin
						update #ESMeses set Diciembre=0,Diciembre_Presup = 0
					end
				set @dFechaIni = convert(char(10),DateAdd(ms,-1,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'
				set @dFechaFin = convert(char(10),DateAdd(ms,-2,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'
				set @iMonthFirst = @iMonthFirst + 1
			end
	end

--
insert into #ESMeses
select codigo,nombre,sum(enero),sum(Enero_Presup),sum(febrero),sum(Febrero_Presup),sum(marzo),sum(Marzo_Presup),
		sum(abril),sum(Abril_Presup),sum(Mayo),sum(Mayo_Presup),sum(junio),sum(Junio_Presup),
		sum(julio),sum(Julio_Presup),sum(agosto),sum(Agosto_Presup),sum(septiembre),sum(Septiembre_Presup),
		sum(octubre),sum(Octubre_Presup),sum(noviembre),sum(Noviembre_Presup),sum(diciembre),sum(Diciembre_Presup),
		0,0,sum(Presup_Anual),'I4101' as TipoCol
from #ESMeses
where codigo like '4101%'
group by codigo,nombre
---- inserto total de ingresos de productos 
insert into #ESMeses 
			select '' as codigo,'  TOTAL  ' as nombre,sum(enero),sum(Enero_Presup),sum(febrero),
					sum(Febrero_Presup),sum(marzo),sum(Marzo_Presup),sum(abril),sum(Abril_Presup),
					sum(mayo),sum(Mayo_Presup),sum(junio),sum(Junio_Presup),sum(julio),sum(Julio_Presup),
					sum(agosto),sum(Agosto_Presup),sum(septiembre),sum(Septiembre_Presup),sum(octubre),
					sum(Octubre_Presup),sum(noviembre),sum(Noviembre_Presup),sum(diciembre),sum(Diciembre_Presup),
					0,0,sum(Presup_Anual),'T4101' as TipoCol
			from   #ESMeses
			where TipoCol = 'I4101'
---- inserto ingresos por servicios
insert into #ESMeses
select codigo,nombre,sum(enero),sum(Enero_Presup),sum(febrero),sum(Febrero_Presup),sum(marzo),sum(Marzo_Presup),
		sum(abril),sum(Abril_Presup),sum(mayo),sum(Mayo_Presup),sum(junio),sum(Junio_Presup),sum(julio),
		sum(Julio_Presup),sum(agosto),sum(Agosto_Presup),sum(septiembre),sum(Septiembre_Presup),sum(octubre),
		sum(Octubre_Presup),sum(noviembre),sum(Noviembre_Presup),sum(diciembre),sum(Diciembre_Presup),0,0,
		sum(Presup_Anual),'I4102' as TipoCol
from #ESMeses
where codigo like '4102%'
group by codigo,nombre

insert into #ESMeses
		select '' as codigo,'  TOTAL  ' as nombre,sum(enero),sum(Enero_Presup),sum(febrero),sum(Febrero_Presup),
				sum(marzo),sum(Marzo_Presup),sum(abril),sum(Abril_Presup),sum(mayo),sum(Mayo_Presup),
				sum(junio),sum(Junio_Presup),sum(julio),sum(Julio_Presup),sum(agosto),sum(Agosto_Presup),
				sum(septiembre),sum(Septiembre_Presup),sum(octubre),sum(Octubre_Presup),sum(noviembre),
				sum(Noviembre_Presup),sum(diciembre),sum(Diciembre_Presup),0,0,sum(Presup_Anual),'T4102' as TipoCol
		from   #ESMeses
		where TipoCol = 'I4102'
---		group by left(codigo,4)
----
----inserto ingresos por prestación de servicios
insert into #ESMeses
select codigo,nombre,sum(enero),sum(Enero_Presup),sum(febrero),sum(Febrero_Presup),sum(marzo),sum(Marzo_Presup),
		sum(abril),sum(Abril_Presup),sum(mayo),sum(Mayo_Presup),sum(junio),sum(Junio_Presup),sum(julio),
		sum(Julio_Presup),sum(agosto),sum(Agosto_Presup),sum(septiembre),sum(Septiembre_Presup),
		sum(octubre),sum(Octubre_Presup),sum(noviembre),sum(Noviembre_Presup),sum(diciembre),
		sum(Diciembre_Presup),0,0,sum(Presup_Anual),'I4103' as TipoCol
from #ESMeses
where codigo like '4103%'
group by codigo,nombre
-- inserto total de ingresos financieros
insert into #ESMeses
select '' as codigo,'  TOTAL  ' as nombre,sum(enero),sum(Enero_Presup),sum(febrero),sum(Febrero_Presup),
		sum(marzo),sum(Marzo_Presup),sum(abril),sum(Abril_Presup),sum(mayo),sum(Mayo_Presup),sum(junio),
		sum(Junio_Presup),sum(julio),sum(Julio_Presup),sum(agosto),sum(Agosto_Presup),sum(septiembre),
		sum(Septiembre_Presup),sum(octubre),sum(Octubre_Presup),sum(noviembre),sum(Noviembre_Presup),
		sum(diciembre),sum(Diciembre_Presup),0,0,sum(Presup_Anual),'T4103' as TipoCol
from   #ESMeses
where TipoCol = 'I4103'
--group by left(codigo,4)
---- Ingresos no operacionales
if ((select count(codigo)
		from #ESMeses
		where codigo like '4104%') >0) 
	begin
		insert into #ESMeses
		select codigo,nombre,sum(enero),sum(Enero_Presup),sum(febrero),sum(Febrero_Presup),sum(marzo),
				sum(Marzo_Presup),sum(abril),sum(Abril_Presup),sum(mayo),sum(Mayo_Presup),sum(junio),
				sum(Junio_Presup),sum(julio),sum(Julio_Presup),sum(agosto),sum(Agosto_Presup),sum(septiembre),
				sum(Septiembre_Presup),sum(octubre),sum(Octubre_Presup),sum(noviembre),sum(Noviembre_Presup),
				sum(diciembre),sum(Diciembre_Presup),0,0,sum(Presup_Anual),'I4104' as TipoCol
		from #ESMeses
		where codigo like '4104%'
		group by codigo,nombre
	end
	-- inserto total 
	insert into #ESMeses 
			select '' as codigo,'  TOTAL  ' as nombre,sum(enero),sum(Enero_Presup),sum(febrero),sum(Febrero_Presup),
					sum(marzo),sum(Marzo_Presup),sum(abril),sum(Abril_Presup),sum(mayo),sum(Mayo_Presup),
					sum(junio),sum(Junio_Presup),sum(julio),sum(Julio_Presup),sum(agosto),sum(Agosto_Presup),
					sum(septiembre),sum(Septiembre_Presup),sum(octubre),sum(Octubre_Presup),
					sum(noviembre),sum(Noviembre_Presup),sum(diciembre),sum(Diciembre_Presup),0,0,
					sum(Presup_Anual),'T4104' as TipoCol
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
		select codigo,nombre,sum(enero),sum(Enero_Presup),sum(febrero),sum(Febrero_Presup),sum(marzo),
				sum(Marzo_Presup),sum(abril),sum(Abril_Presup),sum(mayo),sum(Mayo_Presup),sum(junio),
				sum(Junio_Presup),sum(julio),sum(Julio_Presup),sum(agosto),sum(Agosto_Presup),
				sum(septiembre),sum(Septiembre_Presup),sum(octubre),sum(Octubre_Presup),sum(noviembre),
				sum(Noviembre_Presup),sum(diciembre),sum(Diciembre_Presup),0,0,sum(Presup_Anual),
				'I6104' as TipoCol
		from #ESMeses
		where codigo like '6104%'
		group by codigo,nombre
		-- total de devoluciones y rebajas sobre ventas
		insert into #ESMeses
					select '' as codigo,'  TOTAL  ' as nombre,sum(enero),sum(Enero_Presup),sum(febrero),
							sum(Febrero_Presup),sum(marzo),sum(Marzo_Presup),sum(abril),sum(Abril_Presup),
							sum(mayo),sum(Mayo_Presup),sum(junio),sum(Junio_Presup),sum(julio),sum(Julio_Presup),
							sum(agosto),sum(Agosto_Presup),sum(septiembre),sum(Septiembre_Presup),sum(octubre),
							sum(Octubre_Presup),sum(noviembre),sum(Noviembre_Presup),sum(diciembre),
							sum(Diciembre_Presup),0,0,sum(Presup_Anual),'T6104' as TipoCol
					from   #ESMeses
					where TipoCol =  'I6104'
	end
---- insertando total de los ingresos
insert into #ESMeses
			select '' as codigo,'  TOTAL  INGRESOS ' as nombre,sum(enero),sum(Enero_Presup),sum(febrero),
					sum(Febrero_Presup),sum(marzo),sum(Marzo_Presup),sum(abril),sum(Abril_Presup),sum(mayo),
					sum(Mayo_Presup),sum(junio),sum(Junio_Presup),sum(julio),sum(Julio_Presup),sum(agosto),
					sum(Agosto_Presup),sum(septiembre),sum(Septiembre_Presup),sum(octubre),sum(Octubre_Presup),
					sum(noviembre),sum(Noviembre_Presup),sum(diciembre),sum(Diciembre_Presup),0,0,
					sum(Presup_Anual),'TI' as TipoCol
			from   #ESMeses
			where TipoCol in ('I4101','I4102','I4103','I4104','I6104')
---- Insertando Costos de Venta
if ((select count(codigo)
		from #ESMeses
		where codigo like '51%') >0) 
	begin	
		insert into #ESMeses
		select codigo,nombre,sum(enero)*-1,sum(Enero_Presup)*-1,sum(febrero)*-1,sum(Febrero_Presup)*-1,sum(marzo)*-1,
				sum(Marzo_Presup)*-1,sum(abril)*-1 ,sum(Abril_Presup)*-1,sum(mayo)*-1,sum(Mayo_Presup)*-1,
				sum(junio)*-1,sum(Junio_Presup)*-1,sum(julio)*-1,sum(Julio_Presup)*-1,sum(agosto)*-1,sum(Agosto_Presup)*-1,
				sum(septiembre)*-1,sum(Septiembre_Presup)*-1,sum(octubre)*-1,sum(Octubre_Presup)*-1,
				sum(noviembre)*-1,sum(Noviembre_Presup)*-1,sum(diciembre)*-1,sum(Diciembre_Presup)*-1,0,0,
				sum(Presup_Anual)*-1,'C5101' as TipoCol
		from #ESMeses
		where codigo like '5101%'
		group by codigo,nombre
		order by codigo
		-- Total de Costo de Venta por Productos 
		insert into #ESMeses 
		select ' ' as codigo,'  TOTAL COSTO DE VENTA POR PRODUCTOS ' as nombre,sum(enero),sum(Enero_Presup),
				sum(febrero),sum(Febrero_Presup),sum(marzo),sum(Marzo_Presup),sum(abril),sum(Abril_Presup),
				sum(mayo),sum(Mayo_Presup),sum(junio),sum(Junio_Presup),sum(julio),sum(Julio_Presup),
				sum(agosto),sum(Agosto_Presup),sum(septiembre),sum(Septiembre_Presup),sum(octubre),
				sum(Octubre_Presup),sum(noviembre),sum(Noviembre_Presup),sum(diciembre),sum(Diciembre_Presup),0,0,
				sum(Presup_Anual),'T5101' as TipoCol
		from #ESMeses
		where TipoCol = 'C5101'
		group by left(codigo,4)
		-- Costo de Ventas por Servicios
		insert into #ESMeses
		select codigo,nombre,sum(enero)*-1,sum(Enero_Presup)*-1,sum(febrero)*-1,sum(Febrero_Presup)*-1,sum(marzo)*-1,
				sum(Marzo_Presup)*-1,sum(abril)*-1 ,sum(Abril_Presup)*-1,sum(mayo)*-1,sum(Mayo_Presup)*-1,
				sum(junio)*-1,sum(Junio_Presup)*-1,sum(julio)*-1,sum(Julio_Presup)*-1,sum(agosto)*-1,
				sum(Agosto_Presup)*-1,sum(septiembre)*-1,sum(Septiembre_Presup)*-1,sum(octubre)*-1,
				sum(Octubre_Presup)*-1,sum(noviembre)*-1,sum(Noviembre_Presup)*-1,sum(diciembre)*-1,
				sum(Diciembre_Presup)*-1,0,0,sum(Presup_Anual)*-1,'C5201' as TipoCol
		from #ESMeses
		where codigo like '5201%'
		group by codigo,nombre
		-- Total Costo de Venta por servicios
		insert into #ESMeses 
		select ' ' as codigo,'  TOTAL COSTO DE VENTA POR SERVICIOS ' as nombre,sum(enero),sum(Enero_Presup),
				sum(febrero),sum(Febrero_Presup),sum(marzo),sum(Marzo_Presup),sum(abril),sum(Abril_Presup),
				sum(mayo),sum(Mayo_Presup),sum(junio),sum(Junio_Presup),sum(julio),sum(Julio_Presup),
				sum(agosto),sum(Agosto_Presup),sum(septiembre),sum(Septiembre_Presup),sum(octubre),
				sum(Octubre_Presup),sum(noviembre),sum(Noviembre_Presup),sum(diciembre),sum(Diciembre_Presup),0,0,
				sum(Presup_Anual),'T5201' as TipoCol
		from #ESMeses
		where TipoCol = 'C5201'
		group by left(codigo,4)
		-- Insertando total de Costo de Ventas
		insert into #ESMeses
					select '' as codigo,'  TOTAL COSTO DE VENTAS ' as nombre,sum(enero),sum(Enero_Presup),
							sum(febrero),sum(Febrero_Presup),sum(marzo),sum(Marzo_Presup),sum(abril),
							sum(Abril_Presup),sum(mayo),sum(Mayo_Presup),sum(junio),sum(Junio_Presup),
							sum(julio),sum(Julio_Presup),sum(agosto),sum(Agosto_Presup),sum(septiembre),
							sum(Septiembre_Presup),sum(octubre),sum(Octubre_Presup),sum(noviembre),
							sum(Noviembre_Presup),sum(diciembre),sum(Diciembre_Presup),0,0,sum(Presup_Anual),
							'TC' as TipoCol
					from   #ESMeses
					where TipoCol in ('C5101','C5201')
	end
-- Insertando utilidad bruta
insert into #ESMeses
			select codigo,nombre,sum(enero),sum(Enero_Presup),sum(febrero),sum(Febrero_Presup),sum(marzo),
					sum(Marzo_Presup),sum(abril),sum(Abril_Presup),sum(mayo),sum(Mayo_Presup),sum(junio),
					sum(Junio_Presup),sum(julio),sum(Julio_Presup),sum(agosto),sum(Agosto_Presup),
					sum(septiembre),sum(Septiembre_Presup),sum(octubre),sum(Octubre_Presup),sum(noviembre),
					sum(Noviembre_Presup),sum(diciembre),sum(Diciembre_Presup),sum(total),sum(Total_Presup),
					sum(Presup_Anual),TipoCol
			from 
				(
					select '' as codigo,'  UTILIDAD BRUTA ' as nombre,
						case TipoCol
							when 'TI' then sum(enero) else sum(enero) *-1 end as enero,
						case TipoCol
							when 'TI' then sum(Enero_Presup) else sum(Enero_Presup) *-1 end as Enero_Presup,
						case TipoCol 
							when 'TI' then sum(febrero) else sum(febrero)*-1 end as febrero,
						case TipoCol
							when 'TI' then sum(Febrero_Presup) else sum(Febrero_Presup) *-1 end as Febrero_Presup,
						case TipoCol
							when 'TI' then sum(marzo) else sum(marzo)*-1 end as marzo,
						case TipoCol
							when 'TI' then sum(Marzo_Presup) else sum(Marzo_Presup)*-1 end as Marzo_Presup,
						case TipoCol
							when 'TI' then sum(abril) else sum(abril)*-1 end as abril,
						case TipoCol
							when 'TI' then sum(Abril_Presup) else sum(Abril_Presup) *-1 end as Abril_Presup,
						case TipoCol
							when 'TI' then sum(mayo) else sum(mayo)*-1 end as mayo,
						case TipoCol
							when 'TI' then sum(Mayo_Presup) else sum(Mayo_Presup) *-1 end as Mayo_Presup,
						case TipoCol
							when 'TI' then sum(junio) else sum(junio)*-1 end as junio,
						case TipoCol
							when 'TI' then sum(Junio_Presup) else sum(Junio_Presup) *-1 end as Junio_Presup,
						case TipoCol
							when 'TI' then sum(julio) else sum(julio)*-1 end as julio,
						case TipoCol
							when 'TI' then sum(Julio_Presup) else sum(Julio_Presup) *-1 end as Julio_Presup,
						case TipoCol
							when 'TI' then sum(agosto) else sum(agosto)*-1 end as agosto,
						case TipoCol
							when 'TI' then sum(Agosto_Presup) else sum(Agosto_Presup) *-1 end as Agosto_Presup,
						case TipoCol
							when 'TI' then sum(septiembre) else sum(septiembre)*-1 end as septiembre,
						case TipoCol
							when 'TI' then sum(Septiembre_Presup) else sum(Septiembre_Presup) *-1 end as Septiembre_Presup,
						case TipoCol
							when 'TI' then sum(octubre) else sum(octubre)*-1 end as octubre,
						case TipoCol
							when 'TI' then sum(Octubre_Presup) else sum(Octubre_Presup) *-1 end as Octubre_Presup,
						case TipoCol
							when 'TI' then sum(noviembre) else sum(noviembre)*-1 end as noviembre,
						case TipoCol
							when 'TI' then sum(Noviembre_Presup) else sum(Noviembre_Presup)*-1 end as Noviembre_Presup,
						case TipoCol
							when 'TI' then sum(diciembre) else sum(diciembre)  *-1 end as diciembre,
						case TipoCol
							when 'TI' then sum(Diciembre_Presup) else sum(Diciembre_Presup) *-1 end as Diciembre_Presup,
						0 as total,0 as Total_Presup,
						case TipoCol
							when 'TI' then sum(Presup_Anual) else sum(Presup_Anual) *-1 end as Presup_Anual,
						'UB' as TipoCol
					from   #ESMeses
					where TipoCol in ('TI','TC')
					group by Tipocol
				) T0
			group by T0.codigo,T0.nombre,T0.TipoCol
---- Insertando Gastos Operativos
insert into #ESMeses 
select codigo,nombre,sum(enero)*-1,sum(Enero_Presup)*-1,sum(febrero)*-1 ,sum(Febrero_Presup)*-1,
		sum(marzo)*-1,sum(Marzo_Presup)*-1,sum(abril)*-1,sum(Abril_Presup)*-1,sum(mayo)*-1,sum(Mayo_Presup)*-1,
		sum(junio)*-1,sum(Junio_Presup)*-1,sum(julio)*-1,sum(Julio_Presup)*-1,sum(agosto)*-1,sum(Agosto_Presup)*-1,
		sum(septiembre)*-1,sum(Septiembre_Presup)*-1,sum(octubre)*-1,sum(Octubre_Presup)*-1,sum(noviembre)*-1,
		sum(Noviembre_Presup)*-1,sum(diciembre)*-1,sum(Diciembre_Presup)*-1,0,0,sum(Presup_Anual)*-1,'G6101' as TipoCol
from #ESMeses
where codigo like '6101%' AND codigo NOT LIKE '6104%'
group by codigo,nombre
order by codigo
if (@nNivel<>3)
	begin
		insert into #ESMeses 
				select '', 'TOTAL GASTOS DE ADMINISTRACION',sum(enero),sum(Enero_Presup),
						sum(febrero),sum(Febrero_Presup),sum(marzo),sum(Marzo_Presup),sum(abril),sum(Abril_Presup),
						sum(mayo),sum(Mayo_Presup),sum(junio),sum(Junio_Presup),sum(julio),sum(Julio_Presup),
						sum(agosto),sum(Agosto_Presup),sum(septiembre),sum(Septiembre_Presup),sum(octubre),
						sum(Octubre_Presup),sum(noviembre),sum(Noviembre_Presup),sum(diciembre),sum(Diciembre_Presup),
						0,0,sum(Presup_Anual),'T6101'
				from #ESMeses
				where TipoCol = 'G6101'
				group by left(codigo,4)
	end
--/* GASTOS DE VENTA */ 
insert into #ESMeses
select codigo,nombre,sum(enero)*-1,sum(Enero_Presup)*-1,sum(febrero)*-1,sum(Febrero_Presup)*-1,sum(marzo)*-1,
		sum(Marzo_Presup)*-1,sum(abril)*-1,sum(Abril_Presup),sum(mayo)*-1,sum(Mayo_Presup)*-1,sum(junio)*-1,
		sum(Junio_Presup)*-1,sum(julio)*-1,sum(Julio_Presup),sum(agosto)*-1,sum(Agosto_Presup)*-1,
		sum(septiembre)*-1,sum(Septiembre_Presup)*-1,sum(octubre)*-1,sum(Octubre_Presup)*-1,sum(noviembre)*-1,
		sum(Noviembre_Presup)*-1,sum(diciembre)*-1,sum(Diciembre_Presup)*-1,0,0,sum(Presup_Anual)*-1,'G6102' as TipoCol
from #ESMeses
where codigo like '6102%' AND codigo NOT LIKE '6104%'
group by codigo,nombre
order by codigo

if (@nNivel<>3)
	begin
		insert into #ESMeses 
				select '', 'TOTAL GASTOS DE VENTA',sum(enero),sum(Enero_Presup),sum(Febrero),sum(Febrero_Presup),
						sum(marzo),sum(Marzo_Presup),sum(abril),sum(Abril_Presup),sum(mayo),sum(Mayo_Presup),
						sum(junio),sum(Junio_Presup),sum(julio),sum(Julio_Presup),sum(agosto),sum(Agosto_Presup),
						sum(septiembre),sum(Septiembre_Presup),sum(octubre),sum(Octubre_Presup),
						sum(noviembre),sum(Noviembre_Presup),sum(diciembre),sum(Diciembre_Presup),0,0,
						sum(Presup_Anual),'T6102' as TipoCol
				from #ESMeses
				where TipoCol = 'G6102'
				group by left(codigo,4)
	end
--/* GASTOS FINANCIEROS */
insert into #ESMeses 
select codigo,nombre,sum(enero)*-1 ,sum(Enero_Presup)*-1,sum(febrero)*-1,sum(Febrero_Presup)*-1,sum(marzo)*-1,
		sum(Marzo_Presup)*-1,sum(abril)*-1,sum(Abril_Presup)*-1,sum(mayo)*-1,sum(Mayo_Presup)*-1,sum(junio)*-1,
		sum(Junio_Presup)*-1,sum(julio)*-1,sum(Julio_Presup)*-1,sum(agosto)*-1,sum(Agosto_Presup)*-1,
		sum(septiembre)*-1,sum(Septiembre_Presup)*-1,sum(octubre)*-1,sum(Octubre_Presup),sum(noviembre)*-1,
		sum(Noviembre_Presup)*-1,sum(diciembre)*-1,sum(Diciembre_Presup)*-1,0,0,sum(Presup_Anual)*-1,
		'G6103' as TipoCol
from #ESMeses
where codigo like '6103%' AND codigo NOT LIKE '6104%'
group by codigo,nombre

if (@nNivel<>3)
	begin
		insert into #ESMeses 
				select '', 'TOTAL GASTOS FINANCIEROS',sum(enero),sum(Enero_Presup),sum(febrero),sum(Febrero_Presup),
						sum(marzo),sum(Marzo_Presup),sum(abril),sum(Abril_Presup),sum(mayo),sum(Mayo_Presup),
						sum(junio),sum(Junio_Presup),sum(julio),sum(Julio_Presup),sum(agosto),sum(Agosto_Presup),
						sum(septiembre),sum(Septiembre_Presup),sum(octubre),sum(Octubre_Presup),sum(noviembre),
						sum(Noviembre_Presup),sum(diciembre),sum(Diciembre_Presup),0,0,sum(Presup_Anual),
						'T6103' as TipoCol
				from #ESMeses
				where TipoCol = 'G6103'
				group by left(codigo,4)
	end
-- GASTOS MISCELANEOS

if ((select count(codigo)
		from #ESMeses
		where codigo like '6105%') >0) 
	begin
		insert into #ESMeses 
		select codigo,nombre,sum(enero)*-1 ,sum(Enero_Presup)*-1,sum(febrero)*-1,sum(Febrero_Presup)*-1,
				sum(marzo)*-1,sum(Marzo_Presup)*-1,sum(abril)*-1,sum(Abril_Presup)*-1,sum(mayo)*-1,
				sum(Mayo_Presup)*-1,sum(junio)*-1,sum(Junio_Presup)*-1,sum(julio)*-1,sum(Julio_Presup)*-1,
				sum(agosto)*-1,sum(Agosto_Presup)*-1,sum(septiembre)*-1,sum(Septiembre_Presup)*-1,
				sum(octubre)*-1,sum(Octubre_Presup)*-1,sum(noviembre)*-1,sum(Noviembre_Presup)*-1,
				sum(diciembre)*-1,sum(Diciembre_Presup)*-1,0,0,sum(Presup_Anual)*-1,'G6105' as TipoCol
		from #ESMeses
		where codigo like '6105%' AND codigo NOT LIKE '6104%'
		group by codigo,nombre

		if (@nNivel<>3)
			begin
				insert into #ESMeses  
						select '', 'TOTAL GASTOS MISCELANEOS',sum(enero),sum(Enero_Presup),sum(febrero),
								sum(Febrero_Presup),sum(marzo),sum(Marzo_Presup),sum(abril),sum(Abril_Presup),
								sum(mayo),sum(Mayo_Presup),sum(junio),sum(Junio_Presup),sum(julio),sum(Julio_Presup),
								sum(agosto),sum(Agosto_Presup),sum(septiembre),sum(Septiembre_Presup),
								sum(octubre),sum(Octubre_Presup),sum(noviembre),sum(Noviembre_Presup),
								sum(diciembre),sum(Diciembre_Presup),0,0,sum(Presup_Anual),'T6105'
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
			select codigo,nombre,sum(enero)*-1,sum(Enero_Presup)*-1,sum(febrero)*-1,sum(Febrero_Presup)*-1,
					sum(marzo)*-1,sum(Marzo_Presup)*-1,sum(abril)*-1,sum(Abril_Presup)*-1,sum(mayo)*-1,
					sum(Mayo_Presup)*-1,sum(junio)*-1,sum(Junio_Presup)*-1,sum(julio)*-1,sum(Julio_Presup)*-1,
					sum(agosto)*-1,sum(Agosto_Presup)*-1,sum(septiembre)*-1,sum(Septiembre_Presup)*-1,
					sum(octubre)*-1,sum(Octubre_Presup)*-1,sum(noviembre)*-1,sum(Noviembre_Presup)*-1,
					sum(diciembre)*-1,sum(Diciembre_Presup)*-1,0,0,sum(Presup_Anual)*-1,'G6201' as TipoCol
			from #ESMeses
			where codigo like '62%' AND codigo NOT LIKE '6104%'
			group by codigo,nombre
		insert into #ESMeses
				select '' as codigo,'  TOTAL GASTOS DE NO OPERACION ' as nombre,sum(enero)*-1,sum(Enero_Presup)*-1,
						sum(febrero)*-1,sum(Febrero_Presup)*-1,sum(marzo)*-1,sum(Marzo_Presup)*-1,sum(abril)*-1,
						sum(Abril_Presup)*-1,sum(mayo)*-1,sum(Mayo_Presup)*-1,sum(junio)*-1,sum(Junio_Presup)*-1,
						sum(julio)*-1,sum(Julio_Presup)*-1,sum(agosto)*-1,sum(Agosto_Presup)*-1,sum(septiembre)*-1,
						sum(Septiembre_Presup)*-1,sum(octubre)*-1,sum(Octubre_Presup)*-1,sum(noviembre)*-1,
						sum(Noviembre_Presup)*-1,sum(diciembre)*-1,sum(Diciembre_Presup)*-1,0,0,sum(Presup_Anual)*-1,
						'T6201' as TipoCol
				from  #ESMeses
				where TipoCol = 'G6201'
	end

-- Inserto total de Gastos

insert into #ESMeses
		select '' as codigo,'	TOTAL GASTOS	' as nombre,sum(enero),sum(Enero_Presup),sum(febrero),
				sum(Febrero_Presup),sum(marzo),sum(Marzo_Presup),sum(abril),sum(Abril_Presup),sum(mayo),
				sum(Mayo_Presup),sum(junio),sum(Junio_Presup),sum(julio),sum(Julio_Presup),sum(agosto),
				sum(Agosto_Presup),sum(septiembre),sum(Septiembre_Presup),sum(octubre),sum(Octubre_PResup),
				sum(noviembre),sum(Noviembre_Presup),sum(diciembre),sum(Diciembre_Presup),0,0,
				sum(Presup_Anual),'TG' as TipoCol
		from  #ESMeses
		where TipoCol in ('G6101','G6102','G6103','G6105','G6201')

-- Insertando utilidad antes de impuestos
insert into #ESMeses 
select codigo,nombre,sum(enero),sum(Enero_Presup),sum(febrero),sum(Febrero_Presup),sum(marzo),sum(Marzo_Presup),
		sum(abril),sum(Abril_Presup),sum(mayo),sum(Mayo_Presup),sum(junio),sum(Junio_Presup),sum(julio),
		sum(Julio_Presup),sum(agosto),sum(Agosto_Presup),sum(septiembre),sum(Septiembre_Presup),sum(octubre),
		sum(Octubre_Presup),sum(noviembre),sum(Noviembre_Presup),sum(diciembre),sum(Diciembre_Presup),0,0,
		sum(Presup_Anual),TipoCol
from (
		select '' as codigo,'  UTILIDAD AI ' as nombre,
			case TipoCol
				when 'UB' then sum(enero) else sum(enero) *-1 end as enero,
			case TipoCol
				when 'UB' then sum(Enero_Presup) else sum(Enero_Presup) *-1 end as Enero_Presup,
			case TipoCol
				when 'UB' then sum(febrero) else sum(febrero) *-1 end as febrero,
			case TipoCol
				when 'UB' then sum(Febrero_Presup) else sum(Febrero_Presup) *-1 end as Febrero_Presup,
			case TipoCol
				when 'UB' then sum(marzo) else sum(marzo) *-1 end as marzo,
			case TipoCol
				when 'UB' then sum(Marzo_Presup) else sum(Marzo_Presup) *-1 end as Marzo_Presup,
			case TipoCol
				when 'UB' then sum(abril) else sum(abril) *-1 end as abril,
			case TipoCol
				when 'UB' then sum(Abril_Presup) else sum(Abril_Presup) *-1 end as Abril_Presup,
			case TipoCol
				when 'UB' then sum(mayo) else sum(mayo) *-1 end as mayo,
			case TipoCol
				when 'UB' then sum(Mayo_Presup) else sum(Mayo_Presup) *-1 end as Mayo_Presup,
			case TipoCol
				when 'UB' then sum(junio) else sum(junio) *-1 end as junio,
			case TipoCol
				when 'UB' then sum(Junio_Presup) else sum(Junio_Presup) *-1 end as Junio_Presup,
			case TipoCol
				when 'UB' then sum(julio) else sum(julio) *-1 end as julio,
			case TipoCol
				when 'UB' then sum(Julio_Presup) else sum(Julio_Presup) *-1 end as Julio_Presup,
			case TipoCol
				when 'UB' then sum(agosto) else sum(agosto) *-1 end as agosto,
			case TipoCol
				when 'UB' then sum(Agosto_Presup) else sum(Agosto_Presup) *-1 end as Agosto_Presup,
			case TipoCol
				when 'UB' then sum(septiembre) else sum(septiembre) *-1 end as septiembre,
			case TipoCol
				when 'UB' then sum(Septiembre_Presup) else sum(Septiembre_Presup) *-1 end as Septiembre_Presup,
			case TipoCol
				when 'UB' then sum(octubre) else sum(octubre) *-1 end as octubre,
			case TipoCol
				when 'UB' then sum(Octubre_Presup) else sum(Octubre_Presup) *-1 end as Octubre_Presup,
			case TipoCol
				when 'UB' then sum(noviembre) else sum(noviembre) *-1 end as noviembre,
			case TipoCol
				when 'UB' then sum(Noviembre_Presup) else sum(Noviembre_Presup) *-1 end as Noviembre_Presup,
			case TipoCol
				when 'UB' then sum(diciembre) else sum(diciembre) *-1 end as diciembre,
			case TipoCol
				when 'UB' then sum(Diciembre_Presup) else sum(Diciembre_Presup) *-1 end as Diciembre_Presup,
			0 as Total,	0 as Total_Presup,
			case TipoCol
				when 'UB' then sum(Presup_Anual) else sum(Presup_Anual)*-1 end as Presup_Anual,'UI' as TipoCol
		from   #ESMeses
		where TipoCol IN ('UB','TG')
		group by TipoCol
	) T0
group by t0.codigo,t0.nombre,t0.TipoCol

-- Inserto el tipo de Cambio utilizado en el proceso

insert into #ESMeses 
		select '','Tipo de Cambio' , sum(enero),sum(Enero_Presup),sum(febrero),sum(Febrero_Presup),sum(marzo),
			sum(Marzo_Presup),sum(abril),sum(Abril_Presup),sum(mayo),sum(Mayo_Presup),sum(junio),sum(Junio_Presup),
			sum(julio),sum(Julio_Presup),sum(agosto),sum(Agosto_Presup),sum(septiembre),sum(Septiembre_Presup),
			sum(octubre),sum(Octubre_Presup),sum(noviembre),sum(Noviembre_Presup),sum(diciembre),
			sum(Diciembre_Presup),0,0,0,'TTC'
		from #ESMeses where TipoCol = 'TT'
		
--

update #ESMeses set total = enero+febrero+marzo+abril+mayo+junio+julio+agosto+septiembre+octubre+noviembre+diciembre
		where TipoCol <> 'TTC'

--

update #ESMeses set total_Presup = Enero_Presup+Febrero_Presup+Marzo_Presup+Abril_Presup+Mayo_Presup+Junio_Presup+
									Julio_Presup+Agosto_Presup+Septiembre_Presup+Octubre_Presup+Noviembre_Presup+
									Diciembre_Presup
		where TipoCol <> 'TTC'


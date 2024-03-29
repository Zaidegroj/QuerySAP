set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER procedure [dbo].[EstadoResultadoRealvrsPresupuesto_CVCO] (@DBPais as varchar(4),
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
		exec EstResulConsolRealvrsPresupAnual_CVCO @DBPais , @dFechaIni , @dFechaFin, @dFechaIniAcum,@nNivel ---,@Tc

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
				-- si en ningu
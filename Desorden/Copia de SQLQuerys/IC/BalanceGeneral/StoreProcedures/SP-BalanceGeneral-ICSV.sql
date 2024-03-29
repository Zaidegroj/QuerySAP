set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go




/*
Procedimiento		:	Utilizado en la opción Query Manager->Finanzas-> Balance General
*/

alter  procedure [dbo].[BalanceGeneral]
							(
							@DBPais as varchar(4),
							@dFechaIni as DateTime,
							@dFechaFin as DateTime,
							@nNivel	as int,
							@Tc as numeric(18,4) = null ,
							@iShowSql as int = null
							)
as 

-- Declaración de Variables
declare @iMonthFirst int,
		@iMonthLast int,
		@iFlag int,
		@dFechaIni1 datetime,
		@dFechaFin1 datetime,
		@cCuenta varchar(40),
		@cCuentaProceso	varchar(40),
		@nSaldo	numeric(18,4),
		@nMultiplicador numeric(2,0)

-- set's
set @iMonthFirst	= month(@dFechaIni)
set @iMonthLast		= month(@dFechaFin)
set @iFlag			= 1
set @dFechaIni		= convert(char(10),@dFechaIni,121)+' 00:00:00'
set @dFechaFin		= convert(char(10),DateAdd(ms,-2,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'


-- Creo un cursor a partir de la tabla temporal para recorrerlo y aplicar las actualizaciones por cuenta

declare tcBalance cursor scroll for
				select Cuenta from #BalanceTemp

-- inserto la línea de la utilidad que se actualizará al final del proceso
insert into #BalanceTemp
select ' ','UTILIDAD EJERCICIO','',2,0,0,0,0,0,0,0,0,0,0,0,0,0

if (@Tc is null)
	begin
		set @Tc = 1
	end
if (@Tc > 1)
	begin
		-- inserto el tipo de cambio de acuerdo a la última fecha de cada mes
		insert into #BalanceTemp
		select ' ',' ',' ',2,0,0,0,0,0,0,0,0,0,0,0,0,0
		insert into #BalanceTemp
		select ' ','TIPO DE CAMBIO','',2,0,0,0,0,0,0,0,0,0,0,0,0,0
	end

-- abro el cursor
open tcBalance
Fetch Next from tcBalance into @cCuenta
while (@iMonthFirst <=@iMonthLast)
begin
	-- Obtengo el tipo de cambio si el enviado como parámetro es mayor a uno
	if (@Tc > 1)
		begin
			set @Tc = (select CVSV.dbo.GetTCCountries(@DBPais,@dFechaFin))
		end
	while (@@FETCH_STATUS=0) 
		begin
			set @cCuentaProceso = rtrim(ltrim(substring(@cCuenta,1,9)))+'%'
			--if (@cCuentaProceso like '1%')
			--	begin
					set @nMultiplicador = -1
			--	end
			--else
			--	begin
			--		set @nMultiplicador = -1
			--	end
			exec icsv.dbo.ObtenerSaldoCuenta @dFechaIni,@dFechaFin,@cCuentaProceso,@nSaldo output 
			if (@iMonthFirst = 1)
				begin
					update #BalanceTemp set Enero = (@nSaldo/@Tc) * @nMultiplicador where Cuenta = @cCuenta
					-- Actualizo el tipo de Cambio
					update #BalanceTemp set Enero = @Tc where descripcion = 'TIPO DE CAMBIO'
				end
			if (@iMonthFirst = 2)
				begin
					update #BalanceTemp set febrero = (@nSaldo/@Tc )* @nMultiplicador where Cuenta = @cCuenta
					-- Actualizo el tipo de Cambio
					update #BalanceTemp set febrero = @Tc where descripcion = 'TIPO DE CAMBIO'
				end
			if (@iMonthFirst = 3)
				begin
					update #BalanceTemp set marzo = (@nSaldo/@Tc) * @nMultiplicador where Cuenta = @cCuenta
					-- Actualizo el tipo de Cambio
					update #BalanceTemp set marzo = @Tc where descripcion = 'TIPO DE CAMBIO'
				end
			if (@iMonthFirst = 4)
				begin
					update #BalanceTemp set abril = (@nSaldo/@Tc) * @nMultiplicador where Cuenta = @cCuenta
					-- Actualizo el tipo de Cambio
					update #BalanceTemp set abril = @Tc where descripcion = 'TIPO DE CAMBIO'
				end
			if (@iMonthFirst = 5)
				begin
					update #BalanceTemp set mayo = (@nSaldo/@Tc) * @nMultiplicador where Cuenta = @cCuenta
					-- Actualizo el tipo de Cambio
					update #BalanceTemp set mayo = @Tc where descripcion = 'TIPO DE CAMBIO'
				end
			if (@iMonthFirst = 6)
				begin
					update #BalanceTemp set junio = (@nSaldo/@Tc) * @nMultiplicador where Cuenta = @cCuenta
					-- Actualizo el tipo de Cambio
					update #BalanceTemp set junio = @Tc where descripcion = 'TIPO DE CAMBIO'
				end
			if (@iMonthFirst = 7)
				begin
					update #BalanceTemp set julio = (@nSaldo/@Tc) * @nMultiplicador where Cuenta = @cCuenta
					-- Actualizo el tipo de Cambio
					update #BalanceTemp set julio = @Tc where descripcion = 'TIPO DE CAMBIO'
				end
			if (@iMonthFirst = 8)
				begin
					update #BalanceTemp set agosto = (@nSaldo/@Tc) * @nMultiplicador where Cuenta = @cCuenta
					-- Actualizo el tipo de Cambio
					update #BalanceTemp set agosto = @Tc where descripcion = 'TIPO DE CAMBIO'
				end
			if (@iMonthFirst = 9)
				begin
					update #BalanceTemp set septiembre = (@nSaldo/@Tc) * @nMultiplicador where Cuenta = @cCuenta
					-- Actualizo el tipo de Cambio
					update #BalanceTemp set septiembre = @Tc where descripcion = 'TIPO DE CAMBIO'
				end
			if (@iMonthFirst = 10)
				begin
					update #BalanceTemp set octubre = (@nSaldo/@Tc) * @nMultiplicador where Cuenta = @cCuenta
					-- Actualizo el tipo de Cambio
					update #BalanceTemp set octubre = @Tc where descripcion = 'TIPO DE CAMBIO'
				end
			if (@iMonthFirst = 11)
				begin
					update #BalanceTemp set noviembre = (@nSaldo/@Tc) * @nMultiplicador where Cuenta = @cCuenta
					-- Actualizo el tipo de Cambio
					update #BalanceTemp set noviembre = @Tc where descripcion = 'TIPO DE CAMBIO'
				end
			if (@iMonthFirst = 12)
				begin
					update #BalanceTemp set diciembre = (@nSaldo/@Tc) * @nMultiplicador where Cuenta = @cCuenta
					-- Actualizo el tipo de Cambio
					update #BalanceTemp set diciembre = @Tc where descripcion = 'TIPO DE CAMBIO'
				end
			Fetch Next From tcBalance into @cCuenta
		end
	-- Actualizo el tipo de cambio utilizado en el 
	set @dFechaIni = convert(char(10),DateAdd(ms,-1,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'
	set @dFechaFin = convert(char(10),DateAdd(ms,-2,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'
	set @iMonthFirst = @iMonthFirst + 1
	Fetch First From TcBalance into @cCuenta
end

-- Inserto la Utilidad
update #BalanceTemp set enero		= (select sum(Enero) from #BalanceTemp where nivel = 1),
						febrero		= (select sum(Febrero) from #BalanceTemp where nivel = 1),
						Marzo		= (select sum(marzo) from #BalanceTemp where nivel = 1),
						abril		= (select sum(abril) from #BalanceTemp where nivel = 1),
						mayo		= (select sum(mayo) from #BalanceTemp where nivel = 1),
						junio		= (select sum(junio) from #BalanceTemp where nivel = 1),
						julio		= (select sum(julio) from #BalanceTemp where nivel = 1),
						agosto		= (select sum(agosto) from #BalanceTemp where nivel = 1),
						septiembre	= (select sum(septiembre) from #BalanceTemp where nivel = 1),
						octubre		= (select sum(octubre) from #BalanceTemp where nivel = 1),
						noviembre	= (select sum(noviembre) from #BalanceTemp where nivel = 1),
						diciembre	= (select sum(diciembre) from #BalanceTemp where nivel = 1)
where descripcion = 'UTILIDAD EJERCICIO'

-- Actualizo el total

update #BalanceTemp set total = (Enero+Febrero+Marzo+Abril+
								 Mayo+Junio+Julio+Agosto+
								 Septiembre+Octubre+Noviembre+Diciembre)

-- Armo el query de los meses a mostrar

if (@iShowSql is null)
	begin
		declare @sSql as nvarchar(400)
		--
		set @sSql = 'select cuenta as [Cuenta],descripcion as [Nombre de la Cuenta]'
		if ((select count(enero) from #BalanceTemp where enero <> 0 )>0)
			begin
				set @sSql = @sSql + ',Enero'
			end
		if ((select count(Febrero) from #BalanceTemp where febrero <> 0 )>0)
			begin
				set @sSql = @sSql +  ',Febrero'
			end
		if ((select count(Marzo) from #BalanceTemp where marzo <> 0 )>0)
			begin
				set @sSql = @sSql +  ',Marzo'
			end
		if ((select count(Abril) from #BalanceTemp where abril <> 0 )>0)
			begin
				set @sSql = @sSql +  ',Abril'
			end
		if ((select count(Mayo) from #BalanceTemp where mayo <> 0 )>0)
			begin
				set @sSql = @sSql +  ',Mayo'
			end
		if ((select count(Junio) from #BalanceTemp where junio <> 0 )>0)
			begin
				set @sSql = @sSql +  ',Junio'
			end
		if ((select count(Julio) from #BalanceTemp where julio <> 0 )>0)
			begin
				set @sSql = @sSql +  ',Julio'
			end
		if ((select count(Agosto) from #BalanceTemp where agosto <> 0 )>0)
			begin
				set @sSql = @sSql +  ',Agosto'
			end
		if ((select count(Septiembre) from #BalanceTemp where septiembre <> 0 )>0)
			begin
				set @sSql = @sSql +  ',Septiembre'
			end
		if ((select count(octubre) from #BalanceTemp where octubre <> 0 )>0)
			begin
				set @sSql = @sSql + ',Octubre'
			end
		if ((select count(noviembre) from #BalanceTemp where noviembre <> 0 )>0)
			begin
				set @sSql = @sSql + ',Noviembre'
			end
		if ((select count(Diciembre) from #BalanceTemp where diciembre <> 0 )>0)
			begin
				set @sSql = @sSql + ',Diciembre'
			end
		if ((select count(Total) from #BalanceTemp where total <>0 )> 0)
			begin
				--set @sSql = @sSql + ',Total from #BalanceTemp ' + 'where Nivel < ' + ltrim(rtrim(str(@nNivel)))
				set @sSql = @sSql + ',Total from #BalanceTemp ' + 'where Total <>0 and Nivel < ' + ltrim(rtrim(str(@nNivel)))
			end
	
		exec ( @sSql )
	
	end
-- Drop's
--drop table #BalanceTemp
close tcBalance
deallocate tcBalance


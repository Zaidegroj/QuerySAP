set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go




/*
Procedimiento		:	Utilizado en la opción Query Manager->Finanzas-> Balance General
*/

ALTER  procedure [dbo].[BalanceGeneral]
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

---- Declaración de Variables para el Fetch Next
--declare @sDescripcion varchar(40),
--		@sCuentaPadre varchar(40),
--		@dEnero decimal(18,4),
--		@dFebrero decimal(18,4),
--		@dMarzo decimal(18,4),
--		@dAbril decimal(18,4),
--		@dMayo decimal (18,4),
--		@dJunio decimal(18,4),
--		@dJulio decimal(18,4),
--		@dAgosto decimal(18,4),
--		@dSeptiembre decimal(18,4),
--		@dOctubre decimal(18,4),
--		@dNoviembre decimal(18,4),
--		@dDiciembre decimal(18,4),
--		@dTotal decimal(18,4)

-- set's
set @iMonthFirst	= month(@dFechaIni)
set @iMonthLast		= month(@dFechaFin)
set @iFlag			= 1
set @dFechaIni		= convert(char(10),@dFechaIni,121)+' 00:00:00'
set @dFechaFin		= convert(char(10),DateAdd(ms,-2,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'
set @nMultiplicador	= 1
--print @Tc

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
			set @Tc = (select vmsv.dbo.GetTCCountries(@DBPais,@dFechaFin))
		end
	while (@@FETCH_STATUS=0) 
		begin
			set @cCuentaProceso = rtrim(ltrim(substring(@cCuenta,1,9)))+'%'
			--if (@cCuentaProceso like '1%')
			--	begin
					--set @nMultiplicador = -1
			--	end
			--else
			--	begin
			--		set @nMultiplicador = -1
			--	end
			exec vmsv.dbo.ObtenerSaldoCuenta @dFechaIni,@dFechaFin,@cCuentaProceso,@nSaldo output 
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
update #BalanceTemp set enero		= isnull((select sum(Enero) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(Enero) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
						febrero		= isnull((select sum(Febrero) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(Febrero) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
						Marzo		= isnull((select sum(marzo) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(marzo) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
						abril		= isnull((select sum(abril) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(abril) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
						mayo		= isnull((select sum(mayo) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(mayo) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
						junio		= isnull((select sum(junio) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(junio) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
						julio		= isnull((select sum(julio) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(julio) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
						agosto		= isnull((select sum(agosto) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(agosto) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
						septiembre	= isnull((select sum(septiembre) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(septiembre) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
						octubre		= isnull((select sum(octubre) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(octubre) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
						noviembre	= isnull((select sum(noviembre) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(noviembre) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
						diciembre	= isnull((select sum(diciembre) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(diciembre) from #BalanceTemp where nivel = 1 and substring(cuenta,1,1)<>'1'),0)
where descripcion = 'UTILIDAD EJERCICIO'

-- Actualizo el total

update #BalanceTemp set total = (Enero+Febrero+Marzo+Abril+Mayo+Junio+Julio+Agosto+Septiembre+Octubre+Noviembre+Diciembre)

-- Armo el query de los meses a mostrar

if (@iShowSql is null)

-- Borro las cuentas que no han tenido movimiento en todo el año
	delete	from #BalanceTemp 
			where enero = 0 and
					febrero = 0 and
					marzo = 0 and
					abril = 0 and
					mayo = 0 and
					junio = 0 and
					julio = 0 and
					agosto = 0 and
					septiembre = 0 and
					octubre = 0 and
					noviembre = 0 and
					diciembre = 0

	-- Inserto en la nueva tabla de BalanceconTitulos
	-- ACTIVOS
	insert into #BalanceTempWithTitles
				select * from #BalanceTemp where left(cuenta,1)='1'

	insert into #BalanceTempWithTitles
				select null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null

	insert into #BalanceTempWithTitles
				select null,'     TOTAL '+' '+upper(AcctName)+'..........',null,0,sum(T1.enero),sum(febrero),sum(marzo),sum(abril),sum(mayo),sum(junio),sum(julio),sum(agosto),sum(septiembre),sum(octubre),sum(noviembre),sum(diciembre),sum(total)
				from vmsv.dbo.oact T0 cross join #BalanceTemp T1 
				where (T0.levels = 1 and Left(T0.AcctCode,1)='1') and (T1.Nivel =1 and left(T1.Cuenta,1)='1')
				group by AcctName	

	insert into #BalanceTempWithTitles
				select null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null

	-- PASIVO
	insert into #BalanceTempWithTitles
				select * from #BalanceTemp where left(cuenta,1)='2'

	insert into #BalanceTempWithTitles
				select null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null

	insert into #BalanceTempWithTitles
				select null,'     TOTAL '+' '+upper(AcctName)+'..........',null,0,sum(T1.enero),sum(febrero),sum(marzo),sum(abril),sum(mayo),sum(junio),sum(julio),sum(agosto),sum(septiembre),sum(octubre),sum(noviembre),sum(diciembre),sum(total)
				from vmsv.dbo.oact T0 cross join #BalanceTemp T1 
				where (T0.levels = 1 and Left(T0.AcctCode,1)='2') and (T1.Nivel =1 and left(T1.Cuenta,1)='2')
				group by AcctName	

	insert into #BalanceTempWithTitles
				select null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null

	-- CAPITAL
	if (select count(Cuenta) from #BalanceTemp where left(cuenta,1)='3')>0
		begin
			insert into #BalanceTempWithTitles
					select * from #BalanceTemp where left(cuenta,1)='3'

			insert into #BalanceTempWithTitles
				select null,null,null,0,null,null,null,null,null,null,null,null,null,null,null,null,null

			insert into #BalanceTempWithTitles
					select null,'     TOTAL '+' '+upper(AcctName)+'..........',null,0,sum(T1.enero),sum(febrero),sum(marzo),sum(abril),sum(mayo),sum(junio),sum(julio),sum(agosto),sum(septiembre),sum(octubre),sum(noviembre),sum(diciembre),sum(total)
					from vmsv.dbo.oact T0 cross join #BalanceTemp T1 
					where (T0.levels = 1 and Left(T0.AcctCode,1)='3') and (T1.Nivel =1 and left(T1.Cuenta,1)='3')
					group by AcctName	
		end
	insert into #BalanceTempWithTitles
			select null,'UTILIDAD EJERCICIO',NULL,0,sum(T1.enero),sum(febrero),sum(marzo),sum(abril),sum(mayo),sum(junio),sum(julio),sum(agosto),sum(septiembre),sum(octubre),sum(noviembre),sum(diciembre),sum(total)
			from #BalanceTemp T1
			where descripcion = 'UTILIDAD EJERCICIO'

--	--Actualizo el total de la utilidad
--	update #BalanceTempWithTitles set	enero		= isnull((select sum(Enero) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(Enero) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
--										febrero		= isnull((select sum(Febrero) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(Febrero) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
--										Marzo		= isnull((select sum(marzo) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(marzo) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
--										abril		= isnull((select sum(abril) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(abril) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
--										mayo		= isnull((select sum(mayo) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(mayo) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
--										junio		= isnull((select sum(junio) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(junio) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
--										julio		= isnull((select sum(julio) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(julio) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
--										agosto		= isnull((select sum(agosto) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(agosto) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
--										septiembre	= isnull((select sum(septiembre) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(septiembre) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
--										octubre		= isnull((select sum(octubre) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(octubre) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
--										noviembre	= isnull((select sum(noviembre) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(noviembre) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)<>'1'),0),
--										diciembre	= isnull((select sum(diciembre) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)='1')-(select sum(diciembre) from #BalanceTempWithTitles where nivel = 1 and substring(cuenta,1,1)<>'1'),0)
--				where descripcion = 'UTILIDAD EJERCICIO'
			
---SELECT * from #BalanceTempWithTitles

--	
--	select * from #tcBalance

	begin
		declare @sSql as nvarchar(400)
		--
		set @sSql = 'select cuenta as [Cuenta],descripcion as [Nombre de la Cuenta]'
		if ((select count(enero) from #BalanceTempWithTitles where enero <> 0 )>0)
			begin
				set @sSql = @sSql + ',Enero'
			end
		if ((select count(Febrero) from #BalanceTempWithTitles where febrero <> 0 )>0)
			begin
				set @sSql = @sSql +  ',Febrero'
			end
		if ((select count(Marzo) from #BalanceTempWithTitles where marzo <> 0 )>0)
			begin
				set @sSql = @sSql +  ',Marzo'
			end
		if ((select count(Abril) from #BalanceTempWithTitles where abril <> 0 )>0)
			begin
				set @sSql = @sSql +  ',Abril'
			end
		if ((select count(Mayo) from #BalanceTempWithTitles where mayo <> 0 )>0)
			begin
				set @sSql = @sSql +  ',Mayo'
			end
		if ((select count(Junio) from #BalanceTempWithTitles where junio <> 0 )>0)
			begin
				set @sSql = @sSql +  ',Junio'
			end
		if ((select count(Julio) from #BalanceTempWithTitles where julio <> 0 )>0)
			begin
				set @sSql = @sSql +  ',Julio'
			end
		if ((select count(Agosto) from #BalanceTempWithTitles where agosto <> 0 )>0)
			begin
				set @sSql = @sSql +  ',Agosto'
			end
		if ((select count(Septiembre) from #BalanceTempWithTitles where septiembre <> 0 )>0)
			begin
				set @sSql = @sSql +  ',Septiembre'
			end
		if ((select count(octubre) from #BalanceTempWithTitles where octubre <> 0 )>0)
			begin
				set @sSql = @sSql + ',Octubre'
			end
		if ((select count(noviembre) from #BalanceTempWithTitles where noviembre <> 0 )>0)
			begin
				set @sSql = @sSql + ',Noviembre'
			end
		if ((select count(Diciembre) from #BalanceTempWithTitles where diciembre <> 0 )>0)
			begin
				set @sSql = @sSql + ',Diciembre'
			end

		set @sSql = @sSql + ',Total from #BalanceTempWithTitles ' + 'where Total <>0 and Nivel < ' + ltrim(rtrim(str(@nNivel)))



	
		exec ( @sSql )

		------print @ssQl
	
	end

/*
drop table #BalanceTemp
drop table #BalanceTempWithTitles
*/
close tcBalance
deallocate tcBalance


--select * from oact
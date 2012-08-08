declare @dFechaIni					as datetime,
		@dFechaFin					as datetime,
		@dFechaIniAnual				as datetime,
		@dFechaFinAnual				as datetime,
		@nYear						as int,
		@Tc							as numeric(18,4),
		@nInDesign					as int,
		@cCuenta					as varchar(30),
		@nSaldo						as numeric(14,2),
		@nActivoCirculante			as numeric(18,2),
		@nPasivoCirculante			as numeric(18,2),
		@nCapitalContable			as numeric(18,2),
		@nRazonCirculante			as numeric(18,2),
		@nRazonCapitalTrabajo		as numeric(18,2),
		@nRazonMargenUtilidadBruta	as numeric(18,2),
		@nRazonMargenUtilOperativa	as numeric(18,2),
		@nVentasBrutas				as numeric(18,2),
		@nCostoVentas				as numeric(18,2),
		@nDevolSobreVentas			as numeric(18,2),
		@nGastosOpyDevol			as numeric(18,2),
		@nRazonRentabSobrePatr		as numeric(18,2),
		@nUtilidadNeta				as numeric(18,2),
		@nPatrimonio				as numeric(18,2),
		@nActivosTotales			as numeric(18,2),
		@nCuentasPorCobrar			as numeric(18,2),
		@nVentasNetasAnual			as numeric(18,2),
		@nVentasBrutasAnual			as numeric(18,2),
		@nDevolSobreVentAnual		as numeric(18,2),
		@nRazonDiasPromedioCobro	as numeric(18,2),
		@nDevolucionesAnuales		as numeric(18,2),
		@nRazonRendimientoActivo	as numeric(18,2),
		@nRazonRendimientoCapital	as numeric(18,2)

set @nInDesign = 1

if (@nInDesign = 1)
	begin
		set @dFechaIni		= '01/01/2011 00:00:00'
		set @dFechaFin		= '12/31/2011 00:00:00'
	end
else
	begin
		/* SELECT FROM DBO.JDT1 T0*/
		SET @dFechaIni = /* T0.RefDate */'[%0]'
		SET @dFechaFin = /* T0.RefDate*/'[%1]'
	end


set @nYear			= year(@dFechaIni)
set @dFechaIniAnual	= '01/01/'+convert(char(4),@nYear)
set @dFechaFinAnual	= '12/31/'+convert(char(4),@nYear)

if (@nYear=year(@dFechaFin))
	begin
		-- Obtención de Valores 

		-- Activo circulante 

		set @cCuenta = '11%'
		
		exec ismgt.dbo.ObtenerSaldoCuenta @dFechaIni,@dFechaFin,@cCuenta,@nSaldo output 
		
		set @nActivoCirculante = @nSaldo
		
		-- Pasivo circulante 
		
		set @cCuenta = '21%'
		
		exec ismgt.dbo.ObtenerSaldoCuenta @dFechaIni,@dFechaFin,@cCuenta,@nSaldo output 
		
		set @nPasivoCirculante = @nSaldo 

		-- Capital Contable

		set @cCuenta = '3101%'

		exec ismgt.dbo.ObtenerSaldoCuenta @dFechaIni,@dFechaFin,@cCuenta,@nSaldo output
		set @nCapitalContable = @nSaldo
		
		-- Patrimonio
		
		set @cCuenta = '3%'

		exec ismgt.dbo.ObtenerSaldoCuenta @dFechaIni,@dFechaFin,@cCuenta,@nSaldo output
	
		set @nPatrimonio = @nSaldo
		
		-- Activos Totales
		
		set @cCuenta = '1%'
		
		exec ismgt.dbo.ObtenerSaldoCuenta @dFechaIni,@dFechaFin,@cCuenta,@nSaldo output
		
		set @nActivosTotales = @nSaldo
		
		-- Devoluciones sobre Ventas
		
		set @cCuenta = '6104%'
		
		exec ismgt.dbo.ObtenerSaldoCuenta @dFechaIni,@dFechaFin,@cCuenta,@nSaldo output 
		
		set @nDevolSobreVentas	= @nSaldo *-1

		-- Cuentas por Cobrar (Clientes)
		
		set @cCuenta = '110301%'
		
		exec ismgt.dbo.ObtenerSaldoCuenta @dFechaIni,@dFechaFin,@cCuenta,@nSaldo output
		
		set @nCuentasPorCobrar = @nSaldo 

		-- Ventas Netas Anuales

		set @cCuenta = '4%'

		exec ismgt.dbo.ObtenerSaldoCuenta @dFechaIniAnual,@dFechaFinAnual,@cCuenta,@nSaldo output

		set @nVentasBrutasAnual = @nSaldo 

		set @cCuenta = '6104%'

		exec ismgt.dbo.ObtenerSaldoCuenta @dFechaIniAnual,@dFechaFinAnual,@cCuenta,@nSaldo output
		set @nDevolSobreVentAnual = @nSaldo 
		set @nVentasNetasAnual = @nVentasBrutasAnual - @nDevolSobreVentAnual
		
		---print @nVentasNetasAnual

		-- Total de Gastos Operativos, incluyendo devoluciones

		set @cCuenta = '6%'
		
		exec ismgt.dbo.ObtenerSaldoCuenta @dFechaini,@dFechaFin,@cCuenta,@nSaldo output
		
		set @nGastosOpyDevol	=	@nSaldo 

		-- Ventas Brutas Periodo

		set @cCuenta = '4%'

		exec ismgt.dbo.ObtenerSaldoCuenta @dFechaIni,@dFechaFin,@cCuenta,@nSaldo output
		set @nVentasBrutas = @nSaldo 

		-- Costo de Venta Periodo

		set @cCuenta = '5%'

		exec ismgt.dbo.ObtenerSaldoCuenta @dFechaIni,@dFechaFin,@cCuenta,@nSaldo output 
		set @nCostoVentas = @nSaldo 

		-- Utilidad Neta Periodo
		
--		print @nVentasBrutas 
--		print @nDevolSobreVentas 
--		print @nCostoVentas 
--		print @nGastosOpyDevol

		set @nUtilidadNeta		= (@nVentasBrutas - @nCostoVentas - @nGastosOpyDevol)

		-- RAZONES

		--Razón Capital de Trabajo Neto

		set @nRazonCapitalTrabajo = @nActivoCirculante - @nPasivoCirculante

		-- Razón Circulante

		set @nRazonCirculante = @nActivoCirculante / @nPasivoCirculante

		-- Razón Período Promedio de Cobro

		set @nRazonDiasPromedioCobro = @nCuentasPorCobrar / (@nVentasNetasAnual/360)

		-- Razón Margen Utilidad Bruta

		set @nRazonMargenUtilidadBruta = (@nVentasBrutas-@nCostoVentas)/@nVentasBrutas

		-- Razón Margen Utilidad Operativa
	
		set @nRazonMargenUtilOperativa	= @nUtilidadNeta / (@nVentasBrutas-@nDevolSobreVentas)

		-- Razón Rendimiento de Activos

		set @nRazonRendimientoActivo = @nUtilidadNeta / @nActivosTotales

		-- Razón Rendimiento sobre Capital Contable

		set @nRazonRendimientoCapital = case @nCapitalContable when 0 then 0 else @nUtilidadNeta / @nCapitalContable end

		-- Razón Rentabilidad sobre el patrimonio
		
		set @nRazonRentabSobrePatr	= case @nPatrimonio when 0 then 0 else @nUtilidadNeta/@nPatrimonio end 


		-- Muestra de los datos

		select	'Capital de Trabajo Neto' as [Razón Financiera],'Activo Circulante - Pasivo Circulante' as [Fórmula],
				ltrim(rtrim(convert(char,@nActivoCirculante)))+'-'+rtrim(ltrim(convert(char,@nPasivoCirculante))) as [Valores] ,
				@nRazonCapitalTrabajo as [Resultado]
		union all 
		select	'Razón Circulante' as [Razón Financiera],'Activo Circulante / Pasivo Circulante ' as [Fórmula],
				ltrim(rtrim(convert(char,@nActivoCirculante)))+'/'+rtrim(ltrim(convert(char,@nPasivoCirculante))) as [Valores],
				@nRazonCirculante as [Resultado]
		union all 
		select	'Periodo Promedio de Cobro' as [Razón Financiera],'Cuentas por Cobrar /(Ventas Anuales/360)',
				ltrim(rtrim(convert(char,@nCuentasPorCobrar)))+'/('+rtrim(ltrim(convert(char,@nVentasNetasAnual)))+'/360)' as [Valores],
				@nRazonDiasPromedioCobro as [Resultado]
		union all 
		select	'Margen Utilidad Bruta' as [Razón Financiera],'(Ventas-Costo Venta)/Ventas' as [Fórmula],
				ltrim(rtrim(convert(char,@nVentasBrutas)))+'-'+rtrim(ltrim(convert(char,@nCostoVentas)))+'/'+rtrim(ltrim(convert(char,@nVentasBrutas))),
				@nRazonMargenUtilidadBruta as [Resultado]
		union all 
		select 'Margen Utilidad Operativa' as [Razón Financiera],'Utilidad Neta/Ventas Netas' as [Fórmula],
				ltrim(rtrim(convert(char,@nUtilidadNeta)))+'/'+rtrim(ltrim(convert(char,@nVentasBrutas - @nDevolSobreVentas))),
				@nRazonMargenUtilOperativa as [Resultado]
		union all 
		select	'Rendimiento sobre Activos' as [Razón Financiera],'Utilidad Neta/Activos Totales' as [Fórmula],
				ltrim(rtrim(convert(char,@nUtilidadNeta)))+'/'+rtrim(ltrim(convert(char,@nActivosTotales))),
				@nRazonRendimientoActivo as [Resultado]
		union all 
		select 'Rendimiento Sobre Capital Contable' as [Razón Financiera],'Utilidad Neta/Capital Contable' as [Fórmula],
				ltrim(rtrim(convert(char,@nUtilidadNeta)))+'/'+rtrim(ltrim(convert(char,@nCapitalContable))) as [Fórmula],
				@nRazonRendimientoCapital as [Resultado]
		union all 
		select	'Rentabilidad Sobre Patrimonio' as [Razón Financiera],'(Utilidad Neta/Patrimonio)' as [Fórmula],
				ltrim(rtrim(convert(char,@nUtilidadNeta)))+'/'+rtrim(ltrim(convert(char,@nPatrimonio))) ,
				@nRazonRentabSobrePatr as [Resultado]
		
	end
else
	begin
		select 'No se pueden mostrar datos,Años diferentes seleccionados!!!!'
	end
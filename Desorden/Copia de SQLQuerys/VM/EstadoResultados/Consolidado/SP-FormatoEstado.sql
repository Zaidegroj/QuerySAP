/*  Procedimiento para Formatear el Estado de Resultados por Meses VideoMark.
	Es INDISPENSABLE que en el procedimiento que la llama exista la estructura creada 
	para la tabla #ESMeses y #Estado
*/
alter procedure FormatoEstado (@nNivel as int)
as

insert into #Estado (codigo,nombre) values ('','		*	INGRESOS	*		')
insert into #Estado (codigo,nombre) values ('','		INGRESOS POR PRODUCTOS		')
insert into #Estado 
	select * from #ESMeses where TipoCol = 'I4101'
--Total por productos 
insert into #Estado
	select * from #ESMeses where tipocol = 'T4101'
-- inserto ingresos por servicios
insert into #Estado (codigo,nombre) values ('','		INGRESOS POR SERVICIOS		')
insert into #Estado 
	select * from #ESMeses where TipoCol = 'I4102'
-- Total por servicios
insert into #Estado 
	select * from #ESMeses where tipocol = 'T4102'
--
insert into #Estado (codigo,nombre) values ('','')
insert into #Estado (codigo,nombre) values ('','		INGRESOS FINANCIEROS		')
--inserto ingresos por prestación de servicios
insert into #Estado
select * from #ESMeses where TipoCol = 'I4103' order by Codigo
-- inserto total de ingresos financieros
insert into #Estado 
select * from #ESMeses where TipoCol = 'T4103' 
-- Ingresos no operacionales
if ((select count(codigo)
		from #ESMeses
		where TipoCol = 'I4104') >0) 
	begin
		insert into #Estado (codigo,nombre) values ('','')
		insert into #Estado (codigo,nombre) values ('','	OTROS INGRESOS NO OPERACIONALES		')
		--inserto ingresos por prestación de servicios
		insert into #Estado
		select * from #ESMeses where TipoCol = 'I4104' 
	end
-- inserto total 
insert into #Estado 
		select * from #ESMeses where TipoCol = 'T4104'

----Total Ingresos General
--insert into #Estado (codigo, nombre) values ('','         TOTAL INGRESOS ')
--		insert into #Estado 
--				select * from #ESMeses where TipoCol = 'TI'
--
insert into #Estado (codigo,nombre) values ('','')
-- inserto las devoluciones y rebajas sobre ventas
if ((select count(codigo)
		from #ESMeses
		where TipoCol = 'I6104') >0) 
	begin
		insert into #Estado (codigo,nombre) values ('','	REBAJAS Y DEVOLUCIONES SOBRE VENTAS		')
		insert into #Estado
			select * from #ESMeses where TipoCol = 'I6104'
		-- total de devoluciones y rebajas sobre ventas
		insert into #Estado (codigo,nombre) values ('','')
		insert into #Estado 
					select * from #ESMeses where TipoCol = 'T6104'
	end
-- insertando total de los ingresos
insert into #Estado (codigo,nombre) values ('','')
insert into #Estado 
			select * from #ESMeses where TipoCol in ('TI')

-- Insertando Costos de Venta por productos
if ((select count(codigo)
		from #ESMeses
		where TipoCol = 'C5101') >0) 
	begin	
		insert into #Estado (codigo,nombre) values ('','')
		insert into #Estado (codigo,nombre) values ('','		*	COSTOS	*		')
		insert into #Estado (codigo,nombre) values ('','        COSTO DE VENTA      ')
		insert into #Estado 
		select * from #ESMeses where TipoCol = 'C5101' 
		-- inserto Total Costo de Ventas por productos
		insert into #Estado
				select * from #ESMeses where TipoCol = 'T5101'
	end
if ((select count(codigo)
	 from #ESMeses
	 where TipoCol = 'C5201')>0)
	begin
		-- Costos por servicios
		insert into #Estado (codigo,nombre) values ('','		COSTO DE VENTA POR SERVICIOS	')
		insert into #Estado 
		select * from #ESMeses where TipoCol = 'C5201'
		-- Total Costo de Venta por servicios
		insert into #Estado 
		select * from #ESMeses where TipoCol = 'T5201' 
	end

if ((select count(codigo)
	 from #ESMeses
	 where TipoCol = 'TC')>0)
	begin
		-- Insertando total de Costo de Ventas
		insert into #Estado 
				select * from #ESMeses where TipoCol = 'TC'
	end

-- Insertando utilidad bruta
insert into #Estado (codigo, nombre) values ('','')
insert into #Estado 
			select * from #ESMeses where TipoCol in ('UB') 
-- Insertando Gastos Operativos
insert into #Estado (codigo, nombre) values ('','')
insert into #Estado (codigo,nombre) values ('','    * GASTOS *     ')
/* GASTOS DE ADMINISTRACION */
if (@nNivel <> 3)
	begin
		insert into #Estado (codigo, nombre) values ('','')
		insert into #Estado (codigo,nombre) values ('','        GASTOS DE ADMINISTRACION      ')
	end
insert into #Estado 
select * from #ESMeses where Tipocol = 'G6101'
if (@nNivel<>3)
	begin
		insert into #Estado (codigo, nombre) values ('','')
		insert into #Estado 
				select * from #ESMeses where TipoCol = 'T6101'
	end
/* GASTOS DE VENTA */ 
if (@nNivel <> 3)
	begin
		insert into #Estado (codigo, nombre) values ('','')
		insert into #Estado (codigo,nombre) values ('','		GASTOS DE VENTA		')
	end
insert into #Estado 
select * from #ESMeses where TipoCol = 'G6102'
if (@nNivel<>3)
	begin
		insert into #Estado (codigo, nombre) values ('','')
		insert into #Estado 
				select * from #ESMeses where TipoCol = 'T6102' 
	end
/* GASTOS FINANCIEROS */
if (@nNivel <> 3)
	begin
		insert into #Estado (codigo, nombre) values ('','')
		insert into #Estado (codigo,nombre) values ('','		GASTOS DE FINANCIEROS		')
	end
insert into #Estado 
select * from #ESMeses where TipoCol = 'G6103' 
if (@nNivel<>3)
	begin
		insert into #Estado (codigo, nombre) values ('','')
		insert into #Estado 
				select * from #ESMeses where TipoCol = 'T6103'
	end
/* GASTOS MISCELANEOS */
if ((select count(codigo)
	 from #ESMeses
	 where TipoCol = 'G6105')>0)
	begin
		if (@nNivel <> 3)
			begin
				insert into #Estado (codigo, nombre) values ('','')
				insert into #Estado (codigo,nombre) values ('','		GASTOS MISCELANEOS		')
		end
		insert into #Estado 
			select * from #ESMeses where TipoCol = 'G6105' 
		if (@nNivel<>3)
			begin
				insert into #Estado (codigo, nombre) values ('','')
				insert into #Estado 
					select * from #ESMeses where TipoCol = 'T6105' 
			end
	 end

-- Insertando Gastos de No operación
if ((select count(codigo)
	from #ESMeses
	where TipoCol = 'G6201') >0) 
	begin
		insert into #Estado (codigo, nombre) values ('','')
		insert into #Estado (codigo,nombre) values ('','		GASTOS DE NO OPERACION		')
		insert into #Estado 
			select * from #ESMeses where TipoCol = 'G6201'
		-- Insertando total de Gastos
		insert into #Estado (codigo, nombre) values ('','')
		insert into #Estado 
				select * from #ESMeses where TipoCol = 'T6201'
	end

-- Insertando total de Gastos
insert into #Estado (codigo, nombre) values ('','')
insert into #Estado 
		select * from #ESMeses where TipoCol = 'TG' 


-- Insertando utilidad antes de impuestos
insert into #Estado (codigo, nombre) values ('','')
insert into #Estado 
select * from #ESMeses where TipoCol = 'UI'
-- Inserto el tipo de Cambio utilizado en el proceso
insert into #Estado (codigo,nombre) values (' ', ' ')
insert into #Estado 
		select * from #ESMeses where TipoCol = 'TTC'



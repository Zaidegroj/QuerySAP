set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

/*  Procedimiento para Formatear el Estado de Resultados por Meses VideoMark.
	Es INDISPENSABLE que en el procedimiento que la llama exista la estructura creada 
	para la tabla #ESMeses y #Balance
*/
alter procedure [dbo].[BalanceFormato] (@nNivel as int)
as

insert into #Balance (codigo,nombre) values ('','		*	ACTIVO	*		')
insert into #Balance (codigo,nombre) values ('','		ACTIVO CORRIENTES		')
insert into #Balance 
	select * from #ESMeses where TipoCol = 'A11'
--Total por productos 
insert into #Balance
	select * from #ESMeses where tipocol = 'TA11'
-- inserto ingresos por servicios
insert into #Balance (codigo,nombre) values ('','		ACTIVOS NO CORRIENTES		')
insert into #Balance 
	select * from #ESMeses where TipoCol = 'A12'
-- Total por servicios
insert into #Balance 
	select * from #ESMeses where tipocol = 'TA12'
-- Total Activo
insert into #Balance
	select * from #ESMeses where TipoCol = 'TA'

-- Inserto los pasivos 

insert into #Balance (codigo,nombre) values ('','')
insert into #Balance (codigo,nombre) values ('','     *PASIVOS*     ')
insert into #Balance
	select * from #ESMeses where TipoCol = 'P21' 
insert into #Balance
	select * from #ESMeses where TipoCol = 'TP21'

if ((select count(codigo)
		from #ESMeses
		where TipoCol = 'TP22') >0) 
	begin
		insert into #Balance (codigo,nombre) values ('','		PASIVOS NO CORRIENTES		')
		insert into #Balance
			select * from #ESMeses where TipoCol = 'P22' 
		insert into #Balance
			select * from #ESMeses where TipoCol = 'TP22'
	end

-- Total Pasivo
insert into #Balance
	select * from #ESMeses where TipoCol = 'TP'

-- Inserto Capital y Reserva
if ((select count(codigo)
		from #ESMeses
		where TipoCol = 'TC31') >0) 
	begin
		insert into #Balance (codigo,nombre) values ('','')
		insert into #Balance (codigo,nombre) values ('','     *CAPITAL Y RESERVA*     ')
		insert into #Balance
			select * from #ESMeses where TipoCol = 'C31' 

	end

-- Inserto Pérdidas y Ganancias
insert into #Balance (codigo,nombre) values ('','')
insert into #Balance
	select * from #ESMeses where TipoCol = 'PG31' 

insert into #Balance
		select * from #ESMeses where TipoCol = 'TC31'

--Inserto Total Pasivo mas Capital

insert into #Balance (codigo,nombre) values ('','')
--insert into




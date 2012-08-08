create table #Tmp 
(
CODIGO		VARCHAR(100) NULL,
NOMBRE		NVARCHAR(100) NULL,
SV 		NUMERIC(19,4) NULL,
SV_ANT 		NUMERIC(19,4) NULL,
DIF 		NUMERIC(19,4) NULL,
ACUMULADO	NUMERIC(19,4) NULL,
PRESUP_MENS 	NUMERIC(19,4) NULL,
PRESUP_ANUAL 	NUMERIC(19,4) NULL,
PORCENT_MENS 	NUMERIC(19,4) NULL,
PORCENT_ANUAL 	NUMERIC(19,4) NULL
)

CREATE TABLE #TmpConso(
CODIGO		NVARCHAR(100) NULL,
NOMBRE		NVARCHAR(100) NULL,
SV 		NUMERIC(19,4) NULL,
SV_ANT 		NUMERIC(19,4) NULL,
DIF 		NUMERIC(19,4) NULL,
ACUMULADO	NUMERIC(19,4) NULL,
PRESUP_MENS 	NUMERIC(19,4) NULL,
PRESUP_ANUAL 	NUMERIC(19,4) NULL,
PORCENT_MENS 	NUMERIC(19,4) NULL,
PORCENT_ANUAL 	NUMERIC(19,4) NULL,
TipoCol			Varchar(2) null
)

declare @ESPaises table (
						codigo		nvarchar(100),
						nombre		nvarchar(100),
						Guatemala	numeric(18,4),
						ElSalvador	numeric(18,4) ,
						Honduras	numeric(18,4) ,
						CostaRica	numeric(18,4) ,
						Panama		numeric(18,4) ,
						Dominicana	numeric(18,4)
						)

declare @Estado table (
						codigo		nvarchar(100),
						nombre		nvarchar(100),
						Guatemala	numeric(18,4),
						ElSalvador	numeric(18,4),
						Honduras	numeric(18,4),
						CostaRica	numeric(18,4),
						Panama		numeric(18,4),
						Dominicana	numeric(18,4),
						Total		numeric(18,4),
						TipoCol		varchar(2)
						)

declare @nInDesign		int,
		@FechaIni 		AS DATETIME,
		@FechaFin 		AS DATETIME,
		@FechaIniAcum 	AS DATETIME,
		@Tc				as numeric(10,2),
		@nNivel			as int

set @nInDesign = 1

if (@nInDesign = 1)
	begin
		set @FechaIni		= '05/01/2010 00:00:00'
		set @FechaFin		= '08/31/2010 00:00:00'
		set @FechaIniAcum	= '01/01/2010 00:00:00'
		set @nNivel			= 3
	end
else
	begin
		/* SELECT FROM DBO.JDT1 T0*/
		SET @FechaIni = /* T0.RefDate */'[%0]'
		SET @FechaFin = /* T0.RefDate*/'[%1]'
		SET @FechaIniAcum = '01/01/2010 00:00:00'
		/* select Levels from dbo.oact T1 */
		set @nNivel	= /* T1.Levels */'[%2]'
	end

if (@nNivel not in (3,4,5))
	begin
		set @nNivel = 3
	end

--print @nNivel 

--Guatemala

insert into #Tmpconso
	exec EstadoResultadoConsolidado_R1 'PRGT' , @FechaIni , @FechaFin, @FechaIniAcum,@nNivel,8

insert into @ESPaises (codigo,nombre,guatemala)
		select codigo,nombre, sv from #Tmp where codigo is not null

delete from #Tmp
delete From #TmpConso


--El Salvador

insert into #Tmpconso
	exec EstadoResultadoConsolidado_R1 'VMSV' , @FechaIni , @FechaFin, @FechaIniAcum,@nNivel,8

insert into @ESPaises (codigo,nombre,ElSalvador)
		select codigo,nombre, sv from #Tmp where codigo is not null

delete from #Tmp
delete From #TmpConso

--Honduras

insert into #Tmpconso
	exec EstadoResultadoConsolidado_R1 'PRHN' , @FechaIni , @FechaFin, @FechaIniAcum,@nNivel,8

insert into @ESPaises (codigo,nombre,Honduras)
		select codigo,nombre, sv from #Tmp where codigo is not null

delete From #TmpConso
delete from #Tmp
--select * from prhn.dbo.ortt order by ratedate desc

--Costa Rica

insert into #Tmpconso
	exec EstadoResultadoConsolidado_R1 'VMCR' , @FechaIni , @FechaFin, @FechaIniAcum,@nNivel,8

insert into @ESPaises (codigo,nombre,CostaRica)
		select codigo,nombre, sv from #Tmp where codigo is not null

delete from #Tmp
delete From #TmpConso

--select * from vmcr.dbo.ortt order by ratedate desc

-- Panamá

insert into #Tmpconso
	exec EstadoResultadoConsolidado_R1 'VMPA' , @FechaIni , @FechaFin, @FechaIniAcum,@nNivel,8

insert into @ESPaises (codigo,nombre,Panama)
		select codigo,nombre, sv from #Tmp where codigo is not null

delete from #Tmp
delete From #TmpConso
--select * from vmpa.dbo.ortt order by ratedate desc


-- Dominicana

insert into #Tmpconso
	exec EstadoResultadoConsolidado_R1 'VMDO' , @FechaIni , @FechaFin, @FechaIniAcum,@nNivel,8

insert into @ESPaises (codigo,nombre,Dominicana)
		select codigo,nombre, sv from #Tmp where codigo is not null

delete from #Tmp
delete From #TmpConso
--select * from vmdo.dbo.ortt order by ratedate desc


--- Creo encabezado de Estado
insert into @Estado (codigo,nombre) values ('','		*	INGRESOS	*		')
insert into @Estado (codigo,nombre) values ('','		INGRESOS POR VENTA DE PRODUCTO		')
insert into @Estado 
select codigo,nombre,isnull(sum(guatemala),0),isnull(sum(elsalvador),0),isnull(sum(honduras),0),
		isnull(sum(costarica),0),isnull(sum(panama),0),isnull(sum(dominicana),0),0,'I' as TipoCol
from @ESPaises
where codigo like '4101%'
group by codigo,nombre
order by codigo

-- Inserto Total de Ventas por Producto
insert into @Estado 
			select '' as codigo,'  TOTAL  ' as nombre,isnull(sum(guatemala),0),isnull(sum(elsalvador),0),isnull(sum(honduras),0),
					isnull(sum(costarica),0),isnull(sum(panama),0),isnull(sum(dominicana),0),0,'' as TipoCol
			from   @ESPaises
			where codigo like ('4101%') 
			group by left(codigo,4)

-- inserto ingresos por servicios
insert into @Estado (codigo,nombre) values ('','		INGRESOS POR SERVICIOS		')
insert into @Estado 
select codigo,nombre,isnull(sum(guatemala),0),isnull(sum(elsalvador),0),isnull(sum(honduras),0),
		isnull(sum(costarica),0),isnull(sum(panama),0),isnull(sum(dominicana),0),0,'I' as TipoCol
from @ESPaises
where codigo like '4102%'
group by codigo,nombre
order by codigo

 insert into @Estado 
			select '' as codigo,'  TOTAL  ' as nombre,isnull(sum(guatemala),0),isnull(sum(elsalvador),0),isnull(sum(honduras),0),
					isnull(sum(costarica),0),isnull(sum(panama),0),isnull(sum(dominicana),0),0,'' as TipoCol
			from   @ESPaises
			where codigo like '4102%'
			group by left(codigo,4)

--
insert into @Estado (codigo,nombre) values ('','')
insert into @Estado (codigo,nombre) values ('','		INGRESOS FINANCIEROS		')
insert into @Estado
select codigo,nombre,isnull(sum(guatemala),0),isnull(sum(elsalvador),0),isnull(sum(honduras),0),
		isnull(sum(costarica),0),isnull(sum(panama),0),isnull(sum(dominicana),0),0,'I' as TipoCol
from @ESPaises
where codigo like '4103%'
group by codigo,nombre
order by codigo

-- inserto total de ingresos financieros

insert into @Estado 
select '' as codigo,'  TOTAL  ' as nombre,isnull(sum(guatemala),0),isnull(sum(elsalvador),0),isnull(sum(honduras),0),
		isnull(sum(costarica),0),isnull(sum(panama),0),isnull(sum(dominicana),0),0,'' as TipoCol
from   @ESPaises
where codigo like '4103%'
group by left(codigo,4)


-- Ingresos no operacionales

insert into @Estado (codigo,nombre) values ('','')
insert into @Estado (codigo,nombre) values ('','	OTROS INGRESOS NO OPERACIONALES		')
--inserto ingresos por prestación de servicios
insert into @Estado
select codigo,nombre,isnull(sum(guatemala),0),isnull(sum(elsalvador),0),isnull(sum(honduras),0),
		isnull(sum(costarica),0),isnull(sum(panama),0),isnull(sum(dominicana),0),0,'I' as TipoCol
from @ESPaises
where codigo like '4104%'
group by codigo,nombre
order by codigo

-- inserto total Otros ingresos no operacionales

insert into @Estado 
	select '' as codigo,'  TOTAL  ' as nombre,isnull(sum(guatemala),0),isnull(sum(elsalvador),0),isnull(sum(honduras),0),
			isnull(sum(costarica),0),isnull(sum(panama),0),isnull(sum(dominicana),0),0,'' as TipoCol
	from   @ESPaises
	where codigo like '4104%'
	group by left(codigo,4)

insert into @Estado (codigo,nombre) values ('','')

-- inserto las devoluciones y rebajas sobre ventas

if ((select count(codigo)
		from @ESPaises
		where codigo like '6104%') >0) 
	begin
		insert into @Estado (codigo,nombre) values ('','	REBAJAS Y DEVOLUCIONES SOBRE VENTAS		')
		insert into @Estado
		select codigo,nombre,isnull(sum(guatemala),0)*-1,isnull(sum(elsalvador),0)*-1,isnull(sum(honduras),0)*-1,
				isnull(sum(costarica),0)*-1,isnull(sum(panama),0)*-1,isnull(sum(dominicana),0)*-1,0,'D' as TipoCol
		from @ESPaises
		where codigo like '6104%'
		group by codigo,nombre
		order by codigo
	
		-- total de devoluciones y rebajas sobre ventas
		insert into @Estado (codigo,nombre) values ('','')
		insert into @Estado 
					select '' as codigo,'  TOTAL  ' as nombre,sum(guatemala)*-1,sum(elsalvador)*-1,sum(honduras)*-1,
							sum(costarica)*-1,sum(panama)*-1,sum(dominicana)*-1,0,'TD' as TipoCol
					from   @ESPaises
					where codigo like '6104%'
	end

-- insertando total de los ingresos

insert into @Estado (codigo,nombre) values ('','')
insert into @Estado 
			select codigo,nombre,sum(guatemala),sum(elsalvador),sum(honduras),sum(costarica),sum(panama),sum(dominicana),sum(total),TipoCol
			from 
				(
					select '' as codigo,'  TOTAL  INGRESOS ' as nombre,
						case TipoCol 
							when 'I' then isnull(sum(guatemala),0) else isnull(sum(guatemala),0) *-1 end as guatemala,
						case TipoCol
							when 'I' then isnull(sum(elsalvador),0) else isnull(sum(elsalvador),0)*-1 end as elsalvador,
						case TipoCol
							when 'I' then isnull(sum(honduras),0)   else isnull(sum(honduras),0) *-1 end as honduras,
						case TipoCol 
							when 'I' then isnull(sum(costarica),0) else isnull(sum(costarica),0) *-1 end as costarica,
						case Tipocol
							when 'I' then isnull(sum(panama),0) else isnull(sum(panama),0) *-1 end as panama,
						case TipoCol 
							when 'I' then isnull(sum(dominicana),0) else isnull(sum(dominicana),0) *-1 end as dominicana,
						0 as Total,'TI' as TipoCol
					from   @Estado
					where TipoCol in ('I','D')
					group by TipoCol 
				) T0
			group by T0.codigo,T0.nombre,T0.TipoCol

-- Insertando Costos de Venta por productos

insert into @Estado (codigo,nombre) values ('','')
insert into @Estado (codigo,nombre) values ('','		*	COSTOS	*		')
insert into @Estado (codigo,nombre) values ('','		COSTO DE VENTA POR PRODUCTOS	')
insert into @Estado 
select codigo,nombre,isnull(sum(guatemala),0)*-1,isnull(sum(elsalvador),0)*-1,isnull(sum(honduras),0)*-1,
		isnull(sum(costarica),0)*-1 ,isnull(sum(panama),0)*-1,isnull(sum(dominicana),0)*-1,0,'C' as TipoCol
from @ESPaises
where codigo like '5101%'
group by codigo,nombre
order by codigo

-- Total Costo de Venta por productos
insert into @Estado 
select ' ' as codigo,'  TOTAL COSTO DE VENTA POR PRODUCTO ' as nombre,isnull(sum(guatemala),0)*-1,isnull(sum(elsalvador),0)*-1,isnull(sum(honduras),0)*-1,
		isnull(sum(costarica),0)*-1 ,isnull(sum(panama),0)*-1,isnull(sum(dominicana),0)*-1,0,'' as TipoCol
from @ESPaises
where codigo like '5101%'
group by left(codigo,4)
order by codigo

-- Insertando Costos de Venta por Servicios

insert into @Estado (codigo,nombre) values ('','		COSTO DE VENTA POR SERVICIOS	')
insert into @Estado 
select codigo,nombre,isnull(sum(guatemala),0)*-1,isnull(sum(elsalvador),0)*-1,isnull(sum(honduras),0)*-1,
		isnull(sum(costarica),0)*-1 ,isnull(sum(panama),0)*-1,isnull(sum(dominicana),0)*-1,0,'C' as TipoCol
from @ESPaises
where codigo like '5201%'
group by codigo,nombre
order by codigo

-- Total Costo de Venta por productos
insert into @Estado 
select ' ' as codigo,'  TOTAL COSTO DE VENTA POR SERVICIOS ' as nombre,isnull(sum(guatemala),0)*-1,isnull(sum(elsalvador),0)*-1,isnull(sum(honduras),0)*-1,
		isnull(sum(costarica),0)*-1 ,isnull(sum(panama),0)*-1,isnull(sum(dominicana),0)*-1,0,'' as TipoCol
from @ESPaises
where codigo like '5201%'
group by left(codigo,4)
order by codigo


-- Insertando total de Costo de Ventas

insert into @Estado (codigo, nombre) values ('','')
insert into @Estado 
			select '' as codigo,'  TOTAL COSTO DE VENTAS ' as nombre,
					isnull(sum(guatemala),0),isnull(sum(elsalvador),0),isnull(sum(honduras),0),
					isnull(sum(costarica),0),isnull(sum(panama),0),isnull(sum(dominicana),0),0,'' as TipoCol
			from   @Estado
			where TipoCol = 'C'

-- Insertando utilidad bruta

insert into @Estado (codigo, nombre) values ('','')
insert into @Estado 
			select codigo,nombre,sum(guatemala),sum(elsalvador),sum(honduras),sum(costarica),sum(panama),sum(dominicana),sum(total),TipoCol
			from 
				(
					select '' as codigo,'  UTILIDAD BRUTA ' as nombre,
						case TipoCol
							when 'TI' then isnull(sum(guatemala),0) else isnull(sum(guatemala),0) *-1 end as guatemala,
						case TipoCol
							when 'TI' then isnull(sum(elsalvador),0) else isnull(sum(elsalvador),0) *-1 end as elsalvador,
						case TipoCol 
							when 'TI' then isnull(sum(honduras)  ,0) else isnull(sum(honduras),0)   *-1 end as honduras,
						case TipoCol
							when 'TI' then isnull(sum(costarica) ,0) else isnull(sum(costarica),0)  *-1 end as costarica,
						case TipoCol
							when 'TI' then isnull(sum(panama)    ,0) else isnull(sum(panama   ),0)  *-1 end as panama,
						case TipoCol 
							when 'TI' then isnull(sum(dominicana),0) else isnull(sum(dominicana),0) *-1 end as dominicana,
						0 as total,'UB' as TipoCol
					from   @Estado
					where TipoCol in ('TI','C')
					group by Tipocol
				) T0
			group by T0.codigo,T0.nombre,T0.TipoCol

-- Insertando Gastos Operativos

insert into @Estado (codigo, nombre) values ('','')
insert into @Estado (codigo,nombre) values ('','    * GASTOS *     ')

/* GASTOS DE ADMINISTRACION */
if (@nNivel <> 3)
	begin
		insert into @Estado (codigo, nombre) values ('','')
		insert into @Estado (codigo,nombre) values ('','        GASTOS DE ADMINISTRACION      ')
	end

insert into @Estado 
select codigo,nombre,isnull(sum(guatemala),0)*-1,isnull(sum(elsalvador),0)*-1,isnull(sum(honduras),0)*-1 ,
		isnull(sum(costarica),0)*-1,isnull(sum(panama),0)*-1,isnull(sum(dominicana),0)*-1,0,'G' as TipoCol
from @ESPaises
where codigo like '6101%' AND codigo NOT LIKE '6104%'
group by codigo,nombre
order by codigo

if (@nNivel<>3)
	begin
		insert into @Estado (codigo, nombre) values ('','')
		insert into @Estado (codigo,nombre,guatemala,elsalvador,honduras,costarica,panama,dominicana,total,TipoCol) 
				select '', 'TOTAL GASTOS DE ADMINISTRACION',isnull(sum(guatemala),0)*-1,isnull(sum(elsalvador),0)*-1,isnull(sum(honduras),0)*-1,
						isnull(sum(costarica),0)*-1,isnull(sum(panama),0)*-1,isnull(sum(dominicana),0)*-1,0,''
				from @ESPaises
				where codigo like '6101%' and codigo not like '6104%'
				group by left(codigo,4)
	end

/* GASTOS DE VENTA */ 

if (@nNivel <> 3)
	begin
		insert into @Estado (codigo, nombre) values ('','')
		insert into @Estado (codigo,nombre) values ('','		GASTOS DE VENTA		')
	end

insert into @Estado 
select codigo,nombre,isnull(sum(guatemala),0)*-1,isnull(sum(elsalvador),0)*-1,isnull(sum(honduras),0)*-1,
		isnull(sum(costarica),0)*-1,isnull(sum(panama),0)*-1,isnull(sum(dominicana),0)*-1,0,'G' as TipoCol
from @ESPaises
where codigo like '6102%' AND codigo NOT LIKE '6104%'
group by codigo,nombre
order by codigo


if (@nNivel<>3)
	begin
		insert into @Estado (codigo, nombre) values ('','')
		insert into @Estado (codigo,nombre,guatemala,elsalvador,honduras,costarica,panama,dominicana,total,TipoCol) 
				select '', 'TOTAL GASTOS DE VENTA',isnull(sum(guatemala),0)*-1,isnull(sum(elsalvador),0)*-1,isnull(sum(honduras),0)*-1,
						isnull(sum(costarica),0)*-1,isnull(sum(panama),0)*-1,isnull(sum(dominicana),0)*-1,0,''
				from @ESPaises
				where codigo like '6102%' and codigo not like '6104%'
				group by left(codigo,4)
	end

/* GASTOS FINANCIEROS */

if (@nNivel <> 3)
	begin
		insert into @Estado (codigo, nombre) values ('','')
		insert into @Estado (codigo,nombre) values ('','		GASTOS DE FINANCIEROS		')
	end

insert into @Estado 
select codigo,nombre,isnull(sum(guatemala),0)*-1,isnull(sum(elsalvador),0)*-1 ,isnull(sum(honduras),0)*-1,
		isnull(sum(costarica),0)*-1,isnull(sum(panama),0)*-1,isnull(sum(dominicana),0)*-1,0,'G' as TipoCol
from @ESPaises
where codigo like '6103%' AND codigo NOT LIKE '6104%'
group by codigo,nombre
order by codigo

if (@nNivel<>3)
	begin
		insert into @Estado (codigo, nombre) values ('','')
		insert into @Estado (codigo,nombre,guatemala,elsalvador,honduras,costarica,panama,dominicana,total,TipoCol) 
				select '', 'TOTAL GASTOS FINANCIEROS',isnull(sum(guatemala),0)*-1,isnull(sum(elsalvador),0)*-1,isnull(sum(honduras),0)*-1,
						isnull(sum(costarica),0)*-1,isnull(sum(panama),0)*-1,isnull(sum(dominicana),0)*-1,0,''
				from @ESPaises
				where codigo like '6103%' and codigo not like '6104%'
				group by left(codigo,4)
	end

-- Insertando total de Gastos Operativos
	
insert into @Estado (codigo, nombre) values ('','')
insert into @Estado 
		select '' as codigo,'	TOTAL ' as nombre,isnull(sum(guatemala),0),isnull(sum(elsalvador),0),isnull(sum(honduras),0),
				isnull(sum(costarica),0),isnull(sum(panama),0),isnull(sum(dominicana),0),0,'' as TipoCol
		from  @Estado
		where TipoCol = 'G'
		--where codigo like '61%' and codigo not like '6104%'

-- Insertando Gastos de No operación

if ((select count(codigo)
	from @ESPaises
	where codigo like '62%') >0) 
	begin
		insert into @Estado (codigo, nombre) values ('','')
		insert into @Estado (codigo,nombre) values ('','		GASTOS DE NO OPERACION		')
		insert into @Estado 
			select codigo,nombre,isnull(sum(guatemala),0)*-1,isnull(sum(elsalvador),0)*-1,isnull(sum(honduras),0)*-1,
					isnull(sum(costarica),0)*-1,isnull(sum(panama),0)*-1,isnull(sum(dominicana),0)*-1,0,'G' as TipoCol
			from @ESPaises
			where codigo like '62%' AND codigo NOT LIKE '6104%'
			group by codigo,nombre
			order by codigo

		-- Insertando total de Gastos
				
		insert into @Estado (codigo, nombre) values ('','')
		insert into @Estado 
				select '' as codigo,'  TOTAL GASTOS DE NO OPERACION ' as nombre,isnull(sum(guatemala),0)*-1,isnull(sum(elsalvador),0)*-1,
						isnull(sum(honduras),0)*-1,isnull(sum(costarica)*-1,0),
						isnull(sum(panama),0)*-1,isnull(sum(dominicana),0)*-1,0,'' as TipoCol
				from  @Estado
				where codigo like '62%' and codigo not like '6104%'
	end

-- Insertando total de Gastos General
	
insert into @Estado (codigo, nombre) values ('','')
insert into @Estado 
		select '' as codigo,'	TOTAL GASTOS    ' as nombre,isnull(sum(guatemala),0),isnull(sum(elsalvador),0),isnull(sum(honduras),0),
				isnull(sum(costarica),0),isnull(sum(panama),0),isnull(sum(dominicana),0),0,'' as TipoCol
		from  @Estado
		where TipoCol = 'G'

-- Insertando utilidad antes de impuestos

insert into @Estado (codigo, nombre) values ('','')
insert into @Estado (codigo, nombre) values ('','')
insert into @Estado 
select codigo,nombre,sum(guatemala),sum(elsalvador),sum(honduras),sum(costarica),sum(panama),sum(dominicana),sum(total),TipoCol
from (
		select '' as codigo,'  UTILIDAD AI ' as nombre,
			case Tipocol
				when 'UB' then isnull(sum(guatemala),0) else isnull(sum(guatemala),0)   *-1 end as guatemala,
			case TipoCol
				when 'UB' then isnull(sum(elsalvador),0) else isnull(sum(elsalvador),0) *-1 end as elsalvador,
			case TipoCol
				when 'UB' then isnull(sum(honduras)  ,0) else isnull(sum(honduras)  ,0) *-1 end as honduras,
			case TipoCol
				when 'UB' then isnull(sum(costarica) ,0) else isnull(sum(costarica) ,0) *-1 end as costarica,
			case TipoCol
				when 'UB' then isnull(sum(panama)    ,0) else isnull(sum(panama)    ,0) *-1 end as panama,
			case TipoCol
				when 'UB' then isnull(sum(dominicana),0) else isnull(sum(dominicana),0) *-1 end as dominicana,
			0 as Total,'' as TipoCol
		from   @Estado
		where TipoCol IN ('UB','G')
		group by TipoCol
	) T0
group by t0.codigo,t0.nombre,t0.TipoCol
-- Inserto el tipo de Cambio utilizado en el proceso
insert into @Estado (nombre) values ('  ')
-- Tc Guatemala
set @Tc = (select dbo.GetTCCountries('PRGT',@FechaFin))
insert into @Estado (nombre,guatemala,TipoCol ) values ('Tipo de Cambio',@Tc,'TT')
--Tc El Salvador
set @Tc = (select dbo.GetTCCountries('VMSV',@FechaFin))
update @Estado set ElSalvador= @Tc where TipoCol = 'TT'
--Tc Honduras
set @Tc = (select dbo.GetTCCountries('PRHN',@FechaFin))
update @Estado set Honduras= @Tc where TipoCol = 'TT'
--Tc Costa Rica
set @Tc = (select dbo.GetTCCountries('VMCR',@FechaFin))
update @Estado set CostaRica= @Tc where TipoCol = 'TT'
--Tc Panama
set @Tc = (select dbo.GetTCCountries('VMPA',@FechaFin))
update @Estado set Panama= @Tc where TipoCol = 'TT'
--Tc Dominicana
set @Tc = (select dbo.GetTCCountries('VMDO',@Fechafin))
update @Estado set Dominicana = @Tc where TipoCol = 'TT'

delete from @Estado where	(guatemala=0 or guatemala is null) and
							(honduras = 0 or honduras is null) and 
							(elsalvador = 0 or elsalvador is null) and 
							(costarica = 0 or costarica is null) and 
							(panama = 0 or panama is null) and 
							(dominicana=0 or dominicana is null) and rtrim(ltrim(codigo)) <> '' and nombre <> ''

update @Estado set total = (isnull(guatemala,0)+isnull(honduras,0)+isnull(elsalvador,0)+isnull(costarica,0)+isnull(panama,0)+isnull(dominicana,0)) where TipoCol <>'TT'

select codigo as [Cuenta],nombre as [Nombre de la Cuenta],Guatemala,ElSalvador as [El Salvador],Honduras,costarica as [Costa Rica],Panama,Dominicana,Total
from @Estado 

drop table #Tmp 
drop table #TmpConso


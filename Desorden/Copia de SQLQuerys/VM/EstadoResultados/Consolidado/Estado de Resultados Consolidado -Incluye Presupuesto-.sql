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
---
create table #TmpConso
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
PORCENT_ANUAL 	NUMERIC(19,4) NULL,
TipoCol		char(1) null
)
--Declaración de Variables
DECLARE @FechaIni 	AS DATETIME
DECLARE @FechaFin 	AS DATETIME
DECLARE @FechaIniAcum 	AS DATETIME
DECLARE @Anyo_ACT	AS NVARCHAR(80)
DECLARE @Anyo_ANT	AS NVARCHAR(100)
DECLARE @FechaIni_ANT 	AS DATETIME
DECLARE @FechaFin_ANT 	AS DATETIME
DECLARE @campos		AS NVARCHAR(80)
DECLARE @camposTot	AS NVARCHAR(800),
		@iDesign	as int

set @iDesign = 1
if (@iDesign = 1)
	begin
		set @FechaIni = '05/01/2010 00:00:00'
		set @FechaFin = '05/31/2010 00:00:00'
		set @FechaIniAcum = '01/01/2010 00:00:00'
	end
else
	begin
		/* SELECT FROM PRGT.DBO.JDT1 T0*/
		SET @FechaIni = /* T0.RefDate */'[%0]'
		SET @FechaFin = /* T0.RefDate*/'[%1]'
		SET @FechaIniAcum = /* T0.RefDate*/'[%2]'
	end


SET @FechaIni_ANT=DATEADD(YEAR,-1,@FechaIni)
SET @FechaFin_ANT=DATEADD(YEAR,-1,@FechaFin)
SET @Anyo_ACT=CAST(DATEPART(YEAR,@FechaIni) AS NVARCHAR)
SET @Anyo_ACT=' AS Real_' + @Anyo_ACT
SET @Anyo_ANT=CAST(DATEPART(YEAR,@FechaIni_ANT) AS NVARCHAR)
SET @Anyo_ANT=' AS Real_' + @Anyo_ANT

/*SELECT * FROM PRGT.DBO.ORTT T0*/

-- VideoMark El Salvador
execute  Consolidado_Paises 'VMSV', @FechaIni, @FechaFin, @FechaIniAcum

---- VideoMark Guatemala
execute  Consolidado_Paises 'PRGT', @FechaIni, @FechaFin, @FechaIniAcum

-- VideoMark Honduras
execute Consolidado_Paises 'PRHN', @FechaIni, @FechaFin, @FechaIniAcum

---- VideoMark Costa Rica
execute  Consolidado_Paises 'VMCR', @FechaIni, @FechaFin, @FechaIniAcum

-- VideoMark Panamá
execute  Consolidado_Paises 'VMPA', @FechaIni, @FechaFin, @FechaIniAcum

--VideoMark Dominicana
execute  Consolidado_Paises 'VMDO', @FechaIni, @FechaFin, @FechaIniAcum

--- Creo encabezado de Estado
insert into #TmpConso (codigo,nombre) values ('','    *    INGRESOS    *    ')
insert into #TmpConso (codigo,nombre) values ('','INGRESOS POR VENTA DE PRODUCTOS')
insert into #TmpConso
select codigo,nombre,sum(sv) as sv,sum(sv_ant) as sv_ant,sum(dif) as dif,
		sum(acumulado)as acumulado,sum(presup_mens) as presup_mens,
		sum(presup_anual) as presup_anual,sum(porcent_mens) as porcent_mens,
		sum(porcent_anual) as porcent_anual,'N' as TipoCol
from #Tmp
where codigo like '410101%'
group by codigo,nombre
order by codigo
-- inserto total de ingresos de productos 
insert into #TmpConso 
			select '' as codigo,'  TOTAL  ' as nombre,sum(sv),sum(sv_ant),sum(dif),sum(acumulado),sum(presup_mens),
					sum(presup_anual),0 as porcent_mens,0 as porcent_anual,'I' as TipoCol
			from   #Tmp
			where codigo like '410101%'
--
insert into #TmpConso (codigo,nombre) values ('','')
insert into #TmpConso (codigo,nombre) values ('','   INGRESOS POR PRESTACION DE SERVICIOS   ')
--inserto ingresos por prestación de servicios
insert into #TmpConso
select codigo,nombre,sum(sv) as sv,sum(sv_ant) as sv_ant,sum(dif) as dif,
		sum(acumulado)as acumulado,sum(presup_mens) as presup_mens,
		sum(presup_anual) as presup_anual,sum(porcent_mens) as porcent_mens,
		sum(porcent_anual) as porcent_anual,'N' as TipoCol
from #Tmp
where codigo like '4102%'
group by codigo,nombre
order by codigo

-- inserto total por prestación de servicios
insert into #TmpConso 
			select '' as codigo,'  TOTAL  ' as nombre,sum(sv),sum(sv_ant),sum(dif),sum(acumulado),sum(presup_mens),
					sum(presup_anual),0 as porcent_mens,0 as porcent_anual,'I' as TipoCol
			from   #Tmp
			where codigo like '4102%'
--
insert into #TmpConso (codigo,nombre) values ('','')

-- Inserto ingresos Financieros

insert into #TmpConso (codigo,nombre) values ('','INGRESOS FINANCIEROS')

insert into #TmpConso
select codigo,nombre,sum(sv) as sv,sum(sv_ant) as sv_ant,sum(dif) as dif,
		sum(acumulado)as acumulado,sum(presup_mens) as presup_mens,
		sum(presup_anual) as presup_anual,sum(porcent_mens) as porcent_mens,
		sum(porcent_anual) as porcent_anual,'N' as TipoCol
from #Tmp
where codigo like '4103%'
group by codigo,nombre
order by codigo

-- inserto total de ingresos financieros

insert into #TmpConso 
			select '' as codigo,'  TOTAL  ' as nombre,sum(sv),sum(sv_ant),sum(dif),sum(acumulado),sum(presup_mens),
					sum(presup_anual),0 as porcent_mens,0 as porcent_anual,'I' as TipoCol
			from   #Tmp
			where codigo like '4103%'
--

if ((select count(codigo)
		from #Tmp
		where codigo like '4104%') >0) 
	BEGIN
	insert into #TmpConso (codigo,nombre) values ('','OTROS INGRESOS NO OPERACIONALES')
	
	insert into #TmpConso
	select codigo,nombre,sum(sv) as sv,sum(sv_ant) as sv_ant,sum(dif) as dif,
			sum(acumulado)as acumulado,sum(presup_mens) as presup_mens,
			sum(presup_anual) as presup_anual,sum(porcent_mens) as porcent_mens,
			sum(porcent_anual) as porcent_anual,'N' as TipoCol
	from #Tmp
	where codigo like '4104%'
	group by codigo,nombre
	order by codigo

	--- total de ingresos no operacionales
	
	insert into #TmpConso 
				select '' as codigo,'  TOTAL  ' as nombre,sum(sv),sum(sv_ant),sum(dif),sum(acumulado),sum(presup_mens),
						sum(presup_anual),0 as porcent_mens,0 as porcent_anual,'I' as TipoCol
				from   #Tmp
				where codigo like '4104%'
	END

-- inserto las devoluciones y rebajas sobre ventas
insert into #TmpConso (codigo,nombre) values ('','REBAJAS Y DEVOLUCIONES SOBRE VENTAS')

insert into #TmpConso
select codigo,nombre,sum(sv) as sv,sum(sv_ant) as sv_ant,sum(dif) as dif,
		sum(acumulado)as acumulado,sum(presup_mens) as presup_mens,
		sum(presup_anual) as presup_anual,sum(porcent_mens) as porcent_mens,
		sum(porcent_anual) as porcent_anual,'N' as TipoCol
from #Tmp
where codigo like '6104%'
group by codigo,nombre
order by codigo

-- total de devoluciones y rebajas sobre ventas
insert into #TmpConso (codigo,nombre) values ('','')
insert into #TmpConso 
			select '' as codigo,'  TOTAL  ' as nombre,sum(sv),sum(sv_ant),sum(dif),sum(acumulado),sum(presup_mens),
					sum(presup_anual),0 as porcent_mens,0 as porcent_anual,'I' as TipoCol
			from   #Tmp
			where codigo like '6104%'

-- insertando total de los ingresos

insert into #TmpConso (codigo,nombre) values ('','')
insert into #TmpConso 
			select '' as codigo,'  TOTAL  INGRESOS ' as nombre,sum(sv),sum(sv_ant),sum(dif),sum(acumulado),sum(presup_mens),
					sum(presup_anual),0 as porcent_mens,0 as porcent_anual,'' as TipoCol
			from   #TmpConso
			where TipoCol = 'I'

-- Insertando Costos de Venta
insert into #TmpConso (codigo,nombre) values ('','')
insert into #TmpConso (codigo,nombre) values ('','   COSTO POR VENTA DE PRODUCTOS   ')
insert into #TmpConso 
select codigo,nombre,sum(sv) as sv,sum(sv_ant) as sv_ant,sum(dif) as dif,
		sum(acumulado)as acumulado,sum(presup_mens) as presup_mens,
		sum(presup_anual) as presup_anual,sum(porcent_mens) as porcent_mens,
		sum(porcent_anual) as porcent_anual,'N' as TipoCol
from #Tmp
where codigo like '510101%'
group by codigo,nombre
order by codigo

-- Insertando total de costo de venta por productos
insert into #TmpConso 
			select '' as codigo,'  TOTAL  ' as nombre,sum(sv),sum(sv_ant),sum(dif),sum(acumulado),sum(presup_mens),
					sum(presup_anual),0 as porcent_mens,0 as porcent_anual,'C' as TipoCol
			from   #Tmp
			where codigo like '510101%'

-- Insertando Costos de Venta por Regalías

insert into #TmpConso (codigo,nombre) values ('','')
insert into #TmpConso (codigo,nombre) values ('','   COSTO POR REGALIAS   ')
insert into #TmpConso 
select codigo,nombre,sum(sv) as sv,sum(sv_ant) as sv_ant,sum(dif) as dif,
		sum(acumulado)as acumulado,sum(presup_mens) as presup_mens,
		sum(presup_anual) as presup_anual,sum(porcent_mens) as porcent_mens,
		sum(porcent_anual) as porcent_anual,'N' as TipoCol
from #Tmp
where codigo like '510102%'
group by codigo,nombre
order by codigo

-- Insertando total de costo por regalías
insert into #TmpConso 
			select '' as codigo,'  TOTAL  ' as nombre,sum(sv),sum(sv_ant),sum(dif),sum(acumulado),sum(presup_mens),
					sum(presup_anual),0 as porcent_mens,0 as porcent_anual,'C' as TipoCol
			from   #Tmp
			where codigo like '510102%'

-- Insertando total de Costo de Ventas
insert into #TmpConso (codigo, nombre) values ('','')
insert into #TmpConso 
			select '' as codigo,'  TOTAL COSTO DE VENTAS ' as nombre,sum(sv),sum(sv_ant),sum(dif),sum(acumulado),sum(presup_mens),
					sum(presup_anual),0 as porcent_mens,0 as porcent_anual,'' as TipoCol
			from   #TmpConso
			where TipoCol = 'C'

-- Insertando Costos de Servicios

insert into #TmpConso (codigo,nombre) values ('','')
insert into #TmpConso (codigo,nombre) values ('','   COSTO POR SERVICIOS   ')
insert into #TmpConso 
select codigo,nombre,sum(sv) as sv,sum(sv_ant) as sv_ant,sum(dif) as dif,
		sum(acumulado)as acumulado,sum(presup_mens) as presup_mens,
		sum(presup_anual) as presup_anual,sum(porcent_mens) as porcent_mens,
		sum(porcent_anual) as porcent_anual,'N' as TipoCol
from #Tmp
where codigo like '520101%'
group by codigo,nombre
order by codigo

-- Insertando total de costo por regalías
insert into #TmpConso 
			select '' as codigo,'  TOTAL  ' as nombre,sum(sv),sum(sv_ant),sum(dif),sum(acumulado),sum(presup_mens),
					sum(presup_anual),0 as porcent_mens,0 as porcent_anual,'C' as TipoCol
			from   #Tmp
			where codigo like '520101%'

-- Insertando total de Costo de Ventas
insert into #TmpConso (codigo, nombre) values ('','')
insert into #TmpConso 
			select '' as codigo,'  TOTAL COSTO DE VENTAS ' as nombre,sum(sv),sum(sv_ant),sum(dif),sum(acumulado),sum(presup_mens),
					sum(presup_anual),0 as porcent_mens,0 as porcent_anual,'' as TipoCol
			from   #TmpConso
			where TipoCol = 'C'

-- Insertando utilidad bruta
insert into #TmpConso (codigo, nombre) values ('','')
insert into #TmpConso 
			select '' as codigo,'  UTILIDAD BRUTA ' as nombre,sum(sv),sum(sv_ant),sum(dif),sum(acumulado),sum(presup_mens),
					sum(presup_anual),0 as porcent_mens,0 as porcent_anual,'U' as TipoCol
			from   #TmpConso
			where TipoCol = 'I' or TipoCol = 'C'


-- Insertando Gastos Operativos
insert into #TmpConso (codigo, nombre) values ('','')
insert into #TmpConso (codigo,nombre) values ('','    * GASTOS *     ')
insert into #TmpConso 
select codigo,nombre,sum(sv) as sv,sum(sv_ant) as sv_ant,sum(dif) as dif,
		sum(acumulado)as acumulado,sum(presup_mens) as presup_mens,
		sum(presup_anual) as presup_anual,sum(porcent_mens) as porcent_mens,
		sum(porcent_anual) as porcent_anual,'N' as TipoCol
from #Tmp
where codigo like '61%' AND codigo NOT LIKE '6104%'
group by codigo,nombre
order by codigo

-- Insertando Gastos Operativos
insert into #TmpConso 
select codigo,nombre,sum(sv) as sv,sum(sv_ant) as sv_ant,sum(dif) as dif,
		sum(acumulado)as acumulado,sum(presup_mens) as presup_mens,
		sum(presup_anual) as presup_anual,sum(porcent_mens) as porcent_mens,
		sum(porcent_anual) as porcent_anual,'N' as TipoCol
from #Tmp
where codigo like '62%' AND codigo NOT LIKE '6104%'
group by codigo,nombre
order by codigo

-- Insertando total de Gastos
insert into #TmpConso (codigo, nombre) values ('','')
insert into #TmpConso 
			select '' as codigo,'  TOTAL GASTOS ' as nombre,sum(sv),sum(sv_ant),sum(dif),sum(acumulado),sum(presup_mens),
					sum(presup_anual),0 as porcent_mens,0 as porcent_anual,'G' as TipoCol
			from  #TmpConso
			where (codigo like '61%' or codigo like '62%') and codigo not like '6104%'


-- Insertando utilidad antes de impuestos
insert into #TmpConso (codigo, nombre) values ('','')
insert into #TmpConso (codigo, nombre) values ('','')
insert into #TmpConso 
			select '' as codigo,'  UTILIDAD AI ' as nombre,sum(sv),sum(sv_ant),sum(dif),sum(acumulado),sum(presup_mens),
					sum(presup_anual),0 as porcent_mens,0 as porcent_anual,'' as TipoCol
			from   #TmpConso
			where TipoCol = 'U' or TipoCol = 'G'

-- Actualizo los porcentajes de ejecución
UPDATE #TmpConso SET porcent_mens=round(((sv/presup_mens)*100),2) WHERE TipoCol = 'N' and presup_mens <>0
update #TmpConso set porcent_anual = round(((acumulado/presup_anual)*100),2) where TipoCol = 'N' and presup_mens <>0
--
SET @campos= 'CODIGO,NOMBRE,SV ' + @Anyo_ACT + ', SV_ANT ' + @Anyo_ANT 
SET @camposTot= ' SELECT ' + @campos + ',DIF AS Diferencia,ACUMULADO as Acumulado,PRESUP_MENS AS [Presupuesto Mensual],PRESUP_ANUAL AS [Presupuesto Anual],PORCENT_MENS AS [Porcentaje Mensual],PORCENT_ANUAL AS [Porcentaje Anual] FROM #TmpConso'

exec ( @CamposTot )

drop table #Tmp 
drop table #TmpConso

/*
SELECT * from vmdo.dbo.ortt order by ratedate desc
*/
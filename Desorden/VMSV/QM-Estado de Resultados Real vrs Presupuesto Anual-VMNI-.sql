create table #Tmp 
				(
		CODIGO		VARCHAR(100) NULL,
		NOMBRE NVARCHAR(100) NULL,
		SV NUMERIC(19,4) NULL,
		SV_ANT NUMERIC(19,4) NULL,
		DIF 		NUMERIC(19,4) NULL,
		ACUMULADO NUMERIC(19,4) NULL,
		PRESUP_MENS NUMERIC(19,4) NULL,
		PRESUP_ANUAL NUMERIC(19,4) NULL,
		PORCENT_MENS 	NUMERIC(19,4) NULL,
		PORCENT_ANUAL NUMERIC(19,4) NULL
				)

create table #ESMeses  
				(
		Codigo nvarchar(100) , 
		Nombre nvarchar(100) ,
		Enero numeric(18,4) default 0,
		Enero_Presup numeric (18,4) default 0,
		Febrero numeric(18,4) default 0,	
		Febrero_Presup numeric(18,4) default 0,
		Marzo numeric(18,4) default 0,
		Marzo_Presup numeric(18,4) default 0,
		Abril numeric(18,4) default 0,
		Abril_Presup numeric(18,4) default 0,
		Mayo numeric(18,4) default 0,
		Mayo_Presup numeric(18,4) default 0,
		Junio Numeric(18,4) default 0,
		Junio_Presup numeric(18,4) default 0,
		Julio Numeric(18,4) default 0,
		Julio_Presup numeric(18,4) default 0,
		Agosto Numeric(18,4) default 0,
		Agosto_Presup numeric(18,4) default 0,
		Septiembre Numeric(18,4) default 0,
		Septiembre_Presup numeric(18,4) default 0,
		Octubre Numeric(18,4) default 0,
		Octubre_Presup numeric (18,4) default 0,
		Noviembre numeric(18,4) default 0,
		Noviembre_Presup numeric (18,4) default 0,
		Diciembre	numeric(18,4) default 0,
		Diciembre_Presup Numeric (18,4) default 0,
		Total numeric(18,4) default 0,
		Total_Presup numeric (18,4) default 0,
		Presup_Anual numeric (18,4) default 0,
		TipoCol varchar(10)
				)

create table #Estado  
				(
		Codigo nvarchar(100) ,
		Nombre nvarchar(100) ,
		Enero numeric(18,4) default 0,
		Enero_Presup numeric (18,4) default 0,
		Febrero numeric(18,4) default 0,	
		Febrero_Presup numeric(18,4) default 0,
		Marzo numeric(18,4) default 0,
		Marzo_Presup numeric (18,4) default 0,
		Abril numeric(18,4) default 0,
		Abril_Presup numeric (18,4) default 0,
		Mayo numeric(18,4) default 0,
		Mayo_Presup numeric (18,4) default 0,
		Junio Numeric(18,4) default 0,
		Junio_Presup numeric (18,4) default 0,
		Julio Numeric(18,4) default 0,
		Julio_Presup numeric (18,4) default 0,
		Agosto Numeric(18,4) default 0,
		Agosto_Presup numeric(18,4) default 0,
		Septiembre Numeric(18,4) default 0,
		Septiembre_Presup numeric (18,4) default 0,
		Octubre Numeric(18,4) default 0,
		Octubre_Presup numeric(18,4) default 0,
		Noviembre numeric(18,4) default 0,
		Noviembre_Presup numeric (18,4) default 0,
		Diciembre	numeric(18,4) default 0,
		Diciembre_Presup numeric (18,4) default 0,
		Total numeric(18,4) default 0,
		Total_Presup numeric (18,4) default 0,
		Presup_Anual numeric (18,4) default 0,
		TipoCol varchar(10)
				)

declare @nInDesign		AS int,
		@dFechaIni		AS DATETIME,
		@dFechaFin		AS DATETIME,
		@dFechaIniAcum	AS DATETIME,
		@Tc as numeric(10,2),
		@nNivel as int,
		@nYear as int 

set @nInDesign	= 1

if (@nInDesign = 1)
	begin
		set @dFechaIni		= '01/01/2012 00:00:00'
		set @dFechaFin		= '01/31/2012 00:00:00'
		set @dFechaIniAcum	= '01/01/'+convert(char(4),@nYear)
		set @nNivel			= 3
		set @Tc				= 1
	end
else
	begin
		/* SELECT RefDate FROM DBO.JDT1 T0 */
		SET @dFechaIni = /* T0.RefDate */'[%0]'
		SET @dFechaFin = /* T0.RefDate */'[%1]'
        set @nYear = year(@dFechaIni)
		SET @dFechaIniAcum = '01/01/'+convert(char(4),@nYear)
		/* select Levels from dbo.oact T2 */
		set @nNivel	= /* T2.Levels */'[%3]'

	end

if (@nNivel not in (3,4,5))
	begin
		set @nNivel = 3
	end

exec vmsv.dbo.EstadoResultadoRealvrsPresupuesto 'VMNI',@dFechaIni,@dFechaFin,@dFechaIniAcum,@nNivel,@Tc,1


-- Formateo el Estado de Resultados en base a las cuentas correspondientes.

exec vmsv.DBO.FormatoEstado @nNivel

-- Estes el momento en donde la consulta se genera de acuerdo a los meses solicitados

declare @sSql as nvarchar(max)

set @sSql = 'select codigo as [Cuenta],nombre as [Nombre de la Cuenta]'

if ((select count(enero) from #Estado where enero <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql + ',Enero,Enero_Presup as [Presup.],
							case Enero_Presup
								when 0 then null else (Enero/Enero_Presup) end as [(%)]'
	end
if ((select count(Febrero) from #Estado where febrero <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql +  ',Febrero,Febrero_Presup as [Presup.],
							case Febrero_Presup
								when 0 then null else (Febrero/Febrero_Presup) end as [(%)]'
	end
if ((select count(Marzo) from #Estado where marzo <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql +  ',Marzo,Marzo_Presup as [Presup.],
							case Marzo_Presup
								when 0 then null else (Marzo/Marzo_Presup) end as [(%)]'
	end
if ((select count(Abril) from #Estado where abril <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql +  ',Abril,Abril_Presup as [Presup.],
							case Abril_Presup
								when 0 then null else (Abril/Abril_Presup) end as [(%)]'
	end
if ((select count(Mayo) from #Estado where mayo <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql +  ',Mayo,Mayo_Presup as [Presup.],
							case Mayo_Presup
								when 0 then null else (Mayo/Mayo_Presup) end as [(%)]'
	end
if ((select count(Junio) from #Estado where junio <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql +  ',Junio,Junio_Presup as [Presup.],
							case Junio_Presup
								when 0 then null else (Junio/Junio_Presup) end as [(%)]'
	end
if ((select count(Julio) from #Estado where julio <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql +  ',Julio,Julio_Presup as [Presup.],
							case Julio_Presup
								when 0 then null else (Julio/Julio_Presup) end as [(%)]'
	end
if ((select count(Agosto) from #Estado where agosto <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql +  ',Agosto,Agosto_Presup as [Presup.],
							case Agosto_Presup
								when 0 then null else (Agosto/Agosto_Presup) end as [(%)]'
	end
if ((select count(Septiembre) from #Estado where septiembre <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql +  ',Septiembre,Septiembre_Presup as [Presup.],
							case Septiembre_Presup
								when 0 then null else (Septiembre/Septiembre_Presup) end as [(%)]'
	end
if ((select count(octubre) from #Estado where octubre <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql + ',Octubre,Octubre_Presup as [Presup.],
							case Octubre_Presup
								when 0 then null else (Octubre/Octubre_Presup) end as [(%)]'
	end
if ((select count(noviembre) from #Estado where noviembre <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql + ',Noviembre,Noviembre_Presup as [Presup.],
							case Noviembre_Presup
								when 0 then null else (Noviembre/Noviembre_Presup) end as [(%)]'
	end
if ((select count(Diciembre) from #Estado where diciembre <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql + ',Diciembre,Diciembre_Presup as [Presup.],
							case Diciembre_Presup
								when 0 then null else (Diciembre/Diciembre_Presup) end as [(%)]'
	end

set @sSql = @sSql + ',Total as [Acumulado Real],Total_Presup as [Acumulado Presup.],Presup_Anual,
							 case Presup_Anual
								when 0 then null else (Total/Presup_Anual) end as [(%)] from #Estado '

--Actualizo a valores nulos los ceros para no ser mostrados en SAP
update #Estado set enero = null where enero = 0
update #Estado set Enero_Presup = null where Enero_Presup = 0
--
update #Estado set Febrero = null where Febrero = 0
update #Estado set Febrero_Presup = null where Febrero_Presup = 0
--
update #Estado set marzo = null where Marzo = 0
update #Estado set Marzo_Presup = null where Marzo_Presup = 0
--
update #Estado set Abril = null where Abril = 0
update #Estado set Abril_Presup = null where Abril_Presup = 0
--
update #Estado set Mayo = null where Mayo = 0
update #Estado set Mayo_Presup = null where Mayo_Presup = 0
--
update #Estado set Junio = null where Junio = 0
update #Estado set Junio_Presup = null where Junio_Presup = 0
--
update #Estado set julio = null where Julio = 0
update #Estado set julio_Presup = null where Julio_Presup = 0
--
update #Estado set agosto = null where Agosto = 0
update #Estado set agosto_Presup = null where Agosto_Presup = 0
--
update #Estado set septiembre = null where Septiembre = 0
update #Estado set septiembre_Presup = null where Septiembre_Presup = 0
--
update #Estado set octubre = null where Octubre = 0
update #Estado set octubre_Presup = null where Octubre_Presup = 0
--
update #Estado set Noviembre = null where Noviembre = 0
update #Estado set Noviembre_Presup = null where Noviembre_Presup = 0
--
update #Estado set diciembre = null where Diciembre = 0
update #Estado set diciembre_Presup = null where Diciembre_Presup = 0
--
update #Estado set total = null where total = 0
update #Estado set total_Presup = null where total_Presup = 0
--
update #Estado set presup_anual = null where presup_anual = 0

delete from #Estado where (total = 0 or total is null) and codigo is not null and nombre is not null and TipoCol <> 'TTC' and (Total_Presup = 0 or Total_Presup is null)

exec ( @sSql )

drop table #Estado,#Tmp,#ESMeses

--select * from prgt.dbo.ortt order by ratedate desc
create table #Tmp (
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

create table #ESMeses  (
		Codigo nvarchar(100) , 
		Nombre nvarchar(100) ,
		Enero numeric(18,4) ,
		Febrero numeric(18,4) ,	
		Marzo numeric(18,4) ,
		Abril numeric(18,4) ,
		Mayo numeric(18,4) ,
		Junio Numeric(18,4) ,
		Julio Numeric(18,4) ,
		Agosto Numeric(18,4) ,
		Septiembre Numeric(18,4) ,
		Octubre Numeric(18,4) ,
		Noviembre numeric(18,4) ,
		Diciembre	numeric(18,4) ,	
		Total numeric(18,4),
		TipoCol varchar(10)
						)
create table #Estado  (
		Codigo nvarchar(100) ,
		Nombre nvarchar(100) ,
		Enero numeric(18,4) ,
		Febrero numeric(18,4) ,	
		Marzo numeric(18,4) ,
		Abril numeric(18,4) ,
		Mayo numeric(18,4) ,
		Junio Numeric(18,4) ,
		Julio Numeric(18,4) ,
		Agosto Numeric(18,4) ,
		Septiembre Numeric(18,4) ,
		Octubre Numeric(18,4) ,
		Noviembre numeric(18,4) ,
		Diciembre	numeric(18,4) ,	
		Total numeric(18,4) ,
		TipoCol varchar(10)
						)

declare @nInDesign		AS int,
		@dFechaIni		AS DATETIME,
		@dFechaFin		AS DATETIME,
		@dFechaIniAcum	AS DATETIME,
		@Tc as numeric(10,2),
		@nNivel as int

set @nInDesign = 1

if (@nInDesign = 1)
	begin
		set @dFechaIni		= '01/01/2010 00:00:00'
		set @dFechaFin		= '05/31/2010 00:00:00'
		set @dFechaIniAcum	= '01/01/2010 00:00:00'
		set @nNivel			= 5
		set @Tc				= 8
	end
else
	begin
		/* SELECT FROM DBO.JDT1 T0*/
		SET @dFechaIni = /* T0.RefDate */'[%0]'
		SET @dFechaFin = /* T0.RefDate*/'[%1]'
		SET @dFechaIniAcum = '01/01/2010 00:00:00'
		/* select Levels from dbo.oact T1 */
--		set @nNivel	= /* T1.Levels */'[%2]'
--		/* select rate from dbo.ortt T2 */
--		set @Tc = /* T2.rate */'[%3]'
	end

if (@nNivel not in (3,4,5))
	begin
		set @nNivel = 3
	end

exec ISMSV.dbo.EstadoResultadoxMeses 'ISMSV',@dFechaIni,@dFechaFin,@dFechaIniAcum,@nNivel,@Tc

-- Formateo el Estado de Resultados en base a las cuentas correspondientes.

exec ISMSV.DBO.EstadoResulFormato @nNivel
--
declare @sSql as nvarchar(400)
--
set @sSql = 'select codigo as [Cuenta],nombre as [Nombre de la Cuenta]'

if ((select count(enero) from #Estado where enero <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql + ',Enero'
	end
if ((select count(Febrero) from #Estado where febrero <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql +  ',Febrero'
	end
if ((select count(Marzo) from #Estado where marzo <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql +  ',Marzo'
	end
if ((select count(Abril) from #Estado where abril <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql +  ',Abril'
	end
if ((select count(Mayo) from #Estado where mayo <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql +  ',Mayo'
	end
if ((select count(Junio) from #Estado where junio <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql +  ',Junio'
	end
if ((select count(Julio) from #Estado where julio <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql +  ',Julio'
	end
if ((select count(Agosto) from #Estado where agosto <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql +  ',Agosto'
	end
if ((select count(Septiembre) from #Estado where septiembre <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql +  ',Septiembre'
	end
if ((select count(octubre) from #Estado where octubre <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql + ',Octubre'
	end
if ((select count(noviembre) from #Estado where noviembre <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql + ',Noviembre'
	end
if ((select count(Diciembre) from #Estado where diciembre <> 0 and TipoCol='UI')>0)
	begin
		set @sSql = @sSql + ',Diciembre'
	end
if ((select count(Total) from #Estado where total <>0 and TipoCol = 'UI')> 0)
	begin
		set @sSql = @sSql + ',Total from #Estado '
	end

delete from #Estado where total = 0 and codigo is not null and nombre is not null and TipoCol <> 'TTC'

exec ( @sSql )

drop table #Estado,#Tmp,#ESMeses
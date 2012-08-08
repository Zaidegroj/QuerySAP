/* SIG Unidades */

DECLARE @dFechaIni as datetime,
		@dFechaFin as datetime,
		@sGrupoIni	as varchar(100),
		@sGrupoFin as varchar(100),
		@iInDesign as int


CREATE TABLE #Conso_VM
    (	
		Codigo varchar(20) ,
		descripcion varchar(100),
		Grupo smallint ,
		nombre	NCHAR(100) ,
		GT		NUMERIC(19,4)  ,
		SV		NUMERIC(19,4)  ,
		HN		NUMERIC(19,4)  ,
		CR		NUMERIC(19,4)  ,
		PA		NUMERIC(19,4)  ,
		DO  	NUMERIC(19,4)  ,
		TOTAL	NUMERIC(19,4)  
	)


set @iInDesign = 1

if (@iInDesign = 1)
	begin
		set @dFechaIni	= '01/01/2011 00:00:00'
		set @dFechaFin	= '01/31/2011 00:00:00'
		set @sGrupoIni	= 'ALBUMES Y TARJETAS'
		set @sGrupoFin	= 'VIDEOJUEGOS'
	end
else
	begin
		/* SELECT FROM VMSV.DBO.OINV T0 */
		SET @dFechaIni = /* T0.DocDate */'[%0]'
        /* SELECT FROM VMSV.DBO.OINV T1 */
		SET @dFechaFin = /* T1.DocDate */'[%1]'
		/* SELECT FROM vmsv.dbo.OITB T2 */
		set @sGrupoIni = /* T2.ItmsGrpNam */ '[%2]'
		SET @sGrupoFin = /* T2.ItmsGrpNam */ '[%3]'
	end

insert into #Conso_VM
exec ConsoUnidadesVendidas @dFechaIni,@dFechaFin,@sGrupoIni,@sGrupoFin

--Actualizo total
update #Conso_VM set total = gt+sv+hn+cr+pa+do
--
--
select Codigo as [Código],descripcion as [Descripción],Grupo,Nombre,
		gt as [Guatemala],
		sv as [El Salvador],
		hn as [Honduras],
		cr as [Costa Rica],
		pa as [Panamá],
		do as [Dominicana],
		Total 
from #Conso_VM

drop table #Conso_VM
--
----select * from oinv
----select top 1 CardName from ocrd order by CardName asc
----select * from inv1
----select * from oitm where itmsgrpcod = 100 order by onhand desc
----select * from oitb
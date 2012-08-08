declare @nSaldo numeric (18,4),
		@dFechaIni datetime,
		@dFechaFin datetime,
		@cCuenta varchar(20),
		@cCuentaProceso varchar(20),
		@sDescripcion varchar(100),
		@nNivel		as int,
		@nSemanaInicial as int,
		@nSemanaFinal as int

	
set @dFechaIni		= '05/01/2011 00:00:00'
set @dFechaFin		= '05/31/2011 00:00:00'
set @cCuentaProceso = '5'
set @nNivel			= 5


--select	(select Debit,credit from jdt1 )  --where datepart(week,refdate)=datepart(week,@dFechaIni))
----		(select datepart(week,dateadd(week,1,@dFechaIni))),
----		(select datepart(week,dateadd(week,2,@dFechaIni))),
----		(select datepart(week,dateadd(week,3,@dFechaIni)))
--from    jdt1
--where   refdate between @dFechaIni and @dFechaFin


--select t2.U_descripcion,isnull(case	substring(t2.u_cuenta,1,1)
--		when '1' then isnull(sum(T0.Debit),0)-isnull(sum(T0.Credit),0)
--		when '2' then isnull(SUM(T0.Credit),0)-isnull(SUM(T0.Debit),0) 
--		when '3' then isnull(SUM(T0.Credit),0)-isnull(SUM(T0.Debit),0)
--		when '4' then isnull(SUM(T0.Credit),0)-isnull(SUM(T0.Debit),0)
--		when '5' then isnull(sum(T0.Debit),0)-isnull(sum(T0.Credit),0)
--		when '6' then isnull(sum(T0.Debit),0)-isnull(sum(T0.Credit),0)
--				end ,0)
--FROM	DBO.JDT1 T0  INNER JOIN DBO.OACT T1 ON T0.Account = T1.AcctCode	
--		inner join [@FlujoEfectivo] T2 on T1.FormatCode = T2.U_Cuenta
--WHERE	T0.[RefDate] >=@dFechaIni AND T0.[RefDate] <=@dFechaFin 
--group by t2.u_Descripcion,t2.u_cuenta

---select * from jdt1
---select * from oact
---select * from [@flujoefectivo]

select @dFechaIni,@dFechaFin

DECLARE @date_string NCHAR(6) 
SELECT  @date_string = N'200852' 
SELECT DATEADD( 
           WEEK, 
           CAST(RIGHT(@date_string, 2) AS INT), 
           DATEADD( 
               YEAR, 
               CAST(LEFT(@date_string, 4) AS INT) - 1900, 
               0 
           ) 
       ) 
--Query para SAP
--Declaración de Variables

declare @dFechaIni	as datetime,
		@dFechaFin	as datetime,
		@nNivel		as int,
		@Tc			as numeric(18,4),
		@nInDesign	as int,
		@Codigo		as varchar(30),
		@nSaldo		as numeric(18,4)

set @nInDesign = 1

set @Codigo = '1106%'

if (@nInDesign = 1)
	begin
		set @dFechaIni		= '01/01/2010 00:00:00'
		set @dFechaFin		= '12/31/2010 00:00:00'
		set @nNivel			= 3
	end
SELECT     ISNULL(CASE substring(@Codigo, 1, 1) WHEN '1' THEN isnull(SUM(T0.Debit), 0) - isnull(SUM(T0.Credit), 0) WHEN '2' THEN isnull(SUM(T0.Credit), 0) 
                      - isnull(SUM(T0.Debit), 0) WHEN '3' THEN isnull(SUM(T0.Credit), 0) - isnull(SUM(T0.Debit), 0) WHEN '4' THEN isnull(SUM(T0.Credit), 0) 
                      - isnull(SUM(T0.Debit), 0) WHEN '5' THEN isnull(SUM(T0.Debit), 0) - isnull(SUM(T0.Credit), 0) WHEN '6' THEN isnull(SUM(T0.Debit), 0) 
                      - isnull(SUM(T0.Credit), 0) END, 0) AS Expr1
FROM         JDT1 AS T0 INNER JOIN
                      OACT AS T2 ON T0.Account = T2.AcctCode
WHERE     (T0.RefDate >= @dFechaIni) AND (T0.RefDate <= @dFechaFin) AND (T2.FormatCode LIKE @Codigo)



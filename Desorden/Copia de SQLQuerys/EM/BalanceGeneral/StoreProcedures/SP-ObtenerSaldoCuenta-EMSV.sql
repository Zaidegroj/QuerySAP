set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go




create PROCEDURE [dbo].[ObtenerSaldoCuenta]

@FechaIni 		AS DATETIME,
@FechaFin 		AS DATETIME,
@Codigo 		AS VARCHAR(40),
@nSaldo			as numeric(18,4) output

AS
Begin
	SELECT @nSaldo = isnull(SUM(T0.Credit)-SUM(T0.Debit),0)
	FROM DBO.JDT1 T0  INNER JOIN DBO.OJDT T1 ON T0.TransId = T1.TransId
		INNER JOIN DBO.OACT T2 ON T0.Account = T2.AcctCode
	WHERE T0.[RefDate] >=@FechaIni AND T0.[RefDate] <=@FechaFin AND  T2.FormatCode  LIKE @Codigo
end



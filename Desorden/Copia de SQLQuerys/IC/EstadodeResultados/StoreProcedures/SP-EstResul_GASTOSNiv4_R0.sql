set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


-- =============================================
-- Author:Helena Lopez
-- Create date: 10/03/2010
-- Description:	SP Utilizado en Q Est. Resul .. Genera los Gastos a nivel 3
-- Actualizacion: Incorporar acumulado real
-- =============================================

ALTER  PROCEDURE [dbo].[EstResul_GASTOSNiv4_R0]

@FechaIni 		AS DATETIME,
@FechaFin 		AS DATETIME,
@FechaIni_ANT 		AS DATETIME,
@FechaFin_ANT 		AS DATETIME,
@Ejerc  		AS NVARCHAR(20),
@FechaIniAcum 		AS DATETIME,
@Mes_Ini		AS INT,
@Mes_Fin		AS INT,
@Codigo 		AS VARCHAR(8)	


AS

/*--- Est seg difiere en relacion a los ingresos y costos ya que:*/
/*1. El despliegue final se hace a nivel 4, */

/*la insercion al tmp (tmp_totales) q se despliega toda la data esta casi al final de este segmento*/


/*-- INGRESANDO LA DATA EN DETALLE DE NIVEL 4 PARA LUEGO SUMARIZAR X CUENTA DE  NIVEL 3, EN EL JOIN DE LOS 2 TEMP */
INSERT INTO #Tmp1 
SELECT Cod_SYS,Nombre,Codigo AS Codigo,SUM(Saldo) AS SV, SUM(SV_ANT) AS SV_ANT,SUM(SaldoAcum) AS ACUMULADO,
	SUM(Presup_mens*-1) AS Presup_mens,SUM(Presup_anual*-1) AS Presup_anual 
FROM (

SELECT  
	T0.Account			AS Cod_SYS, 
	T2.AcctName			AS Nombre,
	SUBSTRING(T2.FormatCode,1,6)	AS Codigo, 	
	SUM(T0.Credit)-SUM(T0.Debit)	AS Saldo,
	0 				AS SV_ANT,
	0				AS SaldoAcum,
	0				AS Presup_mens,
	0 				AS Presup_anual
FROM DBO.JDT1 T0  INNER JOIN DBO.OJDT T1 ON T0.TransId = T1.TransId 
	INNER JOIN DBO.OACT T2 ON T0.Account = T2.AcctCode 
WHERE T0.[RefDate] >=@FechaIni AND T0.[RefDate] <=@FechaFin AND  T2.FormatCode  LIKE @Codigo
		--AND T2.FormatCode NOT LIKE '6104%'
GROUP BY T0.Account,T2.AcctName,T2.FormatCode

UNION ALL

SELECT
	T3.AcctCode 			AS Cod_SYS,
	T5.AcctName				AS Nombre,
	SUBSTRING(T5.FormatCode,1,6)	AS Codigo, 
	0				AS Saldo,
	0 				AS SV_ANT,
	0				AS SaldoAcum,
	SUM(T4.DebLTotal)		AS Presup_mens,
	MAX(T3.DebLTotal)		AS Presup_anual

FROM OBGT T3 INNER JOIN BGT1 T4 ON T4.BudgId=T3.AbsId
INNER JOIN OACT T5 ON T3.AcctCode=T5.AcctCode 
	WHERE	T3.FinancYear=@Ejerc
	AND T4.Line_ID>= @Mes_Ini-1
	AND T4.Line_ID<= @Mes_Fin-1
	AND  T5.FormatCode  LIKE @Codigo
	--AND T5.FormatCode NOT LIKE '6104%'
GROUP BY T3.AcctCode,T5.AcctName,T5.FormatCode


) T0 GROUP BY Cod_SYS,Nombre,Codigo --HAVING SUM(Saldo)<>0

UNION ALL


/*extrac data año en comparacion*/
/*---para el año en comparacion no se esta tomando data del presupuesto--- */
SELECT  
	T0.Account			AS Cod_SYS, 
	T2.AcctName			AS Nombre,
	SUBSTRING(T2.FormatCode,1,6)	AS Codigo, 	
	0				AS Saldo,
	SUM(T0.Credit)-SUM(T0.Debit)  	AS SV_ANT,
	0				AS SaldoAcum,
	0				AS Presup_mens,
	0 				AS Presup_anual
	

FROM DBO.JDT1 T0  INNER JOIN DBO.OJDT T1 ON T0.TransId = T1.TransId 
	INNER JOIN DBO.OACT T2 ON T0.Account = T2.AcctCode 
	
WHERE T0.[RefDate] >=@FechaIni_ANT AND T0.[RefDate] <=@FechaFin_ANT AND  T2.FormatCode  LIKE @Codigo
		--AND T2.FormatCode NOT LIKE '6104%'
GROUP BY T0.Account,T2.AcctName,T2.FormatCode

UNION ALL

SELECT  
	T0.Account			AS Cod_SYS, 
	T2.AcctName			AS Nombre,
	SUBSTRING(T2.FormatCode,1,6)	AS Codigo, 	
	0				AS Saldo,
	0 				AS SV_ANT,
	SUM(T0.Credit)-SUM(T0.Debit)	AS SaldoAcum,
	0				AS Presup_mens,
	0 				AS Presup_anual
	

FROM DBO.JDT1 T0  INNER JOIN DBO.OJDT T1 ON T0.TransId = T1.TransId 
	INNER JOIN DBO.OACT T2 ON T0.Account = T2.AcctCode 
	
WHERE T0.[RefDate] >=@FechaIniAcum AND T0.[RefDate] <=@FechaFin AND  T2.FormatCode  LIKE @Codigo
		--AND T2.FormatCode NOT LIKE '6104%'
GROUP BY T0.Account,T2.AcctName,T2.FormatCode



INSERT INTO #Tmp2
--SELECT T1.FormatCode,T1.AcctName  FROM OACT T1 WHERE T1.AcctCode LIKE @Codigo
SELECT T1.AcctCode,T1.AcctName  FROM OACT T1 WHERE T1.AcctCode LIKE @Codigo

/*ESTE SELECT debe ir al tmp q es comun en el seg ppal*/

INSERT INTO #Tmp_Totales
SELECT  T1.codigo,MAX(T2.nombre_cat),SUM(SV),SUM(SV_ANT),SUM(SV)-SUM(SV_ANT) AS dif,SUM(ACUMULADO),
		SUM(T1.Presup_mens),SUM(T1.Presup_anual),
		(SUM(SV)/SUM(CASE T1.Presup_mens WHEN 0.0 THEN 0.01 ELSE T1.Presup_mens END))*100, 
		(SUM(ACUMULADO)/SUM(CASE T1.Presup_anual WHEN 0.0 THEN 0.12 ELSE T1.Presup_anual END))*100 
FROM  #Tmp1 T1  INNER JOIN #Tmp2 T2 ON T1.Codigo=T2.Codigo_cat
group by codigo


--insert into ycvpaprueba.dbo._tmp_
--SELECT  T1.codigo,MAX(T2.nombre_cat),SUM(SV),SUM(SV_ANT),SUM(SV)-SUM(SV_ANT) AS dif,SUM(ACUMULADO),
--		SUM(T1.Presup_mens),SUM(T1.Presup_anual),
--		(SUM(SV)/SUM(CASE T1.Presup_mens WHEN 0.0 THEN 0.01 ELSE T1.Presup_mens END))*100, 
--		(SUM(ACUMULADO)/SUM(CASE T1.Presup_anual WHEN 0.0 THEN 0.12 ELSE T1.Presup_anual END))*100 
--FROM  #Tmp1 T1  INNER JOIN #Tmp2 T2 ON T1.Codigo=T2.Codigo_cat
--group by codigo


--select * from ycvpaprueba.dbo._tmp_ where codigo = '4102'
--delete from ycvpaprueba.dbo._tmp_
--select * from oact where  FormatCode like '4102%'


DELETE FROM #Tmp1









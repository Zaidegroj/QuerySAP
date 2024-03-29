set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go





ALTER PROCEDURE [dbo].[BalanceActivosNiv5]

@FechaIni 		AS DATETIME,
@FechaFin 		AS DATETIME,
@Codigo 		AS VARCHAR(8)	

AS

/*1. El despliegue final se hace a nivel 3, */
/*En el codigo ya esta contemplada la division por cero,
  para el presupuesto el campo utilizado es DebLTotal distinto a los ingresos por lo que utilice otro SP*/
/*INGRESANDO LA DATA EN DETALLE DE NIVEL 3*/

INSERT INTO #Tmp1 
SELECT Cod_SYS,Nombre,Codigo AS Codigo,SUM(Saldo) AS saldo 
FROM 
(
SELECT  
	T0.Account			AS Cod_SYS, 
	T2.AcctName			AS Nombre,
	SUBSTRING(T2.FormatCode,1,9)	AS Codigo, 	
	SUM(T0.Credit)-SUM(T0.Debit)	AS Saldo
FROM DBO.JDT1 T0  INNER JOIN DBO.OJDT T1 ON T0.TransId = T1.TransId 
	INNER JOIN DBO.OACT T2 ON T0.Account = T2.AcctCode 	
WHERE T0.[RefDate] >=@FechaIni AND T0.[RefDate] <=@FechaFin AND  T2.FormatCode  LIKE @Codigo
GROUP BY T0.Account,T2.AcctName,T2.FormatCode
) T0 
GROUP BY Cod_SYS,Nombre,Codigo


INSERT INTO #Tmp2
SELECT T1.AcctCode,T1.AcctName  FROM OACT T1 WHERE T1.AcctCode LIKE @Codigo
--SELECT T1.FormatCode,T1.AcctName  FROM OACT T1 WHERE T1.FormatCode LIKE @Codigo

/*ESTE SELECT debe ir al tmp q es comun en el seg ppal*/


INSERT INTO #Tmp_Totales
SELECT  T1.codigo,(t1.nombre),SUM(saldo) 
FROM  #Tmp1 T1 
group by codigo,nombre

DELETE FROM #Tmp1

---select * from #Tmp_Totales
---select * from jdt1
---select * from ojdt



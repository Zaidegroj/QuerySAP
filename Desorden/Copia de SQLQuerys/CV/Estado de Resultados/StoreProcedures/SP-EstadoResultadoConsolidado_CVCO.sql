set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


/*

Procedimiento		:	Utilizado en la opción Query Manager->Finanzas->Estado Resultados Incl Presupuesto

*/

ALTER  procedure [dbo].[EstadoResultadoConsolidado_CVCO]
							(
							@DBPais as varchar(4),
							@FechaIni as DateTime,
							@FechaFin as DateTime,
							@FechaIniAcum as datetime,
							@nNivel	as int,
							@Tc as numeric(18,4) = null
							)
as 

CREATE TABLE #Tmp_Conso
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

CREATE TABLE #Tmp_Totales
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

/*Tmp1 y Tmp2 es para el proceso de generar los Gastos*/

CREATE TABLE #Tmp1 
(
SYS 	NVARCHAR(80) NULL,
nombre  NVARCHAR(100) NULL,
codigo  VARCHAR(80) NULL,
SV   	NUMERIC(19,4),
SV_ANT 	NUMERIC(19,4),
ACUMULADO	NUMERIC(19,4) NULL,
Presup_mens NUMERIC(19,4),
Presup_anual NUMERIC(19,4)
)

CREATE TABLE #Tmp2 
(
codigo_cat  NVARCHAR(80) NULL,
nombre_cat  NVARCHAR(100) NULL,
)

CREATE TABLE #Tmp_ConsoTotal
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

CREATE TABLE #Tmp_ConsoFinal
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
)

DECLARE @FechaIni_ANT 	AS DATETIME,
		@FechaFin_ANT 	AS DATETIME,
		@Codigo  	AS VARCHAR(8),
		@BANDERA  	AS NUMERIC(19,3),
		@Ejerc  	AS NVARCHAR(20),
		@Mes_Ini	AS INT,
		@Mes_Fin	AS INT,
		@campos		AS NVARCHAR(80),
		@camposTot	AS NVARCHAR(800),
		--@Tc			as numeric(10,2),
		@sSql as nvarchar(4000),
		@ParamDefinition as nvarchar(200)
---
declare @FechaIni1 datetime,
		@FechaFin1 datetime,
		@FechaIni_ANT1 datetime,
		@FechaFin_ANT1 datetime,
		@FechaIniAcum1 datetime,
		@Ejerc1 nvarchar(20),
		@Mes_Ini1 int,
		@Mes_Fin1 int,
		@Codigo1 varchar(8)
---

-- Obtengo el tipo de cambio de acuerdo al país enviado como parámetro
if (@Tc is null) or (@Tc > 1)
	begin
		set @Tc = (select cvsv.dbo.GetTCCountries(@DBPais,@FechaFin))
	end

--print @Tc
SET @Ejerc=CAST(DATEPART(yyyy,@FechaIni) AS NVARCHAR) +'0101' 
SET @Mes_Ini= DATEPART(MONTH,@FechaIni)
SET @Mes_Fin= DATEPART(MONTH,@FechaFin)

SET @FechaIni_ANT=DATEADD(YEAR,-1,@FechaIni)
SET @FechaFin_ANT=DATEADD(YEAR,-1,@FechaFin)

/*INSERTANDO LOS INGRESOS DE LA CUENTA 4102*/

SET @Codigo ='41%'


set @sSql = N'exec ' + @DBPais + '.DBO.EstResul_INGRESOSNiv'+rtrim(ltrim(cast(@nNivel as Char(1))))+'_INDIVACTUAL ' + 
					''''+convert(char(10),@FechaIni,112)+''''+','+
					''''+convert(char(10),@FechaFin,112)+''''+','+
					''''+convert(char(10),@FechaIni_ANT,112)+''''+','+
					''''+convert(char(10),@FechaFin_ANT,112)+''''+','+
					''''+convert(char(10),@FechaIniAcum,112)+''''+','+
					''''+@Ejerc+''''+','+
					''''+convert(char(2),@Mes_Ini)+''''+','+
					''''+convert(char(2),@Mes_Fin)+''''+','+
					''''+@Codigo+''''

set @ParamDefinition = N'@FechaIni1 datetime,@FechaFin1 datetime,@FechaIni_ANT1 datetime,@FechaFin_ANT1 datetime,
						@FechaIniAcum1 datetime,@Ejerc1 nvarchar(20),@Mes_Ini1 int,@Mes_Fin1 int,@Codigo1 varchar(8)'

EXEC sp_executesql	@sSql,@ParamDefinition,
					@FechaIni1 = @FechaIni,
					@FechaFin1 = @FechaFin,
					@FechaIni_ANT1 = @FechaIni_Ant,
					@FechaFin_ANT1 = @FechaFin_ANT,
					@FechaIniAcum1 = @FechaIniAcum,
					@Ejerc1 = @Ejerc,
				    @Mes_Ini1 = @Mes_Ini,
					@Mes_Fin1 = @Mes_Fin,
					@Codigo1 = @Codigo


INSERT #Tmp_Conso (NOMBRE) VALUES ('*			INGRESOS			*')

INSERT #Tmp_Conso (NOMBRE) VALUES ('		INGRESOS POR VENTA DE SERVICIO		')
INSERT INTO #Tmp_Conso
			select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
					round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
					round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual
			from	#Tmp_Totales  
--SELECT * FROM #Tmp_Totales
/*PARA TOTALIZAR*/
INSERT INTO #Tmp_ConsoTotal
			select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
					round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
					round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual
			from	#Tmp_Totales  
--SELECT * FROM #Tmp_Totales
/*INGRESANDO SUB TOTAL*/
INSERT INTO #Tmp_Conso
SELECT ' ' AS CODIGO,'TOTAL' AS NOMBRE,SUM(SV/@tc),SUM(SV_ANT/@tc),SUM(DIF/@tc),SUM(ACUMULADO/@tc),
		SUM(PRESUP_MENS/@tc),SUM(PRESUP_ANUAL/@tc),0 AS PORCENT_MENS,0 AS PORCENT_ANUAL 
FROM  #Tmp_Totales

/*Dejando libre la tabla*/
DELETE  FROM #Tmp_Totales

/*INSERTANDO LOS INGRESOS NO OPERACIONALES */

SET @Codigo ='42%'

set @sSql = 'exec ' + @DBPais +'.DBO.EstResul_INGRESOSNiv'+rtrim(ltrim(cast(@nNivel as Char(1))))+'_INDIVACTUAL ' +
					''''+convert(char(10),@FechaIni,112)+''''+','+
					''''+convert(char(10),@FechaFin,112)+''''+','+
					''''+convert(char(10),@FechaIni_ANT,112)+''''+','+
					''''+convert(char(10),@FechaFin_ANT,112)+''''+','+
					''''+convert(char(10),@FechaIniAcum,112)+''''+','+
					''''+@Ejerc+''''+','+
					''''+convert(char(2),@Mes_Ini)+''''+','+
					''''+convert(char(2),@Mes_Fin)+''''+','+
					''''+@Codigo+''''
--print @sSql
set @ParamDefinition = N'@FechaIni1 datetime,@FechaFin1 datetime,@FechaIni_ANT1 datetime,@FechaFin_ANT1 datetime,
						@FechaIniAcum1 datetime,@Ejerc1 nvarchar(20),@Mes_Ini1 int,@Mes_Fin1 int,@Codigo1 varchar(8)'

EXEC sp_executesql	@sSql,@ParamDefinition,
					@FechaIni1 = @FechaIni,
					@FechaFin1 = @FechaFin,
					@FechaIni_ANT1 = @FechaIni_Ant,
					@FechaFin_ANT1 = @FechaFin_ANT,
					@FechaIniAcum1 = @FechaIniAcum,
					@Ejerc1 = @Ejerc,
				    @Mes_Ini1 = @Mes_Ini,
					@Mes_Fin1 = @Mes_Fin,
					@Codigo1 = @Codigo

SET @BANDERA=(SELECT SUM(SV)+SUM(SV_ANT) AS Tot FROM #Tmp_Totales)
IF @BANDERA<>0
	BEGIN
		INSERT #Tmp_Conso (NOMBRE) VALUES (' ')
		INSERT #Tmp_Conso (NOMBRE) VALUES ('		INGRESOS DIVERSISI		')
		INSERT INTO #Tmp_Conso
		select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
				round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
				round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual
		from	#Tmp_Totales  
		--SELECT * FROM #Tmp_Totales
		/*PARA TOTALIZAR*/
		INSERT INTO #Tmp_ConsoTotal
			select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
					round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
					round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual
			from	#Tmp_Totales  
		--SELECT * FROM #Tmp_Totales
		/*INGRESANDO SUB TOTAL*/
		INSERT INTO #Tmp_Conso
		SELECT ' ' AS CODIGO,'TOTAL' AS NOMBRE,SUM(SV/@Tc),SUM(SV_ANT/@tc),SUM(DIF/@tc),SUM(ACUMULADO/@tc),
				SUM(PRESUP_MENS/@tc),SUM(PRESUP_ANUAL/@tc),0 AS PORCENT_MENS,0 AS PORCENT_ANUAL 
		FROM  #Tmp_Totales
	END
/*Dejando libre la tabla*/
DELETE  FROM #Tmp_Totales
SET @BANDERA=0.0

/*INSERTANDO LOS INGRESOS DE LA CUENTA 4103*/

--SET @Codigo ='4104%'
--set @sSql = 'exec ' + @DBPais + '.DBO.EstResul_INGRESOSNiv'+rtrim(ltrim(cast(@nNivel as Char(1))))+'_INDIVACTUAL ' +
--					''''+convert(char(10),@FechaIni,112)+''''+','+
--					''''+convert(char(10),@FechaFin,112)+''''+','+
--					''''+convert(char(10),@FechaIni_ANT,112)+''''+','+
--					''''+convert(char(10),@FechaFin_ANT,112)+''''+','+
--					''''+convert(char(10),@FechaIniAcum,112)+''''+','+
--					''''+@Ejerc+''''+','+
--					''''+convert(char(2),@Mes_Ini)+''''+','+
--					''''+convert(char(2),@Mes_Fin)+''''+','+
--					''''+@Codigo+''''
--
--set @ParamDefinition = N'@FechaIni1 datetime,@FechaFin1 datetime,@FechaIni_ANT1 datetime,@FechaFin_ANT1 datetime,
--						@FechaIniAcum1 datetime,@Ejerc1 nvarchar(20),@Mes_Ini1 int,@Mes_Fin1 int,@Codigo1 varchar(8)'
--
--EXEC sp_executesql	@sSql,@ParamDefinition,
--					@FechaIni1 = @FechaIni,
--					@FechaFin1 = @FechaFin,
--					@FechaIni_ANT1 = @FechaIni_Ant,
--					@FechaFin_ANT1 = @FechaFin_ANT,
--					@FechaIniAcum1 = @FechaIniAcum,
--					@Ejerc1 = @Ejerc,
--				    @Mes_Ini1 = @Mes_Ini,
--					@Mes_Fin1 = @Mes_Fin,
--					@Codigo1 = @Codigo
--
--SET @BANDERA=   1 --(SELECT SUM(SV)+SUM(SV_ANT) AS Tot FROM #Tmp_Totales)
--IF @BANDERA<>0
--	BEGIN
--		INSERT #Tmp_Conso (NOMBRE) VALUES (' ')
--		INSERT #Tmp_Conso (NOMBRE) VALUES ('		INGRESOS FINANCIEROS		')
--		INSERT INTO #Tmp_Conso
--		--SELECT * FROM #Tmp_Totales
--		select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
--				round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
--				round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual
--		from	#Tmp_Totales  
--		/*PARA TOTALIZAR*/
--		INSERT INTO #Tmp_ConsoTotal
--		--SELECT * FROM #Tmp_Totales
--		select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
--				round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
--				round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual
--		from	#Tmp_Totales  
--		/*INGRESANDO SUB TOTAL*/
--		INSERT INTO #Tmp_Conso
--		SELECT ' ' AS CODIGO,'TOTAL' AS NOMBRE,SUM(SV/@tc),SUM(SV_ANT/@tc),SUM(DIF/@tc),SUM(ACUMULADO/@tc),
--				SUM(PRESUP_MENS/@tc),SUM(PRESUP_ANUAL/@tc),0 AS PORCENT_MENS,0 AS PORCENT_ANUAL 
--		FROM  #Tmp_Totales
--	END
--/*Dejando libre la tabla*/
--DELETE  FROM #Tmp_Totales
--SET @BANDERA=0.0

/*----------- insertando LAS DEVOLUCIONES EN LOS INGRESOS 6104*/

SET @Codigo ='4175%'
set @sSql = 'exec '+ @DBPais+'.DBO.EstResul_GASTOSNiv'+rtrim(ltrim(cast(@nNivel as Char(1))))+'_INDIVACTUAL ' + 
					''''+convert(char(10),@FechaIni,112)+''''+','+
					''''+convert(char(10),@FechaFin,112)+''''+','+
					''''+convert(char(10),@FechaIni_ANT,112)+''''+','+
					''''+convert(char(10),@FechaFin_ANT,112)+''''+','+
					''''+convert(char(10),@FechaIniAcum,112)+''''+','+
					''''+@Ejerc+''''+','+
					''''+convert(char(2),@Mes_Ini)+''''+','+
					''''+convert(char(2),@Mes_Fin)+''''+','+
					''''+@Codigo+''''
set @ParamDefinition = N'@FechaIni1 datetime,@FechaFin1 datetime,@FechaIni_ANT1 datetime,@FechaFin_ANT1 datetime,
					@FechaIniAcum1 datetime,@Ejerc1 nvarchar(20),@Mes_Ini1 int,@Mes_Fin1 int,@Codigo1 varchar(8)'
EXEC sp_executesql	@sSql,@ParamDefinition,
					@FechaIni1 = @FechaIni,
					@FechaFin1 = @FechaFin,
					@FechaIni_ANT1 = @FechaIni_Ant,
					@FechaFin_ANT1 = @FechaFin_ANT,
					@FechaIniAcum1 = @FechaIniAcum,
					@Ejerc1 = @Ejerc,
					@Mes_Ini1 = @Mes_Ini,
					@Mes_Fin1 = @Mes_Fin,
					@Codigo1 = @Codigo
SET @BANDERA=(SELECT SUM(SV)+SUM(SV_ANT) AS Tot FROM #Tmp_Totales)

IF @BANDERA<>0
	BEGIN
		INSERT #Tmp_Conso (NOMBRE) VALUES (' ')
		INSERT #Tmp_Conso (NOMBRE) VALUES ('		REBAJAS Y DEVOLUCIONES SOBRE VENTAS		')
		INSERT INTO #Tmp_Conso
		select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
				round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
				round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual
		from	#Tmp_Totales  
		--SELECT * FROM #Tmp_Totales
		/*PARA TOTALIZAR*/
		INSERT INTO #Tmp_ConsoTotal
		select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
				round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
				round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual
		from	#Tmp_Totales  
		--SELECT * FROM #Tmp_Totales
		/*INGRESANDO SUB TOTAL*/
		INSERT INTO #Tmp_Conso
		SELECT ' ' AS CODIGO,'TOTAL' AS NOMBRE,SUM(SV/@tc),SUM(SV_ANT/@tc),SUM(DIF/@tc),SUM(ACUMULADO/@tc),SUM(PRESUP_MENS/@tc),SUM(PRESUP_ANUAL/@tc),0 AS PORCENT_MENS,0 AS PORCENT_ANUAL FROM  #Tmp_Totales
	END
/*Dejando libre la tabla*/
DELETE  FROM #Tmp_Totales
SET @BANDERA=0.0

/*---------- FIN DE LAS DEVOLUCIONES*/

INSERT #Tmp_Conso (NOMBRE) VALUES (' ')

/*INSERTANDO TOTAL INGRESOS*/

INSERT INTO #Tmp_Conso
SELECT ' ' AS CODIGO,'TOTAL INGRESOS' AS NOMBRE,SUM(SV),SUM(SV_ANT),SUM(DIF),SUM(ACUMULADO),SUM(PRESUP_MENS),SUM(PRESUP_ANUAL),0 AS PORCENT_MENS,0 AS PORCENT_ANUAL FROM  #Tmp_ConsoTotal

INSERT #Tmp_Conso (NOMBRE) VALUES (' ')

/*-----INGRESANDO LOS COSTOS-----*/

INSERT #Tmp_Conso (NOMBRE) VALUES ('*			COSTO DE VENTAS			*')

/*INSERTANDO LOS COSTOS DE LA CUENTA 5101*/

SET @Codigo ='61%'

set @sSql = 'exec ' + @DBPais + '.DBO.EstResul_COSTOSNiv'+rtrim(ltrim(cast(@nNivel as Char(1))))+'_INDIVACTUAL ' + 
					''''+convert(char(10),@FechaIni,112)+''''+','+
					''''+convert(char(10),@FechaFin,112)+''''+','+
					''''+convert(char(10),@FechaIni_ANT,112)+''''+','+
					''''+convert(char(10),@FechaFin_ANT,112)+''''+','+
					''''+convert(char(10),@FechaIniAcum,112)+''''+','+
					''''+@Ejerc+''''+','+
					''''+convert(char(2),@Mes_Ini)+''''+','+
					''''+convert(char(2),@Mes_Fin)+''''+','+
					''''+@Codigo+''''

set @ParamDefinition = N'@FechaIni1 datetime,@FechaFin1 datetime,@FechaIni_ANT1 datetime,@FechaFin_ANT1 datetime,
						@FechaIniAcum1 datetime,@Ejerc1 nvarchar(20),@Mes_Ini1 int,@Mes_Fin1 int,@Codigo1 varchar(8)'

EXEC sp_executesql	@sSql,@ParamDefinition,
					@FechaIni1 = @FechaIni,
					@FechaFin1 = @FechaFin,
					@FechaIni_ANT1 = @FechaIni_Ant,
					@FechaFin_ANT1 = @FechaFin_ANT,
					@FechaIniAcum1 = @FechaIniAcum,
					@Ejerc1 = @Ejerc,
				    @Mes_Ini1 = @Mes_Ini,
					@Mes_Fin1 = @Mes_Fin,
					@Codigo1 = @Codigo

SET @BANDERA=(SELECT SUM(SV)+SUM(SV_ANT) AS Tot FROM #Tmp_Totales)
IF @BANDERA<>0
	BEGIN
		INSERT #Tmp_Conso (NOMBRE) VALUES ('		COSTO POR VENTAS DE PRODUCTOS		')
		INSERT INTO #Tmp_Conso
		select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
				round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
				round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual
		from	#Tmp_Totales  
		--SELECT * FROM #Tmp_Totales
		/*PARA TOTALIZAR*/
		INSERT INTO #Tmp_ConsoTotal
		--SELECT * FROM #Tmp_Totales
		select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
				round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
				round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual
		from	#Tmp_Totales  
		/*ingresando total al bloque*/
		INSERT INTO #Tmp_Conso
		SELECT ' ' AS CODIGO,'TOTAL' AS NOMBRE,SUM(SV/@tc),SUM(SV_ANT/@tc),SUM(DIF/@tc),SUM(ACUMULADO/@tc),
				SUM(PRESUP_MENS/@tc),SUM(PRESUP_ANUAL/@tc),0 AS PORCENT_MENS,0 AS PORCENT_ANUAL 
		FROM  #Tmp_Totales
	END

/*Dejando libre la tabla*/
DELETE  FROM #Tmp_Totales

--/*INSERTANDO LOS COSTOS DE LA CUENTA 5101*/
--SET @Codigo ='5101%'
--
--set @sSql = 'exec ' + @DBPais + '.DBO.EstResul_COSTOSNiv'+rtrim(ltrim(cast(@nNivel as Char(1))))+'_INDIVACTUAL ' +
--					''''+convert(char(10),@FechaIni,112)+''''+','+
--					''''+convert(char(10),@FechaFin,112)+''''+','+
--					''''+convert(char(10),@FechaIni_ANT,112)+''''+','+
--					''''+convert(char(10),@FechaFin_ANT,112)+''''+','+
--					''''+convert(char(10),@FechaIniAcum,112)+''''+','+
--					''''+@Ejerc+''''+','+
--					''''+convert(char(2),@Mes_Ini)+''''+','+
--					''''+convert(char(2),@Mes_Fin)+''''+','+
--					''''+@Codigo+''''
--
--set @ParamDefinition = N'@FechaIni1 datetime,@FechaFin1 datetime,@FechaIni_ANT1 datetime,@FechaFin_ANT1 datetime,
--						@FechaIniAcum1 datetime,@Ejerc1 nvarchar(20),@Mes_Ini1 int,@Mes_Fin1 int,@Codigo1 varchar(8)'
--
--EXEC sp_executesql	@sSql,@ParamDefinition,
--					@FechaIni1 = @FechaIni,
--					@FechaFin1 = @FechaFin,
--					@FechaIni_ANT1 = @FechaIni_Ant,
--					@FechaFin_ANT1 = @FechaFin_ANT,
--					@FechaIniAcum1 = @FechaIniAcum,
--					@Ejerc1 = @Ejerc,
--				    @Mes_Ini1 = @Mes_Ini,
--					@Mes_Fin1 = @Mes_Fin,
--					@Codigo1 = @Codigo
--
--SET @BANDERA=(SELECT SUM(SV)+SUM(SV_ANT) AS Tot FROM #Tmp_Totales)
--IF @BANDERA<>0
--	BEGIN
--		INSERT #Tmp_Conso (NOMBRE) VALUES (' ')
--		INSERT #Tmp_Conso (NOMBRE) VALUES ('COSTO POR REGALIAS')
--		INSERT INTO #Tmp_Conso
--		select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
--				round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
--				round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual
--		from	#Tmp_Totales  
--		--SELECT * FROM #Tmp_Totales
--		/*PARA TOTALIZAR*/
--		INSERT INTO #Tmp_ConsoTotal
--		select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
--				round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
--				round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual
--		from	#Tmp_Totales  
--		--SELECT * FROM #Tmp_Totales
--		/*ingresando total al bloque*/
--		INSERT INTO #Tmp_Conso
--		SELECT ' ' AS CODIGO,'TOTAL' AS NOMBRE,SUM(SV/@tc),SUM(SV_ANT/@tc),SUM(DIF/@tc),SUM(ACUMULADO/@tc),SUM(PRESUP_MENS/@tc),SUM(PRESUP_ANUAL/@tc),0 AS PORCENT_MENS,0 AS PORCENT_ANUAL FROM  #Tmp_Totales
--	END
--
--/*Dejando libre la tabla*/
--DELETE  FROM #Tmp_Totales

/*INSERTANDO TOTAL COSTOS*/
INSERT #Tmp_Conso (NOMBRE) VALUES (' ')
INSERT INTO #Tmp_Conso
SELECT ' ' AS CODIGO,'TOTAL COSTO DE VENTAS' AS NOMBRE,SUM(SV),SUM(SV_ANT),SUM(DIF),SUM(ACUMULADO),
		SUM(PRESUP_MENS),SUM(PRESUP_ANUAL),0 AS PORCENT_MENS,0 AS PORCENT_ANUAL 
FROM  #Tmp_ConsoTotal WHERE CODIGO LIKE '61%'

/*TOTALIZANDO PARCIALMENTE PARA INSERTAR LA GANANCIA BRUTA*/
INSERT #Tmp_Conso (NOMBRE) VALUES (' ')

INSERT INTO #Tmp_Conso
SELECT ' ' AS CODIGO,'UTILIDAD BRUTA' AS NOMBRE,SUM(SV),SUM(SV_ANT),SUM(DIF),SUM(ACUMULADO),SUM(PRESUP_MENS),
		SUM(PRESUP_ANUAL),0 AS PORCENT_MENS,0 AS PORCENT_ANUAL 
FROM  #Tmp_ConsoTotal
INSERT #Tmp_Conso (NOMBRE) VALUES (' ')

/* INSERTANDO GASTOS A NIVEL X NIVEL PARA CUANDO SE NECESITEN DETALLADOS */

-- ADMINISTRACION

if (@nNivel = 3)
	begin
		SET @Codigo = '51%'
	end
else
	begin
		set @Codigo = '51%'
	end

set @sSql = 'exec ' + @DBPais + '.DBO.EstResul_GASTOSNiv'+rtrim(ltrim(cast(@nNivel as Char(1))))+'_INDIVACTUAL ' + 
					''''+convert(char(10),@FechaIni,112)+''''+','+
					''''+convert(char(10),@FechaFin,112)+''''+','+
					''''+convert(char(10),@FechaIni_ANT,112)+''''+','+
					''''+convert(char(10),@FechaFin_ANT,112)+''''+','+
					''''+convert(char(10),@FechaIniAcum,112)+''''+','+
					''''+@Ejerc+''''+','+
					''''+convert(char(2),@Mes_Ini)+''''+','+
					''''+convert(char(2),@Mes_Fin)+''''+','+
					''''+@Codigo+''''
set @ParamDefinition = N'@FechaIni1 datetime,@FechaFin1 datetime,@FechaIni_ANT1 datetime,@FechaFin_ANT1 datetime,
						@FechaIniAcum1 datetime,@Ejerc1 nvarchar(20),@Mes_Ini1 int,@Mes_Fin1 int,@Codigo1 varchar(8)'
EXEC sp_executesql	@sSql,@ParamDefinition,
					@FechaIni1 = @FechaIni,
					@FechaFin1 = @FechaFin,
					@FechaIni_ANT1 = @FechaIni_Ant,
					@FechaFin_ANT1 = @FechaFin_ANT,
					@FechaIniAcum1 = @FechaIniAcum,
					@Ejerc1 = @Ejerc,
					@Mes_Ini1 = @Mes_Ini,
					@Mes_Fin1 = @Mes_Fin,
					@Codigo1 = @Codigo
	
INSERT INTO #Tmp_Conso
select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
		round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
		round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual 
from	#Tmp_Totales 

--print @DBPais
/*PARA TOTALIZAR*/
INSERT INTO #Tmp_ConsoTotal
select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
		round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
		round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual
from	#Tmp_Totales  

DELETE  FROM #Tmp_Totales

-- VENTAS

if (@nNivel = 3)
	begin
		set @Codigo = '52%'
	end
else
	begin
		set @Codigo = '52%'
	end

set @sSql = 'exec ' + @DBPais + '.DBO.EstResul_GASTOSNiv'+rtrim(ltrim(cast(@nNivel as Char(1))))+'_INDIVACTUAL ' + 
					''''+convert(char(10),@FechaIni,112)+''''+','+
					''''+convert(char(10),@FechaFin,112)+''''+','+
					''''+convert(char(10),@FechaIni_ANT,112)+''''+','+
					''''+convert(char(10),@FechaFin_ANT,112)+''''+','+
					''''+convert(char(10),@FechaIniAcum,112)+''''+','+
					''''+@Ejerc+''''+','+
					''''+convert(char(2),@Mes_Ini)+''''+','+
					''''+convert(char(2),@Mes_Fin)+''''+','+
					''''+@Codigo+''''
set @ParamDefinition = N'@FechaIni1 datetime,@FechaFin1 datetime,@FechaIni_ANT1 datetime,@FechaFin_ANT1 datetime,
						@FechaIniAcum1 datetime,@Ejerc1 nvarchar(20),@Mes_Ini1 int,@Mes_Fin1 int,@Codigo1 varchar(8)'


EXEC sp_executesql	@sSql,@ParamDefinition,
					@FechaIni1 = @FechaIni,
					@FechaFin1 = @FechaFin,
					@FechaIni_ANT1 = @FechaIni_Ant,
					@FechaFin_ANT1 = @FechaFin_ANT,
					@FechaIniAcum1 = @FechaIniAcum,
					@Ejerc1 = @Ejerc,
					@Mes_Ini1 = @Mes_Ini,
					@Mes_Fin1 = @Mes_Fin,
					@Codigo1 = @Codigo
	

INSERT INTO #Tmp_Conso
select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
		round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
		round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual
from	#Tmp_Totales  


/*PARA TOTALIZAR*/

INSERT INTO #Tmp_ConsoTotal
select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
		round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
		round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual
from	#Tmp_Totales  

DELETE  FROM #Tmp_Totales

-- FINANCIEROS

if (@nNivel = 3)
	begin
		SET @Codigo = '53%'
	end
else
	begin
		set @Codigo = '53%'
	end

set @sSql = 'exec ' + @DBPais + '.DBO.EstResul_GASTOSNiv'+rtrim(ltrim(cast(@nNivel as Char(1))))+'_INDIVACTUAL ' + 
					''''+convert(char(10),@FechaIni,112)+''''+','+
					''''+convert(char(10),@FechaFin,112)+''''+','+
					''''+convert(char(10),@FechaIni_ANT,112)+''''+','+
					''''+convert(char(10),@FechaFin_ANT,112)+''''+','+
					''''+convert(char(10),@FechaIniAcum,112)+''''+','+
					''''+@Ejerc+''''+','+
					''''+convert(char(2),@Mes_Ini)+''''+','+
					''''+convert(char(2),@Mes_Fin)+''''+','+
					''''+@Codigo+''''
set @ParamDefinition = N'@FechaIni1 datetime,@FechaFin1 datetime,@FechaIni_ANT1 datetime,@FechaFin_ANT1 datetime,
						@FechaIniAcum1 datetime,@Ejerc1 nvarchar(20),@Mes_Ini1 int,@Mes_Fin1 int,@Codigo1 varchar(8)'
--print @sSql
EXEC sp_executesql	@sSql,@ParamDefinition,
					@FechaIni1 = @FechaIni,
					@FechaFin1 = @FechaFin,
					@FechaIni_ANT1 = @FechaIni_Ant,
					@FechaFin_ANT1 = @FechaFin_ANT,
					@FechaIniAcum1 = @FechaIniAcum,
					@Ejerc1 = @Ejerc,
					@Mes_Ini1 = @Mes_Ini,
					@Mes_Fin1 = @Mes_Fin,
					@Codigo1 = @Codigo
	

INSERT INTO #Tmp_Conso

select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
		round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
		round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual
from	#Tmp_Totales  

--SELECT * FROM #Tmp_Totales 
/*PARA TOTALIZAR*/
INSERT INTO #Tmp_ConsoTotal
select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
		round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
		round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual
from	#Tmp_Totales  

DELETE  FROM #Tmp_Totales
	
--/*--------*/
--	
--if (@nNivel = 3)
--	begin
--		SET @Codigo = '5315%'
--	end
--else
--	begin
--		set @Codigo = '5315%'
--	end
--	
--set @sSql = 'exec ' + @DBPais + '.DBO.EstResul_GASTOSNiv'+rtrim(ltrim(cast(@nNivel as char(1))))+'_INDIVACTUAL ' + 
--					''''+convert(char(10),@FechaIni,112)+''''+','+
--					''''+convert(char(10),@FechaFin,112)+''''+','+
--					''''+convert(char(10),@FechaIni_ANT,112)+''''+','+
--					''''+convert(char(10),@FechaFin_ANT,112)+''''+','+
--					''''+convert(char(10),@FechaIniAcum,112)+''''+','+
--					''''+@Ejerc+''''+','+
--					''''+convert(char(2),@Mes_Ini)+''''+','+
--					''''+convert(char(2),@Mes_Fin)+''''+','+
--					''''+@Codigo+''''
--
--set @ParamDefinition = N'@FechaIni1 datetime,@FechaFin1 datetime,@FechaIni_ANT1 datetime,@FechaFin_ANT1 datetime,
--						@FechaIniAcum1 datetime,@Ejerc1 nvarchar(20),@Mes_Ini1 int,@Mes_Fin1 int,@Codigo1 varchar(8)'
--EXEC sp_executesql	@sSql,@ParamDefinition,
--					@FechaIni1 = @FechaIni,
--					@FechaFin1 = @FechaFin,
--					@FechaIni_ANT1 = @FechaIni_Ant,
--					@FechaFin_ANT1 = @FechaFin_ANT,
--					@FechaIniAcum1 = @FechaIniAcum,
--					@Ejerc1 = @Ejerc,
--					@Mes_Ini1 = @Mes_Ini,
--					@Mes_Fin1 = @Mes_Fin,
--					@Codigo1 = @Codigo
--
--
--INSERT INTO #Tmp_Conso
--select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
--		round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
--		round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual
--from	#Tmp_Totales  
----SELECT * FROM #Tmp_Totales 
--/*PARA TOTALIZAR*/
--INSERT INTO #Tmp_ConsoTotal
--select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
--		round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
--		round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual
--from	#Tmp_Totales  
--
--
--DELETE  FROM #Tmp_Totales
	
--/*--------*/
--	
--if (@nNivel = 3)
--	begin
--		SET @Codigo = '5395%'
--	end
--else
--	begin
--		set @Codigo = '5395%'
--	end
--	
--set @sSql = 'exec ' + @DBPais + '.DBO.EstResul_GASTOSNiv'+rtrim(ltrim(cast(@nNivel as char(1))))+'_INDIVACTUAL ' + 
--					''''+convert(char(10),@FechaIni,112)+''''+','+
--					''''+convert(char(10),@FechaFin,112)+''''+','+
--					''''+convert(char(10),@FechaIni_ANT,112)+''''+','+
--					''''+convert(char(10),@FechaFin_ANT,112)+''''+','+
--					''''+convert(char(10),@FechaIniAcum,112)+''''+','+
--					''''+@Ejerc+''''+','+
--					''''+convert(char(2),@Mes_Ini)+''''+','+
--					''''+convert(char(2),@Mes_Fin)+''''+','+
--					''''+@Codigo+''''
--
--set @ParamDefinition = N'@FechaIni1 datetime,@FechaFin1 datetime,@FechaIni_ANT1 datetime,@FechaFin_ANT1 datetime,
--						@FechaIniAcum1 datetime,@Ejerc1 nvarchar(20),@Mes_Ini1 int,@Mes_Fin1 int,@Codigo1 varchar(8)'
--EXEC sp_executesql	@sSql,@ParamDefinition,
--					@FechaIni1 = @FechaIni,
--					@FechaFin1 = @FechaFin,
--					@FechaIni_ANT1 = @FechaIni_Ant,
--					@FechaFin_ANT1 = @FechaFin_ANT,
--					@FechaIniAcum1 = @FechaIniAcum,
--					@Ejerc1 = @Ejerc,
--					@Mes_Ini1 = @Mes_Ini,
--					@Mes_Fin1 = @Mes_Fin,
--					@Codigo1 = @Codigo
--
--
--INSERT INTO #Tmp_Conso
--select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
--		round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
--		round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual
--from	#Tmp_Totales  
----SELECT * FROM #Tmp_Totales 
--/*PARA TOTALIZAR*/
--INSERT INTO #Tmp_ConsoTotal
--select	codigo,nombre,round((sv/@tc),2) as sv,round((sv_ant/@tc),2) as sv_ant,round((dif/@tc),2) as dif,
--		round((acumulado/@tc),2) as acumulado,round((presup_mens/@tc),2) as presup_mens,
--		round((presup_anual/@tc),2) as presup_anual,porcent_mens,porcent_anual
--from	#Tmp_Totales  

INSERT INTO #Tmp_ConsoFinal
SELECT * FROM  #Tmp_Conso 

DELETE FROM #Tmp_ConsoFinal WHERE SV=0.0 AND SV_ANT=0.00 and acumulado = 0
 
insert into #Tmp
		select * from #Tmp_ConsoFinal

DROP TABLE #Tmp_Conso
DROP TABLE #Tmp_Totales
DROP TABLE #Tmp_ConsoTotal
DROP TABLE #Tmp_ConsoFinal
DROP TABLE #Tmp1
DROP TABLE #Tmp2


--select * from obgt



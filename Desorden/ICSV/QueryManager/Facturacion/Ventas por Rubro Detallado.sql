DECLARE @FechaIni	AS DATETIME
DECLARE @FechaFin	AS DATETIME
DECLARE @CodIni		AS VARCHAR(300)
DECLARE @CodFin		AS VARCHAR(300)
DECLARE @GrupIni	AS VARCHAR(100)
DECLARE @GrupFin	AS VARCHAR(100)
DECLARE @MesIni		AS INT
DECLARE @MesFin		AS INT
DECLARE @Mes 		AS INT
DECLARE @Anyo		AS INT
DECLARE @AnyoAct        AS VARCHAR(4)
DECLARE @Campos 	AS VARCHAR(300)
DECLARE @Agrupa		AS VARCHAR (300),
		@iInDesign as int

CREATE TABLE #TmpGeneMes
 (Grupo		 VARCHAR(100) NULL,
  Codigo 	 VARCHAR(20) NULL,
  Cliente	 VARCHAR(100) NULL,
  Mes		 NUMERIC(19,4) NULL)
  
CREATE TABLE #TmpConsoAnual
 (Grupo		 VARCHAR(100) NULL,
  Codigo 	 VARCHAR(20)  NULL,
  Cliente	 VARCHAR(100) NULL,
  ENERO		 NUMERIC(19,4)NULL,
  FEBRERO	NUMERIC(19,4) NULL,
  MARZO		NUMERIC(19,4) NULL,
  ABRIL		NUMERIC(19,4) NULL,
  MAYO		NUMERIC(19,4) NULL,
  JUNIO		NUMERIC(19,4) NULL,
  JULIO		NUMERIC(19,4) NULL,
  AGOSTO	NUMERIC(19,4) NULL,
  SEPTIEMBRE	NUMERIC(19,4) NULL,
  OCTUBRE	NUMERIC(19,4) NULL,
  NOVIEMBRE	NUMERIC(19,4) NULL,
  DICIEMBRE	NUMERIC(19,4) NULL,
  TOTAL		NUMERIC(19,4) NULL
 )
  
CREATE TABLE #Tmp_2

(Rubro   	DATETIME  
 )


set @iInDesign = 1

if (@iInDesign=1)
	begin
		SET @FechaIni= '01/01/2012 00:00:00'
		SET @FechaFin= '04/30/2012 00:00:00'
		SET @GrupIni= 'Acreedores Exterior'
		SET @GrupFin = 'Theatrical'
		SET @CodIni = 'Buen Hogar'
		SET @CodFin = 'Women''s Health'
	end
else
	begin
		/* SELECT FROM [icsv].[DBO].[OINV] T0 */
		SET @FechaIni= /* T0.DocDate */ '[%0]'
		/* SELECT FROM [ICSV].[DBO].[OINV] T0 */
		SET @FechaFin= /* T0.DocDate */ '[%1]'
		/* SELECT FROM [ICSV].[DBO].[OCRG] T1 */
		SET @GrupIni= /* T1.GroupName */ '[%2]'
		/* SELECT FROM [icsv].[DBO].[OCRG] T1 */
		SET @GrupFin = /* T1.GroupName */ '[%3]'
		/* SELECT FROM [icsv].[DBO].[@suscripciones] T2 */
		SET @CodIni = /* T2.Name */ '[%4]'
		/* SELECT FROM [icsv].[DBO].[@suscripciones] T2 */
		SET @CodFin = /* T2.Name */ '[%5]'
	end


SET @MesIni=DATEPART(MONTH,@FechaIni)
SET @MesFin=DATEPART(MONTH,@FechaFin)
SET @Anyo=DATEPART(YY,@FechaIni)
SET @AnyoAct = CAST(@Anyo AS VARCHAR)
SET @Campos='Grupo,Codigo,Cliente,'
SET @Agrupa='0 + '
WHILE @MesIni<=@MesFin
BEGIN

	IF @MesIni=1
	BEGIN
		SET @FechaIni= CONVERT(DATETIME,'01/01/' + @AnyoAct )
		SET @FechaFin= CONVERT(DATETIME,'01/31/' + @AnyoAct )
		EXEC Mes_VtaxRubro_r01 @FechaIni,@FechaFin,@CodIni,@CodFin,@GrupIni,@GrupFin
		INSERT INTO #TmpConsoAnual
		SELECT	Grupo,Codigo,Cliente,Mes,0 AS FEBRERO,
			0 AS MARZO,0 AS ABRIL,0 AS MAYO,0 AS JUNIO,
			0 AS JULIO,0 AS AGOSTO,0 AS SEPTIEMBRE,
			0 AS OCTUBRE,0 AS NOVIEMBRE,0 AS DICIEMBRE,0 AS TOTAL
		FROM #TmpGeneMes
		DELETE #TmpGeneMes
		SET @Campos=@Campos + 'SUM(ENERO) AS ENERO,'
		SET @Agrupa=@Agrupa + 'SUM(ENERO)+'
	END
	IF @MesIni=2
	BEGIN
		SET @FechaIni= CONVERT(DATETIME,'02/01/' + @AnyoAct )
		SET @FechaFin= CONVERT(DATETIME,'02/28/' + @AnyoAct )
		EXEC Mes_VtaxRubro_r01 @FechaIni,@FechaFin,@CodIni,@CodFin,@GrupIni,@GrupFin
		INSERT INTO #TmpConsoAnual
		SELECT	Grupo,Codigo,Cliente,0 as ENERO,Mes,
			0 AS MARZO,0 AS ABRIL,0 AS MAYO,0 AS JUNIO,
			0 AS JULIO,0 AS AGOSTO,0 AS SEPTIEMBRE,
			0 AS OCTUBRE,0 AS NOVIEMBRE,0 AS DICIEMBRE,0 AS TOTAL	
		FROM #TmpGeneMes	
		DELETE #TmpGeneMes
		SET @Campos=@Campos + 'SUM(FEBRERO) AS FEBRERO,'
		SET @Agrupa=@Agrupa + 'SUM(FEBRERO)+'
	END
	IF @MesIni=3
	BEGIN
		SET @FechaIni= CONVERT(DATETIME,'03/01/' + @AnyoAct )
		SET @FechaFin= CONVERT(DATETIME,'03/31/' + @AnyoAct )
		EXEC Mes_VtaxRubro_r01 @FechaIni,@FechaFin,@CodIni,@CodFin,@GrupIni,@GrupFin
		INSERT INTO #TmpConsoAnual
		SELECT	Grupo,Codigo,Cliente,0 as ENERO,0 AS FEBRERO,
			Mes,0 AS ABRIL,0 AS MAYO,0 AS JUNIO,
			0 AS JULIO,0 AS AGOSTO,0 AS SEPTIEMBRE,
			0 AS OCTUBRE,0 AS NOVIEMBRE,0 AS DICIEMBRE,0 AS TOTAL
		FROM #TmpGeneMes		
		DELETE #TmpGeneMes
		SET @Campos=@Campos + 'SUM(MARZO) AS MARZO,'
		SET @Agrupa=@Agrupa + 'SUM(MARZO)+'
	END
	IF @MesIni=4
	BEGIN
		SET @FechaIni= CONVERT(DATETIME,'04/01/' + @AnyoAct )
		SET @FechaFin= CONVERT(DATETIME,'04/30/' + @AnyoAct )
		EXEC Mes_VtaxRubro_r01 @FechaIni,@FechaFin,@CodIni,@CodFin,@GrupIni,@GrupFin
		INSERT INTO #TmpConsoAnual
		SELECT	Grupo,Codigo,Cliente,0 as ENERO,0 AS FEBRERO,
			0 AS MARZO,Mes,0 AS MAYO,0 AS JUNIO,
			0 AS JULIO,0 AS AGOSTO,0 AS SEPTIEMBRE,
			0 AS OCTUBRE,0 AS NOVIEMBRE,0 AS DICIEMBRE,0 AS TOTAL
		FROM #TmpGeneMes
		DELETE #TmpGeneMes
		SET @Campos=@Campos + 'SUM(ABRIL) AS ABRIL,'
		SET @Agrupa=@Agrupa + 'SUM(ABRIL)+'
	END
	IF @MesIni=5
	BEGIN
		SET @FechaIni= CONVERT(DATETIME,'05/01/' + @AnyoAct )
		SET @FechaFin= CONVERT(DATETIME,'05/31/' + @AnyoAct )
		EXEC Mes_VtaxRubro @FechaIni,@FechaFin,@CodIni,@CodFin,@GrupIni,@GrupFin
		INSERT INTO #TmpConsoAnual
		SELECT	Grupo,Codigo,Cliente,0 as ENERO,0 AS FEBRERO,
			0 AS MARZO,0 AS ABRIL,Mes,0 AS JUNIO,
			0 AS JULIO,0 AS AGOSTO,0 AS SEPTIEMBRE,
			0 AS OCTUBRE,0 AS NOVIEMBRE,0 AS DICIEMBRE,0 AS TOTAL
		FROM #TmpGeneMes
		DELETE #TmpGeneMes
		SET @Campos=@Campos + 'SUM(MAYO) AS MAYO,'
		SET @Agrupa=@Agrupa + 'SUM(MAYO)+'
	END
	IF @MesIni=6
	BEGIN
		SET @FechaIni= CONVERT(DATETIME,'06/01/' + @AnyoAct )
		SET @FechaFin= CONVERT(DATETIME,'06/30/' + @AnyoAct )
		EXEC Mes_VtaxRubro_r01 @FechaIni,@FechaFin,@CodIni,@CodFin,@GrupIni,@GrupFin
		INSERT INTO #TmpConsoAnual
		SELECT	Grupo,Codigo,Cliente,0 as ENERO,0 AS FEBRERO,
			0 AS MARZO,0 AS ABRIL,0 AS MAYO,Mes,
			0 AS JULIO,0 AS AGOSTO,0 AS SEPTIEMBRE,
			0 AS OCTUBRE,0 AS NOVIEMBRE,0 AS DICIEMBRE,0 AS TOTAL
		FROM #TmpGeneMes
		DELETE #TmpGeneMes
		SET @Campos=@Campos + 'SUM(JUNIO) AS JUNIO,'
		SET @Agrupa=@Agrupa + 'SUM(JUNIO)+'
	END
	IF @MesIni=7
	BEGIN
		SET @FechaIni= CONVERT(DATETIME,'07/01/' + @AnyoAct )
		SET @FechaFin= CONVERT(DATETIME,'07/31/' + @AnyoAct )
		EXEC Mes_VtaxRubro_r01 @FechaIni,@FechaFin,@CodIni,@CodFin,@GrupIni,@GrupFin
		INSERT INTO #TmpConsoAnual
		SELECT	Grupo,Codigo,Cliente,0 as ENERO,0 AS FEBRERO,
			0 AS MARZO,0 AS ABRIL,0 AS MAYO,0 AS JUNIO,
			Mes,0 AS AGOSTO,0 AS SEPTIEMBRE,
			0 AS OCTUBRE,0 AS NOVIEMBRE,0 AS DICIEMBRE,0 AS TOTAL
		FROM #TmpGeneMes
		DELETE #TmpGeneMes
		SET @Campos=@Campos + 'SUM(JULIO) AS JULIO,'
		SET @Agrupa=@Agrupa + 'SUM(JULIO)+'
	END
	IF @MesIni=8
	BEGIN
		SET @FechaIni= CONVERT(DATETIME,'08/01/' + @AnyoAct )
		SET @FechaFin= CONVERT(DATETIME,'08/31/' + @AnyoAct )
		EXEC Mes_VtaxRubro_r01 @FechaIni,@FechaFin,@CodIni,@CodFin,@GrupIni,@GrupFin
		INSERT INTO #TmpConsoAnual
		SELECT	Grupo,Codigo,Cliente,0 as ENERO,0 AS FEBRERO,
			0 AS MARZO,0 AS ABRIL,0 AS MAYO,0 AS JUNIO,
			0 AS JULIO,Mes,0 AS SEPTIEMBRE,
			0 AS OCTUBRE,0 AS NOVIEMBRE,0 AS DICIEMBRE,0 AS TOTAL
		FROM #TmpGeneMes
		DELETE #TmpGeneMes
		SET @Campos=@Campos + 'SUM(AGOSTO) AS AGOSTO,'
		SET @Agrupa=@Agrupa + 'SUM(AGOSTO)+'
	END
	IF @MesIni=9
	BEGIN
		SET @FechaIni= CONVERT(DATETIME,'09/01/' + @AnyoAct )
		SET @FechaFin= CONVERT(DATETIME,'09/30/' + @AnyoAct )
		EXEC Mes_VtaxRubro_r01 @FechaIni,@FechaFin,@CodIni,@CodFin,@GrupIni,@GrupFin
		INSERT INTO #TmpConsoAnual
		SELECT	Grupo,Codigo,Cliente,0 as ENERO,0 AS FEBRERO,
			0 AS MARZO,0 AS ABRIL,0 AS MAYO,0 AS JUNIO,
			0 AS JULIO,0 AS AGOSTO,Mes,
			0 AS OCTUBRE,0 AS NOVIEMBRE,0 AS DICIEMBRE,0 AS TOTAL
		FROM #TmpGeneMes
		DELETE #TmpGeneMes
		SET @Campos=@Campos + 'SUM(SEPTIEMBRE) AS SEPTIEMBRE,'
		SET @Agrupa=@Agrupa + 'SUM(SEPTIEMBRE)+'
	END

	IF @MesIni=10
	BEGIN
		SET @FechaIni= CONVERT(DATETIME,'10/01/' + @AnyoAct )
		SET @FechaFin= CONVERT(DATETIME,'10/31/' + @AnyoAct )
		EXEC Mes_VtaxRubro_r01 @FechaIni,@FechaFin,@CodIni,@CodFin,@GrupIni,@GrupFin
		INSERT INTO #TmpConsoAnual
		SELECT	Grupo,Codigo,Cliente,0 as ENERO,0 AS FEBRERO,
			0 AS MARZO,0 AS ABRIL,0 AS MAYO,0 AS JUNIO,
			0 AS JULIO,0 AS AGOSTO,0 AS SEPTIEMBRE,
			Mes,0 AS NOVIEMBRE,0 AS DICIEMBRE,0 AS TOTAL
		FROM #TmpGeneMes
		DELETE #TmpGeneMes
		SET @Campos=@Campos + 'SUM(OCTUBRE) AS OCTUBRE,'
		SET @Agrupa=@Agrupa + 'SUM(OCTUBRE)+'
	END
	IF @MesIni=11
	BEGIN
		SET @FechaIni= CONVERT(DATETIME,'11/01/' + @AnyoAct )
		SET @FechaFin= CONVERT(DATETIME,'11/30/' + @AnyoAct )
		EXEC Mes_VtaxRubro_r01 @FechaIni,@FechaFin,@CodIni,@CodFin,@GrupIni,@GrupFin
		INSERT INTO #TmpConsoAnual
		SELECT	Grupo,Codigo,Cliente,0 as ENERO,0 AS FEBRERO,
			0 AS MARZO,0 AS ABRIL,0 AS MAYO,0 AS JUNIO,
			0 AS JULIO,0 AS AGOSTO,0 AS SEPTIEMBRE,
			0 AS OCTUBRE,Mes,0 AS DICIEMBRE,0 AS TOTAL
		FROM #TmpGeneMes
		DELETE #TmpGeneMes
		SET @Campos=@Campos + 'SUM(NOVIEMBRE) AS NOVIEMBRE,'
		SET @Agrupa=@Agrupa + 'SUM(NOVIEMBRE)+'
	END
	IF @MesIni=12
	BEGIN
		SET @FechaIni= CONVERT(DATETIME,'12/01/' + @AnyoAct )
		SET @FechaFin= CONVERT(DATETIME,'12/31/' + @AnyoAct )
		EXEC Mes_VtaxRubro_r01 @FechaIni,@FechaFin,@CodIni,@CodFin,@GrupIni,@GrupFin
		INSERT INTO #TmpConsoAnual
		SELECT	Grupo,Codigo,Cliente,0 as ENERO,0 AS FEBRERO,
			0 AS MARZO,0 AS ABRIL,0 AS MAYO,0 AS JUNIO,
			0 AS JULIO,0 AS AGOSTO,0 AS SEPTIEMBRE,
			0 AS OCTUBRE,0 AS NOVIEMBRE,Mes,0 AS TOTAL
		FROM #TmpGeneMes
		DELETE #TmpGeneMes
		SET @Campos=@Campos + 'SUM(DICIEMBRE) AS DICIEMBRE,'
		SET @Agrupa=@Agrupa + 'SUM(DICIEMBRE)+'
	END

	SET @MesIni=@MesIni+1
	CONTINUE
END


exec ( 'SELECT ' + @Campos + @Agrupa + ' 0 AS TOTAL FROM #TmpConsoAnual GROUP BY Codigo,Grupo,Cliente ORDER BY Grupo')

DROP TABLE #TmpGeneMes
DROP TABLE #TmpConsoAnual
drop table #tmp_2

---select * from [@rubros]


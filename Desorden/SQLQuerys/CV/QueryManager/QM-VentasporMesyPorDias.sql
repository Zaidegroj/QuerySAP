CREATE TABLE #SIGConso_CV
      (Descripcion	NCHAR(100)	NULL,
       GT		NUMERIC(19,6)	NULL,
       SV		NUMERIC(19,6)	NULL,
       HN		NUMERIC(19,6)	NULL,
       NI		NUMERIC(19,6)	NULL,
       CR  		NUMERIC(19,6)	NULL,
       PA		NUMERIC(19,6)	NULL,
       CO  		NUMERIC(19,6)	NULL,
       TOTAL		NUMERIC(19,6)	NULL,
       PORCENT		NCHAR(20))

CREATE TABLE #SIGConso_CxC
      (Cartera		NCHAR(100)	NULL,
       GT		NUMERIC(19,6)	NULL,
       SV		NUMERIC(19,6)	NULL,
       HN		NUMERIC(19,6)	NULL,
       NI		NUMERIC(19,6)	NULL,
       CR  		NUMERIC(19,6)	NULL,
       PA		NUMERIC(19,6)	NULL,
       CO  		NUMERIC(19,6)	NULL,
	TOTAL		NUMERIC(19,6)	NULL)

CREATE TABLE #SIGConso_VENTA
      (Rubro		NCHAR(100)	NULL,
       GT		NUMERIC(19,6)	NULL,
       SV		NUMERIC(19,6)	NULL,
       HN		NUMERIC(19,6)	NULL,
       NI		NUMERIC(19,6)	NULL,
       CR  		NUMERIC(19,6)	NULL,
       PA		NUMERIC(19,6)	NULL,
       CO  		NUMERIC(19,6)	NULL,
	TOTAL		NUMERIC(19,6)	NULL)

CREATE TABLE #SIGConso_CxCPORCENT
      (Cartera		NCHAR(100)	NULL,
       GT		NUMERIC(19,6)	NULL,
       SV		NUMERIC(19,6)	NULL,
       HN		NUMERIC(19,6)	NULL,
       NI		NUMERIC(19,6)	NULL,
       CR  		NUMERIC(19,6)	NULL,
       PA		NUMERIC(19,6)	NULL,
       CO  		NUMERIC(19,6)	NULL,
	TOTAL		NUMERIC(19,6)	NULL,
	PORCENT		INT	NULL)

create table #VentasMeses
		(
			IdMes		int,
			Mes varchar(20),
			Guatemala	numeric(18,4) default 0,
			ElSalvador	numeric(18,4) default 0,
			Honduras	numeric(18,4) default 0,
			Nicaragua	numeric(18,4) default 0,
			CostaRica	numeric(18,4) default 0,
			Panama		numeric(18,4) default 0,
			Colombia	numeric(18,4) default 0,
			Total		numeric(18,4)
		)


DECLARE @GT AS NUMERIC(19,6),
		@HN AS NUMERIC(19,6),
		@NI AS NUMERIC(19,6),
		@CR AS NUMERIC(19,6),
		@CO AS NUMERIC(19,6),
		@dFechaIni as datetime,
		@dFechaFin as datetime,
		@iInDesign as int,
		@iMonthFirst int,
		@iMonthLast int,
		@dFechaIni1 datetime,
		@dFechaFin1 datetime

set @iInDesign = 1

if (@iInDesign =1)
	begin
		set @dFechaIni = '01/01/2008 00:00:00'
		set @dFechaFin = '12/31/2008 00:00:00'
	end
else
	begin
		/* SELECT FROM CVSV.DBO.INV1 T1 */
		SET @dFechaIni = /* T1.DocDate */ '[%4]'
		SET @dFechaFin = /* T1.DocDate */ '[%5]'
	end

-- set's
set @iMonthFirst	= month(@dFechaIni)
set @iMonthLast		= month(@dFechaFin)
set @dFechaIni		= convert(char(10),@dFechaIni,121)+' 00:00:00'
set @dFechaFin		= convert(char(10),DateAdd(ms,-2,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'

-- Verifico si ha solicitado información de años anteriores al 2008 ya que SAP tiene información a partir de 
-- dicho año

if (year(@dFechaIni)>2007)
	begin
		while (@iMonthFirst <= @iMonthLast)
			begin
				-- Verifico si existe el mes a agregar
				if (select count(Mes) from #VentasMeses where IdMes = month(@dFechaIni) ) = 0
					begin
						insert into #VentasMeses (IdMes,Mes) values (month(@dFechaIni),dbo.ObtenerNombreMes(@iMonthFirst))
					end
				-- Tipo de Cambio Guatemala
				set @GT	=(select cvsv.dbo.ObtenerTcOficial('CVGT',@dFechaFin))
				if (@gt is null)
					begin	
						set @gt = (select cvsv.dbo.GetTcCountries('CVGT',@dFechaFin))
					end
				if (@gt is null)
					begin	
						set @gt = 1
					end
				--	Tipo de cambio Honduras	
				SET @HN	=(select cvsv.dbo.ObtenerTcOficial('CVHN',@dFechaFin))
				if (@hn is null)
					begin
						set @hn = (select cvsv.dbo.GetTcCountries('CVHN',@dFechaFin))
					end
				if (@hn is null)
					begin
						set @hn = 1
					end
				-- Tipo de Cambio Nicaragua
				SET @NI	=(select cvsv.dbo.ObtenerTcOficial('CVNI',@dFechaFin))
				if (@ni is null)
					begin
						set @ni = (select cvsv.dbo.GetTcCountries('CVNI',@dFechaFin))
					end
				if (@ni is null)
					begin
						set @ni = 1
					end
				-- Tipo de Cambio Costa Rica
				SET @CR =(select cvsv.dbo.ObtenerTcOficial('CVCR',@dFechaFin))
				if (@cr is null)
					begin
						set @cr = (select cvsv.dbo.GetTcCountries('CVCR',@dFechaFin))
					end
				if (@cr is null)
					begin
						set @cr = 1
					end
				-- Tipo de Cambio Colombia
				SET @CO	=(select cvsv.dbo.ObtenerTcOficial('CVCO',@dFechaFin))
				if (@co is null)
					begin
						set @Co = (select cvsv.dbo.GetTcCountries('CVCO',@dFechaFin))
					end
				if (@Co is null)
					begin
						set @Co = 1
					end
				---
				EXEC CVSV.DBO.SIG_VtaPEP35mm @dFechaIni,@dFechaFin,@gt,@HN,@NI,@CR,@CO
				EXEC CVSV.DBO.SIG_VtaPEPCineSp @dFechaIni,@dFechaFin,@gt,@HN,@NI,@CR,@CO
				EXEC CVSV.DBO.SIG_VtaPEPSlidesD @dFechaIni,@dFechaFin,@gt,@HN,@NI,@CR,@CO
				EXEC CVSV.DBO.SIG_VtaPEPExtras @dFechaIni,@dFechaFin,@gt,@HN,@NI,@CR,@CO
				EXEC CVSV.DBO.SIG_VtaPAC @dFechaIni,@dFechaFin,@gt,@HN,@NI,@CR,@CO
				INSERT INTO #SIGConso_CV
					SELECT Rubro,ROUND(GT,0),ROUND(SV,0),ROUND(HN,0),ROUND(NI,0),ROUND(CR,0),ROUND(PA,0),ROUND(CO,0),
							ROUND(TOTAL,0),' ' AS PORCENT  
					FROM #SIGConso_VENTA
				-- Actualizo los valores en la tabla temporal
				update #VentasMeses set Guatemala	=(select sum(gt) from #SIGConso_Venta where IdMes=@iMonthFirst),
										ElSalvador	=(select sum(sv) from #SIGConso_Venta where IdMes=@iMonthFirst),
										Honduras	=(select sum(hn) from #SIGConso_Venta where IdMes=@iMonthFirst),
										Nicaragua	=(select sum(ni) from #SIGConso_Venta where IdMes=@iMonthFirst),
										CostaRica	=(select sum(cr) from #SIGConso_Venta where IdMes=@iMonthFirst),
										Panama		=(select sum(pa) from #SIGConso_Venta where IdMes=@iMonthFirst),
										Colombia	=(select sum(co) from #SIGConso_Venta where IdMes=@iMonthFirst)
						where IdMes = @iMonthFirst

				-- Actualizo Fechas Iniciales y Finales 
				set @dFechaIni = convert(char(10),DateAdd(ms,-1,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'
				set @dFechaFin = convert(char(10),DateAdd(ms,-2,DATEADD(mm,1 , @dFechaIni)),121)+' 00:00:00'
				set @iMonthFirst = @iMonthFirst + 1
				-- borro la información de las tablas
				delete from #SIGConso_CxC
				delete from #SIGConso_CV
				delete from #SIGConso_VENTA
				delete from #SIGConso_CxCPORCENT
			end
		
		-- Actualizo el total de las ventas
		update #VentasMeses set total = Guatemala+ElSalvador+Honduras+Nicaragua+CostaRica+Panama+Colombia
		--
		insert into #VentasMeses 
			select null,null,null,null,null,null,null,null,null,null
		--
		-- Inserto Totales
		insert into #VentasMeses
			select 0,'TOTALES.....',sum(Guatemala),sum(ElSalvador),sum(Honduras),sum(Nicaragua),sum(CostaRica),sum(Panama),
					sum(Colombia),sum(Total)
			from #VentasMeses
		
		--
		insert into #VentasMeses 
			select null,null,null,null,null,null,null,null,null,null
		--
		--Inserto % Participación
		insert into #VentasMeses
			select 0,'% Participación',
					Round((sum(T0.Guatemala)/sum(T1.TotalGlobal))*100,2),
					Round((sum(T0.ElSalvador)/sum(T1.TotalGlobal))*100,2),
					Round((sum(T0.Honduras)/sum(T1.TotalGlobal))*100,2),
					Round((sum(T0.Nicaragua)/sum(T1.TotalGlobal))*100,2),
					Round((sum(T0.CostaRica)/sum(T1.TotalGlobal))*100,2),
					Round((sum(T0.Panama)/sum(T1.TotalGlobal))*100,2),
					Round((sum(T0.Colombia)/sum(T1.TotalGlobal))*100,2),
					null
			from #VentasMeses T0 cross join 
				(select sum(Total) as TotalGlobal from #VentasMeses where Mes = 'TOTALES.....') T1 
			where T0.Mes = 'TOTALES.....'
		--
		
		select Mes,Guatemala,ElSalvador,Honduras,Nicaragua,CostaRica,Panama,Colombia,Total
		from #VentasMeses
		
		DROP TABLE #SIGConso_CxC
		DROP TABLE #SIGConso_CV
		DROP TABLE #SIGConso_VENTA
		DROP TABLE #SIGConso_CxCPORCENT
		drop table #VentasMeses
		
		---select 
	end
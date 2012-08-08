CREATE TABLE #SIGConsoCXC_CV
      (Descripcion	NCHAR(100)	NULL,
       GT		NUMERIC(19,6)	NULL,
       SV		NUMERIC(19,6)	NULL,
		hn numeric(19,6) null,
       CR  		NUMERIC(19,6)	NULL,
       PA		NUMERIC(19,6)	NULL,
       DO  		NUMERIC(19,6)	NULL,
	TOTAL		NUMERIC(19,6)	NULL)

CREATE TABLE #SIGConso_CxC
      (Cartera		NCHAR(100)	NULL,
       GT		NUMERIC(19,6)	NULL,
       SV		NUMERIC(19,6)	NULL,
	   HN numeric(19,6) null,
       CR  		NUMERIC(19,6)	NULL,
       PA		NUMERIC(19,6)	NULL,
       DO  		NUMERIC(19,6)	NULL,
	TOTAL		NUMERIC(19,6)	NULL)

CREATE TABLE #SIGConso_CxCAFI
      (Cartera		NCHAR(100)	NULL,
       GT		NUMERIC(19,6)	NULL,
       SV		NUMERIC(19,6)	NULL,
		hn numeric(19,6) null ,
       CR  		NUMERIC(19,6)	NULL,
       PA		NUMERIC(19,6)	NULL,
       DO  		NUMERIC(19,6)	NULL,
	TOTAL		NUMERIC(19,6)	NULL)

CREATE TABLE #SIGConso_CxCTHEAT
      (Cartera		NCHAR(100)	NULL,
       GT		NUMERIC(19,6)	NULL,
       SV		NUMERIC(19,6)	NULL,
		hn numeric(19,6) null,
       CR  		NUMERIC(19,6)	NULL,
       PA		NUMERIC(19,6)	NULL,
       DO  		NUMERIC(19,6)	NULL,
	TOTAL		NUMERIC(19,6)	NULL)


DECLARE @GT AS NUMERIC(19,6),
		@CR AS NUMERIC(19,6),
		@DO AS NUMERIC(19,6),
		@hn as numeric(19,6),

		@fecha2 as datetime,
		@iInDesign as numeric

set @iInDesign = 1

if (@iInDesign =1)
	begin
		set @Fecha2 = '12/31/2011 00:00:00'
	end
else
	begin
		/* SELECT FROM CVSV.DBO.INV1 T1 */
		SET @fecha2 = /* T1.DocDate */ '[%0]'
		--set @Fecha2 = '04/30/2010 00:00:00'
	end

SET @GT=(SELECT RATE FROM PRGT.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)
SET @CR=(SELECT RATE FROM VMCR.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)
SET @DO =(SELECT RATE FROM VMDO.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)
set @hn = (SELECT RATE FROM prhn.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)

--select * from prhn.dbo.ortt order by ratedate desc

EXEC CxCNormalSIN_AFIACTUAL @fecha2,@GT,@hn,@CR,@DO
EXEC CxCA30SIN_AFIACTUAL @fecha2,@GT,@hn,@CR,@DO
EXEC CxCA60SIN_AFIACTUAL @fecha2,@GT,@hn,@CR,@DO
EXEC CxCA90SIN_AFIACTUAL @fecha2,@GT,@hn,@CR,@DO
EXEC CxCA120SIN_AFIACTUAL @fecha2,@GT,@hn,@CR,@DO
EXEC CxCMAS120SIN_AFIACTUAL @fecha2,@GT,@hn,@CR,@DO


INSERT INTO #SIGConsoCXC_CV (Descripcion) VALUES ('  ')
INSERT INTO #SIGConsoCXC_CV (Descripcion) VALUES ('------       CUENTAS POR COBRAR     ------')
INSERT INTO #SIGConsoCXC_CV
SELECT * FROM #SIGConso_CxC

INSERT INTO #SIGConsoCXC_CV (Descripcion) VALUES ('  ')
INSERT INTO #SIGConsoCXC_CV
SELECT 
'SALDO CLIENTES' AS Cartera	,
   SUM(GT),
   SUM(SV),

	sum(hn),
   SUM(CR),
   SUM(PA),
   SUM(DO),
   SUM(TOTAL) FROM #SIGConso_CxC
INSERT INTO #SIGConsoCXC_CV (Descripcion) VALUES ('  ')


/*INGRESANDO SALDO DE LAS AFI*/

EXEC CxCNormalAFI_r1 @fecha2,@GT,@hn,@CR,@DO
EXEC CxCA30AFI_r1 @fecha2,@GT,@hn,@CR,@DO
EXEC CxCA60AFI_r1 @fecha2,@GT,@hn,@CR,@DO
EXEC CxCA90AFI_r1 @fecha2,@GT,@hn,@CR,@DO
EXEC CxCA120AFI_r1 @fecha2,@GT,@hn,@CR,@DO
EXEC CxCMAS120AFI_r1 @fecha2,@GT,@hn,@CR,@DO


INSERT INTO #SIGConsoCXC_CV (Descripcion) VALUES ('  ')
INSERT INTO #SIGConsoCXC_CV
SELECT 
'SALDO AFILIADAS' AS Cartera	,
   SUM(GT),
   SUM(SV),
	sum(hn),
   SUM(CR),
   SUM(PA),
   SUM(DO),
   SUM(TOTAL) FROM #SIGConso_CxCAFI


INSERT INTO #SIGConso_CxC
SELECT * FROM #SIGConso_CxCAFI

/*INGRESANDO THEATRICAL*/

/*INGRESANDO SALDO DE LAS AFI*/

EXEC CxCNormalTHEAT_r1 @fecha2,@GT,@HN,@CR,@DO
EXEC CxCA30THEAT_r1 @fecha2,@GT,@HN,@CR,@DO
EXEC CxCA60THEAT_r1 @fecha2,@GT,@HN,@CR,@DO
EXEC CxCA90THEAT_r1 @fecha2,@GT,@HN,@CR,@DO
EXEC CxCA120THEAT_r1 @fecha2,@GT,@HN,@CR,@DO
EXEC CxCMAS120THEAT_r1 @fecha2,@GT,@HN,@CR,@DO


INSERT INTO #SIGConsoCXC_CV (Descripcion) VALUES ('  ')
INSERT INTO #SIGConsoCXC_CV
SELECT 
'SALDO THEATRICAL' AS Cartera	,
   SUM(GT),
   SUM(SV),
  sum(hn),
   SUM(CR),
   SUM(PA),
   SUM(DO),
   SUM(TOTAL) FROM #SIGConso_CxCTHEAT

-- select * from #SIGConso_CxCTHEAT

INSERT INTO #SIGConso_CxC
SELECT * FROM #SIGConso_CxCTHEAT

/*FIN THEATRICAL*/

INSERT INTO #SIGConsoCXC_CV (Descripcion) VALUES ('  ')
INSERT INTO #SIGConsoCXC_CV
SELECT 
'TOTAL GENERAL' AS Cartera	,
   SUM(GT),
   SUM(SV),
	sum(hn),
   SUM(CR),
   SUM(PA),
   SUM(DO),
   SUM(TOTAL) FROM #SIGConso_CxC
INSERT INTO #SIGConsoCXC_CV (Descripcion) VALUES ('  ')

INSERT INTO #SIGConsoCXC_CV (Descripcion,GT,SV,HN,CR,PA,DO) VALUES ('Tipo de Cambio a la Fecha Final de Selección:',@GT,1,@HN,@CR,1,@DO)

SELECT Descripcion,
	GT AS 'Guatemala',
       SV  AS 'El Salvador',
		HN AS 'Honduras',
       CR  AS 'Costa Rica',
       PA  AS 'Panama',
       DO  AS 'Dominicana',
	TOTAL		
 FROM #SIGConsoCXC_CV


DROP TABLE #SIGConso_CxC
DROP TABLE #SIGConsoCXC_CV
DROP TABLE #SIGConso_CxCAFI
drop table #SIGConso_CxCTHEAT
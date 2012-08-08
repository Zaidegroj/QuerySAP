CREATE TABLE #SIGConsoCXC_CV
      (Descripcion	NCHAR(100)	NULL,
       GT		NUMERIC(19,6)	NULL,
       SV		NUMERIC(19,6)	NULL,
       HN		NUMERIC(19,6)	NULL,
       NI		NUMERIC(19,6)	NULL,
       CR  		NUMERIC(19,6)	NULL,
       PA		NUMERIC(19,6)	NULL,
       CO  		NUMERIC(19,6)	NULL,
	TOTAL		NUMERIC(19,6)	NULL)

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

CREATE TABLE #SIGConso_CxCAFI
      (Cartera		NCHAR(100)	NULL,
       GT		NUMERIC(19,6)	NULL,
       SV		NUMERIC(19,6)	NULL,
       HN		NUMERIC(19,6)	NULL,
       NI		NUMERIC(19,6)	NULL,
       CR  		NUMERIC(19,6)	NULL,
       PA		NUMERIC(19,6)	NULL,
       CO  		NUMERIC(19,6)	NULL,
	TOTAL		NUMERIC(19,6)	NULL)


DECLARE @GT AS NUMERIC(19,6),
		@HN AS NUMERIC(19,6),
		@NI AS NUMERIC(19,6),
		@CR AS NUMERIC(19,6),
		@CO AS NUMERIC(19,6),
		@fecha2 as datetime,
		@iInDesign as int 

set @iInDesign = 1

if (@iInDesign = 1)
	begin
		set @fecha2 = '08/31/2010 00:00:00'
	end
else
	begin
		/* SELECT FROM CVSV.DBO.INV1 T1 */
		SET @fecha2 = /* T1.DocDate */ '[%0]'
	end

set @GT = (select rate from cvgt.dbo.ortt t0 where ratedate = @fecha2)
SET @HN=(SELECT RATE FROM CVHN.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)
SET @NI=(SELECT RATE FROM CVNI.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)
SET @CR =(SELECT RATE FROM CVCR.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)
SET @CO=(SELECT RATE FROM CVCO.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)



EXEC SIG_CxCNormalSAFI @fecha2,@gt,@HN,@NI,@CR,@CO
EXEC SIG_CxCA30SAFI @fecha2,@gt,@HN,@NI,@CR,@CO
EXEC SIG_CxCA60SAFI @fecha2,@gt,@HN,@NI,@CR,@CO
EXEC SIG_CxCA90SAFI @fecha2,@gt,@HN,@NI,@CR,@CO
EXEC SIG_CxCA120SAFI @fecha2,@gt,@HN,@NI,@CR,@CO
EXEC SIG_CxCM120SAFI @fecha2,@gt,@HN,@NI,@CR,@CO
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
   SUM(HN),
   SUM(NI),
   SUM(CR),
   SUM(PA),
   SUM(CO),
   SUM(TOTAL) FROM #SIGConso_CxC
INSERT INTO #SIGConsoCXC_CV (Descripcion) VALUES ('  ')


/*INGRESANDO SALDO DE LAS AFI*/

EXEC SIG_CxCNormalAFI @fecha2,@gt,@HN,@NI,@CR,@CO
EXEC SIG_CxCA30AFI @fecha2,@gt,@HN,@NI,@CR,@CO
EXEC SIG_CxCA60AFI @fecha2,@gt,@HN,@NI,@CR,@CO
EXEC SIG_CxCA90AFI @fecha2,@gt,@HN,@NI,@CR,@CO
EXEC SIG_CxCA120AFI @fecha2,@gt,@HN,@NI,@CR,@CO
EXEC SIG_CxCM120AFI @fecha2,@gt,@HN,@NI,@CR,@CO


INSERT INTO #SIGConsoCXC_CV (Descripcion) VALUES ('  ')
INSERT INTO #SIGConsoCXC_CV
SELECT 
'SALDO AFILIADAS' AS Cartera	,
   SUM(GT),
   SUM(SV),
   SUM(HN),
   SUM(NI),
   SUM(CR),
   SUM(PA),
   SUM(CO),
   SUM(TOTAL) FROM #SIGConso_CxCAFI


INSERT INTO #SIGConso_CxC
SELECT * FROM #SIGConso_CxCAFI

INSERT INTO #SIGConsoCXC_CV (Descripcion) VALUES ('  ')
INSERT INTO #SIGConsoCXC_CV
SELECT 
'TOTAL GENERAL' AS Cartera	,
   SUM(GT),
   SUM(SV),
   SUM(HN),
   SUM(NI),
   SUM(CR),
   SUM(PA),
   SUM(CO),
   SUM(TOTAL) FROM #SIGConso_CxC
INSERT INTO #SIGConsoCXC_CV (Descripcion) VALUES ('  ')

INSERT INTO #SIGConsoCXC_CV (Descripcion,GT,SV,HN,NI,CR,PA,CO) VALUES ('Tipo de Cambio a la Fecha Final de Selección:',@gt,1,@HN,@NI,@CR,1,@CO)

SELECT Descripcion,
	GT AS 'Guatemala',
       SV  AS 'El Salvador',
       HN  AS 'Honduras',
       NI  AS 'Nicaragua',
       CR  AS 'Costa Rica',
       PA  AS 'Panama',
       CO  AS 'Colombia',
	TOTAL		
 FROM #SIGConsoCXC_CV




DROP TABLE #SIGConso_CxC
DROP TABLE #SIGConsoCXC_CV
DROP TABLE #SIGConso_CxCAFI
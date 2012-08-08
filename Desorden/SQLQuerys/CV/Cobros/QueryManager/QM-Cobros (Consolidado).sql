CREATE TABLE #SIGConsoCobros_CV
      (Descripcion	NCHAR(100)	NULL,
       GT		NUMERIC(19,6)	NULL,
       SV		NUMERIC(19,6)	NULL,
       HN		NUMERIC(19,6)	NULL,
       NI		NUMERIC(19,6)	NULL,
       CR  		NUMERIC(19,6)	NULL,
       PA		NUMERIC(19,6)	NULL,
       CO  		NUMERIC(19,6)	NULL,
	TOTAL		NUMERIC(19,6)	NULL)


CREATE TABLE #SIGConsoCobros_CVTOT
      (Descripcion	NCHAR(100)	NULL,
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
		@fecha1 as datetime,
		@fecha2 as datetime,
		@iInDesign as int


set @iInDesign = 1

if (@iInDesign = 1)
	begin
		set @Fecha1 = '01/01/2010 00:00:00'
		set @fecha2 = '08/31/2010 00:00:00'
	end
else
	begin
		/* SELECT FROM CVSV.DBO.INV1 T1 */
		SET @fecha1 = /* T1.DocDate */ '[%4]'
		SET @fecha2 = /* T1.DocDate */ '[%5]'
	end

set @GT=(select rate from cvgt.dbo.ortt T0 where ratedate = @fecha2)
SET @HN=(SELECT RATE FROM CVHN.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)
SET @NI=(SELECT RATE FROM CVNI.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)
SET @CR =(SELECT RATE FROM CVCR.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)
SET @CO=(SELECT RATE FROM CVCO.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)


INSERT INTO #SIGConsoCobros_CV (Descripcion) VALUES ('  ')
INSERT INTO #SIGConsoCobros_CV (Descripcion) VALUES ('------------     COBROS     ------------ ')
EXEC ConsoCobrosSINAfiliada @gt,@HN,@NI,@CR,@CO,@fecha1,@fecha2
EXEC ConsoCobrosAFI @gt,@HN,@NI,@CR,@CO,@fecha1,@fecha2
INSERT INTO #SIGConsoCobros_CV (Descripcion) VALUES ('  ')
INSERT INTO #SIGConsoCobros_CVTOT
SELECT * FROM #SIGConsoCobros_CV

INSERT INTO #SIGConsoCobros_CV
SELECT 
'TOTAL COBROS' AS Descripcion	,
   SUM(GT),
   SUM(SV),
   SUM(HN),
   SUM(NI),
   SUM(CR),
   SUM(PA),
   SUM(CO),
   SUM(TOTAL) FROM  #SIGConsoCobros_CVTOT

INSERT INTO #SIGConsoCobros_CV (Descripcion) VALUES ('  ')
INSERT INTO #SIGConsoCobros_CV (Descripcion,GT,SV,HN,NI,CR,PA,CO) VALUES ('Tipo de Cambio a la Fecha Final de Selección:',@gt,1,@HN,@NI,@CR,1,@CO)

SELECT Descripcion,
	   GT AS 'Guatemala',
       SV  AS 'El Salvador',
       HN  AS 'Honduras',
       NI  AS 'Nicaragua',
       CR  AS 'Costa Rica',
       PA  AS 'Panama',
       CO  AS 'Colombia',
	TOTAL		
 FROM #SIGConsoCobros_CV


DROP TABLE #SIGConsoCobros_CV
DROP TABLE #SIGConsoCobros_CVTOT
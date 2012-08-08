CREATE TABLE #SIGConso_CV
      (Descripcion	NCHAR(100)	NULL,
       GT		NUMERIC(19,6)	NULL,
       SV		NUMERIC(19,6)	NULL,
       HN		NUMERIC(19,6)	NULL,
       NI		NUMERIC(19,6)	NULL,
       CR  		NUMERIC(19,6)	NULL,
       PA		NUMERIC(19,6)	NULL,
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
	TOTAL		NUMERIC(19,6)	NULL)

CREATE TABLE #SIGConso_VENTA
      (Rubro		NCHAR(100)	NULL,
       GT		NUMERIC(19,6)	NULL,
       SV		NUMERIC(19,6)	NULL,
       HN		NUMERIC(19,6)	NULL,
       NI		NUMERIC(19,6)	NULL,
       CR  		NUMERIC(19,6)	NULL,
       PA		NUMERIC(19,6)	NULL,
	TOTAL		NUMERIC(19,6)	NULL)

CREATE TABLE #SIGConso_CxCPORCENT
      (Cartera		NCHAR(100)	NULL,
       GT		NUMERIC(19,6)	NULL,
       SV		NUMERIC(19,6)	NULL,
       HN		NUMERIC(19,6)	NULL,
       NI		NUMERIC(19,6)	NULL,
       CR  		NUMERIC(19,6)	NULL,
       PA		NUMERIC(19,6)	NULL,
	TOTAL		NUMERIC(19,6)	NULL,
	PORCENT		INT	NULL)

DECLARE @GT AS NUMERIC(19,6)
DECLARE @HN AS NUMERIC(19,6)
DECLARE @NI AS NUMERIC(19,6)
DECLARE @CR AS NUMERIC(19,6)
DECLARE @fecha1 as datetime
DECLARE @fecha2 as datetime,
		@InDesign as int

set @InDesign = 1

if (@InDesign = 1)
	begin
		set @fecha1 = '08/01/2010 00:00:00'
		set @fecha2 = '08/31/2010 00:00:00'
	end
else
	begin
		/* SELECT FROM CVSV.DBO.INV1 T1 */
		SET @fecha1 = /* T1.DocDate */ '[%4]'
		SET @fecha2 = /* T1.DocDate */ '[%5]'
	end

/* SIIIIIN COLOMBIA*/

set @gt = (SELECT RATE FROM CVGT.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)
SET @HN=(SELECT RATE FROM CVHN.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)
SET @NI=(SELECT RATE FROM CVNI.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)
SET @CR =(SELECT RATE FROM CVCR.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)

EXEC CVSV.DBO.SIG_VtaPEP35mmSCO_v11 @fecha1,@fecha2,@gt,@HN,@NI,@CR
EXEC CVSV.DBO.SIG_VtaPEPCineSpSCO_v11 @fecha1,@fecha2,@gt,@HN,@NI,@CR
EXEC CVSV.DBO.SIG_VtaPEPSlidesDSCO_v11 @fecha1,@fecha2,@gt,@HN,@NI,@CR
/*EXEC SIG_VtaPEPExtrasSCO @fecha1,@fecha2,@HN,@NI,@CR,@CO*/
EXEC CVSV.DBO.SIG_VtaPACSCO_v11 @fecha1,@fecha2,@gt,@HN,@NI,@CR
INSERT INTO #SIGConso_CV (Descripcion) VALUES ('*              VENTAS                 *')
INSERT INTO #SIGConso_CV
SELECT Rubro,ROUND(GT,0),ROUND(SV,0),ROUND(HN,0),ROUND(NI,0),ROUND(CR,0),ROUND(PA,0),ROUND(TOTAL,0),' ' AS PORCENT  FROM #SIGConso_VENTA     
/*AQUI MODIFSELECT * FROM #SIGConso_VENTA*/
INSERT INTO #SIGConso_CV (Descripcion) VALUES ('  ')
INSERT INTO  #SIGConso_CV
SELECT 
'TOTAL VENTAS' AS Rubro	,
   ROUND(SUM(GT),0),
   ROUND(SUM(SV),0),
   ROUND(SUM(HN),0),
   ROUND(SUM(NI),0),
   ROUND(SUM(CR),0),
   ROUND(SUM(PA),0),
   ROUND(SUM(TOTAL),0),' ' AS PORCENT FROM #SIGConso_VENTA	
	
INSERT INTO #SIGConso_CV (Descripcion) VALUES ('  ')
INSERT INTO #SIGConso_CV (Descripcion) VALUES ('*                COBROS              * ')
EXEC CVSV.DBO.ConsoCobrosSAFI_SCO_v11 @gt,@HN,@NI,@CR,null,@fecha1,@fecha2


EXEC CVSV.DBO.SIG_CxCNormalSAFI_SCO_v11 @fecha2,@gt,@HN,@NI,@CR
EXEC CVSV.DBO.SIG_CxCA30SAFI_SCO_v11 @fecha2,@gt,@HN,@NI,@CR
EXEC CVSV.DBO.SIG_CxCA60SAFI_SCO_v11 @fecha2,@gt,@HN,@NI,@CR
EXEC CVSV.DBO.SIG_CxCA90SAFI_SCO_v11 @fecha2,@gt,@HN,@NI,@CR
EXEC CVSV.DBO.SIG_CxCA120SAFI_SCO_v11 @fecha2,@gt,@HN,@NI,@CR
EXEC CVSV.DBO.SIG_CxCM120SAFI_SCO_v11 @fecha2,@gt,@HN,@NI,@CR
INSERT INTO #SIGConso_CV (Descripcion) VALUES ('  ')
INSERT INTO #SIGConso_CV (Descripcion) VALUES ('*   CUENTAS POR COBRAR    *')

/*INSERT INTO #SIGConso_CV
SELECT * FROM #SIGConso_CxC*/

INSERT INTO #SIGConso_CxCPORCENT
SELECT Cartera,ROUND(GT,0),ROUND(SV,0),ROUND(HN,0),ROUND(NI,0),ROUND(CR,0),ROUND(PA,0),ROUND(TOTAL,0),0 AS PORCENT  
FROM #SIGConso_CxC

UPDATE #SIGConso_CxCPORCENT  SET PORCENT=CAST(ROUND(TOTAL/(SELECT SUM(TOTAL) FROM #SIGConso_CxC) * 100,0 ) AS INT)
INSERT INTO #SIGConso_CxCPORCENT (Cartera) VALUES ('  ')
INSERT INTO #SIGConso_CxCPORCENT
SELECT 
'SALDO' AS Cartera	,
  ROUND(SUM(GT),0), 
  ROUND(SUM(SV),0),
  ROUND(SUM(HN),0),
  ROUND(SUM(NI),0),
  ROUND(SUM(CR),0),
  ROUND(SUM(PA),0),
  ROUND(SUM(TOTAL),0),0 AS PORCENT FROM #SIGConso_CxC

INSERT INTO #SIGConso_CV (Descripcion) VALUES ('  ')
INSERT INTO #SIGConso_CV (Descripcion) VALUES ('  ')
INSERT INTO #SIGConso_CV
SELECT Cartera,GT,SV,HN,NI,CR,PA,TOTAL,SUBSTRING(CAST(PORCENT AS NCHAR),1,3) + '%' AS PORCENT 
FROM #SIGConso_CxCPORCENT
UPDATE  #SIGConso_CV SET PORCENT=' ' WHERE Descripcion ='SALDO'

INSERT INTO #SIGConso_CV (Descripcion) VALUES ('  ')
INSERT INTO #SIGConso_CV (Descripcion,GT,SV,HN,NI,CR,PA) VALUES ('Tipo de Cambio a la Fecha Final de Selección:',@gt,1,@HN,@NI,@CR,1)

SELECT Descripcion,
	 GT AS 'Guatemala',
       SV  AS 'El Salvador',
       HN  AS 'Honduras',
       NI  AS 'Nicaragua',
       CR  AS 'Costa Rica',
       PA  AS 'Panama',
	TOTAL,
	PORCENT		
 FROM #SIGConso_CV


DROP TABLE #SIGConso_CxC
DROP TABLE #SIGConso_CV
DROP TABLE #SIGConso_VENTA
DROP TABLE #SIGConso_CxCPORCENT


--select * from vmsv.dbo.oitw
--select * from vmsv.dbo.oitm
--select * from vmcr.dbo.oinm where itemcode = '7509656300814' order by docdate desc
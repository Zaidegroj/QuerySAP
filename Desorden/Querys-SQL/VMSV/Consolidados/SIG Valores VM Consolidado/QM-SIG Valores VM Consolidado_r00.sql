DECLARE @GT AS NUMERIC(19,6)
DECLARE @HN AS NUMERIC(19,6)
DECLARE @CR AS NUMERIC(19,6)
DECLARE @DO AS NUMERIC(19,6)
DECLARE @fecha1 as datetime
DECLARE @fecha2 as datetime

CREATE TABLE #Conso_VIDEOMARK
      (Descripcion	NCHAR(100)	NULL,
       GT		NUMERIC(19,6)	NULL,
       SV		NUMERIC(19,6)	NULL,
       HN		NUMERIC(19,6)	NULL,
       CR		NUMERIC(19,6)	NULL,
       PA		NUMERIC(19,6)	NULL,
       DO  		NUMERIC(19,6)	NULL,
       TOTAL		NUMERIC(19,6)	NULL,
       PORCENT		NCHAR(100)	NULL)

CREATE TABLE #Conso_VTAVIDEOMARK
      (Descripcion	NCHAR(100)	NULL,
       GT		NUMERIC(19,6)	NULL,
       SV		NUMERIC(19,6)	NULL,
       HN		NUMERIC(19,6)	NULL,
       CR		NUMERIC(19,6)	NULL,
       PA		NUMERIC(19,6)	NULL,
       DO  		NUMERIC(19,6)	NULL,
       TOTAL		NUMERIC(19,6)	NULL)

CREATE TABLE #SIGConso_CxC
      (Cartera		NCHAR(100)	NULL,
       GT		NUMERIC(19,6)	NULL,
       SV		NUMERIC(19,6)	NULL,
       HN		NUMERIC(19,6)	NULL,
       CR  		NUMERIC(19,6)	NULL,
       PA		NUMERIC(19,6)	NULL,
       DO  		NUMERIC(19,6)	NULL,
	TOTAL		NUMERIC(19,6)	NULL)

CREATE TABLE #Tmp_Exi

(Grupo    SMALLINT      NULL,
 Nombre   NVARCHAR(20)  NULL,
 Codigo   NVARCHAR(20)  NULL,
 Articulo NVARCHAR(100) NULL,
 GT       NUMERIC(19,6) NULL,
 SV       NUMERIC(19,6) NULL,
 HN       NUMERIC(19,6)	NULL,
 CR       NUMERIC(19,6) NULL,
 PA       NUMERIC(19,6) NULL,
 DO       NUMERIC(19,6) NULL,
TOTAL		NUMERIC(19,6)	NULL)

CREATE TABLE #SIGConso_CxCPORCENT
      (Cartera		NCHAR(100)	NULL,
       GT		NUMERIC(19,6)	NULL,
       SV		NUMERIC(19,6)	NULL,
       HN	        NUMERIC(19,6)	NULL,
       CR  		NUMERIC(19,6)	NULL,
       PA		NUMERIC(19,6)	NULL,
       DO  		NUMERIC(19,6)	NULL,
	TOTAL		NUMERIC(19,6)	NULL,
	PORCENT		INT	NULL)



/* SELECT FROM VMSV.DBO.INV1 T1 */
SET @fecha1 = /* T1.DocDate */ '[%3]'
SET @fecha2 = /* T1.DocDate */ '[%4]'

SET @CR=(SELECT RATE FROM VMCR.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)
SET @DO=(SELECT RATE FROM VMDO.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)
SET @GT=(SELECT RATE FROM PRGT.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)
SET @HN=(SELECT RATE FROM PRHN.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)

EXEC VMSV.DBO.Conso_VtaVMACTUAL @fecha1,@fecha2,@GT,@HN,@CR,@DO


INSERT INTO #Conso_VIDEOMARK (Descripcion) VALUES ('*                 VENTAS                      *')
INSERT INTO #Conso_VIDEOMARK
SELECT Descripcion, ROUND(GT,0),ROUND(SV,0),ROUND(HN,0),ROUND(CR,0),ROUND(PA,0),ROUND(DO,0),ROUND(TOTAL,0),' ' AS PORCENT FROM #Conso_VTAVIDEOMARK

/*Ingresando el total*/
INSERT INTO #Conso_VIDEOMARK (Descripcion) VALUES ('  ')
INSERT INTO #Conso_VIDEOMARK
SELECT 'TOTAL VENTAS' AS Descripcion,ROUND(SUM(GT),0),ROUND(SUM(SV),0),ROUND(SUM(HN),0),ROUND(SUM(CR),0),ROUND(SUM(PA),0),ROUND(SUM(DO),0),ROUND(SUM(TOTAL),0), ' ' AS PORCENT FROM #Conso_VTAVIDEOMARK
/*AGREGANDO LOS COBROS*/
INSERT INTO #Conso_VIDEOMARK (Descripcion) VALUES ('  ')
INSERT INTO #Conso_VIDEOMARK (Descripcion) VALUES ('*                 COBROS                      *')
/*EST SP Es el unico q modifiq para la part entera lo demas lo hice en este seg.(ppal) ya q los otros SP son mas complejos y pueden ser reutilizados con el format decimal*/
EXEC VMSV.DBO.Conso_CobrosVMACTUAL @fecha1,@fecha2,@GT,@HN,@CR,@DO

/*AGREGANDO LA CUENTA CORRIENTE*/

EXEC VMSV.DBO.CxCNormalSIN_AFIACTUAL @fecha2,@GT,@HN,@CR,@DO
EXEC VMSV.DBO.CxCA30SIN_AFIACTUAL @fecha2,@GT,@HN,@CR,@DO
EXEC VMSV.DBO.CxCA60SIN_AFIACTUAL @fecha2,@GT,@HN,@CR,@DO
EXEC VMSV.DBO.CxCA90SIN_AFIACTUAL @fecha2,@GT,@HN,@CR,@DO
EXEC VMSV.DBO.CxCA120SIN_AFIACTUAL @fecha2,@GT,@HN,@CR,@DO
EXEC VMSV.DBO.CxCMAS120SIN_AFIACTUAL @fecha2,@GT,@HN,@CR,@DO



INSERT INTO #SIGConso_CxCPORCENT
SELECT Cartera,ROUND(GT,0),ROUND(SV,0),ROUND(HN,0),ROUND(CR,0),ROUND(PA,0),ROUND(DO,0),ROUND(TOTAL,0),'0' AS PORCENT FROM #SIGConso_CxC

UPDATE #SIGConso_CxCPORCENT  SET PORCENT=CAST(ROUND(TOTAL/(SELECT SUM(TOTAL) FROM #SIGConso_CxC) * 100,-1 ) AS INT)
INSERT INTO #SIGConso_CxCPORCENT (Cartera) VALUES ('  ')
INSERT INTO #SIGConso_CxCPORCENT
SELECT 
'SALDO' AS Cartera	,
  ROUND(SUM(GT),0),
  ROUND(SUM(SV),0),
  ROUND(SUM(HN),0),
  ROUND(SUM(CR),0),
  ROUND(SUM(PA),0),
  ROUND(SUM(DO),0),
  ROUND(SUM(TOTAL),0),'0' AS PORCENT FROM #SIGConso_CxC

INSERT INTO #Conso_VIDEOMARK (Descripcion) VALUES ('  ')

INSERT INTO #Conso_VIDEOMARK (Descripcion,PORCENT) VALUES ('*       CUENTAS POR COBRAR          *','%')
INSERT INTO #Conso_VIDEOMARK
SELECT Cartera, GT,SV,HN,CR,PA,DO,TOTAL,SUBSTRING(CAST(PORCENT AS NCHAR),1,3) + '%' AS PORCENT FROM #SIGConso_CxCPORCENT
UPDATE  #Conso_VIDEOMARK SET PORCENT=' ' WHERE Descripcion ='SALDO'

/*AGREGANDO EL INVENTARIO*/
INSERT INTO #Conso_VIDEOMARK (Descripcion) VALUES ('  ')
INSERT INTO #Conso_VIDEOMARK (Descripcion) VALUES ('*               INVENTARIO                  *')

EXEC VMSV.DBO.Conso_InventVMACTUAL @GT,@HN,@CR,@DO

INSERT INTO #Conso_VIDEOMARK
SELECT Nombre        AS Nombre       ,
       ROUND(SUM(GT),0)       AS GT  ,
       ROUND(SUM(SV),0)       AS SV  ,
       ROUND(SUM(HN),0)       AS HN  ,
       ROUND(SUM(CR),0)       AS CR  ,
       ROUND(SUM(PA),0)       AS PA  ,
       ROUND(SUM(DO),0)       AS DO  ,
       ROUND(SUM(SV),0) + ROUND(SUM(HN),0) + ROUND(SUM(CR),0) + ROUND(SUM(PA),0) + ROUND(SUM(GT),0) + ROUND(SUM(DO),0) AS TOTAL,
	' ' 	     AS PORCENT
 FROM  #Tmp_Exi
 GROUP BY 
          Nombre	  
ORDER BY Nombre

/*AGREGANDO EL TOTAL DE EXISTENCIA*/
INSERT INTO #Conso_VIDEOMARK (Descripcion) VALUES ('  ')
INSERT INTO #Conso_VIDEOMARK
SELECT 'TOTAL EXISTENCIAS'        AS Nombre ,
       ROUND(SUM(GT),0)       AS GT  ,
       ROUND(SUM(SV),0)       AS SV  ,
       ROUND(SUM(HN),0)       AS HN  ,
       ROUND(SUM(CR),0)       AS CR  ,
       ROUND(SUM(PA),0)       AS PA  ,
       ROUND(SUM(DO),0)       AS DO  ,
       ROUND(SUM(SV),0) + ROUND(SUM(HN),0) + ROUND(SUM(CR),0) + ROUND(SUM(PA),0) + ROUND(SUM(GT),0) + ROUND(SUM(DO),0) AS TOTAL,
	' ' 	     AS PORCENT
 FROM  #Tmp_Exi

INSERT INTO #Conso_VIDEOMARK (Descripcion) VALUES ('  ')
INSERT INTO #Conso_VIDEOMARK (Descripcion) VALUES ('  ')
INSERT INTO #Conso_VIDEOMARK (Descripcion,GT,SV,HN,CR,PA,DO) VALUES ('Tipo de Cambio a la Fecha Final de Selección:',@GT,1,@HN,@CR,1,@DO)

SELECT Descripcion,
	GT AS 'Guatemala',
             SV  AS 'El Salvador',
             HN AS 'Honduras',
            CR  AS 'Costa Rica',
            PA  AS 'Panama',
            DO  AS 'Dominicana',
            TOTAL,
            PORCENT	AS ' '	
 FROM #Conso_VIDEOMARK

/*SELECT * FROM  #Conso_VIDEOMARK*/



DROP TABLE  #Conso_VTAVIDEOMARK
DROP TABLE #Conso_VIDEOMARK
DROP TABLE #SIGConso_CxC
DROP TABLE #Tmp_Exi
DROP TABLE #SIGConso_CxCPORCENT
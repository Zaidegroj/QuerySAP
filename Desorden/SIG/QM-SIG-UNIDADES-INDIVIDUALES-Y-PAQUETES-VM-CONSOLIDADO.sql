/* SIG Unidades */

DECLARE @GT AS NUMERIC(19,4),
		@CR AS NUMERIC(19,4),
		@DO AS NUMERIC(19,4),
		@HN AS NUMERIC(19,4),
		@fecha1 as datetime,
		@fecha2 as datetime,
		@iInDesign as int


CREATE TABLE #Conso_VIDEOMARK
      (	Grupo smallint null,
		Descripcion	NCHAR(100)	NULL,
       GT		NUMERIC(19,4)	NULL,
       SV		NUMERIC(19,4)	NULL,
		HN		NUMERIC(19,4)	NULL,
       CR		NUMERIC(19,4)	NULL,
       PA		NUMERIC(19,4)	NULL,
       DO  		NUMERIC(19,4)	NULL,
       TOTAL	NUMERIC(19,4)	NULL,
		Bandera		NCHAR(10)	
		)

CREATE TABLE #Conso_VTAVIDEOMARK
      ( Grupo smallint null,
		Descripcion	NCHAR(100)	NULL,
       GT		NUMERIC(19,4)	NULL,
       SV		NUMERIC(19,4)	NULL,
		HN		NUMERIC(19,4)	NULL,
       CR		NUMERIC(19,4)	NULL,
       PA		NUMERIC(19,4)	NULL,
       DO  		NUMERIC(19,4)	NULL,
       TOTAL	NUMERIC(19,4)	NULL)

CREATE TABLE #SIGConso_CxC
      (Cartera	NCHAR(100)	NULL,
       GT		NUMERIC(19,4)	NULL,
       SV		NUMERIC(19,4)	NULL,
		HN		NUMERIC(19,4)	NULL,
       CR  		NUMERIC(19,4)	NULL,
       PA		NUMERIC(19,4)	NULL,
       DO  		NUMERIC(19,4)	NULL,
	TOTAL		NUMERIC(19,4)	NULL)

CREATE TABLE #Tmp_Exi

(Grupo    SMALLINT      NULL,
 Nombre   NVARCHAR(60)  NULL,
 Codigo   NVARCHAR(20)  NULL,
 Articulo NVARCHAR(100) NULL,
 GT       NUMERIC(19,4) NULL,
 SV       NUMERIC(19,4) NULL,
 HN		  NUMERIC(19,4)	NULL,
 CR       NUMERIC(19,4) NULL,
 PA       NUMERIC(19,4) NULL,
 DO       NUMERIC(19,4) NULL,
TOTAL	  NUMERIC(19,4)	NULL)


set @iInDesign = 1

if (@iInDesign = 1)
	begin
		set @Fecha1 = '01/01/2011 00:00:00'
		set @Fecha2 = '06/30/2011 00:00:00'
	end
else
	begin
		/* SELECT FROM VMSV.DBO.INV1 T1 */
		SET @fecha1 = /* T1.DocDate */ '[%3]'
		SET @fecha2 = /* T1.DocDate */ '[%4]'
	end

SET @CR=(SELECT RATE FROM VMCR.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)
SET @DO=(SELECT RATE FROM VMDO.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)
SET @GT=(SELECT RATE FROM PRGT.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)
SET @HN=(SELECT RATE FROM PRHN.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)

EXEC VMSV.DBO.ConsoUNI_VtaVM_IndivyPaquetes @fecha1,@fecha2

INSERT INTO #Conso_VIDEOMARK (Descripcion) VALUES ('*          VENTAS               *')
INSERT INTO #Conso_VIDEOMARK
SELECT null,Descripcion, sum(GT),sum(SV),sum(HN),sum(CR),sum(PA),sum(DO),sum(TOTAL),' ' AS Bandera 
FROM #Conso_VTAVIDEOMARK
group by descripcion

/* Ingresando el total */
INSERT INTO #Conso_VIDEOMARK (Descripcion) VALUES ('  ')
INSERT INTO #Conso_VIDEOMARK
SELECT null,'TOTAL VENTAS' AS Descripcion, SUM(GT),SUM(SV),SUM(HN),SUM(CR),SUM(PA),SUM(DO),
		SUM(TOTAL),' ' AS Bandera 
FROM #Conso_VTAVIDEOMARK

DELETE FROM #Conso_VTAVIDEOMARK
INSERT INTO #Conso_VIDEOMARK (Descripcion) VALUES ('  ')

INSERT INTO #Conso_VIDEOMARK (Descripcion) VALUES ('*            PRECIO PROMEDIO DE VENTA         *')

EXEC VMSV.DBO.ConsoUNI_PROMVM_IndivyPaquetes_Test2 @fecha1,@fecha2,@GT,@HN,@CR,@DO


INSERT INTO #Conso_VIDEOMARK
--SELECT null,Descripcion, sum(GT),sum(SV),sum(HN),sum(CR),sum(PA),sum(DO),sum(TOTAL),'p' AS Bandera 
--FROM #Conso_VTAVIDEOMARK
--group by descripcion
SELECT null,Descripcion, GT,SV,HN,CR,PA,DO,TOTAL,'p' AS Bandera FROM #Conso_VTAVIDEOMARK

INSERT INTO #Conso_VIDEOMARK (Descripcion) VALUES ('  ')

/*AGREGANDO EL INVENTARIO*/

INSERT INTO #Conso_VIDEOMARK (Descripcion) VALUES ('  ')
INSERT INTO #Conso_VIDEOMARK (Descripcion) VALUES ('*          INVENTARIO            *')

EXEC VMSV.DBO.ConsoUNI_InventVM_IndivyPaquetes

INSERT INTO #Conso_VIDEOMARK
SELECT null,Nombre        AS Nombre,
       SUM(GT)       AS GT  ,
       SUM(SV)       AS SV  ,
       SUM(HN)       AS SV  ,	
       SUM(CR)       AS CR  ,
       SUM(PA)       AS PA  ,
       SUM(DO)       AS DO  ,
       SUM(SV) + SUM(HN) + SUM(CR) + SUM (PA)+ SUM(GT) + SUM(DO) AS TOTAL,
	' ' AS Bandera
 FROM  #Tmp_Exi
 GROUP BY 
          Nombre	  
ORDER BY Nombre

/*AGREGANDO EL TOTAL DE EXISTENCIA*/
INSERT INTO #Conso_VIDEOMARK (Descripcion) VALUES ('  ')
INSERT INTO #Conso_VIDEOMARK
SELECT null,'TOTAL EXISTENCIAS'        AS Nombre ,
       SUM(GT)       AS GT  ,
       SUM(SV)       AS SV  ,
       SUM(HN)       AS HN  ,
       SUM(CR)       AS CR  ,
       SUM(PA)       AS PA  ,
       SUM(DO)       AS DO  ,
       SUM(SV)+ SUM(HN) + SUM(CR) + SUM (PA)+ SUM(GT) + SUM(DO) AS TOTAL,
       ' ' AS Bandera
 FROM  #Tmp_Exi
INSERT INTO #Conso_VIDEOMARK (Descripcion) VALUES ('  ')
INSERT INTO #Conso_VIDEOMARK (Descripcion) VALUES ('  ')

INSERT INTO #Conso_VIDEOMARK (Descripcion,GT,SV,HN,CR,PA,DO) 
		VALUES ('Tipo de Cambio a la Fecha Final de Selección:',@GT,1,@HN,@CR,1,@DO)


SELECT	Descripcion,
		GT AS 'Guatemala',
		SV  AS 'El Salvador',
		HN AS 'Honduras',
		CR  AS 'Costa Rica',
		PA  AS 'Panama',
		DO  AS 'Dominicana',
		TOTAL
FROM	#Conso_VIDEOMARK


DROP TABLE  #Conso_VTAVIDEOMARK
DROP TABLE #Conso_VIDEOMARK
DROP TABLE #SIGConso_CxC
DROP TABLE #Tmp_Exi

--SELECT * from PRHN.DBO.ORTT T0 order by ratedate desc
--SELECT * from prgt.DBO.ORTT T0 order by ratedate desc
--SELECT * from vmdo.DBO.ORTT T0 order by ratedate desc
--SELECT * from vmcr.DBO.ORTT T0 order by ratedate desc
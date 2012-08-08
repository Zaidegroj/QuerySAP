/*



*/
DECLARE @CR AS NUMERIC(19,6),
		@GT AS NUMERIC(19,6),
		@DO AS NUMERIC(19,6),
		@Hn as numeric(19,6),
		@NI as numeric(19,6),
		@fecha1 as datetime,
		@fecha2 as datetime,
		@iInDesign as int


set @iInDesign = 1

if (@iInDesign = 1)
	begin
		set @fecha1 = '03/01/2012 00:00:00'
		set @fecha2 = '03/28/2012 00:00:00'
	end
else
	begin
		/* SELECT FROM VMSV.DBO.INV1 T1 */
		SET @fecha1 = /* T1.DocDate */ '[%3]'
		SET @fecha2 = /* T1.DocDate */ '[%4]'
	end

SET @GT	=(SELECT RATE FROM PRGT.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)
SET @CR	=(SELECT RATE FROM VMCR.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)
SET @DO =(SELECT RATE FROM VMDO.DBO.ORTT T0 WHERE RATEDATE =  @fecha2)
set @Hn =(select rate from prhn.dbo.ortt T0 where ratedate = @fecha2)
set @NI = (select rate from vmni.dbo.ortt T0 where ratedate = @fecha2)

CREATE TABLE #Tmp_Totales
( NUMERO 	INT 			NULL,
PAIS     	NVARCHAR(20)		NULL,
 CLIENTES   	NUMERIC(19,6)		NULL,
 AFI	  	NUMERIC(19,6)		NULL,
 THEATRICAL	NUMERIC(19,6)		NULL,
 TOTAL		NUMERIC(19,6)		NULL,
TC NUMERIC(19,6)		NULL
)

CREATE TABLE #Tmp_Abonos
( NUMERO 	INT 			NULL,
PAIS     	NVARCHAR(20)		NULL,
 CLIENTES   	NUMERIC(19,6)		NULL,
 AFILIADAS  	NUMERIC(19,6)		NULL,
 THEATRICAL	NUMERIC(19,6)		NULL,
 TOTAL		NUMERIC(19,6)		NULL,
TC NUMERIC(19,6)		NULL
)

INSERT INTO #Tmp_Totales
SELECT  NUMERO,
	Pais   ,
    SUM( Abonos)	AS Clientes,
	SUM(AFI)	AS Afiliadas,
	SUM(THEATRICAL)	AS Theatrical,
	SUM(Abonos + AFI + THEATRICAL) AS TOTAL,
	sum(TC) AS 'Tipo Cambio'
FROM (

		/*EL SALVADOR*/
		SELECT  1 AS NUMERO,
				'El Salvador'  AS Pais,
				SUM(T0.DocTotal) AS Abonos,
				0 AS AFI,
				0 AS THEATRICAL,
				1.0 AS TC
				FROM VMSV.DBO.ORCT T0 LEFT JOIN VMSV.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
				WHERE T0.DocDate >= @fecha1
				AND T0.DocDate <= @fecha2
				AND T1.GroupCode <> 104 and t1.GroupCode <> 108
		UNION ALL
		SELECT  1 AS NUMERO,
			'El Salvador'  AS Pais,
 			0 AS Abonos,
			SUM(T0.DocTotal) AS AFI,
			0 AS THEATRICAL,
			0.0 AS TC
		FROM VMSV.DBO.ORCT T0 LEFT JOIN VMSV.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
		WHERE T0.DocDate >= @fecha1
			AND T0.DocDate <= @fecha2
			AND T1.GroupCode  = 104

		union all 

		SELECT  1 AS NUMERO,
			'El Salvador'  AS Pais,
 			0 AS Abonos,
			0 AS AFI,
			SUM(T0.DocTotal) AS THEATRICAL,
			0.0 AS TC
		FROM vmsv.DBO.ORCT T0 LEFT JOIN vmsv.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
			WHERE T0.DocDate >= @fecha1
			AND T0.DocDate <= @fecha2
			AND T1.GroupCode  = 108

		UNION ALL
		
		/*PRODICA GT*/

		SELECT  2 AS NUMERO,
			'Guatemala'  AS Pais,
			SUM(T0.DocTotal)/@GT AS Abonos,
			0 AS AFI,
			0 AS THEATRICAL,
			@GT AS TC
		FROM PRGT.DBO.ORCT T0 LEFT JOIN PRGT.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
			WHERE T0.DocDate >= @fecha1
			AND T0.DocDate <= @fecha2
			AND T1.GroupCode <> 107 AND T1.GroupCode <> 104 AND T1.GroupCode <> 108
	
		UNION ALL
		
		SELECT  2 AS NUMERO,
			'Guatemala'  AS Pais,
 			0 AS Abonos,
			SUM(T0.DocTotal)/@GT AS AFI,
			0 AS THEATRICAL,
			0.0 AS TC
		FROM PRGT.DBO.ORCT T0 LEFT JOIN PRGT.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
			WHERE T0.DocDate >= @fecha1
			AND T0.DocDate <= @fecha2
			AND T1.GroupCode  = 104

		UNION ALL

		SELECT  2 AS NUMERO,
			'Guatemala'  AS Pais,
 			0 AS Abonos,
			SUM(T0.DocTotal)/@GT AS AFI,
			0 AS THEATRICAL,
			0.0 AS TC
		FROM PRGT.DBO.ORCT T0 LEFT JOIN PRGT.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
		WHERE T0.DocDate >= @fecha1
			AND T0.DocDate <= @fecha2
			AND T1.GroupCode  = 108

		UNION ALL

		SELECT  2 AS NUMERO,
			'Guatemala'  AS Pais,
 			0 AS Abonos,
			0 AS AFI,
			SUM(T0.DocTotal)/@GT AS THEATRICAL,
			0.0 AS TC
		FROM PRGT.DBO.ORCT T0 LEFT JOIN PRGT.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
			WHERE T0.DocDate >= @fecha1
			AND T0.DocDate <= @fecha2
			AND T1.GroupCode  = 107
	
		UNION ALL
		
		/* HONDURAS */

		SELECT  3 AS NUMERO,
			'Honduras'  AS Pais,
			SUM(T0.DocTotal)/@Hn AS Abonos,
			0 AS AFI,
			0 AS THEATRICAL,
			@Hn AS TC
		FROM PRHN.DBO.ORCT T0 LEFT JOIN PRHN.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
			WHERE T0.DocDate >= @fecha1
			AND T0.DocDate <= @fecha2
			AND T1.GroupCode <> 107 AND T1.GroupCode <> 103
		
		UNION ALL
	
		SELECT 3 AS NUMERO,
			'Honduras'  AS Pais,
 			0 AS Abonos,
			SUM(T0.DocTotal)/@Hn AS AFI,
			0 AS THEATRICAL,
			0.0 AS TC
		FROM prhn.DBO.ORCT T0 LEFT JOIN prhn.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
			WHERE T0.DocDate >= @fecha1
			AND T0.DocDate <= @fecha2
			AND T1.GroupCode  = 103
	
		UNION ALL
		
		SELECT  3 AS NUMERO,
			'Honduras'  AS Pais,
 			0 AS Abonos,
			0 AS AFI,
			SUM(T0.DocTotal)/@Hn AS THEATRICAL,
			0.0 AS TC
		FROM prhn.DBO.ORCT T0 LEFT JOIN prhn.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
			WHERE T0.DocDate >= @fecha1
			AND T0.DocDate <= @fecha2
			AND T1.GroupCode  = 107

		UNION ALL 

		/* Nicaragua */

		SELECT  4 AS NUMERO,
			'Nicaragua'  AS Pais,
			SUM(T0.DocTotal)/@Hn AS Abonos,
			0 AS AFI,
			0 AS THEATRICAL,
			@Hn AS TC
		FROM vmni.DBO.ORCT T0 LEFT JOIN vmni.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
			WHERE T0.DocDate >= @fecha1
			AND T0.DocDate <= @fecha2
			AND T1.GroupCode <> 107 AND T1.GroupCode <> 103
		
		UNION ALL
	
		SELECT 4 AS NUMERO,
			'Nicaragua'  AS Pais,
 			0 AS Abonos,
			SUM(T0.DocTotal)/@Hn AS AFI,
			0 AS THEATRICAL,
			0.0 AS TC
		FROM vmni.DBO.ORCT T0 LEFT JOIN vmni.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
			WHERE T0.DocDate >= @fecha1
			AND T0.DocDate <= @fecha2
			AND T1.GroupCode  = 103
	
		UNION ALL
		
		SELECT  4 AS NUMERO,
			'Nicaragua'  AS Pais,
 			0 AS Abonos,
			0 AS AFI,
			SUM(T0.DocTotal)/@Hn AS THEATRICAL,
			0.0 AS TC
		FROM vmni.DBO.ORCT T0 LEFT JOIN vmni.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
			WHERE T0.DocDate >= @fecha1
			AND T0.DocDate <= @fecha2
			AND T1.GroupCode  = 107

		UNION ALL 

		/*COSTA RICA*/
	
		SELECT  5 AS NUMERO,
			'Costa Rica'  AS Pais,
			SUM(T0.DocTotal)/@CR AS Abonos,
			0 AS AFI,
			0 AS THEATRICAL,
			@CR AS TC
		FROM VMCR.DBO.ORCT T0 LEFT JOIN VMCR.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
			WHERE T0.DocDate >= @fecha1
			AND T0.DocDate <= @fecha2
			AND T1.GroupCode <> 107 AND T1.GroupCode <> 103
		
		UNION ALL
	
		SELECT  5 AS NUMERO,
			'Costa Rica'  AS Pais,
 			0 AS Abonos,
			SUM(T0.DocTotal)/@CR AS AFI,
			0 AS THEATRICAL,
			0.0 AS TC
		FROM VMCR.DBO.ORCT T0 LEFT JOIN VMCR.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
			WHERE T0.DocDate >= @fecha1
			AND T0.DocDate <= @fecha2
			AND T1.GroupCode  = 103
	
		UNION ALL
		
		SELECT  5 AS NUMERO,
			'Costa Rica'  AS Pais,
 			0 AS Abonos,
			0 AS AFI,
			SUM(T0.DocTotal)/@CR AS THEATRICAL,
			0.0 AS TC
		FROM VMCR.DBO.ORCT T0 LEFT JOIN VMCR.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
			WHERE T0.DocDate >= @fecha1
			AND T0.DocDate <= @fecha2
			AND T1.GroupCode  = 107

		UNION ALL
		
		/*PANAMA*/
		
		SELECT  6 AS NUMERO,
			'Panamá'  AS Pais,
			SUM(T0.DocTotal) AS Abonos,
			0 AS AFI,
			0 AS THEATRICAL,
			1.0 AS TC
		FROM VMPA.DBO.ORCT T0 LEFT JOIN VMPA.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
			WHERE T0.DocDate >= @fecha1
			AND T0.DocDate <= @fecha2
			AND T1.GroupCode <> 107 AND T1.GroupCode <> 104
		
		UNION ALL
		
		SELECT  6 AS NUMERO,
			'Panamá'  AS Pais,
 			0 AS Abonos,
			SUM(T0.DocTotal) AS AFI,
			0 AS THEATRICAL,
			0.0 AS TC
		FROM VMPA.DBO.ORCT T0 LEFT JOIN VMPA.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
			WHERE T0.DocDate >= @fecha1
			AND T0.DocDate <= @fecha2
			AND T1.GroupCode  = 104
	
		UNION ALL
	
		SELECT  6 AS NUMERO,
			'Panamá'  AS Pais,
 			0 AS Abonos,
			0 AS AFI,
			SUM(T0.DocTotal) AS THEATRICAL,
			0.0 AS TC
		FROM VMPA.DBO.ORCT T0 LEFT JOIN VMPA.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
			WHERE T0.DocDate >= @fecha1
			AND T0.DocDate <= @fecha2
			AND T1.GroupCode  = 107
		
		UNION ALL 
	
		/*DOMINICANA*/
		
		SELECT  7 AS NUMERO,
			'Dominicana'  AS Pais,
			SUM(T0.DocTotal)/@DO AS Abonos,
			0 AS AFI,
			0 AS THEATRICAL,
			@DO AS TC
		FROM VMDO.DBO.ORCT T0 LEFT JOIN VMDO.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
		WHERE T0.DocDate >= @fecha1
			AND T0.DocDate <= @fecha2
			AND T1.GroupCode <> 104

		UNION ALL
	
		SELECT  7 AS NUMERO,
			'Dominicana'  AS Pais,
 			0 AS Abonos,
			SUM(T0.DocTotal)/@DO AS AFI,
			0 AS THEATRICAL,
			0 AS TC
		FROM VMDO.DBO.ORCT T0 LEFT JOIN VMDO.DBO.OCRD T1 ON T1.CardCode = T0.CardCode
		WHERE T0.DocDate >= @fecha1
			AND T0.DocDate <= @fecha2
			AND T1.GroupCode  = 104
	
	) T0 
GROUP BY NUMERO,Pais ORDER BY NUMERO

INSERT INTO #Tmp_Abonos
SELECT * FROM #Tmp_Totales

INSERT INTO #Tmp_Abonos (PAIS) VALUES ('  ')
INSERT INTO #Tmp_Abonos
SELECT 0 AS NUMERO,'TOTAL' AS PAIS,SUM(CLIENTES),SUM(AFI),SUM(THEATRICAL),SUM(TOTAL), 0 AS TC  
FROM #Tmp_Totales

SELECT 
	PAIS,
    CLIENTES,
    AFILIADAS,
    THEATRICAL,
    TOTAL,
	TC AS 'Tipo de Cambio'
 FROM #Tmp_Abonos

DROP TABLE #Tmp_Abonos
DROP TABLE #Tmp_Totales


--select * from ocrd where GroupCode = 108
--select * from orct where CardCode in ('C15001','C15002','C15003','C15004','C15005')
select Grupo,itmsGrpNam,[Total Existencia],[Costo Total],
	case when [total Existencia]
		>0 then ([Costo Total]) / [Total Existencia] else 0 end AS CostoPromedio
from
	(
	--Individuales
	SELECT     T3.ItmsGrpCod as Grupo, T3.ItmsGrpNam, SUM(T2.Cant) AS 'Total Existencia', SUM(T2.Cant * t1.AvgPrice) AS 'Costo Total'
	FROM         OITM AS T1 INNER JOIN
                (SELECT     ItemCode, SUM(OnHand) AS Cant
                 FROM          OITW AS T0
                 WHERE      (WhsCode = '01')
                 GROUP BY ItemCode) AS T2 ON T1.ItemCode = T2.ItemCode INNER JOIN
                      OITB AS T3 ON T1.ItmsGrpCod = T3.ItmsGrpCod
	where T1.ItemCode not in (select u_Codigo from [@paquetes]) 
	GROUP BY T3.ItmsGrpCod, T3.ItmsGrpNam

	union all

	-- Paquetes 

	SELECT     T3.ItmsGrpCod as Grupo, T3.ItmsGrpNam+' '+'-PAQUETE-', SUM(T2.Cant) AS 'Total Existencia', SUM(T2.Cant * t1.AvgPrice) AS 'Costo Total'
	FROM         OITM AS T1 INNER JOIN
               (SELECT     ItemCode, SUM(OnHand) AS Cant
                FROM          OITW AS T0
                WHERE      (WhsCode = '01')
                GROUP BY ItemCode) AS T2 ON T1.ItemCode = T2.ItemCode INNER JOIN
                      OITB AS T3 ON T1.ItmsGrpCod = T3.ItmsGrpCod
	where T1.ItemCode in (select u_Codigo from [@paquetes]) 
	GROUP BY T3.ItmsGrpCod, T3.ItmsGrpNam
 ) DT
ORDER BY grupo


--SIG Inventarios 

--select * from [@paquetes] where u_nombre like 'BR%'

--SELECT * FROM OITW


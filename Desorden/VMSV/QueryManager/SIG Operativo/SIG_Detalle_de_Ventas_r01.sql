SELECT T0.Series     AS Ser,
       T0.DocNum     AS Doc,
       T0.U_FacSerie AS Ser_U,
       T0.U_FacNum   AS Doc_U,
       T0.DocType    AS Tipo,
       T0.DocDate    AS Fecha,
      (T0.DocTotal + T0.WTSum - T0.VatSum) AS 'Neto',
       T0.VatSum     AS IVA,
       T0.WTSum      AS Reten,
       T0.DocTotal   AS 'A Pagar',
       T0.Max1099    AS Total,
       ' ',
       T2.ItmsGrpCod AS Grupo,
       T3.ItmsGrpNam AS Nombre,
       T1.ItemCode   AS Codigo,
       T1.Dscription AS Descripcion,
       T1.Quantity   AS Cant,
       T1.Price      AS 'P. Unit',
       T1.LineTotal  AS 'P. Total'
  FROM      OINV T0
 INNER JOIN INV1 T1 ON T0.DocEntry   = T1.DocEntry
  LEFT JOIN OITM T2 ON T1.ItemCode   = T2.ItemCode
  LEFT JOIN OITB T3 ON T2.ItmsGrpCod = T3.ItmsGrpCod
 WHERE T0.DocDate >= [%0]
   AND T0.DocDate <= [%1]
 ORDER BY T0.Series,
          T0.DocNum
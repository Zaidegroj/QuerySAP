SELECT T4.Series     AS Ser,
       T4.DocNum     AS Doc,
       T4.U_FacSerie AS Ser_U,
       T4.U_FacNum   AS Doc_U,
       T4.DocType    AS Tipo,
       T4.DocDate    AS Fecha,
      (T4.DocTotal + T4.WTSum - T4.VatSum) AS 'Neto',
       T4.VatSum     AS IVA,
       T4.WTSum      AS Reten,
       T4.DocTotal   AS 'A Pagar',
       T4.Max1099    AS Total,
       ' ',
       T6.ItmsGrpCod AS Grupo,
       T7.ItmsGrpNam AS Nombre,
       T5.ItemCode   AS Codigo,
       T5.Dscription AS Descripcion,
       T5.Quantity   AS Cant,
       T5.Price      AS 'P. Unit',
       T5.LineTotal 'P. Total'
  FROM      ORIN T4
 INNER JOIN RIN1 T5 ON T4.DocEntry   = T5.DocEntry
  LEFT JOIN OITM T6 ON T5.ItemCode   = T6.ItemCode
  LEFT JOIN OITB T7 ON T6.ItmsGrpCod = T7.ItmsGrpCod
 WHERE T4.DocDate >= [%0]
   AND T4.DocDate <= [%1]
 ORDER BY T4.Series,
          T4.DocNum
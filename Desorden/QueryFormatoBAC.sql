DECLARE @Fecha    AS DATETIME,
		@GrupoIni AS VARCHAR(100),
		@GrupoFin AS VARCHAR(100),
		@iInDesign as int

set @iInDesign = 1

if (@iInDesign=1)
	begin
		SET @Fecha = '05/31/2011 00:00:00'
		SET @GrupoIni = 'Acreedores Exterior'
		SET @GrupoFin = 'Proveedores Locales'
	end
else
	begin
		/* SELECT FROM VMSV.DBO.OPCH T1 */
		SET @Fecha = /* T1.DocDate */ '[%0]'
		/* SELECT FROM VMSV.DBO.OCRG T2 */
		SET @GrupoIni = /* T2.GroupName */ '[%1]'
		/* SELECT FROM VMSV.DBO.OCRG T2 */
		SET @GrupoFin = /* T2.GroupName */ '[%2]'
	end


SELECT 
	   ----T0.CardCode,
		NIT as Referencia,
       Nombre as [Nombre del Proveedor],             
		rtrim(ltrim(t1.NumDoc)) as [Facturas],
       sum(Saldo)        AS Monto       ,
	   Cuenta_Banco as [Cuenta]
FROM (
		SELECT T0.CardCode,T0.CardName   AS Nombre   ,
				(T0.DocTotal   - T0.PaidToDate)              AS Saldo    ,
				T2.u_nit as nit,
				t2.u_Cuenta_Banco as cuenta_Banco
		FROM    OPCH T0
				INNER JOIN OCRD T2 ON T0.CardCode=T2.CardCode
				INNER JOIN OCRG T3 ON T3.GroupCode=T2.GroupCode
		WHERE  T0.DocDueDate                   <= @Fecha
				AND (T0.DocTotal - T0.PaidToDate) <> 0
				AND  T3.GroupName>=@GrupoIni
				AND  T3.GroupName<=@GrupoFin
		UNION ALL

		SELECT T0.CardCode,T0.CardName                                 AS Nombre   ,
				(T0.DocTotal - T0.PaidToDate)       * -1     AS Saldo    ,
				T2.u_nit AS nit,
				t2.u_Cuenta_Banco
		FROM    ORPC T0
				INNER JOIN OCRD T2 ON T0.CardCode=T2.CardCode
				INNER JOIN OCRG T3 ON T3.GroupCode=T2.GroupCode
		WHERE  T0.DocDueDate                   <= @Fecha
				AND (T0.DocTotal - T0.PaidToDate) <>  0
				AND  T0.DocStatus                  = 'O'
				AND  T0.BaseAmnt                   =  0
				AND  T3.GroupName>=@GrupoIni
				AND  T3.GroupName<=@GrupoFin
	) T0 inner join 
					(
					select CardCode,
						stuff((select ','+rtrim(ltrim(convert(char(15),docnum)))
					from (select docnum
							from opch where opch.cardcode=opchexterna.cardcode and (opch.DocTotal-opch.PaidToDate)<>0 and opch.DocDueDate<=@Fecha)a
								for xml path('')),1,1,'') NumDoc
					from opch opchexterna group by CardCode
					) T1 on T0.CardCode = T1.CardCode 

group by T0.CardCode,nit,nombre,t1.NumDoc,cuenta_banco
ORDER BY nit


--select * from opch
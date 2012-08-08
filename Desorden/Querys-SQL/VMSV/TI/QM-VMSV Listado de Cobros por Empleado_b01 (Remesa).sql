
DECLARE @FechaIni	AS DATETIME,
		@FechaFin	AS DATETIME,
		@CodIni		AS VARCHAR(100),
		@CodFin		AS VARCHAR(100),
		@iInDesign as int,
		@Tc			as numeric(18,4),
		@nIva as numeric(18,4)

set @nIva		= 0.16

set @iInDesign	= 1

if (@iInDesign = 1)
	begin
		set @FechaIni	= '01/01/2011 00:00:00'
		set @FechaFin	= '01/31/2011 00:00:00'
		set @CodIni		= 'Acreedores Exterior'
		set @CodFin		= 'Proveedores Locales'
		set @Tc			= 19.03
	end
else
	begin
		/* SELECT FROM cvsv.DBO.OINV T0 */
		SET @FechaIni= /* T0.DocDate */ '[%0]'
		/* SELECT FROM cvsv.DBO.OINV T0 */
		SET @FechaFin= /* T0.DocDate */ '[%1]'
		/* SELECT FROM cvsv.DBO.OCRG T1 */
		SET @CodIni= /* T1.GroupName */ '[%2]'
		/* SELECT FROM cvsv.DBO.OCRG T1 */
		SET @CodFin = /* T1.GroupName */ '[%3]'
	end


create table #Cobros
	(
		Grupo varchar(100),
		docdate datetime,
		cliente varchar(20),
		nombre_Cliente varchar(100),
		correlativo varchar(20),
		referencia varchar(20),
		comentarios varchar(200),
		Empleado varchar (200),
		total numeric(18,4)
	)

insert into #Cobros
		SELECT  T5.GroupName ,t8.DocDate,T1.CardCode,T1.U_FacNom,T8.DocNum,
				t8.CounterRef,t8.Comments,
				T6.SlpName,t7.U_RemesaBancaria
		FROM	cvsv.dbo.OINV AS T1 INNER JOIN
				cvsv.dbo.OCRD AS T3 ON T1.CardCode = T3.CardCode INNER JOIN
				cvsv.dbo.INV1 AS T0 ON T1.DocEntry = T0.DocEntry INNER JOIN
				cvsv.dbo.OCRG AS T5 ON T3.GroupCode = T5.GroupCode inner join 
				cvsv.dbo.oslp as T6 on T1.slpCode = t6.SlpCode INNER JOIN
				cvsv.dbo.RCT2 AS T7 ON T0.DocEntry = T7.DocEntry INNER JOIN
				cvsv.dbo.ORCT AS T8 ON T7.DocNum = T8.DocNum
		WHERE   (T5.GroupName >= @CodIni) AND (T5.GroupName <= @CodFin) and 
				(T8.DocDate >= @FechaIni) AND (T8.DocDate <= @FechaFin) and t8.canceled = 'N'

--Muestro la consulta formateada
select	grupo as [Grupo],docdate as [Fecha],cliente as [Cliente],nombre_cliente as [Nombre del Cliente],
		correlativo as [Correl],referencia as [Referencia],comentarios as [Comentarios],empleado as [Empleado],
		sum(total) as [Total]
from	#Cobros
group	by grupo,docdate,cliente,nombre_cliente,correlativo,referencia,comentarios,empleado
order	by correlativo

--select * from #Cobros

drop table #Cobros


/*
(SELECT   TOP (10000) T1.U_FacNum AS Doc_U, T8.DocDate AS Fecha_Cobro, T8.DocEntry,
					T7.U_RemesaBancaria as RemesaFactura,T7.U_ComisAgencia as ComisAgencia
			FROM   cvsv.dbo.OINV AS T1 INNER JOIN
					cvsv.dbo.INV1 AS T0 ON T1.DocEntry = T0.DocEntry INNER JOIN
					cvsv.dbo.RCT2 AS T7 ON T0.DocEntry = T7.DocEntry INNER JOIN
					cvsv.dbo.ORCT AS T8 ON T7.DocNum = T8.DocNum
			WHERE      (T8.DocDate >= @FechaIni) AND (T8.DocDate <= @FechaFin) and T8.Canceled = 'N'
				GROUP BY T1.U_FacNum, T8.DocDate, T8.DocEntry,T7.U_RemesaBancaria,T7.U_ComisAgencia) AS DT ON T1.U_FacNum = DT.Doc_U

*/
--select * from rct2 where docnum = 612


DECLARE @DateFrom AS DATETIME,
		@DateTo as datetime,
		@iInDesign as numeric,
		@CardName as varchar(150),
		@cCodigo as varchar(20)

set @iInDesign = 1

-- Tabla 
create table #SalesByCust
	(
		Codigo varchar(20) null,
		nombre varchar(150) null,
		Total numeric(18,2) null
	)

create table #CustomerList
	(
		ColList varchar(50) null 
	)


if (@iInDesign)=1
	begin
		SET @DateFrom = '2011-11-01 00:00:00'
		set @DateTo = '2011-11-30 00:00:00'
		set @CardName = 'CALLEJA, S.A DE C.V'
	end
else
	begin
		/* SELECT FROM ICSV.DBO.OINV T1 */
		SET @DateFrom = /* T1.DocDate */ '[%0]'
		set @DateTo = /* T1.DocDate */ '[%1]'
		/* select from icsv.dbo.ocrd T3 */ 
		set @CardName = /* t3.Cardname */ '[%3]'
	end

if (@CardName='')
	begin
		insert into #CustomerList
			select CardCode from ocrd where GroupCode = 108
	end
else
	begin
		insert into #CustomerList
				select CardCode from ocrd where cardname like @CardName and GroupCode = 108
	end


insert into #SalesByCust
	SELECT T0.CardCode                                 AS Cliente  ,
			--T0.CardName                                 AS Nombre   ,
			t0.u_Facnom as	Nombre,
		   --T1.SeriesName                               AS Serie    ,
		   --T0.DocNum                                   AS Documento,
		   --T0.TaxDate                                  AS Fecha    ,
		   ---T0.DocDueDate                               AS Vence    ,
		  -- @Fecha                                      AS Hasta    ,
		   T0.DocTotal                                 AS Total    
		   --T3.GroupName AS GRUPO

	FROM    OINV T0
			INNER JOIN NNM1 T1 ON T0.Series = T1.Series
			INNER JOIN OCRD T2 ON T0.CardCode=T2.CardCode
			INNER JOIN OCRG T3 ON T3.GroupCode=T2.GroupCode
	WHERE   T0.TaxDate between @DateFrom and @DateTo
			and t0.CardCode in (select ColList collate Latin1_General_CI_AI from #CustomerList ) 

	UNION ALL

	SELECT T0.CardCode                                 AS Cliente  ,
		   --T0.CardName                                 AS Nombre   ,
		   t0.u_FacNom 							   as Nombre,
		   --T1.SeriesName                               AS Serie    ,
		   --T0.DocNum                                   AS Documento,
		   --T0.TaxDate                                  AS Fecha    ,
		   --T0.DocDueDate                               AS Vence    ,
		   --@Fecha                                      AS Hasta    ,
		   T0.DocTotal                        * -1     AS Total    
	  --T3.GroupName AS GRUPO

	  FROM      ORIN T0
	 INNER JOIN NNM1 T1 ON T0.Series = T1.Series
	 INNER JOIN OCRD T2 ON T0.CardCode=T2.CardCode
	 INNER JOIN OCRG T3 ON T3.GroupCode=T2.GroupCode
	 WHERE   T0.TaxDate between @DateFrom and @Dateto
			and t0.CardCode in (select ColList collate Latin1_General_CI_AI from #CustomerList ) 


select codigo,nombre,sum(total) as VentaNeta
from #SalesByCust
where total <> 0
group by codigo,nombre 


Drop table #SalesByCust
Drop table #CustomerList


---select * from oinv where cardname like '%calleja%'
--select * from ocrd
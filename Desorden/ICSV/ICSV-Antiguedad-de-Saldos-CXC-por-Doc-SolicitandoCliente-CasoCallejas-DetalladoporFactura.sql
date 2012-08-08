
DECLARE @DateFrom AS DATETIME,
		@DateTo as datetime,
		@iInDesign as numeric,
		@CardName as varchar(200),
		@cCodigo as varchar(20),
		@sCodigo as varchar(20),
		@sCardName as varchar(200),
		@sNombre as varchar(150),
		@sDocNum as varchar(20),
		@sTipoDoc as varchar(20),
		@sFechaDoc as datetime,
		@nVentaNeta as numeric(18,4),
		@nVentaNetaAcum as numeric(18,4),
		@sVendedor as varchar(100),
		@sCodigoVendedor as varchar(20),
		@VendorList VARCHAR(max),
		@CustomerList varchar(max),
		@nTotalVentaAcumulada as numeric(18,4)

set @iInDesign = 1

set @nVentaNetaAcum = 0
set @nTotalVentaAcumulada = 0
SET @VendorList = ''
set @CustomerList = ''

-- Table declarations

create table #SalesByCust
	(
		Codigo varchar(20) null,
		TipoDoc varchar(30) null,
		docnum varchar(20) null,
		FechaDoc datetime null,
		nombre varchar(200) null,
		slpCode varchar(20) null,
		VentaNeta numeric(18,2) null
	)

create table #Temp
	(
		Codigo varchar(20) null,
		TipoDoc varchar(30) null,
		docnum varchar(20) null,
		FechaDoc datetime null,
		nombre varchar(200) null,
		slpCode varchar(20) null,
		VentaNeta numeric(18,2) null
	)

create table #VendorList
	(
		ColList varchar(50) null
	)

create table #CustomerList
	(
		ColList varchar(50) null 
	)


if (@iInDesign)=1
	begin
		SET @DateFrom = '2011-11-01 00:00:00'
		set @DateTo = '2011-11-30 00:00:00'
		set @CardName = ''
		set @sVendedor = ''
	end
else
	begin
		/* SELECT FROM ICSV.DBO.OINV T1 */
		SET @DateFrom = /* T1.DocDate */ '[%0]'
		set @DateTo = /* T1.DocDate */ '[%1]'
		/* select from icsv.dbo.ocrd T3 */ 
		set @CardName = /* t3.Cardname */ '[%3]'
		/* select from icsv.dbo.oslp t4 */
		set @sVendedor = /* t4.SlpName */ '[%4]'
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
if (@sVendedor='')
	begin
--		SELECT @VendorList = @VendorList + ''+convert(varchar(10),slpcode)+'' + ','
		--FROM oslp
		insert into #VendorList
				----SELECT LEFT(@VendorList, LEN(@VendorList) -1)
				select slpcode from oslp
	end	
else
	begin
		insert into #VendorList
				select slpcode from oslp where slpname like @sVendedor
	end

--select * from #CustomerList

insert into #Temp
	select cliente,TipoDoc,documento,fecha,nombre,slpCode,sum(total) as VentaNeta
	from 
		(
		SELECT T0.CardCode                                 AS Cliente  ,
				--T0.CardName                                 AS Nombre   ,
				t0.u_Facnom as	Nombre,
			   T1.SeriesName                               AS TipoDoc    ,
			   T0.u_Facnum                                   AS Documento,
			   T0.TaxDate                                  AS Fecha    ,
			   ---T0.DocDueDate                               AS Vence    ,
			  -- @Fecha                                      AS Hasta    ,
				t0.slpCode ,
			   T0.DocTotal                                 AS Total    
			   --T3.GroupName AS GRUPO
		FROM    OINV T0
				INNER JOIN NNM1 T1 ON T0.Series = T1.Series
				INNER JOIN OCRD T2 ON T0.CardCode=T2.CardCode
				INNER JOIN OCRG T3 ON T3.GroupCode=T2.GroupCode
		WHERE   T0.TaxDate between @DateFrom and @DateTo
				--AND (T0.DocTotal - T0.PaidToDate) <> 0
				and t2.groupcode = 108
				and t0.CardCode in (select ColList collate Latin1_General_CI_AI from #CustomerList ) 
				and t0.slpCode in (select ColList collate Latin1_General_CI_AI from #VendorList )

		UNION ALL

		SELECT T0.CardCode                                 AS Cliente  ,
			   --T0.CardName                                 AS Nombre   ,
			   t0.u_FacNom 							   as Nombre,
			   T1.SeriesName                               AS TipoDoc    ,
			   T0.u_FacNum                                   AS Documento,
			   T0.TaxDate                                  AS Fecha    ,
			   --T0.DocDueDate                               AS Vence    ,
			   --@Fecha                                      AS Hasta    ,
				t0.slpCode ,
			   T0.DocTotal                        * -1     AS Total    
		  --T3.GroupName AS GRUPO

		  FROM      ORIN T0
		 INNER JOIN NNM1 T1 ON T0.Series = T1.Series
		 INNER JOIN OCRD T2 ON T0.CardCode=T2.CardCode
		 INNER JOIN OCRG T3 ON T3.GroupCode=T2.GroupCode
		 WHERE  T0.TaxDate between @DateFrom and @DateTo
		   --AND (T0.DocTotal - T0.PaidToDate) <>  0
		   --AND  T0.DocStatus                  = 'O'
		   --AND  T0.BaseAmnt                   =  0
		   and t2.groupcode = 108
			and t0.CardCode in (select ColList collate Latin1_General_CI_AI from #CustomerList ) 
			and t0.slpCode in (select ColList collate Latin1_General_CI_AI from #VendorList )

	) Dt
	group by cliente,TipoDoc,documento,nombre,fecha,slpCode


declare tcSalesByCust cursor scroll for
		select codigo,tipodoc,docnum,fechadoc,nombre,ventaneta 
		from #Temp where ventaneta <> 0
		order by codigo,nombre,Fechadoc
		
		open tcSalesByCust
		fetch next from	tcSalesByCust into @sCodigo,@sTipoDoc,@sDocNum,@sFechaDoc,@sNombre,@nVentaNeta
		set @sCardName = @sNombre
		while @@FETCH_STATUS = 0
		begin
			if (@sNombre<>@sCardName)
				begin
					SET @sCardName = @sNombre
					insert into #SalesByCust
					select null,null,null,null,null,null,null
					insert into #SalesByCust
					select null,null,null,null,'Total Sucursal',null,@nVentaNetaAcum
					insert into #SalesByCust
					select null,null,null,null,null,null,null
					set @nVentaNetaAcum = 0
				end
			insert into #SalesbyCust (Codigo,nombre,tipoDoc,docnum,FechaDoc,VentaNeta) values (@sCodigo,@sNombre,@sTipoDoc,@sDocNum,@sFechaDoc,@nVentaNeta)
			set @nVentaNetaAcum = @nVentaNetaAcum + @nVentaNeta
			set @nTotalVentaAcumulada = @nTotalVentaAcumulada + @nVentaNeta
			fetch next from	tcSalesByCust into @sCodigo,@sTipoDoc,@sDocNum,@sFechaDoc,@sNombre,@nVentaNeta
		end

		if (@nVentaNetaAcum<>0)
			begin
					insert into #SalesByCust
					select null,null,null,null,null,null,null
					insert into #SalesByCust
					select null,null,null,null,'Total Sucursal',null,@nVentaNetaAcum
					insert into #SalesByCust
					select null,null,null,null,null,null,null
			end
			insert into #SalesByCust
			select null,null,null,null,null,null,null
			insert into #SalesByCust
					select null,null,null,null,'Total General',null,@nTotalVentaAcumulada
		

select nombre as [Sucursal],fechadoc as [Fecha Doc.],tipodoc as [Tipo],docnum as [Documento],ventaneta as [Venta Neta]
from #SalesByCust


---convert(char(10),FechaDoc,103),
Drop table #SalesByCust
Drop table #temp
drop table #CustomerList
drop table #VendorList
close tcSalesByCust
deallocate tcSalesByCust

--select * from orin where docnum = 134024

---select * from OINV where cardname like '%ANGEL ANTONIO REYES%' and month(taxdate)=11
---select convert(char(10),getdate(),103)
--select * from nnm1
--select * from oslp
--select * from ocrg
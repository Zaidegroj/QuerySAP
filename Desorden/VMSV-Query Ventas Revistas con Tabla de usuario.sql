@DateFrom AS DATETIME,
		@DateTo as datetime,
		@CardName as varchar(200),
		@iInDesign as numeric,
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
		@nTotalVentaAcumulada as numeric(18,4),
		@sPromotora as varchar(50),
		@sPromoter as varchar(30),
		@Sucursalnombre as varchar(200)

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
		Promoter varchar(50) null ,
		nombre varchar(200) null,
		slpCode varchar(20) null,
		VentaNeta numeric(18,2) null,
		SucursalNombre varchar(200) null
	)

create table #Temp
	(
		Promoter varchar(50) null,
		Codigo varchar(20) null,
		TipoDoc varchar(30) null,
		docnum varchar(20) null,
		FechaDoc datetime null,
		nombre varchar(200) null,
		slpCode varchar(20) null,
		VentaNeta numeric(18,2) null,
		Sucursalnombre varchar(200) null
	)

create table #VendorList
	(
		ColList varchar(50) null
	)

create table #CustomerList
	(
		ColList varchar(50) null 
	)

create table #PromoterList
	(
		ColList varchar(50) null
	)

set @iInDesign = 1

if (@iInDesign)=1
	begin
		SET @DateFrom = '2012-02-01 00:00:00'
		set @DateTo = '2012-02-29 00:00:00'
		set @CardName = ''
		set @sVendedor = ''
		set @sPromoter = 'N/A'
	end
else
	begin
                       /* SELECT FROM [ICSV].[DBO].[@DETALLESUCURSALES] T0 */
                       SET @sPromoter = /* T0.U_Promotora */ '[%5]'

		/* select from icsv.dbo.ocrd T3 */ 
		set @CardName = /* t3.Cardname */ '[%3]'
		/* select from icsv.dbo.oslp t4 */
		set @sVendedor = /* t4.SlpName */ '[%4]'
		/* SELECT FROM ICSV.DBO.OINV T1 */
		SET @DateFrom = /* T1.DocDate */ '[%0]'
		set @DateTo = /* T1.DocDate */ '[%1]'

	end


if (@CardName='')
	begin
		insert into #CustomerList
			select CardCode from ocrd where GroupCode = 108
			--select code from [@DetalleSucursal]
	end
else
	begin
		insert into #CustomerList
				select CardCode from ocrd where cardname like @CardName and GroupCode = 108
				--select code from [@Detallesucursal] where name like @CardName
	end
if (@sVendedor='')
	begin
		insert into #VendorList
				select slpcode from oslp
	end	
else
	begin
		insert into #VendorList
				select slpcode from oslp where slpname like @sVendedor
	end

if (@sPromoter='')
	begin
		insert into #PromoterList
				select u_promotora from [@DetalleSucursalES]
	end	
else
	begin
		insert into #PromoterList
				select u_Promotora from [@DetalleSucursalES] where u_Promotora  like @sPromoter and u_Promotora is not null
	end

--select * from #CustomerList

insert into #Temp
	select Promoter,cliente,TipoDoc,documento,fecha,nombre,slpCode,sum(total) as VentaNeta,SucursalNombre
	from 
		(
		SELECT T0.CardCode                                 AS Cliente  ,
				t2.Cardname as	Nombre,
			   T1.SeriesName                               AS TipoDoc    ,
			   T0.u_Facnum                                   AS Documento,
			   T0.TaxDate                                  AS Fecha    ,
				t0.slpCode ,
			   T0.DocTotal                                 AS Total   ,
				t4.u_Promotora as promoter ,
				t4.Name as SucursalNombre
		FROM    OINV T0
				INNER JOIN NNM1 T1 ON T0.Series = T1.Series
				INNER JOIN OCRD T2 ON T0.CardCode=T2.CardCode
				INNER JOIN OCRG T3 ON T3.GroupCode=T2.GroupCode
				left outer join [@DetalleSucursalES] t4  on t4.code = t0.u_suc_dISTRIBUIDor
		WHERE   (t4.u_Promotora in (select ColList collate Latin1_General_CI_AI from #PromoterList) )
				and T0.TaxDate between @DateFrom and @DateTo
				and t2.groupcode = 108
				and t0.CardCode in (select ColList collate Latin1_General_CI_AI from #CustomerList ) 
				and t0.slpCode in (select ColList collate Latin1_General_CI_AI from #VendorList )
				 

		UNION ALL

		SELECT T0.CardCode                                 AS Cliente  ,
			   t2.Cardname 							   as Nombre,
			   T1.SeriesName                               AS TipoDoc    ,
			   T0.u_FacNum                                   AS Documento,
			   T0.TaxDate                                  AS Fecha    ,
				t0.slpCode ,
			   T0.DocTotal                        * -1     AS Total    ,
				t4.u_promotora as promoter,
				t4.Name as sucursalNombre
		  FROM      ORIN T0
				INNER JOIN NNM1 T1 ON T0.Series = T1.Series
				INNER JOIN OCRD T2 ON T0.CardCode=T2.CardCode
				INNER JOIN OCRG T3 ON T3.GroupCode=T2.GroupCode
				inner join [@DetalleSucursalES] t4  on t4.code = t0.u_suc_distribuidor
		 WHERE  (t4.u_Promotora in (select ColList collate Latin1_General_CI_AI from #PromoterList) or t4.u_Promotora is null )
				and T0.TaxDate between @DateFrom and @DateTo
		   and t2.groupcode = 108
			and t0.CardCode in (select ColList collate Latin1_General_CI_AI from #CustomerList ) 
			and t0.slpCode in (select ColList collate Latin1_General_CI_AI from #VendorList )
			

	) Dt
	group by promoter,cliente,TipoDoc,documento,nombre,fecha,slpCode,SucursalNombre

--select * from #Temp

declare tcSalesByCust cursor scroll for
		select codigo,tipodoc,docnum,fechadoc,nombre,ventaneta ,Promoter,SucursalNombre
		from #Temp where ventaneta <> 0
		order by codigo,SucursalNombre,Fechadoc
		
		open tcSalesByCust
		fetch next from	tcSalesByCust into @sCodigo,@sTipoDoc,@sDocNum,@sFechaDoc,@sNombre,@nVentaNeta,@sPromotora,@Sucursalnombre
		set @sCardName = @SucursalNombre    --@sNombre
		while @@FETCH_STATUS = 0
		begin
			if (@SucursalNombre<>@sCardName)
				begin
					SET @sCardName = @Sucursalnombre  --@sNombre
					insert into #SalesByCust
					select null,null,null,null,null,null,null,null,null
					insert into #SalesByCust
					select null,null,null,null,null,'Total Sucursal',null,@nVentaNetaAcum,null
					insert into #SalesByCust
					select null,null,null,null,null,null,null,null,null
					set @nVentaNetaAcum = 0
				end
			insert into #SalesbyCust (Codigo,nombre,tipoDoc,docnum,FechaDoc,VentaNeta,promoter,Sucursalnombre) values (@sCodigo,@sNombre,@sTipoDoc,@sDocNum,@sFechaDoc,@nVentaNeta,@sPromotora,@Sucursalnombre)
			set @nVentaNetaAcum = @nVentaNetaAcum + @nVentaNeta
			set @nTotalVentaAcumulada = @nTotalVentaAcumulada + @nVentaNeta
			fetch next from	tcSalesByCust into @sCodigo,@sTipoDoc,@sDocNum,@sFechaDoc,@sNombre,@nVentaNeta,@sPromotora,@SucursalNombre
		end

		if (@nVentaNetaAcum<>0)
			begin
					insert into #SalesByCust
					select null,null,null,null,null,null,null,null,null
					insert into #SalesByCust
					select null,null,null,null,null,'Total Sucursal',null,@nVentaNetaAcum,null
					insert into #SalesByCust
					select null,null,null,null,null,null,null,null,null
			end
			insert into #SalesByCust
			select null,null,null,null,null,null,null,null,null
			insert into #SalesByCust
					select null,null,null,null,null,'Total General',null,@nTotalVentaAcumulada,null
		

select nombre as [Cliente],Sucursalnombre as [Sucursal],Promoter as [Promotora],fechadoc as [Fecha Doc.],
		tipodoc as [Tipo],docnum as [Documento],ventaneta as [Venta Neta]
from #SalesByCust


Drop table #SalesByCust
Drop table #temp
drop table #CustomerList
drop table #VendorList
drop table #PromoterList
close tcSalesByCust
deallocate tcSalesByCust

--select * from oinv where u_sucursal is not null

---select * from OINV where u_facnum = 10412
---select convert(char(10),getdate(),103)
--select * from nnm1
--select * from oslp
--select * from ocrg
--select * from [@DetalleSucursalES]
--select * from ocrd where CardCode = 'C30005'
--update [@DetalleSucursal] set U_Promotora = 'N/A' where u_Promotora is null
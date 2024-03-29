set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go






ALTER FUNCTION [dbo].[GetTCCountries]
(
	@DBPais varchar(6),@FechaFin datetime
)
RETURNS numeric(10,2)
AS
BEGIN
	DECLARE @Tc as  numeric(10,2)
	if (@DBPais='CVSV')
		begin
			set @Tc = 1
		END
	if (@DBPais='CVHN')
		begin
			SELECT @Tc = T0.rate from CVHN.dbo.ortt T0 where ratedate = @FechaFin
		end
	if (@DBPais='CVNI')
		begin
			select @Tc = T0.rate from CVNI.dbo.ortt T0  where ratedate = @FechaFin
		end
	if (@DBPais='CVCR')
		begin
			select @Tc = T0.rate from CVCR.dbo.ortt T0  where ratedate = @FechaFin
		end
	if (@DBPais='CVPA')
		begin
			set @Tc = 1
		end
	if (@DBPais='CVCO')
		begin
			select @Tc = T0.rate from CVCO.dbo.ortt T0 where ratedate = @FechaFin
		end
	if (@Tc is null )
		begin
			set @Tc = 1
		end
	RETURN @Tc
END






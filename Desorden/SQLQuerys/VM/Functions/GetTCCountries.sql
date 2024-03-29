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
	if (@DBPais='PRGT')
		begin
			select @Tc = T0.rate from prgt.dbo.ortt T0 where ratedate = @FechaFin
		END
	if (@DBPais='VMSV')
		begin
			SEt @Tc = 1
		end
	if (@DBPais='PRHN')
		begin
			select @Tc = T0.rate from prhn.dbo.ortt T0  where ratedate = @FechaFin
		end
	if (@DBPais='VMCR')
		begin
			select @Tc = T0.rate from vmcr.dbo.ortt T0  where ratedate = @FechaFin
		end
	if (@DBPais='VMPA')
		begin
			set @Tc = 1
		end
	if (@DBPais='VMDO')
		begin
			select @Tc = T0.rate from vmdo.dbo.ortt T0 where ratedate = @FechaFin
		end
--	if (@Tc is null )
--		begin
--			--set @Tc = 1
--		end
	RETURN @Tc
END




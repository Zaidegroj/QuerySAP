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
	if (@DBPais='EMSV')
		begin
			select @Tc = 1  --T0.rate from prgt.dbo.ortt T0 where ratedate = @FechaFin
		END
	if (@Tc is null )
		begin
			set @Tc = 1
		end
	RETURN @Tc
END




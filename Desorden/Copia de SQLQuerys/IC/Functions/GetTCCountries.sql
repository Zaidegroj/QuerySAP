set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

alter FUNCTION [dbo].[GetTCCountries]
(
	@DBPais varchar(6),@FechaFin datetime
)
RETURNS numeric(10,2)
AS
BEGIN
	DECLARE @Tc as  numeric(10,2)
	if (@DBPais='ICSV')
		begin
			SEt @Tc = 1
		end
	if (@Tc is null )
		begin
			set @Tc = 1
		end
	RETURN @Tc
END



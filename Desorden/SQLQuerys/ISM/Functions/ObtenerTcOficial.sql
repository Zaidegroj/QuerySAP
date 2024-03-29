set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER FUNCTION [dbo].[ObtenerTCOficial]
(
	@DBPais varchar(6),@FechaFin datetime
)
RETURNS numeric(10,2)
AS
BEGIN
	declare @Tc as  numeric(10,2)
	if (@DBPais='ISMCR')
		begin
			select @Tc = T0.U_TCISMCR from dbo.[@TiposCambio] T0 where U_Fecha = @FechaFin
		end
	if (@DBPais='ISMGT')
		begin
			select @Tc = T0.U_TCISMGT from dbo.[@TiposCambio] T0 where U_Fecha = @FechaFin
		end
	if (@DBPais='ISMSV')
		begin
			set @Tc = 1
		end
	RETURN @Tc
END

-- select * from [@TiposCambio]

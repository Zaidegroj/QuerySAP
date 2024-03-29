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
	if (@DBPais='CVGT')
		begin
			select @Tc = T0.U_TCCVGT from dbo.[@TiposCambio] T0 where U_Fecha = @FechaFin
		end
	if (@DBPais='CVHN')
		begin
			select @Tc = T0.U_TCCVHN from dbo.[@TiposCambio] T0 where U_Fecha = @FechaFin
		end
	if (@DBPais='CVSV')
		begin
			set @Tc = 1
		end
	if (@DBPais='CVNI')
		begin
			select @Tc = T0.U_TCCVNI from dbo.[@TiposCambio] T0  where U_Fecha = @FechaFin
		end
	if (@DBPais='CVCR')
		begin
			select @Tc = T0.U_TCCVCR from dbo.[@TiposCambio] T0  where U_Fecha = @FechaFin
		end
	if (@DBPais='CVCO')
		begin
			select @Tc = T0.U_TCCVCO from dbo.[@TiposCambio] T0 where U_Fecha = @FechaFin
		end
	if (@DBPais='CVPA')
		begin
			set @Tc = 1
		end
	RETURN @Tc
END

-- select * from [@TiposCambio]
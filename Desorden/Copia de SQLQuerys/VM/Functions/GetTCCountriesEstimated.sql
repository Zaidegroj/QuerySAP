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
	if (@DBPais='PRGT')
		begin
			select @Tc = T0.U_TCPRGT from dbo.[@TiposCambio] T0 where U_Fecha = @FechaFin
		end
	if (@DBPais='VMSV')
		begin
			set @Tc = 1
		end
	if (@DBPais='PRHN')
		begin
			select @Tc = T0.U_TCPRHN from dbo.[@TiposCambio] T0  where U_Fecha = @FechaFin
		end
	if (@DBPais='VMCR')
		begin
			select @Tc = T0.U_TCVMCR from dbo.[@TiposCambio] T0  where U_Fecha = @FechaFin
		end
	if (@DBPais='VMPA')
		begin
			set @Tc = 1
		end
	if (@DBPais='VMDO')
		begin
			select @Tc = T0.U_TCVMDO from dbo.[@TiposCambio] T0 where U_Fecha = @FechaFin
		end
	RETURN @Tc
END






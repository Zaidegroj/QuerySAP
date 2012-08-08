
declare @dDateRate as datetime

set @dDateRate = '12/31/2010 00:00:00'

select 'Tipo de Cambio' as description,
		(select rate from prgt.dbo.ortt where ratedate = @dDateRate) as gt,
		(select rate from prhn.dbo.ortt where ratedate = @dDateRate) as hn,
		(select rate from vmcr.dbo.ortt where ratedate = @dDateRate) as cr,
		(select rate from vmdo.dbo.ortt where ratedate = @dDateRate) as do,
		(select rate from vmsv.dbo.ortt where ratedate = @dDateRate) as sv


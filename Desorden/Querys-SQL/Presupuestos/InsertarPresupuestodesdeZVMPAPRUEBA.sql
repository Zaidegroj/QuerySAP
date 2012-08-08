drop table vmcr1
drop table vmcr2
select * into vmcr1 from zvmpaprueba.dbo.obgt
select * into vmcr2 from zvmpaprueba.dbo.bgt1
update vmcr1 set FinancYear = '2011-01-01' where FinancYear = '2010-01-01'

--select * from vmcr1
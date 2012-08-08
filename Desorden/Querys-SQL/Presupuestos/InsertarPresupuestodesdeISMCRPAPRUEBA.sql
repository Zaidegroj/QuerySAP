drop table ismcr1
drop table ismcr2
select * into ismcr1 from ycvpaprueba.dbo.obgt
select * into ismcr2 from ycvpaprueba.dbo.bgt1
update ismcr1 set FinancYear = '2011-01-01' where FinancYear = '2010-10-01'

drop table cvcr1
drop table cvcr2
select * into cvcr1 from ycvpaprueba.dbo.obgt
select * into cvcr2 from ycvpaprueba.dbo.bgt1
update cvcr1 set FinancYear = '2011-01-01' where FinancYear = '2010-01-01'

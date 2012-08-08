

select CardCode,
stuff((select ','+convert(char(15),docnum)
from (select docnum
from opch where opch.cardcode=opchexterna.cardcode and (opch.Doctotal-opch.PaidtoDate)<> 0)a
for xml path('')),1,1,'') NumDoc
from opch opchexterna
group by CardCode
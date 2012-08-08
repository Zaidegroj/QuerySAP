declare @FechaIni as datetime,
		@Fechafin as datetime,
		@StartDateGhost as datetime,
		@EndDateBalanceAccount as datetime,
		@iInDesign as int,
		@nSaldo	numeric(18,4),
		@SysAccount varchar(100),
		@cAccount varchar(100),
		@cAccountName varchar(150),
		@nTcGT numeric(18,2),
		@nTcHN numeric(18,2),
		@nTcNI numeric(18,2),
		@nTcCR numeric(18,2)

-- Variables to tcTransacBank cursor

declare @dDocDate as datetime,
		@sBaseRef as varchar(100),
		@sCheckNum as varchar(100),
		@sDescriptItem as varchar(150),
		@sContrAccountName as varchar(150),
		@nDebit as numeric(18,2),
		@nCredit as numeric(18,2),
		@nAccumBalance as numeric(18,4)
-- Tablas Temporales
create table #BankAccount
	(
		Account varchar(100),
		AccountName varchar(200),
		SysAccount varchar(100)
	)
create table #Result
	(
		Account varchar(100) null,
		AccountName varchar(150) null,
		DocDate	datetime null,
		NumDoc  varchar(100) null,
		CheckNum varchar(100) null,
		DescriptItem varchar(200) null,
		ContrAccountName varchar(100) null,
		Debit numeric(18,2) null,
		Credit numeric(18,2) null,
		Balance numeric(18,2) null
	)

set @iInDesign = 1
set @StartDateGhost = '04/01/1975 00:00:00'

if (@iInDesign=1)
	begin
		SET @FechaIni= '04/01/2012 00:00:00'
		SET @FechaFin= '04/30/2012 00:00:00'
	end
else
	begin
		/* SELECT FROM DBO.JDT1 T0 */
		SET @FechaIni = /* T0.RefDate */ '[%0]'
		SET @FechaFin = /* T0.RefDate */ '[%1]'
	end

set @EndDateBalanceAccount = @FechaIni - 1

-- Bank Transaction CVGT
set @nTcGT	= (select cvsv.dbo.GetTCCountries('CVGT',@FechaFin))

exec cvgt.dbo.getBankAccounts

insert into #Result (AccountName) values ('---Cinevisión Guatemala---Tipo de Cambio:'+convert(char(15),@nTcGT))
declare tcBankAccount cursor scroll for 
		select Account,AccountName,SysAccount from #BankAccount
open tcBankAccount
fetch next from tcBankAccount into @cAccount,@cAccountName,@SysAccount
while @@fetch_status = 0
	begin
		exec cvgt.dbo.ObtenerSaldoCuenta @StartDateGhost,@EndDateBalanceAccount,@cAccount,@nSaldo output
		set @nAccumBalance = @nSaldo
		--
		insert into #Result (Account,AccountName,Balance) values (@cAccount,@cAccountName,round((@nSaldo/@nTcGT),2))
		declare tcTransacBank cursor scroll for 
				SELECT	t0.refdate, T0.BaseRef,isnull(T0.Ref3Line,t0.CreatedBy), T0.LineMemo,T2.AcctName,T0.Debit, T0.Credit
				FROM	cvgt.dbo.JDT1 T0 INNER JOIN cvgt.dbo.OJDT T1 ON  T1.TransId = T0.TransId    
						LEFT OUTER JOIN cvgt.dbo.OACT T2 ON T2.AcctCode = T0.ContraAct    
						LEFT OUTER JOIN cvgt.dbo.OCRD T3  ON  T3.CardCode = T0.ContraAct
				WHERE T0.Account = @SysAccount
						AND  T0.RefDate >= @FechaIni  AND  T0.RefDate <= @FechaFin   
				ORDER BY T0.RefDate,T0.TransId,T0.Line_ID
		open tcTransacBank
		fetch next from tcTransacBank into @dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,@nDebit,@nCredit
		while @@fetch_status=0
			begin
				set @nAccumBalance = @nAccumBalance + @nDebit - @nCredit
				insert into #Result (DocDate,NumDoc,CheckNum,DescriptItem,ContrAccountName,Debit,Credit,Balance) 
							values	(@dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,Round((@nDebit/@nTcGT),2),Round((@nCredit/@nTcGT),2),Round((@nAccumBalance/@nTcGT),2))
				fetch next from tcTransacBank into @dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,@nDebit,@nCredit
			end
		--
		insert into #Result (Account) values (null)
		insert into #Result (Account) values (null)
		close tcTransacBank
		deallocate tcTransacBank
		fetch next from tcBankAccount into @cAccount,@cAccountName,@SysAccount
	end
--- End Bank Transaction CVGT
close tcBankAccount
deallocate tcBankAccount
delete from #BankAccount

-- Transac Bank CVHN
exec cvhn.dbo.getBankAccounts
set @nTcHN	= (select cvsv.dbo.GetTCCountries('CVHN',@FechaFin))
print @nTcHN
insert into #Result (AccountName) values ('---Cinevision Honduras---Tipo de Cambio:'+convert(char(15),@nTcHN))
declare tcBankAccount cursor scroll for 
		select Account,AccountName,SysAccount from #BankAccount
open tcBankAccount
fetch next from tcBankAccount into @cAccount,@cAccountName,@SysAccount
while @@fetch_status = 0
	begin
		exec cvhn.dbo.ObtenerSaldoCuenta @StartDateGhost,@EndDateBalanceAccount,@cAccount,@nSaldo output
		set @nAccumBalance = @nSaldo
		--
		insert into #Result (Account,AccountName,Balance) values (@cAccount,@cAccountName,round((@nSaldo/@nTcHN),2))
		declare tcTransacBank cursor scroll for 
				SELECT	t0.refdate, T0.BaseRef,isnull(T0.Ref3Line,t0.CreatedBy), T0.LineMemo,T2.AcctName,T0.Debit, T0.Credit
				FROM	cvhn.dbo.JDT1 T0 INNER JOIN cvhn.dbo.OJDT T1 ON  T1.TransId = T0.TransId    
						LEFT OUTER JOIN cvhn.dbo.OACT T2 ON T2.AcctCode = T0.ContraAct    
						LEFT OUTER JOIN cvhn.dbo.OCRD T3  ON  T3.CardCode = T0.ContraAct
				WHERE T0.Account = @SysAccount
						AND  T0.RefDate >= @FechaIni  AND  T0.RefDate <= @FechaFin   
				ORDER BY T0.RefDate,T0.TransId,T0.Line_ID
		open tcTransacBank
		fetch next from tcTransacBank into @dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,@nDebit,@nCredit
		while @@fetch_status=0
			begin
				set @nAccumBalance = @nAccumBalance + @nDebit - @nCredit
				insert into #Result (DocDate,NumDoc,CheckNum,DescriptItem,ContrAccountName,Debit,Credit,Balance) 
							values	(@dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,Round((@nDebit/@nTcHN),2),round((@nCredit/@nTcHN),2),round((@nAccumBalance/@nTcHN),2))
				fetch next from tcTransacBank into @dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,@nDebit,@nCredit
			end
		--
		insert into #Result (Account) values (null)
		insert into #Result (Account) values (null)
		close tcTransacBank
		deallocate tcTransacBank
		fetch next from tcBankAccount into @cAccount,@cAccountName,@SysAccount
	end
--- End Bank Transaction CVHN
delete from #BankAccount
close tcBankAccount
deallocate tcBankAccount

-- Bank Transaction CVSV
exec cvsv.dbo.getBankAccounts

insert into #Result (AccountName) values ('--Cinevision El Salvador---')
declare tcBankAccount cursor scroll for 
		select Account,AccountName,SysAccount from #BankAccount
open tcBankAccount
fetch next from tcBankAccount into @cAccount,@cAccountName,@SysAccount
while @@fetch_status = 0
	begin
		exec cvsv.dbo.ObtenerSaldoCuenta @StartDateGhost,@EndDateBalanceAccount,@cAccount,@nSaldo output
		set @nAccumBalance = @nSaldo
		--
		insert into #Result (Account,AccountName,Balance) values (@cAccount,@cAccountName,@nSaldo)
		declare tcTransacBank cursor scroll for 
				SELECT	t0.refdate, T0.BaseRef,isnull(T0.Ref3Line,t0.CreatedBy), T0.LineMemo,T2.AcctName,T0.Debit, T0.Credit
				FROM	JDT1 T0  INNER  JOIN OJDT T1  ON  T1.TransId = T0.TransId    
						LEFT OUTER JOIN OACT T2  ON  T2.AcctCode = T0.ContraAct    
						LEFT OUTER  JOIN OCRD T3  ON  T3.CardCode = T0.ContraAct
				WHERE T0.[Account] = @SysAccount
						AND  T0.RefDate >= @FechaIni  AND  T0.RefDate <= @FechaFin   
				ORDER BY T0.RefDate,T0.TransId,T0.Line_ID
		open tcTransacBank
		fetch next from tcTransacBank into @dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,@nDebit,@nCredit
		while @@fetch_status=0
			begin
				set @nAccumBalance = @nAccumBalance + @nDebit - @nCredit
				insert into #Result (DocDate,NumDoc,CheckNum,DescriptItem,ContrAccountName,Debit,Credit,Balance) 
							values	(@dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,@nDebit,@nCredit,@nAccumBalance)
				fetch next from tcTransacBank into @dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,@nDebit,@nCredit
			end
		--
		insert into #Result (Account) values (null)
		insert into #Result (Account) values (null)
		close tcTransacBank
		deallocate tcTransacBank
		fetch next from tcBankAccount into @cAccount,@cAccountName,@SysAccount
	end
close tcBankAccount
deallocate tcBankAccount
delete from #BankAccount

-- Bank Transaction CVNI
set @nTcNI	= (select cvsv.dbo.GetTCCountries('CVNI',@FechaFin))
exec cvni.dbo.getBankAccounts
insert into #Result (AccountName) values ('---Cinevision Nicaragua---Tipo de Cambio:'+convert(char(15),@nTcNI))
declare tcBankAccount cursor scroll for 
		select Account,AccountName,SysAccount from #BankAccount
open tcBankAccount
fetch next from tcBankAccount into @cAccount,@cAccountName,@SysAccount
while @@fetch_status = 0
	begin
		exec cvni.dbo.ObtenerSaldoCuenta @StartDateGhost,@EndDateBalanceAccount,@cAccount,@nSaldo output
		set @nAccumBalance = @nSaldo
		--
		insert into #Result (Account,AccountName,Balance) values (@cAccount,@cAccountName,round((@nSaldo/@nTcNI),2))
		declare tcTransacBank cursor scroll for 
				SELECT	t0.refdate, T0.BaseRef,isnull(T0.Ref3Line,t0.CreatedBy), T0.LineMemo,T2.AcctName,T0.Debit, T0.Credit
				FROM	cvni.dbo.JDT1 T0 INNER JOIN cvni.dbo.OJDT T1 ON  T1.TransId = T0.TransId    
						LEFT OUTER JOIN cvni.dbo.OACT T2 ON T2.AcctCode = T0.ContraAct    
						LEFT OUTER JOIN cvni.dbo.OCRD T3  ON  T3.CardCode = T0.ContraAct
				WHERE T0.Account = @SysAccount
						AND  T0.RefDate >= @FechaIni  AND  T0.RefDate <= @FechaFin   
				ORDER BY T0.RefDate,T0.TransId,T0.Line_ID
		open tcTransacBank
		fetch next from tcTransacBank into @dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,@nDebit,@nCredit
		while @@fetch_status=0
			begin
				set @nAccumBalance = @nAccumBalance + @nDebit - @nCredit
				insert into #Result (DocDate,NumDoc,CheckNum,DescriptItem,ContrAccountName,Debit,Credit,Balance) 
							values	(@dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,round((@nDebit/@nTcNI),2),round((@nCredit/@nTcNI),2),round((@nAccumBalance/@nTcNI),2))
				fetch next from tcTransacBank into @dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,@nDebit,@nCredit
			end
		--
		insert into #Result (Account) values (null)
		insert into #Result (Account) values (null)
		close tcTransacBank
		deallocate tcTransacBank
		fetch next from tcBankAccount into @cAccount,@cAccountName,@SysAccount
	end
--- End Bank Transaction CVNI
close tcBankAccount
deallocate tcBankAccount
delete from #BankAccount

-- Bank Transaction CVCR
set @nTcCR	= (select cvsv.dbo.GetTCCountries('CVCR',@FechaFin))
exec cvcr.dbo.getBankAccounts
insert into #Result (AccountName) values ('---Cinevision Costa Rica---Tipo de Cambio:'+convert(char(15),@nTcCR))
declare tcBankAccount cursor scroll for 
		select Account,AccountName,SysAccount from #BankAccount
open tcBankAccount
fetch next from tcBankAccount into @cAccount,@cAccountName,@SysAccount
while @@fetch_status = 0
	begin
		exec cvcr.dbo.ObtenerSaldoCuenta @StartDateGhost,@EndDateBalanceAccount,@cAccount,@nSaldo output
		set @nAccumBalance = @nSaldo
		--
		insert into #Result (Account,AccountName,Balance) values (@cAccount,@cAccountName,round((@nSaldo/@nTcCR),2))
		declare tcTransacBank cursor scroll for 
				SELECT	t0.refdate, T0.BaseRef,isnull(T0.Ref3Line,t0.CreatedBy), T0.LineMemo,T2.AcctName,T0.Debit, T0.Credit
				FROM	cvcr.dbo.JDT1 T0 INNER JOIN cvcr.dbo.OJDT T1 ON  T1.TransId = T0.TransId    
						LEFT OUTER JOIN cvcr.dbo.OACT T2 ON T2.AcctCode = T0.ContraAct    
						LEFT OUTER JOIN cvcr.dbo.OCRD T3  ON  T3.CardCode = T0.ContraAct
				WHERE T0.Account = @SysAccount
						AND  T0.RefDate >= @FechaIni  AND  T0.RefDate <= @FechaFin   
				ORDER BY T0.RefDate,T0.TransId,T0.Line_ID
		open tcTransacBank
		fetch next from tcTransacBank into @dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,@nDebit,@nCredit
		while @@fetch_status=0
			begin
				set @nAccumBalance = @nAccumBalance + @nDebit - @nCredit
				insert into #Result (DocDate,NumDoc,CheckNum,DescriptItem,ContrAccountName,Debit,Credit,Balance) 
							values	(@dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,round((@nDebit/@nTcCR),2),round((@nCredit/@nTcCR),2),round((@nAccumBalance/@nTcCR),2))
				fetch next from tcTransacBank into @dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,@nDebit,@nCredit
			end
		--
		insert into #Result (Account) values (null)
		insert into #Result (Account) values (null)
		close tcTransacBank
		deallocate tcTransacBank
		fetch next from tcBankAccount into @cAccount,@cAccountName,@SysAccount
	end

close tcBankAccount
deallocate tcBankAccount
delete from #BankAccount
-- End Bank Transaction CVCR

-- Bank Transaction CVPA
exec cvpa.dbo.getBankAccounts
insert into #Result (AccountName) values ('---Cinevision Panama---')
declare tcBankAccount cursor scroll for 
		select Account,AccountName,SysAccount from #BankAccount
open tcBankAccount
fetch next from tcBankAccount into @cAccount,@cAccountName,@SysAccount
while @@fetch_status = 0
	begin
		exec cvpa.dbo.ObtenerSaldoCuenta @StartDateGhost,@EndDateBalanceAccount,@cAccount,@nSaldo output
		set @nAccumBalance = @nSaldo
		--
		insert into #Result (Account,AccountName,Balance) values (@cAccount,@cAccountName,@nSaldo)
		declare tcTransacBank cursor scroll for 
				SELECT	t0.refdate, T0.BaseRef,isnull(T0.Ref3Line,t0.CreatedBy), T0.LineMemo,T2.AcctName,T0.Debit, T0.Credit
				FROM	cvpa.dbo.JDT1 T0 INNER JOIN cvpa.dbo.OJDT T1 ON  T1.TransId = T0.TransId    
						LEFT OUTER JOIN cvpa.dbo.OACT T2 ON T2.AcctCode = T0.ContraAct    
						LEFT OUTER JOIN cvpa.dbo.OCRD T3  ON  T3.CardCode = T0.ContraAct
				WHERE T0.Account = @SysAccount
						AND  T0.RefDate >= @FechaIni  AND  T0.RefDate <= @FechaFin   
				ORDER BY T0.RefDate,T0.TransId,T0.Line_ID
		open tcTransacBank
		fetch next from tcTransacBank into @dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,@nDebit,@nCredit
		while @@fetch_status=0
			begin
				set @nAccumBalance = @nAccumBalance + @nDebit - @nCredit
				insert into #Result (DocDate,NumDoc,CheckNum,DescriptItem,ContrAccountName,Debit,Credit,Balance) 
							values	(@dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,@nDebit,@nCredit,@nAccumBalance)
				fetch next from tcTransacBank into @dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,@nDebit,@nCredit
			end
		--
		insert into #Result (Account) values (null)
		insert into #Result (Account) values (null)
		close tcTransacBank
		deallocate tcTransacBank
		fetch next from tcBankAccount into @cAccount,@cAccountName,@SysAccount
	end
--- End Bank Transaction CVPA


close tcBankAccount
deallocate tcBankAccount

select Account,AccountName,DocDate,Numdoc,CheckNum,DescriptItem,ContrAccountName,Debit,Credit,Balance 
from #Result 
drop table #Result
drop Table #BankAccount


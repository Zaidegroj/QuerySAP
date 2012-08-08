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
		@nTcCR numeric(18,2),
		@nTcDO numeric(18,2)

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

set @iInDesign = 0
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

-- Bank Transaction PRGT
set @nTcGT	= (select vmsv.dbo.GetTCCountries('PRGT',@FechaFin))

exec prgt.dbo.getBankAccounts
insert into #Result (AccountName) values ('---VideoMark Guatemala---Tipo de Cambio:'+convert(char(15),@nTcGT))
declare tcBankAccount cursor scroll for 
		select Account,AccountName,SysAccount from #BankAccount
open tcBankAccount
fetch next from tcBankAccount into @cAccount,@cAccountName,@SysAccount
while @@fetch_status = 0
	begin
		exec prgt.dbo.ObtenerSaldoCuenta @StartDateGhost,@EndDateBalanceAccount,@cAccount,@nSaldo output
		set @nAccumBalance = @nSaldo
		--
		insert into #Result (Account,AccountName,Balance) values (@cAccount,@cAccountName,round((@nSaldo/@nTcGT),2))
		declare tcTransacBank cursor scroll for 
				SELECT	t0.refdate, T0.BaseRef,isnull(T0.Ref3Line,t0.CreatedBy), T0.LineMemo,T2.AcctName,T0.Debit, T0.Credit
				FROM	prgt.dbo.JDT1 T0 INNER JOIN prgt.dbo.OJDT T1 ON  T1.TransId = T0.TransId    
						LEFT OUTER JOIN prgt.dbo.OACT T2 ON T2.AcctCode = T0.ContraAct    
						LEFT OUTER JOIN prgt.dbo.OCRD T3  ON  T3.CardCode = T0.ContraAct
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
--- End Bank Transaction PRGT
close tcBankAccount
deallocate tcBankAccount
delete from #BankAccount

-- Transac Bank PRHN
exec prhn.dbo.getBankAccounts
set @nTcHN	= (select vmsv.dbo.GetTCCountries('PRHN',@FechaFin))
print @nTcHN
insert into #Result (AccountName) values ('---VideoMark Honduras---Tipo de Cambio:'+convert(char(15),@nTcHN))
declare tcBankAccount cursor scroll for 
		select Account,AccountName,SysAccount from #BankAccount
open tcBankAccount
fetch next from tcBankAccount into @cAccount,@cAccountName,@SysAccount
while @@fetch_status = 0
	begin
		exec prhn.dbo.ObtenerSaldoCuenta @StartDateGhost,@EndDateBalanceAccount,@cAccount,@nSaldo output
		set @nAccumBalance = @nSaldo
		--
		insert into #Result (Account,AccountName,Balance) values (@cAccount,@cAccountName,round((@nSaldo/@nTcHN),2))
		declare tcTransacBank cursor scroll for 
				SELECT	t0.refdate, T0.BaseRef,isnull(T0.Ref3Line,t0.CreatedBy), T0.LineMemo,T2.AcctName,T0.Debit, T0.Credit
				FROM	prhn.dbo.JDT1 T0 INNER JOIN prhn.dbo.OJDT T1 ON  T1.TransId = T0.TransId    
						LEFT OUTER JOIN prhn.dbo.OACT T2 ON T2.AcctCode = T0.ContraAct    
						LEFT OUTER JOIN prhn.dbo.OCRD T3  ON  T3.CardCode = T0.ContraAct
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
--- End Bank Transaction PRHN
delete from #BankAccount
close tcBankAccount
deallocate tcBankAccount

-- Bank Transaction Vmsv
exec vmsv.dbo.getBankAccounts

insert into #Result (AccountName) values ('---VideoMark El Salvador---')
declare tcBankAccount cursor scroll for 
		select Account,AccountName,SysAccount from #BankAccount
open tcBankAccount
fetch next from tcBankAccount into @cAccount,@cAccountName,@SysAccount
while @@fetch_status = 0
	begin
		exec vmsv.dbo.ObtenerSaldoCuenta @StartDateGhost,@EndDateBalanceAccount,@cAccount,@nSaldo output
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

-- Bank Transaction VMNI
set @nTcNI	= (select vmsv.dbo.GetTCCountries('VMNI',@FechaFin))
exec vmni.dbo.getBankAccounts
insert into #Result (AccountName) values ('---VideoMark Nicaragua---Tipo de Cambio:'+convert(char(15),@nTcNI))
declare tcBankAccount cursor scroll for 
		select Account,AccountName,SysAccount from #BankAccount
open tcBankAccount
fetch next from tcBankAccount into @cAccount,@cAccountName,@SysAccount
while @@fetch_status = 0
	begin
		exec vmni.dbo.ObtenerSaldoCuenta @StartDateGhost,@EndDateBalanceAccount,@cAccount,@nSaldo output
		set @nAccumBalance = @nSaldo
		--
		insert into #Result (Account,AccountName,Balance) values (@cAccount,@cAccountName,round((@nSaldo/@nTcNI),2))
		declare tcTransacBank cursor scroll for 
				SELECT	t0.refdate, T0.BaseRef,isnull(T0.Ref3Line,t0.CreatedBy), T0.LineMemo,T2.AcctName,T0.Debit, T0.Credit
				FROM	vmni.dbo.JDT1 T0 INNER JOIN vmni.dbo.OJDT T1 ON  T1.TransId = T0.TransId    
						LEFT OUTER JOIN vmni.dbo.OACT T2 ON T2.AcctCode = T0.ContraAct    
						LEFT OUTER JOIN vmni.dbo.OCRD T3  ON  T3.CardCode = T0.ContraAct
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
--- End Bank Transaction VMNI
close tcBankAccount
deallocate tcBankAccount
delete from #BankAccount

-- Bank Transaction VMCR
set @nTcCR	= (select vmsv.dbo.GetTCCountries('VMCR',@FechaFin))
exec vmcr.dbo.getBankAccounts
insert into #Result (AccountName) values ('---VideoMark Costa Rica---Tipo de Cambio:'+convert(char(15),@nTcCR))
declare tcBankAccount cursor scroll for 
		select Account,AccountName,SysAccount from #BankAccount
open tcBankAccount
fetch next from tcBankAccount into @cAccount,@cAccountName,@SysAccount
while @@fetch_status = 0
	begin
		exec vmcr.dbo.ObtenerSaldoCuenta @StartDateGhost,@EndDateBalanceAccount,@cAccount,@nSaldo output
		set @nAccumBalance = @nSaldo
		--
		insert into #Result (Account,AccountName,Balance) values (@cAccount,@cAccountName,round((@nSaldo/@nTcCR),2))
		declare tcTransacBank cursor scroll for 
				SELECT	t0.refdate, T0.BaseRef,isnull(T0.Ref3Line,t0.CreatedBy), T0.LineMemo,T2.AcctName,T0.Debit, T0.Credit
				FROM	vmcr.dbo.JDT1 T0 INNER JOIN vmcr.dbo.OJDT T1 ON  T1.TransId = T0.TransId    
						LEFT OUTER JOIN vmcr.dbo.OACT T2 ON T2.AcctCode = T0.ContraAct    
						LEFT OUTER JOIN vmcr.dbo.OCRD T3  ON  T3.CardCode = T0.ContraAct
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
-- End Bank Transaction VMCR

-- Bank Transaction VMPA
exec vmpa.dbo.getBankAccounts
insert into #Result (AccountName) values ('---VideoMark Panama---')
declare tcBankAccount cursor scroll for 
		select Account,AccountName,SysAccount from #BankAccount
open tcBankAccount
fetch next from tcBankAccount into @cAccount,@cAccountName,@SysAccount
while @@fetch_status = 0
	begin
		exec vmpa.dbo.ObtenerSaldoCuenta @StartDateGhost,@EndDateBalanceAccount,@cAccount,@nSaldo output
		set @nAccumBalance = @nSaldo
		--
		insert into #Result (Account,AccountName,Balance) values (@cAccount,@cAccountName,@nSaldo)
		declare tcTransacBank cursor scroll for 
				SELECT	t0.refdate, T0.BaseRef,isnull(T0.Ref3Line,t0.CreatedBy), T0.LineMemo,T2.AcctName,T0.Debit, T0.Credit
				FROM	vmpa.dbo.JDT1 T0 INNER JOIN vmpa.dbo.OJDT T1 ON  T1.TransId = T0.TransId    
						LEFT OUTER JOIN vmpa.dbo.OACT T2 ON T2.AcctCode = T0.ContraAct    
						LEFT OUTER JOIN vmpa.dbo.OCRD T3  ON  T3.CardCode = T0.ContraAct
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
--- End Bank Transaction VMPA
close tcBankAccount
deallocate tcBankAccount
delete from #BankAccount

-- Bank Transaction VMDO
set @nTcDO	= (select vmsv.dbo.GetTCCountries('VMDO',@FechaFin))
exec vmdo.dbo.getBankAccounts
insert into #Result (AccountName) values ('---VideoMark Dominicana---Tipo de Cambio:'+convert(char(15),@nTcDO))
declare tcBankAccount cursor scroll for 
		select Account,AccountName,SysAccount from #BankAccount
open tcBankAccount
fetch next from tcBankAccount into @cAccount,@cAccountName,@SysAccount
while @@fetch_status = 0
	begin
		exec vmdo.dbo.ObtenerSaldoCuenta @StartDateGhost,@EndDateBalanceAccount,@cAccount,@nSaldo output
		set @nAccumBalance = @nSaldo
		--
		insert into #Result (Account,AccountName,Balance) values (@cAccount,@cAccountName,round((@nSaldo/@nTcDO),2))
		declare tcTransacBank cursor scroll for 
				SELECT	t0.refdate, T0.BaseRef,isnull(T0.Ref3Line,t0.CreatedBy), T0.LineMemo,T2.AcctName,T0.Debit, T0.Credit
				FROM	vmdo.dbo.JDT1 T0 INNER JOIN vmdo.dbo.OJDT T1 ON  T1.TransId = T0.TransId    
						LEFT OUTER JOIN vmdo.dbo.OACT T2 ON T2.AcctCode = T0.ContraAct    
						LEFT OUTER JOIN vmdo.dbo.OCRD T3  ON  T3.CardCode = T0.ContraAct
				WHERE T0.Account = @SysAccount
						AND  T0.RefDate >= @FechaIni  AND  T0.RefDate <= @FechaFin   
				ORDER BY T0.RefDate,T0.TransId,T0.Line_ID
		open tcTransacBank
		fetch next from tcTransacBank into @dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,@nDebit,@nCredit
		while @@fetch_status=0
			begin
				set @nAccumBalance = @nAccumBalance + @nDebit - @nCredit
				insert into #Result (DocDate,NumDoc,CheckNum,DescriptItem,ContrAccountName,Debit,Credit,Balance) 
							values	(@dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,round((@nDebit/@nTcDO),2),round((@nCredit/@nTcDO),2),round((@nAccumBalance/@nTcDO),2))
							--values	(@dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,@nDebit,@nCredit,@nAccumBalance)
				fetch next from tcTransacBank into @dDocDate,@sBaseRef,@sCheckNum,@sDescriptItem,@sContrAccountName,@nDebit,@nCredit
			end
		--
		insert into #Result (Account) values (null)
		insert into #Result (Account) values (null)
		close tcTransacBank
		deallocate tcTransacBank
		fetch next from tcBankAccount into @cAccount,@cAccountName,@SysAccount
	end
--- End Bank Transaction VMDO
close tcBankAccount
deallocate tcBankAccount

select Account,AccountName,DocDate,Numdoc,CheckNum,DescriptItem,ContrAccountName,Debit,Credit,Balance 
from #Result 
drop table #Result
drop Table #BankAccount
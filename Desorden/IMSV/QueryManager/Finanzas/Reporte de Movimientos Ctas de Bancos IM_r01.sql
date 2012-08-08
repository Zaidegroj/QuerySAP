declare @FechaIni as datetime,
		@Fechafin as datetime,
		@StartDateGhost as datetime,
		@EndDateBalanceAccount as datetime,
		@iInDesign as int,
		@nSaldo	numeric(18,4),
		@SysAccount varchar(100),
		@cAccount varchar(100),
		@cAccountName varchar(150)

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

-- Bank Transaction IMSV
exec imsv.dbo.getBankAccounts

insert into #Result (AccountName) values ('--InterMundial El Salvador---')
declare tcBankAccount cursor scroll for 
		select Account,AccountName,SysAccount from #BankAccount
open tcBankAccount
fetch next from tcBankAccount into @cAccount,@cAccountName,@SysAccount
while @@fetch_status = 0
	begin
		exec imsv.dbo.ObtenerSaldoCuenta @StartDateGhost,@EndDateBalanceAccount,@cAccount,@nSaldo output
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

select Account,AccountName,DocDate,Numdoc,CheckNum,DescriptItem,ContrAccountName,Debit,Credit,Balance 
from #Result 
drop table #Result
drop Table #BankAccount


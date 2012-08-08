using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Data.SqlClient;
using DataAccess;
using System.Configuration;

namespace CorpReports
{
    public partial class ReportMain : Form
    {
        public ReportMain()
        {
            InitializeComponent();
        }

        private void btnReportExecute_Click(object sender, EventArgs e)
        {
            //--Query obtenido de SAP
            //--Declaración de Variables
            DBhelper objDBhelper = new DBhelper();

declare @dFechaIni	as datetime,
		@dFechaFin	as datetime,
		@nNivel		as int,
		@Tc			as numeric(18,4),
		@nInDesign	as int,
		@cCuenta	as varchar(30)

set @nInDesign = 0

if (@nInDesign = 1)
	begin
		set @dFechaIni		= '01/01/2010 00:00:00'
		set @dFechaFin		= '05/31/2010 00:00:00'
		set @nNivel			= 5
	end
else
	begin
		/* SELECT FROM DBO.JDT1 T0*/
		SET @dFechaIni = /* T0.RefDate */'[%0]'
		SET @dFechaFin = /* T0.RefDate*/'[%1]'
		/* select Levels from dbo.oact T1 */
		set @nNivel	= /* T1.Levels */'[%2]'
	end

create table #BalanceTemp
(
	Cuenta		varchar(20),
	Descripcion	varchar(100),
	CuentaPadre	varchar(20),
	Nivel		int,
	Enero		numeric(18,4),
	Febrero		numeric(18,4),
	Marzo		numeric(18,4),
	Abril		numeric(18,4),
	Mayo		numeric(18,4),
	Junio		numeric(18,4),
	Julio		numeric(18,4),
	Agosto		numeric(18,4),
	Septiembre	numeric(18,4),
	Octubre		numeric(18,4),
	Noviembre	numeric(18,4),
	Diciembre	numeric(18,4),
	Total		numeric(18,4)
)



-- Obtengo el catálogo general y lo deposito en una tabla temporal para actualizar saldos

with c
as 
(
	select AcctCode,AcctName,FatherNum,Segment_0,FormatCode,2 as Nivel
	from prgt.dbo.oact b 
	where AcctCode like '1%' or AcctCode like '2%' or AcctCode like '3%'
	union all
	select t0.AcctCode,t0.AcctName,t0.FatherNum,t0.Segment_0,t0.FormatCode,Nivel + 1 
	from (
		select b.AcctCode as AcctCode,b.AcctName,b.FatherNum,b.Segment_0,b.FormatCode from prgt.dbo.oact b where Levels=5
         ) T0 join c on t0.FatherNum = c.AcctCode
)
insert into #BalanceTemp
select isnull(c.FormatCode,c.AcctCode) as Cuenta,c.AcctName,c.FatherNum,e.Levels,0 as Enero,0 as Febrero,0 as Marzo,0 as Abril, 0 as Mayo,
		0 as Junio,0 as Julio,0 as Agosto,0 as Septiembre,0 as Octubre,0 as Noviembre,0 as Diciembre, 0 as Total
from c inner join prgt.dbo.oact e on c.FatherNum = e.AcctCode
where e.Levels < @nNivel
order by isnull(c.FormatCode,c.AcctCode)

-- Ejecuto el procedimiento almacenado para llenar el balance
exec prgt.dbo.BalanceGeneral 'PRGT',@dFechaIni,@dFechaFin,@nNivel,2


drop table #BalanceTemp
close tcBalance
deallocate tcBalance
        }

    }
}
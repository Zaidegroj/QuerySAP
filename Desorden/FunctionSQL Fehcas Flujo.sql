
DECLARE @datecol datetime,
		@nMes int,
		@WeekNum INT,
        @YearNum char(4)

set @nMes = 4
set @datecol = convert(datetime,convert(char,@nMes)+'01/'+'/2011')
print @datecol
set @WeekNum = DATEPART(WK, @datecol)
set @YearNum = CAST(DATEPART(YY, @datecol) AS CHAR(4))


SELECT DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @YearNum) + (@WeekNum-1), 6) AS StartOfWeek;
SELECT DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @YearNum) + (@WeekNum-1), 5) AS EndOfWeek;
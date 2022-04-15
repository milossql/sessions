-------------------------------------------------------------------------------------
-- Session: Transact-SQL Tips - Local Variables
-- Milos Radivojevic, Data Platform MVP, Entain, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------
USE TSQLTips;
SET NOCOUNT ON;
SET STATISTICS TIME ON;

declare @now datetime = getdate()
select * from dbo.Events e
inner join dbo.EventDetails ed ON e.Id = ed.EventId
where e.EventDate >= @now
order by e.EventDate desc

go
select * from dbo.Events e
inner join dbo.EventDetails ed ON e.Id = ed.EventId
where e.EventDate >= '20220415 12:00'
order by e.EventDate desc

--select count(*) from Events
--select 2993909*0.30
-- 898172.70


USE Statistik;
GO
SELECT * FROM B WHERE pid >= 86649 AND pid < 86749 ORDER BY c1
GO
--192 rows
/*
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'B'. Scan count 1, logical reads 795, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 77 ms.*/


DECLARE @id INT = 86649, @offset INT = 100;
SELECT * FROM B WHERE pid >= @id AND pid < @id + @offset  ORDER BY c1
GO
/*
 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
Table 'B'. Scan count 5, logical reads 4920230, physical reads 1, page server reads 0, read-ahead reads 4981729, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 26126 ms,  elapsed time = 14443 ms.*/

/*  How to deal with this?

* do not use local variables
* use OPTION (RECOMPILE)
* wrap a query in a stored procedure (local variables will become parameters)
*/


/* do not use local variables*/
USE TSQLTips;

declare @now datetime = getdate()
select * from dbo.Events e
inner join dbo.EventDetails ed ON e.Id = ed.EventId
where e.EventDate >= @now
order by e.EventDate desc
go

select * from dbo.Events e
inner join dbo.EventDetails ed ON e.Id = ed.EventId
where e.EventDate >= getdate()
order by e.EventDate desc



/* use OPTION (RECOMPILE)*/
USE TSQLTips;
declare @now datetime = getdate()
select * from dbo.Events e
inner join dbo.EventDetails ed ON e.Id = ed.EventId
where e.EventDate >= @now
order by e.EventDate desc
OPTION(RECOMPILE);
GO
USE Statistik;
GO
SELECT * FROM B WHERE pid >= 86649 AND pid < 86749 ORDER BY c1
GO
DECLARE @id INT = 86649, @offset INT = 100;
SELECT * FROM B WHERE pid >= @id AND pid < @id + @offset  ORDER BY c1
OPTION(RECOMPILE);
GO
/* wrap a query in a stored procedure (local variables will become parameters)*/
USE TSQLTips;
GO
create or alter procedure dbo.GetEvents (@date as datetime)
as
select * from dbo.Events e
inner join dbo.EventDetails ed ON e.Id = ed.EventId
where e.EventDate >= @date
order by e.EventDate desc
go


declare @now datetime = getdate()
EXEC dbo.GetEvents @now;
--do not forget to put some constraint to stop people calling the proc for date from ancient past
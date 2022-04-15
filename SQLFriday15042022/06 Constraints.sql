-------------------------------------------------------------------------------------
-- Session: Transact-SQL Tips - Constraints and Performance
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------
 --------------------------------------------------------------------
--CHECK Constraint
---------------------------------------------------------------------
USE AdventureWorks2019;
SELECT DISTINCT Status FROM Sales.SalesOrderHeader;
--Result: 5 (the status 5 is set for all orders)

--Check for rows with the status 4 or 6
SELECT * FROM Sales.SalesOrderHeader WHERE Status = 4;
SELECT * FROM Sales.SalesOrderHeader WHERE Status = 6;

--Let's create a CHECK constraint, which disallows values greather than 5 for the status column
ALTER TABLE Sales.SalesOrderHeader WITH CHECK ADD CONSTRAINT chkStatus CHECK (Status < 6);

--Check for rows with the status 4 or 6
SELECT * FROM Sales.SalesOrderHeader WHERE Status = 4;
SELECT * FROM Sales.SalesOrderHeader WHERE Status = 6;
--Result: 100% : 0% (in the first case Clustered Index Scan has been performed, for the second query 
--					the table was not touched at all!)

--Clean-Up
ALTER TABLE Sales.SalesOrderHeader DROP CONSTRAINT chkStatus;

---------------------------------------------------------------------
-- UNIQUE Constraint
---------------------------------------------------------------------
USE TSQLTips;
 
--create and populate lookup tables
DROP TABLE IF EXISTS dbo.StatusLookup;
GO
CREATE TABLE dbo.StatusLookup(id TINYINT NOT NULL, Descr	VARCHAR(10));
INSERT INTO dbo.StatusLookup VALUES(1,'open'),(2,'closed'),(3,'cancelled');
GO
 
--run query
SELECT *, 
	(SELECT descr FROM dbo.StatusLookup sl WHERE o.Status=sl.id) orderstatus
INTO #t1
FROM dbo.Orders o
WHERE id <= 1000000
GO
/*
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 1 ms.
Table 'StatusLookup'. Scan count 1000000, logical reads 1000000, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Orders'. Scan count 5, logical reads 139451, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 6 376 ms,  elapsed time = 1 606 ms.
*/

--create and populate lookup tables
DROP TABLE IF EXISTS dbo.StatusLookup2;
GO
CREATE TABLE dbo.StatusLookup2(id TINYINT NOT NULL PRIMARY KEY,Descr	VARCHAR(10));
INSERT INTO dbo.StatusLookup2 VALUES(1,'open'),(2,'closed'),(3,'cancelled');
 
--run query again
SELECT *, 
	(SELECT descr FROM dbo.StatusLookup2 sl WHERE o.Status=sl.id) orderstatus
INTO #t2
FROM dbo.Orders o
WHERE id <= 1000000;

/*
Table 'StatusLookup2'. Scan count 1, logical reads 2, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Orders'. Scan count 5, logical reads 142199, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 1092 ms,  elapsed time = 361 ms.
*/

/*Why the second query performs better?
In the firsdt query we use a lookup table without PK (or UQ) constraint, therefore, this would be possible:
INSERT INTO dbo.StatusLookup VALUES(1,'xxx');
in that case we would have two entries for the id of 1 and SQL Server would return an exception
The fact that we still do not have such value does not help for performance, SQL Server must check this and, as you can see, this can be expensive.
*/
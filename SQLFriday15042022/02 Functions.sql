-------------------------------------------------------------------------------------
-- Session: Transact-SQL Tips - Functions and arithmetic operations
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-------------------------------------------------------------------------------------
USE AdventureWorks2019;

-- Create and populate dbo.Orders
DROP TABLE IF EXISTS dbo.Orders;
SELECT * INTO dbo.Orders FROM Sales.SalesOrderHeader;
--add a PK and clustered index
ALTER TABLE dbo.Orders ADD CONSTRAINT PK_Orders PRIMARY KEY (SalesOrderID); 
GO

--get all orders from 2013, which query is faster?
SELECT * FROM dbo.Orders WHERE YEAR(OrderDate) = 2013;
SELECT * FROM dbo.Orders WHERE OrderDate >= '20130101' AND OrderDate < '20140101';
GO
/*
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.
Table 'Orders'. Scan count 1, logical reads 784, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 338 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.
Table 'Orders'. Scan count 1, logical reads 784, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 16 ms,  elapsed time = 326 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.*/

/* The table has only clustered index, the only way to get results is to perform Clusterd Index Scan, it does not matter how you write a query*/
--create index
CREATE INDEX ix1 ON dbo.Orders(OrderDate);
GO
SELECT * FROM dbo.Orders WHERE YEAR(OrderDate) = 2013;
SELECT * FROM dbo.Orders WHERE OrderDate >= '20130101' AND OrderDate < '20140101';
GO
/*SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.
Table 'Orders'. Scan count 1, logical reads 784, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 333 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.
Table 'Orders'. Scan count 1, logical reads 784, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 342 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.*/

/* The table has an index, but the query is not selective enough, again Clustered Index, it does not matter how you write a query*/

--you can enforce the index usage and see that you'll end up with significantly more logical reads
SELECT * FROM dbo.Orders WHERE OrderDate >= '20130101' AND OrderDate < '20140101';
SELECT * FROM dbo.Orders WITH (INDEX(ix1)) WHERE OrderDate >= '20130101' AND OrderDate < '20140101';
/*
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 1 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.
Table 'Orders'. Scan count 1, logical reads 784, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 31 ms,  elapsed time = 328 ms.
Table 'Orders'. Scan count 1, logical reads 43475, physical reads 0, page server reads 0, read-ahead reads 5, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 15 ms,  elapsed time = 326 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.*/

--set order date to today for one order
UPDATE dbo.Orders SET OrderDate = '20210427', DueDate= '20210428', 
	ShipDate= '20210429' 
WHERE SalesOrderID = 75123;
GO

--repeat the query for the year 2021, now the query is very selective (only one order in 2021)
SELECT * FROM dbo.Orders WHERE YEAR(OrderDate) = 2021;
SELECT * FROM dbo.Orders WHERE OrderDate >= '20210101' AND OrderDate < '20220101';
GO
/*
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 2 ms.
Table 'Orders'. Scan count 1, logical reads 76, physical reads 0, page server reads 0, read-ahead reads 64, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 2 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.
Table 'Orders'. Scan count 1, logical reads 5, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.*/

   --An example with a large table (100M rows)
USE Statistik;
SELECT * FROM A WHERE pid = 67279;
SELECT * FROM A WHERE ABS(pid) = 67279;
/*
SQL Server parse and compile time: 
   CPU time = 9 ms, elapsed time = 9 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.
Table 'A'. Scan count 1, logical reads 37, physical reads 3, page server reads 0, read-ahead reads 40, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 2 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.
Table 'A'. Scan count 5, logical reads 2121968, physical reads 1, page server reads 0, read-ahead reads 2118596, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 9873 ms,  elapsed time = 7347 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.
*/

USE AdventureWorks2019;
--a function is problematic uin the WHERE clause only if has table columns as arguments
SELECT * FROM dbo.Orders WHERE DATEADD(day, 1, OrderDate) = '20210428';
SELECT * FROM dbo.Orders WHERE OrderDate = DATEADD(day, 1, '20210426')
/*
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 2 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
Table 'Orders'. Scan count 1, logical reads 76, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 16 ms,  elapsed time = 3 ms.
Table 'Orders'. Scan count 1, logical reads 5, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.*/


--Arithmetical operations - the same issue
USE Statistik;
SELECT * FROM A WHERE id = 67279;
SELECT * FROM A WHERE id + 1 = 67280;
/*
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 1 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.
Table 'A'. Scan count 0, logical reads 4, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.
Table 'A'. Scan count 5, logical reads 175005, physical reads 1, page server reads 0, read-ahead reads 173570, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 4954 ms,  elapsed time = 1489 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.*/

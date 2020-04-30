-------------------------------------------------------------------------------------
-- Intelligent Query Processing - Table Variable Deferred Compilation
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------

IF DB_ID('TestDb') IS NULL CREATE DATABASE TestDb;
GO
USE TestDb;
GO
SET NOCOUNT ON SET STATISTICS TIME ON;
GO

ALTER DATABASE TestDb SET COMPATIBILITY_LEVEL = 140;
GO
DECLARE @t TABLE(id INT)
INSERT INTO @t SELECT n FROM dbo.GetNums(5000);
SELECT * FROM @t;
GO
/*
 SQL Server Execution Times:
   CPU time = 15 ms,  elapsed time = 25 ms.
SQL Server parse and compile time: 
   CPU time = 47 ms, elapsed time = 79 ms.

 SQL Server Execution Times:
   CPU time = 31 ms,  elapsed time = 47 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 209 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.
   */

ALTER DATABASE TestDb SET COMPATIBILITY_LEVEL = 150;
GO
DECLARE @t TABLE(id INT)
INSERT INTO @t SELECT n FROM dbo.GetNums(5000);
SELECT * FROM @t;
GO
/*
 SQL Server Execution Times:
   CPU time = 16 ms,  elapsed time = 4 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 6 ms.
SQL Server parse and compile time: 
   CPU time = 16 ms, elapsed time = 20 ms.

 SQL Server Execution Times:
   CPU time = 31 ms,  elapsed time = 30 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 2 ms.

 SQL Server Execution Times:
   CPU time = 15 ms,  elapsed time = 148 ms.
      */
--Let us try to find out what would be the estimation, if we would have a simple predicate in the WHERE clause, like in this query:

--ensure that CL is 140
ALTER DATABASE TestDb SET COMPATIBILITY_LEVEL = 140;
GO
DECLARE @t TABLE(id INT)
INSERT INTO @t SELECT 1 + ABS(CHECKSUM(NEWID())) % 100 FROM dbo.GetNums(5000);
SELECT * FROM @t WHERE id = 6;
GO
ALTER DATABASE TestDb SET COMPATIBILITY_LEVEL = 150;
GO
DECLARE @t TABLE(id INT)
INSERT INTO @t SELECT 1 + ABS(CHECKSUM(NEWID())) % 100 FROM dbo.GetNums(5000);
SELECT * FROM @t WHERE id = 6;
--Yes, this is not 1 anymore, but some other value – 70.7107. 
--This magic number is actually the square root of the table variable cardinality.

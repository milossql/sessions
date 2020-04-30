-------------------------------------------------------------------------------------
-- Intelligent Query Processing - Approximate Query Processing
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------
 
USE AdventureWorksDW2019;
GO
SET NOCOUNT ON SET STATISTICS TIME ON;
GO

SELECT COUNT(*) AS rows FROM FactProductInventory;
GO
/*
 SQL Server Execution Times:
   CPU time = 94 ms,  elapsed time = 110 ms.
*/

SELECT rows FROM sysindexes
WHERE OBJECT_NAME(id) = 'FactProductInventory' AND indid < 2;
GO
/*
 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 1 ms.
*/
SELECT rows 
FROM sys.partitions
WHERE OBJECT_NAME(object_id) = 'FactProductInventory' AND index_id < 2;
GO
/*
 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 1 ms.
*/



--------------------------------
---- APPROX_COUNT_DISTINCT
--------------------------------
USE AdventureWorksDW2019;
GO
SET STATISTICS TIME ON;
GO
SELECT COUNT(DISTINCT(UnitCost)) FROM dbo.FactProductInventory;
GO
/*
 SQL Server Execution Times:
   CPU time = 125 ms,  elapsed time = 165 ms.
 Memory Grant: 56 MB
*/
SELECT APPROX_COUNT_DISTINCT(UnitCost) FROM dbo.FactProductInventory;
 
/*
 SQL Server Execution Times:
   CPU time = 422 ms,  elapsed time = 502 ms.
  Memory Grant: 0
*/

USE Statistik;
GO
--Table A 100M rows
SELECT COUNT(DISTINCT(pid)) FROM dbo.A;
/*
 9896294 rows
 SQL Server Execution Times:
       CPU time = 15031 ms,  elapsed time = 2673 ms.
  Memory Grant: 1.8 GB
*/
GO
SELECT APPROX_COUNT_DISTINCT(pid) FROM dbo.A;
/*
 10040012 rows
 SQL Server Execution Times:
      CPU time = 10312 ms,  elapsed time = 1562 ms.
  Memory Grant: 34 MB
*/

--Discrepancy:
SELECT (10040012-9896294)*100.0/9896294; 
--1,45%

--Table B  335M rows
SELECT COUNT(DISTINCT(pid)) FROM dbo.B;
/*
 99823957 rows
 SQL Server Execution Times:
   CPU time = 157563 ms,  elapsed time = 146707 ms..
  Memory Grant: 542 MB
*/

SELECT APPROX_COUNT_DISTINCT(pid) FROM dbo.B;
/*
 98007348 rows
 SQL Server Execution Times:
   CPU time = CPU time = 62156 ms,  elapsed time = 37782 ms.
  Memory Grant: 12,3 MB
*/

--Discrepancy:
SELECT (99823957-98007348)*100.0/99823957; 
--1,82%
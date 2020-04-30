-------------------------------------------------------------------------------------
-- Intelligent Query Processing - Batch mode on rowstore
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------

USE AdventureWorksDW2019;
GO
SET NOCOUNT ON SET STATISTICS TIME ON;
GO

ALTER DATABASE AdventureWorksDW2019 SET COMPATIBILITY_LEVEL = 140;
GO
SELECT COUNT(*) FROM (SELECT DISTINCT UnitCost, UnitsIn,MovementDate FROM dbo.FactProductInventory)x;
GO
/*
 SQL Server Execution Times:
    CPU time = 1093 ms,  elapsed time = 326 ms.
  Memory Grant: 72 MB
*/
ALTER DATABASE AdventureWorksDW2019 SET COMPATIBILITY_LEVEL = 150;
GO
SELECT COUNT(*) FROM (SELECT DISTINCT UnitCost, UnitsIn,MovementDate FROM dbo.FactProductInventory)x;
GO
/*
 SQL Server Execution Times:
    CPU time = 389 ms,  elapsed time = 120 ms.
  Memory Grant: 109 MB
*/
ALTER DATABASE AdventureWorksDW2019 SET COMPATIBILITY_LEVEL = 140;
GO
SELECT COUNT(*), MAX(UnitsIn) FROM dbo.FactProductInventory;
GO
/*
 SQL Server Execution Times:
    CPU time = 218 ms,  elapsed time = 216 ms.
  Memory Grant: 0 MB
*/
ALTER DATABASE AdventureWorksDW2019 SET COMPATIBILITY_LEVEL = 150;
GO
SELECT COUNT(*), MAX(UnitsIn) FROM dbo.FactProductInventory;
GO
/*
 SQL Server Execution Times:
    CPU time = 63 ms,  elapsed time = 63 ms.
  Memory Grant: 3 MB
*/

--Batch mode works if table has at least 131.072 rows...
--row mode
SELECT COUNT(*), MAX(UnitsIn) FROM 
(SELECT TOP (131071) * FROM dbo.FactProductInventory) xxx;
GO
--batch mode
SELECT COUNT(*), MAX(UnitsIn) FROM 
(SELECT TOP (131072) * FROM dbo.FactProductInventory) xxx;
GO
 

USE WideWorldImporters;
GO
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 140;
GO
SELECT COUNT(*) FROM  Warehouse.ColdRoomTemperatures_Archive;
GO
/*
 SQL Server Execution Times:
    CPU time = 4109 ms,  elapsed time = 1371 ms.
  Memory Grant: 5 MB
*/
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 150;
GO
SELECT COUNT(*) FROM  Warehouse.ColdRoomTemperatures_Archive;
GO
/*
 SQL Server Execution Times:
    CPU time = 1469 ms,  elapsed time = 441 ms.
  Memory Grant: 17 MB
*/
 
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 140;
GO
SELECT ColdRoomSensorNumber, COUNT(*) FROM  Warehouse.ColdRoomTemperatures_Archive
GROUP BY ColdRoomSensorNumber;
GO
/*
 SQL Server Execution Times:
    CPU time = 6110 ms,  elapsed time = 2132 ms.
  Memory Grant: 9 MB
*/
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 150;
GO
SELECT ColdRoomSensorNumber, COUNT(*) FROM  Warehouse.ColdRoomTemperatures_Archive
GROUP BY ColdRoomSensorNumber;
GO
/*
 SQL Server Execution Times:
    CPU time = 2031 ms,  elapsed time = 755 ms.
  Memory Grant: 19 MB
*/

ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 140;
GO
WITH cte AS(
SELECT ColdRoomTemperatureID, ROW_NUMBER() OVER(PARTITION BY ColdRoomTemperatureID ORDER BY ColdRoomTemperatureID) rn 
FROM WarehoUSE.ColdRoomTemperatures_Archive
)
SELECT * FROM cte WHERE rn > 1;
GO

/*
 SQL Server Execution Times:
    CPU time = 9625 ms,  elapsed time = 4234 ms.
  Memory Grant: 288 MB
*/
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 150;
GO
WITH cte AS(
SELECT ColdRoomTemperatureID, ROW_NUMBER() OVER(PARTITION BY ColdRoomTemperatureID ORDER BY ColdRoomTemperatureID) rn 
FROM WarehoUSE.ColdRoomTemperatures_Archive
)
SELECT * FROM cte WHERE rn > 1;
GO
/*
 SQL Server Execution Times:
    CPU time = 2297 ms,  elapsed time = 673 ms..
  Memory Grant: 129 MB
*/

USE Statistik;
GO
ALTER DATABASE Statistik SET COMPATIBILITY_LEVEL = 140;
GO
SELECT COUNT_BIG(DISTINCT pid) FROM dbo.A;
GO
/*
 SQL Server Execution Times:
    CPU time = 50830 ms,  elapsed time = 25628 ms.
  Memory Grant: 10 MB
*/
ALTER DATABASE Statistik SET COMPATIBILITY_LEVEL = 150;
GO
SELECT COUNT_BIG(DISTINCT pid) from dbo.A;
GO
/*
 SQL Server Execution Times:
    CPU time = 19814 ms,  elapsed time = 6419 ms.
  Memory Grant: 680 MB
*/

ALTER DATABASE Statistik SET COMPATIBILITY_LEVEL = 140;
GO
SELECT COUNT_BIG(DISTINCT pid) from dbo.B;
GO
/*
 SQL Server Execution Times:
    PU time = 516250 ms,  elapsed time = 605741 ms. (10 minutes!)
  Memory Grant: 25 MB
*/

ALTER DATABASE Statistik SET COMPATIBILITY_LEVEL = 150;
GO
SELECT COUNT_BIG(DISTINCT pid) from dbo.B;
GO
/*
 SQL Server Execution Times:
    CPU time = 163406 ms,  elapsed time = 113577 ms.
  Memory Grant: 680 MB
*/

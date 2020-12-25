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
SELECT COUNT(*), MAX(UnitsIn) FROM dbo.FactProductInventory;
GO
ALTER DATABASE AdventureWorksDW2019 SET COMPATIBILITY_LEVEL = 150;
GO
SELECT COUNT(*), MAX(UnitsIn) FROM dbo.FactProductInventory;
GO


ALTER DATABASE AdventureWorksDW2019 SET COMPATIBILITY_LEVEL = 140;
GO
SELECT COUNT(*), MAX(UnitPrice) FROM dbo.FactInternetSales;
GO
ALTER DATABASE AdventureWorksDW2019 SET COMPATIBILITY_LEVEL = 150;
GO
SELECT COUNT(*), MAX(UnitPrice) FROM dbo.FactInternetSales;
GO


 
--Batch mode works if table has at least 131.072 rows...
--row mode
SELECT COUNT(*), MAX(UnitsIn) FROM 
(SELECT TOP (131071) * FROM dbo.FactProductInventory) xxx;
GO
--batch mode
SELECT COUNT(*), MAX(UnitsIn) FROM 
(SELECT TOP (131072) * FROM dbo.FactProductInventory) xxx;
GO
 

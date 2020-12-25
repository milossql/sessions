-------------------------------------------------------------------------------------
-- Intelligent Query Processing - Batch mode on rowstore
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-- Limitations
-------------------------------------------------------------------------------------

-----------------------------
-- BLOB
----------------------------
USE AdventureWorksDW2019;
ALTER DATABASE AdventureWorksDW2019 SET COMPATIBILITY_LEVEL = 150;
GO
DROP TABLE IF EXISTS dbo.FactProductInventory2
SELECT * INTO dbo.FactProductInventory2 FROM dbo.FactProductInventory;
CREATE UNIQUE CLUSTERED INDEX cl ON dbo.FactProductInventory2(ProductKey, DateKey)
SELECT COUNT(*), MAX(UnitsIn) FROM dbo.FactProductInventory2;
GO
ALTER TABLE dbo.FactProductInventory2 ADD Note NVARCHAR(MAX)
GO
SELECT COUNT(*), MAX(UnitsIn) FROM dbo.FactProductInventory2 WHERE Note IS NULL
SELECT COUNT(*), MAX(UnitsIn) FROM dbo.FactProductInventory2;
GO
-----------------------------
-- xml
----------------------------
ALTER TABLE dbo.FactProductInventory2 ADD Note2 XML
GO
SELECT COUNT(*), MAX(UnitsIn) FROM dbo.FactProductInventory2 WHERE Note2 IS NULL
SELECT COUNT(*), MAX(UnitsIn) FROM dbo.FactProductInventory2;
GO
-----------------------------
-- sparse
----------------------------

ALTER TABLE dbo.FactProductInventory2 ADD UnitsInSp INT SPARSE;
GO
UPDATE FactProductInventory2 SET UnitsInSp=UnitsIn
GO
SELECT COUNT(*), MAX(UnitsInSp) FROM dbo.FactProductInventory2 WHERE UnitsInSp >= 0
SELECT COUNT(*), MAX(UnitsIn) FROM dbo.FactProductInventory2 WHERE UnitsIn >= 0;
GO
-----------------------------
-- memory optimized tables
----------------------------
DROP TABLE IF EXISTS dbo.FactProductInventoryMem
CREATE TABLE dbo.FactProductInventoryMem(
	ProductKey int NOT NULL,
	DateKey int NOT NULL,
	MovementDate date NOT NULL,
	UnitCost money NOT NULL,
	UnitsIn int NOT NULL,
	UnitsOut int NOT NULL,
	UnitsBalance int NOT NULL,
 CONSTRAINT PK_FactProductInventoryMem PRIMARY KEY    NONCLUSTERED 
(
	ProductKey  ,
	DateKey  
))
WITH 
(MEMORY_OPTIMIZED=ON, DURABILITY=SCHEMA_ONLY)
 GO
INSERT INTO dbo.FactProductInventoryMem  
SELECT ProductKey, DateKey, MovementDate,
UnitCost, UnitsIn, UnitsOut, UnitsBalance FROM dbo.FactProductInventory;
 
SELECT COUNT(*), MAX(UnitsIn) FROM dbo.FactProductInventoryMem;


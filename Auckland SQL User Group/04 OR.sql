-------------------------------------------------------------------------------------
-- Session: Transact-SQL Tips - OR statement
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-------------------------------------------------------------------------------------
USE WideWorldImporters;
GO
SET NOCOUNT ON;
SET  STATISTICS TIME ON;
SELECT DISTINCT p.StockItemID, p.StockItemName
FROM Warehouse.StockItems  p
INNER JOIN Sales.OrderLines o ON p.StockItemID = o.StockItemID OR p.StockItemName = o.Description;
GO

SELECT DISTINCT p.StockItemID, p.StockItemName
FROM Warehouse.StockItems  p
INNER JOIN Sales.OrderLines o ON p.StockItemID = o.StockItemID 
UNION
SELECT DISTINCT p.StockItemID, p.StockItemName
FROM Warehouse.StockItems  p
INNER JOIN Sales.OrderLines o ON p.StockItemName = o.Description;
GO

USE TSQLTips;
GO
SELECT * FROM Orders WHERE Status IN (0,3);
GO
--slow!

--how to solve it?
--rewrite as UNION
SELECT * FROM Orders WHERE Status = 0
UNION ALL
SELECT * FROM Orders WHERE Status = 3;

--using HINT
SELECT * FROM Orders WHERE Status IN (0,3)
OPTION(USE HINT('QUERY_OPTIMIZER_COMPATIBILITY_LEVEL_110'))
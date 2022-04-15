-------------------------------------------------------------------------------------
-- Session: Transact-SQL Tips - OR statement
-- Milos Radivojevic, Data Platform MVP, Entain, Austria
-------------------------------------------------------------------------------------
USE WideWorldImporters;
GO
SET NOCOUNT ON;
SET  STATISTICS TIME ON;

--a slow query using OR
SELECT DISTINCT p.StockItemID, p.StockItemName
FROM Warehouse.StockItems  p
INNER JOIN Sales.OrderLines o ON p.StockItemID = o.StockItemID OR p.StockItemName = o.Description;
GO
--how to solve it?
--rewrite as UNION
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

select distinct Status from Orders;
--all rows have 1 for the status
SELECT * FROM Orders WHERE Status IN (0,3);
GO
--slow!

--how to solve it?
--rewrite as UNION
SELECT * FROM Orders WHERE Status = 0
UNION 
SELECT * FROM Orders WHERE Status = 3;

--using the QUERY_OPTIMIZER_COMPATIBILITY_LEVEL_110 HINT
SELECT * FROM Orders WHERE Status IN (0,3)
OPTION(USE HINT('QUERY_OPTIMIZER_COMPATIBILITY_LEVEL_110'))
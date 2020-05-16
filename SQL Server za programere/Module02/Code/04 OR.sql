-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 2: Writing Well-Performed Queries - OR statement
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------
USE WideWorldImporters;
GO
SELECT DISTINCT
	p.StockItemID,
	p.StockItemName
FROM Warehouse.StockItems  p
INNER JOIN Sales.OrderLines o
ON p.StockItemID = o.StockItemID OR p.StockItemName = o.Description;
GO
SELECT
	p.StockItemID,
	p.StockItemName
FROM Warehouse.StockItems  p
INNER JOIN Sales.OrderLines o
ON p.StockItemID = o.StockItemID 
UNION
SELECT
	p.StockItemID,
	p.StockItemName
FROM Warehouse.StockItems  p
INNER JOIN Sales.OrderLines o
ON p.StockItemName = o.Description;
GO

USE OSK;
SELECT * FROM tabOrders WHERE fStatusId IN (0,3);
GO
SELECT * FROM tabOrders WHERE fStatusId = 0
UNION 
SELECT * FROM tabOrders WHERE fStatusId = 3;

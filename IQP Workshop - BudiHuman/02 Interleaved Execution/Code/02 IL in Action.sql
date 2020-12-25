-------------------------------------------------------------------------------------
-- Intelligent Query Processing - Interleaved Execution
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-- Interleaved Execution in action
-------------------------------------------------------------------------------------
USE WideWorldImporters;
GO
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 110;
GO
SELECT ol.OrderID, ol.UnitPrice, ol.StockItemID 
FROM Sales.Orderlines ol
INNER JOIN dbo.SignificantOrders() f1 ON f1.Id = ol.OrderID
WHERE PackageTypeID = 7 ORDER BY ol.Quantity;
GO

ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 120;
GO
SELECT ol.OrderID, ol.UnitPrice, ol.StockItemID 
FROM Sales.Orderlines ol
INNER JOIN dbo.SignificantOrders() f1 ON f1.Id = ol.OrderID
WHERE PackageTypeID = 7 ORDER BY ol.Quantity;
GO

ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 140;
GO
SELECT ol.OrderID, ol.UnitPrice, ol.StockItemID 
FROM Sales.Orderlines ol
INNER JOIN dbo.SignificantOrders() f1 ON f1.Id = ol.OrderID
WHERE PackageTypeID = 7 ORDER BY ol.Quantity;



-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 3: Writing Well-Performed Queries - Comma Separated List of Order Ids
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------
USE WideWorldImporters;
GO
SELECT CustomerID, STRING_AGG(OrderId,',') AS OrderIds
FROM Sales.Orders 
GROUP BY CustomerID
ORDER BY CustomerID;
GO
SELECT CustomerID, STRING_AGG(OrderId,',') WITHIN GROUP (ORDER BY OrderId) AS OrderIds
FROM Sales.Orders 
GROUP BY CustomerID 
ORDER BY CustomerID;
GO
--prior to SQL Server 2017
 SELECT c.CustomerID,
  STUFF((SELECT  ',' + CAST(o.OrderId AS VARCHAR(10))   AS [text()]
   FROM Sales.Orders o
   WHERE c.CustomerID = o.CustomerID
   ORDER BY o.OrderId ASC
   FOR XML PATH('')), 1, 1, '')
FROM Sales.Customers c
ORDER BY CustomerID;
GO


-------------------------------------------------------------------------------------
-- Intelligent Query Processing - Adaptive Join
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-- Join types
-------------------------------------------------------------------------------------

USE AdventureWorks2019;
GO

--Nested Loops Join
SELECT o.SalesOrderID, c.LastName 
FROM Person.Person c
INNER JOIN Sales.SalesOrderHeader o ON o.CustomerID = c.BusinessEntityID
WHERE c.BusinessEntityID = 14501;

--Merge Join
SELECT o.SalesOrderID, o.OrderDate, o.CurrencyRateID, c.* 
FROM Person.Person c
INNER JOIN Sales.SalesOrderHeader o ON o.CustomerID = c.BusinessEntityID

--Hash Join
SELECT o.SalesOrderID, o.OrderDate, c.LastName 
FROM Person.Person c
INNER JOIN Sales.SalesOrderHeader o ON o.CustomerID = c.BusinessEntityID


 
-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 6: Common Developer Mistakes - Aliases
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------

USE WideWorldImporters;
SELECT * FROM Sales.Orders WHERE
OrderDate IN (SELECT OrderDate FROM Sales.Customers)
GO
/*
(73595 rows affected)
*/

USE WideWorldImporters
SELECT * FROM Sales.Orders WHERE
OrderDate IN (SELECT AccountOpenedDate FROM Sales.Customers c)
GO
/*
(3117 rows affected)
*/

USE WideWorldImporters
SELECT * FROM Sales.Orders o WHERE
o.OrderDate IN (SELECT c.OrderDate FROM Sales.Customers c)
GO
/*
Msg 207, Level 16, State 1, Line 13
Invalid column name 'OrderDate'.
*/
-------------------------------------------------------------------------------------
-- Intelligent Query Processing - Memory Grant Feedback
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-- Sort Operator
-------------------------------------------------------------------------------------

USE WideWorldImporters;
SELECT *
FROM Sales.Orders o
INNER JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
WHERE o.OrderID = 234;

SELECT *
FROM Sales.Orders o
INNER JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
WHERE o.OrderID = 234 ORDER BY ol.Quantity DESC
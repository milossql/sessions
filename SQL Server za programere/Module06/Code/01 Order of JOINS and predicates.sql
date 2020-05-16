-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 6: Common Developer Mistakes - Order of JOINS and predicates
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------

USE AdventureWorks2019;
-----------------------------------------------
--Order of JOINS
-----------------------------------------------
SELECT c.CustomerID, h.SalesOrderID
FROM Sales.Customer c 
LEFT JOIN Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID 
WHERE c.CustomerID IN (1, 11000);
/*
CustomerID  SalesOrderID
----------- ------------
1           NULL
11000       43793
11000       51522
11000       57418
*/



SELECT c.CustomerID, h.SalesOrderID, o.SalesOrderDetailID
FROM Sales.Customer c 
LEFT JOIN (
	Sales.SalesOrderHeader h 
	INNER JOIN Sales.SalesOrderDetail o ON h.SalesOrderID = o.SalesOrderID
)
ON c.CustomerID = h.CustomerID 
WHERE c.CustomerID IN (1, 11000);
SELECT c.CustomerID, h.SalesOrderID, o.SalesOrderDetailID
FROM Sales.Customer c 
LEFT JOIN Sales.SalesOrderHeader h 
INNER JOIN Sales.SalesOrderDetail o 
ON h.SalesOrderID = o.SalesOrderID
ON c.CustomerID = h.CustomerID 
WHERE c.CustomerID IN (1, 11000);


/*
CustomerID  SalesOrderID SalesOrderDetailID
----------- ------------ ------------------
11000       43793        449
11000       51522        38715
11000       51522        38716
11000       57418        63800
11000       57418        63801
11000       57418        63802
11000       57418        63803
11000       57418        63804
*/

SELECT c.CustomerID, h.SalesOrderID, o.SalesOrderDetailID
FROM Sales.Customer c 
LEFT JOIN Sales.SalesOrderHeader h 
INNER JOIN Sales.SalesOrderDetail o 
	ON h.SalesOrderID = o.SalesOrderID
	ON c.CustomerID = h.CustomerID 
WHERE c.CustomerID IN (1, 11000);
/*
CustomerID  SalesOrderID SalesOrderDetailID
----------- ------------ ------------------
1           NULL         NULL
11000       43793        449
11000       51522        38715
11000       51522        38716
11000       57418        63800
11000       57418        63801
11000       57418        63802
11000       57418        63803
11000       57418        63804
*/

--------------------------------------------
--OUTER JOINS - Placement of predicates
--------------------------------------------

--inner join it does not matter, where you put the filter (ON or WHERE)
SELECT c.CustomerID, h.SalesOrderID 
FROM Sales.Customer c 
INNER JOIN Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID   
WHERE c.CustomerID = 11000;

SELECT c.CustomerID, h.SalesOrderID 
FROM Sales.Customer c 
INNER JOIN Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID  
AND c.CustomerID = 11000;

--outer join, it makes difference
SELECT c.CustomerID, h.SalesOrderID 
FROM Sales.Customer c 
LEFT JOIN Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID   
WHERE c.CustomerID = 1;

SELECT c.CustomerID, h.SalesOrderID 
FROM Sales.Customer c 
LEFT JOIN Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID  
AND c.CustomerID = 1;

SELECT c.CustomerID, h.SalesOrderID 
FROM Sales.Customer c 
LEFT JOIN Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID   
WHERE c.CustomerID = 1 AND h.OrderDate > '20000101';

SELECT c.CustomerID, h.SalesOrderID 
FROM Sales.Customer c 
LEFT JOIN Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID 
AND h.OrderDate > '20000101'
WHERE c.CustomerID = 1;

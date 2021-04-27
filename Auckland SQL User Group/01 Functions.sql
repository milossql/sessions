-------------------------------------------------------------------------------------
-- Session: Transact-SQL Tips - Functions and arithmetic operations
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-------------------------------------------------------------------------------------
USE AdventureWorks2019;

-- Create and populate tables dbo.Orders
DROP TABLE IF EXISTS dbo.Orders;
SELECT * INTO dbo.Orders FROM Sales.SalesOrderHeader;
 
ALTER TABLE dbo.Orders
ADD CONSTRAINT PK_Orders PRIMARY KEY (SalesOrderID); 
GO
SELECT * FROM dbo.Orders WHERE YEAR(OrderDate) = 2013;
SELECT * FROM dbo.Orders WHERE OrderDate >= '20130101' AND OrderDate < '20140101';
GO
--create index
CREATE INDEX ix1 ON dbo.Orders(OrderDate);
GO
SELECT * FROM dbo.Orders WHERE YEAR(OrderDate) = 2013;
SELECT * FROM dbo.Orders WHERE OrderDate >= '20130101' AND OrderDate < '20140101';
GO
--test
SELECT * FROM dbo.Orders WHERE OrderDate >= '20130101' AND OrderDate < '20140101';
SELECT * FROM dbo.Orders WITH (INDEX(ix1)) WHERE OrderDate >= '20130101' AND OrderDate < '20140101';

--set order date to today for one order
UPDATE dbo.Orders SET OrderDate = '20210427', DueDate= '20210428', 
	ShipDate= '20210429' 
WHERE SalesOrderID = 75123;
GO

SELECT * FROM dbo.Orders WHERE YEAR(OrderDate) = 2021;
SELECT * FROM dbo.Orders WHERE OrderDate >= '20210101' AND OrderDate < '20220101';
GO
---------------------------------------------------------------------
--- SUBSTRING Function vs. LIKE Operator
---------------------------------------------------------------------
USE AdventureWorks2019;
GO
--Compare the queries (low selectivity)
SELECT * FROM  Person.Person WHERE SUBSTRING(LastName, 1, 1) = 'A'; 
GO
SELECT * FROM  Person.Person WHERE LastName LIKE 'A%';
--Result: 50% : 50% (Query is not selective enough)

--Compare the queries (high selectivity)
SELECT * FROM Person.Person WHERE SUBSTRING(LastName, 1, 4) = 'Atki'; 
GO
SELECT * FROM Person.Person WHERE LastName LIKE 'Atki%'; 
--Result: 92% : 8% (The second query performs better => it is SARGeable, the first query uses a function)
 

---------------------------------------------------------------------
--UPPER Function
---------------------------------------------------------------------
USE AdventureWorks2019
GO
SELECT * FROM Person.Person WHERE UPPER(LastName)='OKELBERRY';
SELECT * FROM Person.Person WHERE  LastName ='okELBeRrY';
GO

 
SELECT * FROM dbo.Orders WHERE DATEADD(day, 1, OrderDate) = '20210428';
SELECT * FROM dbo.Orders WHERE OrderDate = DATEADD(day, 1, '20210426')
GO
------------------------------------------
--- Arithmetic operators
------------------------------------------
SELECT * FROM dbo.Orders WHERE SalesOrderID = 43666 - 1;
SELECT * FROM dbo.Orders WHERE SalesOrderID + 1 = 43666;
GO

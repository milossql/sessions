-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 2: Writing Well-Performed Queries - Functions in the WHERE clause
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------

USE AdventureWorks2019
GO
-- Create and populate tables dbo.Orders
DROP TABLE IF EXISTS dbo.Orders;
GO
SELECT * INTO dbo.Orders FROM Sales.SalesOrderHeader;
 
ALTER TABLE dbo.Orders
ADD CONSTRAINT PK_Orders PRIMARY KEY (SalesOrderID); 
GO

------------------------------------------
--- Funkcije
------------------------------------------
USE AdventureWorks2019;
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
UPDATE dbo.Orders SET OrderDate = '20200413', DueDate= '20200414', 
	ShipDate= '20200415' 
WHERE SalesOrderID = 75123;

GO
SELECT * FROM dbo.Orders WHERE YEAR(OrderDate) = 2020;
SELECT * FROM dbo.Orders WHERE OrderDate >= '20200101' AND OrderDate < '20210101';

-- ili je drugi upit brzi il su isti, nikad nije prvi brzi

SELECT SalesOrderID,OrderDate FROM dbo.Orders WHERE YEAR(OrderDate) = 2013;
SELECT SalesOrderID,OrderDate FROM dbo.Orders WHERE OrderDate >= '20130101' AND OrderDate < '20140101';
GO
------------------------------------------
--- Arithmetic operators
------------------------------------------
SELECT * FROM dbo.Orders WHERE SalesOrderID = 43666 - 1;
 
SELECT * FROM dbo.Orders WHERE SalesOrderID + 1 = 43666;

GO
USE Statistik
SELECT * FROM A WHERE id = 77765;

SELECT * FROM A WHERE id + 1 = 77766;
GO

DROP TABLE IF EXISTS dbo.Orders;
GO

USE Statistik
SELECT * FROM A WHERE pid = 77765
SELECT * FROM A WHERE ABS(pid) = 77765
GO


---------------------------------------------------------------------
--SUBSTRING Function vs. LIKE Operator
---------------------------------------------------------------------
USE AdventureWorks2019;
GO
-- Create and populate dbo.Contacts
DROP TABLE IF EXISTS dbo.Contacts;
GO
SELECT BusinessEntityID, PersonType, NameStyle, Title, FirstName, MiddleName, LastName, Suffix
INTO dbo.Contacts FROM Person.Person;

ALTER TABLE dbo.Contacts
ADD CONSTRAINT PK_Contacts PRIMARY KEY (BusinessEntityID); 
GO

CREATE INDEX ix1 ON dbo.Contacts(LastName);
GO

--Compare the queries (low selectivity)
SELECT * FROM dbo.Contacts WHERE SUBSTRING(LastName, 1, 1) = 'A'; 
GO
SELECT * FROM dbo.Contacts WHERE LastName LIKE 'A%';
--Result: 50% : 50% (Query is not selective enough)

--Compare the queries (high selectivity)
SELECT * FROM dbo.Contacts WHERE SUBSTRING(LastName, 1, 4) = 'Atki'; 
GO
SELECT * FROM dbo.Contacts WHERE LastName LIKE 'Atki%'; 
--Result: 92% : 8% (The second query performs better => it is SARGeable, the first query uses a function)

--Low selectivity, but covered query
SELECT LastName,BusinessEntityID FROM dbo.Contacts WHERE SUBSTRING(LastName, 1, 1) = 'A'; 
GO
SELECT LastName,BusinessEntityID FROM dbo.Contacts WHERE LastName LIKE 'A%';
--Result: 93% : 7% 

---------------------------------------------------------------------
--UPPER Function
---------------------------------------------------------------------
USE AdventureWorks2019
GO
SELECT * FROM dbo.Contacts WHERE UPPER(LastName)='OKELBERRY';
GO
SELECT * FROM dbo.Contacts WHERE  LastName ='okELBeRrY';
GO
DROP TABLE IF EXISTS dbo.Contacts;
GO

 
CREATE OR ALTER FUNCTION dbo.DodajDan(@ulaz DATETIME)
RETURNS DATETIME 
AS 
BEGIN
    RETURN DATEADD(day, 1, @ulaz);
END;
GO

SELECT * FROM dbo.Orders WHERE OrderDate = dbo.DodajDan('20200412')

SELECT * FROM dbo.Orders WHERE dbo.DodajDan(OrderDate) = '20200414';

---------------------------------------------------------------------
--Arithmetical Operation in the WHERE clause
---------------------------------------------------------------------
USE AdventureWorks2019;
GO
SELECT * FROM dbo.Orders WHERE SalesOrderID = 43665;
SELECT * FROM dbo.Orders WHERE SalesOrderID + 1 = 43666;
SELECT * FROM dbo.Orders WHERE SalesOrderID = 43666 -1;
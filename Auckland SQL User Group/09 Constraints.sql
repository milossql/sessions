-------------------------------------------------------------------------------------
-- Session: Transact-SQL Tips - Constraints and Performance
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at

-------------------------------------------------------------------------------------

---------------------------------------------------------------------
--Constraints and Performance
---------------------------------------------------------------------

--CHECK Constraint
---------------------------------------------------------------------
USE AdventureWorks2019;
GO
SELECT DISTINCT Status FROM Sales.SalesOrderHeader;
--Result: 5 (the status 5 is set for all orders)

--Let's create a CHECK constraint, which disallows values greather than 5 for the status column
ALTER TABLE Sales.SalesOrderHeader WITH CHECK ADD CONSTRAINT chkStatus CHECK (Status <= 5);

--Check for rows with the status 4 or 6
SELECT * FROM Sales.SalesOrderHeader WHERE Status = 4;
SELECT * FROM Sales.SalesOrderHeader WHERE Status = 6;
--Result: 100% : 0% (in the first case Clustered Index Scan has been performed, for the second query 
--					the table was not touched at all!)

--Clean-Up
ALTER TABLE Sales.SalesOrderHeader DROP CONSTRAINT chkStatus;


---------------------------------------------------------------------
-- UNIQUE Constraint
---------------------------------------------------------------------

use TSQLTips
DROP TABLE IF EXISTS dbo.tabStatus;
GO

CREATE TABLE dbo.tabStatus(id TINYINT NOT NULL,	Descr VARCHAR(20));
INSERT INTO dbo.tabStatus VALUES(1,'open'),(2,'closed'),(3,'cancelled');
GO


--query
SELECT *, 
	(SELECT Descr FROM dbo.tabStatus s WHERE o.Status = s.id) orderstatus
FROM dbo.Orders o
WHERE id <= 100000
GO
DROP TABLE IF EXISTS dbo.tabStatus2;
GO
CREATE TABLE dbo.tabStatus2(id TINYINT NOT NULL PRIMARY KEY,	Descr VARCHAR(20));
INSERT INTO dbo.tabStatus2 VALUES(1,'open'),(2,'closed'),(3,'cancelled');
GO

SELECT *, 
	(SELECT Descr FROM dbo.tabStatus s WHERE o.Status = s.id) orderstatus
FROM dbo.Orders o
WHERE id <= 100000
GO
SELECT *, 
	(SELECT Descr FROM dbo.tabStatus2 s WHERE o.Status = s.id) orderstatus
FROM dbo.Orders o
WHERE id <= 100000
GO


---------------------------------
-- Foreign Key
---------------------------------
 USE AdventureWorks2019;
 GO
-- create a clone table Production.Product2 without primary key and unique constraint
DROP TABLE IF EXISTS Sales.CustomerAddress2;

-- create a clone table Production.Product2 without primary key and unique constraint
SELECT * INTO Sales.CustomerAddress2 FROM Sales.CustomerAddress;

-- 4.2 check the queries
	SELECT c.* 
	FROM Sales.Customer c
	INNER JOIN Sales.CustomerAddress ca
		ON c.CustomerID=ca.CustomerID 
	INNER JOIN  Person.Address a
		ON a.AddressID=ca.AddressID
GO
	SELECT c.* 
	FROM Sales.Customer c
	INNER JOIN Sales.CustomerAddress2 ca
		ON c.CustomerID=ca.CustomerID
	INNER JOIN  Person.Address a
		ON a.AddressID=ca.AddressID		
--RESULTS:	Query 1: 19.220 rows, 215 logical reads
--			Query 2: 19.220 rows, 243 logical reads
--			in the first plan the table Person.Address wasn't touched at all

-- 4.3 create a foreign key
ALTER TABLE Sales.CustomerAddress2 ADD FOREIGN KEY (AddressID) REFERENCES Person.Address(AddressID);

-- 4.4 check the queries
	SELECT c.* 
	FROM Sales.Customer c
	INNER JOIN Sales.CustomerAddress ca
		ON c.CustomerID=ca.CustomerID 
	INNER JOIN  Person.Address a
		ON a.AddressID=ca.AddressID
GO
	SELECT c.* 
	FROM Sales.Customer c
	INNER JOIN Sales.CustomerAddress2 ca
		ON c.CustomerID=ca.CustomerID
	INNER JOIN  Person.Address a
		ON a.AddressID=ca.AddressID		
--RESULTS:	identical results

-- clean up
DROP TABLE IF EXISTS Sales.CustomerAddress2;
GO



-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 1: DB Design Common Mistakes - Foreign Keys
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------

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



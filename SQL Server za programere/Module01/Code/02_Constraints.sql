-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 1: DB Design Common Mistakes - Constraints
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------
USE StaraSrbija;
GO
--Name constraints
DROP TABLE IF EXISTS dbo.K;
CREATE TABLE dbo.K(
id int not null,
c1 date default getdate()
)
GO
--change data type
ALTER TABLE k ALTER COLUMN c1 DATETIME;
GO
 /*
Msg 5074, Level 16, State 1, Line 121
The object 'DF__K__c1__239E4DCF' is dependent on column 'c1'.
Msg 4922, Level 16, State 9, Line 121
ALTER TABLE ALTER COLUMN c1 failed because one or more objects access this column.
*/
--you need to remove constraint first, but you need the name
ALTER TABLE k DROP CONSTRAINT DF__K__c1__239E4DCF;
ALTER TABLE k ALTER COLUMN c1 DATETIME;
ALTER TABLE k ADD CONSTRAINT DF_K_c1 DEFAULT GETDATE() FOR c1;
GO
--this won't work on another server, you have to use dynamic SQL
DECLARE @sql NVARCHAR(300)
DECLARE @cname NVARCHAR(200) = (SELECT name FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('dbo.K'))
SET @sql = CONCAT(N'ALTER TABLE k DROP CONSTRAINT ',@cname);
EXEC sp_executesql @sql;
ALTER TABLE k ALTER COLUMN c1 DATETIME;
ALTER TABLE k ADD CONSTRAINT DF_K_c1 DEFAULT GETDATE() FOR c1;
GO


--CHECK constraints and data integrity
---------------------------------------------------------------------
USE AdventureWorks2019
GO
SELECT DISTINCT Status FROM Sales.SalesOrderHeader;
--Result: 5 (the status 5 is set for all orders)

--Let's create a CHECK constraint, which disallows values greather than 5 for the status column
ALTER TABLE Sales.SalesOrderHeader WITH CHECK ADD CONSTRAINT chkStatus CHECK (Status between 3 and 5);

--Check for rows with the status 4 or 6
SELECT * FROM Sales.SalesOrderHeader WHERE Status = 4;
SELECT * FROM Sales.SalesOrderHeader WHERE Status = 6;
--Result: 100% : 0% (in the first case Clustered Index Scan has been performed, for the second query 
--					the table was not touched at all!)

--Clean-Up
ALTER TABLE Sales.SalesOrderHeader DROP CONSTRAINT chkStatus;
GO


--UNIQUE constraints

 USE AdventureWorks2019;
 GO
-- create a clone table Production.Product2 without primary key and unique constraint
DROP TABLE IF EXISTS Production.Product2;
SELECT * INTO Production.Product2 FROM Production.Product;
GO
-- 3.2 check the queries
SELECT SalesorderID, ProductID, (SELECT Name FROM Production.Product p WHERE p.ProductID=so.ProductID) PName
FROM Sales.SalesOrderDetail so
GO
SELECT SalesorderID, ProductID, (SELECT Name FROM Production.Product2 p WHERE p.ProductID=so.ProductID) PName
FROM Sales.SalesOrderDetail so
--RESULTS:	Query 1: 121.317 rows, 243 logical reads
--			Query 2: 121.317 rows, 1.801 logical reads
--			additional spool operators in the seccond plan, tempdb


-- 3.3 UNIQUE INDEX as performance friend
CREATE UNIQUE NONCLUSTERED INDEX [IX_ProductID_Unique] ON [Production].[Product2] ([ProductID] ASC)

-- 3.4 check the queries
SELECT SalesorderID, ProductID, (SELECT Name FROM Production.Product p WHERE p.ProductID=so.ProductID) PName
FROM Sales.SalesOrderDetail so
GO
SELECT SalesorderID, ProductID, (SELECT Name FROM Production.Product2 p WHERE p.ProductID=so.ProductID) PName
FROM Sales.SalesOrderDetail so
--RESULTS:	Query 1: 121.317 rows, 243 logical reads
--			Query 2: 121.317 rows, 243 logical reads
--			the same plan
-- 3.5 clean up
DROP TABLE IF EXISTS Production.Product2;
GO

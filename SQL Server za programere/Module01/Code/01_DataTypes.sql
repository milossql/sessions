-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 1: DB Design Common Mistakes -  - Data Types
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------

IF DB_ID('StaraSrbija') IS NULL CREATE DATABASE StaraSrbija;
GO
USE StaraSrbija;
GO
-- 1.1 Help function developed by Itzik Ben-Gan (http://tsql.solidq.com)
IF OBJECT_ID('dbo.GetNums', 'IF') IS NOT NULL DROP FUNCTION dbo.GetNums;
GO
CREATE FUNCTION dbo.GetNums(@n AS BIGINT) RETURNS TABLE
AS
RETURN
  WITH
  L0   AS(SELECT 1 AS c UNION ALL SELECT 1),
  L1   AS(SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
  L2   AS(SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
  L3   AS(SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
  L4   AS(SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
  L5   AS(SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
  Nums AS(SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n FROM L5)
  SELECT n FROM Nums WHERE n <= @n;
GO
--create and populate sample table 1
DROP TABLE IF EXISTS dbo.StudentExams1;
CREATE TABLE dbo.StudentExams1(
	exam_number int NOT NULL,
	student_id int NOT NULL,
	exam_id int NOT NULL,
	exam_note int NULL,
	exam_date datetime  NULL,
 CONSTRAINT PK_StudentExams1 PRIMARY KEY CLUSTERED (exam_number ASC)
)
GO
DECLARE @date_from DATETIME = '20000101';
DECLARE @date_to DATETIME = '20171231';
DECLARE @number_of_rows INT = 1000000;
INSERT INTO dbo.StudentExams1
SELECT n AS exam_number,
    1 + ABS(CHECKSUM(NEWID())) % 50000 AS student_id,
    1 + ABS(CHECKSUM(NEWID())) % 40 AS exam_id,
    5 + ABS(CHECKSUM(NEWID())) % 6 AS exam_note,
(SELECT(@date_from +(ABS(CAST(CAST( NewID() AS BINARY(8) )AS INT))%CAST((@date_to - @date_from)AS INT)))) exam_date
FROM dbo.GetNums(@number_of_rows)
GO
--create and populate sample table 2
DROP TABLE IF EXISTS dbo.StudentExams2;
CREATE TABLE dbo.StudentExams2(
	exam_number int NOT NULL,
	student_id int NOT NULL,
	exam_id int NOT NULL,
	exam_note TINYINT NULL,
	exam_date DATE NULL,
 CONSTRAINT PK_StudentExams2 PRIMARY KEY CLUSTERED (exam_number ASC)
)
GO
DECLARE @date_from DATETIME = '20000101';
DECLARE @date_to DATETIME = '20171231';
DECLARE @number_of_rows INT = 1000000;
INSERT INTO dbo.StudentExams2
SELECT n AS exam_number,
    1 + ABS(CHECKSUM(NEWID())) % 50000 AS student_id,
    1 + ABS(CHECKSUM(NEWID())) % 40 AS exam_id,
    5 + ABS(CHECKSUM(NEWID())) % 6 AS exam_note,
(SELECT(@date_from +(ABS(CAST(CAST( NewID() AS BINARY(8) )AS INT))%CAST((@date_to - @date_from)AS INT)))) exam_date
FROM dbo.GetNums(@number_of_rows)
GO

--Check the table size
SELECT  OBJECT_NAME(s.object_id) AS table_name, CAST((s.used_page_count/128.0) AS int) table_size_MB
FROM sys.dm_db_partition_stats AS s 
INNER JOIN sys.indexes AS i
	ON s.[object_id] = i.[object_id] AND s.index_id = i.index_id
INNER JOIN sys.tables AS t
	ON s.[object_id] = t.[object_id] 
WHERE s.object_id IN ( OBJECT_ID('dbo.StudentExams1'), OBJECT_ID('dbo.StudentExams2')) AND s.index_id < 2;
/*
table_name                              table_size_MB
--------------------------------------- -------------
StudentExams1                           32
StudentExams2                           24
*/

--Check the data page number 
SELECT OBJECT_NAME(p.object_id) AS table_name, data_pages
FROM sys.allocation_units AS a
INNER JOIN	sys.partitions	AS p
  ON a.container_id = p.partition_id
WHERE p.object_id IN ( OBJECT_ID('dbo.StudentExams1'), OBJECT_ID('dbo.StudentExams2')) 
GO
/*
table_name                      data_pages
------------------------------- --------------------
StudentExams1                   4082
StudentExams2                   3096
*/
SET NOCOUNT ON;
SET STATISTICS IO ON;

SELECT * FROM dbo.StudentExams1 WHERE exam_note = 4;
SELECT * FROM dbo.StudentExams2 WHERE exam_note = 4;
/*
Table 'StudentExams1'. Scan count 1, logical reads 4098, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'StudentExams2'. Scan count 1, logical reads 3107, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
*/

---------------------------------------------------------------------------------
-- Constraints
---------------------------------------------------------------------------------

--Name constraints
USE StaraSrbija;
GO
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
ALTER TABLE k DROP CONSTRAINT DF_K_c1;
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

-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 2: Writing Well-Performed Queries - Constraints and Performance
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
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
USE OSK;

DROP TABLE IF EXISTS dbo.tabStatus;
GO

CREATE TABLE dbo.tabStatus(id TINYINT NOT NULL,	Descr VARCHAR(20));
INSERT INTO dbo.tabStatus VALUES(1,'open'),(2,'closed'),(3,'cancelled');
GO
ALTER TABLE tabOrders ADD fStatusId TINYINT;
GO
 
;WITH cte AS(
SELECT  fId,
fStatusId,
1 + ABS(CHECKSUM(NEWID())) % 3 AS fStatus
FROM dbo.tabOrders
)
UPDATE cte SET fStatusId = fStatus;
GO

--query
SELECT *, 
	(SELECT Descr FROM dbo.tabStatus s WHERE o.fStatusId = s.id) orderstatus
FROM dbo.tabOrders o
WHERE fId <= 100000
GO

 
--INSERT INTO dbo.tabStatus2 VALUES(2,'xxx')
DROP TABLE IF EXISTS dbo.tabStatus2;
GO
CREATE TABLE dbo.tabStatus2(id TINYINT NOT NULL PRIMARY KEY,	Descr VARCHAR(20));
INSERT INTO dbo.tabStatus2 VALUES(1,'open'),(2,'closed'),(3,'cancelled');
GO
SELECT *, 
	(SELECT Descr FROM dbo.tabStatus2 s WHERE o.fStatusId = s.id) orderstatus
FROM dbo.tabOrders o
WHERE fId <= 100000
GO
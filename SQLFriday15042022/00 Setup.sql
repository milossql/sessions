-------------------------------------------------------------------------------------
-- Session: Transact-SQL Tips - Setup
-- Milos Radivojevic, Data Platform MVP, Entain, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------

/*
* creating a sample database
* creating sample tables and indexes
* populating the tables
*/

IF DB_ID('TSQLTips') IS NULL CREATE DATABASE TSQLTips;
GO
USE TSQLTips;
GO
-------------------------------------------------
--- Events
--------------------------------------------------
IF OBJECT_ID('dbo.Events', 'U') IS NOT NULL DROP TABLE dbo.Events;
CREATE TABLE dbo.Events(
Id INT NOT NULL,
OrganizerId INT NOT NULL,
EventDate DATETIME NOT NULL,
EventLocation INT NOT NULL,
Price INT NOT NULL,
Other CHAR(500) NOT NULL DEFAULT 'test',
CONSTRAINT PK_Events PRIMARY KEY CLUSTERED (Id ASC)
);
GO
CREATE INDEX ix1 ON dbo.Events(EventDate)
GO
 
-- Help function developed by Itzik Ben-Gan (http://tsql.solidq.com)
CREATE OR ALTER FUNCTION dbo.GetNums(@n AS BIGINT) RETURNS TABLE
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

 --populate the table
INSERT INTO dbo.Events(id,OrganizerId,EventDate,EventLocation, Price)
SELECT n AS id, 
 1 + ABS(CHECKSUM(NEWID())) % 10000 AS OrganizerId,
 --random date from 1.1.2010 until 30.04.2022
 dateadd(minute, ABS(CHECKSUM(NEWID())) % 6482880, '20100101') EventDate ,
  1 + ABS(CHECKSUM(NEWID())) % 10000 AS EventLocation,
  10 + ABS(CHECKSUM(NEWID())) % 5000 AS Price 
FROM dbo.GetNums(3000000)
GO

IF OBJECT_ID('dbo.EventDetails', 'U') IS NOT NULL DROP TABLE dbo.EventDetails;
CREATE TABLE dbo.EventDetails(
ID INT NOT NULL,
EventId INT NOT NULL,
ItemId TINYINT NOT NULL,
Other CHAR(500) NOT NULL DEFAULT 'test',
CONSTRAINT PK_EventDetails PRIMARY KEY CLUSTERED (Id ASC)
);
GO
CREATE INDEX ix1 ON dbo.EventDetails(EventId)
GO
--populate the table
INSERT INTO dbo.EventDetails(id,EventId,ItemId)
SELECT n AS id, 
 1 + ABS(CHECKSUM(NEWID())) % 3000000 AS OrganizerId, 1
FROM dbo.GetNums(3000000)
GO
 INSERT INTO dbo.EventDetails(id,EventId,ItemId)
SELECT 3000000+n AS id, 
 1 + ABS(CHECKSUM(NEWID())) % 3000000 AS OrganizerId, 2
FROM dbo.GetNums(3000000)
GO
 INSERT INTO dbo.EventDetails(id,EventId,ItemId)
SELECT 6000000+n AS id, 
 1 + ABS(CHECKSUM(NEWID())) % 3000000 AS OrganizerId, 3
FROM dbo.GetNums(3000000)
GO

-------------------------------------------------
--- Orders
--------------------------------------------------
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
CREATE TABLE dbo.Orders(
Id INT NOT NULL,
CustomerId INT NOT NULL,
OrderDate DATETIME NOT NULL,
Amount INT NOT NULL,
Status TINYINT NOT NULL DEFAULT 1,
Other CHAR(500) NOT NULL DEFAULT 'test',
CONSTRAINT PK_Orders PRIMARY KEY CLUSTERED (Id ASC)
);
GO
CREATE INDEX ix1 ON dbo.Orders(OrderDate)
GO
CREATE INDEX ix2 ON dbo.Orders(CustomerId)
GO
CREATE INDEX ix3 ON dbo.Orders(Status)
GO

DECLARE @date_from DATETIME = '19850101';
DECLARE @date_to DATETIME = '20200920';
INSERT INTO dbo.Orders(id,CustomerId,OrderDate,Amount)
SELECT n AS id, 
 1 + ABS(CHECKSUM(NEWID())) % 1000000 AS CustomerId,

 (SELECT(@date_from +(ABS(CAST(CAST( NewID() AS BINARY(8) )AS INT))%CAST((@date_to - @date_from)AS INT)))) OrderDate ,
  10 + ABS(CHECKSUM(NEWID())) % 10000 AS Amount 
FROM dbo.GetNums(10000000)
GO

UPDATE dbo.Orders SET OrderDate='20170101' WHERE CustomerId < 100000;

UPDATE STATISTICS dbo.Orders ix1;

ALTER TABLE dbo.Orders ADD CustId VARCHAR(20);
GO
UPDATE dbo.Orders SET CustId = CustomerId;
GO
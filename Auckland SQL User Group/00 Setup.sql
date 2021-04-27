-------------------------------------------------------------------------------------
-- Session: Transact-SQL Tips -Setup
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-------------------------------------------------------------------------------------
IF DB_ID('TSQLTips') IS NULL CREATE DATABASE TSQLTips;
GO
USE TSQLTips;
GO
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

 
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
CREATE TABLE dbo.Orders(
Id INT NOT NULL,
CustomerId INT NOT NULL,
OrderDate DATETIME NOT NULL,
Status TINYINT NOT NULL DEFAULT 1,
Amount INT NOT NULL,
Other CHAR(500) NOT NULL DEFAULT 'test',
CONSTRAINT PK_Orders PRIMARY KEY CLUSTERED (Id ASC)
);
GO
CREATE INDEX ix1 ON dbo.Orders(OrderDate)
GO
DECLARE @no_of_rows INT = 10000000;
DECLARE @date_from DATETIME = '20000101';
DECLARE @minutes_since_date_from BIGINT = (SELECT DATEDIFF(minute, @date_from, GETDATE()));
INSERT INTO dbo.Orders(id,CustomerId,OrderDate,Amount)
SELECT n AS id, 
	1 + ABS(CHECKSUM(NEWID())) % 1000000 AS CustomerId,
  DATEADD(minute, (1 + ABS(CHECKSUM(NEWID())) % @minutes_since_date_from), @date_from ) OrderDate,
  10 + ABS(CHECKSUM(NEWID())) % 10000 AS Amount 
FROM dbo.GetNums(@no_of_rows);

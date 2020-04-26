-------------------------------------------------------------------------------------
-- Parameter Sniffing in SQL Server Stored Procedures
-- Milos Radivojevic, Data Plarform MVP, bwin, Austria
-- E: MRadivojevic@gvcgroup.com
-------------------------------------------------------------------------------------
IF DB_ID('PS') IS NULL
	CREATE DATABASE PS;
GO 
USE PS;
GO
--help function, credits to Itzik Ben-Gan
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
 
-- Create a sample table
DROP TABLE IF EXISTS dbo.Orders;
CREATE TABLE dbo.Orders(
	Id INT NOT NULL,
	CustomerId INT NOT NULL,
	OrderDate DATETIME NOT NULL,
	Amount INT NOT NULL,
	Other CHAR(500) NULL,
 CONSTRAINT PK_Orders PRIMARY KEY CLUSTERED (Id ASC)
)
GO

--Populate the table
 DECLARE @date_from DATETIME = '20100101';
 DECLARE @date_to DATETIME = '20200425';
 DECLARE @number_of_rows INT = 10000000;
 INSERT INTO dbo.Orders
 SELECT n AS Id,
    1 + ABS(CHECKSUM(NEWID())) % 50000 AS CustomerId,
	(SELECT(@date_from +(ABS(CAST(CAST( NewID() AS BINARY(8) )AS INT))%CAST((@date_to - @date_from)AS INT)))) OrderDate,
    10 + ABS(CHECKSUM(NEWID())) % 10000 AS Amount,
	'other'
FROM dbo.GetNums(@number_of_rows)
ORDER BY 1
GO

-- Indexes
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'ix1' AND object_id = OBJECT_ID(N'dbo.Orders'))
	CREATE INDEX ix1 ON dbo.Orders (CustomerId);
GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'ix2' AND object_id = OBJECT_ID(N'dbo.Orders'))
	CREATE INDEX ix2 ON dbo.Orders (OrderDate)
GO


------------------------------
--- Default Solution
------------------------------
CREATE OR ALTER PROCEDURE dbo.GetOrders
@CustomerId INT = NULL, @OrderDate DATETIME = NULL
AS
BEGIN
	SELECT 
		TOP (10) *
	FROM dbo.Orders
	WHERE 
		(CustomerId = @CustomerId OR @CustomerId IS NULL)
		AND 
		(OrderDate = @OrderDate OR @OrderDate IS NULL)
	ORDER BY Amount DESC;
END
GO

-------------------------------------------------------------------------------------
-- Intelligent Query Processing - Scalar UDF Inlining
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-- Regression example
-------------------------------------------------------------------------------------

IF DB_ID('ScalarUDF') IS NULL CREATE DATABASE ScalarUDF;
GO
USE ScalarUDF;
GO

/*******************************************************************************
	create sample tables and functions
*******************************************************************************/

--create help function
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

----the Customers table
DROP TABLE IF EXISTS dbo.Customers;
CREATE TABLE dbo.Customers(
	CustomerId INT NOT NULL,
	CustomerName VARCHAR(20) NOT NULL,
CONSTRAINT PK_Customers PRIMARY KEY CLUSTERED (CustomerId ASC)
);
GO

DECLARE @number_of_rows INT = 1000;
INSERT INTO dbo.Customers(CustomerID,CustomerName)
SELECT n,
CONCAT('CUST',n) 
FROM dbo.GetNums(@number_of_rows)
GO

--the Orders table
DROP TABLE IF EXISTS dbo.Orders;
CREATE TABLE dbo.Orders(
	OrderId INT NOT NULL,
	CustomerID INT NOT NULL,
	OrderDate DATETIME NOT NULL,
CONSTRAINT PK_Orders PRIMARY KEY CLUSTERED (OrderId ASC)
);
GO
CREATE INDEX ix1 on dbo.Orders(CustomerID);
GO 
drop index ix1 on dbo.Orders
DECLARE @number_of_rows INT = 10000000;
DECLARE @date_from DATETIME = '20000101';
DECLARE @date_to DATETIME = '20171025';
INSERT INTO dbo.Orders(OrderId,CustomerID,OrderDate)
SELECT n,
1 + ABS(CHECKSUM(NEWID())) % 1000 AS CustomerID,
(SELECT(@date_from +(ABS(CAST(CAST( NewID() AS BINARY(8)) AS INT))%CAST((@date_to - @date_from)AS INT)))) AS OrderDate
FROM dbo.GetNums(@number_of_rows)
GO

 
CREATE OR ALTER FUNCTION dbo.GetOrderCnt (@CustomerId INT)
RETURNS INT
AS
BEGIN
    DECLARE @Cnt INT;
    SELECT @Cnt = COUNT(*) FROM dbo.Orders WHERE CustomerId = @CustomerId;
    RETURN @Cnt;
END
GO
ALTER DATABASE ScalarUDF SET COMPATIBILITY_LEVEL = 140;
GO
SELECT TOP (10) *,dbo.GetOrderCnt(CustomerId) FROM dbo.Customers   
 
GO
ALTER DATABASE ScalarUDF SET COMPATIBILITY_LEVEL = 150;
GO
SELECT TOP (10) *,dbo.GetOrderCnt(CustomerId) FROM dbo.Customers  
GO
ALTER DATABASE ScalarUDF SET COMPATIBILITY_LEVEL = 150;
GO
SELECT TOP (10) *,dbo.GetOrderCnt(CustomerId) FROM dbo.Customers  
OPTION (USE HINT('DISABLE_TSQL_SCALAR_UDF_INLINING'));
 

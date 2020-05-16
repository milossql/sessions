-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 3: Common Transact-SQL Tasks - Foreach
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------

--help function GetNums originaly created by Itzik Ben-Gan (http://tsql.solidq.com)
IF OBJECT_ID('dbo.GetNums') IS NOT NULL DROP FUNCTION dbo.GetNums;
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
 
--Create customer table
DROP TABLE IF EXISTS dbo.Customers;
CREATE TABLE dbo.Customers(
custid INT NOT NULL,
custname VARCHAR(20) NOT NULL,
country TINYINT NOT NULL,
CONSTRAINT PK_Customers PRIMARY KEY CLUSTERED (custid ASC)
);
GO
 
-- Populate the table with 1M rows
INSERT INTO dbo.Customers(custid,custname,country)
SELECT n AS custid, 'CUST' + CAST(n AS VARCHAR) AS custname, 1 AS country
FROM dbo.GetNums(1000000)
GO
-- Add additional 100K rows
INSERT INTO dbo.Customers(custid,custname,country)
SELECT 1000000 + n AS custid, 'CUST' + CAST(n AS VARCHAR) AS custname, 2 AS country
FROM dbo.GetNums(100000)
GO
-- Add additional 10K rows
INSERT INTO dbo.Customers(custid,custname,country)
SELECT 1100000 + n AS custid, 'CUST' + CAST(n AS VARCHAR) AS custname, 3 AS country
FROM dbo.GetNums(10000)
GO
-- Add additional 1K rows
INSERT INTO dbo.Customers(custid,custname,country)
SELECT 1110000 + n AS custid, 'CUST' + CAST(n AS VARCHAR) AS custname, 4 AS country
FROM dbo.GetNums(1000)
GO
-- Add additional 100 rows
 INSERT INTO dbo.Customers(custid,custname,country)
SELECT 1111000 + n AS custid, 'CUST' + CAST(n AS VARCHAR) AS custname, 5 AS country
FROM dbo.GetNums(100)
GO
--Create a sample table
DROP TABLE IF EXISTS dbo.Orders;
CREATE TABLE dbo.Orders(
id INT IDENTITY(1,1) NOT NULL,
custid INT NOT NULL,
orderdate DATETIME NOT NULL,
amount MONEY NOT NULL,
CONSTRAINT PK_Orders PRIMARY KEY CLUSTERED (id ASC)
);
GO
 
 -- Populate the order table with 20M rows for 2014
DECLARE @date_from DATETIME = '20140101';
DECLARE @date_to DATETIME = '20180101';
DECLARE @number_of_rows INT = 20000000;
INSERT INTO dbo.Orders(custid,orderdate,amount)
SELECT 1 + ABS(CHECKSUM(NEWID())) % 1111100 AS custid,
(SELECT(@date_from +(ABS(CAST(CAST( NewID() AS BINARY(8)) AS INT))%CAST((@date_to - @date_from)AS INT)))) AS orderdate,
1 + ABS(CHECKSUM(NEWID())) % 1000 AS amount
FROM dbo.GetNums(@number_of_rows)
GO
-- Add additional 1M rows for 2015
DECLARE @date_from DATETIME = '20180101';
DECLARE @date_to DATETIME = '20180501';
DECLARE @number_of_rows INT = 1000000;
INSERT INTO dbo.Orders(custid,orderdate,amount)
SELECT 1 + ABS(CHECKSUM(NEWID())) % 1111100 AS custid,
(SELECT(@date_from +(ABS(CAST(CAST( NewID() AS BINARY(8)) AS INT))%CAST((@date_to - @date_from)AS INT)))) AS orderdate,
1 + ABS(CHECKSUM(NEWID())) % 1000 AS amount
FROM dbo.GetNums(@number_of_rows)
GO
--Create the optimal index
CREATE INDEX ix1 ON dbo.Orders(custid, orderdate);
GO

--Create Procs
 
CREATE OR ALTER PROCEDURE dbo.uspGetCustomers
@Country TINYINT
AS
BEGIN
    SELECT custid
    FROM dbo.Customers
    WHERE country = @Country
	ORDER BY custid;
END
GO
CREATE OR ALTER PROCEDURE dbo.uspGetTop2OrdersForCustomer
@CustID INT
AS
BEGIN
	SELECT TOP (2) *
    FROM dbo.Orders
    WHERE custid = @CustID
    AND orderdate >= '20180101'
    ORDER BY orderdate DESC, id DESC;
END
GO
CREATE OR ALTER PROCEDURE dbo.uspGetOrdersForCustomers
@Country TINYINT
AS
BEGIN
	WITH cte AS
	(
		SELECT o.*,
		ROW_NUMBER() OVER(PARTITION BY o.custid ORDER BY o.orderdate DESC, o.id DESC) rn
		FROM dbo.Customers c
		INNER JOIN dbo.Orders o ON c.custid = o.custid
		WHERE orderdate >= '20180101'
		AND country = @Country
	)
	 SELECT id, custid, orderdate, amount FROM cte
	 WHERE rn < 3 AND amount >= 1000
	 ORDER BY custid, orderdate DESC;
END
GO
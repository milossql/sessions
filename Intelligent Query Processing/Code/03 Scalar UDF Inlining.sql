-------------------------------------------------------------------------------------
-- Intelligent Query Processing - Scalar UDF Inlining
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------

IF DB_ID('TestDb') IS NULL CREATE DATABASE TestDb;
GO
USE TestDb;
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

DECLARE @number_of_rows INT = 100000;
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

DECLARE @number_of_rows INT = 1000000;
DECLARE @date_from DATETIME = '20000101';
DECLARE @date_to DATETIME = '20171025';
INSERT INTO dbo.Orders(OrderId,CustomerID,OrderDate)
SELECT n,
1 + ABS(CHECKSUM(NEWID())) % 100000 AS CustomerID,
(SELECT(@date_from +(ABS(CAST(CAST( NewID() AS BINARY(8)) AS INT))%CAST((@date_to - @date_from)AS INT)))) AS OrderDate
FROM dbo.GetNums(@number_of_rows)
GO


--the OrderDetails table
DROP TABLE IF EXISTS dbo.OrderDetails;
CREATE TABLE dbo.OrderDetails(
	Id INT NOT NULL,
	OrderId INT NOT NULL,
	Quantity INT NOT NULL,
	UnitPrice DECIMAL(10,2) NOT NULL,
CONSTRAINT PK_OrderDetails PRIMARY KEY CLUSTERED (Id ASC)
);
GO

DECLARE @number_of_rows INT = 3000000;
INSERT INTO dbo.OrderDetails(Id, OrderId,Quantity,UnitPrice)
SELECT n, 1 + ABS(CHECKSUM(NEWID())) % 1000000 AS Quantity,
1 + ABS(CHECKSUM(NEWID())) % 20 AS Quantity,
 ABS(CHECKSUM(NEWID())) % 500 AS UnitPrice 
FROM dbo.GetNums(@number_of_rows)
GO

--the F1_Scalar scalar user-defined function
CREATE OR ALTER FUNCTION dbo.F1_Scalar(@Quantity AS int, @UnitPrice DECIMAL(10,2)) RETURNS  DECIMAL(10,2)
AS
BEGIN
    DECLARE @Amount  DECIMAL(10,2);
    SELECT @Amount = @Quantity * @UnitPrice
    RETURN @Amount;
END
GO

--ensure that the database runs under CL 140
ALTER DATABASE TestDb SET COMPATIBILITY_LEVEL = 140;
GO

--turn on the STATISTICS TIME
SET NOCOUNT ON SET STATISTICS TIME ON;
GO

--turn on the Discard results after execution option
--in order to suppress painting the results

--run the statement invoking the function
SELECT *, dbo.F1_Scalar(Quantity,UnitPrice) xx
FROM dbo.OrderDetails;

/*Result:
 SQL Server Execution Times:
   CPU time = 22421 ms,  elapsed time = 25938 ms.
*/

--switch to CL 150
ALTER DATABASE TestDb SET COMPATIBILITY_LEVEL = 150;
GO

--run the statement again
SELECT *, dbo.F1_Scalar(Quantity,UnitPrice) xx
FROM dbo.OrderDetails;

/*Result:
 SQL Server Execution Times:
   CPU time = 2172 ms,  elapsed time = 2373 ms.
*/

/****************************************************************************************************************
26 seconds vs. 2.37 seconds
More than 10 tiems faster! Very impressive!
BUT, there are many limitations:
- The UDF does not invoke any intrinsic function that is either time-dependent (such as GETDATE()) or has side effects3 (such as NEWSEQUENTIALID()).
- The UDF uses the EXECUTE AS CALLER clause (the default behavior if the EXECUTE AS clause is not specified).
- The UDF does not reference table variables or table-valued parameters.
- The query invoking a scalar UDF does not reference a scalar UDF call in its GROUP BY clause.
- The query invoking a scalar UDF in its select list with DISTINCT clause does not have ORDER BY clause.
- The UDF is not used in ORDER BY clause.
- The UDF is not natively compiled (interop is supported).
- The UDF is not used in a computed column or a check constraint definition.
- The UDF does not reference user-defined types.
- There are no signatures added to the UDF.
- The UDF is not a partition function.

The most important one is related to the usage of time-dependent functions.
As soon as you use a time function such as GETDATE() function, inlining does not work

****************************************************************************************************************/
--check the flag showing wheather the function is inlineable
--ensure that you uncheck the Discard results after execution option
SELECT CONCAT(SCHEMA_NAME(o.schema_id),'.',o.name) func_name, is_inlineable
FROM sys.sql_modules m
INNER JOIN sys.objects o ON o.object_id = m.object_id
WHERE o.type = 'FN'; 
GO
/*Result:
func_name	is_inlineable
dbo.F1_Scalar	1
*/

--let's add GETDATE() to the function definition
CREATE OR ALTER FUNCTION dbo.F1_Scalar(@Quantity AS int, @UnitPrice DECIMAL(10,2)) RETURNS  DECIMAL(10,2)
AS
BEGIN
    DECLARE @Amount  DECIMAL(10,2);
	DECLARE @d DATETIME = GETDATE();
    SELECT @Amount = @Quantity * @UnitPrice
    RETURN @Amount;
END
GO

--check the flag showing wheather the function is inlineable
SELECT CONCAT(SCHEMA_NAME(o.schema_id),'.',o.name) func_name, is_inlineable
FROM sys.sql_modules m
INNER JOIN sys.objects o ON o.object_id = m.object_id
WHERE o.type = 'FN'; 
GO
/*Result:
func_name	is_inlineable
dbo.F1_Scalar	0
*/

/*
Conclusion:
 - improvements are impressive, but with many limitations.
 - check the is_inlineable attribute to see whether your functions are eligible for this feature
*/

--cleanup
DROP FUNCTION IF EXISTS dbo.F1_Scalar;
GO
DROP TABLE IF EXISTS dbo.OrderDetails;
GO
DROP TABLE IF EXISTS dbo.Orders;
GO
DROP TABLE IF EXISTS dbo.Customers;
GO
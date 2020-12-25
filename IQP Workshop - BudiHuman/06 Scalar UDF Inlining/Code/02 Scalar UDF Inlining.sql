-------------------------------------------------------------------------------------
-- Intelligent Query Processing - Scalar UDF Inlining
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-- Regression example
-------------------------------------------------------------------------------------
USE TestDb;
GO
CREATE OR ALTER FUNCTION dbo.GetOrderItemStatus(
@Quantity INT, @UnitPrice DECIMAL(10,2)) 
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @Ret VARCHAR(20) = '';
    DECLARE @Amount  DECIMAL(10,2) =  @Quantity * @UnitPrice;
    IF @Amount > 1000
        SET @Ret = 'TOP 1000'
    ELSE IF @Amount > 500
        SET @Ret = 'TOP 500'
    RETURN @Ret;
END
GO
SET STATISTICS TIME ON;
GO
ALTER DATABASE TestDb SET COMPATIBILITY_LEVEL = 140;
GO
SELECT *, dbo.GetOrderItemStatus(Quantity,UnitPrice) ItemStatus FROM dbo.OrderDetails;
GO
ALTER DATABASE TestDb SET COMPATIBILITY_LEVEL = 150;
GO
SELECT *, dbo.GetOrderItemStatus(Quantity,UnitPrice) ItemStatus FROM dbo.OrderDetails;
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
ALTER DATABASE TestDb SET COMPATIBILITY_LEVEL = 140;
GO
SELECT * FROM dbo.Customers WHERE dbo.GetOrderCnt(CustomerId) > 25;
GO
ALTER DATABASE TestDb SET COMPATIBILITY_LEVEL = 150;
GO
SELECT * FROM dbo.Customers WHERE dbo.GetOrderCnt(CustomerId) > 25;
GO

CREATE OR ALTER FUNCTION dbo.GetDaysFromLastOrder(@CustomerId INT) 
RETURNS INT
AS
BEGIN
    DECLARE @Days INT;
    DECLARE @LastOrder DATETIME;
    SET @LastOrder = (SELECT TOP (1) OrderDate FROM dbo.Orders WHERE CustomerId = @CustomerId ORDER BY OrderDate DESC);
    SELECT @Days = DATEDIFF(day, @LastOrder, GETDATE());
    RETURN @Days;
END
GO
ALTER DATABASE TestDb SET COMPATIBILITY_LEVEL = 140;
GO
SELECT * FROM dbo.Customers WHERE dbo.GetDaysFromLastOrder(CustomerId) > 365;
GO
ALTER DATABASE TestDb SET COMPATIBILITY_LEVEL = 150;
GO
SELECT * FROM dbo.Customers WHERE dbo.GetDaysFromLastOrder(CustomerId) > 365;
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


ALTER DATABASE TestDb SET COMPATIBILITY_LEVEL = 140;
GO
SELECT TOP (5) *,dbo.GetOrderCnt(CustomerId) FROM dbo.Customers2  
WHERE CustomerId < 1000
GO
ALTER DATABASE TestDb SET COMPATIBILITY_LEVEL = 150;
GO
SELECT TOP (5) *,dbo.GetOrderCnt(CustomerId) FROM dbo.Customers2 
WHERE CustomerId < 1000

SELECT TOP (10) * FROM dbo.Customers WHERE dbo.GetOrderCnt(CustomerId) > 25
OPTION (USE HINT('DISABLE_TSQL_SCALAR_UDF_INLINING'));
 
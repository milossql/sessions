-------------------------------------------------------------------------------------
-- Intelligent Query Processing - Interleaved Execution
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-- Limitations
-------------------------------------------------------------------------------------
USE WideWorldImporters;
GO

CREATE OR ALTER FUNCTION dbo.Top2OrdersForCustomer(@CustomerId INT)
RETURNS @T TABLE
(ID    INT  NOT NULL)
AS
BEGIN
    INSERT INTO @T
	SELECT TOP (2) OrderId FROM Sales.Orders WHERE CustomerID = @CustomerId
    RETURN
END
GO
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 140;
GO

SELECT * FROM Sales.Customers c
CROSS APPLY dbo.Top2OrdersForCustomer(c.CustomerID) x
 
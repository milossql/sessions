-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 2: Writing Well-Performed Queries - UDFs
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------

USE WideWorldImporters;
GO
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 140;
GO
CREATE OR ALTER FUNCTION dbo.GetMaxOrderDateForCustomer_Scalar(@CustomerID AS int) 
RETURNS DATE
AS
BEGIN
    DECLARE @OrderDate DATE;
    SELECT @OrderDate = MAX(OrderDate) FROM Sales.Orders WHERE CustomerID = @CustomerID
    RETURN @OrderDate;
END
GO
 
CREATE OR ALTER FUNCTION dbo.GetMaxOrderDateForCustomer_Inline(@CustomerID AS int) RETURNS TABLE
AS RETURN 
	SELECT MAX(OrderDate)  MaxOrderDate FROM Sales.Orders
    WHERE CustomerID = @CustomerID
GO

CREATE OR ALTER  FUNCTION dbo.GetMaxOrderDateForCustomer_Multiline(@CustomerID AS int)
RETURNS @t TABLE (MaxOrderDate DATE)
AS 
BEGIN 
	INSERT @t
    SELECT MAX(OrderDate) FROM Sales.Orders WHERE CustomerID = @CustomerID;
    RETURN
END
GO

SELECT p.CustomerID, dbo.GetMaxOrderDateForCustomer_Scalar(p.CustomerID) MaxOrderDate
FROM Sales.Customers p --elapsed time = 1447 ms.
GO
SELECT p.CustomerID, (SELECT MaxOrderDate FROM dbo.GetMaxOrderDateForCustomer_Inline(p.CustomerID)) MaxOrderDate
FROM Sales.Customers p --elapsed time = 265 ms.
GO
SELECT p.CustomerID, m.MaxOrderDate  
FROM Sales.Customers p 
OUTER APPLY  dbo.GetMaxOrderDateForCustomer_Multiline(p.CustomerID) m -- elapsed time = 17871 ms



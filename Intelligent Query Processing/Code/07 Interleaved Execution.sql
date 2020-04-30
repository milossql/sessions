-------------------------------------------------------------------------------------
-- Intelligent Query Processing - Interleaved Execution
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------
 
USE WideWorldImporters;
GO
SET NOCOUNT ON SET STATISTICS TIME ON;
GO


--create a sample MTVF
CREATE OR ALTER FUNCTION dbo.SignificantOrders()
RETURNS @T TABLE
(ID    INT  NOT NULL)
AS
BEGIN
    INSERT INTO @T
	SELECT OrderId FROM Sales.Orders
    RETURN
END
GO

--Set the compatibility mode to SQL Server 2012 and run the query with Include Actual Execution Plan
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 130;
GO
SELECT ol.OrderID, ol.UnitPrice, ol.StockItemID 
FROM Sales.Orderlines ol
INNER JOIN dbo.SignificantOrders() f1 ON f1.Id = ol.OrderID
WHERE PackageTypeID = 7;
GO  
/*
	Execution plan: based on the Nest Loop Join
	   CPU time = 875 ms,  elapsed time = 864 ms.
	Estimated Number of Rows for function: 100
*/

--Set the compatibility mode to SQL Server 2017 and run the query with Include Actual Execution Plan
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 150;
GO
SELECT ol.OrderID,  ol.UnitPrice, ol.StockItemID 
FROM Sales.Orderlines ol
INNER JOIN dbo.SignificantOrders() f1 ON f1.Id = ol.OrderID
WHERE PackageTypeID = 7;
GO  
/*
	Execution plan: based on the Hash Match Join
	   CPU time = 422 ms,  elapsed time = 427 ms.
	Estimated Number of Rows for function: 73595 (actual number actually)
*/

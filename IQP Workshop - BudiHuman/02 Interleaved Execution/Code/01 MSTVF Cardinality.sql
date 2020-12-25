-------------------------------------------------------------------------------------
-- Intelligent Query Processing - Interleaved Execution
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-- MSTVF Cardinality
-------------------------------------------------------------------------------------

USE WideWorldImporters;
GO
SET NOCOUNT ON SET STATISTICS TIME ON;
GO
--create a sample MTVF
CREATE OR ALTER FUNCTION dbo.SignificantOrders()
RETURNS @T TABLE
(ID INT NOT NULL)
AS
BEGIN
    INSERT INTO @T
	SELECT OrderId FROM Sales.Orders
    RETURN
END
GO
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 110;
GO
SELECT * FROM dbo.SignificantOrders();
GO
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 130;
GO
SELECT * FROM dbo.SignificantOrders();
GO
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 140;
GO
SELECT * FROM dbo.SignificantOrders();
GO
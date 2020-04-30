-------------------------------------------------------------------------------------
-- Intelligent Query Processing - Adaptive Join
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------

USE WideWorldImporters;
GO
--create a sample stored procedure
CREATE OR ALTER PROCEDURE dbo.GetOrderDetails
@UnitPrice DECIMAL(18,2)
AS
SELECT o.OrderID, o.OrderDate, ol.OrderLineID, ol.Quantity, ol.UnitPrice
FROM Sales.OrderLines ol
INNER JOIN Sales.Orders o ON ol.OrderID = o.OrderID
WHERE ol.UnitPrice = @UnitPrice;
GO


--Set the compatibility mode to SQL Server 2016 and run the query with Include Actual Execution Plan
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 130;
GO
EXEC dbo.GetOrderDetails 112;
GO
/*
The execution plan is Hash Join based, with longer duration and CPU usage 
*/
EXEC dbo.GetOrderDetails 36;
GO
/*
The execution plan is the same, taken form cache
*/

--clear cache and execute the same queries but in different order
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
EXEC dbo.GetOrderDetails 36;
GO
/*
The execution plan is Nested Loop Join based, with longer duration and CPU usage 
*/
EXEC dbo.GetOrderDetails 112;
GO
/*
The execution plan is the same, taken form cache
*/


--Set the compatibility mode to SQL Server 2016 and run the query with Include Actual Execution Plan
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 140;
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
EXEC dbo.GetOrderDetails 112;
GO
/*
The execution plan is Adaptive Join based
--Actual Join Type: HashMatch
--upper branch executed (clustered index scan)
*/
EXEC dbo.GetOrderDetails 36;
GO
/*
The execution plan is Adaptive Join based
--Actual Join Type: NestedLoop
--lower branch executed (clustered index seek)
*/

--Disable Batch Mode Adaptive Join
ALTER DATABASE SCOPED CONFIGURATION SET DISABLE_BATCH_MODE_ADAPTIVE_JOINS = ON;
GO

--Enable Batch Mode Adaptive Join
ALTER DATABASE SCOPED CONFIGURATION SET DISABLE_BATCH_MODE_ADAPTIVE_JOINS = OFF;
GO
 
--Disable auf Query Ebene
CREATE OR ALTER PROCEDURE dbo.GetOrderDetails
@UnitPrice DECIMAL(18,2)
AS
SELECT o.OrderID, o.OrderDate, ol.OrderLineID, ol.Quantity, ol.UnitPrice
FROM Sales.OrderLines ol
INNER JOIN Sales.Orders o ON ol.OrderID = o.OrderID
WHERE ol.UnitPrice = @UnitPrice
OPTION (USE HINT('DISABLE_BATCH_MODE_ADAPTIVE_JOINS')); 
GO
EXEC dbo.GetOrderDetails 36;
GO
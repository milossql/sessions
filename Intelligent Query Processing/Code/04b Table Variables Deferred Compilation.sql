-------------------------------------------------------------------------------------
-- Intelligent Query Processing - Table Variable Deferred Compilation
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------

USE AdventureWorks2019;
GO
SET NOCOUNT ON SET STATISTICS TIME ON;
GO

--ensure that database runs in the CL 140
ALTER DATABASE AdventureWorks2019 SET COMPATIBILITY_LEVEL = 140;
GO
--run the following code with the Discard results after execution option
DECLARE @T AS TABLE (ProductID INT);
INSERT INTO @T SELECT ProductID FROM Production.Product WHERE ProductLine IS NOT NULL;

SELECT * FROM @T t
INNER JOIN Sales.SalesOrderDetail od on t.ProductID = od.ProductID
INNER JOIN Sales.SalesOrderHeader h on h.SalesOrderID = od.SalesOrderID
ORDER BY od.UnitPrice DESC;
GO
/*Result:
	Execution plan: Nested Loop Join based
	SQL Server Execution Times:
	CPU time = 984 ms,  elapsed time = 1234 ms.
   */

--switch to CL 150
ALTER DATABASE AdventureWorks2019 SET COMPATIBILITY_LEVEL = 150;
GO
--run the following code with the Discard results after execution option
DECLARE @T AS TABLE (ProductID INT);
INSERT INTO @T SELECT ProductID FROM Production.Product WHERE ProductLine IS NOT NULL;

SELECT * FROM @T t
INNER JOIN Sales.SalesOrderDetail od on t.ProductID = od.ProductID
INNER JOIN Sales.SalesOrderHeader h on h.SalesOrderID = od.SalesOrderID
ORDER BY od.UnitPrice DESC;
GO
/*Result:
	Execution plan: Hash Match Join based
	SQL Server Execution Times:
	CPU time = 1284 ms,  elapsed time = 532 ms.
   */

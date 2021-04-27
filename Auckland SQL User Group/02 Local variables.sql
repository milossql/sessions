-------------------------------------------------------------------------------------
-- Session: Transact-SQL Tips - Local variables
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-------------------------------------------------------------------------------------
USE TSQLTips;
GO
DECLARE @today DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0);
SELECT * FROM dbo.Orders WHERE OrderDate >= @today;


SELECT * FROM dbo.Orders WHERE OrderDate >= '20210426';

USE Statistik
GO
DECLARE @current INT = 10000, @size INT = 500;
SELECT * FROM dbo.A WHERE pid >= @current AND pid < @current + @size;

SELECT * FROM dbo.A WHERE pid >= 10000 AND pid < 10500;
 GO

DECLARE @current INT = 10000, @size INT = 500;
SELECT * FROM B WHERE pid >= @current AND pid < @current + @size;

SELECT * FROM B WHERE pid >= 10000 AND pid < 10500;
 

 --OPTION RECOMPILE
USE TSQLTips;
GO
DECLARE @today DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0);
SELECT * FROM dbo.Orders WHERE OrderDate >= @today OPTION (RECOMPILE);

GO


DECLARE @today DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0);
SELECT * FROM dbo.Orders WHERE OrderDate >= @today 

SELECT * FROM dbo.Orders WHERE OrderDate >= @today  
GO
 

SELECT * FROM dbo.Orders WHERE OrderDate >= DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0);

SELECT * FROM dbo.Orders WHERE OrderDate >= DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0); 
--not the same date
GO
CREATE PROCEDURE dbo.GetOrders @today DATETIME
AS
SELECT * FROM dbo.Orders WHERE OrderDate >= @today  
SELECT * FROM dbo.Orders WHERE OrderDate >= @today  
GO
 

DECLARE @today DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0);
EXEC dbo.GetOrders @today



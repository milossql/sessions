-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 2: Writing Well-Performed Queries - Local Variables
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------
USE OSK;
GO
--statistics
DBCC SHOW_STATISTICS ('dbo.tabOrders','ix_tabOrders_fOrderDate');

--comparison (no discrepancy)
SELECT * FROM dbo.tabOrders WHERE fOrderDate = '20140330';
DECLARE @d DATE = '20140330';
SELECT * FROM dbo.tabOrders WHERE fOrderDate = @d;
GO

--comparison (discrepancy)
SELECT * FROM dbo.tabOrders WHERE fOrderDate = '20170101' 
ORDER BY fCustomerId;
DECLARE @d DATE = '20170101';
SELECT * FROM dbo.tabOrders WHERE fOrderDate = @d
ORDER BY fCustomerId;
GO

--comparison (discrepancy)
SELECT * FROM dbo.tabOrders WHERE fOrderDate >='20191231' 
ORDER BY fAmount;
DECLARE @d DATE = '20191231';
SELECT * FROM dbo.tabOrders WHERE fOrderDate >= @d ORDER BY fAmount;


DECLARE @d1 DATE = '20191231', @d2 DATE = '20221231'
SELECT * FROM dbo.tabOrders WHERE fOrderDate >= @d1 AND fOrderDate<@d2 ORDER BY fAmount;
GO

SELECT * FROM dbo.tabOrders WHERE fOrderDate >='20191231';

DECLARE @d DATE = '20191231';
SELECT * FROM dbo.tabOrders WHERE fOrderDate >= @d;
DECLARE @d1 DATE = '20191231';
DECLARE @d2 DATE = '20191231';
--ALTER DATABASE OSK SET COMPATIBILITY_LEVEL = 150
SELECT * FROM dbo.tabOrders WHERE fOrderDate BETWEEN @d1 AND @d2;
GO
DECLARE @yesterday DATETIME = DATEADD(day, -1, GETDATE())
SELECT * FROM dbo.tabOrders WHERE fOrderDate >= @yesterday
OPTION (RECOMPILE)
GO
 USE Statistik
  DECLARE @p INT = 3456
 DECLARE @q INT = 3466

SELECT * FROM dbo.A WHERE pid BETWEEN @p AND @q
GO
 

SELECT * FROM dbo.A WHERE pid BETWEEN 3456 AND 3466

SELECT * FROM dbo.tabOrders WHERE fOrderDate >= DATEADD(day, -1, GETDATE())
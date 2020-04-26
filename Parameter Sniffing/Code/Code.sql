-------------------------------------------------------------------------------------
-- Parameter Sniffing in SQL Server Stored Procedures
-- Milos Radivojevic, Data Plarform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------
USE PS;
GO

--invoke the procedure
EXEC dbo.GetOrders 567, NULL;
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
EXEC dbo.GetOrders NULL,'20200401';
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
EXEC dbo.GetOrders NULL, NULL;
GO
----------------------------------------------
--- Solution 1 – Disable Parameter Sniffing
----------------------------------------------
CREATE OR ALTER PROCEDURE dbo.GetOrders
@CustomerId INT = NULL, @OrderDate DATETIME = NULL
AS
BEGIN
	SELECT 
		TOP (10) *
	FROM dbo.Orders
	WHERE 
		(CustomerId = @CustomerId OR @CustomerId IS NULL)
	AND 
		(OrderDate = @OrderDate OR @OrderDate IS NULL)
	ORDER BY Amount DESC
	OPTION (OPTIMIZE FOR UNKNOWN);
END
GO
CREATE OR ALTER PROCEDURE dbo.GetOrders
	@CustomerId INT = NULL, @OrderDate DATETIME = NULL
AS
BEGIN
	DECLARE @cid INT = @CustomerId;
	DECLARE @od DATETIME = @OrderDate;
	SELECT TOP (10) * FROM dbo.Orders
	WHERE 
		(CustomerId = @cid OR @cid IS NULL)
		AND 
		(OrderDate = @od OR @od IS NULL)
	ORDER BY Amount DESC;
END
GO

ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = OFF;
GO

----------------------------------------------
--- Solution 3 – Recompile
----------------------------------------------
EXEC dbo.GetOrders 567,NULL WITH RECOMPILE;
EXEC dbo.GetOrders NULL,'20200401' WITH RECOMPILE;
EXEC dbo.GetOrders NULL,NULL WITH RECOMPILE;
GO
CREATE OR ALTER PROCEDURE dbo.GetOrders
@CustomerId INT = NULL, @OrderDate DATETIME = NULL
WITH RECOMPILE
AS
BEGIN
	SELECT 
		TOP (10) *
	FROM dbo.Orders
	WHERE 
		(CustomerId = @CustomerId OR @CustomerId IS NULL)
	AND 
		(OrderDate = @OrderDate OR @OrderDate IS NULL)
	ORDER BY Amount DESC
END
GO

----------------------------------------------
--- Solution 4 – OPTION (RECOMPILE)
----------------------------------------------
CREATE OR ALTER PROCEDURE dbo.GetOrders
@CustomerId INT = NULL, @OrderDate DATETIME = NULL
AS
BEGIN
	SELECT 
		TOP (10) *
	FROM dbo.Orders
	WHERE 
		(CustomerId = @CustomerId OR @CustomerId IS NULL)
	AND 
		(OrderDate = @OrderDate OR @OrderDate IS NULL)
	ORDER BY Amount DESC
	OPTION (RECOMPILE)
END
GO


----------------------------------------------
--- Solution 5 – Decomposition (Static)
----------------------------------------------
CREATE OR ALTER PROCEDURE dbo.GetOrders
	@CustomerId INT = NULL, @OrderDate DATETIME = NULL
AS
BEGIN
	IF @CustomerId IS NOT NULL
		EXEC dbo.GetOrders1 @CustomerId
	ELSE
		IF @OrderDate IS NOT NULL
			EXEC dbo.GetOrders2 @OrderDate
		ELSE
			EXEC dbo.GetOrders3  
END
GO
----------------------------------------------
--- Solution 6 – Decomposition (Dynamic)
----------------------------------------------
CREATE OR ALTER PROCEDURE dbo.GetOrders
	@CustomerId INT = NULL, @OrderDate DATETIME = NULL
AS
BEGIN
 
	DECLARE @sql NVARCHAR(800) = N'SELECT TOP (10) * FROM dbo.Orders WHERE 1 = 1  '
	IF @CustomerId IS NOT NULL 
		SET @sql+= ' AND CustomerId = @cid '
	IF @OrderDate IS NOT NULL 
		SET @sql+= ' AND OrderDate = @od '
	SET @sql+= ' ORDER BY Amount DESC ' 
	
EXEC sp_executesql @sql,  N'@cid INT, @od DATETIME',  @cid = @CustomerId, @od = @OrderDate;
END
GO

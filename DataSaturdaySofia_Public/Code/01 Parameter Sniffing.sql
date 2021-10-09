-------------------------------------------------------------------------------------
-- Parameter Sniffing in SQL Server Stored Procedures
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
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
--- Default Implementation 
----------------------------------------------
CREATE OR ALTER PROCEDURE dbo.GetOrders
	@CustomerId INT = NULL, @OrderDate DATETIME = NULL
AS
BEGIN
	SELECT TOP (10) * FROM dbo.Orders
	WHERE 
		(CustomerId = @CustomerId OR @CustomerId IS NULL)
		AND 
		(OrderDate = @OrderDate OR @OrderDate IS NULL)
	ORDER BY Amount DESC;
END
GO

----------------------------------------------
--- Solution 1 – Disable Parameter Sniffing
----------------------------------------------
--OPTIMIZE FOR UNKNOWN
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

--
--ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = OFF;
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
EXEC dbo.GetOrders 457
EXEC dbo.GetOrders NULL, '20200401'
GO
--DISABLE_PARAMETER_SNIFFING
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
	OPTION (USE HINT ('DISABLE_PARAMETER_SNIFFING'));
END
GO


----------------------------------------------
--- Solution 2 – a favorite combination
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
	OPTION (OPTIMIZE FOR (@CustomerId=450));
END
GO


----------------------------------------------
--- Solution 3 – Recompile
----------------------------------------------
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
CREATE OR ALTER PROCEDURE dbo.GetOrders1
@CustomerId INT
AS
BEGIN
	SELECT TOP (10) *
	FROM dbo.Orders
	WHERE CustomerId = @CustomerId
	ORDER BY Amount DESC
END
GO

CREATE OR ALTER PROCEDURE dbo.GetOrders2
@OrderDate DATETIME
AS
BEGIN
	SELECT TOP (10) *
	FROM dbo.Orders
	WHERE OrderDate = @OrderDate
	ORDER BY Amount DESC
END
GO

CREATE OR ALTER PROCEDURE dbo.GetOrders3
AS
BEGIN
	SELECT TOP (10) *
	FROM dbo.Orders
	ORDER BY Amount DESC
END
GO

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

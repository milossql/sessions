-------------------------------------------------------------------------------------
-- Intelligent Query Processing - Memory Grant Feedback 
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------

IF DB_ID('TestDb') IS NULL CREATE DATABASE TestDb;
GO
USE TestDb;
GO
/*******************************************************************************
	create sample tables and functions
*******************************************************************************/
CREATE OR ALTER FUNCTION dbo.GetNums(@n AS BIGINT) RETURNS TABLE
AS
RETURN
  WITH
  L0   AS(SELECT 1 AS c UNION ALL SELECT 1),
  L1   AS(SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
  L2   AS(SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
  L3   AS(SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
  L4   AS(SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
  L5   AS(SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
  Nums AS(SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n FROM L5)
  SELECT n FROM Nums WHERE n <= @n;
GO

--Create a sample table
DROP TABLE IF EXISTS dbo.Events;
CREATE TABLE dbo.Events(
Id INT IDENTITY(1,1) NOT NULL,
EventType TINYINT NOT NULL,
EventDate DATETIME NOT NULL,
Note CHAR(100) NOT NULL DEFAULT 'test',
CONSTRAINT PK_Events PRIMARY KEY CLUSTERED (id ASC)
);
GO
-- Populate the table with 10M rows
DECLARE @date_from DATETIME = '20000101';
DECLARE @date_to DATETIME = '20171025';
DECLARE @number_of_rows INT = 10000000;
INSERT INTO dbo.Events(EventType,EventDate)
SELECT 1 + ABS(CHECKSUM(NEWID())) % 5 AS eventtype,
(SELECT(@date_from +(ABS(CAST(CAST( NewID() AS BINARY(8)) AS INT))%CAST((@date_to - @date_from)AS INT)))) AS EventDate
FROM dbo.GetNums(@number_of_rows)
GO
--Create index on the orderdate column
CREATE INDEX ix1 ON dbo.Events(EventDate);
GO
 
--create stored procedure
CREATE OR ALTER PROCEDURE dbo.GetEvents
@OrderDate DATETIME
AS
BEGIN
	DECLARE @now DATETIME = @OrderDate;
	SELECT * FROM dbo.Events
	WHERE EventDate >= @now
	ORDER BY Note DESC;
END
GO

-----------------------------------------------------------------------
--- SQL Server 2016
-----------------------------------------------------------------------

--ensure that the database runs under CL 130 (SQL Server 2016)
ALTER DATABASE TestDb SET COMPATIBILITY_LEVEL = 130;
GO
--ensure that cache is empty
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO


--include Actual Execution Plan
EXEC dbo.GetEvents '20180101'; 
GO 3
/*Result:
Memory Grant is 591 MB for all three executions
*/

-------------------------------------------------------------------------------
--- SQL Server 2017
-------------------------------------------------------------------------------
--ensure that the database runs under CL 140 (SQL Server 2017) and empty cache
ALTER DATABASE TestDb SET COMPATIBILITY_LEVEL = 140;
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

--include Actual Execution Plan
EXEC dbo.GetEvents '20180101'; 
GO 3
/*Result:
Memory Grant is still 591 MB for all three executions
*/

--achieving MG in SQL Server 2017 by creating a fake columnstore index

--create a fake columnstore index
CREATE NONCLUSTERED COLUMNSTORE INDEX ixc ON dbo.Events(id, EventType,EventDate, Note) WHERE id  = -4;
GO

--clear cache
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO


--include Actual Execution Plan
EXEC dbo.GetEvents '20180101'; 
GO 3
/*Result:
Memory Grant
1. execution: 670 MB
2. execution: 2.4 MB
3. execution: 2.4 MB
*/ 

-----------------------------------------------------------------------
--- SQL Server 2019
-----------------------------------------------------------------------
--ensure that the database runs under CL 150 (SQL Server 2019) and empty cache
ALTER DATABASE TestDb SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

--remove the columnstore index
DROP INDEX ixc ON dbo.Events;
GO


--include Actual Execution Plan
EXEC dbo.GetEvents '20180101'; 
GO 3
/*Result:
Memory Grant
1. execution: 662 MB
2. execution: 5.88 MB
3. execution: 5.88 MB
*/ 
--columnstore index in SQL Server 2019 not required!

--cleanup
DROP TABLE IF EXISTS dbo.Events;
GO
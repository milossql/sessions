-------------------------------------------------------------------------------------
-- Intelligent Query Processing - Memory Grant Feedback
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-- Memory Grant Feedback
-------------------------------------------------------------------------------------

USE TestDb;
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
EXEC dbo.GetEvents '20200101'; 
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
EXEC dbo.GetEvents '20200101'; 
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
EXEC dbo.GetEvents '20200101'; 
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
EXEC dbo.GetEvents '20200101'; 
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
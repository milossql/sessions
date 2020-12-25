-------------------------------------------------------------------------------------
-- Intelligent Query Processing - Memory Grant Feedback
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-- Memory Grant Feedback Disabled
-------------------------------------------------------------------------------------

USE TestDb;
GO
EXEC dbo.GetEvents '20200101'; 
EXEC dbo.GetEvents '20180101'; 
GO 32

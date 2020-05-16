-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 6: Common Mistakes - DELETE in Batches
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------
USE TestDb;
GO
--Delete all rows from the Orders table
--in small batches (1000 items per statement)
DECLARE @ProcessedPackage TABLE (	
	id INT NOT NULL PRIMARY KEY CLUSTERED
);

WHILE (1 = 1)
BEGIN 
	INSERT INTO @ProcessedPackage (id)	
	SELECT TOP 1000 id	
	FROM	
		dbo.Orders o	
	WHERE
		orderdate  < '20070101'	
	ORDER BY
		o.id ASC 	

	IF @@ROWCOUNT = 0		
		BREAK;				 	

	DELETE o
	FROM	
		@ProcessedPackage p		
		INNER JOIN dbo.Orders o ON p.id = o.id		

 
	DELETE FROM @ProcessedPackage; 
END
GO


 
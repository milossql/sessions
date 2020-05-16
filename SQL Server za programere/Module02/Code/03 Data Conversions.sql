-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 2: Writing Well-Performed Queries - Data Conversions
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------

---------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------
SET STATISTICS IO ON; --include IO statistics
SET NOCOUNT ON; --do not show affected rows info
--INCLUDE ACTUAL EXECUTION PLAN
GO
USE AdventureWorks2019
GO

-- Create and populate tables dbo.Contacts
DROP TABLE IF EXISTS dbo.Contacts;
GO
SELECT * INTO dbo.Contacts FROM AdventureWorks2019.Person.Person;
--Create clustered index on ContactID and nonclustered on the LastName
CREATE UNIQUE CLUSTERED INDEX PK_Contacts ON dbo.Contacts(BusinessEntityID);
GO
CREATE INDEX ix1 ON dbo.Contacts(LastName);
GO

---------------------------------------------------------------------
--Data Type Conversions
---------------------------------------------------------------------

-- 3.1 nvarchar column and varchar argument - NOTHING happens
SELECT FirstName, LastName FROM dbo.Contacts WHERE LastName ='Atkinson';
GO
SELECT FirstName, LastName FROM dbo.Contacts WHERE LastName = N'Atkinson';
--Result: 50% : 50% 

--Add new column with VARCHAR type, update and index it
ALTER TABLE dbo.Contacts ADD LastName2 VARCHAR(50);
GO
UPDATE dbo.Contacts SET LastName2 = LastName;
GO
CREATE INDEX ix2 ON dbo.Contacts(LastName2);
GO

--VARCHAR column and NVARCHAR argument - CONVERSION needed
SELECT FirstName,LastName2 FROM dbo.Contacts WHERE LastName2 = 'Atkinson';
SELECT FirstName,LastName2 FROM dbo.Contacts WHERE LastName2 = N'Atkinson';


--Result: 5% : 95% (Conversion overhead is significant; non-unicode will be converted to Unicode)
--Logical Reads: 5 vs. 54

--Equivalent to an explicit conversion
SELECT FirstName, LastName2 FROM dbo.Contacts WHERE LastName2 = N'Atkinson';
SELECT FirstName, LastName2 FROM dbo.Contacts WHERE CONVERT(NVARCHAR(50),LastName2)= N'Atkinson';


--Solution: Use the column data type for argument too, or explicitely convert the argument data type to the column data type
SELECT FirstName, LastName2 FROM dbo.Contacts WHERE LastName2 ='Atkinson';
SELECT FirstName, LastName2 FROM dbo.Contacts WHERE LastName2 = CONVERT(VARCHAR(50),N'Atkinson')

--Clean up
DROP INDEX ix2 ON dbo.Contacts;
ALTER TABLE dbo.Contacts DROP COLUMN LastName2;
GO

--conversion penalties
USE PS;
GO
ALTER TABLE dbo.Orders ADD CustId VARCHAR(20);
GO
UPDATE dbo.Orders SET CustId = CustomerId;
GO
CREATE INDEX ix3 ON dbo.Orders(CustId);
GO

SELECT * FROM dbo.Orders WHERE CustId =  989;
SELECT * FROM dbo.Orders WHERE CustId =  '989';

--silent cut--off

DECLARE @mess NVARCHAR(50) =N'Rebuild';
SELECT * FROM sys.messages WHERE text LIKE @mess + '%' 
GO
DECLARE @mess NVARCHAR(50) =N'Rebuilding the log file is not supported for databases containing memory-optimized tables.'
SELECT * FROM sys.messages WHERE text = @mess;
GO
DECLARE @mess NVARCHAR(50) =N'Rebuild log can only specify one file.'
SELECT * FROM sys.messages WHERE text = @mess;
GO

DECLARE @x TINYINT = '1';
SELECT @x + '1';

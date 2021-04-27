-------------------------------------------------------------------------------------
-- Session: Transact-SQL Tips - Data type conversions
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-------------------------------------------------------------------------------------
USE AdventureWorks2019;
GO
SELECT FirstName, LastName FROM Person.Person WHERE LastName ='Atkinson';
SELECT FirstName, LastName FROM Person.Person WHERE LastName = N'Atkinson';
GO
--Result: 50% : 50% 

--Add new column with VARCHAR type, update and index it
ALTER TABLE Person.Person ADD LastName2 VARCHAR(50);
GO
UPDATE Person.Person SET LastName2 = LastName;
GO
CREATE INDEX ix2 ON Person.Person(LastName2);
GO

--VARCHAR column and NVARCHAR argument - CONVERSION needed
SELECT FirstName,LastName2 FROM Person.Person WHERE LastName2 = 'Atkinson';
SELECT FirstName,LastName2 FROM Person.Person WHERE LastName2 = N'Atkinson';
GO
--Equivalent to an explicit conversion
SELECT FirstName, LastName2 FROM Person.Person WHERE LastName2 = N'Atkinson';
SELECT FirstName, LastName2 FROM Person.Person WHERE CONVERT(NVARCHAR(50), LastName2)= N'Atkinson';
GO
DROP INDEX ix2 ON Person.Person;
ALTER TABLE Person.Person DROP COLUMN LastName2;
GO

--large table
SELECT * FROM Orders WHERE CustId = 143
SELECT * FROM Orders WHERE CustId = '143'
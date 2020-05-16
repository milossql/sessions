-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 6: Common Developer Mistakes - Predicate evaluation order
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------

--------------------------------------------
--Predicate evaluation order
--------------------------------------------
--TASK: Get all records from the Address table for the city Tacoma and ZIP 98403
--PostalCode is alphanumeric
--This works
USE AdventureWorks2019;
SELECT * FROM Person.Address 
WHERE City = 'Tacoma' AND PostalCode = 98403;
--(96 row(s) affected)

--This one doesn't work
SELECT * FROM Person.Address 
WHERE City LIKE 'Tacoma' AND  PostalCode =98403;
--Conversion failed when converting the nvarchar value 'K4B 1S2' to data type int.
--There is no guarantee that operation against the City column will be evaluated first!

 --This one works regardless the evaluation order
SELECT * FROM Person.Address 
WHERE City LIKE 'Tacoma' AND  CASE WHEN PostalCode NOT LIKE '%[^0-9]%' THEN PostalCode END = 98403;
--(96 row(s) affected)

--This one works regardless the evaluation order (let's remove the City column)
SELECT * FROM Person.Address 
WHERE  CASE WHEN PostalCode NOT LIKE '%[^0-9]%' THEN PostalCode END = 98403;
--(96 row(s) affected)
SELECT * FROM Person.Address 
WHERE City LIKE 'Tacoma' AND PostalCode = N'98403';

SELECT * FROM Person.Address 
WHERE ISNUMERIC(PostalCode) = 1 AND  PostalCode = 98403;
--(90 row(s) affected)

SELECT ISNUMERIC(',')
SELECT ISNUMERIC('/')
SELECT ISNUMERIC('#')
SELECT ISNUMERIC('+')
SELECT ISNUMERIC('$')
SELECT ISNUMERIC('	')
 SELECT ISNUMERIC('0d2345')

SELECT ISNUMERIC('12e34') 
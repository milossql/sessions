-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 6: Common Developer Mistakes - Distinct
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------

USE AdventureWorks2019;
SELECT 
p.BusinessEntityId, 
FirstName, 
MiddleName, 
LastName, 
Title, 
Suffix, 
EmailPromotion
FROM Person.Person p 
INNER JOIN Person.BusinessEntityAddress pa ON p.BusinessEntityID = pa.BusinessEntityID
INNER JOIN Person.Address a ON a.AddressID = pa.AddressID
WHERE p.BusinessEntityId BETWEEN 2994 AND 2996;

--remove duplicates from the result set by using DISTINCT => WRONG!!!
SELECT DISTINCT 
p.BusinessEntityId, 
FirstName, 
MiddleName, 
LastName, 
Title, 
Suffix, 
EmailPromotion
FROM Person.Person p 
INNER JOIN Person.BusinessEntityAddress pa ON p.BusinessEntityID = pa.BusinessEntityID
INNER JOIN Person.Address a ON a.AddressID = pa.AddressID
WHERE p.BusinessEntityId BETWEEN 2994 AND 2996;

SELECT 
p.BusinessEntityId, 
FirstName, 
MiddleName, 
LastName, 
Title, 
Suffix, 
EmailPromotion
FROM Person.Person p 
WHERE p.BusinessEntityId BETWEEN 2994 AND 2996
AND EXISTS(SELECT 1 FROM Person.BusinessEntityAddress pa 
INNER JOIN Person.Address a ON a.AddressID = pa.AddressID
WHERE p.BusinessEntityID = pa.BusinessEntityID)


 
-- when you expect no duplicates and you got them, you need to communicate this
-- either it is a problem with your query or with the underlying data
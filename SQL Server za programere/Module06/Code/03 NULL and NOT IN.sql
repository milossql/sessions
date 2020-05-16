-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 6: Common Developer Mistakes - NULL and NOT IN
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------

-----------------------------------------------
--NULL and NOT IN
------------------------------------------------

--Create a help table
USE AdventureWorks2019;
DROP TABLE IF EXISTS dbo.Color;
CREATE TABLE dbo.Color (id int, name varchar(30) not null)
INSERT INTO dbo.Color(id,name) VALUES(1,'Black'),(2,'White'), (3,'Purple')
GO
SELECT * FROM dbo.Color;
/*Results
id          name
----------- ------------------------------
1           Black
2           White
3           Purple						*/
------------------------------------------------------------------------------------------------------------
--TASK: List of colors in which there is no products in the Production.Product table
------------------------------------------------------------------------------------------------------------
--NOT IN approach (wrong)
SELECT * FROM AdventureWorks2019.Production.Product
WHERE Color = 'Purple';

SELECT * FROM dbo.Color 
WHERE name NOT IN (SELECT Color FROM AdventureWorks2019.Production.Product)



SELECT * FROM dbo.Color 
WHERE name IN (SELECT Color FROM AdventureWorks2019.Production.Product)
UNION ALL
SELECT * FROM dbo.Color 
WHERE name NOT IN (SELECT Color FROM AdventureWorks2019.Production.Product)


 
/*Results
id          name
----------- ------------------------------					

(0 row(s) affected)							*/

--The list is empty but it should be shown "Purple"!

--IN works correct
SELECT * FROM dbo.Color 
WHERE name IN (NULL,'Black','Blue');
/*Results
id          name
----------- ------------------------------
1           Black							*/

--But NOT IN doesn't due to three value logic
SELECT * FROM dbo.Color 
WHERE name NOT IN (NULL,'Black','Blue');
/*Results
id          name
----------- ------------------------------					

(0 row(s) affected)							*/

--Solution is NOT EXISTS approach 
SELECT *
FROM dbo.Color c
WHERE NOT EXISTS(SELECT 1 FROM AdventureWorks2019.Production.Product p
WHERE p.Color = c.name);          
GO
/*Results
id          name
----------- ------------------------------
3           Purple						*/

SELECT * FROM dbo.Color 
WHERE name NOT IN (SELECT Color FROM AdventureWorks2019.Production.Product
WHERE Color IS NOT NULL)

-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 6: Common Developer Mistakes - NULL and NOT IN
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------

-----------------------------------------------
--DATETIME and BETWEEN
------------------------------------------------
USE AdventureWorks2019;
SELECT * FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '20130101 00:00:00.000' AND '20131231 23:59:59.999'
ORDER BY OrderDate DESC;

--this is the highest date in 2013 for the DATETIME data type
--20131231 23:59:59.997
SELECT CAST('20131231 23:59:59.998' AS DATETIME);
/* 2013-12-31 23:59:59.997 */
SELECT CAST('20131231 23:59:59.999' AS DATETIME);
/* 2014-01-01 00:00:00.000 */

--this is the highest date in 2013 for the DATETIME2 data type
--20131231 23:59:59.9999999
SELECT CAST('20131231 23:59:59.99999994' AS DATETIME2);
/* 2013-12-31 23:59:59.9999999 */
SELECT CAST('20131231 23:59:59.99999995' AS DATETIME2);
/* 2014-01-01 00:00:00.0000000 */

--Therefore, always use the comparison operators >= and <
SELECT * FROM Sales.SalesOrderHeader
WHERE OrderDate >= '20130101' AND OrderDate < '20140101'
ORDER BY OrderDate DESC;


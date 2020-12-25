-------------------------------------------------------------------------------------
-- Intelligent Query Processing - Table Variable Deferred Compilation
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-- Regressions
-------------------------------------------------------------------------------------

USE Statistik;
GO
--issue with this query:
SELECT * FROM A
INNER JOIN B ON A.id = B.pid
WHERE A.pid = 413032
ORDER BY b.C1 DESC;


--a possible workaround - table variable
ALTER DATABASE Statistik SET COMPATIBILITY_LEVEL = 150;
GO

--SELECT * FROM A
--INNER LOOP JOIN B ON A.id = B.pid
--WHERE A.pid = 413032
--ORDER BY b.C1 DESC;


DECLARE @t TABLE(id INT PRIMARY KEY, pid INT, c1 CHAR(100));
INSERT INTO @t
SELECT * FROM A
WHERE A.pid = 413032;
SELECT  * FROM @t A
INNER JOIN B ON A.id = B.pid
ORDER BY b.C1 DESC;
GO

 

--a possible workaround - table variable
ALTER DATABASE Statistik SET COMPATIBILITY_LEVEL = 140;
GO
 
DECLARE @t TABLE(id INT PRIMARY KEY, pid INT, c1 CHAR(100));
INSERT INTO @t
SELECT * FROM A
WHERE A.pid = 413032;
SELECT * FROM @t A
INNER JOIN B ON A.id = B.pid
INNER JOIN B C ON C.pid = B.pid
ORDER BY c.C1 DESC;
GO

ALTER DATABASE Statistik SET COMPATIBILITY_LEVEL = 150;
GO

DECLARE @t TABLE(id INT PRIMARY KEY, pid INT, c1 CHAR(100));
INSERT INTO @t
SELECT * FROM A
WHERE A.pid = 10959455;
SELECT * FROM @t A
INNER JOIN B ON A.id = B.pid
INNER JOIN B C ON C.pid = B.pid
ORDER BY c.C1 DESC
--OPTION (USE HINT('DISABLE_DEFERRED_COMPILATION_TV'));
GO
--workaround is broken!
--ALTER DATABASE SCOPED CONFIGURATION SET DEFERRED_COMPILATION_TV = OFF;
--OPTION (USE HINT('DISABLE_DEFERRED_COMPILATION_TV'));
--ALTER DATABASE SCOPED CONFIGURATION SET DEFERRED_COMPILATION_TV = ON;

 
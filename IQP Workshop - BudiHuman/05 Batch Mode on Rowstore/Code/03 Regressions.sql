-------------------------------------------------------------------------------------
-- Intelligent Query Processing - Batch mode on rowstore
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-- Regression
-------------------------------------------------------------------------------------
ALTER DATABASE Statistik SET COMPATIBILITY_LEVEL = 140;
GO
SELECT * FROM A
INNER JOIN B ON A.id = B.pid
WHERE A.pid IN (413032,2606843,1992195,2485866,10510587)
ORDER BY b.C1  DESC;

 ALTER DATABASE Statistik SET COMPATIBILITY_LEVEL = 150;
GO
SELECT * FROM A
INNER JOIN B ON A.id = B.pid
WHERE A.pid IN (413032,2606843,1992195,2485866,10510587)
ORDER BY b.C1  DESC;

--OPTION (USE HINT('DISALLOW_BATCH_MODE'));;
 
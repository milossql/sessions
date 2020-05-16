-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 3: Common Transact-SQL Tasks - Running Total
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------

--Get Running Total

 

USE StaraSrbija;
GO
--Create table dbo.Orders

IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
CREATE TABLE dbo.Orders(
	id INT IDENTITY(1,1) NOT NULL,
	custid INT NOT NULL,
	orderdate DATETIME NOT NULL,
	amount MONEY NOT NULL,
 CONSTRAINT PK_Orders PRIMARY KEY CLUSTERED (id ASC)
)
GO
-- 3.3 Fill the table
 DECLARE @date_from DATETIME = '20100101';
 DECLARE @date_to DATETIME = '20180101';
 DECLARE @number_of_rows INT = 100000;
 INSERT INTO dbo.Orders(custid,orderdate,amount)
 SELECT 1 + ABS(CHECKSUM(NEWID())) % 1000 AS custid,
(SELECT(@date_from +(ABS(CAST(CAST( NewID() AS BINARY(8) )AS INT))%CAST((@date_to - @date_from)AS INT)))) orderdate,
50 + ABS(CHECKSUM(NEWID())) % 1000 AS amount
FROM dbo.GetNums(@number_of_rows)
ORDER BY 1
GO
 
--Get Running Total
SELECT o.id, o.amount,
(
	SELECT SUM(amount)
	FROM dbo.Orders i
	WHERE i.id <= o.id
) RunnTotal
FROM dbo.Orders o
WHERE o.id <= 100000
ORDER BY o.id;


-- Window Functions Aggregate Function Enhancements
SELECT id, amount, SUM(amount)
OVER(ORDER BY id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) RunnTotal
FROM dbo.Orders o
ORDER BY o.id;

SELECT id, amount, SUM(amount) OVER(ORDER BY id) RunnTotal
FROM dbo.Orders o
ORDER BY o.id;
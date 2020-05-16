-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 6: Common Developer Mistakes - TOP (1)
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------
USE NewDB;
--Create sample table 
DROP TABLE IF EXISTS dbo.Customers;
CREATE TABLE dbo.Customers(
	id INT NOT NULL,
	custname NVARCHAR(50) NOT NULL,
 CONSTRAINT PK_Customers PRIMARY KEY CLUSTERED (id ASC)
)
GO

DROP TABLE IF EXISTS dbo.NextPayment;
CREATE TABLE dbo.NextPayment(
	custid INT NOT NULL,
	amount MONEY NOT NULL,
	details NVARCHAR(100) NULL
)
GO
CREATE CLUSTERED INDEX ixc ON dbo.NextPayment(custid)
GO

--populate the Customers table
INSERT INTO dbo.Customers(id, custname)
SELECT --1 + ABS(CHECKSUM(NEWID())) % 100000 AS custid,
n, 'cust' + CAST(n AS NVARCHAR)
FROM dbo.GetNums(10000)
GO


--populate the NextPayment table
INSERT INTO dbo.NextPayment(custid, amount, details)
SELECT n, 1 + ABS(CHECKSUM(NEWID())) % 1000 AS amount, 'details'
FROM dbo.GetNums(9999)
GO
INSERT INTO dbo.NextPayment(custid, amount, details) VALUES(10000, 10000000, N''),(10000, 5, N'');
GO
SELECT * FROM Customers
SELECT * FROM NextPayment

SELECT c.id, c.custname, 
(
	SELECT p.amount
	FROM dbo.NextPayment p WHERE p.custid = c.id
) x
FROM dbo.Customers c

--
SELECT c.id, c.custname, 
(
	SELECT TOP (1) p.amount
	FROM dbo.NextPayment p WHERE p.custid = c.id
)
FROM dbo.Customers c

SELECT * FROM dbo.NextPayment WHERE custid = 10000;
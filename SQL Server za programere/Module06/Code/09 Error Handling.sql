-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 6: Common Mistakes - Error Handling
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------
USE StaraSrbija;
GO
DROP TABLE IF EXISTS dbo.T1;
CREATE TABLE dbo.T1(id INT PRIMARY KEY);
GO

BEGIN TRAN
	INSERT INTO T1(id) VALUES(1);
	INSERT INTO T1(id) VALUES(1);
COMMIT

SELECT * FROM T1;
SELECT @@TRANCOUNT;
GO


DROP TABLE IF EXISTS dbo.T1;
CREATE TABLE dbo.T1(id INT PRIMARY KEY);
GO

BEGIN TRAN
	INSERT INTO T1(id) VALUES(1);
	PRINT CAST('abc' AS INT)
COMMIT

SELECT * FROM T1;
SELECT @@TRANCOUNT;
GO

DROP TABLE IF EXISTS dbo.T1;
CREATE TABLE dbo.T1(id INT PRIMARY KEY);
GO

BEGIN TRAN
	INSERT INTO T1(id) VALUES(1);
	SELECT 1/0
COMMIT

SELECT * FROM T1;
SELECT @@TRANCOUNT;
GO

BEGIN TRY
SELEC * FROM T1
PRINT 'Šta KK?'
END TRY
BEGIN CATCH
	PRINT 'Štampaj brt'
END CATCH

GO
SELECT * FROM dbo.AmarGile;
PRINT 'Ne znam brt'
GO

SELECT 1/0;
PRINT 'Ne, aj brt sad će i ovo da se odštampa!?'
GO

--XACT_ABORT 
SET XACT_ABORT ON;
DROP TABLE IF EXISTS dbo.T1;
CREATE TABLE dbo.T1(id INT PRIMARY KEY);
GO

BEGIN TRAN
	INSERT INTO T1(id) VALUES(1);
	INSERT INTO T1(id) VALUES(1);
COMMIT

SELECT * FROM T1;
SELECT @@TRANCOUNT;
SET XACT_ABORT OFF;
GO
--use XACT_ABORT ON to instruct statement level exceptions to behave as batch level exceptions


--XACT_ABORT 
SET XACT_ABORT ON;
DROP TABLE IF EXISTS dbo.T1;
CREATE TABLE dbo.T1(id INT PRIMARY KEY);
GO

BEGIN TRAN
	INSERT INTO T1(id) VALUES(1);
	RAISERROR('Svi gresimo, svi gresimo, al ti nisi smela', 16, 1)
COMMIT

SELECT * FROM T1;
SELECT @@TRANCOUNT;
SET XACT_ABORT OFF;
GO
--Raiserror ignores XACT_ABORT

------------------------------------
--TRY/CATCH
------------------------------------
DROP TABLE IF EXISTS dbo.T1;
CREATE TABLE dbo.T1(id INT PRIMARY KEY);
GO

CREATE OR ALTER PROCEDURE dbo.TestProc AS
BEGIN TRY
	BEGIN TRAN
		INSERT INTO T1(id) VALUES(1);
		INSERT INTO T1(id) VALUES(1);
	COMMIT TRAN
END TRY
BEGIN CATCH
   IF @@TRANCOUNT > 0 
		ROLLBACK TRAN;
END CATCH
GO 
EXEC  dbo.TestProc;
SELECT * FROM T1;
SELECT @@TRANCOUNT;
GO
--syntax error
CREATE OR ALTER PROCEDURE dbo.TestProc AS
BEGIN TRY
	BEGIN TRAN
		INSERT INTO T1(id) VALUES(1);
		INSERT C(id) VALUES(1);
		
	COMMIT TRAN
END TRY
BEGIN CATCH
   IF @@TRANCOUNT > 0 
		ROLLBACK TRAN;
END CATCH
GO 
EXEC  dbo.TestProc;
SELECT * FROM T1;
SELECT @@TRANCOUNT;
--ROLLBACK

GO
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
EXEC  dbo.TestProc;
SELECT * FROM T1;
SELECT @@TRANCOUNT;
--ROLLBACK

--Recommendation for error handling in a stored procedure
CREATE OR ALTER PROCEDURE dbo.YourSP 
AS
SET XACT_ABORT ON;
SET NOCOUNT ON;
BEGIN TRY
	--here your code
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRAN;
		;THROW
 END CATCH



-------------------------------------------------------------------------------------
-- Session: Transact-SQL Tips - Window functions vs. APPLY
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------
 
 
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
CREATE TABLE dbo.Users(
id INT NOT NULL,
name NVARCHAR(20) NOT NULL,
CONSTRAINT PK_Users PRIMARY KEY CLUSTERED (id ASC)
);
GO

INSERT INTO dbo.Users(id,name)
SELECT n AS id, 'USER' + CAST(n AS VARCHAR) AS name 
FROM dbo.GetNums(10000)
GO

 
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
CREATE TABLE dbo.Users(
id INT NOT NULL,
name NVARCHAR(20) NOT NULL,
CONSTRAINT PK_Users PRIMARY KEY CLUSTERED (id ASC)
);
GO

INSERT INTO dbo.Users(id,name)
SELECT n AS id, 'USER' + CAST(n AS VARCHAR) AS name 
FROM dbo.GetNums(1000000)
GO

IF OBJECT_ID('dbo.Logins', 'U') IS NOT NULL DROP TABLE dbo.Logins;
CREATE TABLE dbo.Logins(
id INT NOT NULL,
userid INT NOT NULL,
app_id TINYINT NOT NULL,
login_date DATETIME NOT NULL,
CONSTRAINT PK_Logins PRIMARY KEY CLUSTERED (id ASC)
);
GO
CREATE INDEX ix1 ON Logins(userid, login_date desc)
GO
 DECLARE @date_from DATETIME = '20000101';
 DECLARE @date_to DATETIME = '20181031';
INSERT INTO dbo.Logins(id,userid,app_id,login_date)
SELECT n AS id, 
 1 + ABS(CHECKSUM(NEWID())) % 10000 AS userid,
 1 + ABS(CHECKSUM(NEWID())) % 10 AS app_id,
 (SELECT(@date_from +(ABS(CAST(CAST( NewID() AS BINARY(8) )AS INT))%CAST((@date_to - @date_from)AS INT)))) login_date
FROM dbo.GetNums(10000000)
GO

 
IF OBJECT_ID('dbo.Logins2', 'U') IS NOT NULL DROP TABLE dbo.Logins2;
CREATE TABLE dbo.Logins2(
id INT NOT NULL,
userid INT NOT NULL,
app_id TINYINT NOT NULL,
login_date DATETIME NOT NULL,
CONSTRAINT PK_Logins2 PRIMARY KEY CLUSTERED (id ASC)
);
GO
CREATE INDEX ix1 ON Logins2(userid, login_date desc)
GO
 DECLARE @date_from DATETIME = '20000101';
 DECLARE @date_to DATETIME = '20181031';
INSERT INTO dbo.Logins2(id,userid,app_id,login_date)
SELECT n AS id, 
 1 + ABS(CHECKSUM(NEWID())) % 10000 AS userid,
 1 + ABS(CHECKSUM(NEWID())) % 10 AS app_id,
 (SELECT(@date_from +(ABS(CAST(CAST( NewID() AS BINARY(8) )AS INT))%CAST((@date_to - @date_from)AS INT)))) login_date
FROM dbo.GetNums(100000000)
GO
 WITH cte AS
(
	SELECT u.name, l.login_date, l.app_id,
	ROW_NUMBER() OVER(PARTITION BY l.userid ORDER BY l.login_date DESC) rn
	FROM dbo.Users u
	INNER JOIN dbo.Logins0 l
		ON u.id=l.userid
)
SELECT name,login_date,app_id 
FROM cte
WHERE rn = 1;
go
SELECT u.name, l2.login_date, l2.app_id 
FROM dbo.Users u
CROSS APPLY
(
	SELECT TOP 1 l.login_date, l.app_id
	FROM  dbo.Logins0 l
	WHERE u.id=l.userid
	ORDER BY l.login_date DESC
) l2
GO
 WITH cte AS
(
	SELECT u.name, l.login_date, l.app_id,
	ROW_NUMBER() OVER(PARTITION BY l.userid ORDER BY l.login_date DESC) rn
	FROM dbo.Users u
	INNER JOIN dbo.Logins l
		ON u.id=l.userid
)
SELECT name,login_date,app_id 
FROM cte
WHERE rn = 1;
go
SELECT u.name, l2.login_date, l2.app_id 
FROM dbo.Users u
CROSS APPLY
(
	SELECT TOP 1 l.login_date, l.app_id
	FROM  dbo.Logins l
	WHERE u.id=l.userid
	ORDER BY l.login_date DESC
) l2
GO
 WITH cte AS
(
	SELECT u.name, l.login_date, l.app_id,
	ROW_NUMBER() OVER(PARTITION BY l.userid ORDER BY l.login_date DESC) rn
	FROM dbo.Users u
	INNER JOIN dbo.Logins2 l
		ON u.id=l.userid
)
SELECT name,login_date,app_id 
FROM cte
WHERE rn = 1;
go
SELECT u.name, l2.login_date, l2.app_id 
FROM dbo.Users u
CROSS APPLY
(
	SELECT TOP 1 l.login_date, l.app_id
	FROM  dbo.Logins2 l
	WHERE u.id=l.userid
	ORDER BY l.login_date DESC
) l2

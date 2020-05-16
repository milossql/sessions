-------------------------------------------------------------------------------------
-- Workshop: SQL Server for Application Developers
-- Module 6: Common Developer Mistakes - MERGE
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------
USE StaraSrbija;
GO
DROP TABLE IF EXISTS dbo.tabMerge;
CREATE TABLE dbo.tabMerge
(
  id INT  NOT NULL,
  c1 NVARCHAR(50) NOT NULL,
  c2 NVARCHAR(30) NOT NULL,
  c3 NVARCHAR(30) NOT NULL,
  c4 INT NOT NULL
  CONSTRAINT PK_tabMerge PRIMARY KEY(id)
);
GO
--three sessions
BEGIN TRY
  WHILE 1 = 1
  BEGIN
	MERGE INTO dbo.tabMerge AS t
	USING (SELECT CHECKSUM(SYSDATETIME()), N'abc', N'test', 'blah',1)
          AS s(id,c1,c2,c3,c4)
		ON s.id = t.id
	WHEN MATCHED THEN UPDATE
		SET t.c1 = s.c1,
			t.c2 = s.c2,
			t.c3 = s.c3,
			t.c4 = s.c4
    WHEN NOT MATCHED THEN INSERT
      VALUES(s.id, s.c1, s.c2, s.c3, s.c4);
  END;
END TRY
BEGIN CATCH
  ;THROW;
END CATCH;
 
 -- Msg 2627, Level 14, State 1, Line 9
--Violation of PRIMARY KEY constraint 'PK_tabMerge'. Cannot insert duplicate key in object 'dbo.tabMerge'. The duplicate key value is (1639635611).
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
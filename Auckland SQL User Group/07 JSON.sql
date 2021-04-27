-------------------------------------------------------------------------
-- Session: Transact-SQL Tips - Difference between two columns
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-------------------------------------------------------------------------------------
SELECT * FROM sys.databases WHERE database_id = 1
SELECT * FROM sys.databases WHERE database_id = 3

SELECT * FROM sys.databases WHERE database_id = 1 FOR JSON AUTO
SELECT * FROM OPENJSON((SELECT * FROM sys.databases WHERE database_id = 1 FOR JSON AUTO))
SELECT * FROM OPENJSON((SELECT * FROM sys.databases WHERE database_id = 1 FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER))

SELECT 
	mst.[key], 
	mst.[value] AS mst_val, 
	mdl.[value] AS mdl_val
FROM OPENJSON ((SELECT * FROM sys.databases WHERE database_id = 1 FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER)) mst
INNER JOIN OPENJSON((SELECT * FROM sys.databases WHERE database_id = 3 FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER)) mdl
ON mst.[key] = mdl.[key] AND mst.[value] <> mdl.[value];


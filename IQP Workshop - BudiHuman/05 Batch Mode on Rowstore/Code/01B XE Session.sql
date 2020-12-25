CREATE EVENT SESSION BMH ON SERVER 
ADD EVENT sqlserver.batch_mode_heuristics(
    ACTION(sqlserver.database_name, sqlserver.sql_text))
ADD TARGET package0.event_file (SET filename = N'BMH')
WITH (MAX_DISPATCH_LATENCY=1 SECONDS)
GO

ALTER EVENT SESSION BMH ON SERVER STATE = start;  
GO  

CREATE EVENT SESSION MGF ON SERVER 
ADD EVENT sqlserver.memory_grant_feedback_loop_disabled(
    ACTION(sqlserver.database_name, sqlserver.sql_text)),
ADD EVENT sqlserver.memory_grant_updated_by_feedback(
    ACTION(sqlserver.database_name,sqlserver.sql_text)),
ADD EVENT sqlserver.spilling_report_to_memory_grant_feedback(
    ACTION(sqlserver.database_name,sqlserver.sql_text))
ADD TARGET package0.event_file (SET filename = N'BMH')
WITH (MAX_DISPATCH_LATENCY=1 SECONDS)
GO

ALTER EVENT SESSION MGF ON SERVER STATE = start;  
GO  

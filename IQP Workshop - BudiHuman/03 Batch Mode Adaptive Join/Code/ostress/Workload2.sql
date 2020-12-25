USE WideWorldImporters
GO
EXEC dbo.GetOrderDetails 36;
DECLARE @I INT = 0
WHILE @I < 50
BEGIN
	EXEC dbo.GetOrderDetails 112;
	SET @I+=1;
END
GO
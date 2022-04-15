 
USE TSQLTips;
GO
DECLARE @CustId INT = 726564;
SELECT 
	Id,
	CustomerId,
	DATEADD(day, 7, OrderDate) AS ShipDate,
	dbo.MyScalarFunctionToGetYear(OrderDate) AS OrderYear,
	CAST(Amount AS DECIMAL(10,2)) AS Amount,
	Other,
	CASE WHEN Status = 1 THEN 'OK' ELSE 'Not OK' END AS StatusMessage

FROM dbo.Orders WHERE Custid = @CustId 
GO


SELECT * FROM dbo.Orders WHERE Custid = 726564
GO
SELECT * FROM dbo.Orders WHERE Custid = '726564'
GO

SELECT * FROM dbo.Orders WHERE CustomerId = 726564
GO
SELECT * FROM dbo.Orders WHERE CustomerId = '726564'
GO

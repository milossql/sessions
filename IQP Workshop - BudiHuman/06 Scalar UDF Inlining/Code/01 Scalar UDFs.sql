-------------------------------------------------------------------------------------
-- Intelligent Query Processing - Scalar UDFs
-- Milos Radivojevic, Data Platform MVP, bwin, Austria
-- E: milos.radivojevic@chello.at
-- W: https://milossql.wordpress.com/
-------------------------------------------------------------------------------------
USE TestDb;
GO
CREATE OR ALTER FUNCTION dbo.TestFunction(
@Quantity INT, @UnitPrice DECIMAL(10,2)) 
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @Ret VARCHAR(20) = '';
    --DECLARE @Amount  DECIMAL(10,2) =  @Quantity * @UnitPrice;
    IF  @Quantity * @UnitPrice >= 1000
        SET @Ret = 'TOP 1000'
    RETURN @Ret;
END
GO

ALTER DATABASE TestDb SET COMPATIBILITY_LEVEL = 140;
GO
SELECT *, dbo.TestFunction(Quantity,UnitPrice) ItemStatus FROM dbo.OrderDetails;
GO

SELECT *, CASE WHEN Quantity*UnitPrice >= 1000 THEN 'TOP 1000' ELSE '' END
 ItemStatus FROM dbo.OrderDetails;
GO
  
CREATE OR ALTER FUNCTION dbo.TestFunction_inl(
@Quantity INT, @UnitPrice DECIMAL(10,2)) 
RETURNS TABLE
AS
RETURN
(
    SELECT  CASE WHEN @Quantity * @UnitPrice>= 1000
     THEN 'TOP 1000'
	 ELSE ''
	 END AS ItemStatus
)
GO
SELECT *, x.ItemStatus 
FROM dbo.OrderDetails
OUTER APPLY(
SELECT ItemStatus FROM dbo.TestFunction_inl(Quantity,UnitPrice)

) x;
GO


SELECT *, CASE WHEN Quantity*UnitPrice >= 1000 THEN 'TOP 1000' ELSE '' END
  ItemStatus FROM dbo.OrderDetails;
  GO
  SELECT *, dbo.GetOrderItemStatus(Quantity,UnitPrice) ItemStatus FROM dbo.OrderDetails;
GO
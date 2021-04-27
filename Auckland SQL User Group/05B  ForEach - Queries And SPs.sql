
--Create Procs
CREATE OR ALTER PROCEDURE dbo.uspGetCustomers
@Country TINYINT
AS
BEGIN
    SELECT custid
    FROM dbo.Customers
    WHERE country = @Country
	ORDER BY custid;
END
GO 
CREATE OR ALTER PROCEDURE dbo.uspGetTop2OrdersForCustomer
@CustID INT
AS
BEGIN
	SELECT TOP (2) *
    FROM dbo.Orders
    WHERE custid = @CustID
    AND orderdate >= '20180101'
    ORDER BY orderdate DESC, id DESC;
END
GO
CREATE OR ALTER PROCEDURE dbo.uspGetOrdersForCustomers
@Country TINYINT
AS
BEGIN
	WITH cte AS
	(
		SELECT o.*,
		ROW_NUMBER() OVER(PARTITION BY o.custid ORDER BY o.orderdate DESC, o.id DESC) rn
		FROM dbo.Customers c
		INNER JOIN dbo.Orders o ON c.custid = o.custid
		WHERE orderdate >= '20180101'
		AND country = @Country
	)
	 SELECT id, custid, orderdate, amount FROM cte
	 WHERE rn < 3 AND amount >= 1000
	 ORDER BY custid, orderdate DESC;
END
GO
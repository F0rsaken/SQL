-- select klient�w, posegregowanych po najcz�ciaj korzystaj�cych
CREATE VIEW V_MostFrequentClients 
AS
	SELECT TOP 10 c.ClientName, c.ClientSurname, COUNT (*) AS Frequency
	FROM ClientReservations as cr
	INNER JOIN Clients AS c 
			ON cr.ClientID = c.ClientID
	WHERE cr.IsCancelled = 0
	GROUP BY cr.ClientID, c.ClientName, c.ClientSurname
	ORDER BY Frequency DESC
GO 

-- select klient�w, posegregowanych po tych, kt�rzy najwi�cej zap�acili
CREATE VIEW V_MostProfitableClients
AS
	SELECT TOP 10 c.ClientName, c.ClientSurname, SUM(p.FineAssessed) as TotalProfit
	FROM Payments as p
	INNER JOIN ClientReservations as cr
			ON p.PaymentID = cr.ClientReservationID
	INNER JOIN Clients as c
			ON cr.ClientID = c.ClientID
	WHERE cr.IsCancelled = 0
	GROUP BY cr.ClientID, c.ClientName, c.ClientSurname
	ORDER BY TotalProfit DESC
GO
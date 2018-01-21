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

-- nieopłacone rezerwacje nieaktywne
CREATE VIEW V_UnpayedCancelledReservations
AS
	SELECT conf.ConferenceName, c.ClientName
	FROM Payments p
	JOIN ClientReservations cr
	ON cr.ClientReservationID = p.PaymentID
	JOIN Clients c
	ON c.ClientID = cr.ClientID
	JOIN Conferences conf
	ON conf.ConferenceID = cr.ConferenceID
	WHERE p.FineAssessed < p.FinePaid AND cr.IsCancelled = 1
GO

-- nieopłacone rezerwacje wciąż aktywne
CREATE VIEW V_UnpayedNotCancelledReservations
AS
	SELECT conf.ConferenceName, c.ClientName, (p.FineAssessed - p.FinePaid) as Difference
	FROM Payments p
	JOIN ClientReservations cr
	ON cr.ClientReservationID = p.PaymentID
	JOIN Clients c
	ON c.ClientID = cr.ClientID
	JOIN Conferences conf
	ON conf.ConferenceID = cr.ConferenceID
	WHERE p.FineAssessed < p.FinePaid AND cr.IsCancelled = 0
GO

--nadpłacone rezerwacje
CREATE VIEW V_OverPayedReservations
AS
	SELECT conf.ConferenceName, c.ClientName, (p.FinePaid - p.FineAssessed) as Difference
	FROM Payments p
	JOIN ClientReservations cr
	ON cr.ClientReservationID = p.PaymentID
	JOIN Clients c
	ON c.ClientID = cr.ClientID
	JOIN Conferences conf
	ON conf.ConferenceID = cr.ConferenceID
	WHERE p.FinePaid > p.FineAssessed
GO

-- opłacone rezerwacje, przed konferencją
CREATE VIEW V_PayedReservations
AS
	SELECT conf.ConferenceName, c.ClientName
	FROM Payments p
	JOIN ClientReservations cr
	ON cr.ClientReservationID = p.PaymentID
	JOIN Clients c
	ON c.ClientID = cr.ClientID
	JOIN Conferences conf
	ON conf.ConferenceID = cr.ConferenceID
	WHERE p.FinePaid = p.FineAssessed AND conf.StartDate > CONVERT(date, GETDATE())
GO

-- lista anulowanych rezerwacji na konferencje
CREATE VIEW V_CancelledConferencesReseravtions
AS
	SELECT c.ClientID, c.ClientName, c.ClientSurname, conf.ConferenceID, conf.ConferenceName 
	FROM Clients AS c
	INNER JOIN ClientReservations AS cr
		ON c.ClientID = cr.ClientID
	INNER JOIN Conferences AS conf
		ON cr.ConferenceID = conf.ConferenceID
	WHERE cr.IsCancelled = 1
GO

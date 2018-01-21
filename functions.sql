-- lista warsztatów w zależności od konferencji
CREATE FUNCTION F_ShowWorkshops
    (
        @ConferenceID int
    )
    RETURNS TABLE
AS
RETURN
    SELECT WorkshopID, WorkshopName
    FROM Workshops
    WHERE ConferenceID = @ConferenceID
GO

-- lista uczestników danej konferencji
CREATE FUNCTION F_ConferenceParticipants
    (
        @ConferenceID int
    )
    RETURNS TABLE
AS
RETURN
    SELECT DISTINCT sub.ParticipantID, p.Name, p.Surname
    FROM (
        SELECT pr.ParticipantID
        FROM Conferences c
            JOIN ClientReservations cr
            on c.ConferenceID = cr.ConferenceID
            JOIN DaysReservations dr
            on dr.ClientReservationID = cr.ClientReservationID
            JOIN ParticipantReservations pr
            on pr.DayReservationID = dr.DayReservationID
        WHERE c.ConferenceID = @ConferenceID AND pr.IsCancelled = 0
    ) as sub
	JOIN Participants p
	ON p.ParticipantID = sub.ParticipantID
GO

-- tworzenie identyfikatorów
CREATE FUNCTION F_CreatePeopleIdentifiers
    (
        @ConferenceID int
    )
    RETURNS TABLE
AS
RETURN
    SELECT DISTINCT sub.ParticipantID, p.Name, p.Surname, c.ClientName
    FROM (
        SELECT pr.ParticipantID, cr.ClientID
        FROM Conferences c
            JOIN ClientReservations cr
            on c.ConferenceID = cr.ConferenceID
            JOIN DaysReservations dr
            on dr.ClientReservationID = cr.ClientReservationID
            JOIN ParticipantReservations pr
            on pr.DayReservationID = dr.DayReservationID
        WHERE c.ConferenceID = @ConferenceID AND pr.IsCancelled = 0
    ) as sub
    JOIN Participants p
    ON p.ParticipantID = sub.ParticipantID
    JOIN Clients c
    ON c.ClientID = sub.ClientID
    WHERE c.IsPrivate = 0
	UNION
	SELECT DISTINCT sub.ParticipantID, p.Name, p.Surname, "isPrivate"
	FROM (
        SELECT pr.ParticipantID, cr.ClientID
        FROM Conferences c
            JOIN ClientReservations cr
            on c.ConferenceID = cr.ConferenceID
            JOIN DaysReservations dr
            on dr.ClientReservationID = cr.ClientReservationID
            JOIN ParticipantReservations pr
            on pr.DayReservationID = dr.DayReservationID
        WHERE c.ConferenceID = @ConferenceID AND pr.IsCancelled = 0
    ) as sub
    JOIN Participants p
    ON p.ParticipantID = sub.ParticipantID
    JOIN Clients c
    ON c.ClientID = sub.ClientID
    WHERE c.IsPrivate = 1
GO

-- wszystkie stawki cenowe dla konferencji
CREATE FUNCTION F_ShowPrices
    (
        @ConferenceID int
    )
    RETURNS TABLE
AS
RETURN
    SELECT p.PriceValue, p.PriceDate
    FROM PriceList p
    WHERE p.ConferenceID = @ConferenceID
GO

-- cena od konferencji w zaleźności od daty
CREATE FUNCTION F_GetCurrentPrice
    (
        @ConferenceID int,
        @CurrentDate date
    )
    RETURNS money
AS
BEGIN
    DECLARE @Price money;
    SELECT TOP 1 @Price = PriceValue
    FROM PriceList
    WHERE @ConferenceID = ConferenceID AND @CurrentDate <= PriceDate
    ORDER BY PriceDate;
    RETURN @Price
END
GO

--lista klientów na konferecje, którzy jeszcze nie zajeli wszystkich miejsc
CREATE FUNCTION F_ClientsWithUnusedPlaces
    (
        @ConferenceID int
    )
    RETURNS TABLE
 AS
 RETURN
    SELECT dr.ConferenceDay, c.ClientName, (dr.NormalReservations + dr.StudentsReservations - (
		SELECT COUNT(*)
		FROM ParticipantReservations pr
		WHERE pr.DayReservationID = dr.DayReservationID
	)) as FreePlaces
    FROM DaysReservations dr
	JOIN ClientReservations cr
	ON cr.ClientReservationID = dr.ClientReservationID
	JOIN Clients c
	ON c.ClientID = cr.ClientID
	WHERE cr.ConferenceID = @ConferenceID AND (dr.NormalReservations + dr.StudentsReservations - (
		SELECT COUNT(*)
		FROM ParticipantReservations pr
		WHERE pr.DayReservationID = dr.DayReservationID
	)) != 0
GO

--lista uczestników na każdy dzień konferencji
CREATE FUNCTION F_ParticipantsListForConferenceDay
	(
		@ConferenceID int,
		@ConferenceDay int
	)
	RETURNS TABLE
AS
	RETURN
		SELECT c.ConferenceName, dr.ConferenceDay, p.*
		FROM Participants AS p
		INNER JOIN ParticipantReservations as pr 
				ON p.ParticipantID = pr.ParticipantID
		INNER JOIN DaysReservations AS dr
				ON pr.DayReservationID = dr.DayReservationID
		INNER JOIN ClientReservations AS cr 
				ON cr.ClientReservationID = dr.ClientReservationID
		INNER JOIN Conferences AS c 
				ON cr.ConferenceID = c.ConferenceID
		WHERE c.ConferenceID = @ConferenceID 
				AND dr.ConferenceDay = @ConferenceDay
				AND pr.IsCancelled = 0
GO

-- lista uczestników na każdy warsztat
CREATE FUNCTION F_ParticipantsListForWorkshop
	(
		@WorkshopID int
	)
	RETURNS TABLE
AS
	RETURN
		SELECT w.WorkshopID, w.WorkshopName, p.*
		FROM Participants AS p
		INNER JOIN ParticipantReservations AS pr
				ON p.ParticipantID = pr.ParticipantID
		INNER JOIN ParticipantWorkshops AS pw
				ON pr.ParticipantReservationID = pw.ParticipantReservationID
		INNER JOIN Workshops AS w 
				ON w.WorkshopID = pw.WorkshopID
		WHERE w.WorkshopID = @WorkshopID 
				AND pw.IsCancelled = 0
GO

-- każdy dzień konferencji z liczbą wolnych i zarezerwowanych miejsc
CREATE FUNCTION F_FreeAndReservedPlacesForConference
	(
		@ConferenceID  int
	)
	RETURNS TABLE
AS
	RETURN
		SELECT c.ConferenceName,
			   dr.ConferenceDay,
			   c.Places,
			   c.Places - SUM(dr.NormalReservations + dr.StudentsReservations) AS FreePlaces,
			   SUM(dr.NormalReservations + dr.StudentsReservations) AS ReservedPlaces
			   
		FROM Conferences AS c
		INNER JOIN  ClientReservations AS cr
				ON c.ConferenceID = cr.ConferenceID
		INNER JOIN DaysReservations AS dr
				ON cr.ClientReservationID = dr.ClientReservationID
		WHERE c.ConferenceID = @ConferenceID
				AND dr.IsCancelled = 0
		GROUP BY dr.ConferenceDay, c.Places, c.ConferenceName
GO

-- lista warsztatów z liczbą wolnych i zarezerwowanych miejsc
CREATE FUNCTION F_FreeAndReservedPlacesForWorkshop
	(
		@WorkshopID  int
	)
	RETURNS TABLE
AS
	RETURN
		SELECT w.WorkshopID,
			   w.WorkshopName,
			   w.Places,
			   SUM(wr.NormalReservations) AS ReservedPlaces
		FROM Workshops AS w
		INNER JOIN WorkshopsReservations AS wr
				ON w.WorkshopID = wr.WorkshopID
		WHERE wr.IsCancelled = 0
		AND w.WorkshopID = @WorkshopID
		GROUP BY w.WorkshopID, w.Places, w.WorkshopName
GO

-- opłaty klienta nieuregulowane
CREATE FUNCTION F_NonregulatedPaymentsByClientID
(
		@ClientID  int
	)
	RETURNS TABLE
AS
	RETURN
		SELECT c.ClientID, c.ClientName, c.ClientSurname, conf.ConferenceID, conf.ConferenceName, p.FineAssessed, p.FinePaid
		FROM Clients AS c
		INNER JOIN ClientReservations AS cr
				ON c.ClientID = cr.ClientID
		INNER JOIN Payments AS p
				ON cr.ClientReservationID = p.PaymentID
		INNER JOIN Conferences AS conf
				ON cr.ConferenceID = conf.ConferenceID
		WHERE cr.IsCancelled = 0
				AND p.FinePaid < p.FineAssessed
				AND c.ClientID = @ClientID
GO

-- opłaty klienta uregulowane
CREATE FUNCTION F_RegulatedPaymentsByClientID
	(
		@ClientID int
	)
	RETURNS TABLE
AS 
	RETURN 
		SELECT c.ClientID, c.ClientName, c.ClientSurname, conf.ConferenceID, conf.ConferenceName, p.FineAssessed, p.FinePaid
		FROM Clients AS c
		INNER JOIN ClientReservations AS cr
				ON c.ClientID = cr.ClientID
		INNER JOIN Payments AS p
				ON cr.ClientReservationID = p.PaymentID
		INNER JOIN Conferences AS conf
				ON cr.ConferenceID = conf.ConferenceID
		WHERE c.ClientID = @ClientID 
				AND cr.IsCancelled = 0
				AND p.FineAssessed <= FinePaid
GO

-- wszystkie opłaty klienta
CREATE FUNCTION F_AllPaymentsByClientID
	(
		@ClientID int
	)
	RETURNS TABLE
AS 
	RETURN 
		SELECT c.ClientID, c.ClientName, c.ClientSurname, conf.ConferenceID, conf.ConferenceName, p.FineAssessed, p.FinePaid
		FROM Clients AS c
		INNER JOIN ClientReservations AS cr
				ON c.ClientID = cr.ClientID
		INNER JOIN Payments AS p
				ON cr.ClientReservationID = p.PaymentID
		INNER JOIN Conferences AS conf
				ON cr.ConferenceID = conf.ConferenceID
		WHERE c.ClientID = @ClientID 
				AND cr.IsCancelled = 0
GO

-- rezerwacje klienta
CREATE FUNCTION F_ClientReservationsHistory
	(
		@ClientID int
	)
	RETURNS TABLE
AS 
	RETURN 
		SELECT c.ClientID, c.ClientName, c.ClientSurname, cr.ConferenceID, cr.IsCancelled, conf.ConferenceName
		FROM Clients AS c
		INNER JOIN ClientReservations AS cr 
				ON c.ClientID = cr.ClientID
		INNER JOIN Conferences AS conf
				ON cr.ConferenceID = conf.ConferenceID
		WHERE c.ClientID = @ClientID
GO


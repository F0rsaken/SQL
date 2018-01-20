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
-- CREATE FUNCTION F_ClientsWithUnusedPlaces
--     (
--         @ConferenceID
--     )
--     RETURNS TABLE
-- AS
-- RETURN
--     SELECT
--     FROM ClientReservations
--     JOIN Clients c
--     ON
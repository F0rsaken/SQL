DECLARE @Iterator INT,
    @WorkshopIterator INT,
    @ConferenceID INT

SET @Iterator = 1

WHILE @Iterator IN
    (
        SELECT DayReservationID 
        FROM DaysReservations
    )
BEGIN

    SET @ConferenceID = (
        SELECT ConferenceID
        FROM ClienReservations cr
        JOIN DaysReservations dr ON dr.ClientReservationID = cr.ClientReservationID
        WHERE @Iterator = dr.DayReservationID
    )
    
    SET @WorkshopIterator = (
        SELECT TOP 1 WorkshopID
        FROM Workshops
        WHERE ConferenceID = @ConferenceID
        ORDER BY WorkshopID
    )

    WHILE @WorkshopIterator IN
        (
            SELECT WorkshopID
            FROM Workshops
            WHERE ConferenceID = @ConferenceID
        )
    BEGIN
        EXEC P_AddReservationForWorkshop
            @DayReservationID = @Iterator,
            @WorkshopID = @WorkshopIterator,
            @NormalReservations = 10
        
        SET @WorkshopIterator += 1
    END

    SET @Iterator += 1

END
GO
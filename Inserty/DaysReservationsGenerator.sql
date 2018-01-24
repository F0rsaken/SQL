use mmandows_a
GO

DECLARE @Iterator INT,
    @NumberOfDays INT,
    @ConferenceID INT,
    @DayIterator INT,
    @NormalRes INT,
    @StudentRes INT

SET @Iterator = 1

WHILE @Iterator IN
    (
        SELECT ClientReservationID
        FROM ClientReservations
    )
BEGIN

    SET @ConferenceID = (
        SELECT ConferenceID FROM ClientReservations WHERE ClientReservationID = @Iterator
    )

    SET @NumberOfDays = DATEDIFF(day, (
        SELECT StartDate FROM Conferences WHERE ConferenceID = @ConferenceID
    ), (
        SELECT EndDate FROM Conferences WHERE ConferenceID = @ConferenceID
    )) + 1
    SET @DayIterator = 1
    WHILE @DayIterator <= @NumberOfDays
    BEGIN
        SET @NormalRes = CONVERT(INT, RAND()*10 + 20)
        SET @StudentRes = CONVERT(INT, RAND()*10 + 20)

        EXEC P_AddReservationForConferenceDay
            @ClientReservationID = @Iterator,
            @ConferenceDay = @DayIterator,
            @NormalReservations = @NormalRes,
            @StudentReservations = @StudentRes


        SET @DayIterator += 1
    END

    SET @Iterator += 1
END
GO
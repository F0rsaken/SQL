USE mmandows_a
DECLARE @Iterator INT,
    @DayIterator INT,
    @WorkshopIterator INT,
    @NumberOfDays INT,
    @ConferenceDay INT,
    @WorkshopStart TIME,
    @WorkshopEnd TIME,
    @Places INT,
    @WorkshopFee MONEY

SET @Iterator = 1

WHILE @Iterator IN
    (
        SELECT ConferenceID
        FROM dbo.Conferences
    )
BEGIN

    SET @NumberOfDays = DATEDIFF(day, (
        SELECT StartDate FROM Conferences WHERE ConferenceID = @Iterator
    ), (
        SELECT EndDate FROM Conferences WHERE ConferenceID = @Iterator
    )) + 1

    SET @DayIterator = 1

    WHILE @DayIterator <= @NumberOfDays
    BEGIN

        SET @WorkshopStart = '8:00'
        SET @WorkshopEnd = '10:00'
        SET @WorkshopIterator = 0

        WHILE @WorkshopIterator < 4
        BEGIN
            SET @Places = CONVERT(INT, RAND()*10 + 20)
            SET @WorkshopFee = ROUND( CONVERT(MONEY, RAND()*20 + 20), 2)

            EXEC P_AddWorkshop  @ConferenceID = @Iterator,
                                @ConferenceDay = @DayIterator,
                                @WorkshopName = 'A',
                                @Places = @Places,
                                @WorkshopFee = @WorkshopFee,
                                @WorkshopStart = @WorkshopStart,
                                @WorkshopEnd = @WorkshopEnd

            SET @WorkshopStart = DATEADD (minute, 120, @WorkshopStart)
            SET @WorkshopEnd = DATEADD (minute, 120, @WorkshopEnd)
            SET @WorkshopIterator += 1
        END

        SET @DayIterator += 1
    END

    SET @Iterator += 1
END
GO

DECLARE @ParticipantReservationID1 INT,
    @ParticipantReservationID2 INT,
    @WorkshopID INT,
    @DayReservationID INT

SET @WorkshopID = 1

WHILE @WorkshopID IN
    (
        SELECT WorkshopID
        FROM Workshops
    )
BEGIN

    SET @DayReservationID = (
        SELECT TOP 1 DayReservationID
        FROM WorkshopsReservations
        WHERE WorkshopID = @WorkshopID
        ORDER BY DayReservationID
    )

    WHILE @DayReservationID IN (
        SELECT DayReservationID
        FROM WorkshopsReservations
        WHERE WorkshopID = @WorkshopID
    )
    BEGIN
        SET @ParticipantReservationID1 = (
            SELECT TOP 1 ParticipantReservationID
            FROM ParticipantReservations
            WHERE DayReservationID = @DayReservationID
            ORDER BY ParticipantReservationID
        )

        SET @ParticipantReservationID2 = (
            SELECT TOP 1 ParticipantReservationID
            FROM ParticipantReservations
            WHERE DayReservationID = @DayReservationID
            ORDER BY ParticipantReservationID DESC
        )

        EXEC P_AddParticipantForWorkshop
            @ParticipantReservationID = @ParticipantReservationID1,
            @WorkshopID = @WorkshopID

        EXEC P_AddParticipantForWorkshop
            @ParticipantReservationID = @ParticipantReservationID2,
            @WorkshopID = @WorkshopID

        SET @DayReservationID += 1

    END

    SET @WorkshopID += 1

END
GO
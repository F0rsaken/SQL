AS

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

AS
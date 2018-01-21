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
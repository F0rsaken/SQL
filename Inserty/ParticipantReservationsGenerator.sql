-- 3340
-- 1000

DECLARE @PartID	INT
	= 1
DECLARE @DayID	INT
	= 1
DECLARE @NormalRes	INT
	= 0
DECLARE @StudentRes	INT
	= 0
DECLARE @StudentCard	INT

WHILE @DayID IN
	(
		SELECT DayReservationID 
		FROM dbo.DaysReservations
	)
BEGIN
	
	SET @NormalRes = 
		(
			SELECT NormalReservations
			FROM dbo.DaysReservations
			WHERE DayReservationID = @DayID
		)
	SET @StudentRes =
		(
			SELECT StudentsReservations
			FROM dbo.DaysReservations
			WHERE DayReservationID = @DayID
		)

	WHILE @NormalRes > 0
	BEGIN

		IF @PartID > 1000
		BEGIN
			SET @PartID = 1
		END
        
		EXEC dbo.P_AddParticipantForConferenceDay @ParticipantID = @PartID,             -- int
			                                          @DayReservationID = @DayID,          -- int
			                                          @StudentCard = NULL,               -- int
			                                          @StudentCardDate = NULL -- date
		SET @PartID = @PartID +1
		SET @NormalRes = @NormalRes - 1	
	
	END	

	WHILE @StudentRes> 0
	BEGIN

		IF @PartID > 1000
		BEGIN
			SET @PartID = 1
		END
        
		SET @StudentCard = RAND()*1000000
		EXEC dbo.P_AddParticipantForConferenceDay @ParticipantID = @PartID,             -- int
			                                          @DayReservationID = @DayID,          -- int
			                                          @StudentCard = @StudentCard,               -- int
			                                          @StudentCardDate = '2018-05-17' -- date
		SET @PartID = @PartID +1
		SET @StudentRes = @StudentRes - 1	
	
	END	


	SET @DayID = @DayID + 1

END
GO
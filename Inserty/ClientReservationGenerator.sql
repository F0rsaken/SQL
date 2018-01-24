DECLARE @i10 	int	
	= 1

DECLARE @clientID	INT
	= 1

DECLARE @confID	INT
	= 1

WHILE @confID IN 
	(
		SELECT ConferenceID 
		FROM dbo.Conferences
	)
BEGIN
		WHILE @i10 <= 10
		BEGIN	

			DECLARE @ConferenceStartDate	DATE
				= (
						SELECT	StartDate 
						FROM dbo.Conferences
						WHERE ConferenceID = @confID
				  )

			DECLARE @ReservationDate	DATE
				= DATEADD(MONTH, -2, @ConferenceStartDate)

			INSERT INTO dbo.ClientReservations
			(
				ConferenceID,
				ClientID,
				ReservationDate,
				IsCancelled
			)
			VALUES
			(   @confID,         -- ConferenceID - int
				@clientID,         -- ClientID - int
				@ReservationDate, -- ReservationDate - date
				0 -- IsCancelled - bit
			)

			SET @clientID = @clientID + 1
			SET @i10 = @i10 + 1	
		END

	SET @i10 = 1
	SET @confID = @confID + 1

END	
GO

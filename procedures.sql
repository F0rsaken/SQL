-- dodawanie konferencji
CREATE PROCEDURE P_AddConference
	@ConferenceName varchar(50),
	@StartDate		date,
	@EndDate		date,
	@Places			int,
	@Discount		float(10)
AS
BEGIN
	INSERT INTO Conferences 
		VALUES
		(
			@ConferenceName,
			@StartDate,
			@EndDate,
			@Places,
			@Discount
		)
END
GO

-- dodawanie warsztatu
CREATE PROCEDURE P_AddWorkshop
	@ConferenceID		int,
	@ConferenceDay		int, 
	@WorkshopName		varchar(50),
	@Places				int, 
	@WorkshopFee		money,
	@WorkshopStart		time, 
	@WorkshopEnd		time 
AS
BEGIN
	INSERT INTO Workshops
		VALUES
		(
			@ConferenceID,
			@ConferenceDay, 
			@WorkshopName,
			@Places, 
			@WorkshopFee,
			@WorkshopStart, 
			@WorkshopEnd
		)
END 
GO

--EXEC P_AddWorkshop @ConferenceID = 4, @ConferenceDay = 1, @WorkshopName = 'WorkshopProcedureTest', @Places = 35, @WorkshopFee = 20, @WorkshopStart = '9:00', @WorkshopEnd = '10:30';

-- dodawanie progu cenowego
CREATE PROCEDURE P_AddPriceToConferencePriceList
	@ConferenceID	int,
	@PriceValue		money,
	@PriceDate		date 
AS
BEGIN
	IF NOT EXISTS 
		(
			SELECT * 
			FROM Conferences 
			WHERE ConferenceID = @ConferenceID
		)
	BEGIN
		RAISERROR ('Nie ma konferencji o takim ID.', -1, -1)
		RETURN
	END

	INSERT INTO PriceList
		VALUES
		(
			@ConferenceID,
			@PriceValue,
			@PriceDate
		)
END
GO

-- usuwanie progu cenowego
CREATE PROCEDURE P_DeletePriceFromConferencePriceList
	@PriceID int
AS 
BEGIN
	IF NOT EXISTS 
		(
			SELECT * 
			FROM PriceList
			WHERE PriceID = @PriceID
		)
	BEGIN
		RAISERROR ('Nie ma progu cenowego o podanym ID', -1, -1)
		RETURN
	END
	DELETE PriceList
		WHERE PriceID = @PriceID 
END
GO

-- EXEC P_AddPriceToConferencePriceList @ConferenceID = 4, @PriceValue = 200, @PriceDate = '2001-04-13';
-- EXEC P_DeletePriceFromConferencePriceList @PriceID = 16;

-- anulowanie rezerwacji na dzien konferencji
CREATE PROCEDURE P_CancelDayReservation
	@DayReservationID int
AS
BEGIN
	IF NOT EXISTS
		(
			SELECT * FROM DaysReservations WHERE DayReservationID = @DayReservationID
		)
	BEGIN
		RAISERROR ('Nie istnieje taki dzień', -1, -1)
	END

	IF (
		SELECT IsCancelled FROM DaysReservations WHERE DayReservationID = @DayReservationID
		) = 1
	BEGIN
		RAISERROR ('Rezerwacja jest już anulowana', -1, -1)
	END
	
	BEGIN
		UPDATE DaysReservations
		SET IsCancelled = 1
		WHERE DayReservationID = @DayReservationID

		UPDATE ParticipantReservations
		SET IsCancelled = 1
		WHERE DayReservationID = @DayReservationID
		
		UPDATE WorkshopsReservations
		SET IsCancelled = 1
		WHERE DayReservationID = @DayReservationID

		-- update participantworkshops
	END
END	
GO
-- EXEC P_AddPriceToConferencePriceList @ConferenceID = 4, @PriceValue = 200, @PriceDate = '2001-04-13';
-- EXEC P_DeletePriceFromConferencePriceList @PriceID = 16; 

-- zmiana informacji o konferencji w tym ilosci miejsc 
CREATE PROCEDURE P_ChangeConferenceDetails
	@ConferenceID	int,
	@StartDate		date,
	@EndDate		date,
	@Places			int,
	@Discount		float(10)
AS
BEGIN
	IF NOT EXISTS
		(
			SELECT *
			FROM Conferences
			WHERE ConferenceID = @ConferenceID
		)
	BEGIN
		RAISERROR ('Nie ma konferencji o takim ID.', -1, -1)
		RETURN
	END

	-- aktualizowanie poczatku konferencji
	IF @StartDate IS NOT NULL
	BEGIN 
		UPDATE Conferences
			SET StartDate	   = @StartDate
			WHERE ConferenceID = @ConferenceID
	END

	-- aktualizowanie konca konferencji
	IF @EndDate IS NOT NULL
	BEGIN
		UPDATE Conferences
			SET EndDate		   = @EndDate
			WHERE ConferenceID = @ConferenceID
	END

	-- aktualizoawnie znizki
	IF @Discount IS NOT NULL
	BEGIN 
		UPDATE Conferences
			SET Discount	   = @Discount
			WHERE ConferenceID = @ConferenceID
	END

	-- aktualizowanie miejsc
	IF @Places IS NOT NULL
	BEGIN 
		UPDATE Conferences
			SET Places		   = @Places
			WHERE ConferenceID = @ConferenceID
	END

END
GO

--EXEC P_ChangeConferenceDetails @ConferenceID = 20, @StartDate = '2001-04-14', @EndDate = '2001-04-17', @Places = 400, @Discount = NULL;
--GO

-- zmiana informacji o warsztacie w tym ilosci miejsc 
CREATE PROCEDURE P_ChangeWorkshopDetails
	@WorkshopID		int,
	@ConferenceDay  int,
	@Places			int,
	@WorkshopStart  time,
	@WorkshopEnd    time
AS
BEGIN 
	IF NOT EXISTS
		( 
			SELECT *
			FROM Workshops
			WHERE WorkshopID = @WorkshopID
		)
	BEGIN 
		RAISERROR ('Nie ma warsztatu o takim ID.', -1, -1)
		RETURN
	END

	-- aktualizowanie dnia 
	IF @ConferenceDay IS NOT NULL
	BEGIN
		UPDATE Workshops
			SET ConferenceDay = @ConferenceDay
			WHERE WorkshopID  = @WorkshopID
	END

	-- aktualizownaie ilo�ci miejsc
	IF @Places IS NOT NULL
	BEGIN
		UPDATE Workshops
			SET Places		 = @Places
			WHERE WorkshopID = @WorkshopID
	END

	-- aktualizowanie czasu rozpocz�cia
	IF @WorkshopStart IS NOT NULL
	BEGIN
		UPDATE Workshops
			SET WorkshopStart = @WorkshopStart
			WHERE WorkshopID  = @WorkshopID
	END

	-- aktualizowanie czasu zako�czenia
	IF @WorkshopEnd IS NOT NULL
	BEGIN
		UPDATE Workshops
			SET WorkshopEnd  = @WorkshopEnd
			WHERE WorkshopID = @WorkshopID
	END

END
GO

--EXEC P_ChangeWorkshopDetails @WorkshopID = 30, @ConferenceDay = NULL, @Places = 20, @WorkshopStart = NULL, @WorkshopEnd = NULL; 
--GO

-- dodawanie rezerwacji na konferencje 
CREATE PROCEDURE P_AddReservationForConference
	@ConferenceID		int,
	@ClientID			int
AS
BEGIN
	IF EXISTS 
		( 
			SELECT *
			FROM ClientReservations
			WHERE ConferenceID = @ConferenceID
				AND ClientID = @ClientID
				AND IsCancelled = 0
		)
	BEGIN
		RAISERROR ('Klient o podanym ID juz rejestrowa� si� na konferencj� o podanym ID', -1, -1)
		RETURN
	END
	INSERT INTO ClientReservations (ConferenceID, ClientID)
		VALUES
		(
			@ConferenceID,
			@ClientID
		)

END
GO

--exec P_AddReservationForConference @ConferenceID = 4, @ClientID =4;
--go

-- dodawanie rezerwacji na dany dzien konferencji
CREATE PROCEDURE P_AddReservationForConferenceDay
	@ClientReservationID		int,
	@ConferenceDay				int,
	@NormalReservations			int,
	@StudentReservations		int
AS
BEGIN
	IF EXISTS
		(
			SELECT *
			FROM DaysReservations 
			WHERE ClientReservationID = @ClientReservationID
				AND ConferenceDay     = @ConferenceDay
				AND IsCancelled		  = 0
		)
	BEGIN
		RAISERROR ('Ten klient dokonywa� ju� rejestracji na ten dzie� konferencji', -1, -1)
		RETURN
	END

	INSERT INTO DaysReservations
		(
			ClientReservationID,
			ConferenceDay,
			NormalReservations,
			StudentsReservations
		)
	VALUES
		(
			@ClientReservationID,
			@ConferenceDay,
			@NormalReservations,
			@StudentReservations
		)

END
GO

--exec P_AddReservationForConferenceDay @ClientReservationID = 1, @ConferenceDay = 1, @NormalReservations = 10, @StudentReservations = 0;
--go

-- dodawanie rezerwacji na warsztat
CREATE PROCEDURE P_AddReservationForWorkshop
	@DayReservationID		int,
	@WorkshopID				int,
	@NormalReservations		int
AS
BEGIN
	IF EXISTS
		(
			SELECT *
			FROM WorkshopsReservations
			WHERE DayReservationID = @DayReservationID
				AND WorkshopID	   = @WorkshopID
				AND IsCancelled	   = 0
		)
	BEGIN
		RAISERROR ('Ten klient rezerwowa� juz miejsca na ten warsztat', -1, -1)
		RETURN
	END

	INSERT INTO WorkshopsReservations
		(
			DayReservationID,
			WorkshopID,
			NormalReservations
		)
	VALUES
		(
			@DayReservationID,
			@WorkshopID,
			@NormalReservations
		)
END
GO

-- dodawnie uczestnika na dany dzien konferencji 
CREATE PROCEDURE P_AddParticipantForConferenceDay
	(
		@ParticipantID		int,
		@DayReservationID	int,
		@StudentCard		int,
		@StudentCardDate	date
	)
AS
BEGIN
	-- czy uczestnik juz nie zostal zarejestrowany
	IF EXISTS 
		(
			SELECT *
			FROM ParticipantReservations
			WHERE ParticipantID		 = @ParticipantID
				AND DayReservationID = @DayReservationID
				AND IsCancelled		 = 0
		)
		BEGIN
			RAISERROR ('Podany uczestnik jest ju� zarejestrowany na ten dzie� konferencji.', -1, -1)
			RETURN
		END
	
	-- czy uczestnik istnieje
	IF NOT EXISTS 
		(
			SELECT *
			FROM Participants
			WHERE ParticipantID = @ParticipantID
		)
	BEGIN 
		RAISERROR ('Nie ma uczestnika o podanym ID.', -1, -1)
		RETURN
	END

	-- czy istnieje rezerwacja dnia o podanym ID
	IF NOT EXISTS
		(
			SELECT *
			FROM DaysReservations
			WHERE DayReservationID = @DayReservationID
				AND IsCancelled = 0
		)
	BEGIN
		RAISERROR ('Nie ma rezerwacji dnia o podanym ID.', -1 , -1)
		RETURN
	END
	
	INSERT INTO ParticipantReservations
		(
			ParticipantID,
			DayReservationID,
			StudentCard,
			StudentCardDate
		)
	VALUES
		(
			@ParticipantID,
			@DayReservationID,
			@StudentCard,
			@StudentCardDate
		)

END
GO


-- dodawanie uczestnika na dany warsztat 
CREATE PROCEDURE P_AddParticipantForWorkshop
	@ParticipantReservationID	int,
	@WorkshopID					int
AS
BEGIN
	IF EXISTS 
		(
			SELECT *
			FROM ParticipantWorkshops
			WHERE ParticipantReservationID = @ParticipantReservationID
				AND WorkshopID			   = @WorkshopID
				AND IsCancelled			   = 0
		)
	BEGIN
		RAISERROR ('Podany uczestnik rezerwowa� jest ju� zarejestrowany na ten warsztat.', -1, -1)
		RETURN
	END

	INSERT INTO ParticipantWorkshops
		(
			ParticipantReservationID,
			WorkshopID
		)
	VALUES
		(
			@ParticipantReservationID,
			@WorkshopID
		)

END
GO


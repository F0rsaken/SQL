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



EXEC P_AddWorkshop @ConferenceID = 4, @ConferenceDay = 1, @WorkshopName = 'WorkshopProcedureTest', @Places = 35, @WorkshopFee = 20, @WorkshopStart = '9:00', @WorkshopEnd = '10:30';


-- dodawanie progu cenowego
CREATE PROCEDURE P_AddPriceToConferencePriceList
	@ConferenceID	int,
	@PriceValue		money,
	@PriceDate		date 
AS
BEGIN
	INSERT INTO PriceList
		VALUES
		(
			@ConferenceID,
			@PriceValue,
			@PriceDate
		)
END



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
		RAISERROR ('Droga pani Aniu, nie ma progu cenowego o podanym ID', -1, -1)
	END
	DELETE PriceList
		WHERE PriceID = @PriceID 
END

EXEC P_AddPriceToConferencePriceList @ConferenceID = 4, @PriceValue = 200, @PriceDate = '2001-04-13';
EXEC P_DeletePriceFromConferencePriceList @PriceID = 16; 

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
		RAISERROR ('Pani Aniu, nie ma konferencji o takim ID.', -1, -1)
	END

	-- aktualizowanie pocz¹tku konferencji
	IF @StartDate IS NOT NULL
	BEGIN 
		UPDATE Conferences
			SET StartDate	   = @StartDate
			WHERE ConferenceID = @ConferenceID
	END

	-- aktualizowanie koñca konferencji
	IF @EndDate IS NOT NULL
	BEGIN
		UPDATE Conferences
			SET EndDate		   = @EndDate
			WHERE ConferenceID = @ConferenceID
	END

	-- aktualizoawnie zni¿ki
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

EXEC P_ChangeConferenceDetails @ConferenceID = 20, @StartDate = '2001-04-14', @EndDate = '2001-04-17', @Places = 400, @Discount = NULL;

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
		RAISERROR ('Pani Aniu, nie ma warsztatu o takim ID.', -1, -1)
	END

	-- aktualizowanie dnia 
	IF @ConferenceDay IS NOT NULL
	BEGIN
		UPDATE Workshops
			SET ConferenceDay = @ConferenceDay
			WHERE WorkshopID  = @WorkshopID
	END

	-- aktualizownaie iloœci miejsc
	IF @Places IS NOT NULL
	BEGIN
		UPDATE Workshops
			SET Places		 = @Places
			WHERE WorkshopID = @WorkshopID
	END

	-- aktualizowanie czasu rozpoczêcia
	IF @WorkshopStart IS NOT NULL
	BEGIN
		UPDATE Workshops
			SET WorkshopStart = @WorkshopStart
			WHERE WorkshopID  = @WorkshopID
	END

	-- aktualizowanie czasu zakoñczenia
	IF @WorkshopEnd IS NOT NULL
	BEGIN
		UPDATE Workshops
			SET WorkshopEnd  = @WorkshopEnd
			WHERE WorkshopID = @WorkshopID
	END

END

EXEC P_ChangeWorkshopDetails @WorkshopID = 1, @ConferenceDay = NULL, @Places = 20, @WorkshopStart = NULL, @WorkshopEnd = NULL; 
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



CREATE PROCEDURE P_AddWorkshop
	@ConferenceID int,
	@ConferenceDay int, 
	@WorkshopName varchar(50),
	@Places int, 
	@WorkshopFee money,
	@WorkshopStart time, 
	@WorkshopEnd time 
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

CREATE PROCEDURE P_AddPriceToConferencePriceList
	@ConferenceID int,
	@PriceValue money,
	@PriceDate date 
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

SELECT *
FROM PriceList

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

SELECT * 
FROM PriceList
EXEC P_AddPriceToConferencePriceList @ConferenceID = 4, @PriceValue = 200, @PriceDate = '2001-04-13';
EXEC P_DeletePriceFromConferencePriceList @PriceID = 16; 
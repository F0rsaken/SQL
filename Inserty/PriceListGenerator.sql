-- wstawiwanie PriceList
DECLARE @Iterator	INT 
	 = 1

DECLARE @PriceValue MONEY
	= 50

DECLARE @FirstDate	DATE
DECLARE @SecondDate	DATE
DECLARE @ThirdDate	DATE

DECLARE @ConferenceDate	DATE


WHILE @Iterator IN
	(
		SELECT ConferenceID
		FROM dbo.Conferences
	)
BEGIN	
	
	SET @ConferenceDate =
		(
			SELECT StartDate
			FROM dbo.Conferences
			WHERE ConferenceID = @Iterator
		)
	SET @FirstDate  = DATEADD(MONTH, -2, @ConferenceDate)
	SET @SecondDate = DATEADD(MONTH, -1, @ConferenceDate)
	SET @ThirdDate  = DATEADD(MONTH, -0, @ConferenceDate)

	EXEC dbo.P_AddPriceToConferencePriceList @ConferenceID = @Iterator,			-- int
	                                         @PriceValue   = @PriceValue,		-- money
	                                         @PriceDate    = @FirstDate			-- date

	SET @PriceValue = @PriceValue + 50

	EXEC dbo.P_AddPriceToConferencePriceList @ConferenceID = @Iterator,        -- int
	                                         @PriceValue = @PriceValue,        -- money
	                                         @PriceDate = @SecondDate		   -- date
	
	SET @PriceValue = @PriceValue + 100

	EXEC dbo.P_AddPriceToConferencePriceList @ConferenceID = @Iterator,        -- int
	                                         @PriceValue = @PriceValue,        -- money
	                                         @PriceDate = @ThirdDate -- date

	SET @Iterator = @Iterator + 1
	
END
GO

-- wstawianie Workshops
-- 1. musi byc w zakresie dni konferencji
-- 2. miejsc na warsztat mniej niz na konf


DECLARE @Rand	INT
	= CONVERT(INT, RAND()*100)

PRINT @Rand
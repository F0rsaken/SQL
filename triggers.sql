USE mmandows_a
GO

CREATE TRIGGER T_CancelAllDaysReservations
	ON ClientReservations
	AFTER UPDATE
AS
BEGIN

	DECLARE @ClientReservationID	int
		= (SELECT ClientReservationID FROM inserted WHERE IsCancelled = 1)

	UPDATE DaysReservations
	SET IsCancelled = 1
	WHERE ClientReservationID = @ClientReservationID

END
GO

-- blokuje rezerwacje na konferencje jezeli na zaden dzien nie ma juz wolnych miejsc
CREATE TRIGGER T_NoFreePlacesForAnyConferenceDay
	ON ClientReservations
	AFTER INSERT
AS
BEGIN

	DECLARE @ConferenceID	int
		= (SELECT ConferenceID FROM inserted)

	IF 
		(
			SELECT COUNT(*)
			FROM F_FreeAndReservedPlacesForConference (@ConferenceID)
				WHERE FreePlaces > 0
		) = 0
	BEGIN
		RAISERROR ('Nie ma juz wolnych miejsc na zaden dzien tej konferencji.', -1, -1)
		ROLLBACK TRANSACTION
	END
		
END
GO

CREATE TRIGGER T_ControlClientSurnameAndIsPrivateStatus
	ON Clients
	AFTER INSERT, UPDATE
AS
BEGIN
	
	DECLARE @IsPrivate		bit
		= (SELECT IsPrivate FROM inserted)

	DECLARE @ClientSurname	varchar(50)
		= (SELECT ClientSurname FROM inserted)


	IF @IsPrivate = 1 AND @ClientSurname IS NULL
	BEGIN
		RAISERROR ('Prywatny klient wymaga podania nazwiska.', -1, -1)
		ROLLBACK TRANSACTION
	END

	IF @IsPrivate = 0 AND @ClientSurname IS NOT NULL
	BEGIN
		RAISERROR ('Dla klienta firmowego nie nale�y podawa� nazwiska.', -1, -1)
		ROLLBACK TRANSACTION
	END

END
GO

-- blokuje zmniejszenie liczby miejsc na konferencje jezeli ilosc do tej pory zarezerwowanych miejsc jest wieksza od nowej liczby dostepnych miejsc
CREATE TRIGGER T_ControlUpdatingPlacesForConference
	ON Conferences
	AFTER UPDATE
AS
BEGIN

	DECLARE @ConferenceID	int
		= ( SELECT ConferenceID FROM inserted)

	DECLARE @NewPlaces	int
		= ( SELECT Places FROM inserted)

	DECLARE @ReservedPlaces	int
		= ( SELECT TOP 1 ReservedPlaces FROM F_FreeAndReservedPlacesForConference (@ConferenceID) ORDER BY ReservedPlaces DESC)

	IF @NewPlaces < @ReservedPlaces
	BEGIN
		RAISERROR ('Nowa ilosc dostepnych miejsc jest mniejsza od juz zarezerwowanej.', -1, -1)
		ROLLBACK TRANSACTION
	END

END
GO

CREATE TRIGGER T_CancelAllParticipantConferenceDayReservations
	ON DaysReservations
	AFTER UPDATE
AS
BEGIN

	UPDATE ParticipantReservations
	SET IsCancelled = 1
	WHERE DayReservationID IN 
		(
			SELECT DayReservationID 
			FROM inserted
			WHERE IsCancelled = 1
		)

END
GO

CREATE TRIGGER T_CancelAllWorkshopsReservations
	ON DaysReservations
	AFTER UPDATE
AS
BEGIN

	UPDATE WorkshopsReservations
	SET IsCancelled = 1
	WHERE DayReservationID IN
		(
			SELECT DayReservationID
			FROM inserted
			WHERE IsCancelled = 1
		)

END
GO

-- blokuje rezerwacje lub zmiane ilosci miejsc na dany dzien konferencji jezeli nie ma juz wolnych miejsc lub nie ma juz tylu wolnych miejsc ile chce klient
CREATE TRIGGER T_NoPlacesForConferenceDay
	ON DaysReservations
	AFTER INSERT, UPDATE 
AS
BEGIN

	DECLARE @ClientReservationID	int
		= ( SELECT ClientReservationID FROM inserted)

	DECLARE @ConferenceDay	int
		= ( SELECT ConferenceDay FROM inserted)

	DECLARE @Places	int
		= ( 
				SELECT i.NormalReservations + i.StudentsReservations - d.NormalReservations - d.StudentsReservations 
				FROM inserted AS i 
				INNER JOIN deleted AS d 
						ON i.DayReservationID = d.DayReservationID
		  )

	DECLARE @ConferenceID	int
		= ( SELECT ConferenceID FROM ClientReservations WHERE ClientReservationID = @ClientReservationID)

	DECLARE @FreePlaces	int
		= ( SELECT FreePlaces FROM F_FreeAndReservedPlacesForConference (@ConferenceID) WHERE ConferenceDay = @ConferenceDay)


	IF @Places > @FreePlaces
	BEGIN
		RAISERROR ('Nie ma tylu wolnych miejsc na ten dzien konferencji.', -1, -1)
		ROLLBACK TRANSACTION
	END

END
GO

CREATE TRIGGER T_CancelAllParticipantWorkshopsReservations1
	ON ParticipantReservations
	AFTER UPDATE
AS
BEGIN
	
	UPDATE ParticipantWorkshops
	SET IsCancelled = 1
	WHERE ParticipantReservationID IN
		(
			SELECT ParticipantReservationID
			FROM inserted
			WHERE IsCancelled = 1
		)
		AND IsCancelled = 0 -- bo anulowanie moze nastapic po anulowaniu rezerwacji na warsztat, albo po anulowaniu rezerwacji na dzien

END
GO

-- sprawdzenie czy można dodać uczestnika na warsztat
CREATE TRIGGER T_CheckIfParticipantCanBeAdded
	ON ParticipantWorkshops
	AFTER INSERT
AS
BEGIN

	DECLARE @ParticipantReservationID INT
		= (SELECT ParticipantReservationID FROM inserted)
	DECLARE @WorkshopID INT
		= (SELECT WorkshopID FROM inserted)
	DECLARE @DayReservationID INT
		= ( SELECT DayReservationID FROM ParticipantReservations
			WHERE ParticipantReservationID = @ParticipantReservationID )

	IF NOT EXISTS (
		SELECT * FROM ParticipantReservations pr
		JOIN DaysReservations dr ON dr.DayReservationID = pr.DayReservationID
		JOIN WorkshopsReservations wr ON wr.DayReservationID = dr.DayReservationID
		WHERE wr.WorkshopID = @WorkshopID AND pr.ParticipantReservationID = @ParticipantReservationID
			AND pr.IsCancelled = 0 AND wr.IsCancelled = 0
	)
	BEGIN
		RAISERROR ('Klient nie zrobił rezerwacji na ten warsztat', -1, -1)
		ROLLBACK TRANSACTION
	END

	IF (
		SELECT count(*) FROM DaysReservations dr
		JOIN ParticipantReservations pr ON pr.DayReservationID = dr.DayReservationID
		JOIN ParticipantWorkshops pw ON pw.ParticipantReservationID = pr.ParticipantReservationID
		WHERE dr.DayReservationID = @DayReservationID AND pw.WorkshopID = @WorkshopID
	) >= (
		SELECT wr.NormalReservations FROM WorkshopsReservations wr
		JOIN DaysReservations dr ON dr.DayReservationID = wr.DayReservationID
		WHERE dr.DayReservationID = @DayReservationID AND wr.WorkshopID = @WorkshopID
	)
	BEGIN
		RAISERROR ('Nie można się już zapisać na warsztat', -1, -1)
		ROLLBACK TRANSACTION
	END
END
GO

-- sprawdzanie, czy wpis do PriceList jet dobry
CREATE TRIGGER T_CheckPriceListInsert
	ON PriceList
	AFTER INSERT
AS
BEGIN
	DECLARE @PriceDate DATE
		= (SELECT PriceDate FROM inserted)
	DECLARE @PriceValue money
		= (SELECT PriceValue FROM inserted)
	DECLARE @ConferenceID INT
		= (SELECT ConferenceID FROM inserted)

	IF @PriceDate >= (SELECT StartDate FROM Conferences WHERE ConferenceID = @ConferenceID)
	BEGIN
		RAISERROR ('Data ceny jest późniejsza niż początek konferencji', -1, -1)
		ROLLBACK TRANSACTION
	END

	IF EXISTS (
		SELECT * FROM PriceList
		WHERE PriceDate < @PriceDate AND ConferenceID = @ConferenceID
	)
	BEGIN
		IF @PriceValue <= (
			SELECT TOP 1 PriceValue FROM PriceList
			WHERE PriceDate < @PriceDate AND ConferenceID = @ConferenceID
			ORDER BY PriceDate DESC
		)
		BEGIN
			RAISERROR ('Cena dla tej daty jest za mała', -1, -1)
			ROLLBACK TRANSACTION
		END
	END

	IF EXISTS (
		SELECT * FROM PriceList
		WHERE PriceDate > @PriceDate AND ConferenceID = @ConferenceID
	)
	BEGIN
		IF @PriceValue >= (
			SELECT TOP 1 PriceValue FROM PriceList
			WHERE PriceDate > @PriceDate AND ConferenceID = @ConferenceID
			ORDER BY PriceDate
		)
		BEGIN
			RAISERROR ('Cena dla tej daty jest za duża', -1, -1)
			ROLLBACK TRANSACTION
		END
	END	
END
GO

-- blokuje zmniejszenie liczby miejsc na warsztat jezeli ilosc do tej pory zarezerwowanych miejsc jest wieksza od nowej liczby dostepnych miejsc
CREATE TRIGGER T_ControlUpdatingPlacesForWorkshop
	ON Workshops
	AFTER UPDATE
AS
BEGIN
	
	DECLARE @WorkshopID	int
		= ( SELECT WorkshopID FROM inserted)

	DECLARE @NewPlaces	int
		= ( SELECT Places FROM inserted)

	DECLARE @ReservedPlaces	int
		= ( SELECT TOP 1 ReservedPlaces FROM F_FreeAndReservedPlacesForWorkshop (@WorkshopID) ORDER BY ReservedPlaces DESC)
	
	IF @NewPlaces < @ReservedPlaces
	BEGIN
		RAISERROR ('Nowa ilosc dostepnych miejsc jest mniejsza od juz zarezerwowanej.', -1, -1)
		ROLLBACK TRANSACTION
	END

END
GO
/*test
exec P_ChangeWorkshopDetails @WorkshopID = 3, @ConferenceDay = NULL, @Places = 9, @WorkshopStart = NULL, @WorkshopEnd =  NULL;

select *
from F_FreeAndReservedPlacesForWorkshop(3)

select * 
from Workshops
*/
go


-- blokuje zm

--sprawdzanie czy wpisany dzien warsztatu jest jednym z dni konferencji
USE mmandows_a
GO

CREATE TRIGGER T_CheckIfWorkshopDayBelongsToConferenceDay
	ON Workshops
	AFTER INSERT
AS
BEGIN
	DECLARE @ConferenceDay INT
		= ( SELECT datediff(day, StartDate, EndDate)
		FROM Conferences
		WHERE ConferenceID = (
				SELECT ConferenceID
				FROM inserted
			)
		)
	SET @ConferenceDay += 1

	IF @ConferenceDay < (
		SELECT ConferenceDay
		FROM inserted
	)
	BEGIN
		RAISERROR ('Konferencja nie ma tylu dni', -1, -1)
		ROLLBACK TRANSACTION
	END
END
GO

-- blokuje rezerwacje lub update miejsc na warsztat jezeli nie ma juz tylu miejsc lub zostalo podane wiecej miejsc niz zarezerwowane na konf.
CREATE TRIGGER T_ControlPlacesForWorkshop
	ON WorkshopsReservations
	AFTER UPDATE, INSERT
AS
BEGIN
	
	DECLARE @WorkshopID	int
		= ( SELECT WorkshopID FROM inserted)

	DECLARE @IncreaseOfPlaces	int
		= ( SELECT i.NormalReservations - d.NormalReservations 
			FROM inserted AS i
			INNER JOIN deleted AS d 
					ON i.WorkshopReservationID = d.WorkshopReservationID
		  )

	DECLARE @FinalNumbnerOfPlaces	int
		= ( SELECT NormalReservations FROM inserted)

	DECLARE @DayReservationID	int
		= ( SELECT DayReservationID FROM inserted)

	DECLARE @ReservedPlacesForConferenceDay	int
		= ( SELECT NormalReservations + StudentsReservations FROM DaysReservations WHERE DayReservationID = @DayReservationID)


	IF @FinalNumbnerOfPlaces > @ReservedPlacesForConferenceDay
	BEGIN
		RAISERROR ('Nie zarezerwowano tylu miejsc na ten dzien konferencji.', -1, -1)
		ROLLBACK TRANSACTION
	END

	DECLARE @FreePlaces	int
		= ( SELECT FreePlaces FROM F_FreeAndReservedPlacesForWorkshop (@WorkshopID))

	IF @IncreaseOfPlaces > @FreePlaces
	BEGIN
		RAISERROR ('Nie ma tylu wolnych miejsc na ten warsztat.', -1, -1)
		ROLLBACK TRANSACTION
	END

END
GO

CREATE TRIGGER T_CancelAllParticipantWorkshopsReservations2
	ON WorkshopsReservations
	AFTER UPDATE
AS
BEGIN
	
	UPDATE ParticipantWorkshops
	SET IsCancelled = 1
	WHERE ParticipantReservationID IN
		(
			SELECT pr.ParticipantReservationID
			FROM ParticipantReservations as pr
			INNER JOIN DaysReservations as dr
					ON pr.DayReservationID = dr.DayReservationID
			INNER JOIN ParticipantWorkshops as pw
					ON pr.ParticipantReservationID = pw.ParticipantReservationID
			WHERE dr.DayReservationID IN
				(
					SELECT DayReservationID
					FROM inserted
					WHERE IsCancelled = 1
				)
		)
		AND IsCancelled = 0 -- bo anulowanie moze nastapic po anulowaniu rezerwacji na warsztat, albo po anulowaniu rezerwacji na dzien

END
GO

DROP TRIGGER T_ControlFreePlacesReservedByClientForConferenceDay
-- blokuje dodanie uczestnika na dzien konferencji jezeli zostaly wykorzystane miejsca zarezerwowane przez klienta
CREATE TRIGGER T_ControlFreePlacesReservedByClientForConferenceDay
	ON ParticipantReservations
	AFTER INSERT
AS
BEGIN
	
	DECLARE @DayReservationID	int
		= ( SELECT DayReservationID FROM inserted)

	DECLARE @IsStudent	bit

	-- sprawdzenie czy dodawany uczestnik to student
	IF ( SELECT StudentCard FROM inserted ) IS NULL
	BEGIN
		SET @IsStudent = 0
	END

	IF ( SELECT StudentCard FROM inserted ) IS NOT NULL
	BEGIN
		SET @IsStudent = 1
	END

	DECLARE @NormalReservations	int
		= ( SELECT NormalReservations FROM DaysReservations WHERE DayReservationID = @DayReservationID)

	DECLARE @StudentsReservations	int
		= ( SELECT StudentsReservations FROM DaysReservations WHERE DayReservationID = @DayReservationID)

	DECLARE @UsedNormalReservations	int
		= ( 
				SELECT COUNT(*)
				FROM ParticipantReservations
				WHERE DayReservationID = @DayReservationID
					AND IsCancelled = 0
					AND StudentCard IS NULL 
		  )

	DECLARE @UsedStudentsReservations	int
		= ( 
				SELECT COUNT(*)
				FROM ParticipantReservations
				WHERE DayReservationID = @DayReservationID
					AND IsCancelled = 0
					AND StudentCard IS NOT NULL 
		  )


	IF @IsStudent = 0 AND @UsedNormalReservations = @NormalReservations
	BEGIN
		RAISERROR ('Wszystkie normalne rezerwacje zostaly juz wykorzystane na ten dzien konferencji.', -1, -1)
		ROLLBACK TRANSACTION
	END

	IF @IsStudent = 1 AND @UsedStudentsReservations = @StudentsReservations
	BEGIN
		RAISERROR ('Wszystkie rezerwacje dla student�w zostaly juz wykorzystane na ten dzien konferencji.', -1, -1)
		ROLLBACK TRANSACTION
	END

END
GO

-- kontrola pol StudentCard i StudentCardDate
CREATE TRIGGER T_ControlStudentsCardFieldsFilling
	ON ParticipantReservations
	AFTER INSERT, UPDATE
AS
BEGIN
	
	DECLARE @StudentCard	int
		= ( SELECT StudentCard FROM inserted )

	DECLARE @StudentCardDate	date
		= ( SELECT StudentCardDate FROM inserted )

	IF (@StudentCard IS NULL AND @StudentCardDate IS NOT NULL)
		OR (@StudentCard IS NOT NULL AND @StudentCardDate IS NULL)
	BEGIN
		RAISERROR ('Prosz� wype�nic wszystkie pola przeznaczone dla studenta.', -1, -1)
		ROLLBACK TRANSACTION
	END
END
GO

-- blokuje zmniejszenie liczby miejsc na warsztat jezeli ilosc do tej pory zarezerwowanych miejsc jest wieksza od nowej liczby dostepnych miejsc
CREATE TRIGGER T_ControlUpdatingPlacesForWorkshop
	ON Workshops
	AFTER UPDATE
AS
BEGIN
	
	DECLARE @WorkshopID	int
		= ( SELECT WorkshopID FROM inserted)

	DECLARE @NewPlaces	int
		= ( SELECT Places FROM inserted)

	DECLARE @ReservedPlaces	int
		= ( SELECT ReservedPlaces FROM F_FreeAndReservedPlacesForWorkshop (@WorkshopID))
	
	IF @NewPlaces < @ReservedPlaces
	BEGIN
		RAISERROR ('Nowa ilosc dostepnych miejsc jest mniejsza od juz zarezerwowanej.', -1, -1)
		ROLLBACK TRANSACTION
	END

END
GO

-- zerowanie op�aty po anulowaniu rezerwacji na konf
CREATE TRIGGER T_DeleteFineAssesdAfterCancelingConferenceReservation
	ON ClientReservations
	AFTER UPDATE
AS
BEGIN
	DECLARE @ClientReservationID	int
		= ( SELECT ClientReservationID FROM inserted WHERE IsCancelled = 1)
	
	IF @ClientReservationID IS NOT NULL
	BEGIN
		UPDATE Payments
		SET FineAssessed = 0
		WHERE PaymentID = @ClientReservationID
	END

END
GO

-- wyliczanie oplaty po zarezerwowaniu lub anulowaniu miejsc na warsztaty
CREATE TRIGGER T_CountFineAfterWorkhopReservationOrUpdate
	ON WorkshopsReservations
	AFTER INSERT, UPDATE
AS
BEGIN
	
	DECLARE @DayReservationID	int
		= ( SELECT DayReservationID FROM inserted)

	DECLARE @ClientReservationID	int
		= ( SELECT ClientReservationID FROM DaysReservations WHERE DayReservationID = @DayReservationID)

	EXEC P_CountFine @ClientReservationID = @ClientReservationID;

END
GO

-- wyliczanie op�at po zarezerwowaniu lub anulowaniu miejsc na dzien konf
CREATE TRIGGER T_CountFineAfterConferenceDayReservationOrUpdate
	ON DaysReservations
	AFTER INSERT, UPDATE
AS
BEGIN
	
	DECLARE @ClientReservationID	int
		= ( SELECT ClientReservationID FROM inserted)

	EXEC P_CountFine @ClientReservationID = @ClientReservationID;

END
GO

-- tworzenie pola oplat
CREATE TRIGGER T_CreatePaymentField
	ON dbo.ClientReservations
	AFTER INSERT
AS
BEGIN
	
	DECLARE @PaymentID	INT
		= ( 
				SELECT ClientReservationID
				FROM Inserted
		  )
	
	DECLARE @ReservationDate DATE
		= (
				SELECT ReservationDate 
				FROM Inserted
		  )

	DECLARE @DueDate	DATE
		= DATEADD(DAY, 7, @ReservationDate)


	INSERT INTO dbo.Payments
	(
	    PaymentID,
		FineAssessed,
	    FinePaid,
	    DueDate
	)
	VALUES
	(   
		@PaymentID,
		0,     -- FineAssessed - money
	    0,     -- FinePaid - money
	    @DueDate -- DueDate - date
	)
END
GO
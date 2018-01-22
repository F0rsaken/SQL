-- ============================
-- Triggery od anulowania 
-- ============================

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
		RAISERROR ('Dla klienta firmowego nie nale¿y podawaæ nazwiska.', -1, -1)
		ROLLBACK TRANSACTION
	END

END
GO		
/*test
EXEC P_AddClient @ClientName = 'TriggerTest', @ClientSurname = NULL, @IsPrivate = 0, @PhoneNumber = 123123123, @Email = 'triggertest12@gmail.com', @Address = 'triggerAdress', @City = 'Trigger', @PostalCode = 123123, @Country = 'Trigger';
GO
*/

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
/*test

select *
from ParticipantReservations as pr
inner join DaysReservations as dr
	on pr.DayReservationID = dr.DayReservationID
	where ClientReservationID = 3

exec P_CancelConferenceReservation @ClientReservationID =3;
*/


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
/*test
exec P_CancelConferenceReservation @ClientReservationID = 2;
go 

select cr.ClientID, cr.IsCancelled, cr.ClientReservationID ,cr.ConferenceID, pr.ParticipantID, pr.DayReservationID, pw.*
from ParticipantWorkshops as pw
inner join ParticipantReservations as pr
on pw.ParticipantReservationID = pr.ParticipantReservationID
inner join DaysReservations as dr
on pr.DayReservationID = dr.DayReservationID
inner join ClientReservations as cr
on dr.ClientReservationID = cr.ConferenceID
*/


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
/*test
exec P_CancelWorkshopResrvation @WorkshopReservationID = 9;
go

select *
from ClientReservations as cr
inner join DaysReservations as dr
on cr.ClientReservationID = dr.ClientReservationID
inner join WorkshopsReservations as wr
on dr.DayReservationID = wr.DayReservationID
where cr.ClientReservationID =4

--28 4
select *
from ParticipantWorkshops
exec P_AddReservationForWorkshop @DayReservationID = 10, @WorkshopID = 1, @NormalReservations = 20;
go
exec P_AddParticipantForWorkshop @ParticipantReservationID = 28, @WorkshopID = 1;
go
*/


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
/*test
exec P_CancelConferenceReservation @ClientReservationID = 5;
go
select cr.ClientID, cr.ClientReservationID, cr.ConferenceID, cr.IsCancelled, dr.DayReservationID, dr.IsCancelled, wr.WorkshopReservationID, wr.DayReservationID, wr.WorkshopID, wr.IsCancelled, pres.ParticipantID,pres.DayReservationID, pres.IsCancelled, pw.ParticipantReservationID, pw.WorkshopID, pw.IsCancelled
from ParticipantReservations as pr
inner join DaysReservations as dr
	on pr.DayReservationID = dr.DayReservationID
inner join WorkshopsReservations as wr
	on dr.DayReservationID = wr.DayReservationID
inner join ClientReservations as cr
	on dr.ClientReservationID = cr.ClientReservationID
inner join ParticipantReservations as pres
	on dr.DayReservationID = pres.DayReservationID
inner join ParticipantWorkshops as pw
	on pr.ParticipantReservationID = pw.ParticipantReservationID
*/



use mmandows_a
go
-- ============================
-- Triggery od wolnych miejsc
-- ============================

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

/*test
drop trigger T_NoPlacesForConferenceDay

SELECT *
FROM F_FreeAndReservedPlacesForConference (1)

select *
from Conferences

select *
from ClientReservations

exec P_AddReservationForConferenceDay @ClientReservationID = 4, @ConferenceDay = 3, @NormalReservations = 30, @StudentReservations = 11;

select *
from DaysReservations as dr
inner join ClientReservations as cr 
	on dr.ClientReservationID = cr.ClientReservationID
where dr.ClientReservationID = 4
	and ConferenceDay =2

UPDATE DaysReservations
	SET NormalReservations = 60
	WHERE ClientReservationID = 4
		AND ConferenceDay = 2


DECLARE @ConferenceID	int = 1
DECLARE @ConferenceDay	int = 2
DECLARE @FreePlaces	int
	= (SELECT FreePlaces FROM F_FreeAndReservedPlacesForConference (@ConferenceID) WHERE ConferenceDay = @ConferenceDay)

PRINT @FreePlaces
*/
use 

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

/*test
 
select *
from WorkshopsReservations

select *
from DaysReservations
where DayReservationID =2

update DaysReservations
	SET IsCancelled = 0
	WHERE DayReservationID = 2

update DaysReservations
	SET NormalReservations = 2
	WHERE DayReservationID =2


update DaysReservations
	SET StudentsReservations = 0
	WHERE DayReservationID =2


select *
from F_FreeAndReservedPlacesForWorkshop(2)
*/
use

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

/*test
select *
from F_FreeAndReservedPlacesForConference(1)

exec P_ChangeConferenceDetails @ConferenceID =1, @StartDate = NULL, @EndDate = NULL, @Places = 40, @Discount = 0.25;
*/
use

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
/*test
exec P_ChangeWorkshopDetails @WorkshopID = 3, @ConferenceDay = NULL, @Places = 9, @WorkshopStart = NULL, @WorkshopEnd =  NULL;

select *
from F_FreeAndReservedPlacesForWorkshop(3)

select * 
from Workshops
*/
use
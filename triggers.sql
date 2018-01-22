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



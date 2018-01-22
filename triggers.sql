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
		
--EXEC P_AddClient @ClientName = 'TriggerTest', @ClientSurname = NULL, @IsPrivate = 0, @PhoneNumber = 123123123, @Email = 'triggertest12@gmail.com', @Address = 'triggerAdress', @City = 'Trigger', @PostalCode = 123123, @Country = 'Trigger';
--GO


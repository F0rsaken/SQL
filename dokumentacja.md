<div id = "grafika" style = "text-align:center; width:400px; height:550px; margin:auto;">
<!-- ![agh_nzw_s_pl_3w_wbr_rgb_150ppi.jpg](C:\Users\mike\Documents\SQLProject\agh_nzw_s_pl_3w_wbr_rgb_150ppi.jpg) -->
</div>
<h1 style = "text-align:center">Laboratorium Podstaw Baz Danych <br/>Dokumentacja Systemu zarządzania konferencjami</h1>
<h3 style = "text-align:right">Miłosz Mandowski <br/>Michał Śledź</h3>

#Spis treści
* Ogólne informacje
* Schemat bazy danych
<a href="#Tabele">
* Tabele
</a>
	* cos 
	* cos
<a href="#Triggery">
* Triggery
</a>
 	* trig 1
 	* trig 2
 	

#Ogólne informacje
Firma organizuje konferencje, które mogą być jedno- lub kilkudniowe. Klienci
powinni móc rejestrować się na konferencje za pomocą systemu www. Klientami mogą być
zarówno indywidualne osoby jak i firmy, natomiast uczestnikami konferencji są osoby (firma
nie musi podawać od razu przy rejestracji listy uczestników - może zarezerwować
odpowiednią ilość miejsc na określone dni oraz na warsztaty, natomiast na 2 tygodnie przed
rozpoczęciem musi te dane uzupełnić - a jeśli sama nie uzupełni do tego czasu, to pracownicy
dzwonią do firmy i ustalają takie informacje). Każdy uczestnik konferencji otrzymuje
identyfikator imienny (+ ew. informacja o firmie na nim). Dla konferencji kilkudniowych,
uczestnicy mogą rejestrować się na dowolne z tych dni.

#Schemat bazy danych
<!-- ![Entity Relationship Diagram1.png](C:\Users\mike\Documents\SQLProject\Entity Relationship Diagram1.png) -->

<a name="Tabele">
#Tabele
</a>
<h6>
Clients - tabela zawierająca informacje o klientach. Zawiera pola
* ClientID - identyfikator klienta, unikatowy, zaczyna się od 1, inkrementowany o 1
* ClientName - nazwa klienta. W przypadku firm nazwa firmy, w przypadku osoby prywatnej imię
* ClientSurname - nazwisko klienta. W przypadku frim pozostaje wartość ```NULL```, w przypadku osoby prywatnej nazwisko
* IsPrivate - informacja czy klientem jest firma czy osoba prywatna. Typ bitowy.
* PhoneNumber - numer telefonu. Musi posiadać 9 cyfr, a pierwsza nie może być zerem
* Email - adres email klienta
* Address - adres klienta
* City - miasto klienta
* PostalCode - kod pocztowy
* Country - państwo klienta
</h6>
```sql
CREATE TABLE Clients (
	ClientID int IDENTITY(1,1) NOT NULL,
	ClientName varchar(50) NOT NULL,
	ClientSurname varchar(50) NULL,
	IsPrivate bit NOT NULL DEFAULT 0,
	PhoneNumber int NOT NULL CHECK (PhoneNumber like '[1-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	Email varchar(50) NOT NULL,
	Address varchar(50) NOT NULL,
	City varchar(50) NOT NULL,
	PostalCode int NOT NULL,
	Country varchar(30) NOT NULL,
	PRIMARY KEY (ClientID));
```
<h6>Conferences - tabela zawierająca informacje o konferencjach. Zawiera pola
* ConferenceID - identyfikator konferencji, unikatowy, zaczyna się od 1, inkrementowany o 1
* ConferenceName - temat konferencji
* StartDate - data rozpoczęcia konferencji w formacie ```yyyy-mm-dd```
* EndDate - data zakończenia konferencji w formacie ```yyyy-mm-dd```
* Discount - zniżka dla studentów. Domyślnie wartość ustawiona na 0. Musi być mniejsza lub równa 1.
</h6>
```sql
CREATE TABLE Conferences (
	ConferenceID int IDENTITY(1,1) NOT NULL,
	ConferenceName varchar(50) NOT NULL,
	StartDate date NOT NULL,
	EndDate date NOT NULL,
	Discount float(4) NOT NULL DEFAULT 0 CHECK (Discount <= 1),
	PRIMARY KEY (ConferenceID));
```
<h6>ClientReservations - przechowuje informacje o rezerwacji klienta na daną konferencję. Zawiera pola:
* ClientReservationID - identyfikator rezerwacji, unikatowy, zaczyna się od 1, inkrementowany o 1
* ConferenceID - identyfikator konferencji
* ClientID - identyfikator klienta
* ReservationDate - data dokonania rezerwacji
</h6>
```sql
CREATE TABLE ClientReservations (
	ClientReservationID int IDENTITY(1,1) NOT NULL,
	ConferenceID int NOT NULL,
	ClientID int NOT NULL,
	ReservationDate date NOT NULL DEFAULT Convert(date, getdate()),
	PRIMARY KEY (ClientReservationID));
```
<h6>DaysReservations - przechowuje informacje o rezerwacjach klientów na konkretne dni konferencji. Zawiera pola:
* DayReservationID - identyfikator rezerwacji na dany dzień, unikatowy, zaczyna się od 1, inkrementowany o 1
* ClientReservationID - identyfikator klienta 
* ConferenceDay - nr dnia, na który dokonano rezerwacji
* NormalReservations - ilość zarezerwowwanych normalnych miejsc, musi być większa od zera
* StudentsReservations - ilość zarezerwowanych studenckich miejsc, domyślnie równa zero
</h6>
```sql
CREATE TABLE DaysReservations (
	DayReservationID int IDENTITY(1,1) NOT NULL,
	ClientReservationID int NOT NULL, 
	ConferenceDay int NOT NULL,
	NormalReservations int NOT NULL CHECK (NormalReservations > 0),
	StudentsReservations int NOT NULL DEFAULT 0,
	PRIMARY KEY (DayReservationID));
```
<h6>ParticipantReservations - przechowuje informacje o zapisach uczestników na dany dzień konferencji. Zawiera pola:
* ParticipantReservationID - identyfikator rezerwacji uczestnika, unikatowy, zaczyna się od 1, inkrementowany o 1
* ParticipantID - identyfikator uczestnika
* DayReservationID - identyfikator rezerwacji klienta na dany dzień
* StudentCard - nr legitymacji studenckiej, równy ```null``` jeżeli uczestnik nie jest studentem
* StudentCardDate - ważność legitymacji studenckiej, równa ```null``` jeżeli uczestnik nie jest studentem
</h6>
```sql
CREATE TABLE ParticipantReservations (
	ParticipantReservationID int IDENTITY(1,1) NOT NULL,
	ParticipantID int NOT NULL,
	DayReservationID int NOT NULL,
	StudentCard int NULL,
	StudentCardDate date NULL,
	PRIMARY KEY (ParticipantReservationID));
```
<h6>Participants - przechowuje informacje o uczestnikach konferencji. Zawiera pola:
* ParticipantID - identyfikator uczestnika, unikatowy, zaczyna się od 1, inkrementowany o 1
* Name - imię uczestnika
* Surname - nazwisko uczestnika
* PhoneNumber - nr telefonu, musi posiadać 9 cyfr, pierwsza musi być różna od zera
* Email - adres email 
* City - miasto
* Country - państwo
* DiscountGranted - informuje czy uczestnikowi przysługuje zniżka studencka, wartość bitowa, domyślnie nie przysługuje ```potrzebne nam????```
</h6>
```sql
CREATE TABLE Participants (
	ParticipantID int IDENTITY(1,1) NOT NULL,
	Name varchar(50) NOT NULL,
	Surname varchar(50) NOT NULL,
	PhoneNumber int NOT NULL CHECK (PhoneNumber like '[1-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	Email varchar(50) NOT NULL,
	City varchar(50) NOT NULL,
	Country varchar(50) NOT NULL,
	DiscountGranted bit NOT NULL DEFAULT 0,
	PRIMARY KEY (ParticipantID));
```
<h6>ParticipantWorkshops - przechowuje informacje o zapisach uczestników na warsztaty. Zawiera pola:
* WorkshopReservationID - identyfikator rezerwacji na warsztat, unikatowy, zaczyna się od 1, inkrementowany o 1
* ParticipantReservationID - identyfikator rezerwacji uczestnika na dany dzień konferencji
* WorkshopID - identyfikator warsztatu
</h6>
```sql
CREATE TABLE ParticipantWorkshops (
	WorkshopReservationID int IDENTITY(1,1) NOT NULL,
	ParticipantReservationID int NOT NULL,
	WorkshopID int NOT NULL,
	PRIMARY KEY (WorkshopReservationID));
```
<h6>Payments - przechowuje informacje o opłatach nałożonych na klientów, za dokonane rezerwacje miejsc na konferencje i warsztaty. Zawiera pola:
* PaymentID - identyfikator opłaty, unikatowy zaczyna się od 1, inkrementowany o 1 
* FineAssessed - należna opłata za rezerwacje miejsc na konferencję i warsztaty
* FinePaid - kwota zapłacona do tej pory
* DueDate - czas, do którego należy dokonać opłaty
</h6>
```sql
CREATE TABLE Payments (
	PaymentID int IDENTITY(1,1) NOT NULL,
	FineAssessed money NOT NULL,
	FinePaid money NOT NULL DEFAULT 0,
	DueDate date NOT NULL,
	PRIMARY KEY (PaymentID));
```
<h6>PriceList - przechowuje informacje o cenach za rezerwacje na konferencję w zależności od daty dokonania rezerwacji. Zawiera pola:
* PriceID - identyfikator opłaty
* ConferenceID - identyfikator konferencji
* PriceValue - cena za rezerwację
* PriceDate - data, do której obowiązuje dana cena
</h6>
```sql
CREATE TABLE PriceList (
	PriceID int IDENTITY(1,1) NOT NULL,
	ConferenceID int NOT NULL,
	PriceValue money NOT NULL,
	PriceDate date NOT NULL,
	PRIMARY KEY (PriceID));
```
<h6>Workshops - przechowuje informacje o warsztatach. Zawiera pola:
* WorkshopID - identyfikator warsztatu, unikatowy, zaczyna się od 1, inkrementowany o 1
* ConferenceID - identyfikator konferencji
* ConferenceDay - nr dnia konferencji, na który przypada warsztat
* WorkshopName - temat/nazwa warsztatu
* Places - ilość dostępnych miejsc
* WorkshopFee - wysokość opłaty należnej za wstęp na warsztat
* WorkshopStart - czas rozpoczęcia warsztatu
* WorkshopEnd - czas zakończenia warsztatu
</h6>
```sql
CREATE TABLE Workshops (
	WorkshopID int IDENTITY(1,1) NOT NULL,
	ConferenceID int NOT NULL,
	ConferenceDay int NOT NULL,
	WorkshopName varchar(50) NOT NULL,
	Places int NOT NULL CHECK (Places >= 0),
	WorkshopFee money NOT NULL,
	WorkshopStart time NOT NULL,
	WorkshopEnd time NOT NULL,
	PRIMARY KEY (WorkshopID));
```
<h6>WorkshopsReservations - przechowuje infomacje o rezerwacjach miejsc na warsztaty przez klientó. Zawiera pola:
* WorkshopReservationID - identyfikator rezerwacji na warsztat, unikatowy, zaczyna się od 1, inkrementowany o 1
* DayReservationID - identyfikator rezerwacji klienta na dany dzień
* WorkshopID - identyfikator warsztatu
* NormalReservations - ilość zarezerwowanych miejsc. Musi być większa od zera
</h6>
```sql
CREATE TABLE WorkshopsReservations (
	WorkshopReservationID int IDENTITY(1,1) NOT NULL,
	DayReservationID int NOT NULL,
	WorkshopID int NOT NULL,
	NormalReservations int NOT NULL CHECK (NormalReservations > 0),
	PRIMARY KEY (WorkshopReservationID));
```

```sql
-- =========================================
-- Creating Keys
-- =========================================

ALTER TABLE WorkshopsReservations
	ADD CONSTRAINT FKWorkshopsResToDaysRes
	FOREIGN KEY (DayReservationID) REFERENCES DaysReservations (DayReservationID);

ALTER TABLE WorkshopsReservations
	ADD CONSTRAINT FKWorkshopsResToWorkshops
	FOREIGN KEY (WorkshopID) REFERENCES Workshops (WorkshopID);

ALTER TABLE ParticipantReservations
	ADD CONSTRAINT FKParticipantResToDaysRes
	FOREIGN KEY (DayReservationID) REFERENCES DaysReservations (DayReservationID);

ALTER TABLE ParticipantReservations
	ADD CONSTRAINT FKParticipantResToParticipants
	FOREIGN KEY (ParticipantID) REFERENCES Participants (ParticipantID);

ALTER TABLE ParticipantWorkshops
	ADD CONSTRAINT FKParticipantWorksToParticipantRes
	FOREIGN KEY (ParticipantReservationID) REFERENCES ParticipantReservations (ParticipantReservationID);

ALTER TABLE ParticipantWorkshops
	ADD CONSTRAINT FKParticipantWorksToWorkshops
	FOREIGN KEY (WorkshopID) REFERENCES Workshops (WorkshopID);

ALTER TABLE ClientReservations
	ADD CONSTRAINT FKClientResToClients
	FOREIGN KEY (ClientID) REFERENCES Clients (ClientID);

ALTER TABLE ClientReservations
	ADD CONSTRAINT FKClientResToConferences
	FOREIGN KEY (ConferenceID) REFERENCES Conferences (ConferenceID);

ALTER TABLE DaysReservations
	ADD CONSTRAINT FKDaysResToClientRes
	FOREIGN KEY (ClientReservationID) REFERENCES ClientReservations (ClientReservationID);

ALTER TABLE Payments
	ADD CONSTRAINT FKPaymentsToClientRes
	FOREIGN KEY (PaymentID) REFERENCES ClientReservations (ClientReservationID);

ALTER TABLE PriceList
	ADD CONSTRAINT FKPriceListToConferences
	FOREIGN KEY (ConferenceID) REFERENCES Conferences (ConferenceID);

ALTER TABLE Workshops
	ADD CONSTRAINT FKWorkshopsToConferences
	FOREIGN KEY (ConferenceID) REFERENCES Conferences (ConferenceID);
```
```sql
-- =========================================
-- Drop code
-- =========================================

ALTER TABLE WorkshopsReservations
	DROP CONSTRAINT FKWorkshopsResToDaysRes;

ALTER TABLE WorkshopsReservations 
	DROP CONSTRAINT FKWorkshopsResToWorkshops;

ALTER TABLE ParticipantReservations
	DROP CONSTRAINT FKParticipantResToDaysRes;

ALTER TABLE ParticipantReservations
	DROP CONSTRAINT FKParticipantResToParticipants;

ALTER TABLE ParticipantWorkshops
	DROP CONSTRAINT FKParticipantWorksToParticipantRes;

ALTER TABLE ParticipantWorkshops
	DROP CONSTRAINT FKParticipantWorksToWorkshops;

ALTER TABLE ClientReservations
	DROP CONSTRAINT FKClientResToClients;

ALTER TABLE ClientReservations
	DROP CONSTRAINT FKClientResToConferences;

ALTER TABLE DaysReservations
	DROP CONSTRAINT FKDaysResToClientRes;

ALTER TABLE Payments
	DROP CONSTRAINT FKPaymentsToClientRes;

ALTER TABLE PriceList
	DROP CONSTRAINT FKPriceListToConferences;

ALTER TABLE Workshops
	DROP CONSTRAINT FKWorkshopsToConferences;

DROP TABLE ClientReservations;
DROP TABLE Clients;
DROP TABLE Conferences;
DROP TABLE DaysReservations;
DROP TABLE ParticipantReservations;
DROP TABLE Participants;
DROP TABLE ParticipantWorkshops;
DROP TABLE Payments;
DROP TABLE PriceList;
DROP TABLE Workshops;
DROP TABLE WorkshopsReservations;
```



<a name="Triggery">
#Triggery
</a>

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```







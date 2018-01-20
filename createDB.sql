-- =========================================
-- Creating Tables
-- =========================================

CREATE TABLE ClientReservations (
	ClientReservationID int IDENTITY(1,1) NOT NULL,
	ConferenceID int NOT NULL,
	ClientID int NOT NULL,
	ReservationDate date NOT NULL DEFAULT Convert(date, getdate()),
	IsCancelled bit NOT NULL DEFAULT 0,
	PRIMARY KEY (ClientReservationID));

CREATE TABLE Clients (
	ClientID int IDENTITY(1,1) NOT NULL,
	ClientName varchar(50) NOT NULL,
	ClientSurname varchar(50) NULL,
	IsPrivate bit NOT NULL DEFAULT 0,
	PhoneNumber int NOT NULL CHECK (PhoneNumber like '[1-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	Email varchar(50) NOT NULL CHECK (Email like '_%[@]_%'),
	Address varchar(50) NOT NULL,
	City varchar(50) NOT NULL,
	PostalCode int NOT NULL,
	Country varchar(30) NOT NULL,
	PRIMARY KEY (ClientID));

CREATE TABLE Conferences (
	ConferenceID int IDENTITY(1,1) NOT NULL,
	ConferenceName varchar(50) NOT NULL,
	StartDate date NOT NULL,
	EndDate date NOT NULL,
	Places int NOT NULL CHECK (Places > 0),
	Discount float(10) NOT NULL DEFAULT 0 CHECK (Discount <= 1),
	PRIMARY KEY (ConferenceID));

CREATE TABLE DaysReservations (
	DayReservationID int IDENTITY(1,1) NOT NULL,
	ClientReservationID int NOT NULL,
	ConferenceDay int NOT NULL CHECK (ConferenceDay > 0),
	NormalReservations int NOT NULL CHECK (NormalReservations > 0),
	StudentsReservations int NOT NULL DEFAULT 0,
	IsCancelled bit NOT NULL DEFAULT 0,
	PRIMARY KEY (DayReservationID));

CREATE TABLE ParticipantReservations (
	ParticipantReservationID int IDENTITY(1,1) NOT NULL,
	ParticipantID int NOT NULL,
	DayReservationID int NOT NULL,
	StudentCard int NULL,
	StudentCardDate date NULL,
	IsCancelled bit NOT NULL DEFAULT 0,
	PRIMARY KEY (ParticipantReservationID));

CREATE TABLE Participants (
	ParticipantID int IDENTITY(1,1) NOT NULL,
	Name varchar(50) NOT NULL,
	Surname varchar(50) NOT NULL,
	PhoneNumber int NOT NULL CHECK (PhoneNumber like '[1-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	Email varchar(50) NOT NULL CHECK (Email like '_%[@]_%'),
	City varchar(50) NOT NULL,
	Country varchar(50) NOT NULL,
	PRIMARY KEY (ParticipantID));

CREATE TABLE ParticipantWorkshops (
	WorkshopReservationID int IDENTITY(1,1) NOT NULL,
	ParticipantReservationID int NOT NULL,
	WorkshopID int NOT NULL,
	IsCancelled bit NOT NULL DEFAULT 0,
	PRIMARY KEY (WorkshopReservationID));

CREATE TABLE Payments (
	PaymentID int IDENTITY(1,1) NOT NULL,
	FineAssessed money NOT NULL DEFAULT 0,
	FinePaid money NOT NULL DEFAULT 0,
	DueDate date NOT NULL DEFAULT DATEADD( day, 7, Convert(date, getdate())),
	PRIMARY KEY (PaymentID));

CREATE TABLE PriceList (
	PriceID int IDENTITY(1,1) NOT NULL,
	ConferenceID int NOT NULL,
	PriceValue money NOT NULL,
	PriceDate date NOT NULL,
	PRIMARY KEY (PriceID));

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

CREATE TABLE WorkshopsReservations (
	WorkshopReservationID int IDENTITY(1,1) NOT NULL,
	DayReservationID int NOT NULL,
	WorkshopID int NOT NULL,
	NormalReservations int NOT NULL CHECK (NormalReservations > 0),
	IsCancelled bit NOT NULL DEFAULT 0,
	PRIMARY KEY (WorkshopReservationID));

-- =========================================
-- Adding Foreign Keys
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
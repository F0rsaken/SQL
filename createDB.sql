CREATE TABLE ClientReservations (
	ClientReservationID int IDENTITY NOT NULL,
	ConferenceID int NOT NULL, ClientID int NOT NULL,
	ReservationDate date NOT NULL,
	PRIMARY KEY (ClientReservationID));

CREATE TABLE Clients (
	ClientID int IDENTITY NOT NULL,
	ConferenceID int NOT NULL,
	ClientName varchar(50) NOT NULL,
	ClientSurname varchar(50) NULL,
	IsPrivate bit NOT NULL,
	PhoneNumber int NOT NULL,
	Email varchar(50) NOT NULL,
	Address varchar(50) NOT NULL,
	City varchar(50) NOT NULL,
	PostalCode int NOT NULL,
	Country varchar(30) NOT NULL,
	PRIMARY KEY (ClientID));

CREATE TABLE Conferences (
	ConferenceID int IDENTITY NOT NULL,
	ConferenceName varchar(50) NOT NULL,
	StartDate date NOT NULL,
	EndDate date NOT NULL,
	Dicount float(10) NOT NULL,
	PRIMARY KEY (ConferenceID));

CREATE TABLE DaysReservations (
	DayReservationID int IDENTITY NOT NULL,
	ClientReservationID int NOT NULL, 
	ConferenceDay int NOT NULL,
	NormalReservations int NOT NULL,
	StudentsReservations int NOT NULL,
	PRIMARY KEY (DayReservationID));

CREATE TABLE ParticipantReservations (
	ParticipantReservationID int IDENTITY NOT NULL,
	ParticipantID int NOT NULL,
	DayReservationID int NOT NULL,
	StudentCard int NULL,
	StudentCardDate date NULL,
	PRIMARY KEY (ParticipantReservationID));

CREATE TABLE Participants (
	ParticipantID int IDENTITY NOT NULL,
	ClientID int NOT NULL, Name varchar(50) NOT NULL,
	Surname varchar(50) NOT NULL,
	PhoneNumber int NOT NULL,
	Email varchar(50) NOT NULL,
	City varchar(50) NOT NULL,
	Country varchar(50) NOT NULL,
	DiscountGranted bit NOT NULL,
	PRIMARY KEY (ParticipantID));

CREATE TABLE ParticipantWorkshops (
	WorkshopReservationID int IDENTITY NOT NULL,
	ParticipantReservationID int NOT NULL,
	WorkshopID int NOT NULL,
	PRIMARY KEY (WorkshopReservationID));

CREATE TABLE Payments (
	PaymentID int NOT NULL,
	FineAssessed money NOT NULL,
	FinePaid money NOT NULL,
	DueDate date NOT NULL,
	PRIMARY KEY (PaymentID));

CREATE TABLE PriceList (
	PriceID int IDENTITY NOT NULL,
	ConferenceID int NOT NULL,
	PriceValue money NOT NULL,
	PriceDate date NOT NULL,
	PRIMARY KEY (PriceID));

CREATE TABLE Workshops (
	WorkshopID int IDENTITY NOT NULL,
	ConferenceID int NOT NULL,
	ConferenceDay int NOT NULL,
	WorkshopName varchar(50) NOT NULL,
	Places int NOT NULL,
	WorkshopFee money NOT NULL,
	WorkshopStart time NOT NULL,
	WorkshopEnd time NOT NULL,
	PRIMARY KEY (WorkshopID));

CREATE TABLE WorkshopsReservations (
	WorkshopReservationID int IDENTITY NOT NULL,
	DayReservationID int NOT NULL,
	WorkshopID int NOT NULL,
	NormalReservations int NOT NULL,
	PRIMARY KEY (WorkshopReservationID));


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
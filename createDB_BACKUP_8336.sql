-- =========================================
-- Creating Tables
-- =========================================

CREATE TABLE ClientReservations (
<<<<<<< HEAD
	ClientReservationID int IDENTITY NOT NULL,
	ConferenceID int NOT NULL,
	ClientID int NOT NULL,
	ReservationDate date NOT NULL,
	IsCancelled bit NOT NULL DEFAULT 0,
=======
	ClientReservationID int IDENTITY(1,1) NOT NULL,
	ConferenceID int NOT NULL,
	ClientID int NOT NULL,
	ReservationDate date NOT NULL DEFAULT Convert(date, getdate()),
>>>>>>> d36ba0ac720f89d35b382bd76aca30a8069fdff8
	PRIMARY KEY (ClientReservationID));

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

CREATE TABLE Conferences (
	ConferenceID int IDENTITY(1,1) NOT NULL,
	ConferenceName varchar(50) NOT NULL,
	StartDate date NOT NULL,
	EndDate date NOT NULL,
<<<<<<< HEAD
	Dicount float(10) NOT NULL,
	Places int NOT NULL CHECK (Places > 0),
=======
	Discount float(4) NOT NULL DEFAULT 0 CHECK (Discount <= 1),
>>>>>>> d36ba0ac720f89d35b382bd76aca30a8069fdff8
	PRIMARY KEY (ConferenceID));

CREATE TABLE DaysReservations (
	DayReservationID int IDENTITY(1,1) NOT NULL,
	ClientReservationID int NOT NULL, 
	ConferenceDay int NOT NULL,
	NormalReservations int NOT NULL CHECK (NormalReservations > 0),
	StudentsReservations int NOT NULL DEFAULT 0,
	PRIMARY KEY (DayReservationID));

CREATE TABLE ParticipantReservations (
	ParticipantReservationID int IDENTITY(1,1) NOT NULL,
	ParticipantID int NOT NULL,
	DayReservationID int NOT NULL,
	StudentCard int NULL,
	StudentCardDate date NULL,
	PRIMARY KEY (ParticipantReservationID));

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

CREATE TABLE ParticipantWorkshops (
	WorkshopReservationID int IDENTITY(1,1) NOT NULL,
	ParticipantReservationID int NOT NULL,
	WorkshopID int NOT NULL,
	PRIMARY KEY (WorkshopReservationID));

CREATE TABLE Payments (
	PaymentID int IDENTITY(1,1) NOT NULL,
	FineAssessed money NOT NULL,
	FinePaid money NOT NULL DEFAULT 0,
	DueDate date NOT NULL,
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
	PRIMARY KEY (WorkshopReservationID));
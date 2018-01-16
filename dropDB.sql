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

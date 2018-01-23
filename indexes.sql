USE mmandows_a

CREATE INDEX I_Clients ON Clients (ClientID)
CREATE INDEX I_ClientReservations ON ClientReservations (ClientReservationID)
CREATE INDEX I_Payments ON Payments (PaymentID)
CREATE INDEX I_Participants ON Participants (ParticipantID)
CREATE INDEX I_PriceList ON PriceList (PriceID)
CREATE INDEX I_Conferences ON Conferences (ConferenceID)
CREATE INDEX I_Workshops ON Workshops (WorkshopID)
CREATE INDEX I_DaysReservations ON DaysReservations (DayReservationID)
CREATE INDEX I_WorkshopsReservations ON WorkshopsReservations (WorkshopReservationID)
CREATE INDEX I_ParticipantEmail ON Participants (Email)
CREATE INDEX I_ClientEmail ON Clients (Email)

DROP INDEX I_Clients ON Clients
DROP INDEX I_ClientReservations ON ClientReservations
DROP INDEX I_Payments ON Payments
DROP INDEX I_Participants ON Participants
DROP INDEX I_PriceList ON PriceList
DROP INDEX I_Conferences ON Conferences
DROP INDEX I_Workshops ON Workshops
DROP INDEX I_DaysReservations ON DaysReservations
DROP INDEX I_WorkshopsReservations ON WorkshopsReservations
DROP INDEX I_ParticipantEmail ON Participants
DROP INDEX I_ClientEmail ON Clients
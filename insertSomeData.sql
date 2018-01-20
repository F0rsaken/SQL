insert into Clients
	values ('X', 'X1', 1, 123123123, 'x1@gmail.com', 'x1x1', 'x1x1', 123123, 'x1x1');
insert into Clients
	values ('Y', 'Y1', 1, 123123123, 'y1@gmail.com', 'y1y1', 'y1y1', 123123, 'y1y1');
insert into Clients
	values ('Z', 'Z1', 1, 123123123, 'z1@gmail.com', 'z1z1', 'z1z1', 123123, 'z1z1');

insert into Conferences
	values ('1', '2001-01-19', '2001-01-21', 20, 0.0)
insert into Conferences
	values ('2', '2001-07-01', '2001-07-06', 40, 0.0)
insert into Conferences
	values ('3', '2001-03-22', '2001-03-25', 30, 0.0)

insert into ClientReservations(ConferenceID, ClientID)
	values (1, 1)
insert into ClientReservations(ConferenceID, ClientID)
	values (2, 1)
insert into ClientReservations(ConferenceID, ClientID)
	values (3, 1)
insert into ClientReservations(ConferenceID, ClientID)
	values (1, 2)
insert into ClientReservations(ConferenceID, ClientID)
	values (2, 2)
insert into ClientReservations(ConferenceID, ClientID)
	values (1, 3)

insert into Workshops
	values (1, 1, 'X1', 10, 20, '8:00', '9:00')
insert into Workshops
	values (1, 2, 'X2', 10, 20, '8:00', '9:00')
insert into Workshops
	values (1, 2, 'X3', 10, 20, '10:00', '12:00')
insert into Workshops
	values (2, 1, 'Y1', 10, 20, '8:00', '9:00')
insert into Workshops
	values (2, 1, 'Y1', 10, 20, '10:00', '18:00')
insert into Workshops
	values (3, 1, 'Z1', 10, 20, '8:00', '9:00')
insert into Workshops
	values (3, 1, 'Z1', 10, 20, '8:00', '9:00')
insert into Workshops
	values (3, 1, 'Z1', 10, 20, '8:00', '9:00')

insert into Participants
	values ('x1', 'x1', 111111111, 'x1@gmail.com', 'xyz', 'Xyz')
insert into Participants
	values ('x2', 'x2', 111111112, 'x2@gmail.com', 'xyz', 'Xyz')
insert into Participants
	values ('x3', 'x3', 111111113, 'x3@gmail.com', 'xyz', 'Xyz')
insert into Participants
	values ('x4', 'x4', 111111114, 'x4@gmail.com', 'xyz', 'Xyz')
insert into Participants
	values ('x5', 'x5', 111111115, 'x5@gmail.com', 'xyz', 'Xyz')
insert into Participants
	values ('x6', 'x6', 111111116, 'x6@gmail.com', 'xyz', 'Xyz')

insert into DaysReservations
	values (1, 1, 20, 10, 0)
insert into DaysReservations
	values (1, 2, 20, 10, 0)
insert into DaysReservations
	values (1, 3, 20, 10, 0)
insert into DaysReservations
	values (2, 1, 20, 10, 0)
insert into DaysReservations
	values (2, 2, 20, 10, 0)
insert into DaysReservations
	values (2, 3, 20, 10, 0)
insert into DaysReservations
	values (3, 1, 20, 10, 0)
insert into DaysReservations
	values (3, 2, 20, 10, 0)
insert into DaysReservations
	values (3, 3, 20, 10, 0)
insert into DaysReservations
	values (4, 1, 20, 10, 0)
insert into DaysReservations
	values (4, 2, 20, 10, 0)
insert into DaysReservations
	values (5, 1, 20, 10, 0)
insert into DaysReservations
	values (5, 2, 20, 10, 0)
insert into DaysReservations
	values (6, 1, 20, 10, 0)
insert into DaysReservations
	values (6, 2, 20, 10, 0)

insert into ParticipantReservations
	values (1, 1, null, null, 0)
insert into ParticipantReservations
	values (1, 2, null, null, 0)
insert into ParticipantReservations
	values (1, 3, null, null, 0)
insert into ParticipantReservations
	values (2, 1, null, null, 0)
insert into ParticipantReservations
	values (2, 2, null, null, 0)
insert into ParticipantReservations
	values (2, 3, null, null, 0)
insert into ParticipantReservations
	values (3, 1, null, null, 0)
insert into ParticipantReservations
	values (3, 2, null, null, 0)
insert into ParticipantReservations
	values (3, 3, null, null, 0)

insert into ParticipantReservations
	values (1, 4, null, null, 0)
insert into ParticipantReservations
	values (1, 5, null, null, 0)
insert into ParticipantReservations
	values (1, 6, null, null, 0)
insert into ParticipantReservations
	values (2, 4, null, null, 0)
insert into ParticipantReservations
	values (2, 5, null, null, 0)
insert into ParticipantReservations
	values (2, 6, null, null, 0)
insert into ParticipantReservations
	values (3, 4, null, null, 0)
insert into ParticipantReservations
	values (3, 5, null, null, 0)
insert into ParticipantReservations
	values (3, 6, null, null, 0)

insert into ParticipantReservations
	values (1, 7, null, null, 0)
insert into ParticipantReservations
	values (1, 8, null, null, 0)
insert into ParticipantReservations
	values (1, 9, null, null, 0)
insert into ParticipantReservations
	values (2, 7, null, null, 0)
insert into ParticipantReservations
	values (2, 8, null, null, 0)
insert into ParticipantReservations
	values (2, 9, null, null, 0)
insert into ParticipantReservations
	values (3, 7, null, null, 0)
insert into ParticipantReservations
	values (3, 8, null, null, 0)
insert into ParticipantReservations
	values (3, 9, null, null, 0)

insert into ParticipantReservations
	values (4, 10, null, null, 0)
insert into ParticipantReservations
	values (4, 11, null, null, 0)
insert into ParticipantReservations
	values (5, 10, null, null, 0)
insert into ParticipantReservations
	values (5, 11, null, null, 0)

insert into ParticipantReservations
	values (4, 12, null, null, 0)
insert into ParticipantReservations
	values (4, 13, null, null, 0)
insert into ParticipantReservations
	values (5, 12, null, null, 0)
insert into ParticipantReservations
	values (5, 13, null, null, 0)

insert into ParticipantReservations
	values (6, 14, null, null, 0)
insert into ParticipantReservations
	values (6, 15, null, null, 0)

insert into ParticipantWorkshops
	values (1, 1, 0)
insert into ParticipantWorkshops
	values (2, 2, 0)
insert into ParticipantWorkshops
	values (2, 3, 0)

insert into ParticipantWorkshops
	values (4, 1, 0)
insert into ParticipantWorkshops
	values (7, 1, 0)

insert into ParticipantWorkshops
	values (10, 4, 0)
insert into ParticipantWorkshops
	values (10, 5, 0)

insert into ParticipantWorkshops
	values (13, 4, 0)
insert into ParticipantWorkshops
	values (13, 5, 0)

insert into ParticipantWorkshops
	values (32, 4, 0)
insert into ParticipantWorkshops
	values (32, 5, 0)

insert into ParticipantWorkshops
	values (34, 4, 0)
insert into ParticipantWorkshops
	values (34, 5, 0)

insert into PriceList
	values (1, 50, '2000-10-01')
insert into PriceList
	values (1, 60, '2000-12-01')
insert into PriceList
	values (1, 70, '2001-01-18')


insert into PriceList
	values (2, 20, '2001-03-01')
insert into PriceList
	values (2, 30, '2001-05-01')
insert into PriceList
	values (2, 50, '2001-06-30')


insert into PriceList
	values (3, 100, '2000-11-22')
insert into PriceList
	values (3, 140, '2001-01-22')
insert into PriceList
	values (3, 200, '2001-03-21')
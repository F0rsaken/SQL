DROP PROCEDURE P_AddClient
DROP PROCEDURE P_AddConference
DROP PROCEDURE P_AddParticipant
DROP PROCEDURE P_AddParticipantForConferenceDay
DROP PROCEDURE P_AddParticipantForWorkshop
DROP PROCEDURE P_AddPriceToConferencePriceList
DROP PROCEDURE P_AddReservationForConference
DROP PROCEDURE P_AddReservationForConferenceDay
DROP PROCEDURE P_AddReservationForWorkshop
DROP PROCEDURE P_AddWorkshop
DROP PROCEDURE P_CancelConferenceReservation
DROP PROCEDURE P_CancelDayReservation
DROP PROCEDURE P_CancelParticipantReservation
DROP PROCEDURE P_CancelParticipantWorkshopReservation
DROP PROCEDURE P_CancelUnpaiedReservation
DROP PROCEDURE P_CancelWorkshopResrvation
DROP PROCEDURE P_ChangeConferenceDetails
DROP PROCEDURE P_ChangeDayReservationPlaces
DROP PROCEDURE P_ChangeWorkshopDetails
DROP PROCEDURE P_ChangeWorkshopReservationPlaces
DROP PROCEDURE P_CheckCurrentPayment
DROP PROCEDURE P_CountFine
DROP PROCEDURE P_DeletePriceFromConferencePriceList


DROP FUNCTION F_AllPaymentsByClientID
DROP FUNCTION F_ClientReservationsHistory
DROP FUNCTION F_ClientsWithUnusedPlaces
DROP FUNCTION F_ConferenceParticipants
DROP FUNCTION F_CreatePeopleIdentifiers
DROP FUNCTION F_FreeAndReservedPlacesForConference
DROP FUNCTION F_FreeAndReservedPlacesForWorkshop
DROP FUNCTION F_NonregulatedPaymentsByClientID
DROP FUNCTION F_ParticipantsListForConferenceDay
DROP FUNCTION F_ParticipantsListForWorkshop
DROP FUNCTION F_RegulatedPaymentsByClientID
DROP FUNCTION F_ShowPrices
DROP FUNCTION F_ShowWorkshops
DROP FUNCTION F_GetCurrentPrice


DROP TRIGGER T_CancelAllDaysReservations
DROP TRIGGER T_NoFreePlacesForAnyConferenceDay
DROP TRIGGER T_ControlClientSurnameAndIsPrivateStatus
DROP TRIGGER T_ControlUpdatingPlacesForConference
DROP TRIGGER T_CancelAllParticipantConferenceDayReservations
DROP TRIGGER T_CancelAllWorkshopsReservations
DROP TRIGGER T_NoPlacesForConferenceDay
DROP TRIGGER T_CancelAllParticipantWorkshopsReservations1
DROP TRIGGER T_CheckIfParticipantCanBeAdded
DROP TRIGGER T_CheckPriceListInsert
DROP TRIGGER T_CheckIfWorkshopDayBelongsToConferenceDay
DROP TRIGGER T_ControlPlacesForWorkshop
DROP TRIGGER T_CancelAllParticipantWorkshopsReservations2
DROP TRIGGER T_ControlUpdatingPlacesForWorkshop

DROP VIEW V_MostFrequentClients
DROP VIEW V_MostProfitableClients
DROP VIEW V_UnpayedCancelledReservations
DROP VIEW V_UnpayedNotCancelledReservations
DROP VIEW V_OverPayedReservations
DROP VIEW V_PayedReservations
DROP VIEW V_CancelledConferencesReseravtions
DROP VIEW V_ClientsList
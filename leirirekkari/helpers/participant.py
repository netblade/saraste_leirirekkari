from leirirekkari.models.dbsession import DBSession
from leirirekkari.models.setting import Setting
from leirirekkari.models.organization import (
    Club,
    SubUnit,
    Village,
    Subcamp,
    VillageKitchen,
    )

from sqlalchemy import func

from leirirekkari.models.participant import (
    Participant,
    ParticipantPhone,
    ParticipantNextOfKin,
    ParticipantLanguage,
    ParticipantPayment,
    ParticipantWishes,
    ParticipantWishesOption,
    ParticipantSignupOption,
    ParticipantMedical,
    ParticipantMedicalDiet,
    ParticipantMedicalFoodAllergy,
    ParticipantMedicalAllergy,
    ParticipantAddress,
    ParticipantMeta,
    ParticipantPresence,
    ParticipantStatus,
    ParticipantEnlistment,
    ParticipantEnlistmentOption,
    ParticipantPolkuBookings,
    ParticipantPolkuAnswers,
    ParticipantPolkuContactInfo,
    )

def getParticipant(obj_id):
    return DBSession.query(Participant).get(obj_id)


def getParticipantName(obj_id):
    if obj_id == 0 or obj_id== None:
        return '--'
    participant = getParticipant(obj_id)
    if participant != None:
        return participant.firstname + ' ' + participant.lastname
    else:
        return ''
        
def getParticipantNickName(obj_id):
    participant = getParticipant(obj_id)
    if participant != None:
        return participant.nickname
    else:
        return ''

def getAvailableAllergies():
    participantMedicalAllergies = DBSession.query(ParticipantMedicalAllergy).order_by(ParticipantMedicalAllergy.name).all()
    return participantMedicalAllergies
    
def getAvailableFoodAllergies():
    participantMedicalFoodAllergies = DBSession.query(ParticipantMedicalFoodAllergy).order_by(ParticipantMedicalFoodAllergy.name).all()
    return participantMedicalFoodAllergies
    
def getAvailableDiets():
    participantMedicalDiets = DBSession.query(ParticipantMedicalDiet).order_by(ParticipantMedicalDiet.name).all()
    return participantMedicalDiets
    
def getPeoplePresenceCounts(dt, club=0, subunit=0, village=0, subcamp=0, village_kitchen=0):
    
    report = DBSession.query(Participant.id)
    
    if club != 0:
        report = report.filter(Participant.club_id == club)
    if subunit != 0:
        report = report.filter(Participant.subunit_id == subunit)
    if village != 0:
        report = report.filter(Participant.village_id == village)
    if subcamp != 0:
        report = report.filter(Participant.subcamp_id == subcamp)
    if village_kitchen != 0:
        village_kitchen = DBSession.query(VillageKitchen).get(village_kitchen)
        if village_kitchen != None:
            village_ids = []
            if len(village_kitchen.villages)>0:
                for village in village_kitchen.villages:
                    village_ids.append(village.id)
                report = report.filter(Participant.village_id.in_(village_ids))
    
    report = report.filter(Participant.active == True)
    report = report.filter(Participant.latest_status_key != 200)
    
    report = report.join(ParticipantPresence).filter(ParticipantPresence.presence_starts <= dt, ParticipantPresence.presence_ends >= dt)
    
    
    participants_count = report.count()
    
    return participants_count
    
def getPeoplePresenceCountsByAgegroup(dt, club=0, subunit=0, village=0, subcamp=0):

    agegroups = {
        0:0,
        1:0,
        2:0,
        3:0,
        4:0,
        5:0,
        6:0,
        7:0,
    }

    report = DBSession.query(Participant.age_group, func.count(Participant.age_group))

    if club != 0:
        report = report.filter(Participant.club_id == club)
    if subunit != 0:
        report = report.filter(Participant.subunit_id == subunit)
    if village != 0:
        report = report.filter(Participant.village_id == village)
    if subcamp != 0:
        report = report.filter(Participant.subcamp_id == subcamp)

    report = report.filter(Participant.active == True)
    report = report.filter(Participant.latest_status_key != 200)

    report = report.join(ParticipantPresence).filter(ParticipantPresence.presence_starts <= dt, ParticipantPresence.presence_ends >= dt)

    report = report.group_by(Participant.age_group)

    participants_count = report.all()
    
    for count in participants_count:
        agegroups[count[0]] = count[1]

    return agegroups

def getParticipantEnlistmentOption(obj_id):
    if obj_id == 0 or obj_id == None:
        return None
    return DBSession.query(ParticipantEnlistmentOption).get(obj_id)

def getEnlistmentName(obj_id):
    if obj_id == 0 or obj_id == None:
        return None
    option = getParticipantEnlistmentOption(obj_id)
    if option != None:
        return option.name
    else:
        return False
        
def countPaymentSums(participant):
    ret = {
        'payments_total':0,
        'paid_total':0,
        'to_pay_total':0
    }
    if len(participant.payment_data) > 0:
        for payment in participant.payment_data:
            ret['payments_total'] += payment.euros
            if payment.paid:
                ret['paid_total'] += payment.euros
            else:
                ret['to_pay_total'] += payment.euros
    
    return ret
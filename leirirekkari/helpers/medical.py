from datetime import datetime

from leirirekkari.models.dbsession import DBSession

from leirirekkari.models.medical import (
    MedicalCard,
    MedicalCardEvent,
    MedicalParticipantStatus,
    MedicalParticipantAdditional,
    MedicalReason,
    MedicalTreatmentType,
    MedicalMethodOfArrival,
    )

def getReasonById(obj_id):
    if obj_id == 0 or obj_id == None:
        return None
    return DBSession.query(MedicalReason).get(obj_id)

def getReasonTitle(obj_id, null_ret = ''):
    if obj_id == 0 or obj_id == None:
        return null_ret
    obj = getReasonById(obj_id)
    if obj != None:
        return obj.title
    else:
        return null_ret

def getTreatmentTypeById(obj_id):
    if obj_id == 0 or obj_id == None:
        return None
    return DBSession.query(MedicalTreatmentType).get(obj_id)

def getTreatmentTypeTitle(obj_id, null_ret = ''):
    if obj_id == 0 or obj_id == None:
        return null_ret
    obj = getTreatmentTypeById(obj_id)
    if obj != None:
        return obj.title
    else:
        return null_ret
    
def getMethodOfArrivalById(obj_id):
    if obj_id == 0 or obj_id == None:
        return None
    return DBSession.query(MedicalTreatmentType).get(obj_id)
    
def getMethodOfArrivalTitle(obj_id, null_ret = ''):
    if obj_id == 0 or obj_id == None:
        return null_ret
    obj = getMethodOfArrivalById(obj_id)
    if obj != None:
        return obj.title
    else:
        return null_ret
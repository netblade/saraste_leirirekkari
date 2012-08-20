# -*- coding: utf-8 -*-
from leirirekkari.models.dbsession import DBSession
from leirirekkari.models.setting import Setting
from leirirekkari.models.organization import (
    Club,
    SubUnit,
    Village,
    VillageKitchen,
    Subcamp,
    )

def getClub(obj_id):
    if obj_id == 0 or obj_id == None:
        return None
    return DBSession.query(Club).get(obj_id)

def getClubByName(name):
    if name == '':
        return None
    return DBSession.query(Club).filter(Club.name==name).first()

def getClubs():
    return DBSession.query(Club).order_by(Club.name).all()

def getClubName(obj_id):
    if obj_id == 0 or obj_id == None:
        return None
    club = getClub(obj_id)
    if club != None:
        return club.name
    else:
        return ''
        
def getSubUnit(obj_id):
    if obj_id == 0 or obj_id == None:
        return None
    return DBSession.query(SubUnit).get(obj_id)

def getSubUnitByName(name):
    if name == '':
        return None
    return DBSession.query(SubUnit).filter(SubUnit.name==name).first()

def getSubUnits():
    return DBSession.query(SubUnit).order_by(SubUnit.name).all()

def getSubUnitName(obj_id):
    if obj_id == 0 or obj_id == None:
        return None
    subUnit = getSubUnit(obj_id)
    if subUnit != None:
        return subUnit.name
    else:
        return False
        
def getVillage(obj_id):
    if obj_id == 0 or obj_id == None:
        return None
    return DBSession.query(Village).get(obj_id)

def getVillageByName(name):
    if name == '':
        return None
    return DBSession.query(Village).filter(Village.name==name).first()

def getVillages():
    return DBSession.query(Village).order_by(Village.name).all()

def getVillageName(obj_id):
    if obj_id == 0 or obj_id == None:
        return None
    village = getVillage(obj_id)
    if village != None:
        return village.name
    else:
        return False
        
        
def getVillageKitchen(obj_id):
    if obj_id == 0 or obj_id == None:
        return None
    return DBSession.query(VillageKitchen).get(obj_id)

def getVillageKitchenByName(name):
    if name == '':
        return None
    return DBSession.query(VillageKitchen).filter(VillageKitchen.name==name).first()

def getVillageKitchens():
    return DBSession.query(VillageKitchen).order_by(VillageKitchen.name).all()

def getVillageKitchenName(obj_id):
    if obj_id == 0 or obj_id == None:
        return None
    village_kitchen = getVillageKitchen(obj_id)
    if village_kitchen != None:
        return village_kitchen.name
    else:
        return False

def getVillageKitchenByVillage(obj_id):
    village = getVillage(obj_id)
    tmp = DBSession.query(VillageKitchen).filter(VillageKitchen.villages.any(id=obj_id)).first()
    return tmp

def getVillageKitchenNameByVillage(obj_id):
    village_kitchen = getVillageKitchenByVillage(obj_id)
    if village_kitchen != None:
        return village_kitchen.name
    else:
        return ''

def getSubcamp(obj_id):
    if obj_id == 0 or obj_id == None:
        return None
    return DBSession.query(Subcamp).get(obj_id)

def getSubcampByName(name):
    if name == '':
        return None
    return DBSession.query(Subcamp).filter(Subcamp.name==name).first()

def getSubcamps():
    return DBSession.query(Subcamp).order_by(Subcamp.name).all()

def getSubcampName(obj_id):
    if obj_id == 0 or obj_id == None:
        return None
    subcamp = getSubcamp(obj_id)
    if subcamp != None:
        return subcamp.name
    else:
        return False
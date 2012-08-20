from datetime import datetime
from dateutil.relativedelta import relativedelta

from sqlalchemy import (
    Table,
    Column,
    Integer,
    Float,
    Text,
	String,
	DateTime,
	Boolean,
    )

from sqlalchemy.ext.declarative import declarative_base

from sqlalchemy import ForeignKey

from sqlalchemy.orm import joinedload_all, subqueryload_all, joinedload, subqueryload

from sqlalchemy.orm import (
    scoped_session,
    sessionmaker,
    relationship,
    backref,
    )

from sqlalchemy.sql.expression import column as expression_column

from leirirekkari.models.dbsession import DBSession, ORMClass, foreign_key_column, Base

from leirirekkari.helpers.helpers import getCurrentUserId

from pyramid.threadlocal import get_current_request

import pyramid.security as security

class ParticipantStatus(Base):
    __tablename__ = 'participant_status'
    id = Column(Integer, primary_key=True)
    participant_id = Column(Integer, ForeignKey('participants.id'), nullable=False)
    status_id = Column(Integer, nullable=False)
    description = Column(Text)
    expected_next_change = Column(DateTime())

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)

class Participant(Base):
    __tablename__ = 'participants'
    id = Column(Integer, primary_key=True)
    firstname = Column(String(255), index=True)
    lastname = Column(String(255), index=True)
    nickname = Column(String(255), index=True)
    title = Column(String(50), index=True)
    birthdate = Column(DateTime(), nullable=False)
    email = Column(String(255), index=True)
    age_group = Column(Integer, nullable=False, default=0, index=True) #0=> unknown, 1=>perheleirin lapsi, 2=>sudari, 3=>Seikkailija, 4=> tarpoja, 5=>samooja, 6=>vaeltaja, 7=> aikuinen 
    active = Column(Boolean, nullable=False, default=1)
    sex = Column(Integer, nullable=False, default=0) # 10 => men, 20 => female
    spiritual = Column(Integer, nullable=False, default=0) # 10 => Ekumeeninen jumalanpalvelus, 20 => Elamankatsomuksellinen ohjelma
    member_no = Column(Integer, nullable=False, default=0, index=True)
    member_id = Column(Integer, nullable=False, default=0, index=True)
    booking_no = Column(String(255), index=True)
    notes = Column(Text)
    sleeping_at = Column(String(255))
    specialities = Column(Text)
    roverway = Column(Integer, nullable=False, default=0)
    pj_course = Column(String(255))
    latest_status_key = Column(Integer, nullable=False, default=0)
    
    club_id = Column(Integer, nullable=False, default=0, index=True)
    subunit_id = Column(Integer, nullable=False, default=0, index=True)
    village_id = Column(Integer, nullable=False, default=0, index=True)
    subcamp_id = Column(Integer, nullable=False, default=0, index=True)
    
    status = None
    wishes = None
    enlistment = None
    
    polku_data = []
    polku_data_searched = False

    phone_data = []
    phone_data_searched = False
    
    address_data = []
    address_data_searched = False
    
    presence_data = []
    presence_data_searched = False
    
    language_data = []
    language_data_searched = False
    
    next_of_kin_data = []
    next_of_kin_data_searched = False
    
    meta_data = []
    meta_data_searched = False
    
    medical_data = None
    medical_data_searched = False
    
    payment_data = []
    payment_data_searched = False

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)
    
    def __init__(self):
        self.active = 1
        self.birthdate = datetime.fromtimestamp(0)
    
    def getParticipantStatus(self):
        self.status = DBSession.query(ParticipantStatus).filter(ParticipantStatus.participant_id==self.id).order_by(ParticipantStatus.metadata_created.desc()).first()
        
    def getParticipantWishes(self):
        self.wishes = DBSession.query(ParticipantWishes).filter(ParticipantWishes.participant_id==self.id).options(joinedload('*')).first()
        
    def getParticipantEnlistment(self):
        self.enlistment = DBSession.query(ParticipantEnlistment).filter(ParticipantEnlistment.participant_id==self.id).options(joinedload('*')).first()
    
    def getParticipantPolkuData(self):
        tmp = DBSession.query(ParticipantPolkuBookings).filter(ParticipantPolkuBookings.participant_id==self.id).options(joinedload('*')).all()
        if tmp != None and len(tmp)>0:
            self.polku_data = tmp
        polku_data_searched = True

    def getParticipantPhoneData(self):
        tmp = DBSession.query(ParticipantPhone).filter(ParticipantPhone.participant_id==self.id).options(joinedload('*')).all()
        if tmp != None and len(tmp)>0:
            self.phone_data = tmp
        phone_data_searched = True

    def getParticipantAddressData(self):
        tmp = DBSession.query(ParticipantAddress).filter(ParticipantAddress.participant_id==self.id).options(joinedload('*')).all()
        if tmp != None and len(tmp)>0:
            self.address_data = tmp
        address_data_searched = True
        
    def getParticipantPaymentData(self):
        tmp = DBSession.query(ParticipantPayment).filter(ParticipantPayment.participant_id==self.id).options(joinedload('*')).all()
        if tmp != None and len(tmp)>0:
            self.payment_data = tmp
        payment_data_searched = True
        
    def getParticipantMetaData(self):
        tmp = DBSession.query(ParticipantMeta).filter(ParticipantMeta.participant_id==self.id).options(joinedload('*')).all()
        if tmp != None and len(tmp)>0:
            self.meta_data = tmp
        meta_data_searched = True

    def getParticipantLanguageData(self):
        tmp = DBSession.query(ParticipantLanguage).filter(ParticipantLanguage.participant_id==self.id).options(joinedload('*')).all()
        if tmp != None and len(tmp)>0:
            self.language_data = tmp
        language_data_searched = True

    def getParticipantPresenceData(self):
        tmp = DBSession.query(ParticipantPresence).filter(ParticipantPresence.participant_id==self.id).options(joinedload('*')).all()
        if tmp != None and len(tmp)>0:
            self.presence_data = tmp
        presence_data_searched = True

    def getParticipantNextOfKinData(self):
        tmp = DBSession.query(ParticipantNextOfKin).filter(ParticipantNextOfKin.participant_id==self.id).options(joinedload('*')).all()
        if tmp != None and len(tmp)>0:
            self.next_of_kin_data = tmp
        next_of_kin_data_searched = True
    
    def getParticipantMedicalData(self):
        request = get_current_request()
        if security.has_permission('office_participant_view_medical', request.context, request) or security.has_permission('medical_view', request.context, request):
            self.medical_data = DBSession.query(ParticipantMedical).filter(ParticipantMedical.participant_id==self.id).options(joinedload('*')).first()
            if self.medical_data == None:
                self.medical_data = ParticipantMedical()
            medical_data_searched = True

class ParticipantPhone(Base):
    __tablename__ = 'participant_phones'
    id = Column(Integer, primary_key=True)
    participant_id = Column(Integer, ForeignKey('participants.id'), nullable=False)
    phone = Column(String(255))
    description = Column(String(255))
    
    def __init__(self, phone = '', participant_id = 0, description = ''):
        self.phone = phone
        self.participant_id = participant_id
        self.description = description

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)

class ParticipantNextOfKin(Base):
    __tablename__ = 'participant_nextofkin'
    id = Column(Integer, primary_key=True)
    participant_id = Column(Integer, ForeignKey('participants.id'), nullable=False)
    primary_name = Column(String(255), index=True)
    primary_phone = Column(String(255), index=True)
    primary_email = Column(String(255), index=True)
    secondary_name = Column(String(255), index=True)
    secondary_phone = Column(String(255), index=True)
    secondary_email = Column(String(255), index=True)

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)
    
class ParticipantLanguage(Base):
    __tablename__ = 'participant_languages'
    id = Column(Integer, primary_key=True)
    participant_id = Column(Integer, ForeignKey('participants.id'), nullable=False, index=True)
    language = Column(String(255), index=True)
    
    def __init__(self, language = '', participant_id = 0):
        self.language = language
        self.participant_id = participant_id

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)

class ParticipantPayment(Base):
    __tablename__ = 'participant_payments'
    id = Column(Integer, primary_key=True)
    participant_id = Column(Integer, ForeignKey('participants.id'), nullable=False, index=True)
    title = Column(String(255), index=True)
    euros = Column(Float, index=True)
    note = Column(Text)
    paid = Column(Boolean, default = False)
    send_invoice = Column(Boolean, default = False)

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)
    
class ParticipantWishesOption(Base):
    __tablename__ = 'participant_wishes_option'
    id = Column(Integer, primary_key=True)
    name = Column(String(255))

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)

class ParticipantWishes(Base):
    __tablename__ = 'participant_wishes'
    id = Column(Integer, primary_key=True)
    participant_id = Column(Integer, ForeignKey('participants.id'), nullable=False)
    activity_1_id = Column(Integer, ForeignKey('participant_wishes_option.id'))
    activity_1 = relationship("ParticipantWishesOption", primaryjoin=(activity_1_id==ParticipantWishesOption.id), backref=backref('activity_1', order_by=id))
    activity_2_id = Column(Integer, ForeignKey('participant_wishes_option.id'))
    activity_2 = relationship("ParticipantWishesOption", primaryjoin=(activity_2_id==ParticipantWishesOption.id), backref=backref('activity_2', order_by=id))
    activity_3_id = Column(Integer, ForeignKey('participant_wishes_option.id'))
    activity_3 = relationship("ParticipantWishesOption", primaryjoin=(activity_3_id==ParticipantWishesOption.id), backref=backref('activity_3', order_by=id))
    preliminary_signups = relationship("ParticipantSignupOption", secondary="assoc_participantwishes_participantsignupoption")

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)
    

class ParticipantSignupOption(Base):
    __tablename__ = 'participant_signup_option'
    id = Column(Integer, primary_key=True)
    name = Column(String(255))

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)


assoc_participantwishes_participantsignupoption = Table("assoc_participantwishes_participantsignupoption", Base.metadata, foreign_key_column("participantwishes_id", Integer, "participant_wishes.id"), foreign_key_column("participantsignupoption_id", Integer, "participant_signup_option.id"))
    
class ParticipantMedical(Base):
    __tablename__ = 'participant_medicals'
    id = Column(Integer, primary_key=True)
    participant_id = Column(Integer, ForeignKey('participants.id'), nullable=False, index=True)
    #diet = Column(Text) # Erityisruokavaliot
    diets = relationship("ParticipantMedicalDiet", secondary="assoc_participantmedical_medicaldiets")
    #food_allergy = Column(Text) # Ruoka-aineallergiat
    food_allergies = relationship("ParticipantMedicalFoodAllergy", secondary="assoc_participantmedical_medicalfoodallergies")
    additional_food = Column(Text) # Lisatiedot, ruoka
    drugs_help = Column(Integer, nullable=False, default=0) # Apua laakityksen ottamiseen
    illnesses = Column(Text) # Sairaudet
    #allergies = Column(Text) # Allergiat
    allergies = relationship("ParticipantMedicalAllergy", secondary="assoc_participantmedical_medicalallergies")
    additional_health = Column(Text) # Terveydentilan lisatiedot
    week_of_pregnancy = Column(String(255)) # Raskausviikot RV leirin aikana

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)

class ParticipantMedicalDiet(Base):
    __tablename__ = 'participant_medical_diets'
    id = Column(Integer, primary_key=True)
    name = Column(String(255))
    
    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)
    
class ParticipantMedicalFoodAllergy(Base):
    __tablename__ = 'participant_medical_food_allergies'
    id = Column(Integer, primary_key=True)
    name = Column(String(255))

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)
    
class ParticipantMedicalAllergy(Base):
    __tablename__ = 'participant_medical_allergies'
    id = Column(Integer, primary_key=True)
    name = Column(String(255))

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)

assoc_participantmedical_medicaldiets = Table("assoc_participantmedical_medicaldiets", Base.metadata, foreign_key_column("participantmedical_id", Integer, "participant_medicals.id"), foreign_key_column("participantmedicaldiet_id", Integer, "participant_medical_diets.id"))
assoc_participantmedical_medicalfoodallergies = Table("assoc_participantmedical_medicalfoodallergies", Base.metadata, foreign_key_column("participantmedical_id", Integer, "participant_medicals.id"), foreign_key_column("participantmedicalfoodallergy_id", Integer, "participant_medical_food_allergies.id"))
assoc_participantmedical_medicalallergies = Table("assoc_participantmedical_medicalallergies", Base.metadata, foreign_key_column("participantmedical_id", Integer, "participant_medicals.id"), foreign_key_column("participantmedicalallergy_id", Integer, "participant_medical_allergies.id"))


class ParticipantAddress(Base):
    __tablename__ = 'participant_address'
    id = Column(Integer, primary_key=True)
    participant_id = Column(Integer, ForeignKey('participants.id'), nullable=False, index=True)
    street = Column(String(255), index=True)
    postalcode = Column(String(255), index=True)
    city = Column(String(255), index=True)
    country = Column(String(255), index=True)
    description = Column(String(255), index=True)
    
    def __init__(self, street = '', postalcode = '', city = '', country = 'Suomi', country_code = 'FI'):
        self.street = street
        self.postalcode = postalcode
        self.city = city
        self.country = country
        self.country_code = country_code
    
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)
    
class ParticipantMeta(Base):
    __tablename__ = 'participant_meta'
    id = Column(Integer, primary_key=True)
    participant_id = Column(Integer, ForeignKey('participants.id'), nullable=False)
    meta_key = Column(String(255), nullable = False, index=True)
    meta_value = Column(Text)
    
    def __init__(self, participant_id = 0, meta_key = '', meta_value = ''):
        self.participant_id = participant_id
        self.meta_key = meta_key
        self.meta_value = meta_value

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)

class ParticipantPresence(Base):
    __tablename__ = 'participant_presence'
    id = Column(Integer, primary_key=True)
    participant_id = Column(Integer, ForeignKey('participants.id'), nullable=False, index=True)
    presence_starts = Column(DateTime(), index=True)
    presence_ends = Column(DateTime(), index=True)
    title = Column(String(255), index=True)
    description = Column(Text)
    
    def __init__(self, starts = datetime.now, ends = None, participant_id = 0, title = '', description = ''):
        self.participant_id = participant_id
        self.presence_starts = starts
        if ends != None and ends > starts:
            self.presence_ends = ends
        else:
            self.presence_ends = starts + relativedelta( days = +1 )
        self.presence_ends = self.presence_ends + relativedelta( seconds = -1 )
        self.title = title
        self.description = description


    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)

class ParticipantEnlistmentOption(Base):
    __tablename__ = 'participant_enlistment_option'
    id = Column(Integer, primary_key=True)
    name = Column(String(255))

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)

class ParticipantEnlistment(Base):
    __tablename__ = 'participant_enlistment'
    id = Column(Integer, primary_key=True)
    participant_id = Column(Integer, ForeignKey('participants.id'), nullable=False)
    job_at_camp = Column(String(255))
    enlisted_by = Column(String(255))
    enlister_works_as = Column(String(255))
    enlistment_table_a_id = Column(Integer, ForeignKey('participant_enlistment_option.id'))
    enlistment_table_a = relationship("ParticipantEnlistmentOption", primaryjoin=(enlistment_table_a_id==ParticipantEnlistmentOption.id), backref=backref('enlistment_table_a', order_by=id))
    enlistment_table_b1_id = Column(Integer, ForeignKey('participant_enlistment_option.id'))
    enlistment_table_b1 = relationship("ParticipantEnlistmentOption", primaryjoin=(enlistment_table_b1_id==ParticipantEnlistmentOption.id), backref=backref('enlistment_table_b1', order_by=id))
    enlistment_table_b2_id = Column(Integer, ForeignKey('participant_enlistment_option.id'))
    enlistment_table_b2 = relationship("ParticipantEnlistmentOption", primaryjoin=(enlistment_table_b2_id==ParticipantEnlistmentOption.id), backref=backref('enlistment_table_b2', order_by=id))
    enlistment_table_b3_id = Column(Integer, ForeignKey('participant_enlistment_option.id'))
    enlistment_table_b3 = relationship("ParticipantEnlistmentOption", primaryjoin=(enlistment_table_b3_id==ParticipantEnlistmentOption.id), backref=backref('enlistment_table_b3', order_by=id))

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)

class ParticipantPolkuBookings(Base):
    __tablename__ = 'participants_polkubookings'
    id = Column(Integer, primary_key=True)
    participant_id = Column(Integer, ForeignKey('participants.id'))
    booking_no = Column(Integer) # BookingNo
    event_no = Column(Integer) # EventNo
    participant_no = Column(Integer) # ParticNo
    # event_title = Column(Integer) # EventTitle
    district = Column(String(255)) # District
    organization_id = Column(Integer) # OrgId
    club_no = Column(Integer) # ClubNo
    club_name = Column(Integer) # ClubName
    member_id = Column(Integer) # MembId
    member_no = Column(Integer) # MembNo
    birthdate = Column(DateTime()) # BirthDate
    # birth_no = Column(Integer) # BirthNo
    firstname = Column(String(255)) # NameFirst
    lastname = Column(String(255)) # NameFamily
    nickname = Column(String(255)) # NameCall
    sex = Column(String(1)) # Sex
    address_name = Column(String(255)) # AdrName1
    address_name2 = Column(String(255)) # AdrName2
    address = Column(String(255)) # Address1
    address2 = Column(String(255)) # Address2
    address3 = Column(String(255)) # Address3
    postalcode = Column(String(255)) # PostalCode1
    postalcode2 = Column(String(255)) # PostalCode2
    city = Column(String(255)) # City
    country_code = Column(String(10)) # CountryCode
    country = Column(String(255)) # Country
    booking_type = Column(String(255)) # BookingType
    booking_status = Column(String(255)) # BookingStatus
    booking_date = Column(DateTime()) # DateBooking
    booking_confirm_date = Column(DateTime()) # DateConfirm
    pay_date = Column(DateTime()) # DatePay1
    pay_date2 = Column(DateTime()) # DatePay2
    invoice = Column(String(255)) # Invoice
    invoice_member_id = Column(Integer) # Invoice_MembId
    invoice_no = Column(Integer) # Invoice_No
    invoice_name = Column(String(255)) # Invoice_Name
    invoide_address_name = Column(String(255)) # Invoice_AdrName
    invoide_address_name2 = Column(String(255)) # Invoice_AdrName2
    invoice_address = Column(String(255)) # Invoice_Address1
    invoice_address2 = Column(String(255)) # Invoice_Address2
    invoice_address3 = Column(String(255)) # Invoice_Address3
    invoice_postalcode = Column(String(255)) # Invoice_PostalCode
    invoice_city = Column(String(255)) # Invoice_City
    booking_note = Column(String(255)) # BookingNote
    food_note = Column(String(255)) # FoodNote
    # have_answer = Column(Integer) # HaveAnswer
    invoide_type = Column(String(255)) # InvType
    reference_code = Column(String(255)) # RefCode
    
    polku_answers_data = []
    polku_contact_data = []
    
    def getPolkuAnswers(self):
        self.polku_answers_data = DBSession.query(ParticipantPolkuAnswers).filter(ParticipantPolkuAnswers.booking_no==self.booking_no).all()
    def getPolkuContact(self):
        self.polku_contact_data = DBSession.query(ParticipantPolkuContactInfo).filter(ParticipantPolkuContactInfo.memb_id==self.member_id).all()
    
    
    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)
    
class ParticipantPolkuAnswers(Base):
    __tablename__ = 'participants_polkuanswers'
    id = Column(Integer, primary_key=True)
    booking_no = Column(Integer) # BookingNo
    quest_id = Column(Integer) # QuestId
    quest_type = Column(String(255)) # QuestType
    answer = Column(String(255)) # Answer
    answer_value = Column(Integer) # AnswerValue
    answer_text = Column(Text) # AnswerText
    stat_quest = Column(String(255)) # Stat_Quest
    stat_answer = Column(Text) # Stat_Answer
    sort_order = Column(Integer) # SortOrder
    
    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)

class ParticipantPolkuContactInfo(Base):
    __tablename__ = 'participants_polku_it_information'
    id = Column(Integer, primary_key=True)
    memb_id = Column(Integer) # MembId
    address_id = Column(Integer) # AddressId
    com_code = Column(String(255)) # ComCode
    country_no = Column(String(255)) # CountryNo
    area_no = Column(String(255)) # AreaNo
    local_no = Column(String(255)) # LocalNo
    descr = Column(String(255)) # Descr
    sort_order = Column(Integer) # SortOrder

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)
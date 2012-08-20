from datetime import datetime

from sqlalchemy import (
    Table,
    Column,
    Integer,
    Text,
	String,
	DateTime,
	Boolean,
    )

from sqlalchemy.ext.declarative import declarative_base

from sqlalchemy import ForeignKey

from sqlalchemy.orm import (
    scoped_session,
    sessionmaker,
    relationship,
    )

from sqlalchemy.sql.expression import column as expression_column

from leirirekkari.models.dbsession import DBSession, ORMClass, foreign_key_column, Base

from leirirekkari.helpers.helpers import getCurrentUserId

class MedicalCard(Base):
    __tablename__ = 'medical_card'
    id = Column(Integer, primary_key=True)
    participant_id = Column(Integer, ForeignKey('participants.id'), nullable=False, index=True)
    hospital_in = Column(DateTime(), index=True)
    hospital_out = Column(DateTime(), index=True)
    method_of_arrival = Column(Integer, ForeignKey('medical_method_of_arrival.id'), nullable=False, index=True)
    medications = Column(Boolean, default=0)
    medications_info = Column(Text)
    treatment_type = Column(Integer, ForeignKey('medical_treatment_type.id'), nullable=False, index=True)
    reason_id = Column(Integer, ForeignKey('medical_reason.id'), nullable=False, index=True)
    diagnose = Column(Text)
    followup_going = Column(String(255), index=True)
    followup_notes = Column(Text)
    card_status = Column(Integer, nullable=False, default=0)
    
    
    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)
    
class MedicalCardEvent(Base):
    __tablename__ = 'medical_card_event'
    id = Column(Integer, primary_key=True)
    card_id = Column(Integer, ForeignKey('medical_card.id'), nullable=False, index=True)
    notes = Column(Text)
    event_time = Column(DateTime())
    writer = Column(String(255), index=True)
    event_type = Column(Integer, nullable=False, default=0)

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)


class MedicalParticipantStatus(Base):
    __tablename__ = 'medical_participant_status'
    id = Column(Integer, primary_key=True)
    participant_id = Column(Integer, ForeignKey('participants.id'), nullable=False, index=True)
    status_id = Column(Integer, nullable=False, default=0, index=True)
    card_id = Column(Integer, ForeignKey('medical_card.id'), nullable=False, index=True)
    description = Column(Text)
    expected_next_change = Column(DateTime())

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)

class MedicalParticipantAdditional(Base):
    __tablename__ = 'medical_participant_additional'
    id = Column(Integer, primary_key=True)
    participant_id = Column(Integer, ForeignKey('participants.id'), nullable=False)
    hetu = Column(String(255), index=True)
    insurance = Column(Boolean)
    insurance_company = Column(String(255), index=True)
    insurance_number = Column(String(255), index=True)
    notes = Column(Text)

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)
    
class MedicalReason(Base):
    __tablename__ = 'medical_reason'
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), index=True)
    description = Column(Text)

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)
    
class MedicalTreatmentType(Base):
    __tablename__ = 'medical_treatment_type'
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), index=True)
    description = Column(Text)

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)
    
class MedicalMethodOfArrival(Base):
    __tablename__ = 'medical_method_of_arrival'
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), index=True)
    description = Column(Text)

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)
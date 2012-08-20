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

class SecurityLogItem(Base):
    __tablename__ = 'security_logitem'
    id = Column(Integer, primary_key=True)
    event_type = Column(Integer, index=True)
    shift_id = Column(Integer, ForeignKey('security_shift.id'), index=True)
    notified_by = Column(String(255), index=True)
    task = Column(String(255), index=True)
    content = Column(Text)
    people_present = Column(Text)
    started = Column(DateTime(), index=True)
    ended = Column(DateTime(), index=True)
    deleted = Column(Boolean)
    
    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)
    
    def __init__(self, content = ''):
        self.content = content

class SecurityShift(Base):
    __tablename__ = 'security_shift'
    id = Column(Integer, primary_key=True)
    starts = Column(DateTime(), index=True)
    ends = Column(DateTime(), index=True)
    leader_id = Column(Integer, index=True)
    notes = Column(Text)

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)

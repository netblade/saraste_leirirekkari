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

class Club(Base):
    __tablename__ = 'clubs'
    id = Column(Integer, primary_key=True)
    name = Column(String(255), unique=True, index=True)
    short_name = Column(String(255), index=True)
    club_code = Column(String(255), unique=True, index=True)
    subunit_id = Column(Integer, index=True)
    leader_id = Column(Integer, index=True)
    
    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)

class SubUnit(Base):
    __tablename__ = 'subunits'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), unique=True, index=True)
    short_name = Column(String(255), index=True)
    village_id = Column(String(255), index=True)
    leader_id = Column(Integer, index=True)

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)
    
class Village(Base):
    __tablename__ = 'villages'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), unique=True, index=True)
    short_name = Column(String(255), index=True)
    subcamp_id = Column(String(255), index=True)
    leader_id = Column(Integer, index=True)

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)
    
class VillageKitchen(Base):
    __tablename__ = 'village_kitchens'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), unique=True, index=True)
    short_name = Column(String(255), index=True)
    subcamp_id = Column(String(255), index=True)
    villages = relationship("Village", secondary="assoc_villagekitchens_villages")
    leader_id = Column(Integer, index=True)

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)

assoc_villagekitchens_villages = Table("assoc_villagekitchens_villages", Base.metadata, foreign_key_column("village_kitchens_id", Integer, "village_kitchens.id"), foreign_key_column("villages_id", Integer, "villages.id"))


class Subcamp(Base):
    __tablename__ = 'subcamps'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), unique=True, index=True)
    short_name = Column(String(255), index=True)
    leader_id = Column(Integer, index=True)

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)
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

class Setting(Base):
    __tablename__ = 'settings'
    id = Column(Integer, primary_key=True)
    setting_key = Column(String(255), unique=True, nullable = False, index=True)
    setting_value = Column(Text)
    locked_key = Column(Boolean, default=False)
    
    
    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)
    
    def __init__(self, setting_key = '', setting_value = '', locked_key = False):
        self.setting_key = setting_key
        self.setting_value = setting_value
        self.locked_key = locked_key

class Feedback(Base):
    __tablename__ = 'feedbacks'
    id = Column(Integer, primary_key=True)
    type = Column(Integer, nullable=False, default=0)
    title = Column(String(255), index=True)
    description = Column(Text)
    status = Column(Integer, nullable=False, default=0)
    parent_id = Column(Integer, ForeignKey('feedbacks.id'))
    children = relationship("Feedback")

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)

    def __init__(self, setting_key = '', setting_value = '', locked_key = False):
        self.setting_key = setting_key
        self.setting_value = setting_value
        self.locked_key = locked_key


class Importer(Base):
    __tablename__ = 'imports'
    id = Column(Integer, primary_key=True)
    filepath = Column(Text) # path to file
    import_type = Column(String(255))
    total_rows = Column(Integer)
    has_headers = Column(Boolean)
    delimeter = Column(String(255))
    rows_per_run = Column(Integer)
    delay_seconds = Column(Integer)
    rows_read = Column(Integer)
    successfull_imports = Column(Integer)


    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)

    def __init__(self, filepath = ''):
        self.filepath = filepath

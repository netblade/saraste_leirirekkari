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
from sqlalchemy import desc

from sqlalchemy.orm import (
    scoped_session,
    sessionmaker,
    relationship,
    )

from sqlalchemy.sql.expression import column as expression_column

from leirirekkari.models.dbsession import DBSession, ORMClass, foreign_key_column, Base

from leirirekkari.helpers.helpers import getCurrentUserId

import bcrypt

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True)
    username = Column(String(255), unique=True, nullable = False)
    firstname = Column(String(255), index=True)
    lastname = Column(String(255), index=True)
    nickname = Column(String(255), index=True)
    title = Column(String(50), index=True)
    email = Column(String(255), index=True)
    language = Column(String(50), index=True)
    password = Column(String(255), nullable = False)
    active = Column(Boolean)
#    last_login_date = Column(DateTime())
    participant_id = Column(Integer) # id
    needs_password_change = Column(Boolean, nullable = False, default=0)
    
    privileges = Column(Text)
    
    groups = relationship("Group", secondary="assoc_users_groups")
#    privileges = relationship("Privilege", secondary="assoc_users_privileges")

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)
    
    log_rounds = 10
    
    groups_by_name = []
    privileges_by_name = []
    
    login_data = []

    def __init__(self, username = '', email = '', nickname = None, set_null_user = False):
        if not set_null_user:
            self.username = username
            if nickname != None:
                self.nickname = nickname
            else:
                self.nickname = username
            self.email = email
            self.active = 1

    def set_password(self, password):
        self.password = self.hash_password(password)
    
    def hash_password(self, password, hashed=None):
        if hashed is None:
            hashed = bcrypt.gensalt(self.log_rounds)
        return unicode(bcrypt.hashpw(password, hashed))

    def validate_password(self, clear, hashed):
        try:
            return self.hash_password(clear, hashed) == hashed
        except ValueError:
            return False
    
    def get_user_groupnames(self):
        self.groups_by_name = []
        for group_tmp in self.groups:
            self.groups_by_name = self.groups_by_name + [group_tmp.name]

    def get_user_privilegenames(self):
        for privilege in self.privileges:
            self.privileges_by_name = self.privileges_by_name + [privilege.name]
            
    def getUserLoginData(self):
        tmp = DBSession.query(UserLogin).filter(UserLogin.user_id==self.id).all()
        if tmp != None:
            self.login_data = tmp

    def getUserLastLoginData(self):
        return DBSession.query(UserLogin).filter(UserLogin.user_id==self.id).order_by(UserLogin.login_time.desc()).first()


class UserLogin(Base):
    __tablename__ = 'user_logins'
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable = False, default=0)
    ip = Column(String(255))
    user_agent = Column(Text)
    login_time = Column(DateTime(), nullable=False, default=datetime.now)
    logout_time = Column(DateTime())
    
    def __init__(self, user_id = 0, ip = '', user_agent = ''):
        self.user_id = user_id
        self.ip = ip
        self.user_agent = user_agent
    
    def set_logout(self):
        self.logout_time = datetime.now()

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)
    
class UserAudit(Base):
    __tablename__ = 'user_audit'
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, nullable = False, default=0)
    model = Column(String(50))
    model_id = Column(Integer, nullable = False, default=0)
    parent_model = Column(String(50))
    parent_model_id = Column(Integer, nullable = False, default=0)
    child_model = Column(String(50))
    child_model_id = Column(Integer, nullable = False, default=0)
    action = Column(String(255))
    revision = Column(Integer, nullable = False, default=0)

    def __init__(self, user_id = 0):
        self.user_id = user_id

    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)

class Group(Base):
    __tablename__ = 'groups'
    id = Column(Integer, primary_key=True)
    name = Column(String(255), unique=True, nullable = False)
    leader_id = Column(Integer, nullable = False, default=0, index=True)
    privileges = Column(Text)
    
#    privileges = relationship("Privilege", secondary="assoc_groups_privileges")
    
    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)

    def __init__(self, name):
        self.name = name

    def set_leader_id(self, leader_id):
        self.leader_id = leader_id

class Privilege(Base):
    __tablename__ = 'privileges'
    id = Column(Integer, primary_key=True)
    name = Column(String(255), unique=True, nullable = False)

    def __init__(self, name):
        self.name = name
    
    #metadata_fields
    metadata_created = Column(DateTime(), nullable=False, default=datetime.now)
    metadata_creator = Column(Integer(), default=getCurrentUserId)
    metadata_modified = Column(DateTime(), default=datetime.now, onupdate=datetime.now)
    metadata_modifier = Column(Integer(), onupdate=getCurrentUserId)
    metadata_revision = Column(Integer(), default=1, onupdate=expression_column('metadata_revision')+1)

assoc_users_groups = Table("assoc_users_groups", Base.metadata, foreign_key_column("user_id", Integer, "users.id"), foreign_key_column("group_id", Integer, "groups.id"))
#assoc_users_privileges = Table("assoc_users_privileges", Base.metadata, foreign_key_column("user_id", Integer, "users.id"), foreign_key_column("privilege_id", Integer, "privileges.id"))
#assoc_groups_privileges = Table("assoc_groups_privileges", Base.metadata, foreign_key_column("group_id", Integer, "groups.id"), foreign_key_column("privilege_id", Integer, "privileges.id"))

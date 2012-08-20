# from datetime import datetime
# 
# from pyramid.security import Everyone
# from pyramid.security import Allow
# 
# from sqlalchemy import (
#     Column,
#     Integer,
#     Text,
#   String,
#   DateTime,
#   Boolean,
#     )
# 
# from sqlalchemy.ext.declarative import declarative_base
# 
# from sqlalchemy.orm import (
#     scoped_session,
#     sessionmaker,
#     )
# 
# from zope.sqlalchemy import ZopeTransactionExtension
# 
# import bcrypt
# 
# DBSession = scoped_session(sessionmaker(extension=ZopeTransactionExtension()))
# Base = declarative_base()
# 
# Base.__acl__ = [
#         (Allow, Everyone, 'view'),
#         (Allow, 'group:editors', 'add'),
#         (Allow, 'group:editors', 'edit'),
#         ]
# 
# class User(Base):
#     __tablename__ = 'users'
#     id = Column(Integer, primary_key=True)
#     username = Column(String(255), unique=True, nullable = False)
#     firstname = Column(String(255))
#     lastname = Column(String(255))
#     email = Column(String(255))
#     password = Column(String(255), nullable = False)
#     active = Column(Boolean)
#     last_login_date = Column(DateTime())
# 
#     #metadata_fields
#     metadata_created = Column(DateTime(), nullable=False)
#     metadata_creator = Column(Integer())
#     metadata_modified = Column(DateTime())
#     metadata_modifier = Column(Integer())
#     
#     groups = []
#     
#     
#     log_rounds = 10
# 
#     def __init__(self, username, email):
#         self.username = username
#         self.email = email
#         self.metadata_created = datetime.now()
# 
#     def set_password(self, password):
#         self.password = self.hash_password(password)
#     
#     def hash_password(self, password, hashed=None):
#         if hashed is None:
#             hashed = bcrypt.gensalt(self.log_rounds)
#         return unicode(bcrypt.hashpw(password, hashed))
# 
#     def validate_password(self, clear, hashed):
#         try:
#             return self.hash_password(clear, hashed) == hashed
#         except ValueError:
#             return False
#         
# class Group(Base):
#     __tablename__ = 'groups'
#     id = Column(Integer, primary_key=True)
#     name = Column(String(255), unique=True, nullable = False)
#     leader_id = Column(Integer)
#     
#     #metadata_fields
#     metadata_created = Column(DateTime(), nullable=False)
#     metadata_creator = Column(Integer())
#     metadata_modified = Column(DateTime())
#     metadata_modifier = Column(Integer())
# 
#     def __init__(self, name):
#         self.name = name
# 
# 
# class GroupPrivilege(Base):
#     __tablename__ = 'group_privileges'
#     id = Column(Integer, primary_key=True)
#     group_id = Column(Integer)
#     status = Column(Integer)
#     
# class UserPrivilege(Base):
#     __tablename__ = 'user_privileges'
#     id = Column(Integer, primary_key=True)
#     user_id = Column(Integer)
#     status = Column(Integer)
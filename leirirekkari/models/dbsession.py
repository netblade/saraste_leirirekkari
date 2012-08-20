from datetime import datetime

from sqlalchemy.orm import (
    scoped_session,
    sessionmaker,
    )
from sqlalchemy import MetaData
    
from sqlalchemy import (
    Table,
    Column,
    Integer,
    Text,
	String,
	DateTime,
	Boolean,
	ForeignKey,
    )

from zope.sqlalchemy import ZopeTransactionExtension

DBSession = scoped_session(sessionmaker(extension=ZopeTransactionExtension()))

from sqlalchemy.ext.declarative import declarative_base

meta = MetaData()

class ORMClass(object):
    
    @classmethod
    def query(class_):
        return DBSession.query(class_)

    @classmethod
    def get(class_, id):
        return Session.query(class_).get(id)
        

# Utility functions
def filterjoin(sep, *items):
    """Join the items into a string, dropping any that are empty.
    """
    items = filter(None, items)
    return sep.join(items)

def foreign_key_column(name, type_, target, nullable=False):
    """Construct a foreign key column for a table.

    ``name`` is the column name. Pass ``None`` to omit this arg in the
    ``Column`` call; i.e., in Declarative classes.

    ``type_`` is the column type.

    ``target`` is the other column this column references.

    ``nullable``: pass True to allow null values. The default is False
    (the opposite of SQLAlchemy's default, but useful for foreign keys).
    """
    fk = ForeignKey(target)
    if name:
        return Column(name, type_, fk, nullable=nullable)
    else:
        return Column(type_, fk, nullable=nullable)

Base = declarative_base(cls=ORMClass)

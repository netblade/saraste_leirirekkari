from datetime import datetime, time, date
from pyramid.threadlocal import get_current_request
from webhelpers.html import literal
from dateutil import parser

additional_search_field_list = [
    "Participant.firstname",
    "Participant.lastname",
    "Participant.nickname",
    "Participant.title",
    "Participant.email",
    "Participant.member_no",
    "Participant.member_id",
    "Participant.booking_no",
    "Participant.notes",
    "Participant.specialities",
    "ParticipantNextOfKin.name",
    "ParticipantNextOfKin.email",
    "ParticipantNextOfKin.phone",
    "ParticipantPhone.phone",
    "ParticipantLanguage.language",
    "ParticipantAddress.street",
    "ParticipantAddress.postalcode",
    "ParticipantAddress.city",
]

additional_search_type_list = [
    '==',
    '!=',
    'LIKE',
    'IN',
]


def getDayString(dt, format='long'):
    if dt == None:
        return ''    
    if format == 'short':
        str = dt.strftime('%a')
    else:
        str = dt.strftime('%A')
    return str

def modDateTime(dt, format='medium'):
    
    if dt == None:
        return ''

    if format == 'short':
        str = dt.strftime('%d.%m.%Y')
    elif format == 'shortwithtime':
        str = dt.strftime('%d.%m. %H:%M')
    elif format == 'long':
        str = dt.strftime('%d.%m.%Y %H:%M:%S')
    else:
        str = dt.strftime('%d.%m.%Y %H:%M')
    return str

def modDate(dt, format='medium'):
    if dt == None:
        return ''
    if format == 'short':
        str = dt.strftime('%d.%m.')
    elif format == 'long':
        str = dt.strftime('%d.%m.%Y')
    else:
        str = dt.strftime('%d.%m.%Y')
    return str

def modTime(dt, format='medium'):
    if dt == None:
        return ''
    if format == 'short':
        str = dt.strftime('%H:%M')
    elif format == 'long':
        str = dt.strftime('%H:%M:%S')
    else:
        str = dt.strftime('%H:%M')
    return str

def getCurrentUserId():
    request = get_current_request()
    if request and request.user:
        return request.user.id
    else:
        return 0

def decodeString(string):
    if string == None:
        return ''
    try:
        tmp = str(string).decode('latin-1')
    except UnicodeEncodeError:
        tmp = string
    return tmp
    
def checkString(string):
    if string == None:
        return ''
    return string

def encodeString(string):
    if string == None:
        return ''
    try:
        tmp = str(string).encode('latin-1')
    except UnicodeEncodeError:
        tmp = string
    return tmp
    
def escapeString(string):
    if string == None:
        return ''
    try:
        tmp = str(string).decode('unicode-escape')
    except UnicodeEncodeError:
        tmp = string
    return tmp

def parseFinnishDateFromString(string, default_now = False):
    if string == '':
        if default_now:
            return datetime.now()
        else:
            return datetime.fromtimestamp(0)
    try:
        ret = parser.parse(string, ignoretz=True, dayfirst=True, yearfirst=False)
    except ValueError:
        return False
    return ret
    
def convertLineBreaks(string):
    return literal(string.replace("\n","<br />"))
    
    
def checkStringAndStrip(string):
    if string == None:
        return ''
    return string.strip()
    

def calculateAgeInYears(birthdate_dt):
    born = birthdate_dt.date()
    today = date.today()
    try: # raised when birth date is February 29 and the current year is not a leap year
        birthday = born.replace(year=today.year)
    except ValueError:
        birthday = born.replace(year=today.year, day=born.day-1)
    if birthday > today:
        return today.year - born.year - 1
    else:
        return today.year - born.year
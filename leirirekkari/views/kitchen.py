# -*- coding: utf-8 -*-
from pyramid.response import Response
from pyramid.view import view_config
import pyramid.security as security

from sqlalchemy.exc import DBAPIError
from sqlalchemy import or_, and_
from sqlalchemy import desc
from sqlalchemy import func as safunc
import sqlalchemy.sql as sql
from pyramid.httpexceptions import HTTPFound

from leirirekkari.models.dbsession import (
    DBSession
    )

from leirirekkari.models.user import (
    User, Group, Privilege, UserAudit, UserLogin
    )

from leirirekkari.models.setting import Setting
from leirirekkari.models.organization import (
    Club,
    SubUnit,
    Village,
    Subcamp,
    )

from leirirekkari.models.participant import (
    Participant,
    ParticipantPhone,
    ParticipantNextOfKin,
    ParticipantLanguage,
    ParticipantPayment,
    ParticipantWishes,
    ParticipantWishesOption,
    ParticipantSignupOption,
    ParticipantMedical,
    ParticipantMedicalDiet,
    ParticipantMedicalFoodAllergy,
    ParticipantMedicalAllergy,
    ParticipantAddress,
    ParticipantMeta,
    ParticipantPresence,
    ParticipantStatus,
    ParticipantEnlistment,
    ParticipantEnlistmentOption,
    ParticipantPolkuBookings,
    ParticipantPolkuAnswers,
    ParticipantPolkuContactInfo,
    )
    
import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.organization as organizationhelpers
import leirirekkari.helpers.user as userhelpers

from pyramid.i18n import get_localizer, negotiate_locale_name
from pyramid.i18n import TranslationString
from pyramid.i18n import get_locale_name

from leirirekkari import checkBrowser, checkDevice

import datetime
from datetime import time, timedelta

class KitchenViews(object):
    def __init__(self, request):
        if checkBrowser(request) or checkDevice(request):
            request.redirect_forbidden = True
        else:
            request.redirect_forbidden = False
        self.request = request
    
    @view_config(route_name='kitchen_frontpage', renderer='kitchen/index.mak', permission='kitchen_view')
    def kitchen_frontpage(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate


        if self.request.method == 'POST' and self.request.POST.get('date') != None and self.request.POST.get('date').strip() != '':
            day = helpers.parseFinnishDateFromString(self.request.POST.get('date').strip())
        else:
            day = datetime.date.today()
        subcamps = DBSession.query(Subcamp).all()
        
        first_day = DBSession.query(Setting).with_entities(Setting.setting_key, Setting.setting_value).filter(Setting.setting_key == 'camp_first_day').first()
        last_day = DBSession.query(Setting).with_entities(Setting.setting_key, Setting.setting_value).filter(Setting.setting_key == 'camp_last_day').first()
        eating_times_breakfast = DBSession.query(Setting).with_entities(Setting.setting_key, Setting.setting_value).filter(Setting.setting_key == 'eating_times_breakfast').first()
        eating_times_lunch = DBSession.query(Setting).with_entities(Setting.setting_key, Setting.setting_value).filter(Setting.setting_key == 'eating_times_lunch').first()
        eating_times_dinner = DBSession.query(Setting).with_entities(Setting.setting_key, Setting.setting_value).filter(Setting.setting_key == 'eating_times_dinner').first()
        eating_times_supper = DBSession.query(Setting).with_entities(Setting.setting_key, Setting.setting_value).filter(Setting.setting_key == 'eating_times_supper').first()
        start_dt = helpers.parseFinnishDateFromString(first_day[1])
        end_dt = helpers.parseFinnishDateFromString(last_day[1])
        
        day_count = (end_dt - start_dt).days + 1
        
        dates = []
        dates.append(day)
        
        days = {
            'start_dt':start_dt,
            'end_dt':end_dt,
            'dates':dates
        }
        
        
        
        eating_times = {
            'eating_times_breakfast':eating_times_breakfast[1],
            'eating_times_lunch':eating_times_lunch[1],
            'eating_times_dinner':eating_times_dinner[1],
            'eating_times_supper':eating_times_supper[1],
        }
        
        self.request.bread.append({'url':'/kitchen/', 'text':_('Kitchen')})
        return {'day':day,'subcamps':subcamps, 'days':days, 'eating_times':eating_times}
        
        
    @view_config(route_name='kitchen_frontpage_all', renderer='kitchen/all.mak', permission='kitchen_view')
    def kitchen_frontpage_all(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        subcamps = DBSession.query(Subcamp).all()

        first_day = DBSession.query(Setting).with_entities(Setting.setting_key, Setting.setting_value).filter(Setting.setting_key == 'camp_first_day').first()
        last_day = DBSession.query(Setting).with_entities(Setting.setting_key, Setting.setting_value).filter(Setting.setting_key == 'camp_last_day').first()
        eating_times_breakfast = DBSession.query(Setting).with_entities(Setting.setting_key, Setting.setting_value).filter(Setting.setting_key == 'eating_times_breakfast').first()
        eating_times_lunch = DBSession.query(Setting).with_entities(Setting.setting_key, Setting.setting_value).filter(Setting.setting_key == 'eating_times_lunch').first()
        eating_times_dinner = DBSession.query(Setting).with_entities(Setting.setting_key, Setting.setting_value).filter(Setting.setting_key == 'eating_times_dinner').first()
        eating_times_supper = DBSession.query(Setting).with_entities(Setting.setting_key, Setting.setting_value).filter(Setting.setting_key == 'eating_times_supper').first()
        start_dt = helpers.parseFinnishDateFromString(first_day[1])
        end_dt = helpers.parseFinnishDateFromString(last_day[1])

        day_count = (end_dt - start_dt).days + 1

        dates = []

        for single_date in (start_dt + timedelta(n) for n in range(day_count)):
            dates.append(single_date)


        days = {
            'start_dt':start_dt,
            'end_dt':end_dt,
            'dates':dates
        }



        eating_times = {
            'eating_times_breakfast':eating_times_breakfast[1],
            'eating_times_lunch':eating_times_lunch[1],
            'eating_times_dinner':eating_times_dinner[1],
            'eating_times_supper':eating_times_supper[1],
        }

        self.request.bread.append({'url':'/kitchen/', 'text':_('Kitchen')})
        return {'subcamps':subcamps, 'days':days, 'eating_times':eating_times}
    5
        
def includeme(config):
    config.add_route('kitchen_frontpage', '/kitchen/')
    config.add_route('kitchen_frontpage_all', '/kitchen/all/')

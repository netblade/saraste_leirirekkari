# -*- coding: utf-8 -*-
from pyramid.response import Response
from pyramid.view import view_config
import pyramid.security as security

from sqlalchemy.exc import DBAPIError
from sqlalchemy import desc
from sqlalchemy import or_, and_
from pyramid.httpexceptions import HTTPFound

from leirirekkari.models.dbsession import (
    DBSession
    )

from leirirekkari.models.user import (
    User, Group, Privilege, UserAudit, UserLogin
    )

from leirirekkari.models.security import (
    SecurityLogItem,
    SecurityShift
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
import leirirekkari.helpers.user as userhelpers

from datetime import datetime

from leirirekkari import checkBrowser, checkDevice

class SecurityViews(object):
    def __init__(self, request):
        if checkBrowser(request) or checkDevice(request):
            request.redirect_forbidden = True
        else:
            request.redirect_forbidden = False
        self.request = request

    @view_config(route_name='security', renderer='security/index.mak', permission='security_view')
    def security_frontpage(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        self.request.bread.append({'url':'/security/', 'text':_('Security')})
        return {}
        
    @view_config(route_name='security_shifts', renderer='security/shifts/index.mak', permission='security_shifts_view')
    def security_list(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        shifts = DBSession.query(SecurityShift).order_by(SecurityShift.starts).all()
        self.request.bread.append({'url':'/security/', 'text':_('Security')})
        self.request.bread.append({'url':'/security/shifts/', 'text':_('Shifts')})
        return {'shifts':shifts}

    @view_config(route_name='security_shifts_new', renderer='security/shifts/new.mak', permission='security_shifts_modify')
    def security_shifts_new(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        shift = SecurityShift()

        if self.request.method == 'POST':
            shift.starts = helpers.parseFinnishDateFromString(self.request.POST.get('starts').strip())
            shift.ends = helpers.parseFinnishDateFromString(self.request.POST.get('ends').strip())
            #shift.leader_id = helpers.decodeString(self.request.POST.get('leader_id').strip())
            shift.notes = helpers.decodeString(self.request.POST.get('notes').strip())
            if type(shift.starts) is datetime and type(shift.ends) is datetime and shift.starts < shift.ends:
                DBSession.add(shift)
                DBSession.flush()
                userAudit = UserAudit(self.request.user.id)
                userAudit.model = 'SecurityShift'
                userAudit.model_id = shift.id
                userAudit.action = 'Create'
                userAudit.revision = shift.metadata_revision
                DBSession.add(userAudit)
                DBSession.flush()
                self.request.session.flash(_(u"Shift created."), 'success')
                return HTTPFound(location='/security/shifts/view/'+str(shift.id)+'/')
            else:
                self.request.session.flash(_(u"Error creating shift. Shift ends before it begins."), 'error')

        self.request.bread.append({'url':'/security/', 'text':_('Security')})
        self.request.bread.append({'url':'/security/shifts/', 'text':_('Shifts')})
        self.request.bread.append({'url':'/security/shifts/new/', 'text':_('Create')})
        return {'shift':shift}
    
    @view_config(route_name='security_shifts_edit', renderer='security/shifts/edit.mak', permission='security_shifts_modify')
    def security_shifts_edit(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        
        shift_id = self.request.matchdict['shift_id']

        shift = DBSession.query(SecurityShift).filter(SecurityShift.id==shift_id).first()
        
        if self.request.method == 'POST':
            shift.starts = helpers.parseFinnishDateFromString(self.request.POST.get('starts').strip())
            shift.ends = helpers.parseFinnishDateFromString(self.request.POST.get('ends').strip())
            #shift.leader_id = helpers.decodeString(self.request.POST.get('leader_id').strip())
            shift.notes = helpers.decodeString(self.request.POST.get('notes').strip())

            if (shift.starts < shift.ends):
                DBSession.add(shift)
                DBSession.flush()
                userAudit = UserAudit(self.request.user.id)
                userAudit.model = 'SecurityShift'
                userAudit.model_id = shift.id
                userAudit.action = 'Update'
                userAudit.revision = shift.metadata_revision
                DBSession.add(userAudit)
                DBSession.flush()
                self.request.session.flash(_(u"Shift saved."), 'success')
                return HTTPFound(location='/security/shifts/view/'+str(shift.id)+'/')
            else:
                self.request.session.flash(_(u"Error saving shift. Shift ends before it begins."), 'error')

        self.request.bread.append({'url':'/security/', 'text':_('Security')})
        self.request.bread.append({'url':'/security/shifts/', 'text':_('Shifts')})
        self.request.bread.append({'url':'/security/shifts/view/'+shift_id+'/', 'text':_('View')})
        self.request.bread.append({'url':'/security/shifts/edit/'+shift_id+'/', 'text':_('Edit')})

        return {'shift':shift}
        
        
    @view_config(route_name='security_shifts_view', renderer='security/shifts/view.mak', permission='security_shifts_view')
    def security_shifts_view(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        shift_id = self.request.matchdict['shift_id']

        shift = DBSession.query(SecurityShift).filter(SecurityShift.id==shift_id).first()
        
        if self.request.method == 'POST':
            logitem = SecurityLogItem()
            logitem.event_type = self.request.POST.get('event_type')
            logitem.shift_id = shift_id
            logitem.notified_by = self.request.POST.get('notified_by')
            logitem.task = self.request.POST.get('task')
            logitem.content = self.request.POST.get('content')
            logitem.deleted = False
            logitem.people_present = self.request.POST.get('people_present')
            logitem.started = helpers.parseFinnishDateFromString(self.request.POST.get('started'), default_now = True)
            logitem.ended = helpers.parseFinnishDateFromString(self.request.POST.get('ended'))
            
            
            DBSession.add(logitem)
            DBSession.flush()

            userAudit = UserAudit(self.request.user.id)
            userAudit.model = 'SecurityLogItem'
            userAudit.model_id = logitem.id
            userAudit.action = 'Create'
            userAudit.revision = logitem.metadata_revision
            DBSession.add(userAudit)
            DBSession.flush()
            self.request.session.flash(_(u"Log item created."), 'success')
            return HTTPFound(location='/security/shifts/view/'+shift_id+'/')
        
        logitems = DBSession.query(SecurityLogItem).filter(SecurityLogItem.shift_id==shift_id, SecurityLogItem.deleted == False).order_by(SecurityLogItem.started.desc()).all()
        self.request.bread.append({'url':'/security/', 'text':_('Security')})
        self.request.bread.append({'url':'/security/shifts/', 'text':_('Shifts')})
        self.request.bread.append({'url':'/security/shifts/view/'+shift_id+'/', 'text':_('View')})
        return {'shift':shift, 'logitems':logitems}

    @view_config(route_name='security_shifts_logitem_edit', renderer='security/shifts/edit_logitem.mak', permission='security_shifts_log_modify')
    def security_shifts_logitem_edit(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        logitem_id = self.request.matchdict['logitem_id']

        logitem = DBSession.query(SecurityLogItem).filter(SecurityLogItem.id==logitem_id).first()

        if self.request.method == 'POST':
            logitem.event_type = self.request.POST.get('event_type').strip()
            logitem.notified_by = self.request.POST.get('notified_by').strip()
            logitem.task = self.request.POST.get('task').strip()
            logitem.content = self.request.POST.get('content').strip()
            logitem.people_present = self.request.POST.get('people_present').strip()
            logitem.started = helpers.parseFinnishDateFromString(self.request.POST.get('started').strip(), default_now = True)
            logitem.ended = helpers.parseFinnishDateFromString(self.request.POST.get('ended').strip())

            DBSession.add(logitem)
            DBSession.flush()
            userAudit = UserAudit(self.request.user.id)
            userAudit.model = 'SecurityLogItem'
            userAudit.model_id = logitem.id
            userAudit.action = 'Update'
            userAudit.revision = logitem.metadata_revision
            DBSession.add(userAudit)
            DBSession.flush()
            self.request.session.flash(_(u"Log item saved."), 'success')
            return HTTPFound(location='/security/shifts/view/'+str(logitem.shift_id)+'/')


        self.request.bread.append({'url':'/security/', 'text':_('Security')})
        self.request.bread.append({'url':'/security/shifts/', 'text':_('Shifts')})
        self.request.bread.append({'url':'/security/shifts/view/'+str(logitem.shift_id)+'/', 'text':_('Shift')})
        self.request.bread.append({'url':'/security/shifts/logitem/edit/'+str(logitem_id)+'/', 'text':_('Edit logitem')})
        return {'logitem':logitem}

    @view_config(route_name='security_shifts_logitem_delete', renderer='security/shifts/edit_logitem.mak', permission='security_shifts_log_modify')
    def security_shifts_logitem_delete(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        logitem_id = self.request.matchdict['logitem_id']

        logitem = DBSession.query(SecurityLogItem).filter(SecurityLogItem.id==logitem_id).first()

        if logitem != None:
            logitem.deleted = True
            DBSession.add(logitem)
            DBSession.flush()
            userAudit = UserAudit(self.request.user.id)
            userAudit.model = 'SecurityLogItem'
            userAudit.model_id = logitem.id
            userAudit.action = 'Deleted'
            userAudit.revision = logitem.metadata_revision
            DBSession.add(userAudit)
            DBSession.flush()
            self.request.session.flash(_(u"Log item deleted."), 'success')
            return HTTPFound(location='/security/shifts/view/'+str(logitem.shift_id)+'/')

        self.request.session.flash(_(u"Error finding logitem to delete."), 'Error')
        return HTTPFound(location='/security/shifts/view/'+str(logitem.shift_id)+'/')


    @view_config(route_name='security_participant_search', renderer='security/participant/search.mak', permission='security_participant_view')
    def security_participant_search(self):
        _ = self.request.translate

        participants = []
        search_string = ''

        if self.request.method == 'POST':
            search_string = self.request.POST.get('searchstr').strip()

            if search_string == '':
                self.request.session.flash(_(u"Empty search, please provide search string."), 'error')
            else:
                participants = DBSession.query(Participant).filter(
                    or_(
                    Participant.firstname.like('%'+search_string+'%'),
                    Participant.lastname.like('%'+search_string+'%'),
                    Participant.nickname.like('%'+search_string+'%'),
                    Participant.member_no.like('%'+search_string+'%')
                    )).all()

        self.request.bread.append({'url':'/security/', 'text':_('Security')})
        self.request.bread.append({'url':'/security/participant/search/', 'text':_('Search')})
        return {'participants':participants, 'search_string':search_string}
        
    @view_config(route_name='security_participant_view', renderer='security/participant/view.mak', permission='security_participant_view')
    def security_participant_view(self):
        _ = self.request.translate

        participant_id = self.request.matchdict['participant_id']

        participant = DBSession.query(Participant).get(participant_id)
        
        if self.request.method == 'POST' and self.request.POST.get('participant_new_status_id') != None and self.request.POST.get('participant_new_status_id').isdigit():
            participantStatus = ParticipantStatus()
            participantStatus.participant_id = participant.id
            participantStatus.status_id = int(self.request.POST.get('participant_new_status_id'))
            description = self.request.POST.get('participant_new_status_description')
            if description != None and description.strip() != '':
                participantStatus.description = description
            expected_next_change = self.request.POST.get('participant_new_status_expected_next_change')
            if expected_next_change != None and expected_next_change.strip() != '':
                participantStatus.expected_next_change = helpers.parseFinnishDateFromString(expected_next_change.strip())
            DBSession.add(participantStatus)
            DBSession.flush()
            participant.latest_status_key = int(self.request.POST.get('participant_new_status_id'))
            DBSession.add(participant)
            DBSession.flush()
            self.request.session.flash(_(u"Added new status for participant."), 'success')
            return HTTPFound(location='/security/participant/view/'+str(participant.id)+'/')
        
        participant.getParticipantAddressData()
        participant.getParticipantPhoneData()
        participant.getParticipantLanguageData()
        participant.getParticipantPresenceData()
        participant.getParticipantNextOfKinData()
        participant.getParticipantMetaData()

        self.request.bread.append({'url':'/security/', 'text':_('Security')})
        self.request.bread.append({'url':'/security/participant/search/', 'text':_('Search')})
        self.request.bread.append({'url':'/security/participant/view/'+participant_id+'/', 'text':_('Participant') + ' ' + helpers.decodeString(participant.firstname) + ' ' + helpers.decodeString(participant.lastname)})
        return {'participant':participant}
        

def includeme(config):
    config.add_route('security', '/security/')
    config.add_route('security_shifts', '/security/shifts/')
    config.add_route('security_shifts_new', '/security/shifts/new/')
    config.add_route('security_shifts_edit', '/security/shifts/edit/{shift_id}/')
    config.add_route('security_shifts_view', '/security/shifts/view/{shift_id}/')
    config.add_route('security_shifts_logitem_edit', '/security/shifts/logitem/edit/{logitem_id}/')
    config.add_route('security_shifts_logitem_delete', '/security/shifts/logitem/delete/{logitem_id}/')
    config.add_route('security_participant_search', '/security/participant/search/')
    config.add_route('security_participant_view', '/security/participant/view/{participant_id}/')
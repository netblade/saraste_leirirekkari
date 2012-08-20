# -*- coding: utf-8 -*-
from pyramid.response import Response
from pyramid.view import view_config
import pyramid.security as security

from sqlalchemy.exc import DBAPIError
from pyramid.httpexceptions import HTTPFound

from leirirekkari.models.dbsession import (
    DBSession
    )
from leirirekkari.models.user import (
    User, Group, Privilege, UserAudit, UserLogin
    )
from leirirekkari.models.setting import Setting

import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.user as userhelpers

from leirirekkari import checkBrowser, checkDevice

class SettingsViews(object):
    def __init__(self, request):
        if checkBrowser(request) or checkDevice(request):
            request.redirect_forbidden = True
        else:
            request.redirect_forbidden = False
        self.request = request

    @view_config(route_name='settings', renderer='settings/index.mak', permission='settings_view')
    def settings_frontpage(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        return {}
        
    @view_config(route_name='settings_list', renderer='settings/list.mak', permission='settings_list')
    def settings_list(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        settings = DBSession.query(Setting).order_by(Setting.setting_key).all()
        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/list/', 'text':_('List')})
        return {'settings':settings}

    @view_config(route_name='settings_new', renderer='settings/new.mak', permission='settings_list')
    def settings_new(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        #TODO: Errors
        errors = {}
        tmp_setting = {
            'setting_key':'',
            'setting_value':'',
        }

        if self.request.method == 'POST':
            tmp_setting['setting_key'] = self.request.POST.get('setting_key').strip()
            tmp_setting['setting_value'] = self.request.POST.get('setting_value')
            if tmp_setting['setting_key'] and tmp_setting['setting_key'] != '':
                if not self.checkIfSettignKeyExists(tmp_setting['setting_key']):
                    setting = Setting(tmp_setting['setting_key'], tmp_setting['setting_value'])
                    DBSession.add(setting)
                    DBSession.flush()
                    userAudit = UserAudit(self.request.user.id)
                    userAudit.model = 'Setting'
                    userAudit.model_id = setting.id
                    userAudit.action = 'Create'
                    userAudit.revision = setting.metadata_revision
                    DBSession.add(userAudit)
                    DBSession.flush()
                    self.request.session.flash(_(u"Setting created."), 'success')
                    return HTTPFound(location='/settings/list/')
                else:
                    self.request.session.flash(_(u"Setting with same key exists allready."), 'error')
            else:
                self.request.session.flash(_(u"Please provide key."), 'error')
        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/list/', 'text':_('List')})
        self.request.bread.append({'url':'/settings/new/', 'text':_('New')})
        return {'setting':tmp_setting}
    
    @view_config(route_name='settings_edit', renderer='settings/edit.mak', permission='settings_list')
    def settings_edit(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        #TODO: Errors
        errors = {}
        tmp_setting = {
            'setting_key':'',
            'setting_value':'',
            'locked_key':False,
        }
        
        setting_id = self.request.matchdict['setting_id']

        setting = DBSession.query(Setting).filter(Setting.id==setting_id).first()
        
        if setting.id:
            tmp_setting = {
                'setting_key':setting.setting_key,
                'setting_value':setting.setting_value,
                'locked_key':setting.locked_key,
            }

        if self.request.method == 'POST':
            if not setting.locked_key:
                tmp_setting['setting_key'] = self.request.POST.get('setting_key').strip()
            else:
                tmp_setting['setting_key'] = setting.setting_key

            tmp_setting['setting_value'] = self.request.POST.get('setting_value')

            if tmp_setting['setting_key'] and tmp_setting['setting_key'] != '':
                if not self.checkIfSettignKeyExists(tmp_setting['setting_key'], setting.id):
                    setting.setting_key = tmp_setting['setting_key']
                    setting.setting_value = tmp_setting['setting_value']
                    DBSession.add(setting)
                    DBSession.flush()
                    userAudit = UserAudit(self.request.user.id)
                    userAudit.model = 'Setting'
                    userAudit.model_id = setting.id
                    userAudit.action = 'Update'
                    userAudit.revision = setting.metadata_revision
                    DBSession.add(userAudit)
                    DBSession.flush()
                    self.request.session.flash(_(u"Setting saved."), 'success')
                    return HTTPFound(location='/settings/list/')
                else:
                    self.request.session.flash(_(u"Setting with same key exists allready."), 'error')
            else:
                self.request.session.flash(_(u"Please provide key."), 'error')

        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/list/', 'text':_('List')})
        self.request.bread.append({'url':'/settings/edit/'+setting_id+'/', 'text':_('Edit')+' ' + setting.setting_key})
        return {'setting':tmp_setting}

    def checkIfSettignKeyExists(self, setting_key, skipId = None):
        if setting_key == '':
            return True
        if skipId != None:
            settings_count = DBSession.query(Setting).filter(Setting.setting_key==setting_key, Setting.id != skipId).count()
        else:
            settings_count = DBSession.query(Setting).filter(Setting.setting_key==setting_key).count()
        if settings_count > 0:
            return True
        return False

def includeme(config):
    config.add_route('settings', '/settings/')
    config.add_route('settings_list', '/settings/list/')
    config.add_route('settings_new', '/settings/new/')
    config.add_route('settings_edit', '/settings/edit/{setting_id}/')
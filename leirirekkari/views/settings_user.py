# -*- coding: utf-8 -*-
from pyramid.response import Response
from pyramid.view import view_config
import pyramid.security as security

from sqlalchemy.exc import DBAPIError
from pyramid.httpexceptions import HTTPFound
from sqlalchemy import desc

from leirirekkari.models.dbsession import (
    DBSession
    )

from leirirekkari.models.user import (
    User, Group, Privilege, UserAudit, UserLogin
    )
from leirirekkari.models.setting import Setting
    

import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.user as userhelpers

from datetime import datetime

from pyramid_mailer import get_mailer
from pyramid_mailer.message import Message

import string
from random import choice

from leirirekkari import checkBrowser, checkDevice

class SettingsUsersViews(object):
    def __init__(self, request):
        if checkBrowser(request) or checkDevice(request):
            request.redirect_forbidden = True
        else:
            request.redirect_forbidden = False
        self.request = request
    
    @view_config(route_name='settings_users', renderer='settings/users/index.mak', permission='settings_users')
    def settings_users_frontpage(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        users = DBSession.query(User).order_by(User.active.desc(), User.lastname, User.firstname, User.username).all()
        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/users/', 'text':_('Users')})
        return {'users':users}

    @view_config(route_name='settings_users_view', renderer='settings/users/view.mak', permission='settings_users')
    def settings_users_view(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        user_id = self.request.matchdict['user_id']

        user = DBSession.query(User).filter(User.id==user_id).first()

        if user.id:
            group_ids = [group.id for group in user.groups]
#            privilege_ids = [privilege.id for privilege in user.privileges]
            tmp_user = {
                'id':user.id,
                'firstname':user.firstname,
                'lastname':user.lastname,
                'email':user.email,
                'title':user.title,
                'login':user.username,
                'language':user.language,
                'groups':user.groups,
                'group_ids':group_ids,
                'privileges':user.privileges,
                'active':user.active,
            }
            if security.has_permission("settings_users_modify_groups", self.request.context, self.request):
                groups = DBSession.query(Group).all()
            else:
                groups = {}
            if security.has_permission("settings_users_modify_permissions", self.request.context, self.request):
                privileges = DBSession.query(Privilege).all()
            else:
                privileges = {}
            self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
            self.request.bread.append({'url':'/settings/users/', 'text':_('Users')})
            self.request.bread.append({'url':'/settings/users/view/'+str(user.id)+'/', 'text':_('View')})
            # TODO: FIX WHOLE USAGE OF DICT AND ARRAY....
            return {'user':tmp_user, 'groups':groups, 'privileges':privileges, 'user_obj':user}
        else:
            return HTTPFound(location='/settings/users/')

    @view_config(route_name='settings_users_new', renderer='settings/users/new.mak', permission='settings_users_modify')
    def settings_users_new(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        
        use_mailer = self.request.registry.settings['leirirekkari.use_mailer']

        tmp_user = {
            'firstname':'',
            'lastname':'',
            'email':'',
            'title':'',
            'login':'',
            'language':'',
            'groups':'',
            'privileges':'',
        }
        
        if security.has_permission("settings_users_modify_groups", self.request.context, self.request):
            groups = DBSession.query(Group).all()
        else:
            groups = {}
        if security.has_permission("settings_users_modify_permissions", self.request.context, self.request):
            privileges = DBSession.query(Privilege).all()
        else:
            privileges = {}

        if self.request.method == 'POST':
            tmp_user['firstname'] = self.request.POST.get('firstname').strip()
            tmp_user['lastname'] = self.request.POST.get('lastname').strip()
            tmp_user['email'] = self.request.POST.get('email').strip()
            tmp_user['login'] = self.request.POST.get('account_login').strip()
            tmp_user['language'] = self.request.POST.get('language').strip()
            tmp_user['title'] = self.request.POST.get('title').strip()
            if tmp_user['login'] and tmp_user['email']:
                login = tmp_user['login']
                if self.request.POST.get('account_password') != None:
                    password1 = self.request.POST.get('account_password').strip()
                else:
                    password1 = ''
                if self.request.POST.get('account_password_again') != None:
                    password2 = self.request.POST.get('account_password_again').strip()
                else:
                    password2 = ''

                if not self.checkIfUsernameExists(login):
                    if password1 == '':
                        password1 = self.nicepass(8,4)
                    elif len(password1) < 12:
                        self.request.session.flash(_(u"Passwords too short, must be at least 12 characters long."), 'error')
                        return {'user':tmp_user, 'groups':groups, 'privileges':privileges, 'use_mailer':use_mailer}
                    elif not self.checkIfPasswordsMatch(password1, password2):
                        self.request.session.flash(_(u"Passwords didn't match."), 'error')
                        return {'user':tmp_user, 'groups':groups, 'privileges':privileges, 'use_mailer':use_mailer}

                    user = User(login, tmp_user['email'])
                    user.set_password(password1)
                    user.active = 1
                    user.firstname = tmp_user['firstname']
                    user.lastname = tmp_user['lastname']
                    user.title = tmp_user['title']
                    user.language = tmp_user['language']
                    if security.has_permission("settings_users_modify_groups", self.request.context, self.request):
                        if len(self.request.POST.getall('groups'))>0:
                            user.groups = DBSession.query(Group).filter(Group.id.in_(self.request.POST.getall('groups'))).all()
                        else:
                            user.groups = []
                    if security.has_permission("settings_users_modify_permissions", self.request.context, self.request):
                        privileges_list = ''
                        if len(self.request.POST.getall('privileges')) > 0:
                            for privilege in DBSession.query(Privilege).filter(Privilege.id.in_(self.request.POST.getall('privileges'))).all():
                                privileges_list += '|'+privilege.name + '|'
                        else:
                            privileges_list = ''
                        user.privileges = privileges_list
                    user.metadata_modified = datetime.now()
                    if self.request.POST.get('send_login_details') != None and self.request.POST.get('send_login_details').strip() == '1':
                        user.needs_password_change = 1
                    elif self.request.POST.get('require_password_change') != None and self.request.POST.get('require_password_change').strip() == '1':
                        user.needs_password_change = 1
                    else:
                        user.needs_password_change = 0
                    
                    DBSession.add(user)
                    DBSession.flush()
                    self.request.session.flash(_(u"User created."), 'success')
                    userAudit = UserAudit(self.request.user.id)
                    userAudit.model = 'User'
                    userAudit.model_id = user.id
                    userAudit.action = 'Create'
                    userAudit.revision = user.metadata_revision
                    DBSession.add(userAudit)
                    DBSession.flush()
                
                    if user.id != '' and user.id != 0:
                        if self.request.registry.settings['leirirekkari.use_mailer'] == 'true':
                            if self.request.POST.get('send_login_details') != None and self.request.POST.get('send_login_details').strip() == '1':
                                mailer = get_mailer(self.request)

                            
                                setting_site_name = DBSession.query(Setting).filter(Setting.setting_key == 'site_name').first()
                                setting_mail_sent_from = DBSession.query(Setting).filter(Setting.setting_key == 'mail_sent_from').first()
                                setting_site_url = DBSession.query(Setting).filter(Setting.setting_key == 'site_url').first()
                            
                                message_subject = _(u"User account information for") + ' ' + setting_site_name.setting_value
                                message_body = _(u"Hi\n\nHere are your account details for ${site_name}.\n\nUsername: ${username}\n\nPassword: ${password}\n\nYou can login at ${site_url}\n\nRemember to behave and that all the personal data is classified and should be used and distributed carefully.", 
                                    mapping={'site_name':setting_site_name.setting_value, 'username':tmp_user['login'], 'password':password1, 'site_url':setting_site_url.setting_value})
                            
                                message = Message(subject=message_subject,
                                    sender=setting_mail_sent_from.setting_value,
                                    recipients=[tmp_user['email']],
                                    body=message_body)
                                mailer.send(message)
                            
                                              
                            
                        return HTTPFound(location='/settings/users/view/'+str(user.id))
                else:
                    self.request.session.flash(_(u"User with that username allready exists. Please choose another one."), 'error')
                    

        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/users/', 'text':_('Users')})
        self.request.bread.append({'url':'/settings/users/new/', 'text':_('New')})

        return {'user':tmp_user, 'groups':groups, 'privileges':privileges, 'use_mailer':use_mailer}

    @view_config(route_name='settings_users_edit', renderer='settings/users/edit.mak', permission='settings_users_modify')
    def settings_users_edit(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        use_mailer = self.request.registry.settings['leirirekkari.use_mailer']

        tmp_user = {
            'id':0,
            'firstname':'',
            'lastname':'',
            'email':'',
            'title':'',
            'login':'',
            'language':'',
            'groups':'',
            'group_ids':'',
            'privilege_ids':'',
        }
        user_id = self.request.matchdict['user_id']

        user = DBSession.query(User).filter(User.id==user_id).first()

        if user.id:
            group_ids = [group.id for group in user.groups]
#            privilege_ids = [privilege.id for privilege in user.privileges]
            tmp_user = {
                'id':user.id,
                'firstname':user.firstname,
                'lastname':user.lastname,
                'email':user.email,
                'title':user.title,
                'login':user.username,
                'language':user.language,
                'groups':user.groups,
                'group_ids':group_ids,
                'privileges':user.privileges
            }

        if security.has_permission("settings_users_modify_groups", self.request.context, self.request):
            groups = DBSession.query(Group).all()
        else:
            groups = {}
        if security.has_permission("settings_users_modify_permissions", self.request.context, self.request):
            privileges = DBSession.query(Privilege).all()
        else:
            privileges = {}

        if self.request.method == 'POST':
            tmp_user['firstname'] = self.request.POST.get('firstname').strip()
            tmp_user['lastname'] = self.request.POST.get('lastname').strip()
            tmp_user['email'] = self.request.POST.get('email').strip()
            if user.id != 1:
                tmp_user['login'] = self.request.POST.get('account_login').strip()
            else:
                tmp_user['login'] = user.username
            tmp_user['language'] = self.request.POST.get('language').strip()
            tmp_user['title'] = self.request.POST.get('title').strip()
            if tmp_user['login'] and tmp_user['email']:
                login = tmp_user['login']
                #TODO: What to do if username exists
                if not self.checkIfUsernameExists(login, user.id):
                    if self.request.POST.get('account_password') != None:
                        password1 = self.request.POST.get('account_password').strip()
                    else:
                        password1 = ''
                    if self.request.POST.get('account_password_again') != None:
                        password2 = self.request.POST.get('account_password_again').strip()
                    else:
                        password2 = ''
                    
                    
                    if password1 != '' and len(password1) < 12:
                        self.request.session.flash(_(u"Passwords too short, must be at least 12 characters long."), 'error')
                        return {'user':tmp_user, 'groups':groups, 'privileges':privileges, 'use_mailer':use_mailer}
                    elif password1 != '' and not self.checkIfPasswordsMatch(password1, password2):
                        self.request.session.flash(_(u"Passwords didn't match."), 'error')
                        return {'user':tmp_user, 'groups':groups, 'privileges':privileges, 'use_mailer':use_mailer}
                    elif password1 != '':
                        user.set_password(password1)
                        user.needs_password_change = 0
                    elif password1 == '' and self.request.POST.get('send_login_details') != None and self.request.POST.get('send_login_details').strip() == '1':
                        password1 = self.nicepass(8,4)

                    if password1 != '':
                        user.set_password(password1)
                        
                        userAudit = UserAudit(self.request.user.id)
                        userAudit.model = 'User'
                        userAudit.model_id = user.id
                        userAudit.action = 'Password update'
                        userAudit.revision = user.metadata_revision
                        DBSession.add(userAudit)
                        DBSession.flush()

                    user.firstname = tmp_user['firstname']
                    user.lastname = tmp_user['lastname']
                    user.title = tmp_user['title']
                    user.language = tmp_user['language']
                    if user.id != 1:
                        user.username = login
                    if security.has_permission("settings_users_modify_groups", self.request.context, self.request):
                        if len(self.request.POST.getall('groups'))> 0:
                            user.groups = DBSession.query(Group).filter(Group.id.in_(self.request.POST.getall('groups'))).all()
                        else:
                            user.groups = []
                    if security.has_permission("settings_users_modify_permissions", self.request.context, self.request):
                        privileges_list = ''
                        if len(self.request.POST.getall('privileges'))>0:
                            for privilege in DBSession.query(Privilege).filter(Privilege.id.in_(self.request.POST.getall('privileges'))).all():
                                privileges_list += '|'+privilege.name + '|'
                        else:
                            privileges_list = ''
                        user.privileges = privileges_list
                    user.metadata_modified = datetime.now()
                    
                    if self.request.POST.get('send_login_details') != None and self.request.POST.get('send_login_details').strip() == '1':
                        user.needs_password_change = 1
                    elif self.request.POST.get('require_password_change') != None and self.request.POST.get('require_password_change').strip() == '1':
                        user.needs_password_change = 1
                    elif password1 != '':
                        user.needs_password_change = 0
                    
                    DBSession.add(user)
                    DBSession.flush()
                    
                    userAudit = UserAudit(self.request.user.id)
                    userAudit.model = 'User'
                    userAudit.model_id = user.id
                    userAudit.action = 'Update'
                    userAudit.revision = user.metadata_revision
                    DBSession.add(userAudit)
                    DBSession.flush()
                    
                    if self.request.registry.settings['leirirekkari.use_mailer'] == 'true':
                        if self.request.POST.get('send_login_details') != None and self.request.POST.get('send_login_details').strip() == '1' and password1 != '':
                            mailer = get_mailer(self.request)

                        
                            setting_site_name = DBSession.query(Setting).filter(Setting.setting_key == 'site_name').first()
                            setting_mail_sent_from = DBSession.query(Setting).filter(Setting.setting_key == 'mail_sent_from').first()
                            setting_site_url = DBSession.query(Setting).filter(Setting.setting_key == 'site_url').first()
                        
                            message_subject = _(u"User account information for") + ' ' + setting_site_name.setting_value
                            message_body = _(u"Hi\n\nHere are your account details for ${site_name}.\n\nUsername: ${username}\n\nPassword: ${password}\n\nYou can login at ${site_url}\n\nRemember to behave and that all the personal data is classified and should be used and distributed carefully.", 
                                mapping={'site_name':setting_site_name.setting_value, 'username':tmp_user['login'], 'password':password1, 'site_url':setting_site_url.setting_value})
                        
                            message = Message(subject=message_subject,
                                sender=setting_mail_sent_from.setting_value,
                                recipients=[tmp_user['email']],
                                body=message_body)
                            mailer.send(message)
                    
                    self.request.session.flash(_(u"User saved."), 'success')
                    return HTTPFound(location='/settings/users/view/'+str(user.id))
                else:
                    self.request.session.flash(_(u"User with that username allready exists. Please choose another one."), 'error')

        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/users/', 'text':_('Users')})
        self.request.bread.append({'url':'/settings/users/edit/'+str(user.id)+'/', 'text':_('Edit')})

        return {'user':tmp_user, 'groups':groups, 'privileges':privileges}

    @view_config(route_name='settings_users_activate', permission='settings_users_modify')
    def settings_users_activate(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        user_id = self.request.matchdict['user_id']

        user = DBSession.query(User).get(user_id)
        user.active = 1
        user.metadata_modified = datetime.now()
        DBSession.add(user)
        DBSession.flush()

        userAudit = UserAudit(self.request.user.id)
        userAudit.model = 'User'
        userAudit.model_id = user.id
        userAudit.action = 'Activated'
        userAudit.revision = user.metadata_revision
        DBSession.add(userAudit)
        DBSession.flush()
        
        self.request.session.flash(_(u"User activated."), 'success')

        return HTTPFound(location='/settings/users/')

    @view_config(route_name='settings_users_deactivate', permission='settings_users_modify')
    def settings_users_deactivate(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        user_id = self.request.matchdict['user_id']
        if user_id != 1:
            user = DBSession.query(User).get(user_id)
            user.active = 0
            user.metadata_modified = datetime.now()
            DBSession.add(user)
            DBSession.flush()

            userAudit = UserAudit(self.request.user.id)
            userAudit.model = 'User'
            userAudit.model_id = user.id
            userAudit.action = 'Deactivated'
            userAudit.revision = user.metadata_revision
            DBSession.add(userAudit)
            DBSession.flush()

            self.request.session.flash(_(u"User deactivated."), 'success')

        return HTTPFound(location='/settings/users/')


    @view_config(route_name='settings_users_delete', permission='settings_users_modify')
    def settings_users_delete(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        
        user_id = self.request.matchdict['user_id']
        if user_id != 1:
            user = DBSession.query(User).get(user_id)

            userAudit = UserAudit(self.request.user.id)
            userAudit.model = 'User'
            userAudit.model_id = user.id
            userAudit.action = 'Deleted'
            userAudit.revision = user.metadata_revision
            DBSession.add(userAudit)
            DBSession.flush()
            
            DBSession.delete(user)
            
            self.request.session.flash(_(u"User deleted."), 'success')
        
        return HTTPFound(location='/settings/users/')

    def checkIfUsernameExists(self, username, skipId = None):
        if username == '':
            return True
        if skipId != None:
            users_count = DBSession.query(User).filter(User.username==username, User.id != skipId).count()
        else:
            users_count = DBSession.query(User).filter(User.username==username).count()
        if users_count > 0:
            return True
        return False

    def checkIfPasswordsMatch(self, password1, password2):
        password1 = password1.strip()
        password2 = password2.strip()
        if password1 == '':
            return False
        if password1 == password2:
            return True
        return False


    @view_config(route_name='settings_groups', renderer='settings/groups/index.mak', permission='settings_groups')
    def settings_groups_frontpage(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        groups = DBSession.query(Group).all()
        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/groups/', 'text':_('Groups')})
        return {'groups':groups}

    @view_config(route_name='settings_groups_view', renderer='settings/groups/view.mak', permission='settings_groups')
    def settings_groups_view(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        group_id = self.request.matchdict['group_id']

        group = DBSession.query(Group).filter(Group.id==group_id).first()

        if group.id:
            
#            privilege_ids = [privilege.id for privilege in group.privileges]
            tmp_group = {
                'id':group.id,
                'name':group.name,
                'leader_id':group.leader_id,
                'privileges':group.privileges
            }

            privileges = DBSession.query(Privilege).all()
            self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
            self.request.bread.append({'url':'/settings/groups/', 'text':_('Groups')})
            self.request.bread.append({'url':'/settings/groups/view/'+str(group.id)+'/', 'text':_('View') + ' ' + helpers.decodeString(group.name)})
            return {'group':tmp_group, 'privileges':privileges}
        else:
            return HTTPFound(location='/settings/groups/')

    @view_config(route_name='settings_groups_new', renderer='settings/groups/new.mak', permission='settings_groups_modify')
    def settings_groups_new(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        tmp_group = {
            'name':'',
            'leader_id':'',
            'privileges':'',
        }

        if self.request.method == 'POST':
            tmp_group['name'] = self.request.POST.get('name').strip()
    #        tmp_group['leader_id'] = self.request.POST.get('leader_id').strip()
            if not self.checkIfGroupnameExists(tmp_group['name']):
                group = Group(tmp_group['name'])
                if security.has_permission("settings_users_modify_permissions", self.request.context, self.request):
                    privileges_list = ''
                    if len(self.request.POST.getall('privileges')) > 0:
                        for privilege in DBSession.query(Privilege).filter(Privilege.id.in_(self.request.POST.getall('privileges'))).all():
                            privileges_list += '|'+privilege.name + '|'
                    group.privileges = privileges_list
                DBSession.add(group)
                DBSession.flush()

                userAudit = UserAudit(self.request.user.id)
                userAudit.model = 'Group'
                userAudit.model_id = group.id
                userAudit.action = 'Create'
                userAudit.revision = group.metadata_revision
                DBSession.add(userAudit)
                DBSession.flush()
                self.request.session.flash(_(u"Group created."), 'success')
                if group.id != '' and group.id != 0:
                    return HTTPFound(location='/settings/groups/view/'+str(group.id))
            else:
                self.request.session.flash(_(u"Group with that name allready exists."), 'error')

        privileges = DBSession.query(Privilege).all()
        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/groups/', 'text':_('Groups')})
        self.request.bread.append({'url':'/settings/groups/new/', 'text':_('New')})
        return {'group':tmp_group, 'privileges':privileges}

    @view_config(route_name='settings_groups_edit', renderer='settings/groups/edit.mak', permission='settings_groups_modify')
    def settings_groups_edit(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        tmp_group = {
            'id':'',
            'name':'',
            'leader_id':'',
            'privileges':'',
        }
        group_id = self.request.matchdict['group_id']

        group = DBSession.query(Group).filter(Group.id==group_id).first()

        if group.id:
            if group.id == 1:
                return HTTPFound(location='/settings/groups/')

#            privilege_ids = [privilege.id for privilege in group.privileges]
            tmp_group = {
                'id':group.id,
                'name':group.name,
                'leader_id':group.leader_id,
                'privileges':group.privileges
            }
            


        if self.request.method == 'POST':
            tmp_group['name'] = self.request.POST.get('name').strip()
            if not self.checkIfGroupnameExists(tmp_group['name'], tmp_group['id']):
                group.name = tmp_group['name']
                if security.has_permission("settings_users_modify_permissions", self.request.context, self.request):
                    privileges_list = ''
                    if len(self.request.POST.getall('privileges'))> 0:
                        for privilege in DBSession.query(Privilege).filter(Privilege.id.in_(self.request.POST.getall('privileges'))).all():
                            privileges_list += '|'+privilege.name + '|'
                    group.privileges = privileges_list
                DBSession.add(group)
                DBSession.flush()

                userAudit = UserAudit(self.request.user.id)
                userAudit.model = 'Group'
                userAudit.model_id = group.id
                userAudit.action = 'Update'
                userAudit.revision = group.metadata_revision
                DBSession.add(userAudit)
                DBSession.flush()
                
                self.request.session.flash(_(u"Group saved."), 'success')
                return HTTPFound(location='/settings/groups/view/'+str(group.id))
            else:
                self.request.session.flash(_(u"Group with that name allready exists."), 'error')

        privileges = DBSession.query(Privilege).all()
        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/groups/', 'text':_('Groups')})
        self.request.bread.append({'url':'/settings/groups/edit/'+str(group.id)+'/', 'text':_('Edit') + ' ' + helpers.decodeString(group.name)})
        return {'group':tmp_group, 'privileges':privileges}

    @view_config(route_name='settings_groups_delete', permission='settings_groups_modify')
    def settings_groups_delete(self):
        _ = self.request.translate

        group_id = self.request.matchdict['group_id']
        if group_id != 1:
            group = DBSession.query(Group).get(group_id)
            DBSession.delete(group)

        return HTTPFound(location='/settings/groups/')

    def checkIfGroupnameExists(self, groupname, skipId = None):
        if groupname == '':
            return True
        if skipId != None:
            groups_count = DBSession.query(Group).filter(Group.name==groupname, Group.id != skipId).count()
        else:
            groups_count = DBSession.query(Group).filter(Group.name==groupname).count()
        if groups_count > 0:
            return True
        return False

    @view_config(route_name='settings_me_view', renderer='settings/me/index.mak', permission='view')
    def settings_me_view(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        user = self.request.user

        if user.id:
            group_ids = [group.id for group in user.groups]
#            privilege_ids = [privilege.id for privilege in user.privileges]
            tmp_user = {
                'id':user.id,
                'firstname':user.firstname,
                'lastname':user.lastname,
                'email':user.email,
                'title':user.title,
                'login':user.username,
                'language':user.language,
                'groups':user.groups,
                'group_ids':group_ids,
                'privileges':user.privileges,
            }

            if security.has_permission("settings_users_modify_groups", self.request.context, self.request):
                groups = DBSession.query(Group).all()
            else:
                groups = {}
            if security.has_permission("settings_users_modify_permissions", self.request.context, self.request):
                privileges = DBSession.query(Privilege).all()
            else:
                privileges = {}
            self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
            self.request.bread.append({'url':'/settings/me/', 'text':_('Me')})
            return {'user':tmp_user, 'groups':groups, 'privileges':privileges}
        else:
            return HTTPFound(location='/settings/')


    @view_config(route_name='settings_me_edit', renderer='settings/me/edit.mak', permission='view')
    def settings_me_edit(self):
        _ = self.request.translate

        tmp_user = {
            'id':0,
            'firstname':'',
            'lastname':'',
            'email':'',
            'title':'',
            'login':'',
            'language':'',
            'groups':'',
        }
        user = self.request.user

        if user.id:
            tmp_user = {
                'id':user.id,
                'firstname':user.firstname,
                'lastname':user.lastname,
                'email':user.email,
                'title':user.title,
                'language':user.language,
            }


        if self.request.method == 'POST':
            tmp_user['firstname'] = self.request.POST.get('firstname').strip()
            tmp_user['lastname'] = self.request.POST.get('lastname').strip()
            tmp_user['email'] = self.request.POST.get('email').strip()
            tmp_user['language'] = self.request.POST.get('language').strip()
            tmp_user['title'] = self.request.POST.get('title').strip()
            if tmp_user['email']:
                if self.request.POST.get('account_password') != None:
                    password1 = self.request.POST.get('account_password').strip()
                else:
                    password1 = ''
                if self.request.POST.get('account_password_again') != None:
                    password2 = self.request.POST.get('account_password_again').strip()
                else:
                    password2 = ''
                
                if password1 != '' and len(password1) < 12:
                    self.request.session.flash(_(u"Passwords too short, must be at least 12 characters long."), 'error')
                    return {'user':tmp_user}
                elif password1 != '' and not self.checkIfPasswordsMatch(password1, password2):
                    self.request.session.flash(_(u"Passwords didn't match."), 'error')
                    return {'user':tmp_user}
                elif password1 != '':
                    user.set_password(password1)
                    user.needs_password_change = 0
                    self.request.session.flash(_(u"Password changed."), 'success')
                    
                    userAudit = UserAudit(self.request.user.id)
                    userAudit.model = 'User'
                    userAudit.model_id = user.id
                    userAudit.action = 'Password update'
                    userAudit.revision = user.metadata_revision
                    DBSession.add(userAudit)
                    DBSession.flush()

                user.firstname = tmp_user['firstname']
                user.lastname = tmp_user['lastname']
                user.title = tmp_user['title']
                user.language = tmp_user['language']
                DBSession.add(user)
                DBSession.flush()

                userAudit = UserAudit(self.request.user.id)
                userAudit.model = 'User'
                userAudit.model_id = user.id
                userAudit.action = 'Update'
                userAudit.revision = user.metadata_revision
                DBSession.add(userAudit)
                DBSession.flush()
                
                if user.id != '' and user.id != 0:
                    self.request.session.flash(_(u"User saved."), 'success')
                    return HTTPFound(location='/settings/me/')
                else:
                    return HTTPFound(location='/settings/me/edit/')
            else:
                self.request.session.flash(_(u"Please provide email address."), 'error')

        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/me/', 'text':_('Me')})
        self.request.bread.append({'url':'/settings/me/edit/', 'text':_('Edit')})
        return {'user':tmp_user}
        
    def nicepass(self, alpha=6,numeric=2):
        """
        returns a human-readble password (say rol86din instead of 
        a difficult to remember K8Yn9muL ) 
        """
        import string
        import random
        vowels = ['a','e','i','o','u']
        consonants = [a for a in string.ascii_lowercase if a not in vowels]
        digits = string.digits

        ####utility functions
        def a_part(slen):
            ret = ''
            for i in range(slen):			
                if i%2 ==0:
                    randid = random.randint(0,20) #number of consonants
                    ret += consonants[randid]
                else:
                    randid = random.randint(0,4) #number of vowels
                    ret += vowels[randid]
            return ret

        def n_part(slen):
            ret = ''
            for i in range(slen):
                randid = random.randint(0,9) #number of digits
                ret += digits[randid]
            return ret

        #### 	
        fpl = alpha/2		
        if alpha % 2 :
            fpl = int(alpha/2) + 1 					
        lpl = alpha - fpl	

        start = a_part(fpl)
        mid = n_part(numeric)
        end = a_part(lpl)

        return "%s%s%s" % (start,mid,end)
    


def includeme(config):
    config.add_route('settings_users', '/settings/users/')
    config.add_route('settings_users_new', '/settings/users/new/')
    config.add_route('settings_users_view', '/settings/users/view/{user_id}/')
    config.add_route('settings_users_edit', '/settings/users/edit/{user_id}/')
    config.add_route('settings_users_delete', '/settings/users/delete/{user_id}/')
    config.add_route('settings_users_deactivate', '/settings/users/deactivate/{user_id}/')
    config.add_route('settings_users_activate', '/settings/users/activate/{user_id}/')
    config.add_route('settings_groups', '/settings/groups/')
    config.add_route('settings_groups_new', '/settings/groups/new/')
    config.add_route('settings_groups_view', '/settings/groups/view/{group_id}/')
    config.add_route('settings_groups_edit', '/settings/groups/edit/{group_id}/')
    config.add_route('settings_groups_delete', '/settings/groups/delete/{group_id}/')
    config.add_route('settings_me_view', '/settings/me/')
    config.add_route('settings_me_edit', '/settings/me/edit/')
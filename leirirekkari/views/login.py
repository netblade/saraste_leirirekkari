# -*- coding: utf-8 -*-
from pyramid.response import Response
from pyramid.view import view_config
import pyramid.security as security

from pyramid.httpexceptions import HTTPFound

from sqlalchemy.exc import DBAPIError

from leirirekkari.models.dbsession import (
    DBSession
    )
from leirirekkari.models.user import (
    User,
    UserLogin
    )

from datetime import datetime

import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.user as userhelpers

from leirirekkari import checkBrowser, checkDevice

class LoginViews(object):
    def __init__(self, request):
        if checkBrowser(request) or checkDevice(request):
            request.redirect_forbidden = True
        else:
            request.redirect_forbidden = False
        self.request = request

    @view_config(route_name='logout', renderer='login.mak', permission=security.NO_PERMISSION_REQUIRED)
    def logout(self):
        _ = self.request.translate
        
        
        if 'user_login_id' in self.request.session:
            user_login_id = self.request.session['user_login_id']
            userLogin = DBSession.query(UserLogin).get(user_login_id)
            if userLogin.id == user_login_id:
                userLogin.set_logout()
                DBSession.add(userLogin)
            
            del self.request.session['user_login_id']
            
        
        headers = security.forget(self.request)
        self.request.session.flash(_(u"You have been logged out."), 'success')
        location = self.request.route_url('home')
        return HTTPFound(location=location, headers=headers)

    @view_config(route_name='login', renderer='login.mak', permission=security.NO_PERMISSION_REQUIRED)
    def login(self):
        _ = self.request.translate
        browser_error = checkBrowser(self.request)
        device_error = checkDevice(self.request)
        
        login = ''
        if self.request.method == 'POST':
            if self.request.POST.get('login') \
                and self.request.POST.get('password') \
                and self.request.POST.get('login').strip() != '' \
                and self.request.POST.get('password').strip() != '':
                login = self.request.POST.get('login')
                password = self.request.POST.get('password')
            
                user = DBSession.query(User).filter(User.username==login).first()
                if (    user is not None 
                    and user.active 
                    and user.validate_password(password, user.password)):
                    headers = security.remember(self.request, user.id)
                    self.request.session.flash(_(u"Welcome, ${username}! You are logged in.", mapping={'username':user.username}), 'success')
                    userLogin = UserLogin(user_id = user.id, ip = self.request.client_addr, user_agent = self.request.user_agent)
                    DBSession.add(userLogin)
                    DBSession.flush()
                    self.request.session['user_login_id'] = userLogin.id
                    if userhelpers.checkUserPasswordChangeNeed(self.request, user):
                        return HTTPFound(location='/settings/me/edit/', headers=headers)
                    return HTTPFound(location='/', headers=headers)

                self.request.session.flash(_(u"Login failed."), 'error')
                
            else:
                self.request.session.flash(_(u"Login failed. Please provide username and password."), 'error')

        return {'login':login, 'browser_error':browser_error, 'device_error':device_error}


def includeme(config):
    config.add_route('login', '/login/')
    config.add_route('logout', '/logout/')
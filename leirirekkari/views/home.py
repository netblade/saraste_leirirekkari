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
    User
    )

import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.user as userhelpers

from leirirekkari import checkBrowser, checkDevice

class HomeViews(object):
    def __init__(self, request):
        if checkBrowser(request) or checkDevice(request):
            request.redirect_forbidden = True
        else:
            request.redirect_forbidden = False
        self.request = request

    @view_config(route_name='home', renderer='home.mak', permission='view')
    def frontpage(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

    
        return {}

def includeme(config):
    config.add_route('home', '/')

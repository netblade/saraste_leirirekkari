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

class ForbiddenViews(object):
    def __init__(self, request):
        if checkBrowser(request) or checkDevice(request):
            request.redirect_forbidden = True
        else:
            request.redirect_forbidden = False
        self.request = request

    @view_config(route_name='forbidden_view', renderer='forbidden.mak', permission=security.NO_PERMISSION_REQUIRED)
    def forbidden_view(self):
        _ = self.request.translate
        browser_error = checkBrowser(self.request)
        device_error = checkDevice(self.request)
        path = self.request.path
        return {'path':path,'login':'', 'browser_error':browser_error, 'device_error':device_error}

def includeme(config):
    config.add_route('forbidden_view', '/forbidden/')

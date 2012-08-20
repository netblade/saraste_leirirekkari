from pyramid.config import Configurator
from pyramid.authentication import AuthTktAuthenticationPolicy
from pyramid.authorization import ACLAuthorizationPolicy
from sqlalchemy import engine_from_config
from pyramid.view import forbidden_view_config, notfound_view_config
from pyramid.renderers import render_to_response
from pyramid.util import DottedNameResolver
from pyramid.threadlocal import get_current_request
import httpagentparser

import locale

from pyramid.security import (
    authenticated_userid, 
    unauthenticated_userid,
    ALL_PERMISSIONS, 
    Allow, 
    Authenticated
    )

from pyramid_beaker import session_factory_from_settings

from leirirekkari.models.dbsession import DBSession

from leirirekkari.models.user import (User, Group, Privilege, UserAudit, UserLogin)

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

from leirirekkari.models.security import (
    SecurityLogItem,
    SecurityShift
    )

from leirirekkari.models.medical import (
    MedicalCard,
    MedicalCardEvent,
    MedicalParticipantStatus,
    MedicalParticipantAdditional,
    MedicalReason,
    MedicalTreatmentType,
    )

conf_defaults = {
    'leirirekkari.base_includes': 'leirirekkari leirirekkari.views leirirekkari.views.home leirirekkari.views.login leirirekkari.views.settings leirirekkari.views.settings_user leirirekkari.views.settings_organization leirirekkari.views.settings_import leirirekkari.views.office leirirekkari.views.security leirirekkari.views.medical leirirekkari.views.misc leirirekkari.views.forbidden leirirekkari.views.kitchen',
    'leirirekkari.session_factory': 'leirirekkari.beaker_session_factory',
    'leirirekkari.date_format': 'medium',
    'leirirekkari.datetime_format': 'medium',
    'leirirekkari.time_format': 'medium',
    }

conf_dotted = set([
    'leirirekkari.base_includes',
    'leirirekkari.session_factory',
    ])

permissions_list = set([
    'view',
    'settings_view',
    'settings_list',
    'settings_users',
    'settings_users_modify',
    'settings_users_activations',
    'settings_users_modify_groups',
    'settings_users_modify_permissions',
    'settings_groups',
    'settings_groups_modify',
    'settings_groups_modify_persons',
    'settings_groups_modify_permissions',
    'settings_me',
    'settings_imports',
    'settings_organization',
    'medical_view',
    'medical_add_card',
    'medical_nurse',
    'medical_doctor',
    'medical_settings',
    'kitchen_view',
    'kitchen_view_allergies',
    'programme_view',
    'security_view',
    'security_shifts_view',
    'security_shifts_modify',
    'security_shifts_log_modify',
    'security_participant_view',
    'security_participant_status',
    'office_view',
    'office_participant_view',
    'office_participant_view_medical',
    'office_participant_view_polku',
    'office_participant_new',
    'office_participant_edit',
    'office_participant_delete',
    ])


def beaker_session_factory(**settings):
    return session_factory_from_settings(settings)

def get_user(request):
    userid = unauthenticated_userid(request)
    if userid != None:
        user = DBSession.query(User).get(userid)
        if user == None:
            return False
        else:
            return user
    else:
        return False 
    
def groupfinder(userid, request):
    if request.matched_route != None and not '__static' in request.matched_route.name:
        user = request.user
        if user and user.username != None:
            user.get_user_groupnames()
            privileges = ['g:%s' % g for g in user.groups_by_name]
            privileges += ['u:'+user.username]
            return privileges
        else:
            return []
    else:
        return []


forbidden_view_config()
def forbidden(request):
    browser_error = checkBrowser(request)
    device_error = checkDevice(request)
    path = request.path
    from pyramid.response import Response
    return render_to_response('forbidden.mak', {'path':path,'login':'', 'browser_error':browser_error, 'device_error':device_error}, request=request)

notfound_view_config()
def notfound(request):
    browser_error = checkBrowser(request)
    device_error = checkDevice(request)
    path = request.path
    from pyramid.response import Response
    return render_to_response('notfound.mak', {'path':path,'login':'', 'browser_error':browser_error, 'device_error':device_error}, request=request)

def checkBrowser(request):
    user_agent = httpagentparser.detect(request.user_agent)
    browser_error = False
    if user_agent['browser']['name'] != 'Chrome' and user_agent['browser']['name'] != 'Firefox':
        browser_error = True
    return browser_error
    
def checkDevice(request):
    device_error = False
    if 'Android' in request.user_agent or 'iPad' in request.user_agent or 'iPhone' in request.user_agent:
        device_error = True
    return device_error

def _resolve_dotted(d, keys=conf_dotted):
    for key in keys:
        value = d[key]
        if not isinstance(value, basestring):
            continue
        new_value = []
        for dottedname in value.split():
            new_value.append(DottedNameResolver(None).resolve(dottedname))
        d[key] = new_value

def leirirekkari_locale_negotiator(request, override = None):
    locale_name = 'fi_FI'
    if request.user and request.user.language:
        locale_name = request.user.language
    if override != None:
        locale_name = override
    locale.setlocale(locale.LC_ALL, 'fi_FI')
    return locale_name

class Root(object):
    __acl__ = [
        (Allow, Authenticated, 'view'),
        (Allow, 'g:superadmin', ALL_PERMISSIONS),
    ]

    def __init__(self, request):
        if request.matched_route != None and not '__static' in request.matched_route.name:
            if request.user:
                for group in request.user.groups:
                    if group.privileges != None and group.privileges != '':
                        group_privileges = group.privileges.split('|')
                        for privilege in group_privileges:
                            privilege = privilege.strip('|')
                            if privilege != '':
                                self.__acl__ = self.__acl__ + [
                                    (Allow, 'g:'+group.name, privilege),
                                ]
                if request.user.privileges != None and request.user.privileges != '':
                    user_privileges = request.user.privileges.split('|')
                    for privilege in user_privileges:
                        privilege = privilege.strip('|')
                        if privilege != '':
                            self.__acl__ = self.__acl__ + [
                                (Allow, 'u:'+request.user.username, privilege),
                            ]
        self.request = request

def main(global_config, **settings):
    """ This function is a 'paste.app_factory' and returns a WSGI
    application.
    """
    config = base_configure(global_config, **settings)

    return config.make_wsgi_app()

def base_configure(global_config, **settings):

    for key, value in conf_defaults.items():
        settings.setdefault(key, value)

    _resolve_dotted(settings)

    engine = engine_from_config(settings, 'sqlalchemy.')
    DBSession.configure(bind=engine)
    
    authentication_policy = AuthTktAuthenticationPolicy(settings['leirirekkari.secret'], callback=groupfinder)
    authorization_policy = ACLAuthorizationPolicy()
    
    config = Configurator(settings=settings, root_factory=Root)

    config.set_request_property(get_user, 'user', reify=True)

    config.set_authentication_policy(authentication_policy)
    config.set_authorization_policy(authorization_policy)
    config.set_default_permission('view')

#    config.add_static_view('static', 'static', cache_max_age=3600)
    config.add_static_view(name=settings['leirirekkari.static_name'], path=settings['leirirekkari.static_path'], cache_max_age=3600)
    config.add_forbidden_view(forbidden)
    config.add_notfound_view(notfound, append_slash=True)
    
    config.add_translation_dirs('leirirekkari:locale/')

    config.set_locale_negotiator(leirirekkari_locale_negotiator)
    
    config.add_subscriber('leirirekkari.subscribers.add_localizer', 'pyramid.events.NewRequest')
    config.add_subscriber('leirirekkari.subscribers.add_renderer_globals', 'pyramid.events.BeforeRender')
    config.add_subscriber('leirirekkari.subscribers.breadcrumb_subscriber', 'pyramid.events.NewRequest')
    
    config.include('pyramid_mailer')
    
    session_factory = settings['leirirekkari.session_factory'][0](**settings)
    config.set_session_factory(session_factory)
    
    # Include modules listed in 'leirirekkari.base_includes':
    for module in settings['leirirekkari.base_includes']:
        config.include(module)
    config.commit()
    
    config.scan()

    return config

def includeme(config):
    settings = config.get_settings()
    return config

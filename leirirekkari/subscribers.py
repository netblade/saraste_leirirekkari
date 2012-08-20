from pyramid.i18n import get_localizer, TranslationStringFactory
from pyramid.threadlocal import get_current_request

tsf = TranslationStringFactory('leirirekkari')

def add_renderer_globals(event):
    request = event['request']
    event['_'] = request.translate
    event['localizer'] = request.localizer

def add_localizer(event):
    request = event.request
    localizer = get_localizer(request)
    def auto_translate(*args, **kwargs):
        return localizer.translate(tsf(*args, **kwargs))
    request.localizer = localizer
    request.translate = auto_translate

def breadcrumb_subscriber( event ):
    """ Build Bread object and add to request """
    img = '<img src="'+event.request.static_url("leirirekkari:static/img/icons/breadcrumb_home.png") + '" />'
    event.request.bread = [{'url':'/', 'text':img}]
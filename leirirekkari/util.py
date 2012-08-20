import re
import urllib

from pyramid.i18n import get_locale_name
from pyramid.threadlocal import get_current_request
from pyramid.url import resource_url

def camel_case_to_name(text):
    """
      >>> camel_case_to_name('FooBar')
      'foo_bar'
      >>> camel_case_to_name('TXTFile')
      'txt_file'
      >>> camel_case_to_name ('MyTXTFile')
      'my_txt_file'
      >>> camel_case_to_name('froBOZ')
      'fro_boz'
      >>> camel_case_to_name('f')
      'f'
    """
    return re.sub(
        r'((?<=[a-z])[A-Z]|(?<!\A)[A-Z](?=[a-z]))', r'_\1', text).lower()
import os

from setuptools import setup, find_packages

here = os.path.abspath(os.path.dirname(__file__))
README = open(os.path.join(here, 'README.txt')).read()
CHANGES = open(os.path.join(here, 'CHANGES.txt')).read()

requires = [
    'Babel',
    'Chameleon>=2.7.4',
    'colander>=0.9.3',
    'deform>=0.9.4',
    'deform_bootstrap>=0.1',
    'formencode',
    'lingua>=1.3',
    'mysql-python',
    'plone.i18n<2.0',
    'py-bcrypt',
    'pyramid',
    'pyramid_beaker',
    'pyramid_debugtoolbar',
    'pyramid_deform>=0.2a3',
    'pyramid_mailer',
    'pyramid_tm',
    'SQLAlchemy',
    'transaction',
    'waitress',
    'zope.sqlalchemy',
    'WebHelpers',
    'cssutils',
    'python-dateutil',
    'cherrypy',
    'PasteDeploy',
    'httpagentparser',
    'repoze.sendmail',
    'openpyxl',
    ]

setup(name='leirirekkari',
    version='0.0',
    description='Saraste 2012 leirin leirirekisteri',
    long_description=README + '\n\n' +  CHANGES,
    classifiers=[
    "Programming Language :: Python",
    "Framework :: Pylons",
    "Topic :: Internet :: WWW/HTTP",
    "Topic :: Internet :: WWW/HTTP :: WSGI :: Application",
    ],
    author='Oskari Kokko',
    author_email='oskari.kokko@iki.fi',
    url='https://github.com/netblade/saraste_leirirekkari',
    keywords='web wsgi bfg pylons pyramid scoutcamp personregistry',
    packages=find_packages(),
    include_package_data=True,
    zip_safe=False,
    test_suite='leirirekkari',
    install_requires=requires,
    message_extractors = {'leirirekkari': [
        ('**.py', 'python', None),
        ('**.mak', 'mako', None),
        ('static/**', 'ignore', None)]},
    entry_points="""\
    [paste.app_factory]
    main = leirirekkari:main
    [console_scripts]
    initialize_leirirekkari_db = leirirekkari.scripts.initializedb:main
    """,
    )


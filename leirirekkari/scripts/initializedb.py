import os
import sys
import transaction

from sqlalchemy import engine_from_config

from pyramid.paster import (
    get_appsettings,
    setup_logging,
    )

from leirirekkari.models.dbsession import (
    DBSession
    )

from leirirekkari.models.user import (
    User,
    Base,
    Group,
    Privilege,
    )

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

from leirirekkari import permissions_list

def usage(argv):
    cmd = os.path.basename(argv[0])
    print('usage: %s <config_uri>\n'
          '(example: "%s development.ini")' % (cmd, cmd)) 
    sys.exit(1)

initial_settings = {
    'import_default_rows_per_run':'800',
    'import_default_delay_seconds':'2',
    'import_default_delimeter':';',
    'import_default_has_headers':1,
    'import_file_upload_dir':'/tmp',
    'person_image_upload_dir':'',
    'mail_sent_from':'noreply@saraste2012.fi',
    'site_name':'Saraste, leirirekisteri',
    'site_url':'leirirekkari.saraste2012.fi',
    'camp_first_day':'27.7.2012',
    'camp_last_day':'11.8.2012',
    'eating_times_breakfast':'08:00',
    'eating_times_lunch':'11:00',
    'eating_times_dinner':'18:00',
    'eating_times_supper':'21:00',
}

def main(argv=sys.argv):
    if len(argv) != 2:
        usage(argv)
    config_uri = argv[1]
    setup_logging(config_uri)
    settings = get_appsettings(config_uri)
    engine = engine_from_config(settings, 'sqlalchemy.')
    DBSession.configure(bind=engine)
    Base.metadata.create_all(engine)
    with transaction.manager:
        sudo_user = User('superadmin', '')
        sudo_user.set_password('password')
        sudo_user.needs_password_change = True
        sudo_user.language = 'fi_FI'
        DBSession.add(sudo_user)
        DBSession.flush()
        
        sudo_group = Group('superadmin')
        sudo_group.set_leader_id(sudo_user.id)
        DBSession.add(sudo_group)
        DBSession.flush()

        sudo_user.groups = [sudo_group]
        DBSession.add(sudo_user)
        DBSession.flush()
        
        for setting_key, setting_value in initial_settings.items():
            tmp_setting = Setting(setting_key, setting_value, True)
            DBSession.add(tmp_setting)
            DBSession.flush()
        
        for permission in sorted(permissions_list):
            tmp_privilege = Privilege(permission)
            DBSession.add(tmp_privilege)
            DBSession.flush()
        
        print ''
        print 'login variables: superadmin / password'
        print ''
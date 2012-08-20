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
    User,
    Base,
    Group,
    Privilege,
    UserAudit, 
    UserLogin,
    )

from leirirekkari.models.setting import (
    Setting,
    Importer
    )
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

import csv

import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.user as userhelpers
import leirirekkari.helpers.organization as organizationhelpers

from datetime import datetime
from dateutil.relativedelta import relativedelta

import os

from leirirekkari import checkBrowser, checkDevice

import string
from random import choice

from pyramid_mailer import get_mailer
from pyramid_mailer.message import Message

class SettingsImportsViews(object):
    def __init__(self, request):
        if checkBrowser(request) or checkDevice(request):
            request.redirect_forbidden = True
        else:
            request.redirect_forbidden = False
        self.request = request
    
    @view_config(route_name='settings_imports_frontpage', renderer='settings/imports/index.mak', permission='settings_imports')
    def settings_imports_frontpage(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/imports/', 'text':_('Imports')})
        return {}

    @view_config(route_name='settings_imports_run_importer', renderer='settings/imports/run.mak', permission='settings_imports')    
    def settings_imports_run_importer(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        
        importer_id = self.request.matchdict['importer_id']
        
        messages = []
        messages2 = []

        importer = DBSession.query(Importer).get(importer_id)
        if importer.id and importer.import_type != '':
            file = open(importer.filepath)
            rows = csv.reader(file, delimiter=';')
            counter = 0
            row_counter = 0
            imported = 0
            if importer.rows_read == 0 and importer.has_headers:
                rows.next()
                row_counter = 1
                counter = 1

            if importer.rows_read > 0:
                while 1:
                    counter += 1
                    rows.next()
                    if counter == importer.rows_read:
                        break

            for row in rows:
                if importer.import_type == 'clubs':
                    ret = self.importClubRow(row)
                elif importer.import_type == 'polkubookings':
                    ret = self.importPolkuBookingRow(row)
                elif importer.import_type == 'polkuanswers':
                    ret = self.importPolkuAnswerRow(row)
                elif importer.import_type == 'polkuanswers_payments':
                    ret = self.importPolkuAnswerPaymentRow(row)
                elif importer.import_type == 'polkucontact':
                    ret = self.importPolkuContactRow(row)
                elif importer.import_type == 'presences':
                    ret = self.importPresenceRow(row)
                elif importer.import_type == 'organization':
                    ret = self.importOrganizationRow(row)
                elif importer.import_type == 'users':
                    ret = self.importUserRow(row)

                messages2.append(ret['message'])
                if ret['success']:
                    imported += 1
                counter += 1
                row_counter += 1

                if row_counter > importer.rows_per_run:
                    break

            if row_counter > 0:
                importer.rows_read += row_counter
                importer.successfull_imports += imported
                DBSession.add(importer)
                to_import = importer.total_rows - importer.rows_read
                if importer.import_type == 'clubs':
                    messages.append(_('Imported clubs: ${clubcount}', mapping={'clubcount':imported}))
                    messages.append(_('Clubs to import: ${clubcount}', mapping={'clubcount':to_import}))
                elif importer.import_type == 'polkubookings':
                    messages.append(_('Imported bookings: ${bookingscount}', mapping={'bookingscount':imported}))
                    messages.append(_('Bookings to import: ${bookingscount}', mapping={'bookingscount':to_import}))
                elif importer.import_type == 'polkuanswers':
                    messages.append(_('Imported answer: ${answerscount}', mapping={'answerscount':imported}))
                    messages.append(_('Answers to import: ${answerscount}', mapping={'answerscount':to_import}))
                elif importer.import_type == 'polkuanswers_payments':
                    messages.append(_('Imported payment: ${answerscount}', mapping={'answerscount':imported}))
                    messages.append(_('Payments to import: ${answerscount}', mapping={'answerscount':to_import}))
                elif importer.import_type == 'polkucontact':
                    messages.append(_('Imported contactinfos: ${infocount}', mapping={'infocount':imported}))
                    messages.append(_('Concact infos to import: ${infocount}', mapping={'infocount':to_import}))
                elif importer.import_type == 'presences':
                    messages.append(_('Imported presences: ${presencecount}', mapping={'presencecount':imported}))
                    messages.append(_('Presence rows to import: ${presencecount}', mapping={'presencecount':to_import}))
                elif importer.import_type == 'organization':
                    messages.append(_('Imported subunits: ${subunitcount}', mapping={'subunitcount':imported}))
                    messages.append(_('Subunit rows to import: ${subunitcount}', mapping={'subunitcount':to_import}))
                elif importer.import_type == 'users':
                    messages.append(_('Imported users: ${usercount}', mapping={'usercount':imported}))
                    messages.append(_('User rows to import: ${usercount}', mapping={'usercount':to_import}))

                messages.extend(messages2)
            
        
        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/imports/', 'text':_('Imports')})
        self.request.bread.append({'url':'/settings/imports/', 'text':_('Running importer')})
        return {'messages':messages, 'importer':importer}

    @view_config(route_name='settings_imports_clubs', renderer='settings/imports/clubs.mak', permission='settings_imports')
    def settings_imports_clubs(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        default_settings = self.getDefaultImportSettings()
        if self.request.method == 'POST':
            settings = {
                'rows_per_run':self.request.POST['rows_per_run'].strip(),
                'delay_seconds':self.request.POST['delay_seconds'].strip(),
                'delimeter':self.request.POST['delimeter'].strip(),
                'has_headers':self.request.POST['has_headers'].strip(),
            }
            importer = self.saveFileToImport(file=self.request.POST['file_to_import'], settings=settings, import_type="clubs")

            if importer.id:
                return HTTPFound(location='/settings/imports/run_importer/'+str(importer.id)+'/')

        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/imports/', 'text':_('Imports')})
        self.request.bread.append({'url':'/settings/imports/clubs/', 'text':_('Import clubs')})
        return {'default_settings':default_settings}
    
    def importClubRow(self, row):
        _ = self.request.translate
        message = ''
        clubs_count = DBSession.query(Club).filter(Club.club_code==row[0]).count()
        
        if clubs_count > 0:
            message = _('Club with name ${clubname} allready exists', mapping={'clubname':helpers.decodeString(row[1])})
            return {'success':False, 'message':message}
        club = Club()
        club.name = helpers.decodeString(row[1])
        club.club_code = row[0]
        DBSession.add(club)
        DBSession.flush()
        userAudit = UserAudit(self.request.user.id)
        userAudit.model = 'Club'
        userAudit.model_id = club.id
        userAudit.action = 'Imported'
        userAudit.revision = club.metadata_revision
        DBSession.add(userAudit)
        DBSession.flush()
        
        del club
        message = _('Imported club ${clubname}', mapping={'clubname':helpers.decodeString(row[1])})
        
        return {'success':True, 'message':message}
        
        
    @view_config(route_name='settings_imports_organization', renderer='settings/imports/organization.mak', permission='settings_imports')
    def settings_imports_organization(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        default_settings = self.getDefaultImportSettings()
        if self.request.method == 'POST':
            settings = {
                'rows_per_run':self.request.POST['rows_per_run'].strip(),
                'delay_seconds':self.request.POST['delay_seconds'].strip(),
                'delimeter':self.request.POST['delimeter'].strip(),
                'has_headers':self.request.POST['has_headers'].strip(),
            }
            importer = self.saveFileToImport(file=self.request.POST['file_to_import'], settings=settings, import_type="organization")

            if importer.id:
                return HTTPFound(location='/settings/imports/run_importer/'+str(importer.id)+'/')

        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/imports/', 'text':_('Imports')})
        self.request.bread.append({'url':'/settings/imports/organization/', 'text':_('Import organization')})
        return {'default_settings':default_settings}

    def importOrganizationRow(self, row):
        _ = self.request.translate
        message = ''
        
        subcamp_name = row[0]
        subcamp = organizationhelpers.getSubcampByName(helpers.decodeString(subcamp_name))
        if subcamp == None:
            subcamp = Subcamp()
            subcamp.name = helpers.decodeString(subcamp_name)
            DBSession.add(subcamp)
            DBSession.flush()
            userAudit = UserAudit(self.request.user.id)
            userAudit.model = 'Subcamp'
            userAudit.model_id = subcamp.id
            userAudit.action = 'Imported'
            userAudit.revision = subcamp.metadata_revision
            DBSession.add(userAudit)
            DBSession.flush()
            
        village_name = row[1]
        village = organizationhelpers.getVillageByName(helpers.decodeString(village_name))
        if village == None:
            village = Village()
            village.name = helpers.decodeString(village_name)
            village.subcamp_id = subcamp.id
            DBSession.add(village)
            DBSession.flush()
            userAudit = UserAudit(self.request.user.id)
            userAudit.model = 'Village'
            userAudit.model_id = village.id
            userAudit.action = 'Imported'
            userAudit.revision = village.metadata_revision
            DBSession.add(userAudit)
            DBSession.flush()
        subunit_name = row[2]
        subunit = organizationhelpers.getSubUnitByName(helpers.decodeString(subunit_name))
        if subunit == None:
            subunit = SubUnit()
            subunit.name = helpers.decodeString(subunit_name)
            subunit.village_id = village.id
            DBSession.add(subunit)
            DBSession.flush()
            userAudit = UserAudit(self.request.user.id)
            userAudit.model = 'SubUnit'
            userAudit.model_id = subunit.id
            userAudit.action = 'Imported'
            userAudit.revision = subunit.metadata_revision
            DBSession.add(userAudit)
            DBSession.flush()
        
        message = _('Imported subunit ${subunitname}', mapping={'subunitname':helpers.decodeString(subunit_name)})
        
        del subcamp
        del village
        del subunit

        return {'success':True, 'message':message}
    
    @view_config(route_name='settings_imports_polkubookings', renderer='settings/imports/polkubookings.mak', permission='settings_imports')
    def settings_imports_polkubookings(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        messages = []
        default_settings = self.getDefaultImportSettings()
        if self.request.method == 'POST':
            settings = {
                'rows_per_run':self.request.POST['rows_per_run'].strip(),
                'delay_seconds':self.request.POST['delay_seconds'].strip(),
                'delimeter':self.request.POST['delimeter'].strip(),
                'has_headers':self.request.POST['has_headers'].strip(),
            }
            importer = self.saveFileToImport(file=self.request.POST['file_to_import'], settings=settings, import_type="polkubookings")

            if importer.id:
                return HTTPFound(location='/settings/imports/run_importer/'+str(importer.id)+'/')
        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/imports/', 'text':_('Imports')})
        self.request.bread.append({'url':'/settings/imports/polkubookings/', 'text':_('Import polku bookings')})
        return {'default_settings':default_settings}


    def importPolkuBookingRow(self, row):
        _ = self.request.translate
        
        message = ''
        participantPolkuBooking = DBSession.query(ParticipantPolkuBookings).filter(ParticipantPolkuBookings.booking_no==row[0]).first()
        if participantPolkuBooking != None:
            message = _('Booking with code ${bookingcode} allready exists, updating', mapping={'bookingcode':helpers.decodeString(row[0])})
            #return {'success':False, 'message':message}
        else:
            participantPolkuBooking = ParticipantPolkuBookings()
        
        member_no = row[9]
        member_id = row[8]
        booking_no = row[0]

        participantPolkuBooking = ParticipantPolkuBookings()
        participantPolkuBooking.booking_no = row[0]
        participantPolkuBooking.event_no = row[1]
        participantPolkuBooking.participant_no = row[2]
        #participantPolkuBooking.#event_title = helpers.decodeString(row[3])
        participantPolkuBooking.district = helpers.decodeString(row[4])
        participantPolkuBooking.organization_id = row[5]
        participantPolkuBooking.club_no = row[6]
        participantPolkuBooking.club_name = helpers.decodeString(row[7])
        participantPolkuBooking.member_id = row[8]
        participantPolkuBooking.member_no = row[9]
        participantPolkuBooking.birthdate = helpers.parseFinnishDateFromString(row[10])
        #participantPolkuBooking.#birth_no = helpers.decodeString(row[11])
        participantPolkuBooking.firstname = helpers.decodeString(row[12])
        participantPolkuBooking.lastname = helpers.decodeString(row[13])
        participantPolkuBooking.nickname = helpers.decodeString(row[14])
        participantPolkuBooking.sex = row[15]
        participantPolkuBooking.address_name = helpers.decodeString(row[16])
        participantPolkuBooking.address_name2 = helpers.decodeString(row[17])
        participantPolkuBooking.address = helpers.decodeString(row[18])
        participantPolkuBooking.address2 = helpers.decodeString(row[19])
        participantPolkuBooking.address3 = helpers.decodeString(row[20])
        participantPolkuBooking.postalcode = helpers.decodeString(row[21])
        participantPolkuBooking.postalcode2 = helpers.decodeString(row[22])
        participantPolkuBooking.city = helpers.decodeString(row[23])
        participantPolkuBooking.country_code = helpers.decodeString(row[24])
        participantPolkuBooking.country = helpers.decodeString(row[25])
        participantPolkuBooking.booking_type = helpers.decodeString(row[26])
        participantPolkuBooking.booking_status = helpers.decodeString(row[27])
        participantPolkuBooking.booking_date = helpers.parseFinnishDateFromString(row[28])
        participantPolkuBooking.booking_confirm_date = helpers.parseFinnishDateFromString(row[29])
        participantPolkuBooking.pay_date = helpers.parseFinnishDateFromString(row[30])
        participantPolkuBooking.pay_date2 = helpers.parseFinnishDateFromString(row[31])
        participantPolkuBooking.invoice = helpers.decodeString(row[32])
        participantPolkuBooking.invoice_member_id = row[33]
        participantPolkuBooking.invoice_no = row[34]
        participantPolkuBooking.invoice_name = helpers.decodeString(row[35])
        participantPolkuBooking.invoide_address_name = helpers.decodeString(row[36])
        participantPolkuBooking.invoide_address_name2 = helpers.decodeString(row[37])
        participantPolkuBooking.invoice_address = helpers.decodeString(row[38])
        participantPolkuBooking.invoice_address2 = helpers.decodeString(row[39])
        participantPolkuBooking.invoice_address3 = helpers.decodeString(row[40])
        participantPolkuBooking.invoice_postalcode = helpers.decodeString(row[41])
        participantPolkuBooking.invoice_city = helpers.decodeString(row[42])
        participantPolkuBooking.booking_note = helpers.decodeString(row[43])
        participantPolkuBooking.food_note = helpers.decodeString(row[44])
        #participantPolkuBooking.#have_answer = helpers.decodeString(row[45])
        participantPolkuBooking.invoide_type = helpers.decodeString(row[46])
        participantPolkuBooking.reference_code = helpers.decodeString(row[47])

        participant = None

        if member_no != '':
            participant = DBSession.query(Participant).filter(Participant.member_no == member_no).first()
        if participant == None:
            participant = DBSession.query(Participant).filter(Participant.booking_no.like('%|'+booking_no+'|%'),).first()
            if participant == None:
                participant = Participant()

        participant.member_no = member_no
        participant.member_id = member_id
        if participant.booking_no == None or participant.booking_no.find('|' + booking_no + '|') < 0:
            if participant.booking_no == '':
                participant.booking_no = '|' + booking_no + '|'
            elif participant.booking_no == None:
                participant.booking_no = '|' + booking_no + '|'
            else:
                participant.booking_no = participant.booking_no + booking_no + '|'

        participant.firstname = helpers.decodeString(row[12])
        participant.lastname = helpers.decodeString(row[13])
        participant.nickname = helpers.decodeString(row[14])
        if row[15] == 'M':
            participant.sex = 10
        elif row[15] == 'K':
            participant.sex = 20
        participant.birthdate = helpers.parseFinnishDateFromString(row[10])

        club = DBSession.query(Club).filter(Club.club_code==row[6]).first()
        if club != None:
            participant.club_id = club.id
            if (participant.subunit_id == 0 or participant.subunit_id == None) and club.subunit_id != 0:
                participant.subunit_id = club.subunit_id
                subunit = organizationhelpers.getSubUnit(club.subunit_id)
                if subunit != None:
                    participant.village_id = subunit.village_id
                    village = organizationhelpers.getVillage(subunit.village_id)
                    del subunit
                    if village != None:
                        participant.subcamp_id = village.subcamp_id
                        del village
        del club

        DBSession.add(participant)
        DBSession.flush()
        userAudit = UserAudit(self.request.user.id)
        userAudit.model = 'Participant'
        userAudit.model_id = participant.id
        userAudit.action = 'Imported'
        userAudit.revision = participant.metadata_revision
        DBSession.add(userAudit)
        DBSession.flush()
        
        participantAddress = ParticipantAddress(helpers.decodeString(row[18]), helpers.decodeString(row[21]), helpers.decodeString(row[23]), helpers.decodeString(row[25]), helpers.decodeString(row[24]))
        participantAddress.participant_id = participant.id
        DBSession.add(participantAddress)
        DBSession.flush()
        userAudit = UserAudit(self.request.user.id)
        userAudit.model = 'ParticipantAddress'
        userAudit.model_id = participantAddress.id
        userAudit.action = 'Imported'
        userAudit.revision = participantAddress.metadata_revision
        DBSession.add(userAudit)
        DBSession.flush()
        del participantAddress

        participantPolkuBooking.participant_id = participant.id
        DBSession.add(participantPolkuBooking)
        DBSession.flush()

        del participantPolkuBooking
        del participant

        message = _('Imported booking ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})

        return {'success':True, 'message':message}
        


    @view_config(route_name='settings_imports_polkuanswers', renderer='settings/imports/polkuanswers.mak', permission='settings_imports')
    def settings_imports_polkuanswers(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        messages = []
        default_settings = self.getDefaultImportSettings()
        if self.request.method == 'POST':
            settings = {
                'rows_per_run':self.request.POST['rows_per_run'].strip(),
                'delay_seconds':self.request.POST['delay_seconds'].strip(),
                'delimeter':self.request.POST['delimeter'].strip(),
                'has_headers':self.request.POST['has_headers'].strip(),
            }
            importer = self.saveFileToImport(file=self.request.POST['file_to_import'], settings=settings, import_type="polkuanswers")

            if importer.id:
                return HTTPFound(location='/settings/imports/run_importer/'+str(importer.id)+'/')
            
        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/imports/', 'text':_('Imports')})
        self.request.bread.append({'url':'/settings/imports/polkuanswers/', 'text':_('Import polku answers')})
        return {'default_settings':default_settings}

    def importPolkuAnswerRow(self, row):
        _ = self.request.translate

        message = ''
        participantPolkuBooking = DBSession.query(ParticipantPolkuBookings).filter(ParticipantPolkuBookings.booking_no==row[0]).first()
        if participantPolkuBooking == None:
            message = _('Booking with code ${bookingcode} not found, skipping.', mapping={'bookingcode':helpers.decodeString(row[0])})
            return {'success':False, 'message':message}
        
        participantPolkuAnswer = ParticipantPolkuAnswers()
        participantPolkuAnswer.booking_no = row[0]
        participantPolkuAnswer.quest_id = row[1]
        participantPolkuAnswer.quest_type = row[2]
        participantPolkuAnswer.answer = helpers.decodeString(row[3])
        participantPolkuAnswer.answer_value = row[4]
        participantPolkuAnswer.answer_text = helpers.decodeString(row[5])
        participantPolkuAnswer.stat_quest = helpers.decodeString(row[6])
        participantPolkuAnswer.stat_answer = helpers.decodeString(row[7])
        participantPolkuAnswer.sort_order =  row[8]
        DBSession.add(participantPolkuAnswer)
        DBSession.flush()
        
        if participantPolkuBooking.participant_id != 0:
            participant_id = participantPolkuBooking.participant_id
            
            skip_questions = [
                '56421', '56530', '56953', '59312', '56423', '59341', '56424', '59342', '56425', '56420', '56419', '59343', '56422', '59340'
            ]
            
            pricing_simple = [
                '56977', 
                '56566', 
                '56969', 
                '59322', 
                '56970', 
                '56567', 
                '59323', 
                '56971', 
                '56568', 
                '59324', 
                '56564', 
                '56967', 
                '59320', 
                '56565', 
                '56968', 
                '59321', 
                '56972', 
                '56569', 
                '59325', 
                '56973', 
                '56570', 
                '59326', 
                '56571', 
                '56974', 
                '59327', 
                '56572', 
                '56975', 
                '59328', 
                '59540', 
                '59541', 
                '56583', 
                '56978', 
                '59329',
                '56584',
                '56979',
                '59330',
            ]
            
            if row[1] in skip_questions:
                message = _('Skipping')

            elif row[1] in pricing_simple:
                participantPayment = ParticipantPayment()
                try:
                    participantPayment.euros = int(row[7])
                except ValueError:
                    participantPayment.euros = 0

                participantPayment.participant_id = participant_id
                participantPayment.title = helpers.decodeString(row[6])
                participantPayment.paid = True
                DBSession.add(participantPayment)
                DBSession.flush()
                
                message = _('Added payment to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
            
            elif row[1] == '56562' or row[1] == '56966':
                participantPayment = ParticipantPayment()
                try:
                    participantPayment.euros = int(row[7]) * 10
                except ValueError:
                    participantPayment.euros = 10

                participantPayment.participant_id = participant_id
                participantPayment.title = helpers.decodeString(row[6])
                participantPayment.paid = True
                participantPayment.note = row[7] + ' kpl'
                DBSession.add(participantPayment)
                DBSession.flush()


            elif row[1] == '56558' or row[1] == '56962' or row[1] == '56556' or row[1] == '56960':
                participantPayment = ParticipantPayment()
                try:
                    participantPayment.euros = int(row[7]) * 12
                except ValueError:
                    participantPayment.euros = 12

                participantPayment.participant_id = participant_id
                participantPayment.title = helpers.decodeString(row[6])
                participantPayment.paid = True
                participantPayment.note = row[7] + ' kpl'
                DBSession.add(participantPayment)
                DBSession.flush()

            
            elif row[1] == '56415' or row[1] == '59333':
                if helpers.decodeString(row[7]) != u'muu, mikä? (Syötä vastaus seuraavaan kysymykseen.)':
                    participantLanguage = ParticipantLanguage()
                    participantLanguage.language = helpers.decodeString(row[7])
                    participantLanguage.participant_id = participant_id
                    message = _('Added language to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                    DBSession.add(participantLanguage)
                    DBSession.flush()
                    del participantLanguage

            elif row[1] == '56416':
                participantLanguage = ParticipantLanguage()
                participantLanguage.language = helpers.decodeString(row[7])
                participantLanguage.participant_id = participant_id
                message = _('Added language to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                DBSession.add(participantLanguage)
                DBSession.flush()
                del participantLanguage

            elif row[1] == '56406' or row[1] ==  '56890' or row[1] ==  '59338':
                participantMedical = DBSession.query(ParticipantMedical).filter(ParticipantMedical.participant_id==participant_id).first()
                if participantMedical == None:
                    participantMedical = ParticipantMedical()
                    participantMedical.participant_id = participant_id
                
                participantMedicalDiet = DBSession.query(ParticipantMedicalDiet).filter(ParticipantMedicalDiet.name == row[7]).first()
                if participantMedicalDiet == None:
                    participantMedicalDiet = ParticipantMedicalDiet()
                    participantMedicalDiet.name = row[7]
                    DBSession.add(participantMedicalDiet)
                    DBSession.flush()
                    
                participantMedical.diets.append(participantMedicalDiet)

                DBSession.add(participantMedical)
                DBSession.flush()
                message = _('Added medical data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                del participantMedical
                
            elif row[1] == '56412' or row[1] ==  '56896' or row[1] ==  '59334':
                participantMedical = DBSession.query(ParticipantMedical).filter(ParticipantMedical.participant_id==participant_id).first()
                if participantMedical == None:
                    participantMedical = ParticipantMedical()
                    participantMedical.participant_id = participant_id

                participantMedicalAllergy = DBSession.query(ParticipantMedicalAllergy).filter(ParticipantMedicalAllergy.name == row[7]).first()
                if participantMedicalAllergy == None:
                    participantMedicalAllergy = ParticipantMedicalAllergy()
                    participantMedicalAllergy.name = row[7]
                    DBSession.add(participantMedicalAllergy)
                    DBSession.flush()

                participantMedical.allergies.append(participantMedicalAllergy)

                DBSession.add(participantMedical)
                DBSession.flush()
                message = _('Added medical data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                del participantMedical

            elif row[1] == '56407' or row[1] == '56891' or row[1] == '59339':
                participantMedical = DBSession.query(ParticipantMedical).filter(ParticipantMedical.participant_id==participant_id).first()
                if participantMedical == None:
                    participantMedical = ParticipantMedical()
                    participantMedical.participant_id = participant_id
                
                participantMedicalFoodAllergy = DBSession.query(ParticipantMedicalFoodAllergy).filter(ParticipantMedicalFoodAllergy.name == row[7]).first()
                if participantMedicalFoodAllergy == None:
                    participantMedicalFoodAllergy = ParticipantMedicalFoodAllergy()
                    participantMedicalFoodAllergy.name = row[7]
                    DBSession.add(participantMedicalFoodAllergy)
                    DBSession.flush()

                participantMedical.food_allergies.append(participantMedicalFoodAllergy)

                DBSession.add(participantMedical)
                DBSession.flush()
                message = _('Added medical data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                del participantMedical

            elif row[1] == '56408' or row[1] == '56892' or row[1] == '59354':
                participantMedical = DBSession.query(ParticipantMedical).filter(ParticipantMedical.participant_id==participant_id).first()
                if participantMedical == None:
                    participantMedical = ParticipantMedical()
                    participantMedical.participant_id = participant_id
                participantMedical.additional_food = helpers.decodeString(row[7])

                DBSession.add(participantMedical)
                DBSession.flush()
                message = _('Added medical data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                del participantMedical

            elif row[1] == '56411' or row[1] == '56895' or row[1] == '59366':
                participantMedical = DBSession.query(ParticipantMedical).filter(ParticipantMedical.participant_id==participant_id).first()
                if participantMedical == None:
                    participantMedical = ParticipantMedical()
                    participantMedical.participant_id = participant_id
                participantMedical.week_of_pregnancy = helpers.decodeString(row[7])

                DBSession.add(participantMedical)
                DBSession.flush()
                message = _('Added medical data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                del participantMedical
                
            elif row[1] == '56410' or row[1] == '56894' or row[1] == '59332':
                participantMedical = DBSession.query(ParticipantMedical).filter(ParticipantMedical.participant_id==participant_id).first()
                if participantMedical == None:
                    participantMedical = ParticipantMedical()
                    participantMedical.participant_id = participant_id
                if participantMedical.illnesses == '' or participantMedical.illnesses == None:
                    participantMedical.illnesses = helpers.decodeString(row[7])
                else: 
                    participantMedical.illnesses = helpers.decodeString(participantMedical.illnesses) + ', ' + helpers.decodeString(row[7])

                DBSession.add(participantMedical)
                DBSession.flush()
                message = _('Added medical data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                del participantMedical
                
            elif row[1] == '56413' or row[1] == '56897' or row[1] == '59335':
                participantMedical = DBSession.query(ParticipantMedical).filter(ParticipantMedical.participant_id==participant_id).first()
                if participantMedical == None:
                    participantMedical = ParticipantMedical()
                    participantMedical.participant_id = participant_id
                answer = helpers.decodeString(row[7])
                if answer == 'En tarvitse':
                    participantMedical.drugs_helps = 0
                elif answer == 'Oma johtaja/savun ensiapuvastaava':
                    participantMedical.drugs_helps = 10
                elif answer == 'Leirisairaala':
                    participantMedical.drugs_helps = 20

                DBSession.add(participantMedical)
                DBSession.flush()
                message = _('Added medical data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                del participantMedical
                
            elif row[1] == '57187' or row[1] == '59077' or row[1] == '59350':
                participantMedical = DBSession.query(ParticipantMedical).filter(ParticipantMedical.participant_id==participant_id).first()
                if participantMedical == None:
                    participantMedical = ParticipantMedical()
                    participantMedical.participant_id = participant_id
                participantMedical.additional_health = helpers.decodeString(row[7])
                DBSession.add(participantMedical)
                DBSession.flush()
                message = _('Added medical data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                del participantMedical
            
            elif row[1] == '56310' or row[1] == '56871' or row[1] == '59355':
                participantNextOfKin = DBSession.query(ParticipantNextOfKin).filter(ParticipantNextOfKin.participant_id==participant_id).first()
                if participantNextOfKin == None:
                    participantNextOfKin = ParticipantNextOfKin()
                    participantNextOfKin.participant_id = participant_id
                participantNextOfKin.primary_name = helpers.decodeString(row[7])
                DBSession.add(participantNextOfKin)
                DBSession.flush()
                message = _('Added next of kin data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                del participantNextOfKin

            elif row[1] == '56311' or row[1] == '56872' or row[1] == '59356':
                participantNextOfKin = DBSession.query(ParticipantNextOfKin).filter(ParticipantNextOfKin.participant_id==participant_id).first()
                if participantNextOfKin == None:
                    participantNextOfKin = ParticipantNextOfKin()
                    participantNextOfKin.participant_id = participant_id
                participantNextOfKin.primary_email = helpers.decodeString(row[7])
                DBSession.add(participantNextOfKin)
                DBSession.flush()
                message = _('Added next of kin data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                del participantNextOfKin
            
            elif row[1] == '56312' or row[1] == '56873' or row[1] == '59357':
                participantNextOfKin = DBSession.query(ParticipantNextOfKin).filter(ParticipantNextOfKin.participant_id==participant_id).first()
                if participantNextOfKin == None:
                    participantNextOfKin = ParticipantNextOfKin()
                    participantNextOfKin.participant_id = participant_id
                participantNextOfKin.primary_phone = helpers.decodeString(row[7])
                DBSession.add(participantNextOfKin)
                DBSession.flush()
                message = _('Added next of kin data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                del participantNextOfKin

            elif row[1] == '56313' or row[1] == '56874' or row[1] == '59358':
                participantNextOfKin = DBSession.query(ParticipantNextOfKin).filter(ParticipantNextOfKin.participant_id==participant_id).first()
                if participantNextOfKin == None:
                    participantNextOfKin = ParticipantNextOfKin()
                    participantNextOfKin.participant_id = participant_id
                participantNextOfKin.secondary_name = helpers.decodeString(row[7])
                DBSession.add(participantNextOfKin)
                DBSession.flush()
                message = _('Added next of kin data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                del participantNextOfKin

            elif row[1] == '56314' or row[1] == '56875' or row[1] == '59359':
                participantNextOfKin = DBSession.query(ParticipantNextOfKin).filter(ParticipantNextOfKin.participant_id==participant_id).first()
                if participantNextOfKin == None:
                    participantNextOfKin = ParticipantNextOfKin()
                    participantNextOfKin.participant_id = participant_id
                participantNextOfKin.secondary_email = helpers.decodeString(row[7])
                DBSession.add(participantNextOfKin)
                DBSession.flush()
                message = _('Added next of kin data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                del participantNextOfKin
            
            elif row[1] == '56315' or row[1] == '56876' or row[1] == '59360':
                participantNextOfKin = DBSession.query(ParticipantNextOfKin).filter(ParticipantNextOfKin.participant_id==participant_id).first()
                if participantNextOfKin == None:
                    participantNextOfKin = ParticipantNextOfKin()
                    participantNextOfKin.participant_id = participant_id
                participantNextOfKin.secondary_phone = helpers.decodeString(row[7])
                DBSession.add(participantNextOfKin)
                DBSession.flush()
                message = _('Added next of kin data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                del participantNextOfKin
            
            elif row[1] == '56332' or row[1] == '56882' or row[1] == '59303':
                participant = DBSession.query(Participant).filter(Participant.id==participant_id).first()
                if participant != None:
                    answer = helpers.decodeString(row[7])
                    if answer == 'Aikuinen (yli 22-vuotias)':
                        participant.age_group = 7
                    elif answer == 'Vaeltaja (18-22-vuotias)':
                        participant.age_group = 6
                    elif answer == 'Samoaja (15-17-vuotias)':
                        participant.age_group = 5
                    elif answer == 'Tarpoja (12-15-vuotias)':
                        participant.age_group = 4
                    elif answer == 'Seikkailija (10-12-vuotias)':
                        participant.age_group = 3
                    elif answer == 'Sudenpentu (7-9-vuotias)':
                        participant.age_group = 2
                    elif answer == 'Perheleirin lapsi (0-7-vuotias)':
                        participant.age_group = 1
                        
                    DBSession.add(participant)
                    DBSession.flush()
                    message = _('Added agegroup data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                    del participant
            
            elif row[1] == '56398' or row[1] == '56888' or row[1] == '59307':
                participant = DBSession.query(Participant).filter(Participant.id==participant_id).first()
                if participant != None:
                    answer = helpers.decodeString(row[7])
                    if answer == u'Ekumeeninen jumalanpalvelus':
                        participant.spiritual = 10
                    elif answer == u'Elämänkatsomuksellinen ohjelma':
                        participant.spiritual = 20
                    DBSession.add(participant)
                    DBSession.flush()
                    message = _('Added spiritual data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                    del participant
            
            elif row[1] == '56484' or row[1] == '56926' or row[1] == '59352':
                participant = DBSession.query(Participant).filter(Participant.id==participant_id).first()
                if participant != None:
                    answer = helpers.decodeString(row[7])
                    if participant.notes == '' or participant.notes == None:
                        participant.notes = answer
                    else: 
                        participant.notes = helpers.decodeString(participant.notes) + ",\n\n" + answer
                    DBSession.add(participant)
                    DBSession.flush()
                    message = _('Added notes data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                    del participant

            elif row[1] == '56493' or row[1] == '56935':
                participant = DBSession.query(Participant).filter(Participant.id==participant_id).first()
                if participant != None:
                    answer = helpers.decodeString(row[7])
                    participant.title = answer
                    DBSession.add(participant)
                    DBSession.flush()
                    message = _('Added title data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                    del participant
            
            elif row[1] == '56531' or row[1] == '56954' or row[1] == '59367':
                participant = DBSession.query(Participant).filter(Participant.id==participant_id).first()
                if participant != None:
                    participant.sleeping_at = helpers.decodeString(row[7])
                    DBSession.add(participant)
                    DBSession.flush()
                    message = _('Added sleeping at data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                    del participant

            elif row[1] == '56368' or row[1] == '56884' or row[1] == '59304':
                participantWishes = DBSession.query(ParticipantWishes).filter(ParticipantWishes.participant_id==participant_id).first()
                if participantWishes == None:
                    participantWishes = ParticipantWishes()
                    participantWishes.participant_id = participant_id

                participantWishesOption = DBSession.query(ParticipantWishesOption).filter(ParticipantWishesOption.name == row[7]).first()
                if participantWishesOption == None:
                    participantWishesOption = ParticipantWishesOption()
                    participantWishesOption.name = row[7]
                    DBSession.add(participantWishesOption)
                    DBSession.flush()

                participantWishes.activity_1_id = participantWishesOption.id
                participantWishes.activity_1 = participantWishesOption

                DBSession.add(participantWishes)
                DBSession.flush()
                message = _('Added participant wish to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})

            elif row[1] == '56393' or row[1] == '56885' or row[1] == '59305':
                participantWishes = DBSession.query(ParticipantWishes).filter(ParticipantWishes.participant_id==participant_id).first()
                if participantWishes == None:
                    participantWishes = ParticipantWishes()
                    participantWishes.participant_id = participant_id
                participantWishesOption = DBSession.query(ParticipantWishesOption).filter(ParticipantWishesOption.name == row[7]).first()
                if participantWishesOption == None:
                    participantWishesOption = ParticipantWishesOption()
                    participantWishesOption.name = row[7]
                    DBSession.add(participantWishesOption)
                    DBSession.flush()

                participantWishes.activity_2_id = participantWishesOption.id
                participantWishes.activity_2 = participantWishesOption

                DBSession.add(participantWishes)
                DBSession.flush()
                message = _('Added participant wish to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
            
            elif row[1] == '56395' or row[1] == '56887' or row[1] == '59306':
                participantWishes = DBSession.query(ParticipantWishes).filter(ParticipantWishes.participant_id==participant_id).first()
                if participantWishes == None:
                    participantWishes = ParticipantWishes()
                    participantWishes.participant_id = participant_id
                participantWishesOption = DBSession.query(ParticipantWishesOption).filter(ParticipantWishesOption.name == row[7]).first()
                if participantWishesOption == None:
                    participantWishesOption = ParticipantWishesOption()
                    participantWishesOption.name = row[7]
                    DBSession.add(participantWishesOption)
                    DBSession.flush()

                participantWishes.activity_3_id = participantWishesOption.id
                participantWishes.activity_3 = participantWishesOption

                DBSession.add(participantWishes)
                DBSession.flush()
                message = _('Added participant wish to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                
            elif row[1] == '56540' or row[1] == '59317':
                participantWishes = DBSession.query(ParticipantWishes).filter(ParticipantWishes.participant_id==participant_id).first()
                if participantWishes == None:
                    participantWishes = ParticipantWishes()
                    participantWishes.participant_id = participant_id

                participantSignupOption = DBSession.query(ParticipantSignupOption).filter(ParticipantSignupOption.name == row[7]).first()
                if participantSignupOption == None:
                    participantSignupOption = ParticipantSignupOption()
                    participantSignupOption.name = row[7]
                    DBSession.add(participantSignupOption)
                    DBSession.flush()

                participantWishes.preliminary_signups.append(participantSignupOption)

                DBSession.add(participantWishes)
                DBSession.flush()
                message = _('Added participant wish to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})

            elif row[1] == '56501' or row[1] == '56943' or row[1] == '59353':
                participant = DBSession.query(Participant).filter(Participant.id==participant_id).first()
                if participant != None and row[7] != None and helpers.decodeString(row[7]).strip() != '':
                    participant.specialities = helpers.decodeString(row[7])
                    DBSession.add(participant)
                    DBSession.flush()
                    message = _('Added specialities data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                    del participant
                    
            elif row[1] == '56541' or row[1] == '59368':
                participant = DBSession.query(Participant).filter(Participant.id==participant_id).first()
                if participant != None and row[7] != None and helpers.decodeString(row[7]).strip() != '':
                    participant.pj_course = helpers.decodeString(row[7])
                    DBSession.add(participant)
                    DBSession.flush()
                    message = _('Added pj course data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                    del participant
                    
            elif row[1] == '56535' or row[1] == '59313':
                participant = DBSession.query(Participant).filter(Participant.id==participant_id).first()
                if participant != None:
                    answer = helpers.decodeString(row[7])
                    if answer == u'Olen Roverwayllä leiriläinen, eli alle 22-vuotias':
                        participant.roverway = 10
                    elif answer == u'Olen Roverwayllä palvelutehtävässä (yli 22v)':
                        participant.roverway = 20
                    DBSession.add(participant)
                    DBSession.flush()
                    message = _('Added roverway data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                    del participant

            elif row[1] == '56494' or row[1] == '56936' or row[1] == '59363':
                participantEnlistment = DBSession.query(ParticipantEnlistment).filter(ParticipantEnlistment.participant_id==participant_id).first()
                if participantEnlistment == None:
                    participantEnlistment = ParticipantEnlistment()
                    participantEnlistment.participant_id = participant_id
                participantEnlistment.enlisted_by = helpers.decodeString(row[7])

                DBSession.add(participantEnlistment)
                DBSession.flush()
                message = _('Added participant enlistment data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                
            elif row[1] == '56495' or row[1] == '56937' or row[1] == '59364':
                participantEnlistment = DBSession.query(ParticipantEnlistment).filter(ParticipantEnlistment.participant_id==participant_id).first()
                if participantEnlistment == None:
                    participantEnlistment = ParticipantEnlistment()
                    participantEnlistment.participant_id = participant_id
                participantEnlistment.enlister_works_as = helpers.decodeString(row[7])

                DBSession.add(participantEnlistment)
                DBSession.flush()
                message = _('Added participant enlistment data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                
            elif row[1] == '56492' or row[1] == '56934' or row[1] == '59308':
                participantEnlistment = DBSession.query(ParticipantEnlistment).filter(ParticipantEnlistment.participant_id==participant_id).first()
                if participantEnlistment == None:
                    participantEnlistment = ParticipantEnlistment()
                    participantEnlistment.participant_id = participant_id

                participantEnlistmentOption = DBSession.query(ParticipantEnlistmentOption).filter(ParticipantEnlistmentOption.name == row[7]).first()
                if participantEnlistmentOption == None:
                    participantEnlistmentOption = ParticipantEnlistmentOption()
                    participantEnlistmentOption.name = row[7]
                    DBSession.add(participantEnlistmentOption)
                    DBSession.flush()

                participantEnlistment.enlistment_table_a_id = participantEnlistmentOption.id
                participantEnlistment.enlistment_table_a = participantEnlistmentOption

                DBSession.add(participantEnlistment)
                DBSession.flush()
                message = _('Added participant enlistment data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})

            elif row[1] == '56938' or row[1] == '56496' or row[1] == '59309':
                participantEnlistment = DBSession.query(ParticipantEnlistment).filter(ParticipantEnlistment.participant_id==participant_id).first()
                if participantEnlistment == None:
                    participantEnlistment = ParticipantEnlistment()
                    participantEnlistment.participant_id = participant_id

                participantEnlistmentOption = DBSession.query(ParticipantEnlistmentOption).filter(ParticipantEnlistmentOption.name == row[7]).first()
                if participantEnlistmentOption == None:
                    participantEnlistmentOption = ParticipantEnlistmentOption()
                    participantEnlistmentOption.name = row[7]
                    DBSession.add(participantEnlistmentOption)
                    DBSession.flush()

                participantEnlistment.enlistment_table_b1_id = participantEnlistmentOption.id
                participantEnlistment.enlistment_table_b1 = participantEnlistmentOption

                DBSession.add(participantEnlistment)
                DBSession.flush()
                message = _('Added participant enlistment data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})

            elif row[1] == '56939' or row[1] == '56497' or row[1] == '59310':
                participantEnlistment = DBSession.query(ParticipantEnlistment).filter(ParticipantEnlistment.participant_id==participant_id).first()
                if participantEnlistment == None:
                    participantEnlistment = ParticipantEnlistment()
                    participantEnlistment.participant_id = participant_id

                participantEnlistmentOption = DBSession.query(ParticipantEnlistmentOption).filter(ParticipantEnlistmentOption.name == row[7]).first()
                if participantEnlistmentOption == None:
                    participantEnlistmentOption = ParticipantEnlistmentOption()
                    participantEnlistmentOption.name = row[7]
                    DBSession.add(participantEnlistmentOption)
                    DBSession.flush()

                participantEnlistment.enlistment_table_b2_id = participantEnlistmentOption.id
                participantEnlistment.enlistment_table_b2 = participantEnlistmentOption

                DBSession.add(participantEnlistment)
                DBSession.flush()
                message = _('Added participant enlistment data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})

            elif row[1] == '56940' or row[1] == '56498' or row[1] == '59311':
                participantEnlistment = DBSession.query(ParticipantEnlistment).filter(ParticipantEnlistment.participant_id==participant_id).first()
                if participantEnlistment == None:
                    participantEnlistment = ParticipantEnlistment()
                    participantEnlistment.participant_id = participant_id

                participantEnlistmentOption = DBSession.query(ParticipantEnlistmentOption).filter(ParticipantEnlistmentOption.name == row[7]).first()
                if participantEnlistmentOption == None:
                    participantEnlistmentOption = ParticipantEnlistmentOption()
                    participantEnlistmentOption.name = row[7]
                    DBSession.add(participantEnlistmentOption)
                    DBSession.flush()

                participantEnlistment.enlistment_table_b3_id = participantEnlistmentOption.id
                participantEnlistment.enlistment_table_b3 = participantEnlistmentOption

                DBSession.add(participantEnlistment)
                DBSession.flush()
                message = _('Added participant enlistment data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})

            elif row[1] == '56493' or row[1] == '56935' or row[1] == '59362':
                participantEnlistment = DBSession.query(ParticipantEnlistment).filter(ParticipantEnlistment.participant_id==participant_id).first()
                if participantEnlistment == None:
                    participantEnlistment = ParticipantEnlistment()
                    participantEnlistment.participant_id = participant_id
                participantEnlistment.job_at_camp = helpers.decodeString(row[7])

                DBSession.add(participantEnlistment)
                DBSession.flush()
                message = _('Added participant enlistment data to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                
            else:
                meta = ParticipantMeta(participant_id = participant_id, meta_key=helpers.decodeString(row[6]), meta_value=helpers.decodeString(row[7]))
                DBSession.add(meta)
                DBSession.flush()
                message = _('Added metadata to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                del meta

        del participantPolkuAnswer
        if message == '':
            message = _('Imported answer to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})

        return {'success':True, 'message':message}

    @view_config(route_name='settings_imports_polkuanswers_payments', renderer='settings/imports/polkuanswers.mak', permission='settings_imports')
    def settings_imports_polkuanswers_payments(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        messages = []
        default_settings = self.getDefaultImportSettings()
        if self.request.method == 'POST':
            settings = {
                'rows_per_run':self.request.POST['rows_per_run'].strip(),
                'delay_seconds':self.request.POST['delay_seconds'].strip(),
                'delimeter':self.request.POST['delimeter'].strip(),
                'has_headers':self.request.POST['has_headers'].strip(),
            }
            importer = self.saveFileToImport(file=self.request.POST['file_to_import'], settings=settings, import_type="polkuanswers_payments")

            if importer.id:
                return HTTPFound(location='/settings/imports/run_importer/'+str(importer.id)+'/')

        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/imports/', 'text':_('Imports')})
        self.request.bread.append({'url':'/settings/imports/polkuanswers/', 'text':_('Import polku answers pricings')})
        return {'default_settings':default_settings}

    def importPolkuAnswerPaymentRow(self, row):
        _ = self.request.translate

        message = ''
        participantPolkuBooking = DBSession.query(ParticipantPolkuBookings).filter(ParticipantPolkuBookings.booking_no==row[0]).first()
        if participantPolkuBooking == None:
            message = _('Booking with code ${bookingcode} not found, skipping.', mapping={'bookingcode':helpers.decodeString(row[0])})
            return {'success':False, 'message':message}

        if participantPolkuBooking.participant_id != 0:
            participant_id = participantPolkuBooking.participant_id

            pricing_simple = [
                '56977', 
                '56566', 
                '56969', 
                '59322', 
                '56970', 
                '56567', 
                '59323', 
                '56971', 
                '56568', 
                '59324', 
                '56564', 
                '56967', 
                '59320', 
                '56565', 
                '56968', 
                '59321', 
                '56972', 
                '56569', 
                '59325', 
                '56973', 
                '56570', 
                '59326', 
                '56571', 
                '56974', 
                '59327', 
                '56572', 
                '56975', 
                '59328', 
                '59540', 
                '59541', 
                '56583', 
                '56978', 
                '59329',
                '56584',
                '56979',
                '59330',
            ]

            if row[1] in pricing_simple:
                participantPayment = ParticipantPayment()
                try:
                    participantPayment.euros = int(row[7])
                except ValueError:
                    participantPayment.euros = 0

                participantPayment.participant_id = participant_id
                participantPayment.title = helpers.decodeString(row[6])
                participantPayment.paid = True
                DBSession.add(participantPayment)
                DBSession.flush()

                message = _('Added payment to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})

            elif row[1] == '56562' or row[1] == '56966':
                participantPayment = ParticipantPayment()
                try:
                    participantPayment.euros = int(row[7]) * 10
                except ValueError:
                    participantPayment.euros = 10

                participantPayment.participant_id = participant_id
                participantPayment.title = helpers.decodeString(row[6])
                participantPayment.paid = True
                participantPayment.note = row[7] + ' kpl'
                DBSession.add(participantPayment)
                DBSession.flush()
                
                meta = ParticipantMeta(participant_id = participant_id, meta_key=helpers.decodeString(row[6]), meta_value=helpers.decodeString(row[7]))
                DBSession.add(meta)
                DBSession.flush()
                message = _('Added metadata to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                del meta


            elif row[1] == '56558' or row[1] == '56962' or row[1] == '56556' or row[1] == '56960':
                participantPayment = ParticipantPayment()
                try:
                    participantPayment.euros = int(row[7]) * 12
                except ValueError:
                    participantPayment.euros = 12

                participantPayment.participant_id = participant_id
                participantPayment.title = helpers.decodeString(row[6])
                participantPayment.paid = True
                participantPayment.note = row[7] + ' kpl'
                DBSession.add(participantPayment)
                DBSession.flush()
                
                meta = ParticipantMeta(participant_id = participant_id, meta_key=helpers.decodeString(row[6]), meta_value=helpers.decodeString(row[7]))
                DBSession.add(meta)
                DBSession.flush()
                message = _('Added metadata to ${bookingcode}', mapping={'bookingcode':helpers.decodeString(row[0])})
                del meta



        return {'success':True, 'message':message}


    @view_config(route_name='settings_imports_polkuit', renderer='settings/imports/polkuit.mak', permission='settings_imports')
    def settings_imports_polkuit(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        messages = []
        default_settings = self.getDefaultImportSettings()
        if self.request.method == 'POST':
            settings = {
                'rows_per_run':self.request.POST['rows_per_run'].strip(),
                'delay_seconds':self.request.POST['delay_seconds'].strip(),
                'delimeter':self.request.POST['delimeter'].strip(),
                'has_headers':self.request.POST['has_headers'].strip(),
            }
            importer = self.saveFileToImport(file=self.request.POST['file_to_import'], settings=settings, import_type="polkucontact")

            if importer.id:
                return HTTPFound(location='/settings/imports/run_importer/'+str(importer.id)+'/')

        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/imports/', 'text':_('Imports')})
        self.request.bread.append({'url':'/settings/imports/clubs/', 'text':_('Import polku contacts')})
        return {'default_settings':default_settings}

    def importPolkuContactRow(self, row):
        _ = self.request.translate

        message = ''

        member_id = row[0]
        participant = DBSession.query(Participant).filter(Participant.member_id==member_id).first()
        if participant == None:
            message = _('Participant with membernumber ${membernumber} not found, skipping.', mapping={'membernumber':row[0]})
            return {'success':False, 'message':message}
        
        participantPolkuContactInfo = ParticipantPolkuContactInfo()
        
        participantPolkuContactInfo.memb_id = helpers.decodeString(row[0])
        participantPolkuContactInfo.address_id = helpers.decodeString(row[1])
        participantPolkuContactInfo.com_code = helpers.decodeString(row[2])
        participantPolkuContactInfo.country_no = helpers.decodeString(row[3])
        participantPolkuContactInfo.area_no = helpers.decodeString(row[4])
        participantPolkuContactInfo.local_no = helpers.decodeString(row[5])
        participantPolkuContactInfo.descr = helpers.decodeString(row[6])
        participantPolkuContactInfo.sort_order = helpers.decodeString(row[7])
        
        DBSession.add(participantPolkuContactInfo)
        DBSession.flush()
        del participantPolkuContactInfo
        
        contact_type = helpers.decodeString(row[6])
        if contact_type == u'Sähköposti':
            participant.email = row[5]
            DBSession.add(participant)
            DBSession.flush()
            del participant
        else:
            participantPhone = ParticipantPhone()
            participantPhone.participant_id = participant.id
            phone = row[3] + row[4] + row[5]
            participantPhone.phone = phone
            participantPhone.description = helpers.decodeString(row[6])
            DBSession.add(participantPhone)
            DBSession.flush()
            del participantPhone
        message = _('Imported contactinfo to ${membernumber}', mapping={'membernumber':helpers.decodeString(row[0])})

        return {'success':True, 'message':message}

    @view_config(route_name='settings_imports_presences', renderer='settings/imports/presence.mak', permission='settings_imports')
    def settings_imports_presences(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        messages = []
        default_settings = self.getDefaultImportSettings()
        if self.request.method == 'POST':
            settings = {
                'rows_per_run':self.request.POST['rows_per_run'].strip(),
                'delay_seconds':self.request.POST['delay_seconds'].strip(),
                'delimeter':self.request.POST['delimeter'].strip(),
                'has_headers':self.request.POST['has_headers'].strip(),
            }
            importer = self.saveFileToImport(file=self.request.POST['file_to_import'], settings=settings, import_type="presences")

            if importer.id:
                return HTTPFound(location='/settings/imports/run_importer/'+str(importer.id)+'/')

        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/imports/', 'text':_('Imports')})
        self.request.bread.append({'url':'/settings/imports/presences/', 'text':_('Import presences')})
        return {'default_settings':default_settings}

    def importPresenceRow(self, row):
        _ = self.request.translate
        message = ''

        booking_no = row[1]
        booking_no_2 = row[2]
        firstname = row[3]
        lastname = row[4]
        club_id = 0
        subunit_id = 0
        village_id = 0
        subcamp_id = 0
        club = organizationhelpers.getClubByName(helpers.decodeString(row[5]))
        if club != None:
            club_id = club.id
        else:
            club_id = 0

        subunit = organizationhelpers.getSubUnitByName(helpers.decodeString(row[8]))
        if subunit != None:
            subunit_id = subunit.id
        
        village = organizationhelpers.getVillageByName(helpers.decodeString(row[7]))
        if village != None:
            village_id = village.id
            
        subcamp = organizationhelpers.getSubcampByName(helpers.decodeString(row[6]))
        if subcamp != None:
            subcamp_id = subcamp.id

        if row[0] != '':
            message = _('Duplicate, skipping')
            return {'success':False, 'message':message}
        if booking_no != '':
            participant = DBSession.query(Participant).filter(Participant.booking_no.like('%|'+booking_no+'|%'),).first()
            if participant == None:
                if booking_no_2 != '':
                    participant = DBSession.query(Participant).filter(Participant.booking_no.like('%|'+booking_no_2+'|%'),).first()
                    if participant == None:
                        participant = Participant()
                        participant.booking_no = '|' + booking_no + '|' + booking_no_2 + '|'
                else:
                    participant = Participant()
                    participant.booking_no = '|'+booking_no+'|'
        else:
            participant = DBSession.query(Participant).filter(Participant.booking_no.like('%|'+booking_no_2+'|%'),).first()
            if participant == None:
                participant = Participant()
                participant.booking_no = '|'+booking_no_2+'|'
                    
        
        if club_id != 0:
            participant.club_id = club_id
        if subunit_id != 0:
            participant.subunit_id = subunit_id
        if village_id != 0:
            participant.village_id = village_id
        if subcamp_id != 0:
            participant.subcamp_id = subcamp_id


        # perheleirin lapsi
        if row[23] != '':
            participant.agegroup = 1
        participant.firstname = firstname
        participant.lastname = lastname
        
        DBSession.add(participant)
        DBSession.flush()

        key = 9
        
        while key < 23:
            ret = self.getParticipantContinuousPresence(row=row, start_key=key)
            if ret != False:
                key = key + ret['days_in_row']
                participantPresence = ParticipantPresence(participant_id=participant.id, starts = ret['start'], ends = ret['end'])
                DBSession.add(participantPresence)
                DBSession.flush()
            else:
                key = key +1

        message = _('Imported presence to ${bookingnumber}', mapping={'bookingnumber':helpers.decodeString(row[1])})

        return {'success':True, 'message':message}
    
    def getParticipantContinuousPresence(self, row, start_key):
        start = None
        end = None
        days_in_row = 0
        camp_start = datetime(2012, 7, 28, 12)
        key = start_key
        if row[key] == '':
            return False
        else:
            while str(row[key].strip()) == '1' and key < 23:
                key = key +1
            days_in_row = key - start_key
            start = camp_start + relativedelta( days = +(start_key-9) )
            end = start + relativedelta( days = +days_in_row )
            end = end + relativedelta( seconds = -1 )
            ret = {
                'days_in_row':days_in_row,
                'start':start,
                'end':end
            }
            return ret
    
    @view_config(route_name='settings_imports_users', renderer='settings/imports/users.mak', permission='settings_imports')
    def settings_imports_users(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        messages = []
        default_settings = self.getDefaultImportSettings()
        if self.request.method == 'POST':
            settings = {
                'rows_per_run':self.request.POST['rows_per_run'].strip(),
                'delay_seconds':self.request.POST['delay_seconds'].strip(),
                'delimeter':self.request.POST['delimeter'].strip(),
                'has_headers':self.request.POST['has_headers'].strip(),
            }
            importer = self.saveFileToImport(file=self.request.POST['file_to_import'], settings=settings, import_type="users")

            if importer.id:
                return HTTPFound(location='/settings/imports/run_importer/'+str(importer.id)+'/')

        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/imports/', 'text':_('Imports')})
        self.request.bread.append({'url':'/settings/imports/users/', 'text':_('Import users')})
        return {'default_settings':default_settings}
    
    def importUserRow(self, row):
        _ = self.request.translate
        message = ''
        
        firstname = row[0]
        lastname = row[1]
        email = row[2]
        username = row[3]
        password = row[4]
        title = row[5]
        group_id = row[6].strip()
        if password == None or password == '' :
            password = self.nicepass(8,4)
        
        user = User()
        user.firstname = firstname.strip()
        user.lastname = lastname.strip()
        user.email = email.strip()
        user.title = title.strip()
        user.username = username.strip()
        if user.username == '':
            message = _('Empty username, skipping')
            return {'success':False, 'message':message}
        user.set_password(password)
        user.needs_password_change = True
        user.language = 'fi_FI'
        
        
        if group_id != None and group_id.strip() != '' and group_id.isdigit():
            group = DBSession.query(Group).get(int(group_id))
            user.groups.append(group)
        
        if self.checkIfUsernameExists(user.username):
            message = _('User with ${username} allready exists, skipping', mapping={'username':helpers.decodeString(username)})
            return {'success':False, 'message':message}
        
        DBSession.add(user)
        DBSession.flush()
        
        
        if self.request.registry.settings['leirirekkari.use_mailer'] == 'true':
            if len(row) > 7 and row[7] != None and row[7] == '1' and user.email != '':
                mailer = get_mailer(self.request)
            
                setting_site_name = DBSession.query(Setting).filter(Setting.setting_key == 'site_name').first()
                setting_mail_sent_from = DBSession.query(Setting).filter(Setting.setting_key == 'mail_sent_from').first()
                setting_site_url = DBSession.query(Setting).filter(Setting.setting_key == 'site_url').first()
            
                message_subject = _(u"User account information for") + ' ' + setting_site_name.setting_value
                message_body = _(u"Hi\n\nHere are your account details for ${site_name}.\n\nUsername: ${username}\n\nPassword: ${password}\n\nYou can login at ${site_url}\n\nRemember to behave and that all the personal data is classified and should be used and distributed carefully.", 
                    mapping={'site_name':setting_site_name.setting_value, 'username':user.username, 'password':password, 'site_url':setting_site_url.setting_value})
            
                message = Message(subject=message_subject,
                    sender=setting_mail_sent_from.setting_value,
                    recipients=[user.email],
                    body=message_body)
                mailer.send(message)
                message = _('Imported user ${username} and sended password by email to address ${email}', mapping={'username':helpers.decodeString(username),'email':helpers.decodeString(email)})

        if message == '':
            message = _('Imported user ${username} with password ${password}', mapping={'username':helpers.decodeString(username),'password':helpers.decodeString(password)})

        return {'success':True, 'message':message}
        

    def getDefaultImportSettings(self):
        default_values = DBSession.query(Setting).with_entities(Setting.setting_key, Setting.setting_value).filter(Setting.setting_key.like('import_default%')).all()
        defaults = {}
        for default_value in default_values:
            defaults[default_value[0]] = default_value[1]
        return defaults
        
        
    def saveFileToImport(self, file, settings, import_type = None):
        if import_type == None:
            return False
            
        base_path_obj = DBSession.query(Setting).filter(Setting.setting_key == 'import_file_upload_dir').first()
        base_path = base_path_obj.setting_value
        if (file != None and file.filename != None):
            dt = datetime.now()
            now_str = dt.strftime("%Y_%m_%d_%H%M%S")
            filename = 'leirirekkari_import_' + now_str + '_' + file.filename
            input_file = file.file
            filepath = os.path.join(base_path, filename)
            output_file = open(filepath, 'wb')
            
            input_file.seek(0)
            while 1:
                data = input_file.read(2<<16)
                if not data:
                    break
                output_file.write(data)
            output_file.close()

            num_rows = sum(1 for line in open(filepath))

            importer = Importer()
            importer.filepath = filepath
            importer.import_type = import_type
            importer.total_rows = num_rows
            importer.has_headers = settings['has_headers']
            importer.delimeter = settings['delimeter']
            importer.rows_per_run = int(settings['rows_per_run'])
            importer.delay_seconds = int(settings['delay_seconds'])
            importer.rows_read = 0
            importer.successfull_imports = 0
            DBSession.add(importer)
            DBSession.flush()
            return importer
        return False
    
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
    config.add_route('settings_imports_frontpage', '/settings/imports/')
    config.add_route('settings_imports_clubs', '/settings/imports/clubs/')
    config.add_route('settings_imports_organization', '/settings/imports/organization/')
    config.add_route('settings_imports_polkubookings', '/settings/imports/polkubookings/')
    config.add_route('settings_imports_polkuanswers', '/settings/imports/polkuanswers/')
    config.add_route('settings_imports_polkuanswers_payments', '/settings/imports/polkuanswers_payments/')
    config.add_route('settings_imports_polkuit', '/settings/imports/polkuit/')
    config.add_route('settings_imports_presences', '/settings/imports/precences/')
    config.add_route('settings_imports_users', '/settings/imports/users/')
    config.add_route('settings_imports_run_importer', '/settings/imports/run_importer/{importer_id}/')
    
# -*- coding: utf-8 -*-
from pyramid.response import Response
from pyramid.view import view_config
import pyramid.security as security

from sqlalchemy.exc import DBAPIError
from sqlalchemy import or_, and_
from pyramid.httpexceptions import HTTPFound

from leirirekkari.models.dbsession import (
    DBSession
    )

from leirirekkari.models.user import (
    User, Group, Privilege, UserAudit, UserLogin
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
from leirirekkari.models.medical import (
    MedicalCard,
    MedicalCardEvent,
    MedicalParticipantStatus,
    MedicalParticipantAdditional,
    MedicalReason,
    MedicalTreatmentType,
    MedicalMethodOfArrival,
    )
    
import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.organization as organizationhelpers
import leirirekkari.helpers.user as userhelpers

from pyramid.i18n import get_localizer, negotiate_locale_name
from pyramid.i18n import TranslationString
from pyramid.i18n import get_locale_name

from datetime import datetime
from dateutil.relativedelta import relativedelta

from leirirekkari import checkBrowser, checkDevice

class OfficeViews(object):
    def __init__(self, request):
        if checkBrowser(request) or checkDevice(request):
            request.redirect_forbidden = True
        else:
            request.redirect_forbidden = False
        self.request = request
    
    @view_config(route_name='medical_frontpage', renderer='medical/index.mak', permission='medical_view')
    def medical_frontpage(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        self.request.bread.append({'url':'/medical/', 'text':_('Medical')})
        return {}
    
    @view_config(route_name='medical_search_participant', renderer='medical/search_participant_res.mak', permission='medical_view')
    def medical_search_participant(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        if self.request.method == 'POST':
            search_string = self.request.POST.get('search_str').strip()
            if len(search_string) < 3:
                return {'participants':[]}
            participants = DBSession.query(Participant).filter(
                or_(
                Participant.firstname.like('%'+search_string+'%'),
                Participant.lastname.like('%'+search_string+'%'),
                Participant.nickname.like('%'+search_string+'%'),
                Participant.member_no.like('%'+search_string+'%')
                )).order_by(Participant.lastname, Participant.firstname).all()
            return {'participants':participants}
        return {'participants':[]}
        
    @view_config(route_name='medical_search_card', renderer='medical/search_card_res.mak', permission='medical_view')
    def medical_search_card(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        if self.request.method == 'POST':
            search_string = self.request.POST.get('search_str').strip()
            if search_string.isdigit():
                cards = DBSession.query(MedicalCard).filter(MedicalCard.id == int(search_string)).all()
                return {'cards':cards}
            else:
                cards = DBSession.query(MedicalCard).select_from(MedicalCard).outerjoin(Participant).filter(
                    or_(
                    Participant.firstname.like('%'+search_string+'%'),
                    Participant.lastname.like('%'+search_string+'%'),
                    Participant.nickname.like('%'+search_string+'%'),
                    Participant.member_no.like('%'+search_string+'%')
                    )).all()
                return {'cards':cards}

        return {'cards':[]}

    @view_config(route_name='medical_card_list', renderer='medical/card/list.mak', permission='medical_view')
    def medical_card_list(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        
        cards = DBSession.query(MedicalCard).all()

        return {'cards':cards}

    @view_config(route_name='medical_card_new', renderer='medical/card/new.mak', permission='medical_add_card')
    def medical_card_new(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        participant_id = self.request.matchdict['participant_id']

        participant = DBSession.query(Participant).filter(Participant.id==participant_id).first()
        participant.getParticipantMedicalData()

        if participant.medical_data == None:
            participant.medical_data = ParticipantMedical()
        
        medicalCard = MedicalCard()
        medicalCard.participant_id = participant.id
        medicalCardEvents = []
        medicalCardEvents.append(MedicalCardEvent())
        
        medicalParticipantAdditional = DBSession.query(MedicalParticipantAdditional).filter(MedicalParticipantAdditional.participant_id==participant_id).first()
        if medicalParticipantAdditional == None:
            medicalParticipantAdditional = MedicalParticipantAdditional()
            medicalParticipantAdditional.participant_id = participant_id
            DBSession.add(medicalParticipantAdditional)
            DBSession.flush()
        

        reasons = DBSession.query(MedicalReason).order_by(MedicalReason.title).all()
        treatmenttypes = DBSession.query(MedicalTreatmentType).order_by(MedicalTreatmentType.title).all()
        methodsofarrival = DBSession.query(MedicalMethodOfArrival).order_by(MedicalMethodOfArrival.title).all()

        if self.request.method == 'POST':
            # save card
            medicalCard.hospital_in = helpers.parseFinnishDateFromString(self.request.POST.get('hospital_in'), True)
            medicalCard.hospital_out = helpers.parseFinnishDateFromString(self.request.POST.get('hospital_out'))
            medicalCard.method_of_arrival = int(self.request.POST.get('method_of_arrival'))
            medicalCard.medications = int(self.request.POST.get('medications'))
            medicalCard.medications_info = self.request.POST.get('medications_info').strip()
            medicalCard.treatment_type = int(self.request.POST.get('treatment_type'))
            medicalCard.reason_id = int(self.request.POST.get('reason_id'))
            medicalCard.diagnose = self.request.POST.get('diagnose').strip()
            medicalCard.followup_going = self.request.POST.get('followup_going').strip()
            medicalCard.followup_notes = self.request.POST.get('followup_notes').strip()
            medicalCard.card_status = int(self.request.POST.get('card_status').strip())
            
            DBSession.add(medicalCard)
            DBSession.flush()
                        
            #save participant additional
            medicalParticipantAdditional.hetu = self.request.POST.get('additional_hetu').strip()
            medicalParticipantAdditional.notes = self.request.POST.get('additional_notes').strip()
            medicalParticipantAdditional.insurance = int(self.request.POST.get('additional_insurance'))
            medicalParticipantAdditional.insurance_company = self.request.POST.get('additional_insurance_company').strip()
            medicalParticipantAdditional.insurance_number = self.request.POST.get('additional_insurance_number').strip()
            DBSession.add(medicalParticipantAdditional)
            DBSession.flush()
            
            #save card event
            medicalCardEvents[0].card_id = medicalCard.id
            medicalCardEvents[0].notes = self.request.POST.get('event_notes').strip()
            medicalCardEvents[0].event_time = helpers.parseFinnishDateFromString(self.request.POST.get('event_time').strip(), True)
            medicalCardEvents[0].writer = self.request.POST.get('event_writer').strip()
            medicalCardEvents[0].event_type = int(self.request.POST.get('event_type'))
            
            DBSession.add(medicalCardEvents[0])
            DBSession.flush()
            
            # save participant medical
            if len(self.request.POST.getall('medical_diet'))>0:
                participant.medical_data.diets = DBSession.query(ParticipantMedicalDiet).filter(ParticipantMedicalDiet.id.in_(self.request.POST.getall('medical_diet'))).all()
                            
            if len(self.request.POST.getall('medical_food_allergy'))>0:
                participant.medical_data.food_allergies = DBSession.query(ParticipantMedicalFoodAllergy).filter(ParticipantMedicalFoodAllergy.id.in_(self.request.POST.getall('medical_food_allergy'))).all()

            participant.medical_data.additional_food = self.request.POST.get('medical_additional_food').strip()
            participant.medical_data.drugs_help = int(self.request.POST.get('medical_drugs_help'))
            participant.medical_data.illnesses = self.request.POST.get('medical_illnesses').strip()

            if len(self.request.POST.getall('medical_allergy'))>0:
                participant.medical_data.allergies = DBSession.query(ParticipantMedicalAllergy).filter(ParticipantMedicalAllergy.id.in_(self.request.POST.getall('medical_allergy'))).all()

            participant.medical_data.additional_health = self.request.POST.get('medical_additional_health').strip()
            participant.medical_data.week_of_pregnancy = self.request.POST.get('medical_week_of_pregnancy').strip()

            participant.medical_data.participant_id = participant_id
            DBSession.add(participant.medical_data)
            DBSession.flush()
            

            return HTTPFound(location='/medical/card/view/'+str(medicalCard.id)+'/')


        self.request.bread.append({'url':'/medical/', 'text':_('Medical')})
        self.request.bread.append({'url':'/medical/card/new/'+participant_id+'/', 'text':_('New card')})
        return {'medicalCard':medicalCard, 'participant':participant, 'medicalParticipantAdditional':medicalParticipantAdditional, 'medicalCardEvents':medicalCardEvents, 'reasons':reasons, 'treatmenttypes':treatmenttypes, 'methodsofarrival':methodsofarrival}


    @view_config(route_name='medical_card_edit', renderer='medical/card/edit.mak', permission='medical_add_card')
    def medical_card_edit(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        card_id = self.request.matchdict['card_id']
        
        medicalCard = DBSession.query(MedicalCard).filter(MedicalCard.id==card_id).first()
        
        participant_id = medicalCard.participant_id

        participant = DBSession.query(Participant).filter(Participant.id==participant_id).first()
        participant.getParticipantMedicalData()

        medicalCardEvents = DBSession.query(MedicalCardEvent).filter(MedicalCardEvent.card_id==card_id).order_by(MedicalCardEvent.event_time).all()
        
        medicalParticipantAdditional = DBSession.query(MedicalParticipantAdditional).filter(MedicalParticipantAdditional.participant_id==participant_id).first()        

        reasons = DBSession.query(MedicalReason).order_by(MedicalReason.title).all()
        treatmenttypes = DBSession.query(MedicalTreatmentType).order_by(MedicalTreatmentType.title).all()
        methodsofarrival = DBSession.query(MedicalMethodOfArrival).order_by(MedicalMethodOfArrival.title).all()

        if self.request.method == 'POST':
            # save card
            medicalCard.hospital_in = helpers.parseFinnishDateFromString(self.request.POST.get('hospital_in'), True)
            medicalCard.hospital_out = helpers.parseFinnishDateFromString(self.request.POST.get('hospital_out'))
            medicalCard.method_of_arrival = int(self.request.POST.get('method_of_arrival'))
            medicalCard.medications = int(self.request.POST.get('medications'))
            medicalCard.medications_info = self.request.POST.get('medications_info').strip()
            medicalCard.treatment_type = int(self.request.POST.get('treatment_type'))
            medicalCard.reason_id = int(self.request.POST.get('reason_id'))
            medicalCard.diagnose = self.request.POST.get('diagnose').strip()
            medicalCard.followup_going = self.request.POST.get('followup_going').strip()
            medicalCard.followup_notes = self.request.POST.get('followup_notes').strip()
            medicalCard.card_status = int(self.request.POST.get('card_status').strip())
            
            DBSession.add(medicalCard)
            DBSession.flush()
                        
            #save participant additional
            medicalParticipantAdditional.hetu = self.request.POST.get('additional_hetu').strip()
            medicalParticipantAdditional.notes = self.request.POST.get('additional_notes').strip()
            medicalParticipantAdditional.insurance = int(self.request.POST.get('additional_insurance'))
            medicalParticipantAdditional.insurance_company = self.request.POST.get('additional_insurance_company').strip()
            medicalParticipantAdditional.insurance_number = self.request.POST.get('additional_insurance_number').strip()
            DBSession.add(medicalParticipantAdditional)
            DBSession.flush()
            
            #save card event
            
            if len(self.request.POST.getall('event_id')) > 0:
                event_ids = self.request.POST.getall('event_id')
                if len(medicalCardEvents) > 0:
                    for medicalCardEvent in medicalCardEvents:
                        if str(medicalCardEvent.id) not in event_ids:
                            DBSession.delete(medicalCardEvent)
                    DBSession.flush()
                
                event_times = self.request.POST.getall('event_time')
                event_writers = self.request.POST.getall('event_writer')
                event_types = self.request.POST.getall('event_type')
                event_notes = self.request.POST.getall('event_notes')

                for key, event_note in enumerate(event_notes):
                    if event_note != '':
                        event_time = event_times[key]
                        event_id = event_ids[key]
                        event_writer = event_writers[key]
                        event_type = event_types[key]
                        
                        event_time_dt = helpers.parseFinnishDateFromString(event_time)

                        if int(event_ids[key]) == 0:
                            tmp_event = MedicalCardEvent()
                            tmp_event.card_id = medicalCard.id
                        else:
                            tmp_event = DBSession.query(MedicalCardEvent).get(event_ids[key])
                        tmp_event.notes = event_note
                        tmp_event.event_time = helpers.parseFinnishDateFromString(event_time)
                        tmp_event.writer = event_writer
                        tmp_event.event_type = event_type

                        DBSession.add(tmp_event)
                        DBSession.flush()

            elif len(medicalCardEvents) > 0:
                for event in medicalCardEvents:
                    DBSession.delete(event)
                DBSession.flush()
            
            # save participant medical
            if len(self.request.POST.getall('medical_diet'))>0:
                participant.medical_data.diets = DBSession.query(ParticipantMedicalDiet).filter(ParticipantMedicalDiet.id.in_(self.request.POST.getall('medical_diet'))).all()
                            
            if len(self.request.POST.getall('medical_food_allergy'))>0:
                participant.medical_data.food_allergies = DBSession.query(ParticipantMedicalFoodAllergy).filter(ParticipantMedicalFoodAllergy.id.in_(self.request.POST.getall('medical_food_allergy'))).all()

            participant.medical_data.additional_food = self.request.POST.get('medical_additional_food').strip()
            participant.medical_data.drugs_help = int(self.request.POST.get('medical_drugs_help'))
            participant.medical_data.illnesses = self.request.POST.get('medical_illnesses').strip()

            if len(self.request.POST.getall('medical_allergy'))>0:
                participant.medical_data.allergies = DBSession.query(ParticipantMedicalAllergy).filter(ParticipantMedicalAllergy.id.in_(self.request.POST.getall('medical_allergy'))).all()

            participant.medical_data.additional_health = self.request.POST.get('medical_additional_health').strip()
            participant.medical_data.week_of_pregnancy = self.request.POST.get('medical_week_of_pregnancy').strip()

            participant.medical_data.participant_id = participant_id
            DBSession.add(participant.medical_data)
            DBSession.flush()
            

            return HTTPFound(location='/medical/card/view/'+str(medicalCard.id)+'/')


        self.request.bread.append({'url':'/medical/', 'text':_('Medical')})
        self.request.bread.append({'url':'/medical/card/edit/'+str(card_id)+'/', 'text':_('Edit card')})
        return {'medicalCard':medicalCard, 'participant':participant, 'medicalParticipantAdditional':medicalParticipantAdditional, 'medicalCardEvents':medicalCardEvents, 'reasons':reasons, 'treatmenttypes':treatmenttypes, 'methodsofarrival':methodsofarrival}

    @view_config(route_name='medical_card_view', renderer='medical/card/view.mak', permission='medical_add_card')
    def medical_card_view(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        card_id = self.request.matchdict['card_id']
        
        medicalCard = DBSession.query(MedicalCard).filter(MedicalCard.id==card_id).first()
        
        participant_id = medicalCard.participant_id

        participant = DBSession.query(Participant).filter(Participant.id==participant_id).first()
        participant.getParticipantMedicalData()

        medicalCardEvents = DBSession.query(MedicalCardEvent).filter(MedicalCardEvent.card_id==card_id).order_by(MedicalCardEvent.event_time).all()
        
        medicalParticipantAdditional = DBSession.query(MedicalParticipantAdditional).filter(MedicalParticipantAdditional.participant_id==participant_id).first()

        reasons = DBSession.query(MedicalReason).order_by(MedicalReason.title).all()
        treatmenttypes = DBSession.query(MedicalTreatmentType).order_by(MedicalTreatmentType.title).all()
        methodsofarrival = DBSession.query(MedicalMethodOfArrival).order_by(MedicalMethodOfArrival.title).all()
        
        participant_cards = DBSession.query(MedicalCard).filter(MedicalCard.participant_id==participant_id).all()

        self.request.bread.append({'url':'/medical/', 'text':_('Medical')})
        self.request.bread.append({'url':'/medical/card/view/'+str(card_id)+'/', 'text':_('View card')})
        return {'medicalCard':medicalCard, 'participant':participant, 'medicalParticipantAdditional':medicalParticipantAdditional, 'medicalCardEvents':medicalCardEvents, 'reasons':reasons, 'treatmenttypes':treatmenttypes, 'methodsofarrival':methodsofarrival, 'participant_cards':participant_cards}

    @view_config(route_name='medical_settings', renderer='medical/settings/index.mak', permission='medical_settings')
    def medical_settings(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        
        reasons = DBSession.query(MedicalReason).order_by(MedicalReason.title).all()
        treatmenttypes = DBSession.query(MedicalTreatmentType).order_by(MedicalTreatmentType.title).all()
        methodsofarrival = DBSession.query(MedicalMethodOfArrival).order_by(MedicalMethodOfArrival.title).all()
        
        self.request.bread.append({'url':'/medical/', 'text':_('Medical')})
        self.request.bread.append({'url':'/medical/settings/', 'text':_('Settings')})
        return {'reasons':reasons, 'treatmenttypes':treatmenttypes, 'methodsofarrival':methodsofarrival}

    @view_config(route_name='medical_settings_reasons_new', renderer='medical/settings/new_reason.mak', permission='medical_settings')
    def medical_settings_reasons_new(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        reason = MedicalReason()
        
        if self.request.method == 'POST':
            reason.title = self.request.POST.get('title').strip()
            reason.description = self.request.POST.get('description').strip()
            if reason.title != '':
                DBSession.add(reason)
                DBSession.flush()
                self.request.session.flash(_(u"Reason created."), 'success')
                return HTTPFound(location='/medical/settings/')
            else:
                self.request.session.flash(_(u"Please provide title."), 'error')


        self.request.bread.append({'url':'/medical/', 'text':_('Medical')})
        self.request.bread.append({'url':'/medical/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/medical/settings/reasons/new/', 'text':_('New reason')})
        return {'reason':reason}
        
    @view_config(route_name='medical_settings_reasons_edit', renderer='medical/settings/edit_reason.mak', permission='medical_settings')
    def medical_settings_reasons_edit(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        reason_id = self.request.matchdict['reason_id']

        reason = DBSession.query(MedicalReason).filter(MedicalReason.id==reason_id).first()

        if self.request.method == 'POST':
            reason.title = self.request.POST.get('title').strip()
            reason.description = self.request.POST.get('description').strip()
            if reason.title != '':
                DBSession.add(reason)
                DBSession.flush()
                self.request.session.flash(_(u"Reason saved."), 'success')
                return HTTPFound(location='/medical/settings/')
            else:
                self.request.session.flash(_(u"Please provide title."), 'error')


        self.request.bread.append({'url':'/medical/', 'text':_('Medical')})
        self.request.bread.append({'url':'/medical/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/medical/settings/reasons/new/', 'text':_('Edit reason')})
        return {'reason':reason}
    
    @view_config(route_name='medical_settings_treatmenttypes_new', renderer='medical/settings/new_treatmenttype.mak', permission='medical_settings')
    def medical_settings_treatmenttypes_new(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        treatmenttype = MedicalTreatmentType()

        if self.request.method == 'POST':
            treatmenttype.title = self.request.POST.get('title').strip()
            treatmenttype.description = self.request.POST.get('description').strip()
            if treatmenttype.title != '':
                DBSession.add(treatmenttype)
                DBSession.flush()
                self.request.session.flash(_(u"Treatmenttype created."), 'success')
                return HTTPFound(location='/medical/settings/')
            else:
                self.request.session.flash(_(u"Please provide title."), 'error')


        self.request.bread.append({'url':'/medical/', 'text':_('Medical')})
        self.request.bread.append({'url':'/medical/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/medical/settings/treatmenttypes/new/', 'text':_('New treatmenttype')})
        return {'treatmenttype':treatmenttype}

    @view_config(route_name='medical_settings_treatmenttypes_edit', renderer='medical/settings/edit_treatmenttype.mak', permission='medical_settings')
    def medical_settings_treatmenttypes_edit(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        treatmenttype_id = self.request.matchdict['treatmenttype_id']

        treatmenttype = DBSession.query(MedicalTreatmentType).filter(MedicalTreatmentType.id==treatmenttype_id).first()

        if self.request.method == 'POST':
            treatmenttype.title = self.request.POST.get('title').strip()
            treatmenttype.description = self.request.POST.get('description').strip()
            if treatmenttype.title != '':
                DBSession.add(treatmenttype)
                DBSession.flush()
                self.request.session.flash(_(u"Treatmenttype saved."), 'success')
                return HTTPFound(location='/medical/settings/')
            else:
                self.request.session.flash(_(u"Please provide title."), 'error')


        self.request.bread.append({'url':'/medical/', 'text':_('Medical')})
        self.request.bread.append({'url':'/medical/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/medical/settings/treatmenttypes/new/', 'text':_('Edit treatmenttype')})
        return {'treatmenttype':treatmenttype}
        
    @view_config(route_name='medical_settings_methodofarrivals_new', renderer='medical/settings/new_methodofarrival.mak', permission='medical_settings')
    def medical_settings_methodofarrivals_new(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        methodofarrival = MedicalMethodOfArrival()

        if self.request.method == 'POST':
            methodofarrival.title = self.request.POST.get('title').strip()
            methodofarrival.description = self.request.POST.get('description').strip()
            if methodofarrival.title != '':
                DBSession.add(methodofarrival)
                DBSession.flush()
                self.request.session.flash(_(u"MethodOfArrival created."), 'success')
                return HTTPFound(location='/medical/settings/')
            else:
                self.request.session.flash(_(u"Please provide title."), 'error')


        self.request.bread.append({'url':'/medical/', 'text':_('Medical')})
        self.request.bread.append({'url':'/medical/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/medical/settings/methodofarrivals/new/', 'text':_('New methodofarrival')})
        return {'methodofarrival':methodofarrival}

    @view_config(route_name='medical_settings_methodofarrivals_edit', renderer='medical/settings/edit_methodofarrival.mak', permission='medical_settings')
    def medical_settings_methodofarrivals_edit(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        methodofarrival_id = self.request.matchdict['methodofarrival_id']

        methodofarrival = DBSession.query(MedicalMethodOfArrival).filter(MedicalMethodOfArrival.id==methodofarrival_id).first()

        if self.request.method == 'POST':
            methodofarrival.title = self.request.POST.get('title').strip()
            methodofarrival.description = self.request.POST.get('description').strip()
            if methodofarrival.title != '':
                DBSession.add(methodofarrival)
                DBSession.flush()
                self.request.session.flash(_(u"MethodOfArrival saved."), 'success')
                return HTTPFound(location='/medical/settings/')
            else:
                self.request.session.flash(_(u"Please provide title."), 'error')


        self.request.bread.append({'url':'/medical/', 'text':_('Medical')})
        self.request.bread.append({'url':'/medical/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/medical/settings/methodofarrivals/new/', 'text':_('Edit methodofarrival')})
        return {'methodofarrival':methodofarrival}

    @view_config(route_name='medical_statistics', renderer='medical/stats.mak', permission='medical_view')
    def medical_statistics(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        reasons = DBSession.query(MedicalReason).order_by(MedicalReason.title).all()
        treatmenttypes = DBSession.query(MedicalTreatmentType).order_by(MedicalTreatmentType.title).all()
        methodsofarrival = DBSession.query(MedicalMethodOfArrival).order_by(MedicalMethodOfArrival.title).all()

        filters = []
        
        start_datetime = ''
        end_datetime = ''

        if self.request.method == 'POST' and self.request.POST.get('start').strip() != '':
            start_datetime = self.request.POST.get('start').strip()
            start_dt = helpers.parseFinnishDateFromString(start_datetime)
            
            if self.request.POST.get('end').strip() != '':
                end_datetime = self.request.POST.get('end').strip()
                end_dt = helpers.parseFinnishDateFromString(end_datetime)
            else:
                end_dt = start_dt + relativedelta( days = +1 )
                end_datetime = helpers.modDateTime(end_dt)

            filters.append(MedicalCard.hospital_in >= start_dt)
            filters.append(MedicalCard.hospital_in <= end_dt)
        
        stats = {}
        
        reason_stats = {}
        treatmenttypes_stats = {}
        methodsofarrival_stats = {}
        
        for reason in reasons:
        
            report = DBSession.query(MedicalCard)
            if len(filters) > 0:
                report = report.filter(and_(*filters)) 
            report = report.filter(MedicalCard.reason_id==reason.id) 
            reason_stats[reason.id] = report.count()
            
        for treatmenttype in treatmenttypes:

            report = DBSession.query(MedicalCard)
            if len(filters) > 0:
                report = report.filter(and_(*filters)) 
            report = report.filter(MedicalCard.treatment_type==treatmenttype.id) 
            treatmenttypes_stats[treatmenttype.id] = report.count()
            
        for methodofarrival in methodsofarrival:

            report = DBSession.query(MedicalCard)
            if len(filters) > 0:
                report = report.filter(and_(*filters)) 
            report = report.filter(MedicalCard.method_of_arrival==methodofarrival.id) 
            methodsofarrival_stats[methodofarrival.id] = report.count()
        
        stats = {
            'reason_stats':reason_stats,
            'treatmenttypes_stats':treatmenttypes_stats,
            'methodsofarrival_stats':methodsofarrival_stats
        }
        
        
        self.request.bread.append({'url':'/medical/', 'text':_('Medical')})
        self.request.bread.append({'url':'/medical/statistics/', 'text':_('Statistics')})
        return {'stats':stats, 'start':start_datetime, 'end':end_datetime}
 
def includeme(config):
    config.add_route('medical_frontpage', '/medical/')
    config.add_route('medical_search_participant', '/medical/search_participant/')
    config.add_route('medical_search_card', '/medical/search_card/')
    config.add_route('medical_card_list', '/medical/card/list/')
    config.add_route('medical_card_new', '/medical/card/new/{participant_id}/')
    config.add_route('medical_card_view', '/medical/card/view/{card_id}/')
    config.add_route('medical_card_edit', '/medical/card/edit/{card_id}/')
    config.add_route('medical_statistics', '/medical/statistics/')
    config.add_route('medical_settings', '/medical/settings/')
    config.add_route('medical_settings_reasons_new', '/medical/settings/reasons/new/')
    config.add_route('medical_settings_reasons_edit', '/medical/settings/reasons/edit/{reason_id}/')
    config.add_route('medical_settings_treatmenttypes_new', '/medical/settings/treatmenttypes/new/')
    config.add_route('medical_settings_treatmenttypes_edit', '/medical/settings/treatmenttypes/edit/{treatmenttype_id}/')
    config.add_route('medical_settings_methodofarrivals_new', '/medical/settings/methodofarrival/new/')
    config.add_route('medical_settings_methodofarrivals_edit', '/medical/settings/methodofarrival/edit/{treatmenttype_id}/')
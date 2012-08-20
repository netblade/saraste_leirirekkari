# -*- coding: utf-8 -*-
from pyramid.response import Response
from pyramid.view import view_config
import pyramid.security as security

from sqlalchemy.exc import DBAPIError
from pyramid.httpexceptions import HTTPFound

from leirirekkari.models.dbsession import (
    DBSession
    )

from leirirekkari.models.organization import (
    Subcamp, Village, SubUnit, Club, VillageKitchen
    )
    
from leirirekkari.models.user import (
    User, Group, Privilege, UserAudit, UserLogin
    )


import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.user as userhelpers

from leirirekkari import checkBrowser, checkDevice

class SettingsOrganizationViews(object):
    def __init__(self, request):
        if checkBrowser(request) or checkDevice(request):
            request.redirect_forbidden = True
        else:
            request.redirect_forbidden = False
        self.request = request
    
    @view_config(route_name='settings_organization', renderer='settings/organization/index.mak', permission='settings_organization')
    def settings_organization_frontpage(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate
        subcamps = DBSession.query(Subcamp).all()
        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/organization/', 'text':_('Organization')})
        return {'subcamps':subcamps}
    
    @view_config(route_name='settings_organization_subcamp_new', renderer='settings/organization/new_subcamp.mak', permission='settings_organization')
    def settings_organization_subcamp_new(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        tmp_subcamp = {
            'name':'',
            'short_name':'',
            'leader_id':'',
        }

        if self.request.method == 'POST':
            tmp_subcamp['name'] = self.request.POST.get('name').strip()
            tmp_subcamp['short_name'] = self.request.POST.get('short_name').strip()
            #tmp_subcamp['leader_id'] = self.request.POST.get('leader_id').strip()
            tmp_subcamp['leader_id'] = 0
            if tmp_subcamp['name']:
                subcamp = Subcamp()
                subcamp.name = tmp_subcamp['name']
                subcamp.short_name = tmp_subcamp['short_name']
                subcamp.leader_id = int(tmp_subcamp['leader_id'])
                DBSession.add(subcamp)
                DBSession.flush()
                userAudit = UserAudit(self.request.user.id)
                userAudit.model = 'Subcamp'
                userAudit.model_id = subcamp.id
                userAudit.action = 'Update'
                userAudit.revision = subcamp.metadata_revision
                DBSession.add(userAudit)
                DBSession.flush()
                self.request.session.flash(_(u"Subcamp created."), 'success')
                return HTTPFound(location='/settings/organization/')
            else:
                self.request.session.flash(_(u"Please provide subcamp name."), 'error')

        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/organization/', 'text':_('Organization')})
        self.request.bread.append({'url':'/settings/organization/subcamp_new/', 'text':_('New subcamp')})
        return {'subcamp':tmp_subcamp}

    @view_config(route_name='settings_organization_subcamp_edit', renderer='settings/organization/edit_subcamp.mak', permission='settings_organization')
    def settings_organization_subcamp_edit(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        tmp_subcamp = {
            'name':'',
            'short_name':'',
            'leader_id':'',
        }

        subcamp_id = self.request.matchdict['subcamp_id']

        subcamp = DBSession.query(Subcamp).filter(Subcamp.id==subcamp_id).first()

        if subcamp.id:
            tmp_subcamp = {
                'name':subcamp.name,
                'short_name':subcamp.short_name,
                'leader_id':subcamp.leader_id,
            }

        if self.request.method == 'POST':
            tmp_subcamp['name'] = self.request.POST.get('name').strip()
            tmp_subcamp['short_name'] = self.request.POST.get('short_name').strip()
            #tmp_subcamp['leader_id'] = self.request.POST.get('leader_id').strip()
            tmp_subcamp['leader_id'] = 0
            if tmp_subcamp['name']:
                subcamp.name = tmp_subcamp['name']
                subcamp.short_name = tmp_subcamp['short_name']
                subcamp.leader_id = int(tmp_subcamp['leader_id'])
                DBSession.add(subcamp)
                DBSession.flush()
                userAudit = UserAudit(self.request.user.id)
                userAudit.model = 'Subcamp'
                userAudit.model_id = subcamp.id
                userAudit.action = 'Update'
                userAudit.revision = subcamp.metadata_revision
                DBSession.add(userAudit)
                DBSession.flush()
                self.request.session.flash(_(u"Subcamp saved."), 'success')
                return HTTPFound(location='/settings/organization/')
            else:
                self.request.session.flash(_(u"Please provide subcamp name."), 'error')
        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/organization/', 'text':_('Organization')})
        self.request.bread.append({'url':'/settings/organization/subcamp_edit/'+subcamp_id+'/', 'text':_('Edit subcamp')})
        return {'subcamp':tmp_subcamp}

    @view_config(route_name='settings_organization_village_new', renderer='settings/organization/new_village.mak', permission='settings_organization')
    def settings_organization_village_new(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        tmp_village = {
            'name':'',
            'short_name':'',
            'leader_id':'',
            'subcamp_id':0,
        }
        
        subcamps = DBSession.query(Subcamp).all()

        if self.request.method == 'POST':
            tmp_village['name'] = self.request.POST.get('name').strip()
            tmp_village['short_name'] = self.request.POST.get('short_name').strip()
            #tmp_village['leader_id'] = self.request.POST.get('leader_id').strip()
            tmp_village['leader_id'] = 0
            tmp_village['subcamp_id'] = self.request.POST.get('subcamp_id').strip()
            if tmp_village['name']:
                village = Village()
                village.name = tmp_village['name']
                village.short_name = tmp_village['short_name']
                village.leader_id = tmp_village['leader_id']
                village.subcamp_id = tmp_village['subcamp_id']
                DBSession.add(village)
                DBSession.flush()
                userAudit = UserAudit(self.request.user.id)
                userAudit.model = 'Village'
                userAudit.model_id = village.id
                userAudit.action = 'Create'
                userAudit.revision = village.metadata_revision
                DBSession.add(userAudit)
                DBSession.flush()
                self.request.session.flash(_(u"Village created."), 'success')
                return HTTPFound(location='/settings/organization/')
            else:
                self.request.session.flash(_(u"Please provide village name."), 'error')

        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/organization/', 'text':_('Organization')})
        self.request.bread.append({'url':'/settings/organization/village_new/', 'text':_('New village')})
        return {'village':tmp_village, 'subcamps':subcamps}

    @view_config(route_name='settings_organization_village_edit', renderer='settings/organization/edit_village.mak', permission='settings_organization')
    def settings_organization_village_edit(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        tmp_village = {
            'name':'',
            'short_name':'',
            'leader_id':'',
            'subcamp_id':0,
        }

        village_id = self.request.matchdict['village_id']

        village = DBSession.query(Village).filter(Village.id==village_id).first()

        subcamps = DBSession.query(Subcamp).all()

        if village.id:
            tmp_village = {
                'name':village.name,
                'short_name':village.short_name,
                'leader_id':village.leader_id,
                'subcamp_id':village.subcamp_id,
            }

        if self.request.method == 'POST':
            tmp_village['name'] = self.request.POST.get('name').strip()
            tmp_village['short_name'] = self.request.POST.get('short_name').strip()
            #tmp_village['leader_id'] = self.request.POST.get('leader_id').strip()
            tmp_village['leader_id'] = 0
            tmp_village['subcamp_id'] = self.request.POST.get('subcamp_id').strip()
            if tmp_village['name']:
                village.name = tmp_village['name']
                village.short_name = tmp_village['short_name']
                village.leader_id = tmp_village['leader_id']
                village.subcamp_id = tmp_village['subcamp_id']
                DBSession.add(village)
                DBSession.flush()
                userAudit = UserAudit(self.request.user.id)
                userAudit.model = 'Village'
                userAudit.model_id = village.id
                userAudit.action = 'Update'
                userAudit.revision = village.metadata_revision
                DBSession.add(userAudit)
                DBSession.flush()
                self.request.session.flash(_(u"Village saved."), 'success')
                return HTTPFound(location='/settings/organization/')
            else:
                self.request.session.flash(_(u"Please provide village name."), 'error')


        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/organization/', 'text':_('Organization')})
        self.request.bread.append({'url':'/settings/organization/village_edit/'+village_id+'/', 'text':_('Edit village')})
        return {'village':tmp_village, 'subcamps':subcamps}
    

    @view_config(route_name='settings_organization_subunit_new', renderer='settings/organization/new_subunit.mak', permission='settings_organization')
    def settings_organization_subunit_new(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        tmp_subunit = {
            'name':'',
            'short_name':'',
            'leader_id':'',
            'village_id':0,
        }

        if self.request.method == 'POST':
            tmp_subunit['name'] = self.request.POST.get('name').strip()
            tmp_subunit['short_name'] = self.request.POST.get('short_name').strip()
            #tmp_subunit['leader_id'] = self.request.POST.get('leader_id').strip()
            tmp_subunit['leader_id'] = 0
            tmp_subunit['village_id'] = self.request.POST.get('village_id').strip()
            if tmp_subunit['name']:
                subunit = SubUnit()
                subunit.name = tmp_subunit['name']
                subunit.short_name = tmp_subunit['short_name']
                subunit.leader_id = tmp_subunit['leader_id']
                subunit.village_id = tmp_subunit['village_id']
                DBSession.add(subunit)
                DBSession.flush()
                userAudit = UserAudit(self.request.user.id)
                userAudit.model = 'SubUnit'
                userAudit.model_id = subunit.id
                userAudit.action = 'Create'
                userAudit.revision = subunit.metadata_revision
                DBSession.add(userAudit)
                DBSession.flush()
                self.request.session.flash(_(u"Subunit created."), 'success')
                return HTTPFound(location='/settings/organization/')
            else:
                self.request.session.flash(_(u"Please provide subunit name."), 'error')

        villages = DBSession.query(Village).all()
        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/organization/', 'text':_('Organization')})
        self.request.bread.append({'url':'/settings/organization/subunit_new/', 'text':_('New subunit')})
        return {'subunit':tmp_subunit, 'villages':villages}

    @view_config(route_name='settings_organization_subunit_edit', renderer='settings/organization/edit_subunit.mak', permission='settings_organization')
    def settings_organization_subunit_edit(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        tmp_subunit = {
            'name':'',
            'short_name':'',
            'leader_id':'',
            'village_id':0,
        }

        subunit_id = self.request.matchdict['subunit_id']

        subunit = DBSession.query(SubUnit).filter(SubUnit.id==subunit_id).first()

        if subunit.id:
            tmp_subunit = {
                'name':subunit.name,
                'short_name':subunit.short_name,
                'leader_id':subunit.leader_id,
                'village_id':subunit.village_id,
            }

        if self.request.method == 'POST':
            tmp_subunit['name'] = self.request.POST.get('name').strip()
            tmp_subunit['short_name'] = self.request.POST.get('short_name').strip()
            #tmp_subunit['leader_id'] = self.request.POST.get('leader_id').strip()
            tmp_subunit['leader_id'] = 0
            tmp_subunit['village_id'] = self.request.POST.get('village_id').strip()
            if tmp_subunit['name']:
                subunit.name = tmp_subunit['name']
                subunit.short_name = tmp_subunit['short_name']
                subunit.leader_id = tmp_subunit['leader_id']
                subunit.village_id = tmp_subunit['village_id']
                DBSession.add(subunit)
                DBSession.flush()
                userAudit = UserAudit(self.request.user.id)
                userAudit.model = 'SubUnit'
                userAudit.model_id = subunit.id
                userAudit.action = 'Update'
                userAudit.revision = subunit.metadata_revision
                DBSession.add(userAudit)
                DBSession.flush()
                self.request.session.flash(_(u"Subunit saved."), 'success')
                return HTTPFound(location='/settings/organization/')
            else:
                self.request.session.flash(_(u"Please provide subunit name."), 'error')

        villages = DBSession.query(Village).all()
        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/organization/', 'text':_('Organization')})
        self.request.bread.append({'url':'/settings/organization/subunit_edit/'+subunit_id+'/', 'text':_('Edit subunit')})
        return {'subunit':tmp_subunit, 'villages':villages}

    @view_config(route_name='settings_organization_club_new', renderer='settings/organization/new_club.mak', permission='settings_organization')
    def settings_organization_club_new(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        tmp_club = {
            'name':'',
            'short_name':'',
            'leader_id':'',
            'subunit_id':0,
            'club_code':'',
        }

        if self.request.method == 'POST':
            tmp_club['name'] = self.request.POST.get('name').strip()
            tmp_club['short_name'] = self.request.POST.get('short_name').strip()
            #tmp_club['leader_id'] = self.request.POST.get('leader_id').strip()
            tmp_club['leader_id'] = 0
            tmp_club['subunit_id'] = self.request.POST.get('subunit_id').strip()
            tmp_club['club_code'] = self.request.POST.get('club_code').strip()
            if tmp_club['name']:
                club = Club()
                club.name = tmp_club['name']
                club.short_name = tmp_club['short_name']
                club.leader_id = tmp_club['leader_id']
                club.subunit_id = tmp_club['subunit_id']
                club.club_code = tmp_club['club_code']
                DBSession.add(club)
                DBSession.flush()
                userAudit = UserAudit(self.request.user.id)
                userAudit.model = 'Club'
                userAudit.model_id = club.id
                userAudit.action = 'Create'
                userAudit.revision = club.metadata_revision
                DBSession.add(userAudit)
                DBSession.flush()
                self.request.session.flash(_(u"Club created."), 'success')
                return HTTPFound(location='/settings/organization/')
            else:
                self.request.session.flash(_(u"Please provide club name."), 'error')

        subunits = DBSession.query(SubUnit).all()
        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/organization/', 'text':_('Organization')})
        self.request.bread.append({'url':'/settings/organization/club_new/', 'text':_('New club')})
        return {'club':tmp_club, 'subunits':subunits}

    @view_config(route_name='settings_organization_club_edit', renderer='settings/organization/edit_club.mak', permission='settings_organization')
    def settings_organization_club_edit(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        tmp_club = {
            'name':'',
            'short_name':'',
            'leader_id':'',
            'subunit_id':0,
            'club_code':'',
        }

        club_id = self.request.matchdict['club_id']

        club = DBSession.query(Club).filter(Club.id==club_id).first()

        if club.id:
            tmp_club = {
                'name':club.name,
                'short_name':club.short_name,
                'leader_id':club.leader_id,
                'subunit_id':club.subunit_id,
                'club_code':club.club_code
            }

        if self.request.method == 'POST':
            tmp_club['name'] = self.request.POST.get('name').strip()
            tmp_club['short_name'] = self.request.POST.get('short_name').strip()
            #tmp_club['leader_id'] = self.request.POST.get('leader_id').strip()
            tmp_club['leader_id'] = 0
            tmp_club['subunit_id'] = self.request.POST.get('subunit_id').strip()
            tmp_club['club_code'] = self.request.POST.get('club_code').strip()
            if tmp_club['name']:
                club.name = tmp_club['name']
                club.short_name = tmp_club['short_name']
                club.leader_id = tmp_club['leader_id']
                club.subunit_id = tmp_club['subunit_id']
                club.club_code = tmp_club['club_code']
                DBSession.add(club)
                DBSession.flush()
                userAudit = UserAudit(self.request.user.id)
                userAudit.model = 'Club'
                userAudit.model_id = club.id
                userAudit.action = 'Update'
                userAudit.revision = club.metadata_revision
                DBSession.add(userAudit)
                DBSession.flush()
                self.request.session.flash(_(u"Club saved."), 'success')
                return HTTPFound(location='/settings/organization/')
            else:
                self.request.session.flash(_(u"Please provide club name."), 'error')

        subunits = DBSession.query(SubUnit).all()
        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/organization/', 'text':_('Organization')})
        self.request.bread.append({'url':'/settings/organization/club_edit/'+club_id+'/', 'text':_('Edit club')})
        return {'club':tmp_club, 'subunits':subunits}
        
    @view_config(route_name='settings_organization_village_kitchen_new', renderer='settings/organization/new_village_kitchen.mak', permission='settings_organization')
    def settings_organization_village_kitchen_new(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        tmp_village_kitchen = {
            'name':'',
            'short_name':'',
            'leader_id':'',
            'subcamp_id':0,
            'village_ids':[]
        }

        subcamps = DBSession.query(Subcamp).all()
        villages = DBSession.query(Village).all()

        if self.request.method == 'POST':
            tmp_village_kitchen['name'] = self.request.POST.get('name').strip()
            tmp_village_kitchen['short_name'] = self.request.POST.get('short_name').strip()
            #tmp_village_kitchen['leader_id'] = self.request.POST.get('leader_id').strip()
            tmp_village_kitchen['leader_id'] = 0
            tmp_village_kitchen['subcamp_id'] = self.request.POST.get('subcamp_id').strip()
            if tmp_village_kitchen['name']:
                village_kitchen = VillageKitchen()
                village_kitchen.name = tmp_village_kitchen['name']
                village_kitchen.short_name = tmp_village_kitchen['short_name']
                village_kitchen.leader_id = tmp_village_kitchen['leader_id']
                village_kitchen.subcamp_id = tmp_village_kitchen['subcamp_id']
                village_kitchen.villages = DBSession.query(Village).filter(Village.id.in_(self.request.POST.getall('villages'))).all()
                DBSession.add(village_kitchen)
                DBSession.flush()
                userAudit = UserAudit(self.request.user.id)
                userAudit.model = 'VillageKitchen'
                userAudit.model_id = village_kitchen.id
                userAudit.action = 'Create'
                userAudit.revision = village_kitchen.metadata_revision
                DBSession.add(userAudit)
                DBSession.flush()
                self.request.session.flash(_(u"Village kitchen created."), 'success')
                return HTTPFound(location='/settings/organization/')
            else:
                self.request.session.flash(_(u"Please provide village_kitchen name."), 'error')

        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/organization/', 'text':_('Organization')})
        self.request.bread.append({'url':'/settings/organization/village_kitchen_new/', 'text':_('New village_kitchen')})
        return {'village_kitchen':tmp_village_kitchen, 'subcamps':subcamps, 'villages':villages}

    @view_config(route_name='settings_organization_village_kitchen_edit', renderer='settings/organization/edit_village_kitchen.mak', permission='settings_organization')
    def settings_organization_village_kitchen_edit(self):
        if self.request.redirect_forbidden:
            return HTTPFound(location='/forbidden/')
        elif userhelpers.checkUserPasswordChangeNeed(self.request):
            return HTTPFound(location='/settings/me/edit/')
        _ = self.request.translate

        tmp_village_kitchen = {
            'name':'',
            'short_name':'',
            'leader_id':'',
            'subcamp_id':0,
            'village_ids':[]
        }

        village_kitchen_id = self.request.matchdict['village_kitchen_id']

        village_kitchen = DBSession.query(VillageKitchen).filter(VillageKitchen.id==village_kitchen_id).first()

        subcamps = DBSession.query(Subcamp).all()
        villages = DBSession.query(Village).all()

        if village_kitchen.id:
            village_ids = []
            if len(village_kitchen.villages)>0:
                for village in village_kitchen.villages:
                    village_ids.append(village.id)
            
            tmp_village_kitchen = {
                'name':village_kitchen.name,
                'short_name':village_kitchen.short_name,
                'leader_id':village_kitchen.leader_id,
                'subcamp_id':village_kitchen.subcamp_id,
                'village_ids':village_ids
            }

        if self.request.method == 'POST':
            tmp_village_kitchen['name'] = self.request.POST.get('name').strip()
            tmp_village_kitchen['short_name'] = self.request.POST.get('short_name').strip()
            #tmp_village_kitchen['leader_id'] = self.request.POST.get('leader_id').strip()
            tmp_village_kitchen['leader_id'] = 0
            tmp_village_kitchen['subcamp_id'] = self.request.POST.get('subcamp_id').strip()
            if tmp_village_kitchen['name']:
                village_kitchen.name = tmp_village_kitchen['name']
                village_kitchen.short_name = tmp_village_kitchen['short_name']
                village_kitchen.leader_id = tmp_village_kitchen['leader_id']
                village_kitchen.subcamp_id = tmp_village_kitchen['subcamp_id']
                village_kitchen.villages = DBSession.query(Village).filter(Village.id.in_(self.request.POST.getall('villages'))).all()
                DBSession.add(village_kitchen)
                DBSession.flush()
                userAudit = UserAudit(self.request.user.id)
                userAudit.model = 'VillageKitchen'
                userAudit.model_id = village_kitchen.id
                userAudit.action = 'Update'
                userAudit.revision = village_kitchen.metadata_revision
                DBSession.add(userAudit)
                DBSession.flush()
                self.request.session.flash(_(u"Village kitchen saved."), 'success')
                return HTTPFound(location='/settings/organization/')
            else:
                self.request.session.flash(_(u"Please provide village_kitchen name."), 'error')


        self.request.bread.append({'url':'/settings/', 'text':_('Settings')})
        self.request.bread.append({'url':'/settings/organization/', 'text':_('Organization')})
        self.request.bread.append({'url':'/settings/organization/village_kitchen_edit/'+village_kitchen_id+'/', 'text':_('Edit village_kitchen')})
        return {'village_kitchen':tmp_village_kitchen, 'subcamps':subcamps, 'villages':villages}

def includeme(config):
    config.add_route('settings_organization', '/settings/organization/')
    config.add_route('settings_organization_subcamp_new', '/settings/organization/subcamp_new/')
    config.add_route('settings_organization_subcamp_edit', '/settings/organization/subcamp_edit/{subcamp_id}/')
    config.add_route('settings_organization_village_new', '/settings/organization/village_new/')
    config.add_route('settings_organization_village_edit', '/settings/organization/village_edit/{village_id}/')
    config.add_route('settings_organization_subunit_new', '/settings/organization/subunit_new/')
    config.add_route('settings_organization_subunit_edit', '/settings/organization/subunit_edit/{subunit_id}/')
    config.add_route('settings_organization_club_new', '/settings/organization/club_new/')
    config.add_route('settings_organization_club_edit', '/settings/organization/club_edit/{club_id}/')
    config.add_route('settings_organization_village_kitchen_new', '/settings/organization/village_kitchen_new/')
    config.add_route('settings_organization_village_kitchen_edit', '/settings/organization/village_kitchen_edit/{village_kitchen_id}/')
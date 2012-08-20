<%
import leirirekkari.helpers.helpers as helpers

from leirirekkari.models.dbsession import (
    DBSession
    )

from leirirekkari.models.organization import (
    Subcamp, Village, SubUnit, Club, VillageKitchen
    )
clubs_shown = []
%>
<%block name="template_add_styles">
</%block>

<%block name="template_add_js">
</%block>

<%block name="template_add_afterbody">

</%block>

<%inherit file="leirirekkari:templates/base.mak"/>
<div id="main_headline" class="twelve columns">
    <h1>${_(u"Organization")}</h1>
</div>
<div id="content_container" class="twelve columns">
    <div id="content" class="row">
        <div class="ten columns">
            <div id="organization_tree">
                <table>
                    <thead>
                        <tr>
                            <th colspan="4">${_('Name')}</th>
                            <th>${_('Leader')}</th>
                            <th>${_('Tools')}</th>
                        </tr>
                    </thead>
                    <tbody>
                    % for subcamp in subcamps:
                        <tr>
                            <td colspan="4">${helpers.decodeString(subcamp.name)}</td>
                            <td></td>
                            <td><a href="/settings/organization/subcamp_edit/${subcamp.id}/">${_('Edit')}</a></td>
                        </tr>
                        <%
                        villages = DBSession.query(Village).filter(Village.subcamp_id==subcamp.id).all()
                        %>
                        % if len(villages) > 0:
                            % for village in villages:
                                <tr>
                                    <td>&nbsp;</td>
                                    <td colspan="3">${helpers.decodeString(village.name)}</td>
                                    <td></td>
                                    <td><a href="/settings/organization/village_edit/${village.id}/">${_('Edit')}</a></td>
                                </tr>
                                <%
                                subunits = DBSession.query(SubUnit).filter(SubUnit.village_id==village.id).all()
                                %>
                                % if len(subunits) > 0:
                                    % for subunit in subunits:
                                        <tr>
                                            <td>&nbsp;</td>
                                            <td>&nbsp;</td>
                                            <td colspan="2">${helpers.decodeString(subunit.name)}</td>
                                            <td></td>
                                            <td><a href="/settings/organization/subunit_edit/${subunit.id}/">${_('Edit')}</a></td>
                                        </tr>
                                        <%
                                        clubs = DBSession.query(Club).filter(Club.subunit_id==subunit.id).all()
                                        %>
                                        % if len(clubs) > 0:
                                        % for club in clubs:
                                            <% 
                                            clubs_shown.append(club.id)
                                            %>
                                            <tr>
                                                <td>&nbsp;</td>
                                                <td>&nbsp;</td>
                                                <td>&nbsp;</td>
                                                <td>${helpers.decodeString(club.name)}</td>
                                                <td></td>
                                                <td><a href="/settings/organization/club_edit/${club.id}/">${_('Edit')}</a></td>
                                            </tr>
                                        % endfor
                                    % endif
                                % endfor
                            % endif
                        % endfor
                    % endif
                % endfor
                </tbody>
                </table>
                <h4>${_('Unassigned clubs')}</h4>
                <%
                unassigned_clubs = DBSession.query(Club).filter(~Club.id.in_(clubs_shown)).all()
                %>
                % if len(unassigned_clubs) > 0:
                
                <table>
                    <thead>
                        <tr>
                            <th>${_('Name')}</th>
                            <th>${_('Leader')}</th>
                            <th>${_('Tools')}</th>
                        </tr>
                    </thead>
                    <tbody>
                        % for unassigned_club in unassigned_clubs:
                        <tr>
                            <td>${helpers.decodeString(unassigned_club.name)}</td>
                            <td></td>
                            <td><a href="/settings/organization/club_edit/${unassigned_club.id}/">${_('Edit')}</a></td>
                        </tr>
                        % endfor
                    </tbody>
                </table>
                % endif
                <h4>${_('Village kitchens')}</h4>
                <div id="village_kitchens">
                    <table>
                        <thead>
                            <tr>
                                <th>${_('Subcamp')}</th>
                                <th>${_('Village kitchen')}</th>
                                <th>${_('Villages')}</th>
                                <th>${_('Tools')}</th>
                            </tr>
                        </thead>
                        <tbody>
                        % for subcamp in subcamps:
                            <%
                            villages_kitchens = DBSession.query(VillageKitchen).filter(VillageKitchen.subcamp_id==subcamp.id).all()
                            %>
                            % if len(villages_kitchens) > 0:
                                % for village_kitchen in villages_kitchens:
                            <tr>
                                <td>${helpers.decodeString(subcamp.name)}</td>
                                <td>${helpers.decodeString(village_kitchen.name)}</td>
                                <td>
                                    % if len(village_kitchen.villages) > 0:
                                        % for village in village_kitchen.villages:
                                            ${helpers.decodeString(village.name)}, 
                                        % endfor
                                        
                                    % endif 
                                </td>
                                <td><a href="/settings/organization/village_kitchen_edit/${village_kitchen.id}/">${_('Edit')}</a></td>
                            </tr>
                                % endfor
                            % endif
                        % endfor
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <div class="two columns">
            <div id="actionsMenu">
            <ul>
                <li><a href="/settings/organization/subcamp_new/">${_(u"Create subcamp")}</a></li>
                <li><a href="/settings/organization/village_new/">${_(u"Create village")}</a></li>
                <li><a href="/settings/organization/village_kitchen_new/">${_(u"Create village kitchen")}</a></li>
                <li><a href="/settings/organization/subunit_new/">${_(u"Create subunit")}</a></li>
                <li><a href="/settings/organization/club_new/">${_(u"Create club")}</a></li>
            </ul>
            </div>
        </div>
    </div>
</div>

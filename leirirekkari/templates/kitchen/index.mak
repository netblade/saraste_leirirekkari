<%
import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.participant as participanthelpers

from time import strftime, mktime

from datetime import datetime

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
        <div class="twelve columns">
            <div id="organization_tree">
                <div>
                    <form method="POST" action="">
                        <label>
                            ${_(u"Select date")}<br>
                            <input type="text" id="date" name="date" class="datepicker" value="${helpers.modDate(days['dates'][0])}" />
                            <input type="Submit" value="${_(u"Refresh")}" />
                        </label>
                    </form>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th rowspan="2" colspan="4">${_('Unit')}</th>
                            % for day in days['dates']:
                            <th colspan="4" style="text-align: center; border-right: 1px solid #000000;">${helpers.getDayString(day)} ${helpers.modDate(day, 'short')}</th>
                            % endfor
                        </tr>
                        <tr>
                            % for day in days['dates']:
                                % for key, eating_time in enumerate(eating_times):
                                    % if key == (len(eating_times)-1):
                                    <th style="border-right: 1px solid #000000;">${eating_times[eating_time]}</th>
                                    % else:
                                    <th>${eating_times[eating_time]}</th>
                                    % endif
                                % endfor
                            % endfor
                        </tr>
                        
                    </thead>
                    <tbody>
                    % for subcamp in subcamps:
                        <tr>
                            <td colspan="4">${helpers.decodeString(subcamp.name)}</td>
                            % for day in days['dates']:
                                % for key, eating_time in enumerate(eating_times):
                                    <%
                                    dt_str = helpers.modDateTime(day, 'short') + ' ' + eating_times[eating_time]
                                    my_dt = helpers.parseFinnishDateFromString(dt_str)
                                    people_count = participanthelpers.getPeoplePresenceCounts(dt=my_dt, subcamp=subcamp.id)
                                    %>
                                    % if key == (len(eating_times)-1):
                                    <td style="border-right: 1px solid #000000;">
                                    % else:
                                    <td>
                                    % endif
                                        <form method="POST" action="/office/report/">
                                            <input type="hidden" name="to_view" value="medical_diets" />
                                            <input type="hidden" name="to_view" value="medical_food_allergies" />
                                            <input type="hidden" name="to_view" value="basic_info" />
                                            <input type="hidden" name="to_view" value="age_group" />
                                            <input type="hidden" name="to_view" value="club" />
                                            <input type="hidden" name="to_view" value="subunit" />
                                            <input type="hidden" name="to_view" value="village" />
                                            <input type="hidden" name="to_view" value="subcamp" />
                                            <input type="hidden" name="to_view" value="kitchen_table" />
                                            <input type="hidden" name="search_subcamp" value="${subcamp.id}" />
                                            <input type="hidden" name="search_datetime" value="${dt_str}" />
                                            <input type="submit" value="${people_count}" />
                                        </form>
                                    </td>
                                % endfor
                            % endfor
                        </tr>
                        <%
                        villages = DBSession.query(Village).filter(Village.subcamp_id==subcamp.id).all()
                        %>
                        % if len(villages) > 0:
                            % for village in villages:
                                <tr>
                                    <td>&nbsp;</td>
                                    <td colspan="3">${helpers.decodeString(village.name)}</td>
                                    % for day in days['dates']:
                                        % for key, eating_time in enumerate(eating_times):
                                            <%
                                            dt_str = helpers.modDateTime(day, 'short') + ' ' + eating_times[eating_time]
                                            my_dt = helpers.parseFinnishDateFromString(dt_str)
                                            people_count = participanthelpers.getPeoplePresenceCounts(dt=my_dt, village=village.id)
                                            %>
                                            % if key == (len(eating_times)-1):
                                            <td style="border-right: 1px solid #000000;">
                                            % else:
                                            <td>
                                            % endif
                                                <form method="POST" action="/office/report/">
                                                    <input type="hidden" name="to_view" value="medical_diets" />
                                                    <input type="hidden" name="to_view" value="medical_food_allergies" />
                                                    <input type="hidden" name="to_view" value="basic_info" />
                                                    <input type="hidden" name="to_view" value="age_group" />
                                                    <input type="hidden" name="to_view" value="club" />
                                                    <input type="hidden" name="to_view" value="subunit" />
                                                    <input type="hidden" name="to_view" value="village" />
                                                    <input type="hidden" name="to_view" value="subcamp" />
                                                    <input type="hidden" name="to_view" value="kitchen_table" />
                                                    <input type="hidden" name="search_village" value="${village.id}" />
                                                    <input type="hidden" name="search_datetime" value="${dt_str}" />
                                                    <input type="submit" value="${people_count}" />
                                                </form>
                                            </td>
                                        % endfor
                                    % endfor
                                </tr>
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
                                            % for day in days['dates']:
                                                % for key, eating_time in enumerate(eating_times):
                                                    <%
                                                    dt_str = helpers.modDateTime(day, 'short') + ' ' + eating_times[eating_time]
                                                    my_dt = helpers.parseFinnishDateFromString(dt_str)
                                                    people_count = participanthelpers.getPeoplePresenceCounts(dt=my_dt, subunit=subunit.id)
                                                    %>
                                                    % if key == (len(eating_times)-1):
                                                    <td style="border-right: 1px solid #000000;">
                                                    % else:
                                                    <td>
                                                    % endif
                                                        <form method="POST" action="/office/report/">
                                                            <input type="hidden" name="to_view" value="medical_diets" />
                                                            <input type="hidden" name="to_view" value="medical_food_allergies" />
                                                            <input type="hidden" name="to_view" value="basic_info" />
                                                            <input type="hidden" name="to_view" value="age_group" />
                                                            <input type="hidden" name="to_view" value="club" />
                                                            <input type="hidden" name="to_view" value="subunit" />
                                                            <input type="hidden" name="to_view" value="village" />
                                                            <input type="hidden" name="to_view" value="subcamp" />
                                                            <input type="hidden" name="to_view" value="kitchen_table" />
                                                            <input type="hidden" name="search_subunit" value="${subunit.id}" />
                                                            <input type="hidden" name="search_datetime" value="${dt_str}" />
                                                            <input type="submit" value="${people_count}" />
                                                        </form>
                                                    </td>
                                                % endfor
                                            % endfor
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
                                                % for day in days['dates']:
                                                    % for key, eating_time in enumerate(eating_times):
                                                        <%
                                                        dt_str = helpers.modDateTime(day, 'short') + ' ' + eating_times[eating_time]
                                                        my_dt = helpers.parseFinnishDateFromString(dt_str)
                                                        people_count = participanthelpers.getPeoplePresenceCounts(dt=my_dt, club=club.id)
                                                        %>
                                                        % if key == (len(eating_times)-1):
                                                        <td style="border-right: 1px solid #000000;">
                                                        % else:
                                                        <td>
                                                        % endif
                                                            <form method="POST" action="/office/report/">
                                                                <input type="hidden" name="to_view" value="medical_diets" />
                                                                <input type="hidden" name="to_view" value="medical_food_allergies" />
                                                                <input type="hidden" name="to_view" value="basic_info" />
                                                                <input type="hidden" name="to_view" value="age_group" />
                                                                <input type="hidden" name="to_view" value="club" />
                                                                <input type="hidden" name="to_view" value="subunit" />
                                                                <input type="hidden" name="to_view" value="village" />
                                                                <input type="hidden" name="to_view" value="subcamp" />
                                                                <input type="hidden" name="to_view" value="kitchen_table" />
                                                                <input type="hidden" name="search_club" value="${club.id}" />
                                                                <input type="hidden" name="search_datetime" value="${dt_str}" />
                                                                <input type="submit" value="${people_count}" />
                                                            </form>
                                                        </td>
                                                    % endfor
                                                % endfor
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
                <br><br>
                <h2>${_(u"Village kitchens")}</h2>
                <table>
                    <thead>
                        <tr>
                            <th colspan="3">${_('Unit')}</th>
                            % for day in days['dates']:
                            <th colspan="4" style="text-align: center; border-right: 1px solid #000000;">${helpers.getDayString(day)} ${helpers.modDate(day, 'short')}</th>
                            % endfor
                        </tr>
                        <tr>
                            <th>${_('Subcamp')}</th>
                            <th>${_('Village kitchen')}</th>
                            <th>${_('Villages')}</th>
                            % for day in days['dates']:
                                % for key, eating_time in enumerate(eating_times):
                                    % if key == (len(eating_times)-1):
                                    <th style="border-right: 1px solid #000000;">${eating_times[eating_time]}</th>
                                    % else:
                                    <th>${eating_times[eating_time]}</th>
                                    % endif
                                % endfor
                            % endfor
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
                            % for day in days['dates']:
                                % for key, eating_time in enumerate(eating_times):
                                    <%
                                    dt_str = helpers.modDateTime(day, 'short') + ' ' + eating_times[eating_time]
                                    my_dt = helpers.parseFinnishDateFromString(dt_str)
                                    people_count = participanthelpers.getPeoplePresenceCounts(dt=my_dt, village_kitchen=village_kitchen.id)
                                    %>
                                    % if key == (len(eating_times)-1):
                                    <td style="border-right: 1px solid #000000;">
                                    % else:
                                    <td>
                                    % endif
                                        <form method="POST" action="/office/report/">
                                            <input type="hidden" name="to_view" value="medical_diets" />
                                            <input type="hidden" name="to_view" value="medical_food_allergies" />
                                            <input type="hidden" name="to_view" value="basic_info" />
                                            <input type="hidden" name="to_view" value="age_group" />
                                            <input type="hidden" name="to_view" value="club" />
                                            <input type="hidden" name="to_view" value="subunit" />
                                            <input type="hidden" name="to_view" value="village" />
                                            <input type="hidden" name="to_view" value="village_kitchen" />
                                            <input type="hidden" name="to_view" value="subcamp" />
                                            <input type="hidden" name="to_view" value="kitchen_table" />
                                            % if len(village_kitchen.villages) > 0:
                                            % for village in village_kitchen.villages:
                                            <input type="hidden" name="search_village" value="${village.id}" />
                                            % endfor
                                            % endif
                                            <input type="hidden" name="search_datetime" value="${dt_str}" />
                                            <input type="submit" value="${people_count}" />
                                        </form>
                                    </td>
                                % endfor
                            % endfor
                        </tr>
                        % endfor
                    % endif
                    % endfor
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

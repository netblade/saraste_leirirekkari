<%
import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.participant as participanthelpers
import leirirekkari.helpers.organization as organizationhelpers

from time import strftime, mktime

from datetime import datetime

from leirirekkari.models.dbsession import (
    DBSession
    )

from leirirekkari.models.organization import (
    Subcamp, Village, SubUnit, Club
    )
clubs_shown = []


all_clubs = organizationhelpers.getClubs()



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
                        <tr>
                            <td colspan="4" style="text-align: right;"><strong>${_(u"TOTAL:")}</strong></td>
                            % for day in days['dates']:
                                % for key, eating_time in enumerate(eating_times):
                                    <%
                                    dt_str = helpers.modDateTime(day, 'short') + ' ' + eating_times[eating_time]
                                    my_dt = helpers.parseFinnishDateFromString(dt_str)
                                    age_groups = participanthelpers.getPeoplePresenceCountsByAgegroup(dt=my_dt)
                                    
                                    total = 0
                                    
                                    for item in age_groups:
                                        total += age_groups[item]
                                    
                                    %>
                                    % if key == (len(eating_times)-1):
                                    <td style="border-right: 1px solid #000000;">
                                    % else:
                                    <td>
                                    % endif
                                        % for item in age_groups:
                                            ${_(u"age_group_"+str(item))}: ${str(age_groups[item])}<br>
                                        % endfor
                                        <form method="POST" action="/office/report/">
                                            <input type="hidden" name="to_view" value="basic_info" />
                                            <input type="hidden" name="to_view" value="age_group" />
                                            <input type="hidden" name="to_view" value="club" />
                                            <input type="hidden" name="to_view" value="subunit" />
                                            <input type="hidden" name="to_view" value="village" />
                                            <input type="hidden" name="to_view" value="subcamp" />
                                            <input type="hidden" name="to_view" value="presences" />
                                            <input type="hidden" name="search_datetime" value="${dt_str}" />
                                            <input type="submit" value="${total}" />
                                        </form>
                                    </td>
                                % endfor
                            % endfor
                        </tr>
                    % for subcamp in subcamps:
                        <tr>
                            <td colspan="4">${helpers.decodeString(subcamp.name)}</td>
                            % for day in days['dates']:
                                % for key, eating_time in enumerate(eating_times):
                                    <%
                                    dt_str = helpers.modDateTime(day, 'short') + ' ' + eating_times[eating_time]
                                    my_dt = helpers.parseFinnishDateFromString(dt_str)
                                    age_groups = participanthelpers.getPeoplePresenceCountsByAgegroup(dt=my_dt, subcamp=subcamp.id)
                                    
                                    total = 0
                                    
                                    for item in age_groups:
                                        total += age_groups[item]
                                    
                                    %>
                                    % if key == (len(eating_times)-1):
                                    <td style="border-right: 1px solid #000000;">
                                    % else:
                                    <td>
                                    % endif
                                        % for item in age_groups:
                                            ${_(u"age_group_"+str(item))}: ${str(age_groups[item])}<br>
                                        % endfor
                                        <form method="POST" action="/office/report/">
                                            <input type="hidden" name="to_view" value="basic_info" />
                                            <input type="hidden" name="to_view" value="age_group" />
                                            <input type="hidden" name="to_view" value="club" />
                                            <input type="hidden" name="to_view" value="subunit" />
                                            <input type="hidden" name="to_view" value="village" />
                                            <input type="hidden" name="to_view" value="subcamp" />
                                            <input type="hidden" name="to_view" value="presences" />
                                            <input type="hidden" name="search_subcamp" value="${subcamp.id}" />
                                            <input type="hidden" name="search_datetime" value="${dt_str}" />
                                            <input type="submit" value="${total}" />
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
                                            age_groups = participanthelpers.getPeoplePresenceCountsByAgegroup(dt=my_dt, village=village.id)

                                            total = 0

                                            for item in age_groups:
                                                total += age_groups[item]

                                            %>
                                            % if key == (len(eating_times)-1):
                                            <td style="border-right: 1px solid #000000;">
                                            % else:
                                            <td>
                                            % endif
                                                % for item in age_groups:
                                                    ${_(u"age_group_"+str(item))}: ${str(age_groups[item])}<br>
                                                % endfor
                                                <form method="POST" action="/office/report/">
                                                    <input type="hidden" name="to_view" value="basic_info" />
                                                    <input type="hidden" name="to_view" value="age_group" />
                                                    <input type="hidden" name="to_view" value="club" />
                                                    <input type="hidden" name="to_view" value="subunit" />
                                                    <input type="hidden" name="to_view" value="village" />
                                                    <input type="hidden" name="to_view" value="subcamp" />
                                                    <input type="hidden" name="to_view" value="presences" />
                                                    <input type="hidden" name="search_village" value="${village.id}" />
                                                    <input type="hidden" name="search_datetime" value="${dt_str}" />
                                                    <input type="submit" value="${total}" />
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
                                                    age_groups = participanthelpers.getPeoplePresenceCountsByAgegroup(dt=my_dt, subunit=subunit.id)

                                                    total = 0

                                                    for item in age_groups:
                                                        total += age_groups[item]

                                                    %>
                                                    % if key == (len(eating_times)-1):
                                                    <td style="border-right: 1px solid #000000;">
                                                    % else:
                                                    <td>
                                                    % endif
                                                        % for item in age_groups:
                                                            ${_(u"age_group_"+str(item))}: ${str(age_groups[item])}<br>
                                                        % endfor
                                                        <form method="POST" action="/office/report/">
                                                            <input type="hidden" name="to_view" value="basic_info" />
                                                            <input type="hidden" name="to_view" value="age_group" />
                                                            <input type="hidden" name="to_view" value="club" />
                                                            <input type="hidden" name="to_view" value="subunit" />
                                                            <input type="hidden" name="to_view" value="village" />
                                                            <input type="hidden" name="to_view" value="subcamp" />
                                                            <input type="hidden" name="to_view" value="presences" />
                                                            <input type="hidden" name="search_subunit" value="${subunit.id}" />
                                                            <input type="hidden" name="search_datetime" value="${dt_str}" />
                                                            <input type="submit" value="${total}" />
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
                                                        age_groups = participanthelpers.getPeoplePresenceCountsByAgegroup(dt=my_dt, club=club.id)

                                                        total = 0

                                                        for item in age_groups:
                                                            total += age_groups[item]

                                                        %>
                                                        % if key == (len(eating_times)-1):
                                                        <td style="border-right: 1px solid #000000;">
                                                        % else:
                                                        <td>
                                                        % endif
                                                            % for item in age_groups:
                                                                ${_(u"age_group_"+str(item))}: ${str(age_groups[item])}<br>
                                                            % endfor
                                                            <form method="POST" action="/office/report/">
                                                                <input type="hidden" name="to_view" value="basic_info" />
                                                                <input type="hidden" name="to_view" value="age_group" />
                                                                <input type="hidden" name="to_view" value="club" />
                                                                <input type="hidden" name="to_view" value="subunit" />
                                                                <input type="hidden" name="to_view" value="village" />
                                                                <input type="hidden" name="to_view" value="subcamp" />
                                                                <input type="hidden" name="to_view" value="presences" />
                                                                <input type="hidden" name="search_club" value="${club.id}" />
                                                                <input type="hidden" name="search_datetime" value="${dt_str}" />
                                                                <input type="submit" value="${total}" />
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
            </div>
        </div>
        <div class="two columns">
            <div id="actionsMenu">
            <ul>
                <li><a href="/office/presences/">${_(u"All")}</a></li>
                <li><a href="/office/presences/clubs/">${_(u"Clubs")}</a></li>
            </ul>
            </div>
        </div>
    </div>
</div>

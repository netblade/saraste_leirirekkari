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
                <h4>${_('Clubs')}</h4>
                % if len(all_clubs) > 0:
                <table>
                    <thead>
                        <tr>
                            <th rowspan="2">${_('Unit')}</th>
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
                        % for club in all_clubs:
                        <tr>
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
                                            <input type="hidden" name="search_subcamp" value="${club.id}" />
                                            <input type="hidden" name="search_datetime" value="${dt_str}" />
                                            <input type="submit" value="${total}" />
                                        </form>
                                    </td>
                                % endfor
                            % endfor
                        </tr>
                        % endfor
                    </tbody>
                </table>
                % endif
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

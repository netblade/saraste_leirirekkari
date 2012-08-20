<%
import pyramid.security as security

import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.organization as organizationhelpers
import leirirekkari.helpers.status as statushelpers

%>
<%block name="template_add_styles">
</%block>

<%block name="template_add_js">
</%block>

<%block name="template_add_afterbody">

</%block>

<%inherit file="leirirekkari:templates/base.mak"/>

<div id="main_headline" class="twelve columns">
    <h1>${_(u"Participant")} ${helpers.decodeString(participant.firstname)} ${helpers.decodeString(participant.lastname)}</h1>
</div>
<div id="content_container" class="twelve columns">
    <div id="content" class="row">
        <div class="ten columns">
            <h2>${_(u"Basic info")}</h2>
            <div class="row">
                <div class="six columns">
                    <strong>${_(u"First name")}</strong><br />
                    ${helpers.decodeString(participant.firstname)}
                    <br /><br />
                    <strong>${_(u"Last name")}</strong><br />
                    ${helpers.decodeString(participant.lastname)}
                    <br /><br />
                    <strong>${_(u"Nickname")}</strong><br />
                    ${helpers.decodeString(participant.nickname)}
                    <br /><br />
                    <strong>${_(u"Birthdate")}</strong><br />
                    ${helpers.modDateTime(participant.birthdate, 'short')}
                    <br /><br />
                    <strong>${_(u"Designation")}</strong><br />
                    ${helpers.decodeString(participant.title)}
                    <strong>${_(u"Agegroup")}</strong><br />
                    % if participant.age_group == 1:
                        ${_(u"Child")}                
                    % elif participant.age_group == 2:
                        ${_(u"Cub")}                 
                    % elif participant.age_group == 3:
                        ${_(u"Adventurer")}          
                    % elif participant.age_group == 4:
                        ${_(u"Exlorer")}             
                    % elif participant.age_group == 5:
                        ${_(u"Exlorer")}             
                    % elif participant.age_group == 6:
                        ${_(u"Rover")}               
                    % elif participant.age_group == 7:
                        ${_(u"Adult")}
                    % else:
                        ${_(u"Unknown")}
                    % endif
                    <br /><br />
                    <strong>${_(u"Member number")}</strong><br />
                    ${helpers.decodeString(participant.member_no)}
                    <br /><br />
                    <strong>${_(u"Sex")}</strong><br />
                    % if participant.sex == 10:
                        ${_(u"Men")}
                    % elif participant.sex == 20:
                        ${_(u"Female")}
                    % else:
                        ${_(u"Unknown")}
                    % endif
                    <br /><br />
                    <strong>${_(u"Club")}</strong><br />
                    <a href="/office/list/?club=${participant.club_id}">${helpers.decodeString(organizationhelpers.getClubName(participant.club_id))}</a>
                    <br /><br />
                    <strong>${_(u"Subunit")}</strong><br />
                    <a href="/office/list/?subunit=${participant.subunit_id}">${helpers.decodeString(organizationhelpers.getSubUnitName(participant.subunit_id))}</a>
                    <br /><br />
                    <strong>${_(u"Village")}</strong><br />
                    <a href="/office/list/?village=${participant.village_id}">${helpers.decodeString(organizationhelpers.getVillageName(participant.village_id))}</a>
                    <br /><br />
                    <strong>${_(u"Subcamp")}</strong><br />
                    <a href="/office/list/?subcamp=${participant.subcamp_id}">${helpers.decodeString(organizationhelpers.getSubcampName(participant.subcamp_id))}</a>
                </div>
                <div class="six columns">
                    <%
                    participant.getParticipantStatus()
                    %>
                    <div id="participant_current_status">
                    % if participant.status == None:
                        <strong>${_(u"Current status")}</strong>: ${_(u"Unknown")}
                        <% participant_status_id = 0 %>
                    % else:
                        <% 
                        participant_status_id = participant.status.status_id
                        %>
                        <strong>${_(u"Current status")}</strong>: ${_(u"Participant status: "+str(participant.status.status_id))}
                        % if participant.status.expected_next_change != None:
                        <br />
                        <strong>${_(u"Expected next change")}</strong>: ${helpers.modDateTime(participant.status.expected_next_change, 'shortwithtime')}
                        % endif
                        % if participant.status.description != None:
                        <br />
                        <strong>${_(u"Description")}</strong>: <br />
                        ${helpers.literal(helpers.convertLineBreaks(helpers.decodeString(participant.status.description)))}
                        % endif
                        
                    % endif
                    </div>
                    <hr />
                    <div id="participant_status_changer">
                        <strong>${_(u"Set new status")}</strong><br />
                        <form method="post" action="">
                        <select name="participant_new_status_id">
                            % for status_key in sorted(statushelpers.status_key_list.iterkeys()):
                                % if participant_status_id == status_key:
                                    <option selected="selected" value="${status_key}">${_("Participant status: "+str(status_key))}</option>
                                % else:
                                    <option value="${status_key}">${_("Participant status: "+str(status_key))}</option>
                                % endif
                            % endfor
                        </select><br /><br />
                        <label>${_(u"Expected next change")}<br />
                        <input name="participant_new_status_expected_next_change" class="datetimepicker" />
                        </label><br />
                        <label>${_(u"Description")}<br />
                        <textarea name="participant_new_status_description"></textarea>
                        </label>
                        <br />
                        <input type="submit" value="${_(u"Change status")}">
                    </div>
                </div>
            </div>
            <hr />
            <div class="row">
                % if len(participant.address_data) > 0:
                <div class="six columns">
                    <h2>${_(u"Address")}</h2>
                    ${_(u"Street address")}<br />
                    ${helpers.decodeString(participant.address_data[0].street)}<br /><br />
                    ${_(u"Postal code")}<br />
                    ${helpers.decodeString(participant.address_data[0].postalcode)}<br /><br />
                    ${_(u"City")}<br />
                    ${helpers.decodeString(participant.address_data[0].city)}<br /><br />
                    ${_(u"Country")}<br />
                    ${helpers.decodeString(participant.address_data[0].country)}<br />
                </div>
                % endif
                <div class="six columns">
                    <h2>${_(u"Contact info")}</h2>
                    ${_(u"Email")}<br />
                    ${helpers.decodeString(participant.email)}
                    % if len(participant.phone_data)>0:
                        <br /><br />
                        <strong>${_(u"Phones")}</strong><br />
                        % for phone in participant.phone_data:
                            % if helpers.decodeString(phone.description) != '':
                            ${_(helpers.decodeString(phone.description))}<br />
                            % endif
                            ${helpers.decodeString(phone.phone)}
                            <br /><br />
                        % endfor
                    % endif
                </div>
            </div>
            <hr />
            <div class="row">
                <div class="six columns">
                    <h2>${_(u"Presences")}</h2>
                    % if len(participant.presence_data)>0:
                        <ul id="participant_presences">
                        % for presence in participant.presence_data:
                        
                            <li>${helpers.getDayString(presence.presence_starts, 'short')} ${helpers.modDateTime(presence.presence_starts, 'shortwithtime')} - ${helpers.getDayString(presence.presence_ends, 'short')} ${helpers.modDateTime(presence.presence_ends, 'shortwithtime')}
                                % if presence.title != '':
                                <br /><strong>${helpers.decodeString(presence.title)}</strong>
                                % endif
                                % if presence.description != '':
                                <br />${helpers.decodeString(presence.description)}
                                % endif
                            </li>
                        % endfor
                        </ul>
                    % else:
                        ${_(u"No presences")}<br />
                    % endif
                </div>
            </div>
            <div class="clearer"></div><br /><br /><br />
        </div>
        <div class="two columns">
            % if security.has_permission('office_participant_new', request.context, request):
            <div id="actionsMenu">
            <ul>
                <li><a href="/office/participant/new/">${_(u"Create participant")}</a></li>
                <li><a href="/office/participant/edit/${participant.id}/">${_(u"Edit participant")}</a></li>                
            </ul>
            </div>
            % endif
        </div>
    </div>
</div>

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
    % if not participant.active:
    <h1 style="float: right;">${_("Booking canceled!")}</h1>
    % endif
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
                    <br><br>
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
                    <strong>${_(u"Booking no")}</strong><br />
                    <%
                    booking_no = helpers.decodeString(participant.booking_no).strip('|')
                    booking_no = booking_no.replace('|', ', ')
                    %>
                    ${booking_no}
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
                    <strong>${_(u"Spiritual programme")}</strong><br />
                    % if participant.spiritual == 10:
                        ${_(u"The ecumenical church service")}
                    % elif participant.spiritual == 20:
                        ${_(u"Life stance programme")}
                    % endif
                    <br /><br />
                    <strong>${_(u"Club")}</strong><br />
                    ${helpers.decodeString(organizationhelpers.getClubName(participant.club_id))}
                    <br /><br />
                    <strong>${_(u"Subunit")}</strong><br />
                    ${helpers.decodeString(organizationhelpers.getSubUnitName(participant.subunit_id))}
                    <br /><br />
                    <strong>${_(u"Village")}</strong><br />
                    ${helpers.decodeString(organizationhelpers.getVillageName(participant.village_id))}
                    <br /><br />
                    <strong>${_(u"Subcamp")}</strong><br />
                    ${helpers.decodeString(organizationhelpers.getSubcampName(participant.subcamp_id))}
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
            % if len(participant.next_of_kin_data) > 0:
            <div class="row">
                <h2>${_(u"Next of kin")}</h2>
                <div class="six columns">
                    <strong>${_(u"Primary")}</strong><br /><br />
                    <strong>${_(u"Name")}</strong><br />
                    ${helpers.decodeString(participant.next_of_kin_data[0].primary_name)}
                    <br /><br />
                    <strong>${_(u"Phone")}</strong><br />
                    ${helpers.decodeString(participant.next_of_kin_data[0].primary_phone)}
                    <br /><br />
                    <strong>${_(u"Email")}</strong><br />
                    ${helpers.decodeString(participant.next_of_kin_data[0].primary_email)}
                </div>
                <div class="six columns">
                    <strong>${_(u"Secondary")}</strong><br /><br />
                    <strong>${_(u"Name")}</strong><br />
                    ${helpers.decodeString(participant.next_of_kin_data[0].secondary_name)}
                    <br /><br />
                    <strong>${_(u"Phone")}</strong><br />
                    ${helpers.decodeString(participant.next_of_kin_data[0].secondary_phone)}
                    <br /><br />
                    <strong>${_(u"Email")}</strong><br />
                    ${helpers.decodeString(participant.next_of_kin_data[0].secondary_email)}
                </div>
            </div>
            <hr />
            % endif
            <div class="row">
                <div class="six columns">
                    <h2>${_(u"Language skills")}</h2>
                    % if len(participant.language_data)>0:
                        <ul>
                        % for language in participant.language_data:
                            <li>${helpers.decodeString(language.language)}</li>
                        % endfor
                        </ul>
                    % else:
                        ${_(u"No language skills")}<br />
                    % endif
                </div>
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
            <hr />
            % if security.has_permission('office_participant_view_medical', request.context, request) and participant.medical_data != None:
                <h2>${_(u"Medical info")}</h2>
                <div class="row">
                    <div class="six columns">
                        <strong>${_(u"Medical_diet")}</strong><br />
                        % if len(participant.medical_data.diets) > 0:
                            <ul>
                            % for diet in participant.medical_data.diets:
                                <li>${helpers.decodeString(diet.name)}</li>
                            % endfor
                            </ul>
                        % endif
                        
                        <br /><br />
                        <strong>${_(u"Medical_food_allergy")}</strong><br />
                        % if len(participant.medical_data.food_allergies) > 0:
                            <ul>
                            % for food_allergy in participant.medical_data.food_allergies:
                                <li>${helpers.decodeString(food_allergy.name)}</li>
                            % endfor
                            </ul>
                        % endif
                        <br /><br />
                        <strong>${_(u"Medical_additional_food")}</strong><br />
                        ${helpers.convertLineBreaks(helpers.decodeString(participant.medical_data.additional_food))}
                        <br /><br />
                    </div>

                    <div class="six columns">
                        <strong>${_(u"Medical_drugs_help")}</strong><br />
                        % if participant.medical_data.drugs_help == 10:
                            ${_("Own leader or subunit first aid")}
                        % elif participant.medical_data.drugs_help == 20:
                            ${_("Camphospital")}
                        % else:
                            ${_("Dont need")}
                        % endif
                        <br /><br />
                        <strong>${_(u"Medical_illnesses")}</strong><br />
                        ${helpers.literal(helpers.decodeString(participant.medical_data.illnesses))}
                        <br /><br />
                        <strong>${_(u"Medical_allergies")}</strong><br />
                        % if len(participant.medical_data.allergies) > 0:
                            <ul>
                            % for allergy in participant.medical_data.allergies:
                                <li>${helpers.decodeString(allergy.name)}</li>
                            % endfor
                            </ul>
                        % endif
                        <br />
                        <br /><br />
                        <strong>${_(u"Medical_additional_health")}</strong><br />
                        ${helpers.convertLineBreaks(helpers.decodeString(participant.medical_data.additional_health))}
                        <br /><br />
                        % if participant.medical_data.week_of_pregnancy != '':
                        <strong>${_(u"Pregnancy weeks during camp")}</strong>: ${helpers.decodeString(participant.medical_data.week_of_pregnancy)}
                        %  endif
                    </div>
                </div>
            <hr />
            % endif
            <div class="row">
                <div class="twelve columns">
                    <h2>${_("Metadatas")}</h2>
                    % if len(participant.meta_data) > 0:
                        <table class="tablesorter">
                            <thead>
                                <tr>
                                    <th>${_(u"Title")}</th>
                                    <th>${_(u"Value")}</th>
                                </tr>
                            </thead>
                            <tbody>
                            % for meta_data in participant.meta_data:
                                <tr>
                                    <td valign="top">
                                        ${helpers.decodeString(meta_data.meta_key)}
                                    </td>
                                    <td valign="top">
                                        ${helpers.decodeString(meta_data.meta_value)}
                                    </td>
                                </tr>
                            % endfor
                            </tbody>
                        </table>
                    % else:
                        ${_("No metadatas")}
                    % endif
                </div>
            </div>
            
            <div class="row">
                <div class="six columns">
                    <h2>${_("Metadatas")}</h2>
                    % if participant.wishes != None:
                        % if participant.wishes.activity_1 != None:
                            <strong>${_(u"Wishes, activity 1")}</strong>: ${helpers.decodeString(participant.wishes.activity_1.name)}
                        % else:
                            <strong>${_(u"Wishes, activity 1")}</strong>: --
                        % endif
                        <br /><br />
                        % if participant.wishes.activity_2 != None:
                            <strong>${_(u"Wishes, activity 2")}</strong>: ${helpers.decodeString(participant.wishes.activity_2.name)}
                        % else:
                            <strong>${_(u"Wishes, activity 2")}</strong>: --
                        % endif
                        <br /><br />
                        % if participant.wishes.activity_3 != None:
                            <strong>${_(u"Wishes, activity 3")}</strong>: ${helpers.decodeString(participant.wishes.activity_3.name)}
                        % else:
                            <strong>${_(u"Wishes, activity 3")}</strong>: --
                        % endif
                        <br /><br />
                        % if len(participant.wishes.preliminary_signups) > 0:
                        <strong>${_(u"Preliminary signups")}</strong>
                        <ul>
                            % for preliminary_signup in participant.wishes.preliminary_signups:
                            <li>${helpers.decodeString(preliminary_signup.name)}
                            % endfor
                        </ul>
                        % endif
                    % else:
                        ${_("No wishes")}
                    % endif
                </div>
                <div class="six columns">
                </div>
            </div>
            
            % if security.has_permission('office_participant_view_polku', request.context, request) and len(participant.polku_data) > 0:
            <% 
            polkudata = participant.polku_data[0]
            %>
            <div class="row">
                <div class="six columns">
                    <h2>${_(u"Polku booking")}</h2>
                    <%
                    polkudata_items = vars(polkudata).items()
                    polkudata_items.sort()
                    %>
                    % for key, value in polkudata_items:
                        % if key not in ('_sa_instance_state', 'id', 'metadata_created', 'metadata_modified', 'metadata_creator', 'metadata_modified'):                            
                            <strong>${_(helpers.decodeString(key))}</strong><br />
                            ${helpers.decodeString(value)}
                            <br /><br />
                        % endif
                    % endfor
                </div>
                <%
                polkudata.getPolkuAnswers()
                answers = participant.polku_data[0].polku_answers_data
                %>
                % if len(answers) > 0:
                <div class="six columns">
                    <h2>${_(u"Polku answers")}</h2>
                    % for answer in answers:
                        ${helpers.decodeString(answer.stat_quest)}?<br />
                        ${helpers.decodeString(answer.stat_answer)}
                        <br /><br />
                    % endfor
                </div>
                % endif
            </div>
            <%
            polkudata.getPolkuContact()
            contacts = participant.polku_data[0].polku_contact_data
            %>
            <div class="row">
                <div class="six columns">
                    % if len(contacts) > 0:
                    <h2>${_(u"Polku contact")}</h2>
                    % for contact in contacts:
                        ${helpers.decodeString(contact.descr)}<br />
                        ${helpers.decodeString(contact.country_no)}${helpers.decodeString(contact.area_no)}${helpers.decodeString(contact.local_no)}
                        <br /><br />
                    % endfor
                    % endif
                </div>
            </div>
            % endif
            <div class="clearer"></div><br /><br /><br />
        </div>
        <div class="two columns">
            <div id="actionsMenu">
            <ul>
                <li><a href="/office/participant/edit/${participant.id}/">${_(u"Edit participant")}</a></li>
                <li><a href="/office/participant/view/${participant.id}/payments/">${_(u"View participant payments")}</a></li>
                % if security.has_permission('office_participant_edit', request.context, request):
                % if participant.active:
                <li><a href="/office/participant/view/${participant.id}/cancel/">${_(u"Participant canceled booking")}</a></li>
                % else:
                <li><a href="/office/participant/view/${participant.id}/uncancel/">${_(u"Uncancel booking")}</a></li>
                % endif
                % endif
            </ul>
            </div>
        </div>
    </div>
</div>

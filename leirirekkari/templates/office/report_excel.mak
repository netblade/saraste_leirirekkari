<%
import pyramid.security as security
import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.organization as organizationhelpers
import leirirekkari.helpers.participant as participanthelpers
from leirirekkari.helpers.status import status_key_list, hospital_status_key_list


subcamps = organizationhelpers.getSubcamps()
villages = organizationhelpers.getVillages()
village_kitchens = organizationhelpers.getVillageKitchens()
subunits = organizationhelpers.getSubUnits()
clubs = organizationhelpers.getClubs()

stats = {
    'agegroups':{
        0:0,
        1:0,
        2:0,
        3:0,
        4:0,
        5:0,
        6:0,
        7:0,
    },
    'spiritual':{
        0:0,
        10:0,
        20:0,
    },
    'sex':{
        0:0,
        10:0,
        20:0,
    },
    'total':0
}

kitchen_stats = {
    'allergies': {},
    'food_allergies': {},
    'diets': {},
}

%>
<style>
th, td {
    border: 1px dotted #CCCCCC;
}

th {
    border-bottom: 1px solid #CCCCCC;
}
</style>
<table class="tablesorter">
<thead>
    <tr>
        % if 'show_status' in filter_strings and filter_strings['show_status'] != 'No':
        <th>${_('Is canceled')}</th>
        % endif
        % if 'booking_no' in to_view and to_view['booking_no']:
        <th>${_('Polku booking no')}</th>
        % endif
        % if 'polku_member_id' in to_view and to_view['polku_member_id']:
        <th>${_('Polku member id')}</th>
        % endif
        % if 'basic_info' in to_view and to_view['basic_info']:
        <th>${_('Firstname')}</th>
        <th>${_('Lastname')}</th>
        <th>${_('Nickname')}</th>
        % endif
        % if 'designation_title' in to_view and to_view['designation_title']:
        <th>${_('Designation')}</th>
        % endif
        % if 'address' in to_view and to_view['address']:
        <th>${_('Street')}</th>
        <th>${_('Postalcode')}</th>
        <th>${_('City')}</th>
        % endif
        % if 'phone_and_email' in to_view and to_view['phone_and_email']:
        <th>${_('Phone')}</th>
        <th>${_('Email')}</th>
        % endif
        % if 'languages' in to_view and to_view['languages']:
        <th>${_('Languages')}</th>
        % endif
        % if 'status' in to_view and to_view['status']:
        <th>${_('Status')}</th>
        % endif
        % if 'status_all' in to_view and to_view['status_all']:
        % if 'status' not in to_view or not to_view['status']:
        <th>${_('Status')}</th>
        % endif
        <th>${_('Expected next change')}</th>
        <th>${_('Status description')}</th>
        % endif
        % if 'sex' in to_view and to_view['sex']:
        <th>${_('Sex')}</th>
        % endif
        % if 'age_group' in to_view and to_view['age_group']:
        <th>${_('Agegroup')}</th>
        % endif
        % if 'birthdate' in to_view and to_view['birthdate']:
        <th>${_('Birthdate')}</th>
        % endif
        % if 'age' in to_view and to_view['age']:
        <th>${_('Age')}</th>
        % endif
        % if 'club' in to_view and to_view['club']:
        <th>${_('Club')}</th>
        % endif
        % if 'subcamp' in to_view and to_view['subcamp']:
        <th>${_('Subcamp')}</th>
        % endif
        % if 'village' in to_view and to_view['village']:
        <th>${_('Village')}</th>
        % endif
        % if 'village_kitchen' in to_view and to_view['village_kitchen']:
        <th>${_('Village kitchen')}</th>
        % endif
        % if 'subunit' in to_view and to_view['subunit']:
        <th>${_('Subunit')}</th>
        % endif
        % if 'presence' in to_view and to_view['presence']:
        <th>${_('Presences')}</th>
        % endif
        % if 'spiritual' in to_view and to_view['spiritual']:
        <th>${_('Spiritual')}</th>
        % endif
        % if 'medical_diets' in to_view and to_view['medical_diets']:
        <th>${_('Medical_diet')}</th>
        % endif
        % if 'medical_diets_boolean' in to_view and to_view['medical_diets_boolean']:
        <th>${_('Medical_diet_boolean')}</th>
        % endif
        % if 'medical_food_allergies' in to_view and to_view['medical_food_allergies']:
        <th>${_('Medical_food_allergy')}</th>
        <th>${_('Medical_additional_food')}</th>
        % endif
        % if 'medical_food_allergies_boolean' in to_view and to_view['medical_food_allergies_boolean']:
        <th>${_('Medical_food_allergy_boolean')}</th>
        % endif
        % if 'medical_allergies' in to_view and to_view['medical_allergies']:
        <th>${_('Allergies')}</th>
        % endif
        % if 'medical_allergies_boolean' in to_view and to_view['medical_allergies_boolean']:
        <th>${_('Allergies_boolean')}</th>
        % endif
        % if 'medical_other' in to_view and to_view['medical_other']:
        <th>${_('Medical_drugs_help')}</th>
        <th>${_('Medical_illnesses')}</th>
        <th>${_('Medical_additional_health')}</th>
        <th>${_('Pregnancy weeks during camp')}</th>
        % endif
        % if 'medical_need_help_boolean' in to_view and to_view['medical_need_help_boolean']:
        <th>${_('Medical_drugs_help_boolean')}</th>
        % endif
        % if 'next_of_kin' in to_view and to_view['next_of_kin']:
        <th>${_(u"Next of kin, primary")}</th>
        <th>${_(u"Next of kin, primary phone")}</th>
        <th>${_(u"Next of kin, secondary")}</th>
        <th>${_(u"Next of kin, secondary phone")}</th>
        % endif
        % if 'wishes' in to_view and to_view['wishes']:
        <th>${_(u"Wishes activity 1")}</th>
        <th>${_(u"Wishes activity 2")}</th>
        <th>${_(u"Wishes activity 3")}</th>
        <th>${_(u"Preliminary signups")}</th>
        % endif
        % if 'designation_all' in to_view and to_view['designation_all']:
        <th>${_(u"Job at camp")}</th>
        <th>${_(u"Enlisted by")}</th>
        <th>${_(u"Enlister works as")}</th>
        <th>${_(u"Enlistment table a")}</th>
        <th>${_(u"Enlistment table b1")}</th>
        <th>${_(u"Enlistment table b2")}</th>
        <th>${_(u"Enlistment table b3")}</th>
        % endif
    </tr>
</thead>
<tbody>
    % if len(participants) > 0:
    % for participant in participants:
    <%
        stats['total'] += 1
        stats['agegroups'][participant.age_group] += 1
        stats['sex'][participant.sex] += 1
        stats['spiritual'][participant.spiritual] += 1
        
    %>
    <tr>
        % if 'show_status' in filter_strings and filter_strings['show_status'] != 'No':
        <td>
            % if not participant.active:
                ${_('Canceled')}
            % endif
        </td>
        % endif
        % if 'booking_no' in to_view and to_view['booking_no']:
        <td>${helpers.decodeString(participant.booking_no.strip('|').replace('|', ', '))}</td>
        % endif
        % if 'polku_member_id' in to_view and to_view['polku_member_id']:
        <td>${helpers.decodeString(participant.member_id)}</td>
        % endif
        % if 'basic_info' in to_view and to_view['basic_info']:
        <td><a href="/office/participant/view/${participant.id}/">${helpers.decodeString(participant.firstname)}</a></td>
        <td>${helpers.decodeString(participant.lastname)}</td>
        <td>${helpers.decodeString(participant.nickname)}</td>
        % endif
        % if 'designation_title' in to_view and to_view['designation_title']:
        <td>${helpers.decodeString(participant.title)}</td>
        % endif
        % if 'address' in to_view and to_view['address']:
        <%
        participant.getParticipantAddressData()
        %>
        % if len(participant.address_data) == 0:
        <td></td>
        <td></td>
        <td></td>
        % else:
        <%
        address = participant.address_data[0]
        %>
        <td>${helpers.decodeString(address.street)}</td>
        <td>${helpers.decodeString(address.postalcode)}</td>
        <td>${helpers.decodeString(address.city)}</td>
        % endif
        % endif
        % if 'phone_and_email' in to_view and to_view['phone_and_email']:
        <%
        participant.getParticipantPhoneData()
        %>
        <td>
            % if len(participant.phone_data) == 0:
                % for phone in participant.phone_data:
                    ${helpers.decodeString(phone.phone)}, 
                % endfor
            % endif
        </td>
        <td>${helpers.decodeString(participant.email)}</td>
        % endif
        % if 'languages' in to_view and to_view['languages']:
        <%
        participant.getParticipantLanguageData()
        %>
        <td>
            % if len(participant.language_data) == 0:
                % for language in participant.language_data:
                    ${helpers.decodeString(language.language)}, 
                % endfor
            % endif
        </td>
        % endif
        
        % if 'status' in to_view and to_view['status']:
        <%
        participant.getParticipantStatus()
        %>
            % if participant.status == None:
            <td>
                <%
                status_id = 0
                %>
                ${_("Participant status: 0")}
            </td>
            % else:
            <td>
                ${_("Participant status: "+str(participant.status.status_id))}
            </td>
            % endif
        
        % endif
        % if 'status_all' in to_view and to_view['status_all']:
        <%
        participant.getParticipantStatus()
        %>
            % if participant.status == None:
                % if 'status' not in to_view or not to_view['status']:
            <td>
                <%
                status_id = 0
                %>
                ${_("Participant status: 0")}
            </td>
            % endif
            <td></td>
            <td></td>
            % else:
            % if 'status' not in to_view or not to_view['status']:
            <td>
                ${_("Participant status: "+str(participant.status.status_id))}
            </td>
            % endif
            <td>
                % if participant.status.expected_next_change != None:
                ${helpers.modDateTime(participant.status.expected_next_change, 'shortwithtime')}
                % endif
            </td>
            <td>${helpers.literal(helpers.decodeString(participant.status.description))}</td>
            % endif
        
        % endif
        % if 'sex' in to_view and to_view['sex']:
        <td>
             % if participant.sex == 10:
                    ${_(u"Men")}
                % elif participant.sex == 20:
                    ${_(u"Female")}
                % else:
                    ${_(u"Unknown")}
                % endif
        </td>
        % endif
        % if 'age_group' in to_view and to_view['age_group']:
        <td>${_(u"age_group_"+str(participant.age_group))}</td>
        % endif
        % if 'birthdate' in to_view and to_view['birthdate']:
        <td>${helpers.modDateTime(participant.birthdate, 'short')}</td>
        % endif
        % if 'age' in to_view and to_view['age']:
        <td>${helpers.calculateAgeInYears(participant.birthdate)}</td>
        % endif
        % if 'club' in to_view and to_view['club']:
        <td>${helpers.decodeString(organizationhelpers.getClubName(participant.club_id))}</td>
        % endif
        % if 'subcamp' in to_view and to_view['subcamp']:
        <td>${helpers.decodeString(organizationhelpers.getSubcampName(participant.subcamp_id))}</td>
        % endif
        % if 'village' in to_view and to_view['village']:
        <td>${helpers.decodeString(organizationhelpers.getVillageName(participant.village_id))}</td>
        % endif
        % if 'village_kitchen' in to_view and to_view['village_kitchen']:
        <th>${helpers.decodeString(organizationhelpers.getVillageKitchenNameByVillage(participant.village_id))}</th>
        % endif
        % if 'subunit' in to_view and to_view['subunit']:
        <td>${helpers.decodeString(organizationhelpers.getSubUnitName(participant.subunit_id))}</td>
        % endif
        % if 'presence' in to_view and to_view['presence']:
        <td>
        <%
        participant.getParticipantPresenceData()
        %>
            % if len(participant.presence_data)>0:
                % for presence in participant.presence_data:
                    ${helpers.getDayString(presence.presence_starts, 'short')} ${helpers.modDateTime(presence.presence_starts, 'shortwithtime')} - ${helpers.getDayString(presence.presence_ends, 'short')} ${helpers.modDateTime(presence.presence_ends, 'shortwithtime')}, 
                % endfor
            % endif
        </td>
        % endif
        % if 'spiritual' in to_view and to_view['spiritual']:
        <td>
            % if participant.spiritual == 10:
                ${_(u"The ecumenical church service")}
            % elif participant.spiritual == 20:
                ${_(u"Life stance programme")}
            % endif
        </td>
        % endif
        % if 'medical_diets' in to_view and to_view['medical_diets']:
        <%
        if not participant.medical_data_searched:
            participant.getParticipantMedicalData()
        %>
        % if participant.medical_data == None:
            <td></td>
        % else:
        <td>
            % if len(participant.medical_data.diets) > 0:
                <%
                medical_data = participant.medical_data
                %>
                % for diet in medical_data.diets:
                    <%
                    if diet.name in kitchen_stats['diets']:
                        kitchen_stats['diets'][diet.name] += 1
                    else:
                        kitchen_stats['diets'][diet.name] = 1
                    %>
                    ${helpers.decodeString(diet.name)}, 
                % endfor
            % endif
        </td>
        % endif
        % endif
        % if 'medical_diets_boolean' in to_view and to_view['medical_diets_boolean']:
        <%
        if not participant.medical_data_searched:
            participant.getParticipantMedicalData()
        %>
        % if participant.medical_data == None:
            <td></td>
        % else:
        <td>
            % if len(participant.medical_data.diets) > 0:
                ${_(u"Yes")}
            % else:
                ${_(u"No")}
            % endif
        </td>
        % endif
        % endif
        % if 'medical_food_allergies' in to_view and to_view['medical_food_allergies']:
        <%
        if not participant.medical_data_searched:
            participant.getParticipantMedicalData()
        %>
           % if participant.medical_data == None:
                <td></td>
                <td></td>
            % else:
        <td>
            % if len(participant.medical_data.food_allergies) > 0:
                <%
                medical_data = participant.medical_data
                %>
                % for food_allergy in medical_data.food_allergies:
                    <%
                    if food_allergy.name in kitchen_stats['food_allergies']:
                        kitchen_stats['food_allergies'][food_allergy.name] += 1
                    else:
                        kitchen_stats['food_allergies'][food_allergy.name] = 1
                    %>
                    ${helpers.decodeString(food_allergy.name)}, 
                % endfor
            % endif
        </td>
        <td>
            ${helpers.decodeString(participant.medical_data.additional_food)}
        </td>
        % endif
        % endif
        % if 'medical_food_allergies_boolean' in to_view and to_view['medical_food_allergies_boolean']:
        <%
        if not participant.medical_data_searched:
            participant.getParticipantMedicalData()
        %>
        % if participant.medical_data == None:
            <td></td>
        % else:
        <td>
            % if len(participant.medical_data.food_allergies) > 0:
                ${_(u"Yes")}
            % else:
                ${_(u"No")}
            % endif
        </td>
        % endif
        % endif
        % if 'medical_allergies' in to_view and to_view['medical_allergies']:
        <%
        if not participant.medical_data_searched:
            participant.getParticipantMedicalData()
        %>
        % if participant.medical_data == None:
            <td></td>
        % else:
        <td>
            % if len(participant.medical_data.allergies) > 0:
            <%
            medical_data = participant.medical_data
            %>
                % for allergy in medical_data.allergies:
                    <%
                    if allergy.name in kitchen_stats['allergies']:
                        kitchen_stats['allergies'][allergy.name] += 1
                    else:
                        kitchen_stats['allergies'][allergy.name] = 1
                    %>
                    ${helpers.decodeString(allergy.name)}, 
                % endfor
            % endif
        </td>
        % endif
        % endif
        % if 'medical_allergies_boolean' in to_view and to_view['medical_allergies_boolean']:
        <%
        if not participant.medical_data_searched:
            participant.getParticipantMedicalData()
        %>
        % if participant.medical_data == None:
            <td></td>
        % else:
        <td>
            % if len(participant.medical_data.food_allergies) > 0:
                ${_(u"Yes")}
            % else:
                ${_(u"No")}
            % endif
        </td>
        % endif
        % endif
        % if 'medical_other' in to_view and to_view['medical_other']:
        <%
        if not participant.medical_data_searched:
            participant.getParticipantMedicalData()
        %>
        % if participant.medical_data == None:
            <td></td>
            <td></td>
            <td></td>
            <td></td>
        % else:
        <td>
            % if participant.medical_data.drugs_help == 10:
                ${_("Own leader or subunit first aid")}
            % elif participant.medical_data.drugs_help == 20:
                ${_("Camphospital")}
            % else:
                ${_("Dont need")}
            % endif
        </td>
        <td>
            ${helpers.literal(helpers.decodeString(participant.medical_data.illnesses))}
        </td>
        <td>${helpers.decodeString(participant.medical_data.additional_health)}</td>
        <td>
            % if participant.medical_data.week_of_pregnancy != '':
            ${helpers.decodeString(participant.medical_data.week_of_pregnancy)}
            % endif
        </td>
        % endif
        % endif
        % if 'medical_need_help_boolean' in to_view and to_view['medical_need_help_boolean']:
        <%
        if not participant.medical_data_searched:
            participant.getParticipantMedicalData()
        %>
        % if participant.medical_data == None:
            <td></td>
        % else:
        <td>
            % if participant.medical_data.drugs_help == 10:
                ${_("Own leader or subunit first aid")}
            % elif participant.medical_data.drugs_help == 20:
                ${_("Camphospital")}
            % else:
                ${_("Dont need")}
            % endif
        </td>
        % endif
        % endif
        % if 'next_of_kin' in to_view and to_view['next_of_kin']:
        <%
        participant.getParticipantNextOfKinData()

        %>
        % if len(participant.next_of_kin_data) == 0:
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        % else:
        <td>
            ${helpers.decodeString(participant.next_of_kin_data[0].primary_name)}, 
            ${helpers.decodeString(participant.next_of_kin_data[0].primary_phone)}, 
            ${helpers.decodeString(participant.next_of_kin_data[0].primary_email)}
        </td>
        <td>${helpers.decodeString(participant.next_of_kin_data[0].primary_phone)}</td>
        <td>
            ${helpers.decodeString(participant.next_of_kin_data[0].secondary_name)}, 
            ${helpers.decodeString(participant.next_of_kin_data[0].secondary_phone)}, 
            ${helpers.decodeString(participant.next_of_kin_data[0].secondary_email)}
        </td>
        <td>${helpers.decodeString(participant.next_of_kin_data[0].secondary_phone)}</td>
        % endif
        % endif
        % if 'wishes' in to_view and to_view['wishes']:
        <%
        participant.getParticipantWishes()
        %>
        % if participant.wishes == None:
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        % else:
        <td>${helpers.decodeString(participant.wishes.activity_1.name)}</td>
        <td>${helpers.decodeString(participant.wishes.activity_2.name)}</td>
        <td>${helpers.decodeString(participant.wishes.activity_3.name)}</td>
        <td>
            % if len(participant.wishes.preliminary_signups) > 0:
                % for signup in participant.wishes.preliminary_signups:
                    ${helpers.decodeString(signup.name)}, 
                % endfor
            % endif
        </td>
        % endif
        % endif
        
        
        % if 'designation_all' in to_view and to_view['designation_all']:
        <%
        participant.getParticipantEnlistment()
        %>
        % if participant.enlistment == None:
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        % else:
        <td>${helpers.decodeString(participant.enlistment.job_at_camp)}</td>
        <td>${helpers.decodeString(participant.enlistment.enlisted_by)}</td>
        <td>${helpers.decodeString(participant.enlistment.enlister_works_as)}</td>
        <td>${helpers.decodeString(participanthelpers.getEnlistmentName(participant.enlistment.enlistment_table_a_id))}</td>
        <td>${helpers.decodeString(participanthelpers.getEnlistmentName(participant.enlistment.enlistment_table_b1_id))}</td>
        <td>${helpers.decodeString(participanthelpers.getEnlistmentName(participant.enlistment.enlistment_table_b2_id))}</td>
        <td>${helpers.decodeString(participanthelpers.getEnlistmentName(participant.enlistment.enlistment_table_b3_id))}</td>
        % endif
        % endif
    </tr>
    % endfor
    % endif
</tbody>
</table>
<br><br><br>
% if 'medical_diets' in to_view and to_view['medical_diets']:
<table>
    <tr><td colspan="2"><strong>${_(u"Medical_diet")}</strong></td></tr>
    % for key in kitchen_stats['diets']:
    <tr>
        <td>${helpers.decodeString(key)}</td>
        <td>${str(kitchen_stats['diets'][key])}</td>
    </tr>
    % endfor
</table>
% endif
% if 'medical_food_allergies' in to_view and to_view['medical_food_allergies']:
<table>
    <tr><td colspan="2"><strong>${_(u"Medical_food_allergy")}</strong></td></tr>
    % for key in kitchen_stats['food_allergies']:
    <tr>
        <td>${helpers.decodeString(key)}</td>
        <td>${str(kitchen_stats['food_allergies'][key])}</td>
    </tr>
    % endfor
</table>
% endif
% if 'medical_allergies' in to_view and to_view['medical_allergies']:
<table>
    <tr><td colspan="2"><strong>${_(u"Allergies")}</strong></td></tr>
    % for key in kitchen_stats['allergies']:
    <tr>
        <td>${helpers.decodeString(key)}</td>
        <td>${str(kitchen_stats['allergies'][key])}</td>
    </tr>
    % endfor
</table>
% endif
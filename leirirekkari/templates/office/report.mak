<%
import pyramid.security as security
import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.organization as organizationhelpers
import leirirekkari.helpers.status as statushelpers
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

kitchen_table = {
    'allergies': {},
    'food_allergies': {},
    'diets': {},
    'participants': {}
}

%>

<%block name="template_add_styles">
</%block>

<%block name="template_add_js">
</%block>

<%block name="template_add_afterbody">

</%block>

<%inherit file="leirirekkari:templates/base.mak"/>

<div id="main_headline" class="twelve columns">
    <h1>${_(u"Search participant")}</h1>
</div>
<div id="content_container" class="twelve columns">
    <div id="content" class="row">
        <div class="ten columns">
            <div id="text_search_container_opener">
                <a href="#">${_(u"Show / hide text search")}</a>
                <br />
            </div>
            <div id="text_search_container" style="display: none;">
                <h3>${_(u"Search")}</h3>
                <form method="post" action="/office/participant/search/">
                    <label for="searchstr">${_(u"Search by text")}</label>
                    <input name="searchstr" id="searchstr" type="text" /><br /><br />
                    <input type="submit" value="${_(u"Search")}" style="width: 175px;" />
                </form>
            </div>
            <br><br>
            <a class="button" style="float: right;" href="#" id="open_in_excel">${_(u"Open in excel")}</a>
            <div id="search_container_opener">
                <a href="#">${_(u"Show / hide search values")}</a>
                <br />
            </div>
            <div id="search_container" style="display: none;">
                <form method="post" id="report_form" action="/office/report/">
                    <div style="clear: left; margin-top: 20px;">
                        <h3>${_(u"New report")}</h3>
                        <div class="haku_input_container">
                            <label for="search_agegroup">${_(u"Agegroup")}</label>
                            <select name="search_agegroup" id="search_agegroup" size="7" multiple="multiple">
                                % if 'search_agegroup' in filter_strings and filter_strings['search_agegroup'].count('1') > 0:
                                    <option selected="selected" value="1">${_(u"Childs")}</option>
                                % else:
                                    <option value="1">${_(u"Childs")}</option>
                                % endif
                                % if 'search_agegroup' in filter_strings and filter_strings['search_agegroup'].count('2') > 0:
                                    <option selected="selected" value="2">${_(u"Cubs")}</option>
                                % else:
                                    <option value="2">${_(u"Cubs")}</option>
                                % endif
                                % if 'search_agegroup' in filter_strings and filter_strings['search_agegroup'].count('3') > 0:
                                    <option selected="selected" value="3">${_(u"Adventurers")}</option>
                                % else:
                                    <option value="3">${_(u"Adventurers")}</option>
                                % endif
                                % if 'search_agegroup' in filter_strings and filter_strings['search_agegroup'].count('4') > 0:
                                    <option selected="selected" value="5">${_(u"Exlorers")}</option>
                                % else:
                                    <option value="5">${_(u"Exlorers")}</option>
                                % endif
                                % if 'search_agegroup' in filter_strings and filter_strings['search_agegroup'].count('5') > 0:
                                    <option selected="selected" value="6">${_(u"Rovers")}</option>
                                % else:
                                    <option value="6">${_(u"Rovers")}</option>
                                % endif
                                % if 'search_agegroup' in filter_strings and filter_strings['search_agegroup'].count('6') > 0:
                                    <option selected="selected" value="4">${_(u"Trackers")}</option>
                                % else:
                                    <option value="4">${_(u"Trackers")}</option>
                                % endif
                                % if 'search_agegroup' in filter_strings and filter_strings['search_agegroup'].count('7') > 0:
                                    <option selected="selected" value="7">${_(u"Adults")}</option>
                                % else:
                                    <option value="7">${_(u"Adults")}</option>
                                % endif
                            </select>
                        </div>
                        <div class="haku_input_container">
                            <label for="search_sex">${_(u"Sex")}</label>
                            <select name="search_sex" id="search_sex" size="2" multiple="multiple">
                                % if 'search_sex' in filter_strings and filter_strings['search_sex'].count('10') > 0:
                                    <option selected="selected" value="10">${_(u"Men")} / ${_(u"Boy")}</option>
                                % else:
                                    <option value="10">${_(u"Men")} / ${_(u"Boy")}</option>
                                % endif
                                % if 'search_sex' in filter_strings and filter_strings['search_sex'].count('20') > 0:
                                    <option selected="selected" value="20">${_(u"Female")} / ${_(u"Girl")}</option>
                                % else:
                                    <option value="20">${_(u"Female")} / ${_(u"Girl")}</option>
                                % endif
                            </select>
                        </div>
                        <div class="haku_input_container">
                            <label for="search_spiritual">${_(u"Spiritual programme")}</label>
                            <select name="search_spiritual" id="search_spiritual" size="2" multiple="multiple">
                                % if 'search_spiritual' in filter_strings and filter_strings['search_spiritual'].count('10') > 0:
                                    <option selected="selected" value="10">${_(u"The ecumenical church service")}</option>
                                % else:
                                    <option value="10">${_(u"The ecumenical church service")}</option>
                                % endif
                                % if 'search_spiritual' in filter_strings and filter_strings['search_spiritual'].count('20') > 0:
                                    <option selected="selected" value="20">${_(u"Life stance programme")}</option>
                                % else:
                                    <option value="20">${_(u"Life stance programme")}</option>
                                % endif
                                
                            </select>
                        </div>
                        <div class="haku_input_container">
                            <label for="search_status">${_(u"Status")}</label>
                            <select name="search_status" id="search_status" size="5" multiple="multiple">
                                % for status_key in sorted(statushelpers.status_key_list.iterkeys()):
                                    % if 'search_status' in filter_strings and filter_strings['search_status'].count(str(status_key)) > 0:
                                        <option selected="selected" value="${status_key}">${_("Participant status: "+str(status_key))}</option>
                                    % else:
                                        <option value="${status_key}">${_("Participant status: "+str(status_key))}</option>
                                    % endif
                                % endfor
                            </select>
                        </div>
                        <div class="haku_input_container">
                            <label for="search_canceled">${_(u"Show canceled")}</label>
                            <select name="search_canceled" id="search_canceled">
                                % if 'show_canceled' in filter_strings and filter_strings['show_canceled'] == 'Only':
                                <option value="No">${_("Show canceled: No")}</option>
                                <option selected="selected" value="Only">${_("Show canceled: Only")}</option>
                                <option value="Both">${_("Show canceled: Both")}</option>
                                % elif 'show_canceled' in filter_strings and filter_strings['show_canceled'] == 'Both':
                                <option value="No">${_("Show canceled: No")}</option>
                                <option value="Only">${_("Show canceled: Only")}</option>
                                <option selected="selected" value="Both">${_("Show canceled: Both")}</option>
                                % else:
                                <option selected="selected" value="No">${_("Show canceled: No")}</option>
                                <option value="Only">${_("Show canceled: Only")}</option>
                                <option value="Both">${_("Show canceled: Both")}</option>
                                % endif
                            </select>
                        </div>
                        <div class="haku_input_container">
                            <label for="search_open_payments">${_(u"Show only open payments")}</label>
                            <select name="search_open_payments" id="search_open_payments">
                                % if 'search_open_payments' in filter_strings and filter_strings['search_open_payments'] == 'Only':
                                <option value="No">${_("Show only open payments: No")}</option>
                                <option selected="selected" value="Only">${_("Show only open payments: Only")}</option>
                                % else:
                                <option selected="selected" value="No">${_("Show only open payments: No")}</option>
                                <option value="Only">${_("Show only open payments: Only")}</option>
                                % endif
                            </select>
                        </div>
                        <div class="clearer"><br /><br /></div>
                        <div class="haku_input_container">
                            <label for="search_subcamp">${_(u"Subcamp")}</label>
                            <select name="search_subcamp" id="search_subcamp" size="5" multiple="multiple">
                                % for subcamp in subcamps:
                                    % if 'search_subcamp' in filter_strings and filter_strings['search_subcamp'].count(str(subcamp.id)) > 0:
                                        <option selected="selected" value="${subcamp.id}">${helpers.decodeString(subcamp.name)}</option>
                                    % else:
                                        <option value="${subcamp.id}">${helpers.decodeString(subcamp.name)}</option>
                                    % endif
                                % endfor
                            </select>
                        </div>
                        <div class="haku_input_container">
                            <label for="search_village">${_(u"Village")}</label>
                            <select name="search_village" id="search_village" size="5" multiple="multiple">
                                % for village in villages:
                                    % if 'search_village' in filter_strings and filter_strings['search_village'].count(str(village.id)) > 0:
                                        <option selected="selected" value="${village.id}">${helpers.decodeString(village.name)}</option>
                                    % else:
                                        <option value="${village.id}">${helpers.decodeString(village.name)}</option>
                                    % endif
                                % endfor
                            </select>
                        </div>
                        <div class="haku_input_container">
                            <label for="search_village_kitchen">${_(u"Village kitchen")}</label>
                            <select name="search_village_kitchen" id="search_village_kitchen" size="5" multiple="multiple">
                                % for village_kitchen in village_kitchens:
                                    % if 'search_village_kitchen' in filter_strings and filter_strings['search_village_kitchen'].count(str(village_kitchen.id)) > 0:
                                        <option selected="selected" value="${village_kitchen.id}">${helpers.decodeString(village_kitchen.name)}</option>
                                    % else:
                                        <option value="${village_kitchen.id}">${helpers.decodeString(village_kitchen.name)}</option>
                                    % endif
                                % endfor
                            </select>
                        </div>
                        <div class="haku_input_container">
                            <label for="search_subunit">${_(u"Subunit")}</label>
                            <select name="search_subunit" id="search_subunit" size="5" multiple="multiple">
                                % for subunit in subunits:
                                    % if 'search_subunit' in filter_strings and filter_strings['search_subunit'].count(str(subunit.id)) > 0:
                                        <option selected="selected" value="${subunit.id}">${helpers.decodeString(subunit.name)}</option>
                                    % else:
                                        <option value="${subunit.id}">${helpers.decodeString(subunit.name)}</option>
                                    % endif
                                % endfor
                            </select>
                        </div>
                        <div class="haku_input_container">
                            <label for="search_club">${_(u"Club")}</label>
                            <select name="search_club" id="search_club" size="5" multiple="multiple">
                                % for club in clubs:
                                    % if 'search_club' in filter_strings and filter_strings['search_club'].count(str(club.id)) > 0:
                                        <option selected="selected" value="${club.id}">${helpers.decodeString(club.name)}</option>
                                    % else:
                                        <option value="${club.id}">${helpers.decodeString(club.name)}</option>
                                    % endif
                                % endfor
                            </select>
                        </div>
                        <div class="clearer"></div><br />
                        <div id="raportti_generator_container_date">
                            <label>
                                ${_(u"Presence date and time")}<br />
                                % if 'search_datetime' in filter_strings:
                                <input type="text" name="search_datetime" class="datetimepicker_search" value="${filter_strings['search_datetime']}" />
                                % else:
                                <input type="text" name="search_datetime" class="datetimepicker_search" />
                                % endif
                            </label>
                        </div>
                        <div id="raportti_generator_container_birthdate">
                            <label>
                                ${_(u"Birthdate")}<br />
                                % if 'search_birthdate' in filter_strings:
                                <input type="text" name="search_birthdate" class="datetimepicker_search_birthdate" value="${filter_strings['search_birthdate']}" />
                                % else:
                                <input type="text" name="search_birthdate" class="datetimepicker_search_birthdate" />
                                % endif
                            </label>
                        </div>
                        <hr />
                        <div id="raportti_generator_container">
                            % if 'search_additional' in filter_strings and len(filter_strings['search_additional'])>0:
                                % for search_additional in filter_strings['search_additional']:
                                <div class="additional_search_row">
                                    <div class="additional_search_row_container_field">
                                        <label>${_(u'Search field')}</label>
                                        <select name="additional_search_row_field">
                                            <option value="">--</option>
                                            % for field_key in helpers.additional_search_field_list:
                                            % if field_key in search_additional['field']:
                                                <option selected="selected" value="${field_key}">${_(u"Additional search field: "+field_key)}</option>
                                            % else:
                                                <option value="${field_key}">${_(u"Additional search field: "+field_key)}</option>
                                            % endif
                                            % endfor
                                        </select>
                                    </div>
                                    <div class="additional_search_row_container_type">
                                        <label>${_(u'Search type')}</label>
                                        <select name="additional_search_row_type">
                                            <option value="">--</option>
                                            % for field_key in helpers.additional_search_type_list:
                                            % if field_key in search_additional['type']:
                                                <option selected="selected" value="${field_key}">${_(u"Additional search type: "+field_key)}</option>
                                            % else:
                                                <option value="${field_key}">${_(u"Additional search type: "+field_key)}</option>
                                            % endif
                                            % endfor
                                        </select>
                                    </div>
                                    <div class="additional_search_row_container_value">
                                        <label>${_(u'Search value')}</label>
                                        <input type="text" name="additional_search_row_value" value="${search_additional['value']}" />
                                    </div>
                                    <div class="search_input_container">
                                        <br /><a href="#" class="remove_additional_search_row">${_(u"Remove line")}</a>
                                    </div>
                                    <div class="clearer"></div>
                                </div>
                                % endfor
                            % endif
                        </div>
                        <div class="clearer"></div>
                        <a href="#" id="add_search_row">${_(u"Add search parameter")}</a>
                        <div id="additional_search_null_row_container" style="display: none;">
                            <div class="additional_search_row">
                                <div class="additional_search_row_container_field">
                                    <label>${_(u'Search field')}</label>
                                    <select name="additional_search_row_field">
                                        <option value="">--</option>
                                        % for field_key in helpers.additional_search_field_list:
                                        <option value="${field_key}">${_(u"Additional search field: "+str(field_key))}</option>
                                        % endfor
                                    </select>
                                </div>
                                <div class="additional_search_row_container_type">
                                    <label>${_(u'Search type')}</label>
                                    <select name="additional_search_row_type">
                                        <option value="">--</option>
                                        % for field_key in helpers.additional_search_type_list:
                                        <option value="${field_key}">${_(u"Additional search type: "+str(field_key))}</option>
                                        % endfor
                                    </select>
                                </div>
                                <div class="additional_search_row_container_value">
                                    <label>${_(u'Search value')}</label>
                                    <input type="text" name="additional_search_row_value" />
                                </div>
                                <div class="search_input_container">
                                    <br /><a href="#" class="remove_additional_search_row">${_(u"Remove line")}</a>
                                </div>
                                <div class="clearer"></div>
                            </div>
                        </div>
                        <hr />
                        <div id="raportti_generator_container_to_show">
                            <div id="what_to_view_opener"><a href="#">${_(u"What to view")}</a></div>
                            <div id="what_to_view_content" style="display: none;">
                            % for item in to_view:
                                % if to_view[item]:
                                <label><input name="to_view" type="checkbox" checked="checked" value="${item}" />&nbsp;${_(u"To_view_" + item)}</label>
                                % else:
                                <label><input name="to_view" type="checkbox" value="${item}" />&nbsp;${_(u"To_view_" + item)}</label>
                                % endif
                            % endfor
                            </div>
                        </div>
                    </div>
                    <div class="clearer"></div><br />
                    <input type="submit" value="${_('Create report')}" style="width: 175px;" />
                    <input type="reset" value="${_(u"Reset")}" />
                    <br /><br />
                </div><br>
                <table class="tablesorter">
                <thead>
                    <tr>
                        <th class="{sorter: false}"><input type="checkbox" id="select_all_participants" name="select_all_participants" /></th>
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
                        % if ('medical_diets' in to_view and to_view['medical_diets']) or ('kitchen_table' in to_view and to_view['kitchen_table']):
                        <th>${_('Medical_diet')}</th>
                        % endif
                        % if 'medical_diets_boolean' in to_view and to_view['medical_diets_boolean']:
                        <th>${_('Medical_diet_boolean')}</th>
                        % endif
                        % if ('medical_food_allergies' in to_view and to_view['medical_food_allergies']) or ('kitchen_table' in to_view and to_view['kitchen_table']):
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
                        % if 'payments' in to_view and to_view['payments']:
                        <th>${_(u"Payments total")}</th>
                        <th>${_(u"Paid total")}</th>
                        <th>${_(u"To pay yet")}</th>
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
                        <td><input type="checkbox" class="participant_id_checkbox" value="${participant.id}" name="participant_id_checkbox" id="participant_id_checkbox_${participant.id}" /></td>
                        % if 'show_status' in filter_strings and filter_strings['show_status'] != 'No':
                        <td>
                            % if not participant.active:
                                ${_('Canceled')}
                            % endif
                        </td>
                        % endif
                        % if 'booking_no' in to_view and to_view['booking_no']:
                        <td>
                            % if participant.booking_no != None:
                                ${helpers.decodeString(participant.booking_no.strip('|').replace('|', ', '))}
                            % endif
                        </td>
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
                                    ${helpers.decodeString(phone.phone)}<br>
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
                                    ${helpers.decodeString(language.language)}<br>
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
                            <td>${helpers.literal(helpers.convertLineBreaks(helpers.decodeString(participant.status.description)))}</td>
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
                                    ${helpers.getDayString(presence.presence_starts, 'short')} ${helpers.modDateTime(presence.presence_starts, 'shortwithtime')} - ${helpers.getDayString(presence.presence_ends, 'short')} ${helpers.modDateTime(presence.presence_ends, 'shortwithtime')}<br />
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
                        % if ('medical_diets' in to_view and to_view['medical_diets']) or ('kitchen_table' in to_view and to_view['kitchen_table']):
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
                                    if diet.name not in kitchen_table['diets']:
                                        kitchen_table['diets'][diet.name] = []
                                    kitchen_table['diets'][diet.name].append(participant.id)
                                    if participant.id not in kitchen_table['participants']:
                                        kitchen_table['participants'][participant.id] = participant.firstname + ' ' + participant.lastname
                                        
                                        
                                    if diet.name in kitchen_stats['diets']:
                                        kitchen_stats['diets'][diet.name] += 1
                                    else:
                                        kitchen_stats['diets'][diet.name] = 1
                                    %>
                                    ${helpers.decodeString(diet.name)}<br />
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
                        % if ('medical_food_allergies' in to_view and to_view['medical_food_allergies']) or ('kitchen_table' in to_view and to_view['kitchen_table']):
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
                                    if food_allergy.name not in kitchen_table['food_allergies']:
                                        kitchen_table['food_allergies'][food_allergy.name] = []
                                    kitchen_table['food_allergies'][food_allergy.name].append(participant.id)
                                    if participant.id not in kitchen_table['participants']:
                                        kitchen_table['participants'][participant.id] = participant.firstname + ' ' + participant.lastname

                                    if food_allergy.name in kitchen_stats['food_allergies']:
                                        kitchen_stats['food_allergies'][food_allergy.name] += 1
                                    else:
                                        kitchen_stats['food_allergies'][food_allergy.name] = 1
                                    %>
                                    ${helpers.decodeString(food_allergy.name)}<br />
                                % endfor
                            % endif
                        </td>
                        <td>
                            ${helpers.convertLineBreaks(helpers.decodeString(participant.medical_data.additional_food))}
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
                                    ${helpers.decodeString(allergy.name)}<br>
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
                        <td>${helpers.convertLineBreaks(helpers.decodeString(participant.medical_data.additional_health))}</td>
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
                            ${helpers.decodeString(participant.next_of_kin_data[0].primary_name)}<br>
                            ${helpers.decodeString(participant.next_of_kin_data[0].primary_phone)}<br>
                            ${helpers.decodeString(participant.next_of_kin_data[0].primary_email)}
                        </td>
                        <td>${helpers.decodeString(participant.next_of_kin_data[0].primary_phone)}</td>
                        <td>
                            ${helpers.decodeString(participant.next_of_kin_data[0].secondary_name)}<br>
                            ${helpers.decodeString(participant.next_of_kin_data[0].secondary_phone)}<br>
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
                                    ${helpers.decodeString(signup.name)}<br>
                                % endfor
                            % endif
                        </td>
                        % endif
                        % endif
                        
                        % if 'payments' in to_view and to_view['payments']:
                        <%
                        participant.getParticipantPaymentData()
                        paymentSums = participanthelpers.countPaymentSums(participant)
                        %>
                        <td>${paymentSums['payments_total']} &euro;</td>
                        <td>${paymentSums['paid_total']} &euro;</td>
                        <td>${paymentSums['to_pay_total']} &euro;</td>
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
                <div class="clearer"></div>
                % if ('medical_diets' in to_view and to_view['medical_diets']) or ('medical_food_allergies' in to_view and to_view['medical_food_allergies']) or ('medical_allergies' in to_view and to_view['medical_allergies']):
                <div id="kithen_stats">
                    <div id="kitchen_stats_open_button">
                        <a class="button" href="#">${_("Show medical stats")}</a>
                    </div>
                    <div id="kitchen_report_statistics" style="display: none;">
                        <div id="kitchen_stats_close_button">
                            <a class="button" href="#">${_("Hide stats")}</a>
                        </div>
                        % if 'medical_diets' in to_view and to_view['medical_diets']:
                        <div style="float: left; margin-right: 10px;">
                            <table>
                                <tr><td colspan="2"><strong>${_(u"Medical_diet")}</strong></td></tr>
                                % for key in kitchen_stats['diets']:
                                <tr>
                                    <td>${helpers.decodeString(key)}</td>
                                    <td>${str(kitchen_stats['diets'][key])}</td>
                                </tr>
                                % endfor
                            </table>
                        </div>
                        % endif
                        % if 'medical_food_allergies' in to_view and to_view['medical_food_allergies']:
                        <div style="float: left; margin-right: 10px;">
                            <table>
                                <tr><td colspan="2"><strong>${_(u"Medical_food_allergy")}</strong></td></tr>
                                % for key in kitchen_stats['food_allergies']:
                                <tr>
                                    <td>${helpers.decodeString(key)}</td>
                                    <td>${str(kitchen_stats['food_allergies'][key])}</td>
                                </tr>
                                % endfor
                            </table>
                        </div>
                        % endif
                        % if 'medical_allergies' in to_view and to_view['medical_allergies']:
                        <div style="float: left; margin-right: 10px;">
                            <table>
                                <tr><td colspan="2"><strong>${_(u"Allergies")}</strong></td></tr>
                                % for key in kitchen_stats['allergies']:
                                <tr>
                                    <td>${helpers.decodeString(key)}</td>
                                    <td>${str(kitchen_stats['allergies'][key])}</td>
                                </tr>
                                % endfor
                            </table>
                        </div>
                        % endif
                    </div>
                </div>
                <div class="clearer"></div><br>
                % endif

                % if 'kitchen_table' in to_view and to_view['kitchen_table']:
                <div id="kitchen_table">
                    <div id="kitchen_table_open_button">
                        <a class="button" href="#">${_("Show kitchen table")}</a>
                    </div>
                    <div id="kitchen_report_table" style="display: none;">
                        <div id="kitchen_table_close_button">
                            <a class="button" href="#">${_("Hide stats")}</a>
                        </div>
                        <%
                        cols_count = len(kitchen_table['participants'])
                        %>
                        <table>
                            <thead>
                            <tr>
                                <th></th>
                                % for participant in kitchen_table['participants']:
                                    <%
                                    tmp = list(kitchen_table['participants'][participant])
                                    %>
                                    <th valign="top" style="text-align: center;">
                                        % for tmp2 in tmp:
                                        ${helpers.decodeString(tmp2)}<br />
                                        % endfor
                                    </th>
                                % endfor
                            </tr>
                            </thead>
                            <tbody>
                                % if len(kitchen_table['diets'])>0:
                                <tr>
                                    <td><strong>${_('Diets')}</strong></td>
                                    <td colspan="${cols_count}"></td>
                                </tr>
                                % for diet in kitchen_table['diets']:
                                    <tr>
                                        <td>${helpers.decodeString(diet)}</td>
                                        % for participant in kitchen_table['participants']:
                                        <td>
                                            % if participant in kitchen_table['diets'][diet]:
                                            <a href="#" alt="${helpers.decodeString(kitchen_table['participants'][participant])}" title="${helpers.decodeString(kitchen_table['participants'][participant])}"><strong>X</strong></a>
                                            % endif
                                        </td>
                                        % endfor
                                    </tr>
                                % endfor
                                % endif
                                % if len(kitchen_table['food_allergies'])>0:
                                <tr>
                                    <td><strong>${_('Food allergies')}</strong></td>
                                    <td colspan="${cols_count}"></td>
                                </tr>
                                % for food_allergy in kitchen_table['food_allergies']:
                                    <tr>
                                        <td>${helpers.decodeString(food_allergy)}</td>
                                        % for participant in kitchen_table['participants']:
                                        <td>
                                            % if participant in kitchen_table['food_allergies'][food_allergy]:
                                            <a href="#" alt="${helpers.decodeString(kitchen_table['participants'][participant])}" title="${helpers.decodeString(kitchen_table['participants'][participant])}"><strong>X</strong></a>
                                            % endif
                                        </td>
                                        % endfor
                                    </tr>
                                % endfor
                                % endif
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="clearer"></div><br>
                % endif
                
                
                
                
                <div id="report_mass_tools">
                    <label>
                        ${_(u"Action")}<br>
                        <select name="mass_tools_action" id="mass_tools_action">
                            <option value="">--</option>
                            <option value="status">${_(u"Update status")}</option>
                        </select>
                    </label>
                    <div style="display: none;" id="mass_tools_action_container_status" class="mass_tools_action_container">
                        <fieldset>
                            <legend>${_(u"New status")}</legend>
                            <label>
                                <select name="participant_new_status_id">
                                    % for status_key in sorted(statushelpers.status_key_list.iterkeys()):
                                        % if participant_status_id == status_key:
                                            <option selected="selected" value="${status_key}">${_("Participant status: "+str(status_key))}</option>
                                        % else:
                                            <option value="${status_key}">${_("Participant status: "+str(status_key))}</option>
                                        % endif
                                    % endfor
                                </select>
                            </label>
                            <label>${_(u"Expected next change")}<br />
                            <input name="participant_new_status_expected_next_change" class="datetimepicker" />
                            </label><br />
                            <label>${_(u"Description")}<br />
                            <textarea name="participant_new_status_description"></textarea>
                            </label>
                        </fieldset>
                    </div>
                    <div id="mass_tools_submit" style="display: none;">
                        <br>
                        <input name="mass_tools_submitter" id="mass_tools_submitter" type="submit" value="${_(u"Save")}">
                    </div>
                </div>
            </form>
        </div>
        <div class="two columns">
            <div id="statistics">
                <div id="stats_open_button">
                    <a class="button" href="#">${_("Show stats")}</a>
                </div>
                <div id="report_statistics" style="display: none;">
                    <div id="stats_close_button">
                        <a class="button" href="#">${_("Hide stats")}</a>
                    </div>
                    <table>
                        <tr>
                            <td><strong>${_(u"Total")}</strong></td>
                            <td>${stats['total']}</td>
                        </tr>
                        <tr>
                            <td colspan="2"><strong>${_(u"Age groups")}</strong></td>
                        </tr>
                        % for key, value in enumerate(stats['agegroups']):
                        <tr>
                            <td>${_(u"age_group_"+str(value))}</td>
                            <td>${stats['agegroups'][value]}</td>
                        </tr>
                        % endfor
                        <tr>
                            <td colspan="2"><strong>${_(u"Sex")}</strong></td>
                        </tr>
                        % for key, value in enumerate(stats['sex']):
                        <tr>
                            <td>${_(u"sex_"+str(value))}</td>
                            <td>${stats['sex'][value]}</td>
                        </tr>
                        % endfor
                        <tr>
                            <td colspan="2"><strong>${_(u"Spiritual")}</strong></td>
                        </tr>
                        % for key, value in enumerate(stats['spiritual']):
                        <tr>
                            <td>${_(u"spiritual_"+str(value))}</td>
                            <td>${stats['spiritual'][value]}</td>
                        </tr>
                        % endfor
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

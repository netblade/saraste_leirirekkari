<%
import pyramid.security as security
import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.organization as organizationhelpers
import leirirekkari.helpers.status as statushelpers
subcamps = organizationhelpers.getSubcamps()
villages = organizationhelpers.getVillages()
village_kitchens = organizationhelpers.getVillageKitchens()
subunits = organizationhelpers.getSubUnits()
clubs = organizationhelpers.getClubs()
%>
<%block name="template_add_styles">
</%block>

<%block name="template_add_js">
</%block>

<%block name="template_add_afterbody">

</%block>

<%inherit file="leirirekkari:templates/base.mak"/>

<div id="main_headline" class="twelve columns">
    <h1>${_(u"Office")}</h1>
</div>
<div id="content_container" class="twelve columns">
    <div id="content" class="row">
        <div class="ten columns">
            <div style="float: left; margin-right: 40px; width: 200px;">
                <h3>${_(u"Search")}</h3>
                <form method="post" action="/office/participant/search/">
                    <label for="searchstr">${_(u"Search by text")}</label>
                    <input name="searchstr" id="searchstr" type="text" /><br /><br />
                    <input type="submit" value="${_(u"Search")}" style="width: 175px;" />
                    <p>${_(u"You can search by name, membershipnumber or some other info")}</p>
                </form>
            </div>
            <div style="float: left;">
                <h3>${_(u"Reports")}</h3>
                <ul id="reports_list">
                    
                </ul>
            </div>
            <form method="post" id="report_form" action="/office/report/">
                <div style="clear: left; margin-top: 20px;">
                    <h3>${_(u"New report")}</h3>
                    <div class="haku_input_container">
                        <label for="search_agegroup">${_(u"Agegroup")}</label>
                        <select name="search_agegroup" id="search_agegroup" size="7" multiple="multiple">
                            <option value="1">${_(u"Childs")}</option>
                            <option value="2">${_(u"Cubs")}</option>
                            <option value="3">${_(u"Adventurers")}</option>
                            <option value="4">${_(u"Trackers")}</option>
                            <option value="5">${_(u"Exlorers")}</option>
                            <option value="6">${_(u"Rovers")}</option>
                            <option value="7">${_(u"Adults")}</option>
                        </select>
                    </div>
                    <div class="haku_input_container">
                        <label for="search_sex">${_(u"Sex")}</label>
                        <select name="search_sex" id="search_sex" size="2" multiple="multiple">
                            <option value="10">${_(u"Men")} / ${_(u"Boy")}</option>
                            <option value="20">${_(u"Female")} / ${_(u"Girl")}</option>
                        </select>
                    </div>
                    <div class="haku_input_container">
                        <label for="search_spiritual">${_(u"Spiritual programme")}</label>
                        <select name="search_spiritual" id="search_spiritual" size="2" multiple="multiple">
                            <option value="10">${_(u"The ecumenical church service")}</option>
                            <option value="20">${_(u"Life stance programme")}</option>
                        </select>
                    </div>
                    <div class="haku_input_container">
                        <label for="search_status">${_(u"Status")}</label>
                        <select name="search_status" id="search_status" size="5" multiple="multiple">
                            % for status_key in sorted(statushelpers.status_key_list.iterkeys()):
                                <option value="${status_key}">${_("Participant status: "+str(status_key))}</option>
                            % endfor
                        </select>
                    </div>
                    <div class="haku_input_container">
                        <label for="search_canceled">${_(u"Show canceled")}</label>
                        <select name="search_canceled" id="search_canceled">
                            <option value="No">${_("Show canceled: No")}</option>
                            <option value="Only">${_("Show canceled: Only")}</option>
                            <option value="Both">${_("Show canceled: Both")}</option>
                        </select>
                    </div>
                    <div class="clearer"><br /><br /></div>
                    <div class="haku_input_container">
                        <label for="search_subcamp">${_(u"Subcamp")}</label>
                        <select name="search_subcamp" id="search_subcamp" size="5" multiple="multiple">
                            % for subcamp in subcamps:
                            <option value="${subcamp.id}">${helpers.decodeString(subcamp.name)}</option>
                            % endfor
                        </select>
                    </div>
                    <div class="haku_input_container">
                        <label for="search_village">${_(u"Village")}</label>
                        <select name="search_village" id="search_village" size="5" multiple="multiple">
                            % for village in villages:
                            <option value="${village.id}">${helpers.decodeString(village.name)}</option>
                            % endfor
                        </select>
                    </div>
                    <div class="haku_input_container">
                        <label for="search_village_kitchen">${_(u"Village kitchen")}</label>
                        <select name="search_village_kitchen" id="search_village_kitchen" size="5" multiple="multiple">
                            % for village_kitchen in village_kitchens:
                            <option value="${village_kitchen.id}">${helpers.decodeString(village_kitchen.name)}</option>
                            % endfor
                        </select>
                    </div>
                    <div class="haku_input_container">
                        <label for="search_subunit">${_(u"Subunit")}</label>
                        <select name="search_subunit" id="search_subunit" size="5" multiple="multiple">
                            % for subunit in subunits:
                            <option value="${subunit.id}">${helpers.decodeString(subunit.name)}</option>
                            % endfor
                        </select>
                    </div>
                    <div class="haku_input_container">
                        <label for="search_club">${_(u"Club")}</label>
                        <select name="search_club" id="search_club" size="5" multiple="multiple">
                            % for club in clubs:
                            <option value="${club.id}">${helpers.decodeString(club.name)}</option>
                            % endfor
                        </select>
                    </div>
                    <div class="clearer"></div><br />
                    <div id="raportti_generator_container_date">
                        <label>
                            ${_(u"Presence date and time")}<br />
                            <input type="text" name="search_datetime" class="datetimepicker_search" />
                        </label>
                    </div>
                    <div id="raportti_generator_container_birthdate">
                        <label>
                            ${_(u"Birthdate")}<br />
                            <input type="text" name="search_birthdate" class="datetimepicker_search_birthdate" />
                        </label>
                    </div>
                    <hr />
                    <div id="raportti_generator_container">
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
                    <div class="clearer"></div><br />
                    <input type="submit" value="${_('Create report')}" style="width: 175px;" />&nbsp;&nbsp;<a class="button" href="#" id="open_in_excel">${_(u"Open in excel")}</a>
                    <br /><br /><br /><br /><br />
                </div>
                <div class="clearer"></div>
            </form>
        </div>
        <div class="two columns">
            <div id="actionsMenu">
            <ul>
                <li><a href="/office/participant/new/">${_(u"Create participant")}</a></li>
                <li><a href="/office/presences/">${_(u"Presences")}</a></li>
            </ul>
            </div>
        </div>
    </div>
</div>

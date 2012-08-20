<%
import pyramid.security as security

import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.participant as participanthelpers

%>
<%block name="template_add_styles">
</%block>

<%block name="template_add_js">
</%block>

<%block name="template_add_afterbody">

</%block>

<%inherit file="leirirekkari:templates/base.mak"/>

<div id="main_headline" class="twelve columns">
	<h1>${_(u"Create new participant")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
			<form method="POST" action="">
				<fieldset>
					<legend>${_(u"Basic info")}</legend>
					<div class="row">
						<div class="six columns">
							<label>
								${_(u"First name")}<br />
								<input type="text" name="firstname" value="${helpers.decodeString(participant.firstname)}" />
							</label>
							<label>
								${_(u"Last name")}<br />
								<input type="text" name="lastname" value="${helpers.decodeString(participant.lastname)}" />
							</label>
							<label>
								${_(u"Nickname")}<br />
								<input type="text" name="nickname" value="${helpers.decodeString(participant.nickname)}" />
							</label>
							<label>
								${_(u"Birthdate")}<br />
								<input type="text" class="datepicker" name="birthdate" value="${helpers.decodeString(participant.birthdate)}" />
							</label>
							<label>
								${_(u"Designation")}<br />
								<input type="text" name="title" value="${helpers.decodeString(participant.title)}" />
							</label>
						</div>
						<div class="six columns">
							<label>
								${_(u"Agegroup")}<br />
								<select name="age_group">
								    <option value="0">--</option>
								    % if participant.age_group == '1':
										<option selected="selected" value="1">${_(u"Child")}</option>
									% else:
										<option value="1">${_(u"Child")}</option>
									% endif
									% if participant.age_group == '2':
										<option selected="selected" value="2">${_(u"Cub")}</option>
									% else:
										<option value="2">${_(u"Cub")}</option>
									% endif
									% if participant.age_group == '3':
										<option selected="selected" value="3">${_(u"Adventurer")}</option>
									% else:
										<option value="3">${_(u"Adventurer")}</option>
									% endif
									% if participant.age_group == '4':
										<option selected="selected" value="4">${_(u"Trackers")}</option>
									% else:
										<option value="4">${_(u"Trackers")}</option>
									% endif
									% if participant.age_group == '5':
										<option selected="selected" value="5">${_(u"Exlorer")}</option>
									% else:
										<option value="5">${_(u"Exlorer")}</option>
									% endif
									% if participant.age_group == '6':
										<option selected="selected" value="6">${_(u"Rover")}</option>
									% else:
										<option value="6">${_(u"Rover")}</option>
									% endif
									% if participant.age_group == '7':
										<option selected="selected" value="7">${_(u"Adult")}</option>
									% else:
										<option value="7">${_(u"Adult")}</option>
									% endif
								</select>
							</label>
							<label>
								${_(u"Member number")}<br />
								<input type="text" name="member_no" value="${helpers.decodeString(participant.member_no)}" />
							</label>
							<label>
								${_(u"Sex")}<br />
								<select name="sex">
									<option value="0">--</option>
									% if participant.sex == '10':
										<option selected="selected" value="10">${_(u"Men")}</option>
									% else:
										<option value="10">${_(u"Men")}</option>
									% endif
									% if participant.sex == '20':
										<option selected="selected" value="20">${_(u"Female")}</option>
									% else:
										<option value="20">${_(u"Female")}</option>
									% endif
								</select>
							</label>
							<label>
								${_(u"Spiritual programme")}<br />
								<select name="spiritual">
									<option value="0">--</option>
									% if participant.spiritual == '10':
										<option selected="selected" value="10">${_(u"The ecumenical church service")}</option>
									% else:
										<option value="10">${_(u"The ecumenical church service")}</option>
									% endif
									% if participant.spiritual == '20':
										<option selected="selected" value="20">${_(u"Life stance programme")}</option>
									% else:
										<option value="20">${_(u"Life stance programme")}</option>
									% endif
								</select>
							</label>
							<label>
								${_(u"Club")}<br />
								<select name="club_id">
								    <option value="0">--</option>
									% for club in clubs:
										% if participant.club_id == club.id:
											<option selected="selected" value="${club.id}">${helpers.decodeString(club.name)}</option>
										% else:
											<option value="${club.id}">${helpers.decodeString(club.name)}</option>
										% endif
									% endfor
								</select>
							</label>
							<label>
								${_(u"Subunit")}<br />
								<select name="subunit_id">
								    <option value="0">--</option>
									% for subunit in subunits:
										% if participant.subunit_id == subunit.id:
											<option selected="selected" value="${subunit.id}">${helpers.decodeString(subunit.name)}</option>
										% else:
											<option value="${subunit.id}">${helpers.decodeString(subunit.name)}</option>
										% endif
									% endfor
								</select>
							</label>
						</div>
					</div>
				</fieldset>
				<div class="row">
					<div class="six columns">
						<fieldset>
							<legend>${_(u"Address")}</legend>
							<label>
								${_(u"Street address")}<br />
								<input type="text" name="address_street" value="${helpers.decodeString(participant.address_data[0].street)}" />
							</label>
							<label>
								${_(u"Postal code")}<br />
								<input type="text" name="address_postalcode" value="${helpers.decodeString(participant.address_data[0].postalcode)}" />
							</label>
							<label>
								${_(u"City")}<br />
								<input type="text" name="address_city" value="${helpers.decodeString(participant.address_data[0].city)}" />
							</label>
							<label>
								${_(u"Country")}<br />
								<input type="text" name="address_country" value="${helpers.decodeString(participant.address_data[0].country)}" />
							</label>
						</fieldset>
					</div>
					<div class="six columns">
						<fieldset>
							<legend>${_(u"Phone and email")}</legend>
							<label>
								${_(u"Email")}<br />
								<input type="text" name="email" value="${helpers.decodeString(participant.email)}" />
							</label>
							<div id="phones_container">
							    % if len(participant.phone_data) > 0:
    							    % for phone_data in participant.phone_data:
    							    <div class="clearer"></div>
            							<label>
            								${_(u"Number")}<br />
            								<input class="phone_number" type="text" name="phone_number" value="${helpers.decodeString(phone_data.phone)}" />
            							</label>
            							<label>
            								${_(u"Phone type")}<br />
            								<input class="phone_type" type="text" name="phone_type" value="${helpers.decodeString(phone_data.description)}" />
            							</label>
            							<div class="remove_phone_row_container" style="float:left; margin-left: 10px;">
            								<br /><a href="#" class="remove_phone_row">${_(u"Remove line")}</a>
            							</div>
        							</fieldset>
    							    % endfor
							    % endif
							</div>
							<div id="phone_row_null" style="display: none;">
							    
                                <div class="phone_row">
                                <fieldset>
                                    <div class="clearer"></div>
            							<label>
            								${_(u"Number")}<br />
            								<input class="phone_number" type="text" name="phone_number" value="" />
            							</label>
            							<label>
            								${_(u"Phone type")}<br />
            								<input class="phone_type" type="text" name="phone_type" value="" />
            							</label>
            							<div class="remove_phone_row_container" style="float:left; margin-left: 10px;">
            								<br /><a href="#" class="remove_phone_row">${_(u"Remove line")}</a>
            							</div>
        							</fieldset>
    							</div>
    							<div class="clearer"></div>
							</div>
							<div class="clearer"></div>
							<a href="#" id="add_phone_row">${_(u"Add phone")}</a>
						</fieldset>
					</div>
				</div>
				<div class="row">
					<div class="six columns">
						<fieldset>
							<legend>${_(u"Next of kin, primary")}</legend>
							<label>
								${_(u"Name")}<br />
								<input type="text" name="next_of_kin_0_name" value="${helpers.decodeString(participant.next_of_kin_data[0].primary_name)}" />
							</label>
							<label>
								${_(u"Phone")}<br />
								<input type="text" name="next_of_kin_0_phone" value="${helpers.decodeString(participant.next_of_kin_data[0].primary_phone)}" />
							</label>
							<label>
								${_(u"Email")}<br />
								<input type="text" name="next_of_kin_0_email" value="${helpers.decodeString(participant.next_of_kin_data[0].primary_email)}" />
							</label>
						</fieldset>
					</div>
					<div class="six columns">
						<fieldset>
							<legend>${_(u"Next of kin, secondary")}</legend>
							<label>
								${_(u"Name")}<br />
								<input type="text" name="next_of_kin_1_name" value="${helpers.decodeString(participant.next_of_kin_data[0].secondary_name)}" />
							</label>
							<label>
								${_(u"Phone")}<br />
								<input type="text" name="next_of_kin_1_phone" value="${helpers.decodeString(participant.next_of_kin_data[0].secondary_phone)}" />
							</label>
							<label>
								${_(u"Email")}<br />
								<input type="text" name="next_of_kin_1_email" value="${helpers.decodeString(participant.next_of_kin_data[0].secondary_email)}" />
							</label>
						</fieldset>
					</div>
				</div>
				<div class="row">
					<div class="six columns">
						<fieldset>
							<legend>${_(u"Language skills")}</legend>
							<div id="language_skills_container">
							% if len(participant.language_data) > 0:
							    % for language_data in participant.language_data:
							    <div class="language_skill_row">
                                    <div class="clearer"></div>
        							<label>
        								${_(u"Language")}<br />
        								<input type="text" name="language" value="${helpers.decodeString(language_data.language)}" />
        							</label>
        							<div class="remove_langskill_row_container" style="float:left; margin-left: 10px;">
        								<br /><a href="#" class="remove_langskill_row">${_(u"Remove line")}</a>
        							</div>
    							</div>
							    % endfor
							% endif
							</div>
                            <div id="language_skill_row_null" style="display: none;">
                                <div class="language_skill_row">
                                    <div class="clearer"></div>
        							<label>
        								${_(u"Language")}<br />
        								<input type="text" name="language" value="" />
        							</label>
        							<div class="remove_langskill_row_container" style="float:left; margin-left: 10px;">
        								<br /><a href="#" class="remove_langskill_row">${_(u"Remove line")}</a>
        							</div>
    							</div>
							</div>
							<div class="clearer"></div>
							<a href="#" id="add_language_row">${_(u"Add language")}</a>
						</fieldset>
					</div>
					<div class="six columns">
					    <fieldset>
					        <legend>${_("Presences")}</legend>
					        <div id="presences_container">
					        % if len(participant.presence_data) > 0:
					            % for presence_data in participant.presence_data:
					            <div class="presence_row">
                                    <fieldset>
                                        <legend>${_("Presence")}</legend>
                                        <div class="clearer"></div>
            							<label>
            								${_(u"Starts")}<br />
            								<input class="presence_starts" type="text" name="presence_starts" value="${helpers.decodeString(presence_data.presence_starts)}" />
            							</label>
            							<label>
            								${_(u"Ends")}<br />
            								<input class="presence_ends" type="text" name="presence_ends" value="${helpers.decodeString(presence_data.presence_ends)}" />
            							</label>
            							<div class="remove_presence_row_container" style="float:left; margin-left: 10px;">
            								<br /><a href="#" class="remove_presence_row">${_(u"Remove line")}</a>
            							</div>
            							<div class="clearer"></div>
            							<label style="margin-right: 10px;">
            								${_(u"Title")}<br />
            								<input class="presence_title" type="text" name="presence_title" value="${helpers.decodeString(presence_data.title)}" />
            							</label>
            							<label>
            								${_(u"Description")}<br />
            								<textarea class="presence_description" name="presence_description">${helpers.decodeString(presence_data.description)}</textarea>
            							</label>
        							</fieldset>
    							</div>
    							<div class="clearer"></div>
					            % endfor
					        % endif
							</div>
							<div id="presence_row_null" style="display: none;">
                                <div class="presence_row" id="presence_row_null_row">
                                    <fieldset>
                                        <legend>${_("Presence")}</legend>
                                        <input type="hidden" name="presence_id" value="0" />
                                        <div class="clearer"></div>
            							<label>
            								${_(u"Starts")}<br />
            								<input class="presence_starts_null" type="text" name="presence_starts" value="" />
            							</label>
            							<label>
            								${_(u"Ends")}<br />
            								<input class="presence_ends_null" type="text" name="presence_ends" value="" />
            							</label>
            							<div class="remove_presence_row_container" style="float:left; margin-left: 10px;">
            								<br /><a href="#" class="remove_presence_row">${_(u"Remove line")}</a>
            							</div>
            							<div class="clearer"></div>
            							<label style="margin-right: 10px;">
            								${_(u"Title")}<br />
            								<input class="presence_title" type="text" name="presence_title" value="" />
            							</label>
            							<label>
            								${_(u"Description")}<br />
            								<textarea class="presence_description" name="presence_description"></textarea>
            							</label>
        							</fieldset>
    							</div>
    							<div class="clearer"></div>
							</div>
							<div class="clearer"></div>
							<a href="#" id="add_presence_row">${_(u"Add presence")}</a>
					    </fieldset>
					</div>
				</div>
				<div class="row">
				    <div class="six columns">
                        <fieldset>
                            <legend>${_("Metadatas")}</legend>
                            <div id="metadatas_container">
                            % if len(participant.meta_data) > 0:
                                % for meta_data in participant.meta_data:
                                <div class="metadata_row">
                                    <fieldset>
                                        <legend>${_("Metadata item")}</legend>
                                        <div class="clearer"></div>
                    					<label style="margin-right: 10px;">
                    						${_(u"Title")}<br />
                    						<input class="meta_key" type="text" name="meta_key" value="${helpers.decodeString(meta_data.meta_key)}" />
                    					</label>
                    					<label>
                    						${_(u"Description")}<br />
                    						<textarea class="meta_value" name="meta_value">${helpers.decodeString(meta_data.meta_value)}</textarea>
                    					</label>
                    					<div class="remove_metadata_row_container" style="float:left; margin-left: 10px;">
            								<br /><a href="#" class="remove_metadata_row">${_(u"Remove line")}</a>
            							</div>
                    				</fieldset>
                    			</div>
                    			<div class="clearer"></div>
                                % endfor
                            % endif
                    		</div>
                    		<div id="metadata_row_null" style="display: none;">
                                <div class="metadata_row" id="metadata_row_null_row">
                                    <fieldset>
                                        <legend>${_("Metadata")}</legend>
                                        <div class="remove_metadata_row_container" style="float:right; margin-left: 10px;">
                                            <a href="#" class="remove_metadata_row">${_(u"Remove line")}</a>
            							</div>
                    					<label style="margin-right: 10px;">
                    						${_(u"Key")}<br />
                    						<input class="metadata_title" type="text" name="meta_key" value="" />
                    					</label>
                    					<label>
                    						${_(u"Value")}<br />
                    						<textarea class="metadata_description" name="meta_value"></textarea>
                    					</label>
                    				</fieldset>
                    			</div>
                    			<div class="clearer"></div>
                    		</div>
                    		<div class="clearer"></div>
                    		<a href="#" id="add_metadata_row">${_(u"Add metadata")}</a>
                        </fieldset>
                    </div>
                </div>
				% if security.has_permission('office_participant_view_medical', request.context, request):
				<%
				medical_data = participant.medical_data
				%>
				<fieldset>
					<legend>${_(u"Medical info")}</legend>
					<div class="row">
						<div class="six columns">
						    <strong>${_(u"Medical_diet")}</strong><br />
							<%
							diets = participanthelpers.getAvailableDiets()
							%>
							% if len(diets) > 0:
                                % for diet in diets:
                                    % if diet in medical_data.diets:
                                    <label><input type="checkbox" checked="checked" name="medical_diet" value="${diet.id}" />&nbsp;${helpers.decodeString(diet.name)}</label>
                                    % else:
                                    <label><input type="checkbox" name="medical_diet" value="${diet.id}" />&nbsp;${helpers.decodeString(diet.name)}</label>
                                    % endif
                                % endfor
                            % endif
                            <br />
                            <strong>${_(u"Medical_food_allergy")}</strong><br />
							<%
							food_allergies = participanthelpers.getAvailableFoodAllergies()
							%>
							% if len(food_allergies) > 0:
                                % for food_allergy in food_allergies:
                                    % if food_allergy in medical_data.food_allergies:
                                    <label><input type="checkbox" checked="checked" name="medical_food_allergy" value="${food_allergy.id}" />&nbsp;${helpers.decodeString(food_allergy.name)}</label>
                                    % else:
                                    <label><input type="checkbox" name="medical_food_allergy" value="${food_allergy.id}" />&nbsp;${helpers.decodeString(food_allergy.name)}</label>
                                    % endif
                                % endfor
                            % endif
                            <br />
							<label>
								${_(u"Medical_additional_food")}<br />
								<textarea name="medical_additional_food" class="textarea_small">${helpers.decodeString(medical_data.additional_food)}</textarea>
							</label>
						</div>

						<div class="six columns">
							<label>${_(u"Medical_drugs_help")}</label>
							% if participant.medical_data.drugs_help == 10:
							    <label><input type="radio" name="medical_drugs_help" value="0" />&nbsp;${_("Dont need")}</label>
							    <label><input checked="checked" type="radio" name="medical_drugs_help" value="10" />&nbsp;${_("Own leader or subunit first aid")}</label>
							    <label><input type="radio" name="medical_drugs_help" value="20" />&nbsp;${_("Camphospital")}</label>
							% elif participant.medical_data.drugs_help == 20:
								<label><input type="radio" name="medical_drugs_help" value="0" />&nbsp;${_("Dont need")}</label>
							    <label><input type="radio" name="medical_drugs_help" value="10" />&nbsp;${_("Own leader or subunit first aid")}</label>
							    <label><input checked="checked" type="radio" name="medical_drugs_help" value="20" />&nbsp;${_("Camphospital")}</label>
							% else:
    							<label><input checked="checked" type="radio" name="medical_drugs_help" value="0" />&nbsp;${_("Dont need")}</label>
							    <label><input type="radio" name="medical_drugs_help" value="10" />&nbsp;${_("Own leader or subunit first aid")}</label>
							    <label><input type="radio" name="medical_drugs_help" value="20" />&nbsp;${_("Camphospital")}</label>
						    % endif
								<br />
							<label>
								${_(u"Medical_illnesses")}<br />
								<textarea name="medical_illnesses" class="textarea_small">${helpers.decodeString(medical_data.illnesses)}</textarea>
							</label>
							<strong>${_(u"Medical_allergies")}</strong><br />
							<%
							allergies = participanthelpers.getAvailableAllergies()
							%>
							% if len(allergies) > 0:
                                % for allergy in allergies:
                                    % if allergy in medical_data.allergies:
                                    <label><input type="checkbox" checked="checked" name="medical_allergy" value="${allergy.id}" />&nbsp;${helpers.decodeString(food_allergy.name)}</label>
                                    % else:
                                    <label><input type="checkbox" name="medical_allergy" value="${allergy.id}" />&nbsp;${helpers.decodeString(allergy.name)}</label>
                                    % endif
                                % endfor
                            % endif
                            <br />
							<label>
								${_(u"Medical_additional_health")}<br />
								<textarea name="medical_additional_health" class="textarea_small">${helpers.decodeString(medical_data.additional_health)}</textarea>
							</label>
							<br />
							<label>
								${_(u"Pregnancy weeks during camp")}<br />
								<input type="text" name="medical_week_of_pregnancy" />&nbsp;${helpers.decodeString(medical_data.week_of_pregnancy)}</textarea>
							</label>
						</div>
					</div>
				</fieldset>
				% endif
				<fieldset>
					<input type="submit" value="${_(u"Create")}" />
					<input type="reset" value="${_(u"Reset")}" />
				</fieldset>
			</form>
			<div class="clearer"></div>
		</div>
		<div class="two columns">
			<div id="actionsMenu">
<!--			<ul>
				<li><a href="/office/participant/new/">${_(u"Create participant")}</a></li>
			</ul>-->
			</div>
		</div>
	</div>
</div>

<%
import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.organization as organizationhelpers
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
	<h1>${_(u"Create new card")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
			<form method="POST" action="">
			    <fieldset>
					<legend>${_(u"Card info")}</legend>
					<div class="row">
    					<div class="six columns">
        					<label>
        						${_(u"Checked in")}<br />
        						<input type="text" name="hospital_in" class="datetimepickernow" value="${helpers.modDateTime(medicalCard.hospital_in)}" />
        					</label>
        					<label>
        						${_(u"Checked out")}<br />
        						<input type="text" name="hospital_out" class="datetimepicker" value="${helpers.modDateTime(medicalCard.hospital_out)}" />
        					</label>
        					<label>
        						${_(u"Method of arrival")}<br />
        					    <select name="method_of_arrival">
        					        <option value="0">--</option>
        					        % if len(methodsofarrival) > 0:
        					        % for methodofarrival in methodsofarrival:
        					            % if methodofarrival.id == medicalCard.method_of_arrival:
        					                <option selected="selected" value="${methodofarrival.id}">${helpers.decodeString(methodofarrival.title)}</option>
        					            % else:
        					                <option value="${methodofarrival.id}">${helpers.decodeString(methodofarrival.title)}</option>
        					            % endif
        					        % endfor
        					        % endif
        					    </select>
        					</label>
    					</div>
    					<div class="six columns">
    					    <label>
        						${_(u"Card status")}<br />
        					    <select name="card_status">
    					            % if medicalCard.card_status == 0 or medicalCard.card_status == None:
    					                <option selected="selected" value="0">${_(u"card_status_0")}</option>
    					                <option value="10">${_(u"card_status_10")}</option>
    					                <option value="20">${_(u"card_status_20")}</option>
    					                <option value="30">${_(u"card_status_30")}</option>
    					            % elif medicalCard.card_status == 10:
    					                <option value="0">${_(u"card_status_0")}</option>
    					                <option selected="selected" value="10">${_(u"card_status_10")}</option>
    					                <option value="20">${_(u"card_status_20")}</option>
    					                <option value="30">${_(u"card_status_30")}</option>
					                % elif medicalCard.card_status == 20:
    					                <option value="0">${_(u"card_status_0")}</option>
    					                <option value="10">${_(u"card_status_10")}</option>
    					                <option selected="selected" value="20">${_(u"card_status_20")}</option>
    					                <option value="30">${_(u"card_status_30")}</option>
					                % elif medicalCard.card_status == 30:
    					                <option value="0">${_(u"card_status_0")}</option>
    					                <option value="10">${_(u"card_status_10")}</option>
    					                <option value="20">${_(u"card_status_20")}</option>
    					                <option selected="selected" value="30">${_(u"card_status_30")}</option>
    					            % endif
        					    </select>
        					</label>
        				</div>
					</div>
				</fieldset>
    		    <fieldset>
    		        <legend>${_(u"Patient info")}</legend>
    		        <fieldset>
        		        <legend>${_(u"Camp registry")}</legend>
            			<div class="row">
        					<div class="six columns">
                		        % if participant.nickname != '':
                		            ${helpers.decodeString(participant.firstname)} "${helpers.decodeString(participant.nickname)}" ${helpers.decodeString(participant.lastname)}
                		        % else:
                                    ${helpers.decodeString(participant.firstname)} ${helpers.decodeString(participant.lastname)}
                                % endif
                                <br /><br />
                                ${helpers.modDate(participant.birthdate)}<br />
                                ${_('Age group '+str(participant.age_group))}
                            </div>
        					<div class="six columns">
                                ${helpers.decodeString(organizationhelpers.getClubName(participant.club_id))}<br />
                                ${helpers.decodeString(organizationhelpers.getSubUnitName(participant.subunit_id))}<br />
                                ${helpers.decodeString(organizationhelpers.getVillageName(participant.village_id))}<br />
                                ${helpers.decodeString(organizationhelpers.getSubcampName(participant.subcamp_id))}
                            </div>
                        </div>
                    </fieldset>
                    <fieldset>
            			<div class="row">
        					<div class="six columns">
        					    <fieldset>
        					        <legend>${_(u"Additional")}</legend>
            					    <label>
                						${_(u"Social security number")}<br />
                						<input type="text" name="additional_hetu" value="${helpers.decodeString(medicalParticipantAdditional.hetu)}" />
                					</label>
                					<label>${_(u"Notes")}<br />
    						        <textarea name="additional_notes">${helpers.decodeString(medicalCardEvents[0].notes)}</textarea></label>
    						    </fieldset>
        					</div>
        					<div class="six columns">
        					    <fieldset>
                    		        <legend>${_(u"Insurance")}</legend>
            						% if medicalParticipantAdditional.insurance:
            						    <label><input type="radio" name="additional_insurance" value="0" />&nbsp;${_("Insurance, scouts")}</label>
            						    <label><input checked="checked" type="radio" name="additional_insurance" value="1" />&nbsp;${_("Insurance, other")}</label>
            						% else:
        						        <label><input checked="checked" type="radio" name="additional_insurance" value="0" />&nbsp;${_("Insurance, scouts")}</label>
        						        <label><input type="radio" name="additional_insurance" value="1" />&nbsp;${_("Insurance, other")}</label>
            					    % endif
            						<br />
                					</label>
                					<label>
                						${_(u"Insurance company")}<br />
                						<input type="text" name="additional_insurance_company" value="${helpers.decodeString(medicalParticipantAdditional.insurance_company)}" />
                					</label>
                					<label>
                						${_(u"Insurance number")}<br />
                						<input type="text" name="additional_insurance_number" value="${helpers.decodeString(medicalParticipantAdditional.insurance_number)}" />
                					</label>
                                </fielset>
        					</div>
            			</div>
            		</fieldset>
                </fieldset>
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
							% if medical_data.drugs_help == 10:
							    <label><input type="radio" name="medical_drugs_help" value="0" />&nbsp;${_("Dont need")}</label>
							    <label><input checked="checked" type="radio" name="medical_drugs_help" value="10" />&nbsp;${_("Own leader or subunit first aid")}</label>
							    <label><input type="radio" name="medical_drugs_help" value="20" />&nbsp;${_("Camphospital")}</label>
							% elif medical_data.drugs_help == 20:
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
				<fieldset>
				    <legend>${_(u"Medications")}</legend>
					<label>
						${_(u"Medications given")}<br />
					    <select name="medications">
					        % if medicalCard.medications:
					            <option value="0">${_(u"No")}</option>
					            <option selected="selected" value="1">${_(u"Yes")}</option>
					        % else:
					            <option selected="selected" value="0">${_(u"No")}</option>
					            <option value="1">${_(u"Yes")}</option>
					        % endif
					    </select>
					</label>
					<label>
						${_(u"Medications info")}<br />
						<textarea name="medications_info">${helpers.decodeString(medicalCard.medications_info)}</textarea>
					</label>
				</fieldset>
				<fieldset>
				    <legend>${_(u"Treatment")}</legend>
					<label>
						${_(u"Treatment type")}<br />
					    <select name="treatment_type">
                            <option value="0">--</option>
					        % if len(treatmenttypes) > 0:
						        % for treatmenttype in treatmenttypes:
						            % if treatmenttype.id == medicalCard.treatment_type:
						                <option selected="selected" value="${treatmenttype.id}">${helpers.decodeString(treatmenttype.title)}</option>
						            % else:
						                <option value="${treatmenttype.id}">${helpers.decodeString(treatmenttype.title)}</option>
						            % endif
						        % endfor
						    % endif
						</select>
					</label>
					<label>
						${_(u"Reason")}<br />
					    <select name="reason_id">
					        <option value="0">--</option>
					        % if len(reasons) > 0:
					        % for reason in reasons:
					            % if methodofarrival.id == medicalCard.reason_id:
					                <option selected="selected" value="${reason.id}">${helpers.decodeString(reason.title)}</option>
					            % else:
					                <option value="${reason.id}">${helpers.decodeString(reason.title)}</option>
					            % endif
					        % endfor
					    </select>
						% endif
					</label>
					<label>
						${_(u"Diagnose")}<br />
						<textarea name="diagnose">${helpers.decodeString(medicalCard.diagnose)}</textarea>
					</label>
				</fieldset>
				<fieldset>
				    <legend>${_(u"Follow up")}</legend>
					<label>
						${_(u"Going to")}<br />
						<input type="text" name="followup_going" value="${helpers.decodeString(medicalCard.followup_going)}" />
					</label>
					<label>
						${_(u"Follow up notes")}<br />
						<textarea name="followup_notes">${helpers.decodeString(medicalCard.followup_notes)}</textarea>
					</label>
				</fieldset>
				<fieldset>
				    <legend>${_(u"Events")}</legend>
				    <div class="medical_event">
                        <div class="row">
                            <div class="four columns">
                                <label>${_(u"Time")}<br />
        						<input type="text" name="event_time" class="datetimepicker" value="${helpers.modDateTime(medicalCardEvents[0].event_time)}" /></label>
                            </div>
                            <div class="four columns">
                                <label>${_(u"Writer")}<br />
        						<input type="text" name="event_writer" value="${helpers.decodeString(medicalCardEvents[0].writer)}" /></label>
                            </div>
                            <div class="four columns">
                                <label>${_(u"Type")}</label>
                                <select name="event_type">
                                    % if medicalCardEvents[0].event_type == 20:
                                        <option value="10">${_('Nurse')}</option>
                                        <option selected="selected" value="20">${_('Doctor')}</option>
                                    % else:
                                        <option selected="selected" value="10">${_('Nurse')}</option>
                                        <option value="20">${_('Doctor')}</option>
                                    % endif
                                </select>
                            </div>
                        </div>
                        <div class="row">
                            <div class="twelve columns">
                                <label>${_(u"Notes")}<br />
						        <textarea name="event_notes">${helpers.decodeString(medicalCardEvents[0].notes)}</textarea></label>
                            </div>
                        </div>
                    </div>
				</fieldset>
				<fieldset>
					<input type="submit" value="${_(u"Create")}" />
					<input type="reset" value="${_(u"Reset")}" />
				</fieldset>
			</form>
		</div>
		<div class="two columns">
		</div>
	</div>
</div>

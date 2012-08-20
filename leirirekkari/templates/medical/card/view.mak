<%
import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.organization as organizationhelpers
import leirirekkari.helpers.participant as participanthelpers
import leirirekkari.helpers.medical as medicalhelpers
%>
<%block name="template_add_styles">
</%block>

<%block name="template_add_js">
</%block>

<%block name="template_add_afterbody">

</%block>

<%inherit file="leirirekkari:templates/base.mak"/>
<div id="main_headline" class="twelve columns">
    <h1 style="float:right;">${_('Card id')}: ${str(medicalCard.id)}</h1>
	<h1>
	    ${_(u"View card for")}
	    % if participant.nickname != '':
            ${helpers.decodeString(participant.firstname)} "${helpers.decodeString(participant.nickname)}" ${helpers.decodeString(participant.lastname)}
        % else:
            ${helpers.decodeString(participant.firstname)} ${helpers.decodeString(participant.lastname)}
        % endif
	</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns wideprint">
			<form method="POST" action="">
			    <fieldset>
        			<div class="row">
    					<div class="six columns">
        					<legend>${_(u"Basic info")}</legend>
        					${_(u"Checked in")}: ${helpers.modDateTime(medicalCard.hospital_in)}
        					<br /><br />
        					% if medicalCard.hospital_in < medicalCard.hospital_out:
        					    <div class="hideprint">
        					    ${_(u"Checked out")}: ${helpers.modDateTime(medicalCard.hospital_out)}
        					    <br /><br />
        					    </div>
        					% endif
            					<div class="showprint">
        					    % if medicalCard.hospital_in > medicalCard.hospital_out:
            				        ${_(u"Checked out")}: ______________________
            				    % else:
            				        ${_(u"Checked out")}: ${helpers.modDateTime(medicalCard.hospital_out)}
            				    % endif
            				    <br /><br />
            				    </div>
                                ${_(u"Method of arrival")}: ${helpers.decodeString(medicalhelpers.getMethodOfArrivalTitle(medicalCard.method_of_arrival, '--'))}
        					</div>
        					<div class="six columns">
        						${_(u"Card status")}: <strong>${_(u"card_status_"+str(medicalCard.card_status))}</strong>
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
                                ${_('age_group_'+str(participant.age_group))}
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
                					<strong>${_(u"Social security number")}</strong>: ${helpers.decodeString(medicalParticipantAdditional.hetu)}
                					% if medicalParticipantAdditional.notes.strip() != '':
                                    <br /><br />
                                    <strong>${_(u"Notes")}</strong><br />
                                    ${helpers.convertLineBreaks(helpers.decodeString(medicalParticipantAdditional.notes))}
                                    % endif
    						    </fieldset>
        					</div>
        					<div class="six columns">
        					    <fieldset>
                    		        <legend>${_(u"Insurance")}</legend>
            						% if medicalParticipantAdditional.insurance:
                                        <strong>${_("Insurance, other")}</strong><br />
                						${_(u"Insurance company")}: ${helpers.decodeString(medicalParticipantAdditional.insurance_company)}
                                        <br />
                						${_(u"Insurance number")}: ${helpers.decodeString(medicalParticipantAdditional.insurance_number)}
            						% else:
                                        ${_("Insurance, scouts")}
            					    % endif
            						<br />
                                </fielset>
        					</div>
            			</div>
            		</fieldset>
                </fieldset>
    		    <fieldset>
    		        <legend>${_(u"Medical info")}</legend>
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
    		    </fieldset>
				<fieldset>
				    <legend>${_(u"Medications")}</legend>
					${_(u"Medications given")}: 
			        % if medicalCard.medications:
                        ${_(u"Yes")}
			        % else:
                        ${_(u"No")}
			        % endif
			        <br /><br />
			        % if medicalCard.medications_info.strip() != '':
                    <br /><br />
					${_(u"Medications info")}<br />
                    ${helpers.convertLineBreaks(helpers.decodeString(medicalCard.medications_info))}
                    % endif
				</fieldset>
				<fieldset>
				    <legend>${_(u"Treatment")}</legend>
					<label>
						${_(u"Treatment type")}: ${helpers.decodeString(medicalhelpers.getTreatmentTypeTitle(medicalCard.treatment_type, '--'))}
					</label>
					<label>
						${_(u"Reason")}: ${helpers.decodeString(medicalhelpers.getTreatmentTypeTitle(medicalCard.reason_id, '--'))}
					</label>
					<label>
						${_(u"Diagnose")}<br />
                        ${helpers.convertLineBreaks(helpers.decodeString(medicalCard.diagnose))}
					</label>
				</fieldset>
				<fieldset>
				    <legend>${_(u"Follow up")}</legend>
					${_(u"Going to")}: ${helpers.decodeString(medicalCard.followup_going)}
                    <br /><br />
					${_(u"Follow up notes")}<br />
					${helpers.convertLineBreaks(helpers.decodeString(medicalCard.followup_notes))}
				</fieldset>
				<fieldset>
				    <legend>${_(u"Events")}</legend>
				    % for medicalCardEvent in medicalCardEvents:
				    <div class="medical_event">
                        <div class="row">
                            <div class="four columns">
                                <label>${_(u"Time")}: ${helpers.modDateTime(medicalCardEvent.event_time)}
                            </div>
                            <div class="four columns">
                                <label>${_(u"Writer")}: ${helpers.decodeString(medicalCardEvent.writer)}
                            </div>
                            <div class="four columns">
                                <strong>${_(u"Type")}</strong>: 
                                % if medicalCardEvent.event_type == 20:
                                    ${_('Doctor')}
                                % else:
                                    ${_('Nurse')}
                                % endif
                            </div>
                        </div>
                        <div class="row">
                            <div class="twelve columns">
                                <strong>${_(u"Info")}</strong><br />
						        ${helpers.literal(helpers.decodeString(medicalCardEvent.notes))}
                            </div>
                        </div>
                        <hr />
                    </div>
                    % endfor
                    <div class="showprint">
                        <fielset>
                            <legend>${_(u"Event")}</legend>
                            <br />
                            <div class="row">
                                <div class="four columns">
                                    <label>${_(u"Time")}: _____________
                                </div>
                                <div class="four columns">
                                    <label>${_(u"Writer")}: _____________
                                </div>
                                <div class="four columns">
                                    <strong>${_(u"Type")}</strong>: _____________
                                </div>
                            </div>
                            <div class="row">
                                <div class="twelve columns">
                                    <strong>${_(u"Info")}</strong><br />
                                    <br />
    						        <hr />
    						        <br />
    						        <hr />
    						        <br />
    						        <hr />
    						        <br />
    						        <hr />
                                </div>
                            </div>
                        </fielset>
                        <fielset>
                            <legend>${_(u"Event")}</legend>
                            <br />
                            <div class="row">
                                <div class="four columns">
                                    <label>${_(u"Time")}: _____________
                                </div>
                                <div class="four columns">
                                    <label>${_(u"Writer")}: _____________
                                </div>
                                <div class="four columns">
                                    <strong>${_(u"Type")}</strong>: _____________
                                </div>
                            </div>
                            <div class="row">
                                <div class="twelve columns">
                                    <strong>${_(u"Info")}</strong><br />
                                    <br />
    						        <hr />
    						        <br />
    						        <hr />
    						        <br />
    						        <hr />
    						        <br />
    						        <hr />
                                </div>
                            </div>
                        </fielset>
                        <fielset>
                            <legend>${_(u"Event")}</legend>
                            <br />
                            <div class="row">
                                <div class="four columns">
                                    <label>${_(u"Time")}: _____________
                                </div>
                                <div class="four columns">
                                    <label>${_(u"Writer")}: _____________
                                </div>
                                <div class="four columns">
                                    <strong>${_(u"Type")}</strong>: _____________
                                </div>
                            </div>
                            <div class="row">
                                <div class="twelve columns">
                                    <strong>${_(u"Info")}</strong><br />
                                    <br />
    						        <hr />
    						        <br />
    						        <hr />
    						        <br />
    						        <hr />
    						        <br />
    						        <hr />
                                </div>
                            </div>
                        </fielset>
                    </div>
				</fieldset>
			</form>
		</div>
		<div class="two columns hideprint">
			<div id="actionsMenu">
    			<ul>
    				<li><a href="/medical/card/edit/${medicalCard.id}/">${_(u"Edit card")}</a></li>
    			</ul>
			</div>
			% if len(participant_cards) > 0:
			<div id="participant_cards">
			    <table class="tablesorter">
                <thead>
                    <tr>
                        <th>${_('Id')}</th>
                        <th>${_('Status')}</th>
                        <th>${_('Created')}</th>
                    </tr>
                </thead>
                <tbody>
                    % for card in participant_cards:
                    <tr>
                        <td><a href="/medical/card/view/${card.id}/">${card.id}</a></td>
                        <td>${_(u"card_status_"+str(card.card_status))}</td>
                        <td>${helpers.modDateTime(card.metadata_created)}</td>
                    </tr>
                    % endfor
                </tbody>
                </table>
			</div>
			% endif
		</div>
	</div>
</div>

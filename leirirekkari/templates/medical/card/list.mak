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
	<h1>${_(u"View card")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
            % if len(cards) > 0:
            <h2>${_(u"Results")}  (${len(cards)})</h2>
            <table class="tablesorter">
            <thead>
                <tr>
                    <th>${_('Id')}</th>
                    <th>${_('Patient')}</th>
                    <th>${_('Status')}</th>
                    <th>${_('Created')}</th>
                </tr>
            </thead>
            <tbody>
                % for card in cards:
                <%
                participant = participanthelpers.getParticipant(card.participant_id)
                %>
                <tr>
                    <td><a href="/medical/card/view/${card.id}/">${card.id}</a></td>
                    <td><a href="/office/participant/view/${participant.id}/">${helpers.decodeString(participant.firstname)} ${helpers.decodeString(participant.lastname)}</a></td>
                    <td>${_(u"card_status_"+str(card.card_status))}</td>
                    <td>${helpers.modDateTime(card.metadata_created)}</td>
                </tr>
                % endfor
            </tbody>
            </table>
            % else:
            <h2>${_(u"Results")}</h2>
            ${_(u"No cards found")}
            % endif
            <br /><br />
    	</div>
		<div class="two columns">
			<div id="actionsMenu">
			<ul>
				<li><a href="/medical/card/list/">${_(u"Cards")}</a></li>
				<li><a href="/medical/statistics/">${_(u"Statistics")}</a></li>
				<li><a href="/medical/settings/">${_(u"Settings")}</a></li>
			</ul>
			</div>
		</div>
	</div>
</div>

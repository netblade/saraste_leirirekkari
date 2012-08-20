<%
import pyramid.security as security
import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.participant as participanthelpers
%>
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
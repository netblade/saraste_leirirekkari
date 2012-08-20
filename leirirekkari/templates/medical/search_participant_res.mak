<%
import pyramid.security as security
import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.organization as organizationhelpers
%>
% if len(participants) > 0:
<h2>${_(u"Results")} (${len(participants)})</h2>
<table class="tablesorter">
<thead>
    <tr>
        <th class="{sorter: false}">${_('Card')}</th>
        <th>${_('Name')}</th>
        <th>${_('Club')}</th>
        <th>${_('Subunit')}</th>
        <th>${_('Village')}</th>
        <th>${_('Subcamp')}</th>
    </tr>
</thead>
<tbody>
    % for participant in participants:
    <tr>
        <td><a class="button" href="/medical/card/new/${participant.id}/">${_(u"Create")}</a></td>
        <td><a href="/office/participant/view/${participant.id}/">
        ${helpers.decodeString(participant.firstname)}
        % if participant.nickname.strip() != '':
            "${helpers.decodeString(participant.nickname)}"
        % endif
        ${helpers.decodeString(participant.lastname)}
        </a></td>
        <td>${helpers.decodeString(organizationhelpers.getClubName(participant.club_id))}</td>
        <td>${helpers.decodeString(organizationhelpers.getSubcampName(participant.subcamp_id))}</td>
        <td>${helpers.decodeString(organizationhelpers.getVillageName(participant.village_id))}</td>
        <td>${helpers.decodeString(organizationhelpers.getSubUnitName(participant.subunit_id))}</td>
    </tr>
    % endfor
</tbody>
</table>
% else:
<h2>${_(u"Results")}</h2>
${_(u"No participants found")}
% endif
<br /><br />
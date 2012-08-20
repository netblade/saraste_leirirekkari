<%
import pyramid.security as security
import leirirekkari.helpers.helpers as helpers

from leirirekkari.models.dbsession import (
    DBSession
    )

from leirirekkari.models.organization import (
    Subcamp, Village, SubUnit, Club
    )
from leirirekkari.models.participant import (
    Participant
    )
clubs_shown = []
%>

<%block name="template_add_styles">
</%block>

<%block name="template_add_js">
</%block>

<%block name="template_add_afterbody">

</%block>

<%inherit file="base.mak"/>
<div id="main_headline" class="twelve columns">
    <h1>${_(u"Presences by unit")}</h1>
</div>
<div id="content_container" class="twelve columns">
    <div id="content" class="row">
        <div class="twelve columns">
            <div id="organization_tree">
				<table>
					<thead>
						<tr>
							<th colspan="4">${_('Name')}</th>
							<th>${_('Leader')}</th>
							<th>${_('Tools')}</th>
						</tr>
					</thead>
					<tbody>
					% for subcamp in subcamps:
						<tr>
							<td colspan="4">${helpers.decodeString(subcamp.name)}</td>
							<td></td>
							<td><a href="/settings/organization/subcamp_edit/${subcamp.id}/">${_('Edit')}</a></td>
						</tr>
						<%
						villages = DBSession.query(Village).filter(Village.subcamp_id==subcamp.id).all()
						%>
						% if len(villages) > 0:
							% for village in villages:
								<tr>
									<td>&nbsp;</td>
									<td colspan="3">${helpers.decodeString(village.name)}</td>
									<td></td>
									<td><a href="/settings/organization/village_edit/${village.id}/">${_('Edit')}</a></td>
								</tr>
								<%
								subunits = DBSession.query(SubUnit).filter(SubUnit.village_id==village.id).all()
								%>
								% if len(subunits) > 0:
									% for subunit in subunits:
										<tr>
											<td>&nbsp;</td>
											<td>&nbsp;</td>
											<td colspan="2">${helpers.decodeString(subunit.name)}</td>
											<td></td>
											<td><a href="/settings/organization/subunit_edit/${subunit.id}/">${_('Edit')}</a></td>
										</tr>
										<%
										clubs = DBSession.query(Club).filter(Club.subunit_id==subunit.id).all()
										%>
										% if len(clubs) > 0:
										% for club in clubs:
											<% 
											clubs_shown.append(club.id)
											%>
											<tr>
												<td>&nbsp;</td>
												<td>&nbsp;</td>
												<td>&nbsp;</td>
												<td>${helpers.decodeString(club.name)}</td>
												<td></td>
												<td><a href="/settings/organization/club_edit/${club.id}/">${_('Edit')}</a></td>
											</tr>
										% endfor
									% endif
								% endfor
							% endif
						% endfor
					% endif
				% endfor
				</tbody>
				</table>
				<h4>${_('Unassigned clubs')}</h4>
				<%
				unassigned_clubs = DBSession.query(Club).filter(~Club.id.in_(clubs_shown)).all()
				%>
				% if len(unassigned_clubs) > 0:
				
				<table>
					<thead>
						<tr>
							<th>${_('Name')}</th>
							<th>${_('Leader')}</th>
							<th>${_('Tools')}</th>
						</tr>
					</thead>
					<tbody>
						% for unassigned_club in unassigned_clubs:
						<tr>
							<td>${helpers.decodeString(unassigned_club.name)}</td>
							<td></td>
							<td><a href="/settings/organization/club_edit/${unassigned_club.id}/">${_('Edit')}</a></td>
						</tr>
						% endfor
					</tbody>
				</table>
				% endif
			</div>
            <div class="clearer"></div>
            <br /><br /><br /><br /><br /><br /><br />
        </div>
    </div>
</div>
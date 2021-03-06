<%
import pyramid.security as security
import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.organization as organizationhelpers

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
	    <div id="search_container_opener" style="padding-left: 20px;">
	        <a href="#">${_(u"Show / hide search values")}</a>
	        <br /><br />
	    </div>
	    <div id="search_container" style="display: none; padding-left: 20px;">
			<form method="post" action="/office/participant/search/">
				<label for="searchstr">${_(u"Search by text")}</label>
				<div class="row">
				    <div class="six columns">
				        <input name="searchstr" id="searchstr" type="text" value="${search_string}" style=" float: left; margin-right: 10px;" />
				        <input type="submit" value="${_(u"Search")}" style="width: 175px; float: left; margin-top: 6px;" />
				    </div>
				</div>
			</form>
	    </div>
		<div class="ten columns">
            <table class="tablesorter">
            <thead>
                <tr>
                    <th>${_('Firstname')}</th>
                    <th>${_('Lastname')}</th>
                    <th>${_('Nickname')}</th>
                    <th>${_('Agegroup')}</th>
                    <th>${_('Club')}</th>
                    <th>${_('Subcamp')}</th>
                    <th>${_('Village')}</th>
                    <th>${_('Subunit')}</th>
                    <th>${_('Presences')}</th>
                </tr>
            </thead>
            <tbody>
                % for participant in participants:
                <tr>
                    <td><a href="/office/participant/view/${participant.id}/">${helpers.decodeString(participant.firstname)}</a></td>
                    <td>${helpers.decodeString(participant.lastname)}</td>
                    <td>${helpers.decodeString(participant.nickname)}</td>
                    <td>${_(u"age_group_"+str(participant.age_group))}</td>
                    <td>${helpers.decodeString(organizationhelpers.getClubName(participant.club_id))}</td>
                    <td>${helpers.decodeString(organizationhelpers.getSubcampName(participant.subcamp_id))}</td>
                    <td>${helpers.decodeString(organizationhelpers.getVillageName(participant.village_id))}</td>
                    <td>${helpers.decodeString(organizationhelpers.getSubUnitName(participant.subunit_id))}</td>
                    <td>
                        % if len(participant.presence_data)>0:
                            % for presence in participant.presence_data:
                                ${helpers.getDayString(presence.presence_starts, 'short')} ${helpers.modDateTime(presence.presence_starts, 'shortwithtime')} - ${helpers.getDayString(presence.presence_ends, 'short')} ${helpers.modDateTime(presence.presence_ends, 'shortwithtime')}<br />
                            % endfor
                        % endif
                    </td>
                </tr>
                % endfor
            </tbody>
            </table>
			<div class="clearer"></div>
		</div>
		<div class="two columns">
			<div id="actionsMenu">
			<ul>
				<li><a href="/office/participant/new/">${_(u"Create participant")}</a></li>
			</ul>
			</div>
		</div>
	</div>
</div>

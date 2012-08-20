<%
import leirirekkari.helpers.helpers as helpers
%>
<%block name="template_add_styles">
</%block>

<%block name="template_add_js">
</%block>

<%block name="template_add_afterbody">

</%block>

<%inherit file="leirirekkari:templates/base.mak"/>
<div id="main_headline" class="twelve columns">
	<h1>${_(u"Groups")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
			<table id="users" class="tablesorter">
				<thead>
					<tr>
					    <th>${_(u"Id")}</th>
						<th>${_(u"Name")}</th>
<!--						<th>${_(u"Leader")}</th>-->
						<th class="{sorter: false}">${_(u"Tools")}</th>
					</tr>
				</thead>
				<tbody>
				    % for group in groups:
				        ${makerow(group)}
				    % endfor
				</tbody>
			</table>
		</div>
		<div class="two columns">
			<div id="actionsMenu">
			<ul>
				<li><a href="/settings/groups/new/">${_(u"Create")}</a></li>
			</ul>
			</div>
		</div>
	</div>
</div>



<%def name="makerow(group)">
    <tr>
        <td>${str(group.id)}</td>
		<td><a href="/settings/groups/view/${group.id}">${helpers.decodeString(group.name)}</a></td>
<!--		<td>${group.leader_id}</td>-->
		<td>
		% if group.id != 1:
		<a href="/settings/groups/edit/${group.id}">${_(u"Edit")}</a>
		% else:
		&nbsp;
		% endif
		</td>
    </tr>
</%def>

<%
import pyramid.security as security
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
	<h1>${_(u"Settings")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
		    <h2>${_(u"Reasons")}</h2>
		    % if len(reasons) > 0:
			<table id="users" class="tablesorter">
				<thead>
					<tr>
						<th>${_(u"Title")}</th>
						<th class="{sorter: false}">${_(u"Tools")}</th>
					</tr>
				</thead>
				<tbody>
				    % for reason in reasons:
                    <tr>
                		<td>${helpers.decodeString(reason.title)}</td>
                		<td><a href="/medical/settings/reasons/edit/${reason.id}/">${_(u"Edit")}</a></td>
                    </tr>
				    % endfor
				</tbody>
			</table>
			% else:
			${_(u"No reasons defined, please create")}
			% endif
			<br /><br />
			<h2>${_(u"Treatmenttypes")}</h2>
		    % if len(treatmenttypes) > 0:
			<table id="users" class="tablesorter">
				<thead>
					<tr>
						<th>${_(u"Title")}</th>
						<th class="{sorter: false}">${_(u"Tools")}</th>
					</tr>
				</thead>
				<tbody>
				    % for treatmenttype in treatmenttypes:
                    <tr>
                		<td>${helpers.decodeString(treatmenttype.title)}</td>
                		<td><a href="/medical/settings/treatmenttypes/edit/${treatmenttype.id}/">${_(u"Edit")}</a></td>
                    </tr>
				    % endfor
				</tbody>
			</table>
			% else:
			${_(u"No treatmenttypes defined, please create")}
			% endif
			<br /><br />
			<h2>${_(u"Methodsofarrival")}</h2>
		    % if len(methodsofarrival) > 0:
			<table id="users" class="tablesorter">
				<thead>
					<tr>
						<th>${_(u"Title")}</th>
						<th class="{sorter: false}">${_(u"Tools")}</th>
					</tr>
				</thead>
				<tbody>
				    % for methodofarrival in methodsofarrival:
                    <tr>
                		<td>${helpers.decodeString(methodofarrival.title)}</td>
                		<td><a href="/medical/settings/methodofarrival/edit/${methodofarrival.id}/">${_(u"Edit")}</a></td>
                    </tr>
				    % endfor
				</tbody>
			</table>
			% else:
			${_(u"No reasons defined, please create")}
			% endif
		</div>
		<div class="two columns">
			<div id="actionsMenu">
			<ul>
				<li><a href="/medical/settings/reasons/new/">${_(u"Create reason")}</a></li>
				<li><a href="/medical/settings/treatmenttypes/new/">${_(u"Create treatmenttype")}</a></li>
				<li><a href="/medical/settings/methodofarrival/new/">${_(u"Create methodofarrival")}</a></li>
			</ul>
			</div>
		</div>
	</div>
</div>
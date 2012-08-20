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
	<h1>${_(u"Settings")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
			<table id="users" class="tablesorter">
				<thead>
					<tr>
						<th>${_(u"Key")}</th>
						<th>${_(u"Value")}</th>
						<th class="{sorter: false}">${_(u"Tools")}</th>
					</tr>
				</thead>
				<tbody>
				    % for setting in settings:
				        ${makerow(setting)}
				    % endfor
				</tbody>
			</table>
		</div>
		<div class="two columns">
			<div id="actionsMenu">
			<ul>
				<li><a href="/settings/new/">${_(u"Create")}</a></li>
			</ul>
			</div>
		</div>
	</div>
</div>



<%def name="makerow(setting)">
    <tr>
		<td>${helpers.decodeString(setting.setting_key)}</td>
		<td>${helpers.decodeString(setting.setting_value)}</td>
		<td><a href="/settings/edit/${setting.id}">${_(u"Edit")}</a></td>
    </tr>
</%def>

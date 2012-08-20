<%
import pyramid.security as security
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
		<div class="twelve columns">
			<ul id="frontpage_links">
				<li><a href="/settings/me/"><img src="${request.static_url('leirirekkari:static/img/icons/settings_2.png')}" alt="" /><div class="text_container">${_(u"My own")}</div></a></li>
				% if security.has_permission('settings_users', request.context, request):
				<li><a href="/settings/users/"><img src="${request.static_url('leirirekkari:static/img/icons/folder_users.png')}" width="40" alt="" /><div class="text_container">${_(u"Users")}</div></a></li>
				% endif
				% if security.has_permission('settings_groups', request.context, request):
				<li><a href="/settings/groups/"><img src="${request.static_url('leirirekkari:static/img/icons/folder_groups.png')}" width="40" alt="" /><div class="text_container">${_(u"Groups")}</div></a></li>
				% endif
				% if security.has_permission('settings_list', request.context, request):
				<li><a href="/settings/list/"><img src="${request.static_url('leirirekkari:static/img/icons/settings.png')}" width="40" alt="" /><div class="text_container">${_(u"Settings")}</div></a></li>
				% endif
				% if security.has_permission('settings_organization', request.context, request):
				<li><a href="/settings/organization/"><img src="${request.static_url('leirirekkari:static/img/icons/organization.png')}" width="40" alt="" /><div class="text_container">${_(u"Organization")}</div></a></li>
				% endif
				% if security.has_permission('settings_imports', request.context, request):
				<li><a href="/settings/imports/"><img src="${request.static_url('leirirekkari:static/img/icons/import.png')}" width="40" alt="" /><div class="text_container">${_(u"Import")}</div></a></li>
				% endif
			</ul>
			<div class="clearer"></div>
			<br /><br /><br /><br /><br /><br /><br />
		</div>
	</div>
</div>
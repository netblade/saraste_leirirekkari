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

<%inherit file="base.mak"/>
<div id="main_headline" class="twelve columns">
	<h1>${_(u"Camp registry")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="twelve columns">
			<ul id="frontpage_links">
				% if security.has_permission('office_view', request.context, request):
				<li><a href="/office/"><img src="${request.static_url('leirirekkari:static/img/icons/office.png')}" alt="" /><div class="text_container">${_(u"Office")}</div></a></li>
				% endif
				% if security.has_permission('security_view', request.context, request):
				<li><a href="/security/"><img src="${request.static_url('leirirekkari:static/img/icons/security.png')}" alt="" /><div class="text_container">${_(u"Security")}</div></a></li>
				% endif
<!--
				% if security.has_permission('programme_view', request.context, request):
				<li><a href="/programme/"><img src="${request.static_url('leirirekkari:static/img/icons/programme.png')}" alt="" /><div class="text_container">${_(u"Programme")}</div></a></li>
				% endif
-->
				% if security.has_permission('kitchen_view', request.context, request):
				<li><a href="/kitchen/"><img src="${request.static_url('leirirekkari:static/img/icons/kitchen.png')}" alt="" /><div class="text_container">${_(u"Kitchen")}</div></a></li>
				% endif

				% if security.has_permission('medical_view', request.context, request):
				<li><a href="/medical/"><img src="${request.static_url('leirirekkari:static/img/icons/hospital.png')}" alt="" /><div class="text_container">${_(u"Medical")}</div></a></li>
				% endif}
			</ul>
			<div class="clearer"></div>
			<br /><br /><br /><br /><br /><br /><br />
		</div>
	</div>
</div>
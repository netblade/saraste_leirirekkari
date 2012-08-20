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
	<h1>${_(u"Imports")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="twelve columns">
			<ul>
				<li><a href="/settings/imports/clubs/">${_(u"Import clubs")}</a></li>
				<li><a href="/settings/imports/organization/">${_(u"Import organization")}</a></li>
				<li><a href="/settings/imports/polkubookings/">${_(u"Import polku bookings")}</a></li>
				<li><a href="/settings/imports/polkuanswers/">${_(u"Import polku answers")}</a></li>
				<li><a href="/settings/imports/polkuit/">${_(u"Import polku contact")}</a></li>
				<li><a href="/settings/imports/precences/">${_(u"Import presences")}</a></li>
				<li><a href="/settings/imports/users/">${_(u"Import users")}</a></li>
			</ul>
			<div class="clearer"></div>
			<br /><br /><br /><br /><br /><br /><br />
		</div>
	</div>
</div>
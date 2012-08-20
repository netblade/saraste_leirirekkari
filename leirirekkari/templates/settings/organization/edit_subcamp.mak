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
	<h1>${_(u"Edit subcamp")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
			<form method="POST" action="">
				<fieldset>
					<legend>${_(u"Subcamp")}</legend>
					<label>
						${_(u"Name")}<br />
						<input type="text" name="name" value="${helpers.decodeString(subcamp['name'])}" />
					</label>
					<label>
						${_(u"Short name")}<br />
						<input type="text" name="short_name" value="${helpers.decodeString(subcamp['short_name'])}" />
					</label>
					<div id="hidden" name="leader_id" value="0" />
				</fieldset>
				<fieldset>
					<input type="submit" value="${_(u"Save")}" />
					<input type="reset" value="${_(u"Reset")}" />
				</fieldset>
			</form>
		</div>
		<div class="two columns">
			<div id="actionsMenu">
			<ul>
			<li><a href="/settings/organization/subcamp_new/">${_(u"Create subcamp")}</a></li>
			<li><a href="/settings/organization/village_new/">${_(u"Create village")}</a></li>
            <li><a href="/settings/organization/village_kitchen_new/">${_(u"Create village kitchen")}</a></li>
			<li><a href="/settings/organization/subunit_new/">${_(u"Create subunit")}</a></li>
			<li><a href="/settings/organization/club_new/">${_(u"Create club")}</a></li>
			</ul>
			</div>
		</div>
	</div>
</div>
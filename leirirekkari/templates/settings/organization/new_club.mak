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
	<h1>${_(u"New club")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
			<form method="POST" action="">
				<fieldset>
					<legend>${_(u"Subcamp")}</legend>
					<label>
						${_(u"Name")}<br />
						<input type="text" name="name" value="${club['name']}" />
					</label>
					<label>
						${_(u"Short name")}<br />
						<input type="text" name="short_name" value="${club['short_name']}" />
					</label>
					<label>
						${_(u"Club code")}<br />
						<input type="text" name="club_code" value="${helpers.decodeString(club['club_code'])}" />
					</label>
					<label>
						${_(u"Sub unit")}<br />
						<select name="subunit_id">
							% for subunit in subunits:
								<option value="${subunit.id}">${helpers.decodeString(subunit.name)}</option>
							% endfor
						</select>
					</label>
					<input type="hidden" name="leader_id" />
				</fieldset>
				<fieldset>
					<input type="submit" value="${_(u"Create")}" />
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

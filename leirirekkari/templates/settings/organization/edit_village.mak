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
	<h1>${_(u"Edit village")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
			<form method="POST" action="">
				<fieldset>
					<legend>${_(u"Village")}</legend>
					<label>
						${_(u"Name")}<br />
						<input type="text" name="name" value="${helpers.decodeString(village['name'])}" />
					</label>
					<label>
						${_(u"Short name")}<br />
						<input type="text" name="short_name" value="${helpers.decodeString(village['name'])}" />
					</label>
					<label>
						${_(u"Subcamp")}<br />
						<select name="subcamp_id">
							% for subcamp in subcamps:
								% if subcamp.id == village['subcamp_id']:
									<option selected="selected" value="${subcamp.id}">${helpers.decodeString(subcamp.name)}</option>
								% else:
									<option value="${subcamp.id}">${helpers.decodeString(subcamp.name)}</option>
								% endif
							% endfor
						</select>
					</label>
					<input type="hidden" name="leader_id" />
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

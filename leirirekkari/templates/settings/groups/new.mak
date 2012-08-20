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
	<h1>${_(u"Create new group")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
			<form method="POST" action="">
				<fieldset>
					<legend>${_(u"Basic info")}</legend>
					<label>
						${_(u"Name")}<br />
						<input type="text" name="name" value="${group['name']}" />
					</label>
				</fieldset>
				% if len(privileges) > 0 and group['privileges'] != None:
				<fieldset>
					<legend>${_(u"Privileges")}</legend>
					% for privilege in privileges:
				        ${makerow_privilege(privilege)}
				    % endfor
				</fieldset>
				% endif
				<fieldset>
					<input type="submit" value="${_(u"Create")}" />
					<input type="reset" value="${_(u"Reset")}" />
				</fieldset>
			</form>
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

<%def name="makerow_privilege(privilege)">
	<label>
		<input value="${privilege.id}" type="checkbox" name="privileges" />&nbsp;${_(privilege.name)}
	</label>
</%def>
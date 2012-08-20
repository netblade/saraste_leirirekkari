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
	<h1>${_(u"Edit group")}&nbsp;${helpers.decodeString(group['name'])}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
			<form method="POST" action="">
				<fieldset>
					<legend>${_(u"Basic info")}</legend>
					<label>
						${_(u"Name")}<br />
						<input type="text" name="name" value="${helpers.decodeString(group['name'])}" />
					</label>
				</fieldset>
				<fieldset>
					<legend>${_(u"Privileges")}</legend>
					% for privilege in privileges:
				        ${makerow_privilege(privilege, group['privileges'])}
				    % endfor
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
				<li><a href="/settings/groups/new/">${_(u"Create")}</a></li>
			</ul>
			</div>
		</div>
	</div>
</div>

<%def name="makerow_privilege(privilege, userprivileges)">
	% if userprivileges != None and userprivileges.find('|'+privilege.name+'|') > -1:
	<label>
		<input checked="checked" value="${privilege.id}" type="checkbox" name="privileges" />&nbsp;${_(privilege.name)}
	</label>
	% else:
	<label>
		<input value="${privilege.id}" type="checkbox" name="privileges" />&nbsp;${_(privilege.name)}
	</label>
	% endif
</%def>
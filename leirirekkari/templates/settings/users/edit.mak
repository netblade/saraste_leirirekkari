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
	<h1>${_(u"Edit user")}&nbsp;${helpers.decodeString(user['firstname'])}&nbsp;${helpers.decodeString(user['lastname'])}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
			<form method="POST" action="">
				<fieldset>
					<legend>${_(u"Basic info")}</legend>
					<label>
						${_(u"First name")}<br />
						<input type="text" name="firstname" value="${helpers.decodeString(user['firstname'])}" />
					</label>
					<label>
						${_(u"Last name")}<br />
						<input type="text" name="lastname" value="${helpers.decodeString(user['lastname'])}" />
					</label>
					<label>
						${_(u"Email")}<br />
						<input type="text" name="email" value="${helpers.decodeString(user['email'])}" />
					</label>
					<label>
						${_(u"Designation")}<br />
						<input type="text" name="title" value="${helpers.decodeString(user['title'])}" />
					</label>
					<label>
						${_(u"Language")}<br />
						<select name="language">
							% if user['language'] == 'fi_FI':
								<option selected="selected" value="fi_FI">${_(u"Finnish")}</option>
							% else:
								<option value="fi_FI">${_(u"Finnish")}</option>
							% endif
							% if user['language'] == 'sv_FI':
								<option selected="selected" value="sv_FI">${_(u"Finland Swedish")}</option>
							% else:
								<option value="sv_FI">${_(u"Finland Swedish")}</option>
							% endif
							% if user['language'] == 'en_US':
								<option selected="selected" value="en_US">${_(u"English")}</option>
							% else:
								<option value="en_US">${_(u"English")}</option>
							% endif
						</select>
					</label>
				</fieldset>
				% if user['id'] != 1:
				<fieldset>
					<legend>${_(u"Login info")}</legend>
					<label>
						${_(u"Username")}<br />
						<input value="${helpers.decodeString(user['login'])}" type="text" autocomplete="off" name="account_login" />
					</label>
					<label>
						${_(u"Password")}<br />
						<input type="password" autocomplete="off" name="account_password" />
					</label>
					<label>
						${_(u"Password confirmation")}<br />
						<input type="password" autocomplete="off" name="account_password_again" />
					</label>
				</fieldset>
				% endif
				<fieldset>
					<legend>${_(u"Groups")}</legend>
					% for group in groups:
				        ${makerow_group(group, user['group_ids'])}
				    % endfor
				</fieldset>
				<fieldset>
					<legend>${_(u"Personal privileges")}</legend>
					% for privilege in privileges:
				        ${makerow_privilege(privilege, user['privileges'])}
				    % endfor
				</fieldset>
				% if use_mailer == 'true':
				<fieldset>
					<legend>${_(u"Email")}</legend>
					<label>
					    <input type="checkbox" name="send_login_details" value="1" />&nbsp;${_(u"Send login and password by email to given email address?")}
					</label>
				</fieldset>
				% endif
				<fieldset>
					<legend>${_(u"Require password change")}</legend>
					<label>
					    <input type="checkbox" name="require_password_change" value="1" />&nbsp;${_(u"Require user to change password on next login?")}
					</label>
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
				<li><a href="/settings/users/new/">${_(u"Create")}</a></li>
			</ul>
			</div>
		</div>
	</div>
</div>


<%def name="makerow_group(group, usergroups)">
	% if group.id in usergroups:
	<label>
		<input checked="checked" value="${group.id}" type="checkbox" name="groups" />&nbsp;${helpers.decodeString(group.name)}
	</label>
	% else:
	<label>
		<input value="${group.id}" type="checkbox" name="groups" />&nbsp;${helpers.decodeString(group.name)}
	</label>
	% endif
</%def>

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
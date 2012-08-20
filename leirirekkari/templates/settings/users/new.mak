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
	<h1>${_(u"Create new user")}</h1>
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
				% if len(groups) > 0:
				<fieldset>
					<legend>${_(u"Groups")}</legend>
					% for group in groups:
				        ${makerow_group(group)}
				    % endfor
				</fieldset>
				% endif
				% if len(privileges) > 0 and user['privileges'] != None:
				<fieldset>
					<legend>${_(u"Personal privileges")}</legend>
					% for privilege in privileges:
				        ${makerow_privilege(privilege)}
				    % endfor
				</fieldset>
				% endif
				% if use_mailer == 'true':
				<fieldset>
					<legend>${_(u"Email")}</legend>
					<label>
					    <input type="checkbox" checked="checked" name="send_login_details" value="1" />&nbsp;${_(u"Send login and password by email to given email address?")}
					</label>
				</fieldset>
				% endif
				<fieldset>
					<legend>${_(u"Require password change")}</legend>
					<label>
					    <input type="checkbox" checked="checked" name="require_password_change" value="1" />&nbsp;${_(u"Require user to change password on first login?")}
					</label>
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
				<li><a href="/settings/users/new/">${_(u"Create")}</a></li>
			</ul>
			</div>
		</div>
	</div>
</div>


<%def name="makerow_group(group)">
	<label>
		<input value="${group.id}" type="checkbox" name="groups" />&nbsp;${helpers.decodeString(group.name)}
	</label>
</%def>

<%def name="makerow_privilege(privilege)">
	<label>
		<input value="${privilege.id}" type="checkbox" name="privileges" />&nbsp;${_(privilege.name)}
	</label>
</%def>
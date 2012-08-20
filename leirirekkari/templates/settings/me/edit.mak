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
				<fieldset>
					<legend>${_(u"Change password")}</legend>
					<label>
						${_(u"Password")}<br />
						<input type="password" autocomplete="off" name="account_password" />
					</label>
					<label>
						${_(u"Password confirmation")}<br />
						<input type="password" autocomplete="off" name="account_password_again" />
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

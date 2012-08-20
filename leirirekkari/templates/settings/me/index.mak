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
	<h1>${_(u"User")}&nbsp;${helpers.decodeString(user['firstname'])}&nbsp;${helpers.decodeString(user['lastname'])}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
			<strong>${_(u"First name")}</strong><br />
			${helpers.decodeString(user['firstname'])}
			<br /><br />
			<strong>${_(u"Last name")}</strong><br />
			${helpers.decodeString(user['lastname'])}
			<br /><br />
			<strong>${_(u"Email")}</strong><br />
			${helpers.decodeString(user['email'])}
			<br /><br />
			<strong>${_(u"Designation")}</strong><br />
			${helpers.decodeString(user['title'])}
			<br /><br />
			<strong>${_(u"Language")}</strong><br />
				% if user['language'] == 'fi_FI':
					${_(u"Finnish")}
				% elif user['language'] == 'sv_FI':
					${_(u"Finland Swedish")}
				% elif user['language'] == 'en_US':
					${_(u"English")}
				% else:
					${_(u"Not set")}
				% endif
			<br /><br />
			<strong>${_(u"Username")}</strong><br />
			${helpers.decodeString(user['login'])}
			<br /><br />
			% if len(groups) > 0:
				<strong>${_(u"Groups")}</strong><br />
				% if len(user['group_ids']) > 0:
					<ul>
					% for group in groups:
						${makerow_group(group, user['group_ids'])}
					% endfor
					</ul>
				% else:
					${_(u"No groups")}
				% endif
			% endif
			<br /><br />
			% if len(privileges) > 0 and user['privileges'] != None:
			    <%
                user_privileges = user['privileges'].split('|')
    			%>
				<strong>${_(u"Privileges")}</strong><br />
				% if len(user_privileges) > 0:
					<ul>
					    % for user_privilege in user_privileges:
					    <%
					    privilege = user_privilege.strip('|')
					    %>
					    % if privilege != '':
					        <li>${_(privilege)}</li>
					    % endif
					    % endfor
					</ul>
				% else:
					${_(u"No specific privileges")}
				% endif
			% endif
		</div>
		<div class="two columns">
			<div id="actionsMenu">
			<ul>
				<li><a href="/settings/me/edit/">${_(u"Edit")}</a></li>
			</ul>
			</div>
		</div>
	</div>
</div>

<%def name="makerow_group(group, usergroups)">
	% if group.id in usergroups:
		<li>${helpers.decodeString(group.name)}</li>
	% endif
</%def>

<%def name="makerow_privilege(privilege, userprivileges)">
	% if privilege.id in userprivileges:
		<li>${_(privilege.name)}</li>
	% endif
</%def>
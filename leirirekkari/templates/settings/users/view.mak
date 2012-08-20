<%
import leirirekkari.helpers.helpers as helpers
%>
<%block name="template_add_styles">
</%block>

<%block name="template_add_js">
<script>
$('#trigger_delete').click(function() {
	return confirm('${_("Are you sure that you want to delete this person?")}');
});
</script>
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
			${_(u"Username")}<br />
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
				<strong>${_(u"Personal privileges")}</strong><br />
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
			<br /><br />
			<h2>${_(u"Login data")}</h2>
			<%
			user_obj.getUserLoginData()
			%>
			% if user_obj.login_data:
			<table class="tablesorter">
			    <thead>
    			    <tr>
                        <th class="{sorter: 'fiDate'}">${_(u"Login")}</th>
                        <th class="{sorter: 'fiDate'}">${_(u"Logout")}</th>
                        <th>${_(u"Ip")}</th>
                        <th>${_(u"User agent")}</th>
    			    </tr>
			    </thead>
			    <tbody>
			    % for login_data in user_obj.login_data:
			        <tr>
			            <td>${helpers.modDateTime(login_data.login_time)}</td>
			            <td>
			                % if login_data.logout_time != None:
                    		    ${helpers.modDateTime(login_data.logout_time)}
                    		% endif
			            </td>
			            <td>${helpers.decodeString(login_data.ip)}</td>
			            <td>${helpers.decodeString(login_data.user_agent)}</td>
			        </tr>
			    % endfor
			    </tbody>
			</table>
			% else:
			${_(u"No logins")}
			% endif
			
		</div>
		<div class="two columns">
			<div id="actionsMenu">
			<ul>
				<li><a href="/settings/users/new/">${_(u"Create")}</a></li>
				<li><a href="/settings/users/edit/${helpers.decodeString(user['id'])}/">${_(u"Edit")}</a></li>
				% if user['id'] != 1:
					% if user['active'] == 1:
					<li><a href="/settings/users/deactivate/${helpers.decodeString(user['id'])}/">${_(u"Deactivate")}</a></li>
					% else:
					<li><a href="/settings/users/activate/${helpers.decodeString(user['id'])}/">${_(u"Activate")}</a></li>
					% endif
					<li><br /><a id="trigger_delete" href="/settings/users/delete/${user['id']}/">${_(u"Delete")}</a></li>
				% endif
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

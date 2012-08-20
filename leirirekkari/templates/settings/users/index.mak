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
	<h1>${_(u"Users")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
			<table id="users" class="tablesorter">
				<thead>
					<tr>
						<th>${_(u"Username")}</th>
						<th>${_(u"Firstname")}</th>
						<th>${_(u"Lastname")}</th>
						<th>${_(u"Email")}</th>
						<th class="{sorter: 'fiDate'}">${_(u"Last login")}</th>
						<th>${_(u"Active")}</th>
						<th class="{sorter: false}">${_(u"Tools")}</th>
					</tr>
				</thead>
				<tbody>
				    % for user in users:
				        ${makerow(user)}
				    % endfor
				</tbody>
			</table>
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



<%def name="makerow(user)">
    <tr>
		<td><a href="/settings/users/view/${user.id}/">${helpers.decodeString(user.username)}</a></td>
		<td>${helpers.decodeString(user.firstname)}</td>
		<td>${helpers.decodeString(user.lastname)}</td>
		<td>${helpers.decodeString(user.email)}</td>
		<td>
		<%
		user_last_login = user.getUserLastLoginData()
		%>
		% if user_last_login != None:
		    ${helpers.modDateTime(user_last_login.login_time)}
		% endif
		</td>
		<td>
		% if user.active == 1:
			${_('Yes')}
		% else:
			${_('No')}
		% endif
		</td>
		<td><a href="/settings/users/edit/${user.id}/">${_(u"Edit")}</a></td>
    </tr>
</%def>

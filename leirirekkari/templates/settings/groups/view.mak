<%
import leirirekkari.helpers.helpers as helpers
%>
<%block name="template_add_styles">
</%block>

<%block name="template_add_js">
<script>
$('#trigger_delete').click(function() {
	return confirm('${_("Are you sure that you want to delete this group?")}');
});
</script>
</%block>

<%block name="template_add_afterbody">

</%block>

<%inherit file="leirirekkari:templates/base.mak"/>
<div id="main_headline" class="twelve columns">
	<h1>${_(u"Group")}&nbsp;${helpers.decodeString(group['name'])}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
			<strong>${_(u"Name")}</strong><br />
			${helpers.decodeString(group['name'])}
			<br /><br />
			% if len(privileges) > 0 and group['privileges'] != None:
			    <%
    			user_privileges = group['privileges'].split('|')
    			%>
				<strong>${_(u"Privileges")}</strong><br />
				% if len(group['privileges']) > 0:
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
					% if group['id'] == 1:
						${_(u"All privileges")}
					% else:
						${_(u"No privileges")}
					% endif
				% endif
			% endif
		</div>
		<div class="two columns">
			<div id="actionsMenu">
			<ul>
				<li><a href="/settings/groups/new/">${_(u"Create")}</a></li>
				% if group['id'] != 1:
				<li><a href="/settings/groups/edit/${group['id']}">${_(u"Edit")}</a></li>
				<li><br /><a id="trigger_delete" href="/settings/groups/delete/${group['id']}/">${_(u"Delete")}</a></li>
				% endif
			</ul>
			</div>
		</div>
	</div>
</div>

<%def name="makerow_privilege(privilege, groupprivileges)">
	% if privilege.id in groupprivileges:
		<li>${_(privilege.name)}</li>
	% endif
</%def>
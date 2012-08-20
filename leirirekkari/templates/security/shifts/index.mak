<%
import pyramid.security as security
import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.participant as participanthelpers
%>
<%block name="template_add_styles">
</%block>

<%block name="template_add_js">
</%block>

<%block name="template_add_afterbody">

</%block>

<%inherit file="leirirekkari:templates/base.mak"/>

<div id="main_headline" class="twelve columns">
	<h1>${_(u"Security shifts")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
        <div class="ten columns">
    		<table id="users" class="tablesorter">
    			<thead>
    				<tr>
    					<th class="{sorter: false}">${_(u"View")}</th>
    					<th class="{sorter: 'fiDate'}">${_(u"Starts")}</th>
    					<th class="{sorter: 'fiDate'}">${_(u"Ends")}</th>
    					<th>${_(u"Leader")}</th>
    					<th class="{sorter: false}">${_(u"Tools")}</th>
    				</tr>
    			</thead>
    			<tbody>
    			    % for shift in shifts:
    			        <tr>
    			            <td><a href="/security/shifts/view/${shift.id}/">${_(u"View")}</a></td>
    			            <td>${helpers.modDateTime(shift.starts)}</td>
    			            <td>${helpers.modDateTime(shift.ends)}</td>
    			            <td>${helpers.decodeString(participanthelpers.getParticipantName(shift.leader_id))}</td>
    			            <td><a href="/security/shifts/edit/${shift.id}/">${_(u"Edit")}</a></td>
    			        </tr>
    			    % endfor
    			</tbody>
    		</table>
    	</div>
    	<div class="two columns">
    		<div id="actionsMenu">
    		<ul>
    			<li><a href="/security/shifts/new/">${_(u"Create")}</a></li>
    		</ul>
    		</div>
    	</div>
	</div>
</div>



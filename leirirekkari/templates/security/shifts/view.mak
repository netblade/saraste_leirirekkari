<%
import leirirekkari.helpers.helpers as helpers
%>
<%block name="template_add_styles">
</%block>

<%block name="template_add_js">
<script>
$('#trigger_delete').click(function() {
	return confirm('${_("Are you sure that you want to delete this logitem?")}');
});
</script>
</%block>

<%block name="template_add_afterbody">

</%block>

<%inherit file="leirirekkari:templates/base.mak"/>
<div id="main_headline" class="twelve columns">
    <h1>${_(u"View shift")}</h1>
</div>
<div id="content_container" class="twelve columns">
    <div id="content" class="row">
        <div class="ten columns">
            <div class="row">
                <div class="six columns">
                    <h2>${_(u"Basic info")}</h2>
                    <strong>${_(u"Starts")}</strong><br />
                    ${helpers.modDateTime(shift.starts)}
                    <br /><br />
                    <strong>${_(u"Ends")}</strong><br />
                    ${helpers.modDateTime(shift.ends)}
                    <br /><br />
                    <strong>${_(u"Notes")}</strong><br />
                    ${helpers.decodeString(shift.notes)}
                    <br /><br />
                </div>
                <div class="six columns">
                    <h2>${_(u"New log item")}</h2>
                    <form method="POST">
                        <label>
                            ${_(u"Log item type")}<br />
                            <select name="event_type">
                                <option value="10">${_('Event type Help')}</option>
                                <option value="20">${_('Event type Security')}</option>
                                <option value="30">${_('Event type Alarm')}</option>
                            </select>
                        </label>
                        <label>
                            ${_(u"Notified by")}<br />
                            <input name="notified_by" type="text" value="${helpers.decodeString(request.user.firstname)} ${helpers.decodeString(request.user.lastname)}" />
                        </label>
                        <label>
                            ${_(u"Task")}<br />
                            <input name="task" type="text" />
                        </label>
                        <label>
                            ${_(u"Description")}<br />
                            <textarea name="content"></textarea>
                        </label>
                        <label>
                            ${_(u"People present")}<br />
                            <textarea name="people_present"></textarea>
                        </label>
                        <label>
                            ${_(u"Started")}<br />
                            <input type="text" name="started" class="datetimepickernow" />
                        </label>
                        <label>
                            ${_(u"Ended")}<br />
                            <input type="text" name="ended" class="datetimepickernow" />
                        </label>
                        <br />
                        <input type="submit" value="${_(u"Create")}" />
                    </form>
                </div>
            </div>
            <div class="row">
                <div class="twelve columns">
                    <h2>${_(u"Log items")}</h2>
                    % if len(logitems) > 0:
                        <table>
                        % for logitem in logitems:
                            <tr>
                                <td valign="top">
                                    <span class="event_type">
                                    % if logitem.event_type == 10:
                                        ${_('Event type Help')}
                                    % elif logitem.event_type == 20:
                                        ${_('Event type Security')}
                                    % elif logitem.event_type == 30:
                                        ${_('Event type Alarm')}
                                    % endif
                                    </span>
                                    ${helpers.modDateTime(logitem.started)}
                                    % if logitem.ended != None and logitem.started != None and logitem.started < logitem.ended:
                                        - <br />${helpers.modDateTime(logitem.ended)}
                                    % endif
                                </td>
                                <td valign="top">
                                    ${helpers.decodeString(logitem.task)}<br />
                                    ${helpers.decodeString(logitem.notified_by)}
                                </td>
                                <td valign="top">
                                    <a href="/security/shifts/logitem/edit/${logitem.id}/">${_("Edit")}</a><br />
                                    <a id="trigger_delete" href="/security/shifts/logitem/delete/${logitem.id}/">${_("Delete")}</a>
                                </td>
                            </tr>
                            <tr>
                                <td align="right">${_(u"Description")}</td>
                                <td colspan="2" valign="top">${helpers.convertLineBreaks(helpers.decodeString(logitem.content))}</td>
                            </tr>
                            <tr>
                                <td align="right">${_(u"People present")}</td>
                                <td colspan="2" valign="top">${helpers.convertLineBreaks(helpers.decodeString(logitem.people_present))}</td>
                            </tr>
                            <tr>
                                <td colspan="3"><hr /></td>
                            </tr>
                        % endfor
                        </table>
                    % else:
                        ${_(u"No items")}
                    % endif
                </div>
            </div>
        </div>
        <div class="two columns">
            <div id="actionsMenu">
            <ul>
                <li><a href="/security/shifts/new/">${_(u"Create")}</a></li>
                <li><a href="/security/shifts/edit/${shift.id}/">${_(u"Edit")}</a></li>
            </ul>
            </div>
        </div>
    </div>
</div>

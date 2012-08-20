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
    <h1>${_(u"Create new shift")}</h1>
</div>
<div id="content_container" class="twelve columns">
    <div id="content" class="row">
        <div class="ten columns">
            <form method="POST" action="">
                <fieldset>
                    <legend>${_(u"Basic info")}</legend>
                    <label>
                        ${_(u"Log item type")}<br />
                        <select name="event_type">
                            % if logitem.event_type == 10:
                            <option selected = selected value="10">${_('Event type Help')}</option>
                            % else:
                            <option value="10">${_('Event type Help')}</option>
                            % endif
                            % if logitem.event_type == 20:
                            <option selected = selected value="20">${_('Event type Security')}</option>
                            % else:
                            <option value="20">${_('Event type Security')}</option>
                            % endif
                            % if logitem.event_type == 30:
                            <option selected = selected value="30">${_('Event type Alarm')}</option>
                            % else:
                            <option value="30">${_('Event type Alarm')}</option>
                            % endif
                        </select>
                    </label>
                    <label>
                        ${_(u"Notified by")}<br />
                        <input name="notified_by" type="text" value="${helpers.decodeString(logitem.notified_by)}" />
                    </label>
                    <label>
                        ${_(u"Task")}<br />
                        <input name="task" type="text" value="${helpers.decodeString(logitem.task)}" />
                    </label>
                    <label>
                        ${_(u"Description")}<br />
                        <textarea name="content">${helpers.decodeString(logitem.content)}</textarea>
                    </label>
                    <label>
                        ${_(u"People present")}<br />
                        <textarea name="people_present">${helpers.decodeString(logitem.people_present)}</textarea>
                    </label>
                    <label>
                        ${_(u"Started")}<br />
                        <input type="text" name="started" class="datetimepicker" value="${helpers.modDateTime(logitem.started)}" />
                    </label>
                    <label>
                        ${_(u"Ended")}<br />
                        <input type="text" name="ended" class="datetimepicker" value="${helpers.modDateTime(logitem.ended)}" />
                    </label>
                    <br />
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
                <li><a href="/security/shifts/new/">${_(u"Create")}</a></li>
            </ul>
            </div>
        </div>
    </div>
</div>

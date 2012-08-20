<%
import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.organization as organizationhelpers
import leirirekkari.helpers.participant as participanthelpers
import leirirekkari.helpers.medical as medicalhelpers
%>
<%block name="template_add_styles">
</%block>

<%block name="template_add_js">
</%block>

<%block name="template_add_afterbody">

</%block>

<%inherit file="leirirekkari:templates/base.mak"/>
<div id="main_headline" class="twelve columns">
	<h1>${_(u"View card")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="six columns">
            % if len(stats['reason_stats']) > 0:
            <h2>${_(u"Reasons")}</h2>
            <table class="tablesorter">
            <thead>
                <tr>
                    <th>${_('Title')}</th>
                    <th>${_('Count')}</th>
                </tr>
            </thead>
            <tbody>
                % for key, value in enumerate(stats['reason_stats']):
                <tr>
                    <td>${helpers.decodeString(medicalhelpers.getReasonTitle(value))}</td>
                    <td>${stats['reason_stats'][value]}</td>
                </tr>
                % endfor
            </tbody>
            </table>
            % endif
            <br /><br />
            % if len(stats['treatmenttypes_stats']) > 0:
            <h2>${_(u"Treatment type")}</h2>
            <table class="tablesorter">
            <thead>
                <tr>
                    <th>${_('Title')}</th>
                    <th>${_('Count')}</th>
                </tr>
            </thead>
            <tbody>
                % for key, value in enumerate(stats['treatmenttypes_stats']):
                <tr>
                    <td>${helpers.decodeString(medicalhelpers.getTreatmentTypeTitle(value))}</td>
                    <td>${stats['treatmenttypes_stats'][value]}</td>
                </tr>
                % endfor
            </tbody>
            </table>
            % endif
            <br /><br />
            % if len(stats['methodsofarrival_stats']) > 0:
            <h2>${_(u"Method of arrival")}</h2>
            <table class="tablesorter">
            <thead>
                <tr>
                    <th>${_('Title')}</th>
                    <th>${_('Count')}</th>
                </tr>
            </thead>
            <tbody>
                % for key, value in enumerate(stats['methodsofarrival_stats']):
                <tr>
                    <td>${helpers.decodeString(medicalhelpers.getMethodOfArrivalTitle(value))}</td>
                    <td>${stats['methodsofarrival_stats'][value]}</td>
                </tr>
                % endfor
            </tbody>
            </table>
            % endif
            <br /><br />
    	</div>
		<div class="four columns">
		    <form method="post" action="">
		        <label>${_(u'Start')}<br />
		        <input name="start" class="datetimepicker" value="${helpers.decodeString(start)}" type="text" />
		        </label><br /><br />
		        <label>${_(u'End')}<br />
		        <input name="end" class="datetimepicker" value="${helpers.decodeString(end)}" type="text" />
		        </label><br /><br />
		        <input type="submit" value="${_(u'Update view')}">
		    </form>
		</div>
		<div class="two columns">
			<div id="actionsMenu">
			<ul>
				<li><a href="/medical/card/list/">${_(u"Cards")}</a></li>
				<li><a href="/medical/statistics/">${_(u"Statistics")}</a></li>
				<li><a href="/medical/settings/">${_(u"Settings")}</a></li>
			</ul>
			</div>
		</div>
	</div>
</div>

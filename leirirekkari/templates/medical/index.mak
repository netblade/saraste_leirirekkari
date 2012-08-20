<%
import pyramid.security as security
import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.organization as organizationhelpers

%>
<%block name="template_add_styles">
</%block>

<%block name="template_add_js">
</%block>

<%block name="template_add_afterbody">

</%block>

<%inherit file="leirirekkari:templates/base.mak"/>

<div id="main_headline" class="twelve columns">
	<h1>${_(u"Medical")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
		    <div class="row">
        		<div class="six columns">
        		    <h3>${_(u"Go to card")}</h3>
    				<form id="medical_search_card" method="post" action="#">
    					<label for="haku">${_(u"Search by card id or patient name or membernumber")}</label>
    					<input name="medical_search_card_str" id="medical_search_card_str" type="text" /><br /><br />
    					<input type="submit" value="${_(u"Search")}" style="width: 175px;" />
    				</form>
        		</div>
        		<div class="six columns">
        		    <div id="medical_search_card_results">
        			</div>
        		</div>
        	</div>
		    <div class="row">
        		<div class="four columns">
    				<h3>${_(u"Search participant")}</h3>
    				<form id="medical_search_participant" method="post" action="#">
    					<label for="haku">${_(u"Search by text")}</label>
    					<input name="medical_search_participant_str" id="medical_search_participant_str" type="text" /><br /><br />
    					<input type="submit" value="${_(u"Search")}" style="width: 175px;" />
    				</form>
        		</div>
        		<div class="eight columns">
        		    <div id="medical_search_participant_results">
        			</div>
        		</div>
        	</div>
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

<%
import pyramid.security as security
%>
<%block name="template_add_styles">
</%block>

<%block name="template_add_js">
</%block>

<%block name="template_add_afterbody">

</%block>

<%inherit file="leirirekkari:templates/base.mak"/>

<div id="main_headline" class="twelve columns">
	<h1>${_(u"Security")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
		    <div class="row">
		        <div class="twelve columns">
    			    <ul id="frontpage_links">
        				<li><a href="/security/shifts/"><img src="${request.static_url('leirirekkari:static/img/icons/shift.png')}" alt="" /><div class="text_container">${_(u"Shifts")}</div></a></li>
        			</ul>
        			<div class="clearer"></div>
        	    </div>
    	    </div>
    	    <div class="row">
		        <div class="twelve columns"><br /><br />
    	            <div id="search_container">
            			<form method="post" action="/security/participant/search/">
            				<label for="searchstr">${_(u"Search by text")}</label>
            				<div class="row">
            				    <div class="six columns">
            				        <input name="searchstr" id="searchstr" type="text" value=""  />
            				        <input type="submit" value="${_(u"Search")}" style="width: 175px; margin-top: 6px;" />
            				    </div>
            				</div>
            			</form>
            	    </div>
            	</div>
            </div>
		</div>
		<div class="two columns">

			<div class="clearer"></div>
		</div>
	</div>
</div>
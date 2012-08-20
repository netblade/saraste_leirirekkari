
<%block name="template_add_styles">
</%block>

<%block name="template_add_js">
</%block>

<%block name="template_add_afterbody">

</%block>

<%inherit file="base.mak"/>
<div id="main_headline" class="twelve columns">
	<h1>${_(u"Camp registry")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="twelve columns">
		    % if browser_error:
			    <div id="login_container">
			        <h2>${_("You cant use Internet Explorer or Safari for this site, please install Chrome or Firefox.")}</h2>
			        <br /><br />
			        <a target="_blank" href="https://www.google.com/chrome">Chrome</a><br />
			        <a target="_blank" href="http://getfirefox.com">Firefox</a><br />
			    </div>
		    % elif device_error:
			    <div id="login_container">
			        <h2>${_("You cant use your device for this site Please login from a device thats a bit more secure")}</h2>
			    </div>
		    % else:
			    <h2>${_(u"Page not found")}</h2>
			    <div class="clearer"></div>
			    <br /><br /><br /><br /><br /><br /><br />
			% endif
		</div>
	</div>
</div>
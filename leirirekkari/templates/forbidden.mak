
<%block name="template_add_styles">
	<link rel="stylesheet" href="${request.static_url('leirirekkari:static/css/login.css')}">
</%block>


<%inherit file="base.mak"/>
<div id="main_headline" class="twelve columns">
	<h1>${_(u"Access denied")}</h1>
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
			<div id="login_container">
				<form method="post" action="/login/">
					<label for="login">${_(u"Login")}</label>
					<input type="text" name="login" id="login" value="${login}" /><br /><br />
					<label for="login">${_(u"Password")}</label>
					<input type="password" name="password" id="password" /><br /><br />
					<input class="submit" type="submit" value="${_(u"Log in")}" />
				</form>
			</div>
			% endif
		</div>
	</div>
</div>
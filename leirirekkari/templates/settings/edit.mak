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
    % if setting['locked_key']:
        <h1>${_(u"Edit setting")}&nbsp;${setting['setting_key']}</h1>
    % else:
        <h1>${_(u"Edit setting")}&nbsp;${_('setting: ' + setting['setting_key'])}</h1>
    % endif
	
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
			<form method="POST" action="">
				<fieldset>
					<legend>${_(u"Setting")}</legend>
					% if setting['locked_key']:
					    <strong>${_(u"Key")}:</strong> ${setting['setting_key']}<br />
					    <strong>${_(u"Use")}:</strong> ${_('setting: ' + setting['setting_key'])}<br /><br />
					% else:
					<label>
					    ${_(u"Key")}<br />
					    <input type="text" name="setting_key" value="${helpers.decodeString(setting['setting_key'])}" />
					</label>
					% endif
					<label>
						${_(u"Value")}<br />
						<textarea name="setting_value">${helpers.decodeString(setting['setting_value'])}</textarea>
					</label>
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
				<li><a href="/settings/new/">${_(u"Create")}</a></li>
			</ul>
			</div>
		</div>
	</div>
</div>

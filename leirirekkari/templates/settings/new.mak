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
	<h1>${_(u"Create new setting")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
			<form method="POST" action="">
				<fieldset>
					<legend>${_(u"Setting")}</legend>
					<label>
						${_(u"Key")}<br />
						<input type="text" name="setting_key" value="${helpers.decodeString(setting['setting_key'])}" />
					</label>
					<label>
						${_(u"Value")}<br />
						<textarea name="setting_value">${helpers.decodeString(setting['setting_value'])}</textarea>
					</label>
				</fieldset>
				<fieldset>
					<input type="submit" value="${_(u"Create")}" />
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

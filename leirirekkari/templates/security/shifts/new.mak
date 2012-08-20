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
						${_(u"Starts")}<br />
						<input type="text" name="starts" class="datetimepicker" value="${helpers.decodeString(shift.starts)}" />
					</label>
					<label>
						${_(u"Ends")}<br />
						<input type="text" name="ends" class="datetimepicker" value="${helpers.decodeString(shift.ends)}" />
					</label>
					<label>
						${_(u"Notes")}<br />
						<textarea name="notes">${helpers.decodeString(shift.notes)}</textarea>
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
				<li><a href="/security/shifts/new/">${_(u"Create")}</a></li>
			</ul>
			</div>
		</div>
	</div>
</div>

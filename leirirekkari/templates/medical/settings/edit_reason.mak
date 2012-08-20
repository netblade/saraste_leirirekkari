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
	<h1>${_(u"Edit reason")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
			<form method="POST" action="">
				<fieldset>
					<legend>${_(u"Reason")}</legend>
					<label>
						${_(u"Title")}<br />
						<input type="text" name="title" value="${helpers.decodeString(reason.title)}" />
					</label>
					<label>
						${_(u"Description")}<br />
						<textarea name="description">${helpers.decodeString(reason.description)}</textarea>
					</label>
				</fieldset>
				<fieldset>
					<input type="submit" value="${_(u"Save")}" />
					<input type="reset" value="${_(u"Reset")}" />
				</fieldset>
			</form>
		</div>
		<div class="two columns">
		</div>
	</div>
</div>

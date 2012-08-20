<%
import leirirekkari.helpers.helpers as helpers
%>
<%block name="template_add_styles">
</%block>

<%block name="template_add_js">
% if importer.rows_read < importer.total_rows: 
<script>
$(document).ready(function () {
    setTimeout('reloadImporterPage()', ${importer.delay_seconds}000)
});

function reloadImporterPage() {
    document.location.href = document.location.href;
}
</script>
% endif
</%block>

<%block name="template_add_afterbody">

</%block>

<%inherit file="leirirekkari:templates/base.mak"/>
<div id="main_headline" class="twelve columns">
	<h1>${_(u"Running importer")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
		    % if importer.rows_read >= importer.total_rows: 
                <h2>${_(u"Importer allready run. Imported ${itemcount} items.", mapping={'itemcount':importer.successfull_imports})}</h2>
			% endif
			% if len(messages) > 0:
				<div id="status_messages">
				% for message in messages:
					${message}<br />
				% endfor
				</div>
			% endif
		</div>
	</div>
</div>

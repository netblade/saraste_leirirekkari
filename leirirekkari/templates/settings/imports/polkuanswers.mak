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
	<h1>${_(u"Import polku answers")}</h1>
</div>
<div id="content_container" class="twelve columns">
	<div id="content" class="row">
		<div class="ten columns">
			<form method="POST" action="" accept-charset="utf-8" enctype="multipart/form-data">
			    <fieldset>
        			<legend>${_(u"Settings")}</legend>
        			<label>
        				${_(u"Delimeter")}<br />
                        <select name="delimeter">
                            % if default_settings['import_default_delimeter'] == ';':
                                <option value=";" selected="selected">;</option>
                            % else:
                                <option value=";">;</option>
                            % endif
                            % if default_settings['import_default_delimeter'] == ',':
                                <option value="," selected="selected">,</option>
                            % else:
                                <option value=",">,</option>
                            % endif
                        </select>
        			</label>
        			<label>
        				${_(u"Headers")}<br />
                        <select name="has_headers">
                            % if default_settings['import_default_has_headers'] == '1':
                                <option value="1" selected="selected">${_('Yes')}</option>
                            % else:
                                <option value="1">${_('Yes')}</option>
                            % endif
                            % if default_settings['import_default_has_headers'] == '0':
                                <option value="0" selected="selected">${_('No')}</option>
                            % else:
                                <option value="0">${_('No')}</option>
                            % endif
                        </select>
        			</label>
        			<label>
        				${_(u"Delay between import runs")}<br />
                        <input type="text" name="delay_seconds" value="${default_settings['import_default_delay_seconds']}" />
        			</label>
        			<label>
        				${_(u"Rows per run")}<br />
                        <input type="text" name="rows_per_run" value="${default_settings['import_default_rows_per_run']}" />
        			</label>
        		</fieldset>
				<fieldset>
					<legend>${_(u"File")}</legend>
					<label>
						${_(u"CSV-file")}<br />
						<input type="file" name="file_to_import" />
					</label>
				</fieldset>
				<fieldset>
					<input type="submit" value="${_(u"Import")}" />
					<input type="reset" value="${_(u"Reset")}" />
				</fieldset>
			</form>
		</div>
	</div>
</div>

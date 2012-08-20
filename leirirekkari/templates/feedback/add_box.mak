
<%block name="template_add_styles">
</%block>

<%block name="template_add_js">
</%block>

<%block name="template_add_afterbody">
</%block>

<%inherit file="leirirekkari:templates/base_clean.mak"/>
<h2>${_(u"Feedback")}</h2>
${_(u"Send feedback about the leirirekkari. Or bug report. Or wish list item. Or just say hey")}
<form method="post" action="/feedback/add/box/submit/">
    <fieldset>
        <legend>Feedback</legend>
        <label>
            ${_(u"Type")}<br>
            <select name="feedback_type">
                <option value="0">--</option>
                <option value="1">${_(u"Feedback")}</option>
                <option value="2">${_(u"Bug report")}</option>
                <option value="3">${_(u"Wish list item")}</option>
                <option value="4">${_(u"Hey")}</option>
            </select>
        </label>
        <br>
        <label>
            ${_(u"Title")}<br>
            <input type="text" name="feedback_title" />
        </label>
        <label>
            ${_(u"Content")}<br>
            <textarea name="feedback_description"></textarea>
        </label>
        <input type="submit" value="${_(u"Send")}" />
    </fieldset>
</form>
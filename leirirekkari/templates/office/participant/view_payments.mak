<%
import pyramid.security as security

import leirirekkari.helpers.helpers as helpers
import leirirekkari.helpers.organization as organizationhelpers
import leirirekkari.helpers.status as statushelpers

%>
<%block name="template_add_styles">
</%block>

<%block name="template_add_js">
</%block>

<%block name="template_add_afterbody">

</%block>

<%inherit file="leirirekkari:templates/base.mak"/>

<div id="main_headline" class="twelve columns">
    <h1>${_(u"Participant")} ${helpers.decodeString(participant.firstname)} ${helpers.decodeString(participant.lastname)}, ${_(u"Payments")}</h1>
</div>
<div id="content_container" class="twelve columns">
    <div id="content" class="row">
        <div class="ten columns">
            <h2>${_(u"Basic info")}</h2>
            <div class="row">
                <div class="six columns">
                    <strong>${_(u"First name")}</strong><br />
                    ${helpers.decodeString(participant.firstname)}
                    <br /><br />
                    <strong>${_(u"Last name")}</strong><br />
                    ${helpers.decodeString(participant.lastname)}
                    <br /><br />
                    <strong>${_(u"Nickname")}</strong><br />
                    ${helpers.decodeString(participant.nickname)}
                    <br /><br />
                    <strong>${_(u"Member number")}</strong><br />
                    ${helpers.decodeString(participant.member_no)}
                    <br /><br />
                    <strong>${_(u"Booking no")}</strong><br />
                    <%
                    booking_no = helpers.decodeString(participant.booking_no).strip('|')
                    booking_no = booking_no.replace('|', ', ')
                    %>
                    ${booking_no}
                    <br /><br />
                </div>
                <div class="six columns">
                    % if len(participant.address_data) > 0:
                        <h2>${_(u"Address")}</h2>
                        ${_(u"Street address")}<br />
                        ${helpers.decodeString(participant.address_data[0].street)}<br /><br />
                        ${_(u"Postal code")}<br />
                        ${helpers.decodeString(participant.address_data[0].postalcode)}<br /><br />
                        ${_(u"City")}<br />
                        ${helpers.decodeString(participant.address_data[0].city)}<br /><br />
                        ${_(u"Country")}<br />
                        ${helpers.decodeString(participant.address_data[0].country)}<br />
                    % endif
                </div>
            </div>
            <hr />
            <div class="row">
                <div class="twelve columns">
                    % if len(participant.payment_data) > 0:
                    <% 
                        total_paid = 0
                        total_sum = 0
                        to_pay = 0
                    %>
                        <table class="tablesorter">
                            <thead>
                                <tr>
                                    <th>${_(u"Title")}</th>
                                    <th>${_(u"Euros")}</th>
                                    <th>${_(u"Note")}</th>
                                    <th>${_(u"Paid")}</th>
                                    <th>${_(u"Send invoice")}</th>
                                    % if security.has_permission('office_participant_edit', request.context, request):
                                    <th class="{sorter: false}"></th>
                                    % endif
                                </tr>
                            </thead>
                            <tbody>
                                % for payment_data in participant.payment_data:
                                <%
                                total_sum += payment_data.euros
                                %>
                                <tr>
                                    <td class="payment_title">${helpers.decodeString(payment_data.title)}</td>
                                    <td class="payment_euros"><span>${helpers.decodeString(payment_data.euros)}</span>&nbsp;&euro;</td>
                                    <td class="payment_notes"><span style="display:none;">${helpers.decodeString(payment_data.note)}</span>${helpers.convertLineBreaks(helpers.decodeString(payment_data.note))}</td>
                                    <td class="payment_paid">
                                        % if payment_data.paid:
                                        <%
                                        total_paid += payment_data.euros
                                        %>
                                            <span style="display: none;">1</span>
                                            ${_(u"Yes")}
                                        % else:
                                        <%
                                        to_pay += payment_data.euros
                                        %>
                                            <span style="display: none;">0</span>
                                            ${_(u"No")}
                                        % endif
                                    </td>
                                    <td class="payment_send_invoice">
                                        % if payment_data.send_invoice:
                                            <span style="display: none;">1</span>
                                            ${_(u"Yes")}
                                        % else:
                                            <span style="display: none;">0</span>
                                            ${_(u"No")}
                                        % endif
                                    </td>
                                    <td>
                                        % if security.has_permission('office_participant_edit', request.context, request):
                                        <a class="button edit_payment" id="edit_payment_button_${str(payment_data.id)}" href="#">${_(u"Edit")}</a>
                                        % endif
                                    </td>
                                </tr>
                                % endfor
                            </tbody>
                            <tr>
                                <td style="border-top: 2px solid #000000;text-align: right;">${_(u"Total sum:")}</td>
                                <td style="border-top: 2px solid #000000;"><strong>${total_sum}&nbsp;&euro;</strong></td>
                                <td style="border-top: 2px solid #000000;text-align: right;">${_(u"Total paid:")}</td>
                                <td style="border-top: 2px solid #000000;"><strong>${total_paid}&nbsp;&euro;</strong></td>
                                <td style="border-top: 2px solid #000000;"></td>
                                <td style="border-top: 2px solid #000000;"></td>
                            </tr>
                            % if to_pay > 0:
                            
                            <tr>
                                <td style="border-top: 2px solid #000000;text-align: right;">${_(u"Still to pay:")}</td>
                                <td style="border-top: 2px solid #000000;"><strong>${to_pay}&nbsp;&euro;</strong></td>
                                <td style="border-top: 2px solid #000000;text-align: right;"></td>
                                <td style="border-top: 2px solid #000000;"></td>
                                <td style="border-top: 2px solid #000000;"></td>
                                <td style="border-top: 2px solid #000000;"></td>
                            </tr>
                            % endif
                        </table>
                        <br><br>
                    % else:
                        ${_(u"No payment data")}
                    % endif 
                </div>
            </div>
            % if security.has_permission('office_participant_edit', request.context, request):
            <div class="row">
                <div class="twelve columns">
                    <form method="post" action="">
                        <fieldset id="edit_payment">
                            <input type="hidden" name="payment_id" id="payment_id" value="0">
                            <legend>${_(u"New payment")}</legend>
                            <div style="display: none;" id="edit_payment_str">${_(u"Edit payment")}</div>
                            <div style="display: none;" id="new_payment_str">${_(u"New payment")}</div>
                            <label>
                                ${_(u"Title")}<br />
                                <input type="text" id="payment_title" name="payment_title" />
                            </label>
                            <label>
                                ${_(u"Euros")}<br />
                                <input type="number" id="payment_euros" step="0.01" name="payment_euros" />
                            </label>
                            <label>
                                ${_(u"Note")}<br />
                                <textarea id="payment_note" name="payment_note"></textarea>
                            </label>
                            <label>
                                ${_(u"Paid")}<br />
                                <select name="payment_paid" id="payment_paid">
                                    <option value="0">${_(u"No")}</option>
                                    <option value="1">${_(u"Yes")}</option>
                                </select>
                            </label>
                            <label>
                                ${_(u"Send invoice")}<br />
                                <select name="payment_send_invoice" id="payment_send_invoice">
                                    <option value="0">${_(u"No")}</option>
                                    <option value="1">${_(u"Yes")}</option>
                                </select>
                            </label>
                        </fieldset>
                        <fieldset>
                            <input type="submit" value="${_(u"Save")}" />
                            <input id="reset_payment" type="reset" value="${_(u"Reset")}" />
                        </fieldset>
                    </form>
                </div>
            </div>
            % endif
        </div>
        <div class="two columns">
            <div id="actionsMenu">
            <ul>
                <li><a href="/office/participant/view/${participant.id}/">${_(u"View participant")}</a></li>
                <li><a href="/office/participant/edit/${participant.id}/">${_(u"Edit participant")}</a></li>
                
            </ul>
            </div>
        </div>
    </div>
</div>

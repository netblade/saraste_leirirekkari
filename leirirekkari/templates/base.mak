<%
import pyramid.security as security
import leirirekkari.helpers.helpers as helpers
%>

<!doctype html>
<html class="no-js" lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

    <title>${_(u"Camp registry")}</title>
    <meta name="description" content="">
    <meta name="author" content="">

    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="robots" content="noindex,nofollow" />

    <link rel="Shortcut icon" href="${request.static_url('leirirekkari:static/img/favicon.ico')}" type="image/x-icon" />

    <!-- CSS concatenated and minified via ant build script-->
    <link rel="stylesheet" href="${request.static_url('leirirekkari:static/css/libs/normalize.css')}">
    <!-- end CSS-->
    
    <link rel="stylesheet" href="${request.static_url('leirirekkari:static/css/libs/ui-lightness/jquery-ui-1.8.21.custom.css')}">
    <link rel="stylesheet" href="${request.static_url('leirirekkari:static/css/libs/jquery-ui-timepicker-addon.css')}">
    <link rel="stylesheet" href="${request.static_url('leirirekkari:static/css/libs/fancybox/jquery.fancybox.css')}">

    <!-- Foundation -->
    <link rel="stylesheet" href="${request.static_url('leirirekkari:static/css/libs/foundation/foundation.css')}">

    <link rel="stylesheet" href="${request.static_url('leirirekkari:static/css/style.css')}">
    <link rel="stylesheet" href="${request.static_url('leirirekkari:static/css/forms.css')}">
    <link rel="stylesheet" href="${request.static_url('leirirekkari:static/css/tablesorter.css')}">
    
    <%block name="template_add_styles">
    </%block>
    <link rel="stylesheet" href="${request.static_url('leirirekkari:static/css/print.css')}" media="print">
</head>

<body>
<%block name="template_add_afterbody">

</%block>
    <div id="loader" style="display: none;"><img src="${request.static_url('leirirekkari:static/img/icons/ajax-loader.gif')}" alt="" /></div>
    <div id="flash_messages">
        % if len(request.session.peek_flash('info')) > 0:
            <%
            messages = request.session.pop_flash('info')
            %>
            % for message in messages:
        <div class="flash_message info">
            <div class="icon">&nbsp;</div>
            <div class="text">${helpers.literal(message)}</div>
        </div>
            % endfor
        % endif
        % if len(request.session.peek_flash('success')) > 0:
            <%
            messages = request.session.pop_flash('success')
            %>
            % for message in messages:
        <div class="flash_message success">
            <div class="icon">&nbsp;</div>
            <div class="text">${helpers.literal(message)}</div>
        </div>
            % endfor
        % endif
        % if len(request.session.peek_flash('error')) > 0:
            <%
            messages = request.session.pop_flash('error')
            %>
            % for message in messages:
        <div class="flash_message error">
            <div class="icon">&nbsp;</div>
            <div class="text">${helpers.literal(message)}</div>
        </div>
            % endfor
        % endif
    </div>

    <div id="wrapper">
        <div id="container">
            <div id="header_container">
                <div id="header" class="row" role="banner">
                    <div class="twelve columns">
                        <div style="text-align: right; float: right">
                            <ul class="header_links" id="header_links_right">
                                % if security.has_permission('view', request.context, request):
                                <li><a href="/settings/"><div class="icon_container"><img src="${request.static_url('leirirekkari:static/img/icons/settings.png')}" alt="" /></div><div class="text_container">${_(u"Settings")}</div></a></li>
                                <li><a href="/logout/"><div class="icon_container"><img src="${request.static_url('leirirekkari:static/img/icons/log_out.png')}" alt="" /></div><div class="text_container">${_(u"Log out")}</div></a></li>
                                % endif
                            </ul>
                        </div>
                        <div>
                            <ul class="header_links" id="header_links_left">
                                <li><a href="/">${_(u"Home")}<br /><img src="${request.static_url('leirirekkari:static/img/tmp/Logo_saraste_hamy_200px.png')}" width="40" /></a></li>
                                % if security.has_permission('office_view', request.context, request):
                                <li><a href="/office/"><div class="icon_container"><img src="${request.static_url('leirirekkari:static/img/icons/office.png')}" alt="" /></div><div class="text_container">${_(u"Office")}</div></a></li>
                                % endif
                                % if security.has_permission('security_view', request.context, request):
                                <li><a href="/security/"><div class="icon_container"><img src="${request.static_url('leirirekkari:static/img/icons/security.png')}" alt="" /></div><div class="text_container">${_(u"Security")}</div></a></li>
                                % endif
<!--
                                % if security.has_permission('programme_view', request.context, request):
                                <li><a href="/programme/"><div class="icon_container"><img src="${request.static_url('leirirekkari:static/img/icons/programme.png')}" alt="" /></div><div class="text_container">${_(u"Programme")}</div></a></li>
                                % endif
                                -->
                                % if security.has_permission('kitchen_view', request.context, request):
                                <li><a href="/kitchen/"><div class="icon_container"><img src="${request.static_url('leirirekkari:static/img/icons/kitchen.png')}" alt="" /></div><div class="text_container">${_(u"Kitchen")}</div></a></li>
                                % endif

                                % if security.has_permission('medical_view', request.context, request):
                                <li><a href="/medical/"><div class="icon_container"><img src="${request.static_url('leirirekkari:static/img/icons/hospital.png')}" alt="" /></div><div class="text_container">${_(u"Medical")}</div></a></li>
                                % endif
                            </ul>
                        </div>
                    </div>  
                </div>
            </div>
            <div id="main_container">
                <div id="breadcrumb" class="row" role="main">
                    <div id="breadcrumb_content">
                        <div class="twelve columns">
                        <%
                        counter = 1
                        length = len(request.bread)
                        %>
                        % for link in request.bread:
                            % if counter > 1:
                            &raquo;
                            % endif
                            % if counter == length and counter > 1:
                            <span>${helpers.literal(link['text'])}</span>
                            % else:
                            <a href="${helpers.literal(link['url'])}">${helpers.literal(link['text'])}</a>
                            % endif
                            
                            <% counter += 1 %>
                        % endfor
<!--                            <a href="#">${_(u"Frontpage")}</a><div class="breadcrumb_separator">&raquo;</div><a href="security_index.html">${_(u"Security")}</a>-->
                        </div>
                    </div>
                </div>
                <div id="main" class="row" role="main">
                    ${self.body()}
                </div>
            </div>
        </div> <!--! end of #container -->
    </div>
    <div class="clearer"></div>
    <div id="footer_container">
        <div id="footer" class="row">
            <div id="footer_content">
                <div class="six columns">
                    &copy; <a href="mailto:netblade@iki.fi">NetBlade</a>
                </div>
                <div class="six columns">
                    % if security.has_permission('view', request.context, request):
                    <a href="/feedback/add/box/" id="feedback_opener" data-fancybox-type="iframe">${_(u"Feedback")}</a>
                    % endif
                </div>
            </div>
        </div>
    </div>
    <script src="${request.static_url('leirirekkari:static/js/libs/foundation/modernizr.foundation.js')}"></script>
    
    <script src="${request.static_url('leirirekkari:static/js/libs/jquery-1.7.2.min.js')}"></script>
    <script src="${request.static_url('leirirekkari:static/js/libs/jquery-ui-1.8.16.custom.min.js')}"></script>
    <script src="${request.static_url('leirirekkari:static/js/libs/jquery.ui.datepicker-fi.js')}"></script>

    <script src="${request.static_url('leirirekkari:static/js/libs/jquery-ui-timepicker-addon.js')}"></script>
    
    <!-- scripts concatenated and minified via ant build script-->
    <script defer src="${request.static_url('leirirekkari:static/js/libs/plugins.js')}"></script>
    
    
    <script src="${request.static_url('leirirekkari:static/js/libs/jquery.autogrowtextarea.js')}"></script>

    <script src="${request.static_url('leirirekkari:static/js/libs/jquery.scrollTo-1.4.2-min.js')}"></script>
    <script src="${request.static_url('leirirekkari:static/js/libs/jquery.fancybox.pack.js')}"></script>
    
    
    <!-- Foundation -->

    <script src="${request.static_url('leirirekkari:static/js/libs/foundation/foundation.js')}"></script>

    <script src="${request.static_url('leirirekkari:static/js/style_items.js')}"></script>
    <script src="${request.static_url('leirirekkari:static/js/medical.js')}"></script>
    
    <!-- Tablesorter -->

    <script src="${request.static_url('leirirekkari:static/js/libs/jquery.tablesorter/jquery.metadata.js')}"></script>
    <script src="${request.static_url('leirirekkari:static/js/libs/jquery.tablesorter/addons/pager/jquery.tablesorter.pager.js')}"></script>
    <link rel="stylesheet" href="${request.static_url('leirirekkari:static/js/libs/jquery.tablesorter/addons/pager/jquery.tablesorter.pager.css')}">
    <script src="${request.static_url('leirirekkari:static/js/libs/jquery.tablesorter/jquery.tablesorter.min.js')}"></script>


    <%block name="template_add_js">
    
    </%block>
    
    <!-- end scripts-->
    <!--[if lt IE 7 ]>
        <script src="//ajax.googleapis.com/ajax/libs/chrome-frame/1.0.3/CFInstall.min.js"></script>
        <script>window.attachEvent('onload',function(){CFInstall.check({mode:'overlay'})})</script>
    <![endif]-->
    
</body>
</html>

<%
import pyramid.security as security
import leirirekkari.helpers.helpers as helpers
%>

<!doctype html>
<html class="no-js" lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

    <title>${_(u"Camp registry")}</title>
    <meta name="description" content="">
    <meta name="author" content="">

    <meta name="viewport" content="width=device-width,initial-scale=1">

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

<body class="clean_body">
<%block name="template_add_afterbody">

</%block>
    ${self.body()}
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

var stop_flash_hides = false;
$(document).ready(function () {
    $.datepicker.setDefaults($.datepicker.regional['fi']);
    $.datepicker.setDefaults({
        dateFormat: "dd.mm.yy"
    });
    $('.header_links li').hover(
        function(){
            $('.icon_container img', this).show();
            $(this).animate({marginTop: "0px"}, 500 );
        },
        function(){
            $(this).animate({marginTop: "-40px"}, 500, function(){
                $('.icon_container img', this).hide();
            });
        }
        
    );
    
    $('#add_search_row').click(function() {
        var content = $('#additional_search_null_row_container').html();
        $('#raportti_generator_container').append(content);
        $('.remove_additional_search_row').click(function() {
            $(this).parent('.search_input_container').parent('.additional_search_row').remove();
            return false;
        });
        return false;
    });
    
    var content = $('#additional_search_null_row_container').html();
    $('#raportti_generator_container').append(content);
    $('.remove_additional_search_row').click(function() {
        $(this).parent('.search_input_container').parent('.additional_search_row').remove();
        return false;
    });
    
    $('#add_language_row').click(function() {
        var content = $('#language_skill_row_null').html();
        $('#language_skills_container').append(content);
        $('.remove_langskill_row').click(function() {
            $(this).parent('.remove_langskill_row_container').parent('.language_skill_row').remove();
            return false;
        });
        return false;
    });
    
    $('#add_phone_row').click(function() {
        var content = $('#phone_row_null').html();
        $('#phones_container').append(content);
        $('.remove_phone_row').click(function() {
            $(this).parent('.remove_phone_row_container').parent('fieldset').parent('.phone_row').remove();
            return false;
        });
        return false;
    });
    
    $('#add_metadata_row').click(function() {
        var content = $('#metadata_row_null').html();
        $('#metadatas_container').append(content);
        $('.remove_metadata_row').click(function() {
            $(this).parent('.remove_metadata_row_container').parent('fieldset').parent('.metadata_row').remove();
            return false;
        });
        return false;
    });
    
    $('#add_presence_row').click(function() {
        var content = $('#presence_row_null').html();
        var row_id_time = new Date().getTime();
        var row_id = 'presence_row_'+row_id_time+'_row';
        content = content.replace('presence_row_null_row', row_id);
        content = content.replace('presence_starts_null', 'presence_starts_' + row_id_time);
        content = content.replace('presence_ends_null', 'presence_starts_' + row_id_time);
        $('#presences_container').append(content);
        $('.remove_presence_row').click(function() {
            $(this).parent('.remove_presence_row_container').parent('fieldset').parent('.presence_row').remove();
            return false;
        });
        var row = $('#'+row_id);
        var obj = $('.presence_start', $(row));
        $('.presence_starts_' + row_id_time).datetimepicker({
            dateFormat: "dd.mm.yy",
            timeFormat: 'hh:mm',
            hour: 12
        });
        $('.presence_ends_' + row_id_time).datetimepicker({
            dateFormat: "dd.mm.yy",
            timeFormat: 'hh:mm',
            hour: 12
        });

        return false;
    });
    
    var content = $('#search_row').html();
    $('#raportti_generator_container').append(content);
    
    $('.remove_row').click(function() {
        $(this).parent('.haku_input_container').parent('.haku_input_container_2').remove();
        return false;
    });

    $.tablesorter.defaults.widgets = ['zebra'];
    $.tablesorter.addParser({
        // set a unique id
        id: 'fiDate',
        is: function(s) {
            // return false so this parser is not auto detected
            return false;
        },
        format: function(s) {
            // format your data for normalization
            s = s.replace(/\./g,"_");
            s = s.replace(/(\d{1,2})[\_](\d{1,2})[\_](\d{4})/, "$3/$2/$1");
            date = new Date(s).getTime();
            return $.tablesorter.formatFloat(date);
        },
        // set type, either numeric or text
        type: 'numeric'
    });

    $('.tablesorter').tablesorter({dateFormat: "fi", sortMultiSortKey: 'altKey'});
    
    $('.datepicker').datepicker({
        dateFormat: "dd.mm.yy"
    });
    
    $.timepicker.regional['fi'] = {
        timeOnlyTitle: 'Valitse kellonaika',
        timeText: 'Aika',
        hourText: 'Tunti',
        minuteText: 'Minuutti',
        secondText: 'Sekuntti',
        millisecText: 'Millisekuntti',
        currentText: 'Nyt',
        closeText: 'Valmis',
        ampm: false
    };
    $.timepicker.setDefaults($.timepicker.regional['fi']);
    
    $('.datetimepicker').datetimepicker({
        dateFormat: "dd.mm.yy",
        timeFormat: 'hh:mm'
    });
    $('.timepicker').timepicker();
    $('.datetimepickernow').datetimepicker({
        dateFormat: "dd.mm.yy",
        timeFormat: 'hh:mm',
        hour: getCurrentHour(),
        minute: getCurrentMinute()
    });
    
    $('.flash_message').click(function(){
        $(this).slideUp(500, "linear");
    });
    
    $('.flash_message').hover(function(){
        stop_flash_hides = true;
    });
    
    $('.presence_starts').datetimepicker({
        dateFormat: "dd.mm.yy",
        timeFormat: 'hh:mm',
        hour: 12
    });
    $('.presence_ends').datetimepicker({
        dateFormat: "dd.mm.yy",
        timeFormat: 'hh:mm',
        hour: 12
    });
    
    $('.datetimepicker_search').datetimepicker({
        dateFormat: "dd.mm.yy",
        timeFormat: 'hh:mm',
        hour: 12
    });
    
    $('#search_container_opener a').click(function() {
       $('#search_container').toggle('slow'); 
       return false;
    });
    $('#text_search_container_opener a').click(function() {
       $('#text_search_container').toggle('slow'); 
       return false;
    });
    
    $("textarea").autoGrow();
    
    
    $('.edit_payment').click(function() {
        var id = $(this).attr('id').replace('edit_payment_button_', '');
        var parent_tr = $(this).parent('td').parent('tr');
        var title = $('td.payment_title', parent_tr).html();
        var euros = $('td.payment_euros span', parent_tr).html();
        var notes = $('td.payment_notes span', parent_tr).html();
        var paid = $('td.payment_paid span', parent_tr).html();
        var send_invoice = $('td.payment_send_invoice span', parent_tr).html();
        
        $('#payment_id').val(id);
        $('#payment_title').val(title);
        $('#payment_euros').val(euros);
        $('#payment_note').text(notes);
        $('#payment_paid option').each(function() {
            if ($(this).val()==paid) {
                $(this).attr('selected',true);
            }
            
        });
        $('#payment_send_invoice option').each(function() {
            if ($(this).val()==send_invoice) {
                $(this).attr('selected',true);
            }
            
        });
        
        $('#edit_payment legend').html($('#edit_payment_str').html());
        
        
        $.scrollTo('#edit_payment', 800);
        
        return false;
    });
    
    $('#reset_payment').click(function() {
        $('#edit_payment legend').html($('#new_payment_str').html());
    });
    
    $('#select_all_participants').click(function() {
        if ($(this).is(':checked')) {
            $('.participant_id_checkbox').attr('checked', true)
        } else {
            $('.participant_id_checkbox').attr('checked', false)
        }
    });
    
    $('.participant_id_checkbox').click(function() {
        if ($('input.participant_id_checkbox[type=checkbox]:not(:checked)').length) {
            $('#select_all_participants').attr('checked', false)
        }
        if (!$('input.participant_id_checkbox[type=checkbox]:not(:checked)').length) {
            $('#select_all_participants').attr('checked', true)
        }
    });
    
    
    $('#mass_tools_action').change(function() {
        var action = $(this).val();
        $('.mass_tools_action_container').hide();
        $('#mass_tools_action_container_'+action).show();
        if (action == '') {
            $('#mass_tools_submit').hide();
        } else {
            $('#mass_tools_submit').show();
        }
    });
    
    $('.datetimepicker_search_birthdate').datepicker( { 
        minDate: new Date(new Date().getFullYear(), 1 - 1),
        maxDate: new Date(new Date().getFullYear()+1, 1 - 1, -1)
    });
    
    $('#what_to_view_opener').click(function() {
        $('#what_to_view_content').toggle('slow');
        return false;
    });
    
    $('#open_in_excel').click(function() {
        var report_form = $('#report_form');
        $(report_form).attr("target", "_blank");
        $(report_form).attr('action', '/office/report_excel/')
        $(report_form).submit();
        $(report_form).attr("target", "_self");
        $(report_form).attr('action', '/office/report/')
        return false;
    });

    $('#stats_close_button a').click(function() {
        $('#report_statistics').slideUp(function() {
            $('#stats_open_button').show();
        });
        
        return false;
    });
    
    $('#stats_open_button a').click(function() {
        $('#stats_open_button').hide();
        $('#report_statistics').slideDown();
        return false;
    });
    
    $('#kitchen_stats_close_button a').click(function() {
        $('#kitchen_report_statistics').slideUp(function() {
            $('#kitchen_stats_open_button').show();
        });
        
        return false;
    });
    
    $('#kitchen_stats_open_button a').click(function() {
        $('#kitchen_stats_open_button').hide();
        $('#kitchen_report_statistics').slideDown();
        return false;
    });

    $('#kitchen_table_close_button a').click(function() {
        $('#kitchen_report_table').slideUp(function() {
            $('#kitchen_table_open_button').show();
        });
        
        return false;
    });
    
    $('#kitchen_table_open_button a').click(function() {
        $('#kitchen_table_open_button').hide();
        $('#kitchen_report_table').slideDown();
        return false;
    });

    
    $('#feedback_opener').fancybox({
            width       : 800,
            height      : 600,
            autoSize    : false,
            closeClick  : false,
            openEffect  : 'elastic',
            closeEffect : 'elastic',
            closeBtn    : true,
            padding     : 10
        });
    
    setTimeout('hideFlashMessages()', 3000);
});

function getCurrentHour() {
    return new Date().getHours();
}

function getCurrentMinute() {
    return new Date().getMinutes();
}

function hideFlashMessages() {
    $('.flash_message.info, .flash_message.success').each(function(){
        if (!stop_flash_hides) {
            $(this).slideUp(2000, "linear");
        }
    });
}

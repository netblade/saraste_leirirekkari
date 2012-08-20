$(document).ready(function () {
    $('#medical_search_participant').submit(function() {
        $('#medical_search_participant_results').html($('#loader').html());
        search_str = $('#medical_search_participant_str').val();
        $.post('/medical/search_participant/',{ search_str: search_str },
            function(data) {
                $('#medical_search_participant_results').html(data);
                $('#medical_search_participant_results .tablesorter').tablesorter();
        });
        return false;
    });
    
    $('#medical_search_card').submit(function() {
        $('#medical_search_card_results').html($('#loader').html());
        search_str = $('#medical_search_card_str').val();
        $.post('/medical/search_card/',{ search_str: search_str },
            function(data) {
                $('#medical_search_card_results').html(data);
                $('#medical_search_card_results .tablesorter').tablesorter();
        });
        return false;
    });
    
    $('#add_medical_event_row').click(function() {
		var content = $('#medical_event_null').html();
		// id="presence_row_null_row"
		var row_id_time = new Date().getTime();
		var row_id = 'medical_card_event_'+row_id_time+'_row';
		content = content.replace('medical_card_event_null_row', row_id);
		
		$('#medical_card_events_container').append(content);
		$('.remove_medical_card_event_row').click(function() {
			$(this).parent('.remove_medical_card_event_row_container').parent('.columns').parent('.row').parent('.medical_event').remove();
			return false;
		});
		$('.event_time_datetimepicker', '#'+row_id).datetimepicker({
            timeFormat: 'hh:mm',
        });
		return false;
	});
	
	$('.remove_medical_card_event_row').click(function() {
		$(this).parent('.remove_medical_card_event_row_container').parent('.columns').parent('.row').parent('.medical_event').remove();
		return false;
	});
});
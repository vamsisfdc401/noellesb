(function($) {
    $(function() {
        
        // Add checkboxes for toggle functionality.
        $('.nbcu-bom-table tr.child').prev('tr.parent').each(function(index, value) {
            var markup = '<input id="nbcu-ec-widget-' + index + '" type="checkbox" class="hidden" data-toggle="toggle">';
            markup += '<label for="nbcu-ec-widget-' + index + '"><i class="fa"></i></label>';
            $('td span', value).prepend(markup);
        });
        
        // Toggle functionality.
        $('[data-toggle="toggle"]').change(function(){
            $(this).parents('.parent').next('.child').find('td').toggle();
        });

        // Add spacing for all elements.
        $('.nbcu-bom-table .child td:first-child:not(:has(label)) span').each(function(index, value) {
            var currentPadding = $(value).css('padding-left');
            $(value).css('padding-left', parseInt(currentPadding) + 25);
        });
    });
})(jQuery);

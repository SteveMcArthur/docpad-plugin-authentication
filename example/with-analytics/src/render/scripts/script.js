/*global $ */
$(function () {

    $.getJSON('/analytics/data/endpoints', function (data) {
        var tabs = $('#tabs ul');
        for (var i = 0; i < data.length; i++) {
            var txt = (data[i] instanceof Array) ? data[i][0] : data[i];
            var li = $('<li>').appendTo(tabs);
            li.text(txt);
        }


        $('ul.tabs li').click(function (event) {
            event.preventDefault();
            var endPoint = $(this).text();
            $.getJSON('/analytics/data/' + endPoint, function (data) {
                $('#results table tr').remove();
                $('#results table thead').append('<tr>');

                var headers = data.columnHeaders;
                var rows = data.rows;
                var i = 0;
                var headRow = $('#results table thead tr');
                for (i = 0; i < headers.length; i++) {
                    $('<th>').appendTo(headRow).text(headers[i].name);
                }
                var tBody = $('#results table tbody');
                for (i = 0; i < rows.length; i++) {
                    var tRow = $('<tr>').appendTo(tBody);
                    var row = rows[i];
                    for (var k = 0; k < row.length; k++) {
                        $('<td>').appendTo(tRow).text(row[k]);
                    }

                }

                $('#results pre').html(JSON.stringify(data, null, 4));
            });
        });

    });


});
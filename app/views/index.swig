{% extends './template/freebase.swig' %}

{% block pageTitle %} List Devices {% endblock %}

{% block style %}
<link rel="stylesheet" href="/gridster/dist/jquery.gridster.css">
<link rel="stylesheet" href="/css/app.css">
{% endblock %}

{% block content %}
<div id="board-content" style="margin-top: 30px; padding: 15px 30px;">
    <h2> Your Devices </h2>

    <div class="gridster">
        <ul id="dev-grid-container">
        {% for row in devices %}
            {% set currentRow = loop.index %}
            {% for col in row %}
            <li data-row="{{ currentRow }}" data-col="{{ loop.index }}" data-sizex="1" data-sizey="1">
                <div class="glx-device-grid" href="/dashboard/{{ col.device.id }}" id="device-{{ col.device.id }}" device-type="gallon"
                    style="background-image: url('/img/{{ col.device.background }}'); background-size: auto 190px ">
                    <div class="row">
                        <div class="device-name">
                            {{ col.device.name }} <span style="color: rgba(255, 255, 255, .6)">at {{ col.config.locationName }}</span>
                        </div>
                    </div>

                    <div class="row">
                        <div class="device-metric">
                            <span style="font-size: 20pt; font-weight: bold; color: white">{{ col.attr.waterLevelPercent }}%</span>
                        </div>
                    </div>

                    <div class="row">
                        <div class="device-state">
                            <span style="text-align: right; color: white">{{ col.attr.stateString }}</span>
                        </div>
                    </div>
                </div>
            </li>
            {% endfor %}
        {% endfor %}
        </ul>
    </div>
</div>
{% endblock %}

{% block late-script %}
<script src="/gridster/dist/jquery.gridster.js"></script>
<script src="https://cdn.socket.io/socket.io-1.4.5.js"></script>
<script>
$(function() {
    var socket = io.connect('{{ wsUrl }}');

    function parseIncData(data) {
        var recvd =  data;
        if (typeof data === 'string') {
            try {
                recvd = JSON.parse(data);
            } catch (ex) {
                console.error('Invalid JSON');
            }
        }

        return recvd;
    }

    socket.on('connect', function() {
        socket.on('getState', function(data) {
            var recvd = parseIncData(data);
            var $device = $('#device-' + recvd.deviceId);

            if (parseInt(recvd.state) === 0) {
                $device.find('.device-state').find('span').html('OFF');
            } else {
                $device.find('.device-state').find('span').html('ON');
            }
        });

        socket.on('metric', function (data) {
            var recvd = parseIncData(data);
            var $device = $('#device-' + recvd.deviceId);
            var url = '/img/img_gallon_percentage_' + recvd.waterLevelPercent + '.png';

            $device.css('background-image', 'url(' + url + ')');
            $device.find('.device-metric').find('span').html(recvd.waterLevelPercent + '%');
        });
    });
})
</script>
<script>
$(function() {
    var gr = $('.gridster ul').gridster({
        widget_base_dimensions: [300, 300],
        widget_margins: [10, 10],
        min_cols: 1,
        max_cols: 3,
        widget_class: 'glx-device-grid',
        autogenerate_stylesheet: true,
    }).data('gridster');

    gr.disable();

    $('.glx-device-grid').on('click', function(event) {
        if ($(this).attr('href')) {
            window.location = $(this).attr('href');
        }
    });
});
</script>
{% endblock %}

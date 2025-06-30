//= require jquery
//= require moment
//= require moment/ja.js
//= require bootstrap-datetimepicker

$(document).on('turbo:load', function() {
  // 日付ピッカーの初期化（Rails 8.0対応）
  initializeDatePickers();
});

$(document).ready(function() {
  // Turboを使わない場合のフォールバック
  if (!window.Turbo) {
    initializeDatePickers();
  }
});

function initializeDatePickers() {
  console.log('Initializing date pickers...');
  console.log('jQuery available:', typeof $ !== 'undefined');
  console.log('moment available:', typeof moment !== 'undefined');
  console.log('datetimepicker available:', typeof $.fn !== 'undefined' && typeof $.fn.datetimepicker !== 'undefined');
  
  if (typeof $ === 'undefined' || typeof moment === 'undefined') {
    console.error('Required dependencies not loaded');
    return;
  }
  
  if (typeof $.fn.datetimepicker === 'undefined') {
    console.error('DateTimePicker plugin not loaded');
    return;
  }
  
  $('.input-group.date').each(function() {
    var $this = $(this);
    if (!$this.data('DateTimePicker')) {
      console.log('Initializing datepicker on element:', this);
      $this.datetimepicker({
        format: 'YYYY-MM-DD',
        dayViewHeaderFormat: 'YYYY年MMMM',
        locale: 'ja',
        showClose: true,
        icons: {
          time: 'glyphicon glyphicon-time',
          date: 'glyphicon glyphicon-calendar',
          up: 'glyphicon glyphicon-chevron-up',
          down: 'glyphicon glyphicon-chevron-down',
          previous: 'glyphicon glyphicon-chevron-left',
          next: 'glyphicon glyphicon-chevron-right',
          today: 'glyphicon glyphicon-screenshot',
          clear: 'glyphicon glyphicon-trash',
          close: 'glyphicon glyphicon-remove'
        }
      });
      console.log('DatePicker initialized successfully');
    }
  });
}
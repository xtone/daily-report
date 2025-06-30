//= require jquery
//= require moment
//= require moment/ja.js
//= require bootstrap-datetimepicker

$(document).on('turbo:load', function() {
  // 日付ピッカーの初期化（Rails 8.0対応）
  initializeSummaryDatePickers();
});

$(document).ready(function() {
  // Turboを使わない場合のフォールバック
  if (!window.Turbo) {
    initializeSummaryDatePickers();
  }
});

function initializeSummaryDatePickers() {
  console.log('Initializing summary date pickers...');
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
  
  // サマリーページ特有の日付ピッカー初期化
  $('#summaryRender .input-group.date').each(function() {
    var $this = $(this);
    if (!$this.data('DateTimePicker')) {
      console.log('Initializing summary datepicker on element:', this);
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
      console.log('Summary DatePicker initialized successfully');
      
      // 日付が変更されたときにCSVダウンロードボタンを有効化
      $this.on('dp.change', function(e) {
        console.log('Date changed:', e.date);
        enableSummaryDownloadButton();
        
        // CSVダウンロードフォームの隠しフィールドを更新
        var fieldName = $(this).find('input').attr('name');
        var newDate = $(this).find('input').val();
        if (fieldName === 'reports[start]') {
          $('#csv_start_date').val(newDate);
        } else if (fieldName === 'reports[end]') {
          $('#csv_end_date').val(newDate);
        }
      });
    }
  });
}

// CSVダウンロードボタンを有効化する関数
function enableSummaryDownloadButton() {
  var downloadForm = document.getElementById('summaryDownload');
  if (downloadForm) {
    var submitButton = downloadForm.querySelector('input[type="submit"]');
    if (submitButton) {
      submitButton.removeAttribute('disabled');
    }
  }
}
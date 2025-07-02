//= require jquery
//= require moment
//= require moment/ja.js
//= require bootstrap-datetimepicker

// Rails 8.0でTurboと連携するための日付ピッカー初期化
(function() {
  'use strict';

  // Turboイベントの登録
  document.addEventListener('turbo:load', function() {
    initializeUnsubmittedDatePickers();
  });

  // DOMContentLoadedイベントでも初期化（初回ページロード時）
  document.addEventListener('DOMContentLoaded', function() {
    initializeUnsubmittedDatePickers();
  });

  // turbo:renderイベントでも初期化（Turboフレーム更新時）
  document.addEventListener('turbo:render', function() {
    initializeUnsubmittedDatePickers();
  });
})();

function initializeUnsubmittedDatePickers() {
  // 依存関係のチェック
  if (typeof $ === 'undefined' || typeof moment === 'undefined' || typeof $.fn.datetimepicker === 'undefined') {
    return;
  }
  
  // 日報未提出一覧ページの日付ピッカーを初期化
  $('#unsubmittedsRender .input-group.date').each(function() {
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
//= require jquery
//= require moment
//= require moment/ja.js
//= require bootstrap-datetimepicker

// Rails 8.0でTurboと連携するための日付ピッカー初期化
(function() {
  'use strict';

  // Turboイベントの登録
  document.addEventListener('turbo:load', function() {
    // 少し遅延させて、すべてのスクリプトが読み込まれてから実行
    setTimeout(function() {
      initializeDatePickers();
    }, 100);
  });

  // DOMContentLoadedイベントでも初期化（初回ページロード時）
  document.addEventListener('DOMContentLoaded', function() {
    initializeDatePickers();
  });

  // turbo:renderイベントでも初期化（Turboフレーム更新時）
  document.addEventListener('turbo:render', function() {
    initializeDatePickers();
  });

  // turbo:before-renderイベントで既存のdatepickerを破棄
  document.addEventListener('turbo:before-render', function() {
    $('.input-group.date').each(function() {
      var $this = $(this);
      if ($this.data('DateTimePicker')) {
        $this.data('DateTimePicker').destroy();
      }
    });
  });
})();

window.initializeDatePickers = function() {
  // 依存関係のチェック
  if (typeof $ === 'undefined' || typeof moment === 'undefined' || typeof $.fn.datetimepicker === 'undefined') {
    return;
  }
  
  // 日付ピッカーの初期化
  $('.input-group.date').each(function() {
    var $this = $(this);
    if (!$this.data('DateTimePicker')) {
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
    }
  });
};
// テスト環境でTurbo Driveを確実に無効化
if (typeof Turbo !== 'undefined') {
  // Turboが初期化される前にも無効化を試みる
  if (Turbo.session) {
    Turbo.session.drive = false;
  }
  
  // DOMContentLoadedイベントでも無効化
  document.addEventListener('DOMContentLoaded', function() {
    if (Turbo.session) {
      Turbo.session.drive = false;
      console.log('[Test] Turbo Drive disabled');
    }
  });
  
  // turbo:loadイベントでも無効化（Turboが完全に初期化された後）
  document.addEventListener('turbo:load', function() {
    if (Turbo.session) {
      Turbo.session.drive = false;
      console.log('[Test] Turbo Drive disabled on turbo:load');
    }
  });
}
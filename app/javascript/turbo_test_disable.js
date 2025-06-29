// テスト環境でTurbo Driveを確実に無効化
if (typeof Turbo !== 'undefined') {
  document.addEventListener('DOMContentLoaded', function() {
    Turbo.session.drive = false;
    console.log('[Test] Turbo Drive disabled');
  });
  
  // Turboが初期化される前にも無効化を試みる
  if (Turbo.session) {
    Turbo.session.drive = false;
  }
}
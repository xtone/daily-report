// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import * as Turbo from "@hotwired/turbo"

// テスト環境でTurbo Driveを無効化
if (process.env.NODE_ENV === 'test' || process.env.RAILS_ENV === 'test') {
  // Turboの初期化直後に無効化
  Turbo.session.drive = false
  console.log('[Test] Turbo Drive disabled immediately after import');
  
  // 追加の無効化処理もロード
  import('./turbo_test_disable')
}

// 共通のユーティリティ
import "./utils/common"

console.log("Application loaded")
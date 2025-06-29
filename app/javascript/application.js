// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"

// テスト環境でTurbo Driveを無効化
if (process.env.NODE_ENV === 'test' || process.env.RAILS_ENV === 'test') {
  import('./turbo_test_disable')
}

// 共通のユーティリティ
import "./utils/common"

console.log("Application loaded")
# CI環境でのE2Eテストの安定性を向上させるための設定
if ENV['CI']
  RSpec.configure do |config|
    # CI環境では各テストの前後に待機時間を追加
    config.before(:each, type: :feature) do
      # ブラウザが完全に初期化されるのを待つ
      sleep 0.5
    end

    config.after(:each, type: :feature) do
      # 次のテストに影響しないようにセッションをクリア
      Capybara.reset_sessions!
      # ブラウザが完全にリセットされるのを待つ
      sleep 0.3
    end

    # Turbo Driveのために、ページロード後の追加待機
    config.before(:each, type: :feature, js: true) do
      Capybara.default_max_wait_time = 15 # CI環境では待機時間を長めに
    end
  end

  # Capybaraの追加設定
  Capybara.configure do |capybara_config|
    # アセットのプリコンパイルを待つ
    capybara_config.server = :puma, { Silent: true }

    # CI環境でのタイムアウトを延長
    capybara_config.default_max_wait_time = 15

    # アクションの間に少し待機
    capybara_config.default_normalize_ws = true
  end

  # Playwright driver for CI (already configured in capybara.rb)
  # CI環境では既にcapybara.rbで設定されているPlaywrightドライバーを使用
end

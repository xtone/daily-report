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
  
  # Seleniumのタイムアウト設定
  Capybara.register_driver :selenium_chrome_headless_ci do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless=new') # 新しいヘッドレスモード
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-gpu')
    options.add_argument('--disable-setuid-sandbox')
    options.add_argument('--disable-web-security')
    options.add_argument('--window-size=1920,1080') # より大きな画面サイズ
    options.add_argument('--start-maximized')
    options.add_argument('--disable-blink-features=AutomationControlled')
    options.add_argument('--disable-features=VizDisplayCompositor')
    # ページロードのタイムアウトを延長
    options.add_argument('--page-load-strategy=normal')
    
    # タイムアウト設定
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.read_timeout = 120 # 読み込みタイムアウトを2分に
    client.open_timeout = 120 # 接続タイムアウトを2分に

    Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      options: options,
      http_client: client
    )
  end
  
  # CI環境では専用ドライバーを使用
  Capybara.javascript_driver = :selenium_chrome_headless_ci
end
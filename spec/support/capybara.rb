require 'capybara/rspec'
require 'selenium-webdriver'
require 'webdrivers/chromedriver'

# Chromeドライバーの自動管理（インストールされているChromeに合わせて自動的にダウンロード）
Webdrivers.cache_time = 86_400 # 1日間キャッシュ

# Capybara configuration
Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')
  options.add_argument('--disable-setuid-sandbox')
  options.add_argument('--window-size=1280,800')

  # Chromeのバイナリパスを明示的に指定（Docker環境用）
  options.binary = '/usr/bin/google-chrome-stable' if File.exist?('/usr/bin/google-chrome-stable')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium_chrome_headless
Capybara.default_max_wait_time = 5

# Server configuration
Capybara.server_host = '0.0.0.0'
Capybara.server_port = 3001
Capybara.app_host = 'http://localhost:3001'

RSpec.configure do |config|
  config.include Capybara::DSL
end

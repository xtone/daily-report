require 'capybara/rspec'
require 'selenium-webdriver'

# Chrome/Chromiumの設定
Selenium::WebDriver::Chrome.path = ENV['CHROME_BIN'] if ENV['CHROME_BIN']

# Capybara configuration
Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')
  options.add_argument('--disable-setuid-sandbox')
  options.add_argument('--window-size=1280,800')
  
  # CI環境用の追加設定
  if ENV['CI']
    options.add_argument('--disable-blink-features=AutomationControlled')
    options.add_argument('--disable-features=VizDisplayCompositor')
    options.add_argument('--disable-web-security')
  end

  # Chrome/Chromiumのバイナリパスを明示的に指定
  if ENV['CHROME_BIN']
    options.binary = ENV['CHROME_BIN']
  elsif File.exist?('/usr/bin/chromium')
    options.binary = '/usr/bin/chromium'
  elsif File.exist?('/usr/bin/google-chrome-stable')
    options.binary = '/usr/bin/google-chrome-stable'
  end

  # WebDriverのパスを設定
  service = if ENV['CHROMEDRIVER_PATH']
    Selenium::WebDriver::Service.chrome(path: ENV['CHROMEDRIVER_PATH'])
  else
    Selenium::WebDriver::Service.chrome
  end

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options, service: service)
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium_chrome_headless
# CI環境では待ち時間を長く設定
Capybara.default_max_wait_time = ENV['CI'] ? 10 : 5

# Server configuration
Capybara.server_host = '0.0.0.0'
Capybara.server_port = 3001
Capybara.app_host = 'http://localhost:3001'

RSpec.configure do |config|
  config.include Capybara::DSL
end

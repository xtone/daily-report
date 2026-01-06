require 'capybara/rspec'
require 'capybara/playwright'

# Playwright driver configuration
Capybara.register_driver :playwright do |app|
  Capybara::Playwright::Driver.new(app,
    browser_type: :chromium,
    headless: true,
    playwright_cli_executable_path: ENV['PLAYWRIGHT_CLI_PATH'] || 'npx playwright'
  )
end

# Default settings
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :playwright
# CI環境では待ち時間を長く設定
Capybara.default_max_wait_time = ENV['CI'] ? 10 : 5

# Server configuration
Capybara.server_host = '0.0.0.0'
Capybara.server_port = 3001
Capybara.app_host = 'http://localhost:3001'

RSpec.configure do |config|
  config.include Capybara::DSL
end

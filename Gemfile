source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 8.0.0'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.4.4'
# Use Puma as the app server (updated for Rails 8 compatibility)
gem 'puma', '~> 6.4'
# Use logger
gem 'logger'
# Bootsnap for faster boot times
gem 'bootsnap', '>= 1.1.0', require: false
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Sprockets for asset pipeline (required for Rails 7)
gem 'sprockets-rails'
# Use honoka-rails (Bootstrap Theme for Japanese)
gem 'honoka-rails'
# Use Slim for templating engine
gem 'slim-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# CoffeeScript support - 一時的に追加（アセットパイプライン互換性のため）
gem 'coffee-rails'
# Use Data-Confirm Modal
gem 'data-confirm-modal'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# gem 'webpacker', '~> 5.0' # Replaced with jsbundling-rails
gem 'jsbundling-rails'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbo replaces Turbolinks in Rails 7
gem 'turbo-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Config to manage environment specific settings
gem 'config'

# Use Capistrano for deployment
gem 'capistrano-rails', group: :development

# Use Pundit and Devise to provide authorization system
gem 'devise', '>= 4.8.1'
gem 'devise-encryptable'
gem 'pundit'

# Use Holidays to deal holidays
gem 'holidays'

# Use Gretel to make it easy to create breadcrumbs
gem 'gretel'

# Use Bootstrap 3 Datepicker
gem 'bootstrap3-datetimepicker-rails', '~> 4.14.30'
gem 'momentjs-rails', '>= 2.9.0'

# Use EnumHelp to work fine with I18n
gem 'enum_help'

# Use Kaminari for pagination
gem 'kaminari'

# Use Spreadsheet to read xls file
gem 'roo-xls', '~> 1.1.0'
gem 'spreadsheet'

# Use slack-notifier to send notifications to Slack webhooks
gem 'slack-notifier'

# Use image_processing for Active Storage (Rails 6.1 requirement)
gem 'image_processing', '~> 1.2'

gem 'concurrent-ruby', '1.3.4'

# Required for Rails 7+ (Ruby 3.1+)
gem 'net-imap', require: false
gem 'net-pop', require: false
gem 'net-smtp', require: false

# Required for Rails 8 (Rack 3 compatibility)
gem 'rackup', require: false

group :development, :test do
  gem 'factory_bot_rails', '~> 6.2'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'shoulda-matchers', '~> 4.0'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'awesome_print'
  gem 'byebug', platform: :mri
  gem 'pry-byebug', '~> 3.10'
  gem 'pry-rails'

  # E2E testing with Playwright
  gem 'capybara'
  gem 'capybara-playwright-driver'
  gem 'database_cleaner-active_record'

  # CI/CD
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
  gem 'rspec_junit_formatter'
  gem 'rubocop', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '~> 3.3'
  gem 'web-console'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows and some Linux environments do not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data'

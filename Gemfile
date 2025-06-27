source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.0'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.4.4'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use logger for Rails 6.1 compatibility
gem 'logger'
# Bootsnap for faster boot times
gem 'bootsnap', '>= 1.1.0', require: false
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Use honoka-rails (Bootstrap Theme for Japanese)
gem 'honoka-rails'
# Use Slim for templating engine
gem 'slim-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# Use Data-Confirm Modal
gem 'data-confirm-modal'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'webpacker', '~> 5.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
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
gem 'pundit'
gem "devise", ">= 4.7.0"
gem 'devise-encryptable'

# Use Holidays to deal holidays
gem 'holidays'

# Use Gretel to make it easy to create breadcrumbs
gem 'gretel'

# Use Bootstrap 3 Datepicker
gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '~> 4.14.30'

# Use EnumHelp to work fine with I18n
gem 'enum_help'

# Use Spreadsheet to read xls file
gem 'spreadsheet'
gem 'roo-xls', '~> 1.1.0'

# Use slack-notifier to send notifications to Slack webhooks
gem 'slack-notifier'

# Use image_processing for Active Storage (Rails 6.1 requirement)
gem 'image_processing', '~> 1.2'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails', '~> 4.11'
  gem 'shoulda-matchers', '~> 4.0'
  gem 'rails-controller-testing'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'awesome_print'
  gem 'pry-rails'
  gem 'pry-byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.1.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'rubocop', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

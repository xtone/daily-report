require 'database_cleaner/active_record'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation, except: %w[user_roles])
    # UserRoleの初期データを作成
    UserRole.find_or_create_by(role: 'administrator')
    UserRole.find_or_create_by(role: 'director')
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, type: :feature) do
    # Capybaraのテストは別スレッドで実行されるため、truncationを使用
    DatabaseCleaner.strategy = :truncation, { except: %w[user_roles] }
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end
end
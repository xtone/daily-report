# カスタムバリデーターを手動で読み込み
Dir[Rails.root.join('app/validators/*.rb')].each { |f| require f }
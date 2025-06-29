# テスト実行前にUserRoleレコードを作成
RSpec.configure do |config|
  config.before(:suite) do
    # UserRoleレコードを事前に作成
    UserRole.find_or_create_by(role: 'administrator')
    UserRole.find_or_create_by(role: 'director')
  end
end
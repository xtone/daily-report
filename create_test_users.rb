# テストユーザーを作成
user = User.create!(
  email: 'test@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  name: 'テストユーザー',
  began_on: Date.today
)
puts "テストユーザー作成: #{user.email}"

# 管理者ユーザーを作成
admin = User.create!(
  email: 'admin@example.com',
  password: 'admin123',
  password_confirmation: 'admin123',
  name: '管理者',
  began_on: Date.today
)
admin_role = UserRole.find_by(name: 'administrator')
admin.user_roles << admin_role if admin_role
admin.save!
puts "管理者ユーザー作成: #{admin.email}"

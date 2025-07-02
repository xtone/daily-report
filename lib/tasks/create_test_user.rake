namespace :test do
  desc 'Create test user'
  task create_user: :environment do
    user = User.new(
      email: 'test@example.com',
      password: 'password',
      name: 'テストユーザー',
      began_on: Date.today
    )
    if user.save
      puts "User created successfully: #{user.email}"

      # 管理者権限を付与
      admin_role = UserRole.find_by(role: 1)
      if admin_role
        user.user_roles << admin_role
        user.save!
        puts 'Admin role assigned to user'
      end
    else
      puts "Failed to create user: #{user.errors.full_messages.join(', ')}"
    end
  end
end

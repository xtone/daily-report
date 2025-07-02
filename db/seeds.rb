# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

require 'digest/md5'

puts "Creating user roles..."
admin_role = UserRole.find_or_create_by(role: 0)
director_role = UserRole.find_or_create_by(role: 1)

puts "Creating users..."
# 開発用ユーザーを作成
users = []

# 管理者ユーザー
admin = User.find_or_initialize_by(email: 'admin@example.com')
admin.name = '管理者'
admin.began_on = Date.today - 2.years
admin.division = :sales_director
if admin.new_record?
  admin.id = 1
  password = Digest::MD5.hexdigest('admin123' + '1')
  admin.encrypted_password = password
  admin.save(validate: false)
end
admin.user_roles << admin_role unless admin.user_roles.include?(admin_role)
users << admin
puts "  Created admin: #{admin.email}"

# ディレクターユーザー
director = User.find_or_initialize_by(email: 'director@example.com')
director.name = 'ディレクター'
director.began_on = Date.today - 1.year
director.division = :sales_director
if director.new_record?
  director.id = 2
  password = Digest::MD5.hexdigest('director123' + '2')
  director.encrypted_password = password
  director.save(validate: false)
end
director.user_roles << director_role unless director.user_roles.include?(director_role)
users << director
puts "  Created director: #{director.email}"

# 一般ユーザー（エンジニア）
engineers = [
  { name: '山田太郎', email: 'yamada@example.com', id: 3 },
  { name: '佐藤花子', email: 'sato@example.com', id: 4 },
  { name: '鈴木一郎', email: 'suzuki@example.com', id: 5 }
]

engineers.each do |engineer_data|
  user = User.find_or_initialize_by(email: engineer_data[:email])
  user.name = engineer_data[:name]
  user.began_on = Date.today - rand(6..18).months
  user.division = :engineer
  if user.new_record?
    user.id = engineer_data[:id]
    password = Digest::MD5.hexdigest('password' + engineer_data[:id].to_s)
    user.encrypted_password = password
    user.save(validate: false)
  end
  users << user
  puts "  Created engineer: #{user.email}"
end

# 一般ユーザー（デザイナー）
designers = [
  { name: '田中美咲', email: 'tanaka@example.com', id: 6 },
  { name: '高橋健二', email: 'takahashi@example.com', id: 7 }
]

designers.each do |designer_data|
  user = User.find_or_initialize_by(email: designer_data[:email])
  user.name = designer_data[:name]
  user.began_on = Date.today - rand(6..18).months
  user.division = :designer
  if user.new_record?
    user.id = designer_data[:id]
    password = Digest::MD5.hexdigest('password' + designer_data[:id].to_s)
    user.encrypted_password = password
    user.save(validate: false)
  end
  users << user
  puts "  Created designer: #{user.email}"
end

puts "\nCreating projects..."
# プロジェクトを作成
projects = []

project_data = [
  { code: 2401, name: 'Webサイトリニューアル', name_reading: 'うぇぶさいとりにゅーある', category: :client_shot },
  { code: 2402, name: 'ECサイト構築', name_reading: 'いーしーさいとこうちく', category: :client_shot },
  { code: 2403, name: 'モバイルアプリ開発', name_reading: 'もばいるあぷりかいはつ', category: :client_shot },
  { code: 2404, name: 'システム保守', name_reading: 'しすてむほしゅ', category: :client_maintenance },
  { code: 2405, name: 'UI/UXデザイン改善', name_reading: 'ゆーあいゆーえっくすでざいんかいぜん', category: :client_shot },
  { code: nil, name: '社内研修', name_reading: 'しゃないけんしゅう', category: :internal },
  { code: nil, name: '休み', name_reading: 'やすみ', category: :general_affairs }
]

project_data.each_with_index do |data, index|
  project = Project.find_or_initialize_by(name: data[:name])
  project.code = data[:code]
  project.name_reading = data[:name_reading]
  project.category = data[:category]
  project.hidden = false
  if project.new_record?
    project.id = index + 1
    project.save(validate: false)
  end
  projects << project
  puts "  Created project: #{project.name} (Code: #{project.code || 'N/A'})"
end

puts "\nAssigning users to projects..."
# ユーザーをプロジェクトに割り当て
# 管理者とディレクターは全プロジェクトに参加
[admin, director].each do |user|
  projects.each do |project|
    UserProject.find_or_create_by(user: user, project: project)
  end
end

# エンジニアは開発系プロジェクトに参加
User.where(division: :engineer).each do |user|
  projects.select { |p| [:client_shot, :client_maintenance, :internal, :general_affairs].include?(p.category.to_sym) }.each do |project|
    UserProject.find_or_create_by(user: user, project: project)
  end
end

# デザイナーはデザイン系プロジェクトに参加
User.where(division: :designer).each do |user|
  projects.select { |p| [:client_shot, :internal, :general_affairs].include?(p.category.to_sym) }.each do |project|
    UserProject.find_or_create_by(user: user, project: project)
  end
end

puts "\nCreating reports and operations..."
# 過去30日分の日報データを作成
start_date = Date.today - 30
end_date = Date.today

users.each do |user|
  (start_date..end_date).each do |date|
    # 土日は休み
    if date.wday == 0 || date.wday == 6
      report = Report.find_or_create_by(user: user, worked_in: date)
      Operation.find_or_create_by(
        report: report,
        project: projects.find { |p| p.name == '休み' },
        workload: 100
      )
      next
    end

    # 平日は作業を記録
    report = Report.find_or_create_by(user: user, worked_in: date)
    
    # ランダムに1-3個のプロジェクトで作業
    user_projects = user.projects.where.not(name: '休み').sample(rand(1..3))
    
    if user_projects.empty?
      # プロジェクトがない場合は社内研修
      Operation.find_or_create_by(
        report: report,
        project: projects.find { |p| p.name == '社内研修' },
        workload: 100
      )
    else
      # 作業時間を配分
      total_workload = 100
      workloads = []
      
      user_projects[0..-2].each do |_|
        workload = rand(20..40)
        workloads << workload
        total_workload -= workload
      end
      workloads << total_workload
      
      user_projects.each_with_index do |project, index|
        Operation.find_or_create_by(
          report: report,
          project: project,
          workload: workloads[index]
        )
      end
    end
  end
end

puts "\nSeeding completed!"
puts "=" * 50
puts "Created:"
puts "  - #{User.count} users"
puts "  - #{Project.count} projects"
puts "  - #{Report.count} reports"
puts "  - #{Operation.count} operations"
puts "\nDefault passwords:"
puts "  - admin@example.com: admin123"
puts "  - director@example.com: director123"
puts "  - Other users: password"
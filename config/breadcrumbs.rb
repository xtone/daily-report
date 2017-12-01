crumb :root do
  link '管理画面', admin_root_path
end

crumb :projects do
  link 'プロジェクト管理', projects_path
end

crumb :project do |project|
  if project.persisted?
    link project.name, project_path(project)
  else
    link '新規登録', new_project_path
  end
  parent :projects
end

crumb :project_members do |project|
  link 'プロジェクトメンバー管理', project_members_path(project)
  parent :project, project
end

crumb :users do
  link 'ユーザー一覧', users_path
end

crumb :user do |user|
  if user.persisted?
    link user.name, user_path(user)
  else
    link '新規登録', new_user_path
  end
  parent :users
end

crumb :csvs do
  link 'CSV出力', admin_csvs_path
end

crumb :summary do
  link '稼働集計', summary_path
end

crumb :unsubmitted do
  link '日報未提出一覧', unsubmitted_path
end

crumb :estimates do
  link '見積書アップロード', estimates_path
end

crumb :bills do
  link '請求書アップロード', bills_path
end

# crumb :project_issues do |project|
#   link "Issues", project_issues_path(project)
#   parent :project, project
# end

# crumb :issue do |issue|
#   link issue.title, issue_path(issue)
#   parent :project_issues, issue.project
# end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).
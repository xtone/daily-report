require 'csv'

namespace :app do
  desc '旧システムからのデータをインポートする'
  task import_csv: :environment do
    begin
      ApplicationRecord.transaction do
        # user.csv -> User
        CSV.table(Rails.root.join('tmp', 'user.csv')).each do |row|
          user = User.new(
            id: row[:id],
            email: row[:email] == 'NULL' ? nil : row[:email],
            encrypted_password: row[:password]
          )
          user.save(validate: false)
        end
        # profile.csv -> User
        CSV.table(Rails.root.join('tmp', 'profile.csv')).each do |row|
          user = User.find(row[:id])
          user.update_attribute(:name, row[:fullname])
        end
        # user_printouts.csv -> User
        CSV.table(Rails.root.join('tmp', 'user_printouts.csv')).each do |row|
          user = User.find(row[:id])
          user.deleted_at = row[:printout] == 1 ? nil : user.updated_at
          user.began_on = row[:starting_date]
          user.save(validate: false)
        end
        # projects.csv -> Project
        CSV.table(Rails.root.join('tmp', 'projects.csv')).each do |row|
          project = Project.new(
            id: row[:id],
            code: row[:pid].present? ? row[:pid].to_i : nil,
            name: row[:name],
            name_reading: row[:name_kana],
            hidden: row[:deleted] == 1,
            created_at: row[:created],
            updated_at: row[:modified]
          )
          # codeはuniqueness制約があるが、既存projectのcodeにUniqueでないものがあるため
          # ここではvalidationをスキップする。
          project.save(validate: false)
        end

        # user_projects.csv -> UserProject
        CSV.table(Rails.root.join('tmp', 'user_projects.csv')).each do |row|
          # 元データがUniqueでないので、ここはcreateに失敗しても例外にしない
          UserProject.create(
            user_id: row[:user_id],
            project_id: row[:project_id]
          )
        end

        # daily_reports.csv -> Report
        CSV.table(Rails.root.join('tmp', 'daily_reports.csv')).each do |row|
          Report.create!(
            id: row[:id],
            user_id: row[:profile_id],
            worked_in: row[:date],
            created_at: row[:created],
            updated_at: row[:modified]
          )
        end

        # contents.csv -> Operation
        CSV.table(Rails.root.join('tmp', 'contents.csv')).each do |row|
          Operation.create!(
            id: row[:id],
            report_id: row[:daily_report_id],
            project_id: row[:project_id],
            workload: row[:rate],
            created_at: row[:created],
            updated_at: row[:modified]
          )
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      puts "#{e.class}: #{e.message}"
      p e.record
      e.record.errors.full_messages.each { |str| puts str }
    rescue => e
      puts "#{e.class}: #{e.message}"
      e.backtrace.each { |str| puts str }
    end
  end

  desc ''
  task unsubmitted_notification_mail: :environment do
    User.available.each do |user|
      dates = Report.unsubmitted_dates(user.id)
      next if dates.blank?
      ReportMailer.unsubmitted_notification(user, dates).deliver_later
    end
  end
end

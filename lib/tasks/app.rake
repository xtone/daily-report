require 'csv'

namespace :app do
  desc ''
  task import_csv: :environment do
    begin
      ApplicationRecord.transaction do
        # user.csv -> User
        CSV.table(Rails.root.join('tmp', 'user.csv')).each do |row|
          user = User.create!(id: row[:id], email: row[:email] == 'NULL' ? nil : row[:email])
          user.update_attributes!(encrypted_password: row[:password])
        end
        # profile.csv -> User
        CSV.table(Rails.root.join('tmp', 'profile.csv')).each do |row|
          user = User.find_by(id: row[:id])
          user.update_attributes!(name: row[:fullname])
        end
        # user_printouts.csv -> User
        CSV.table(Rails.root.join('tmp', 'user_printouts.csv')).each do |row|
          user = User.find_by(id: row[:id])
          user.update_attributes!(enrolled: row[:printout] == 1, created_at: row[:starting_date])
        end
        # projects.csv -> Project
        CSV.table(Rails.root.join('tmp', 'projects.csv')).each do |row|
          Project.create!(
            id: row[:id],
            code: row[:pid].to_i,
            name: row[:name],
            name_reading: row[:name_kana],
            hidden: row[:deleted] == 1,
            created_at: row[:created],
            updated_at: row[:modified]
          )
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
end

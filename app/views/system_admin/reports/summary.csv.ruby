require 'csv'

CSV.generate do |csv|
  header = [I18n.t('activerecord.models.project')]
  @users.each { |user| header << user.name }
  header << I18n.t('system_admin.reports.summary.total')
  csv << header

  @projects.each do |project_id, project|
    row = [project.name]
    row_total = 0
    @users.each do |user|
      value = @sum.dig(project_id, user.id) || 0
      row_total += value
      row << (value.positive? ? "#{value}%" : '-')
    end
    row << "#{row_total}%"
    csv << row
  end
end

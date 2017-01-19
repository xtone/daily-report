require 'csv'

CSV.generate(encoding: 'Shift_JIS') do |csv|
  header = %w(PJコード プロジェクト名)
  @users.each do |user|
    header << user.name
  end
  csv << header

  @sum.each do |sum|
    row = [@projects[sum[0]].code, @projects[sum[0]].name]
    @users.each do |user|
      row << sum[1][user.id]
    end
    csv << row
  end
end
require 'csv'

CSV.generate(encoding: 'Shift_JIS') do |csv|
  csv << %w{名前 日付 プロジェクト名 関与割合(%)}
  @reports.each do |report|
    row = [report.user.name, report.worked_in.strftime('%Y/%m/%d')]
    report.operations.each do |operation|
      row << operation.project.name << operation.workload
    end
    csv << row
  end
end
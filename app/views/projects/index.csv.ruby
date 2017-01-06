require 'csv'

CSV.generate(encoding: 'SJIS', undef: :replace, replace: '*') do |csv|
  csv << %w{コード 名前 よみ(かな) 表示/非表示 作成日}
  @projects.each do |project|
    csv << [
      project.code,
      project.name,
      project.name_reading,
      project.display_status,
      project.created_at.strftime('%Y-%m-%d')
    ]
  end
end

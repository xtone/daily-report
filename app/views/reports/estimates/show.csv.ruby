require 'csv'

csv_string = CSV.generate do |csv|
  header = %w(
    PJコード
    プロジェクト名
    PJ種別

    見積書件名
    見積書日付
    見積もり金額合計
    見積書件数
    見積書ファイル名
    予定原価合計
    営業・ディレクター想定工数合計
    エンジニア想定工数合計
    デザイナー想定工数合計
    その他想定工数合計

    請求書件名
    請求書日付
    請求金額合計
    請求書件数
    請求書ファイル名
    原価金額合計
    原価件数
    営業・ディレクター工数合計
    エンジニア工数合計
    デザイナー工数合計
    その他工数合計
  )
  @users.each do |user|
    header << user.name
  end
  csv << header

  @projects.each do |project|
    row = [project.code, project.name, project.category_i18n]
    estimates = project.estimates
    if estimates.present?
      row << estimates.first.subject
      row << estimates.first.estimated_on
      row << estimates.sum { |e| e.amount }
      row << estimates.count
      row << estimates.map { |e| e.filename }.join("\n")
      row << estimates.sum { |e| e.cost }
      row << estimates.sum { |e| e.director_manday }
      row << estimates.sum { |e| e.engineer_manday }
      row << estimates.sum { |e| e.designer_manday }
      row << estimates.sum { |e| e.other_manday }
    else
      row.push(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
    end

    bills = project.bills
    if bills.present?
      row << bills.first.subject
      row << bills.first.claimed_on
      row << bills.sum { |b| b.amount }
      row << bills.count
      row << bills.map { |b| b.filename }.join("\n")
      row << 0 # TODO: OutsideCost
      row << 0 # TODO: OutsideCost
    else
      row.push(nil, nil, nil, nil, nil, nil, nil)
    end
    workloads = project.workloads_by_division
    row << workloads[User.divisions[:director]]
    row << workloads[User.divisions[:engineer]]
    row << workloads[User.divisions[:designer]]
    row << workloads[User.divisions[:other]]

    workloads = project.workloads_by_user
    @users.each do |user|
      row << workloads[user.id]
    end
    csv << row
  end
end

convert_to_windows31j(csv_string)

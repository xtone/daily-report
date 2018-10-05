require 'csv'

CSV.generate(encoding: 'SJIS') do |csv|
  csv << %w{id 名前 メールアドレス 集計開始日}
  @users.each do |user|
    csv << [user.id, user.name, user.email, user.began_on]
  end
end
require 'csv'

CSV.generate(encoding: 'Shift_JIS') do |csv|
  csv << %w{ID 名前 メールアドレス}
  @users.each do |user|
    csv << [user.id, user.name, user.email]
  end
end
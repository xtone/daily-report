require 'csv'

CSV.generate do |csv|
  csv << %w{ID 名前 メールアドレス}
  @users.each do |user|
    csv << [user.id, user.name, user.email]
  end
end
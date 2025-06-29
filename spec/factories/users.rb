FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "ユーザー#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }
    began_on { Time.zone.local(2017, 1, 1) }
    encrypted_password { "tmp" } # 一時的な値を設定
    
    after(:create) do |user|
      # MD5でパスワードを暗号化（IDが確定してから）
      if user.password.present?
        require 'digest/md5'
        salt = user.id.to_s
        user.update_column(:encrypted_password, Digest::MD5.hexdigest(user.password + salt))
      end
    end

    trait :administrator do
      after(:create) do |user, evaluator|
        user.user_roles << FactoryBot.create(:user_role, :administrator)
      end
    end

    trait :director do
      after(:create) do |user, evaluator|
        user.user_roles << FactoryBot.create(:user_role, :director)
      end
    end

    trait :deleted do
      deleted_at { Time.zone.local(2017, 1, 1) }
    end
  end
end

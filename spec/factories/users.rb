FactoryGirl.define do
  factory :user do
    name "苗字名前"
    email "user@example.com"
    password "password"

    trait :administrator do
      after(:create) do |user, evaluator|
        user.user_roles << FactoryGirl.create(:user_role, :administrator)
      end
    end

    trait :general_affairs do
      after(:create) do |user, evaluator|
        user.user_roles << FactoryGirl.create(:user_role, :general_affairs)
      end
    end

    trait :director do
      after(:create) do |user, evaluator|
        user.user_roles << FactoryGirl.create(:user_role, :director)
      end
    end

    trait :deleted do
      deleted_at Time.zone.local(2017, 1, 1)
    end
  end
end

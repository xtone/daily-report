FactoryGirl.define do
  factory :user_role do
    trait :administrator do
      role 0
    end
    trait :general_affairs do
      role 1
    end
    trait :director do
      role 2
    end
  end
end

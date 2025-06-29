FactoryBot.define do
  factory :user_role do
    trait :administrator do
      role { 0 }
    end
    trait :director do
      role { 1 }
    end
  end
end

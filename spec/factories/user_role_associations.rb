FactoryGirl.define do
  factory :user_role_association do
    association :user
    association :user_role
  end
end

FactoryGirl.define do
  factory :user_project do
    association :user
    association :project
  end
end

FactoryGirl.define do
  factory :project do
    sequence(:code) { |n| 17000 + n }
    name "プロジェクト"
    name_reading "ぷろじぇくと"

    trait :hidden do
      hidden true
    end

    trait :with_user_project do
      after(:create) do |project|
        user = FactoryGirl.create(:user, email: 'project_user@example.com')
        FactoryGirl.create(:user_project, user: user, project: project)
      end
    end
  end
end

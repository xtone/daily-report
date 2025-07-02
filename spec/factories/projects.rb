FactoryBot.define do
  factory :project do
    sequence(:code) { |n| 17_000 + n }
    name { 'プロジェクト' }
    name_reading { 'ぷろじぇくと' }

    trait :hidden do
      hidden { true }
    end

    trait :with_user_project do
      after(:create) do |project|
        user = FactoryBot.create(:user, email: 'project_user@example.com')
        FactoryBot.create(:user_project, user: user, project: project)
      end
    end
  end
end

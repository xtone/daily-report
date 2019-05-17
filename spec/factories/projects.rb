FactoryGirl.define do
  factory :project do
    code nil
    name "プロジェクト"
    name_reading "ぷろじぇくと"

    trait :hidden do
      hidden true
    end

    trait :with_user_project do
      after(:create) do |project|
        project.user_projects << FactoryGirl.create(:user_project, user_id: 1, project_id: project.id)
      end
    end
  end
end

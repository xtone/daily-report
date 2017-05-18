FactoryGirl.define do
  factory :project do
    code nil
    name "プロジェクト"
    name_reading "ぷろじぇくと"

    trait :hidden do
      hidden true
    end
  end
end

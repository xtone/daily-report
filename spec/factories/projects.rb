FactoryGirl.define do
  factory :project do
    code 16001
    name "プロジェクト"
    name_reading "ぷろじぇくと"

    trait :hidden do
      hidden true
    end
  end
end

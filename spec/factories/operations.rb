FactoryGirl.define do
  factory :operation do
    association :report
    association :project
    workload 100
  end
end

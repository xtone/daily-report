FactoryGirl.define do
  factory :report do
    association :user
    worked_in "2016-11-16"
  end
end

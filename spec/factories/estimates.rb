FactoryBot.define do
  factory :estimate do
    association :project
    sequence(:serial_no) { |n| "EST-#{n.to_s.rjust(4, '0')}" }
    subject { '見積もり件名' }
    amount { 100_000 }
    filename { 'estimate.pdf' }
    estimated_on { Date.current }
    director_manday { 1.0 }
    engineer_manday { 5.0 }
    designer_manday { 2.0 }
    other_manday { 0.0 }
    cost { 50_000 }
  end
end

FactoryBot.define do
  factory :bill do
    association :estimate
    sequence(:serial_no) { |n| "BILL-#{n.to_s.rjust(4, '0')}" }
    subject "請求書件名"
    amount 100000
    filename "bill.pdf"
  end
end

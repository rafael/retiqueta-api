FactoryGirl.define do
  factory :order do
    association :user
    total_amount 100
    financial_status 'paid'
    currency 'VEF'
    association :payment_transaction
  end
end

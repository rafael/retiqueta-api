FactoryGirl.define do
  factory :payment_transaction do
    association :user
    payment_method 'visa'
    payment_provider 'ml'
    status 'paid'
  end
end

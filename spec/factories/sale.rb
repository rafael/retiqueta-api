FactoryGirl.define do
  factory :sale do
    association :user
    association :order
    amount 100
    store_fee 0
  end
end

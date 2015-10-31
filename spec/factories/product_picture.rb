FactoryGirl.define do
  factory :product_picture do
    association :user
    position 0
  end
end

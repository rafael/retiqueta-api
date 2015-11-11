FactoryGirl.define do
  factory :product_picture do
    association :user
    product nil
    position 0
  end
end

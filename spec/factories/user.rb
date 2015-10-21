FactoryGirl.define do
  factory :user do
    sequence(:username)  { |n| "johnsnow#{n}" }
    name  "John De Las Nieves"
    sequence(:email) { |n| "john#{n}@winterfell.com"}
    password "123456"
  end
end

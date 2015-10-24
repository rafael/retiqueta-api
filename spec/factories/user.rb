FactoryGirl.define do
  factory :user do
    sequence(:username)  { |n| "johnsnow#{n}" }
    sequence(:email) { |n| "john#{n}@winterfell.com"}
    password "123456"
  end
end

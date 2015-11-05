FactoryGirl.define do
  factory :profile do
    association :user
    sequence(:first_name)  { |n| "John #{n}" }
    sequence(:last_name) { |n| "Snow #{n}"}
    country { "Venezuela" }
    bio { "My Super Bio" }
    website  { "http://www.google.com" }
  end
end

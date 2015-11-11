FactoryGirl.define do
  factory :user do
    sequence(:username)  { |n| "johnsnow#{n}" }
    sequence(:email) { |n| "john#{n}@winterfell.com"}
    password "123456"
    after(:build) do |user|
      build(:profile, user: user)
    end
  end
end

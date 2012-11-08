FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "user#{n}" }
    password "password"
    password_confirmation { |u| u.password }
  end
  factory :role do
  end
  factory :group do
  end
  factory :title do
  end
  factory :company do
  end
end

require 'factory_girl/step_definitions'

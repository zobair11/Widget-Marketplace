FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password' }
    role { :general_user }
    first_name { 'John' }
    last_name { 'Doe' }

    after(:create) do |user|
      create(:balance, user: user, balance: 0.0)
    end
  end
end

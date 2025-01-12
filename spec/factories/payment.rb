FactoryBot.define do
  factory :payment do
    amount { 50.0 }
    association :user
  end
end

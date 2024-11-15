FactoryBot.define do
  factory :balance do
    balance { 100.0 }
    association :user
  end
end
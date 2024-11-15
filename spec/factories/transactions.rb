FactoryBot.define do
  factory :transaction do
    association :buyer, factory: :user
    association :widget
    marketplace_fee { 5.0 }
  end
end

FactoryBot.define do
  factory :widget do
    description { 'A sample widget' }
    price { 100.0 }
    status { 'available' }
    association :seller, factory: :user
  end
end

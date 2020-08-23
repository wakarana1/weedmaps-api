FactoryBot.define do
  factory :medical_recommendation do
    association :user, factory: :user
    number { Faker::Number.number(digits: 9) }
    issuer { 'Golden Grove Department County Department of Public Health' }
    state { Faker::Address.state_abbr }
    expiration_date { Faker::Date.forward(days: 365) }
    image_url { Faker::Fillmurray.image }
  end
end

FactoryBot.define do
  factory :identification do
    association :user, factory: :user
    number { Faker::Number.number(digits: 9) }
    state { Faker::Address.state_abbr }
    expiration_date { Faker::Date.forward(days: 365) }
    image_url { Faker::Fillmurray.image }
  end
end

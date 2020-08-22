FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email(domain: 'weedmaps') }
    dob { Faker::Date.between(from: 50.years.ago, to: 18.years.ago) }
  end
end

FactoryBot.define do
  factory :coupon do
    name { Faker::Marketing.buzzwords }
    code { Faker::Alphanumeric.alphanumeric(number: 8).upcase }
    discount_value { Faker::Number.between(from: 5, to: 50) }
    discount_type { ["percent", "dollar"].sample }
    active { true } 
  end
end

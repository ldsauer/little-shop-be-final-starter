FactoryBot.define do
  factory :coupon do
    name { "MyString" }
    code { "MyString" }
    discount_value { "9.99" }
    discount_type { "MyString" }
    active { false }
    merchant { nil }
  end
end

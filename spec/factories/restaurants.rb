FactoryBot.define do
  factory :restaurant do
    name { "MyString" }
    cuisine { "MyString" }
    rating { "9.99" }
    price_level { 1 }
    distance { "MyString" }
    description { "MyText" }
    image_url { "MyString" }
  end
end

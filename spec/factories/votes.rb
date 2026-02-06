FactoryBot.define do
  factory :vote do
    participant { nil }
    restaurant { nil }
    liked { false }
  end
end

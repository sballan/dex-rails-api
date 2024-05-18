FactoryBot.define do
  factory :term do
    sequence(:term) { |n| "term#{n}" }
  end
end

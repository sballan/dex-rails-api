FactoryBot.define do
  factory :posting do
    association :document
    association :term
    sequence(:position) { |n| n }
  end
end

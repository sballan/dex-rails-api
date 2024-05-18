FactoryBot.define do
  factory :document do
    transient do
      postings_attributes { [] }
    end

    after(:build) do |document, evaluator|
      evaluator.postings_attributes.each do |posting_attributes|
        document.postings.build(posting_attributes)
      end
    end
  end
end

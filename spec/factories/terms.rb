# == Schema Information
#
# Table name: terms
#
#  id   :integer          not null, primary key
#  term :string           not null
#
# Indexes
#
#  index_terms_on_term  (term) UNIQUE
#
FactoryBot.define do
  factory :term do
    sequence(:term) { |n| "term#{n}" }
  end
end

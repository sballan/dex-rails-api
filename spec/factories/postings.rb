# == Schema Information
#
# Table name: postings
#
#  id          :integer          not null, primary key
#  position    :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  document_id :integer          not null
#  term_id     :integer          not null
#
# Indexes
#
#  index_postings_on_document_id                           (document_id)
#  index_postings_on_term_id                               (term_id)
#  index_postings_on_term_id_and_document_id_and_position  (term_id,document_id,position) UNIQUE
#
# Foreign Keys
#
#  document_id  (document_id => documents.id) ON DELETE => cascade
#  term_id      (term_id => terms.id) ON DELETE => cascade
#
FactoryBot.define do
  factory :posting do
    association :document
    association :term
    sequence(:position) { |n| n }
  end
end

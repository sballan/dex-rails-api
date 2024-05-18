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
class Posting < ApplicationRecord
  belongs_to :document
  belongs_to :term

  validates :position, presence: true
  validates :document_id, presence: true
  validates :term_id, presence: true
  validates :term_id, uniqueness: {scope: %i[position document_id]}
end

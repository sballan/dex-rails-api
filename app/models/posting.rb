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
#  index_postings_on_term_id_and_position_and_document_id  (term_id,position,document_id) UNIQUE
#
# Foreign Keys
#
#  document_id  (document_id => documents.id)
#  term_id      (term_id => terms.id)
#
class Posting < ApplicationRecord
end

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
class Term < ApplicationRecord
  has_many :postings, dependent: :destroy

  validates :term, presence: true
  validates :term, uniqueness: true
end

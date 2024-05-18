# == Schema Information
#
# Table name: documents
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Document < ApplicationRecord
  has_many :postings, dependent: :destroy

  validates :postings, presence: true

  accepts_nested_attributes_for :postings, allow_destroy: true

  def self.search_for_terms(terms, proximity)
    Document::QuerySearchForTerms.new(terms, proximity).call
  end
end

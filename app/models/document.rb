# == Schema Information
#
# Table name: documents
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Document < ApplicationRecord
  has_one :page, dependent: :nullify
  has_many :postings, dependent: :destroy

  accepts_nested_attributes_for :postings, allow_destroy: true

  def self.search_for_terms(terms, proximity)
    Document::SearchForTerms.new(terms, proximity).call
  end

  def self.search_for_text(text, proximity)
    Document::SearchForText.new(text, proximity).call
  end
end

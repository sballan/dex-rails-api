# == Schema Information
#
# Table name: documents
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

RSpec.describe Document, type: :model do
  describe ".search_for_terms" do
    let(:proximity) { 5 }
    let(:terms) { ["term1", "term2", "term3"] }

    before do
      # Create terms
      term1 = create(:term, term: "term1")
      term2 = create(:term, term: "term2")
      term3 = create(:term, term: "term3")

      # Create documents with postings
      @doc1 = create(:document, postings_attributes: [
        {term_id: term1.id, position: 1},
        {term_id: term2.id, position: 2},
        {term_id: term3.id, position: 3}
      ])

      @doc2 = create(:document, postings_attributes: [
        {term_id: term1.id, position: 1},
        {term_id: term3.id, position: 2},
        {term_id: term2.id, position: 3}
      ])

      @doc3 = create(:document, postings_attributes: [
        {term_id: term1.id, position: 1},
        {term_id: term2.id, position: 10},
        {term_id: term3.id, position: 20}
      ])
    end

    it "returns documents with terms in order within the specified proximity" do
      results = Document.search_for_terms(terms, proximity)

      expect(results).to include(@doc1)
      expect(results).not_to include(@doc2)
      expect(results).not_to include(@doc3)
    end
  end

  describe ".search_for_text" do
    let(:proximity) { 5 }
    let(:text) { "Some text for testing" }

    before do
      # Create terms
      term1 = create(:term, term: "some")
      term2 = create(:term, term: "text")
      term3 = create(:term, term: "test")

      # Create documents with postings
      @doc1 = create(:document, postings_attributes: [
        {term_id: term1.id, position: 0},
        {term_id: term2.id, position: 1},
        {term_id: term3.id, position: 2}
      ])

      @doc2 = create(:document, postings_attributes: [
        {term_id: term1.id, position: 0},
        {term_id: term3.id, position: 1},
        {term_id: term2.id, position: 2}
      ])

      @doc3 = create(:document, postings_attributes: [
        {term_id: term1.id, position: 0},
        {term_id: term2.id, position: 9},
        {term_id: term3.id, position: 19}
      ])
    end

    it "returns documents with terms in order within the specified proximity" do
      results = Document.search_for_text(text, proximity)


      expect(results).to include(@doc1)
      expect(results).not_to include(@doc2)
      expect(results).not_to include(@doc3)
    end
  end
end

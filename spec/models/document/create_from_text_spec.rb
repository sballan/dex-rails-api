require "rails_helper"

RSpec.describe Document::CreateFromText, type: :model do
  describe "#process_and_persist" do
    let(:text) { "Some text for testing" }
    let(:service) { Document::CreateFromText.new(text) }

    it "creates a new document" do
      expect { service.process_and_persist }.to change { Document.count }.by(1)
    end

    it "creates new terms" do
      expect { service.process_and_persist }.to change { Term.count }.by(3)
    end

    it "creates new postings" do
      expect { service.process_and_persist }.to change { Posting.count }.by(3)
    end

    it "creates the correct postings" do
      service.process_and_persist
      term1 = Term.find_by(term: "some")
      term2 = Term.find_by(term: "text")
      term3 = Term.find_by(term: "test")

      postings = service.document.postings
      posting_1 = postings.find { |p| p.term_id == term1.id }
      posting_2 = postings.find { |p| p.term_id == term2.id }
      posting_3 = postings.find { |p| p.term_id == term3.id }

      expect(posting_1.position).to eq(0)
      expect(posting_2.position).to eq(1)
      expect(posting_3.position).to eq(2)
    end
  end
end

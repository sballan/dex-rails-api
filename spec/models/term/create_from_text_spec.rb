require "rails_helper"

RSpec.describe Term::CreateFromText, type: :model do
  describe "#create_terms" do
    let(:text) { "Some text for testing" }
    let(:term_create_from_text) { Term::CreateFromText.new(text) }

    context "when terms do not exist" do
      it "creates new terms" do
        expect { term_create_from_text.create_terms }.to change { Term.count }.by(3)
      end

      it "returns the created terms" do
        terms = term_create_from_text.create_terms
        expect(terms.map(&:term)).to match_array(%w[some text test])
      end
    end

    context "when terms already exist" do
      before do
        term_create_from_text.create_terms
      end

      it "does not create new terms" do
        expect { term_create_from_text.create_terms }.not_to change { Term.count }
      end
    end

    context "when some terms exist and some do not" do
      let(:existing_term) { "Some text" }

      before do
        Term::CreateFromText.new(existing_term).create_terms
      end

      it "only creates new terms" do
        expect { term_create_from_text.create_terms }.to change { Term.count }.by(1)
      end
    end
  end
end

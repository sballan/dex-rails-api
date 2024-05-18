require "rails_helper"

RSpec.describe Term::CreateFromText, type: :model do
  describe "#call" do
    let(:text) { "Some text for testing" }
    let(:service) { Term::CreateFromText.new(text) }

    context "when terms do not exist" do
      it "creates new terms" do
        expect { service.call(text) }.to change { Term.count }.by(3)
      end

      it "returns the created terms" do
        terms = service.call(text)
        expect(terms.map(&:term)).to match_array(%w[some text test])
      end
    end

    context "when terms already exist" do
      before do
        service.call(text)
      end

      it "does not create new terms" do
        expect { service.call(text) }.not_to change { Term.count }
      end
    end

    context "when some terms exist and some do not" do
      let(:existing_term) { "Some" }
      let(:new_term) { "newterm" }
      let(:mixed_text) { "#{existing_term} #{new_term}" }

      before do
        service.call existing_term
      end

      it "only creates new terms" do
        expect { service.call(mixed_text) }.to change { Term.count }.by(1)
      end
    end
  end
end

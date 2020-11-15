require 'rails_helper'

describe Result, type: :model do
  context "Basics" do
    let(:query) { Query.create(text: "My Search Term") }
    let(:page) { Page.create(url: "http://www.google.com") }
    let(:kind) { "title" }

    it 'can be created with a query and a page' do
      expect(Result.create(query: query, page: page, kind: kind)).to be_truthy
    end
  end
end

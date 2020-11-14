require 'rails_helper'

describe Result, type: :model do
  context "Basics" do
    let(:query) { Query.create(text: "My Search Term") }
    let(:page) { Page.create(url: "http://www.google.com") }
    let(:kind) { "title" }

    expect(Result.create(query: query, page: page, kind: kind)).to be_truthy
  end
end

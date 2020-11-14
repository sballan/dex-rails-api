require 'rails_helper'

describe Query, type: :model do
  let(:text) { "My Search Term"}

  it "can be created with text" do
    expect(Query.create(text: text)).to be_truthy
  end
end

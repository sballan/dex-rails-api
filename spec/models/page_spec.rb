require 'rails_helper'

describe Page, type: :model do
  let(:url) { 'http://www.google.com' }

  it 'can be created with a url' do
    expect(Page.create(url: url)).to be_truthy
  end
end

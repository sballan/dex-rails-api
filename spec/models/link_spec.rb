require 'rails_helper'

describe Link, type: :model do
  let(:from_page) { Page.create url: 'www.google.com' }
  let(:to_page) { Page.create url: 'www.wikipedia.org' }

  it 'can be created with two Pages' do
    expect(Link.create(from: from_page, to: to_page)).to be_truthy
  end
end

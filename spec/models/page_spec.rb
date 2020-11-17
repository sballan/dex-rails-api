require 'rails_helper'

describe Page, type: :model do
  context 'Basics' do
    let(:url) { 'http://www.google.com' }
    let(:page) { Page.create(url: url) }

    it 'can be created with a url' do
      expect(page).to be_truthy
    end
  end

  context 'Links' do
    let(:page1) { Page.create(url: "https://www.page1.com") }
    let(:page2) { Page.create(url: "https://www.page2.com") }
    let(:page3) { Page.create(url: "https://www.page3.com") }

    let(:link1) { Link.create(from: page1, to: page2) }
    let(:link2) { Link.create(from: page3, to: page1) }

    it 'can have a link to other pages' do
      page1.links_to = [link1]
      page1.save

      expect(page1.links_to.size).to eql(1)
      expect(page1.links_to.first).to be_a(Link)
      expect(page1.links_to.first).to eql(link1)
      expect(page1.links_to.first).to_not eql(link2)
    end

    it 'can be linked to from other pages' do
      page1.links_from = [link2]
      page1.save

      expect(page1.links_from.size).to eql(1)
      expect(page1.links_from.first).to be_a(Link)
      expect(page1.links_from.first).to eql(link2)
      expect(page1.links_from.first).to_not eql(link1)
    end
  end
end

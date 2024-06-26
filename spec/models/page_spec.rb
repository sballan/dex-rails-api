# == Schema Information
#
# Table name: pages
#
#  id          :integer          not null, primary key
#  host        :string
#  rank        :decimal(, )
#  title       :string
#  url         :string
#  document_id :integer
#
# Indexes
#
#  index_pages_on_document_id  (document_id)
#  index_pages_on_rank         (rank)
#  index_pages_on_url          (url) UNIQUE
#
# Foreign Keys
#
#  document_id  (document_id => documents.id)
#
require "rails_helper"

describe Page, type: :model do
  context "Basics" do
    let(:url) { "http://www.google.com" }
    let(:page) { Page.create(url: url) }

    it "can be created with a url" do
      expect(page).to be_truthy
    end
  end

  context "Links" do
    let(:page1) { Page.create(url: "https://www.page1.com") }
    let(:page2) { Page.create(url: "https://www.page2.com") }
    let(:page3) { Page.create(url: "https://www.page3.com") }

    let(:link1) { Link.create(from: page1, to: page2) }
    let(:link2) { Link.create(from: page3, to: page1) }

    it "can have a link to other pages" do
      page1.links_to = [link1]
      page1.save

      expect(page1.links_to.size).to eql(1)
      expect(page1.links_to.first).to be_a(Link)
      expect(page1.links_to.first).to eql(link1)
      expect(page1.links_to.first).to_not eql(link2)
    end

    it "can be linked to from other pages" do
      page1.links_from = [link2]
      page1.save

      expect(page1.links_from.size).to eql(1)
      expect(page1.links_from.first).to be_a(Link)
      expect(page1.links_from.first).to eql(link2)
      expect(page1.links_from.first).to_not eql(link1)
    end
  end

  context "Scopes" do
    describe "by_site" do
      before(:example) do
        @page1 = Page.create!(url: "http://www.test.com")
        @page2 = Page.create!(url: "http://www.test.com/some/path")
        @page3 = Page.create!(url: "http://www.test.com/some/other/path")
        @page4 = Page.create!(url: "http://www.not_test.com")
        @site = Site.create!(home_url: "http://www.test.com", host: "www.test.com")
      end

      it "can find the home page for the site" do
        pages = Page.by_site(@site)
        expect(pages).to include(@page1)
      end

      it "can find an arbitrary page for the site" do
        pages = Page.by_site(@site)
        expect(pages).to include(@page2)
      end

      it "does not find pages for other sites" do
        pages = Page.by_site(@site)
        expect(pages).to_not include(@page4)
      end
    end
  end
end

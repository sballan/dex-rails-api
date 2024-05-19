# == Schema Information
#
# Table name: links
#
#  id      :integer          not null, primary key
#  text    :string
#  from_id :integer          not null
#  to_id   :integer          not null
#
# Indexes
#
#  index_links_on_from_id                     (from_id)
#  index_links_on_to_id                       (to_id)
#  index_links_on_to_id_and_from_id_and_text  (to_id,from_id,text) UNIQUE
#
# Foreign Keys
#
#  from_id  (from_id => pages.id)
#  to_id    (to_id => pages.id)
#
require "rails_helper"

describe Link, type: :model do
  context "Basics" do
    let(:from_page) { Page.create url: "www.google.com" }
    let(:to_page) { Page.create url: "www.wikipedia.org" }

    it "can be created with two Pages" do
      expect(Link.create(from: from_page, to: to_page)).to be_truthy
    end
  end
end

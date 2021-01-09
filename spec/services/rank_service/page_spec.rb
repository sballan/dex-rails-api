require "rails_helper"

describe RankService::Page do
  context "Basics" do
    it "can be initialized with id, position, and start_rank" do
      page = RankService::Page.new id: 1, position: 2, start_rank: 0.4
      expect(page).to be
    end

    it "can set backlinks" do
      page = RankService::Page.new(id: 1, position: 2, start_rank: 0.4)
      page.back_links = {3 => RankService::Page.new(id: 2, position: 3, start_rank: 0.4)}
      expect(page.back_links).to_not be_empty
      expect(page.back_links[3].id).to eql(2)
    end
  end
end
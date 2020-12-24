require "rails_helper"

describe IndexService::Commands::IndexPage do
  context "Basics" do
    describe "Level 0 index" do
      before do
        allow(ParseService::Client).to receive(:download_cached_parsed_page).and_return({title: "test title"})
      end

      before(:example) do
        page = Page.create url: "https://test.com"
        level = 0
        @command = IndexService::Commands::IndexPage.new(page, level)
        @command.run!
      end

      it "can be created with the right attributes" do
        expect(@command).to be
      end
    end
  end
end

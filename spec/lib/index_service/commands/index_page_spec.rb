require "rails_helper"

describe IndexService::Commands::IndexPage do
  context "Basics" do
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

  context "Features" do
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

      it "creates a Query for each word in the title" do
        queries = Query.where(text: ["test", "title"])
        titles = Set.new(queries.map(&:text))
        expect(titles).to eql(Set.new(%w[test title]))
      end

      it "creates a PageMatch for each Query" do
        q1 = Query.find_by_text 'test'
        q2 = Query.find_by_text 'title'

        pm1 = PageMatch.find_by_query_id q1.id
        pm2 = PageMatch.find_by_query_id q2.id

        expect(pm1).to be
        expect(pm2).to be
      end
    end

    describe "Level 1 index" do
      before do
        allow(ParseService::Client).to receive(:download_cached_parsed_page).and_return({title: "test this title"})
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

      it "creates a Query for each word in the title" do
        queries = Query.where(text: %w[test this title])
        titles = Set.new(queries.map(&:text))
        expect(titles).to eql(Set.new(%w[test this title]))
      end

    end
  end
end

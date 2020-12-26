require "rails_helper"

describe IndexService::Commands::InsertQueriesAndPageMatches do
  context "Basics" do
    before(:example) do
      page = Page.create url: "https://test.com"
      attributes = [{
        query_text: "some_text",
        page_id: page.id,
        kind: "title",
        full: true,
        length: 1,
        distance: 0
      }]
      @command = IndexService::Commands::InsertQueriesAndPageMatches.new(attributes)
      @command.run!
    end

    it "can be created with the right attributes" do
      expect(@command).to be
    end
  end

  context "Features" do
    before(:example) do
      page = Page.create url: "https://test.com"
      attributes = [{
        query_text: "some_text",
        page_id: page.id,
        kind: "title",
        full: true,
        length: 1,
        distance: 0
      }]
      @command = IndexService::Commands::InsertQueriesAndPageMatches.new(attributes)
      @command.run!
    end

    it "creates a query" do
      query = Query.find_by_text "some_text"
      expect(query).to be
    end

    it "creates a PageMatch that belongs to that query" do
      query = Query.find_by_text "some_text"
      page_match = PageMatch.last
      expect(page_match.query).to eql(query)
    end
  end
end

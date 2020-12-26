require "rails_helper"

describe IndexService::Commands::IndexPageText do
  context "Basics" do
    before(:example) do
      page = Page.create url: "https://test.com"
      query_text = "my_text"
      kind = "title"
      max_length = 1
      max_distance = 0

      @command = IndexService::Commands::IndexPageText.new(page, query_text, kind, max_length, max_distance)
      @command.run!
    end

    it "can be created with the right attributes" do
      expect(@command).to be
    end
  end

  context "Features" do
    before(:example) do
      page = Page.create url: "https://test.com"
      query_text = "my_text"
      kind = "title"
      max_length = 1
      max_distance = 0

      @command = IndexService::Commands::IndexPageText.new(page, query_text, kind, max_length, max_distance)
      @command.run!
    end

    it "creates a query" do
      query = Query.find_by_text "my_text"
      expect(query).to be
    end

    it "creates a PageMatch that belongs to that query" do
      query = Query.find_by_text "my_text"
      page_match = PageMatch.last
      expect(page_match.query).to eql(query)
    end
  end
end

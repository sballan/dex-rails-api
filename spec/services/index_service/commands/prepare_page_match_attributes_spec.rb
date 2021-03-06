require "rails_helper"

describe IndexService::Commands::PreparePageMatchAttributes do
  context "Basics" do
    it "can be created with a words array, max_distance, and max_length" do
      words_array = ["myWord"]
      max_distance = 0
      max_length = 1

      command = IndexService::Commands::PreparePageMatchAttributes.new(0, words_array, "title", max_distance, max_length)
      expect(command).to be
    end
  end

  context "Execution" do
    it "can create a match for a single word" do
      words_array = ["myWord"]
      max_distance = 0
      max_length = 1

      expected_results = [{page_id: 0, distance: 0, kind: "title", length: 1, query_text: "myWord", full: true}]

      command = IndexService::Commands::PreparePageMatchAttributes.new(0, words_array, "title", max_distance, max_length)
      command.run!
      expect(command.payload).to eql(expected_results)
    end

    it "can create a match for a two words" do
      words_array = ["myWord", "myOtherWord"]
      max_distance = 0
      max_length = 2

      expected_results = [
        {
          page_id: 0, distance: 0, length: 1, kind: "title", query_text: "myWord", full: false
        },
        {
          page_id: 0, distance: 0, length: 1, kind: "title", query_text: "myOtherWord", full: false
        },
        {
          page_id: 0, distance: 0, length: 2, kind: "title", query_text: "myWord myOtherWord", full: true
        }
      ]

      command = IndexService::Commands::PreparePageMatchAttributes.new(0, words_array, "title", max_distance, max_length)
      command.run!
      expect(command.payload).to eql(expected_results)
    end

    it "can create a match for a three words with distance 1" do
      words_array = ["myWord", "myOtherWord", "myLastWord"]
      max_distance = 1
      max_length = 3

      expected_results = [
        {
          page_id: 0, distance: 0, length: 1, kind: "title", query_text: "myWord", full: false
        },
        {
          page_id: 0, distance: 0, length: 1, kind: "title", query_text: "myOtherWord", full: false
        },
        {
          page_id: 0, distance: 0, length: 1, kind: "title", query_text: "myLastWord", full: false
        },
        {
          page_id: 0, distance: 0, length: 2, kind: "title", query_text: "myWord myOtherWord", full: false
        },
        {
          page_id: 0, distance: 0, length: 2, kind: "title", query_text: "myOtherWord myLastWord", full: false
        },
        {
          page_id: 0, distance: 1, length: 2, kind: "title", query_text: "myWord myLastWord", full: false
        },
        {
          page_id: 0, distance: 0, length: 3, kind: "title", query_text: "myWord myOtherWord myLastWord", full: true
        }
      ]

      command = IndexService::Commands::PreparePageMatchAttributes.new(0, words_array, "title", max_distance, max_length)
      command.run!
      expect(command.payload).to eql(expected_results)
    end
  end
end

require "rails_helper"

describe IndexService::Commands::SanitizeQueryText do
  context "Features" do
    it "converts to lowercase" do
      input_text = "MyText"
      command = IndexService::Commands::SanitizeQueryText.new(input_text)
      command.run!
      expect(command.payload).to eql("mytext")
    end

    it "strips leading and trailing whitespace" do
      input_text = " my text "
      command = IndexService::Commands::SanitizeQueryText.new(input_text)
      command.run!
      expect(command.payload).to eql("my text")
    end

    it "removes long strings of whitespace" do
      input_text = "my \n great \r text\n\r"
      command = IndexService::Commands::SanitizeQueryText.new(input_text)
      command.run!
      expect(command.payload).to eql("my great text")
    end

    it "removes non-alphanumeric characters" do
      input_text = "my4$ great&7 text***"
      command = IndexService::Commands::SanitizeQueryText.new(input_text)
      command.run!
      expect(command.payload).to eql("my4 great7 text")
    end
  end
end

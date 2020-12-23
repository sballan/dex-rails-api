module IndexService::Commands
  class SanitizeQueryText < Command::Base::Abstract
    def initialize(input_string)
      super()
      @input_string = input_string
    end

    def run_proc
      output_string = @input_string.tap do |str|
        str.strip! # Remove leading and trailing whitespace
        str.downcase! # Only use lowercase characters
        str.gsub!(/[^a-zA-Z0-9\s]/, "") # Keep only alphanumeric characters, in English (for now?)
        str.gsub!(/\s+/, " ") # Replace inner substrings of whitespace with single space
      end

      result.succeed!(output_string)
    end
  end
end

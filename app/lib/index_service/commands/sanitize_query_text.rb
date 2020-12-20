module IndexService::Commands
  class SanitizeQueryText < Command::Base::Abstract
    def initialize(input_string)
      super()
      @input_string = input_string
    end

    def run_proc
      output_string = @input_string.tap do |str|
        str.strip! # Remove leadinga and trailing whitespace
        str.downcase! # Only use lowercase characters
        str.gsub!(/\s+/, " ") # Replace inner substrings of whitespace with single space
        str.gsub!(/[^a-zA-Z0-9]/, "") # Keep only alphanumeric characters, in English (for now?)
      end
      output_string = nil if output_string.blank?

      result.succeed!(output_string)
    end
  end
end

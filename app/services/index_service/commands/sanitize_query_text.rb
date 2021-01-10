module IndexService::Commands
  class SanitizeQueryText < Command::Abstract
    def initialize(input_string)
      super()
      @input_string = input_string
    end

    def run_proc
      output_string = @input_string.tap do |str|
        str.strip! # Remove leading and trailing whitespace
        str.downcase! # Only use lowercase characters
        str.gsub!(/[^\w\s]/, "") # Keep only alphanumeric characters, in English (for now?)
        str.gsub!(/\ba\b|\bor\b|\ban\b|\bthe\b|\band\b|\bof\b/, "") # Remove silly words. TODO: do this a better way
        str.gsub!(/\s+/, " ") # Replace inner substrings of whitespace with single space
      end

      result.succeed!(output_string)
    end
  end
end

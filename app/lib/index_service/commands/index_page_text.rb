module IndexService::Commands
  class IndexPageText < Command::Abstract
    def initialize(page, input_string, kind, max_length, max_distance)
      super()
      @page = page
      @input_string = input_string
      @kind = kind
      @max_distance = max_distance
      @max_length = max_length
    end

    def run_proc
      words_array = sanitized_words
      return if words_array.blank?

      attributes = prepare_page_match_attributes(words_array)
      insert_queries_and_page_matches(attributes)

      result.succeed!
    end

    private

    def sanitized_words
      command = SanitizeQueryText.new(@input_string)
      command.run!
      command.payload.split(" ")
    end

    def prepare_page_match_attributes(words_array)
      command = PreparePageMatchAttributes.new(@page.id, words_array, @kind, @max_distance, @max_length)
      command.run!
      command.payload
    end

    def insert_queries_and_page_matches(attributes)
      command = InsertQueriesAndPageMatches.new(attributes)
      command.run_with_gc!
    end
  end
end

module Command
  class Search < Command::Base::Abstract
    def initialize(text)
      super()
      @text = text.downcase
    end

    def run_proc
      matches_array = []
      text_words = @text.split(/\s/)

      matches_array << @text
      matches_array.concat(text_words)
      matches_array.concat(text_words.map {|w| "%#{w}%"})

      result.succeed!(Page.for_query_text(matches_array).by_links_from_count)
    end
  end
end
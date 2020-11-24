module Command
  class Search < Command::Base::Abstract
    def initialize(text)
      super()
      @text = text.downcase
    end

    def run_proc
      matches_set = Set.new
      text_words = @text.split(/\s/)

      matches_set << @text
      matches_set.merge(text_words)
      matches_set.merge(text_words.map {|w| "%#{sanitize_sql_like(w)}%"})

      result.succeed!(Page.for_query_text(matches_set.to_a).by_links_from_count)
    end
  end
end
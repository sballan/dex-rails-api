module Command
  class SearchDb < Command::Base::Abstract
    def initialize(text, results_count=20)
      super()
      @text = text.downcase
      @results_count = results_count
    end

    def run_proc
      matches_set = Set.new
      text_words = @text.split(/\s/)

      matches_set << @text
      matches_set.merge(text_words)
      matches_set.merge(text_words.map {|w| "%#{ActiveRecord::Base.send(:sanitize_sql_like, w)}%"})

      pages = Page.for_query_text(matches_set.to_a).by_links_from_count.limit(@results_count)
      result.succeed!(pages)
    end
  end
end
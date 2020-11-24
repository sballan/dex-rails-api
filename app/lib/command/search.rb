module Command
  class Search < Command::Base::Abstract
    def initialize(text)
      super()
      @text = text
    end

    def run_proc
      full_text = @text
      text_words = @text.split(/\s/).map {|w| "%#{w}%"}
      text_words << full_text
      Query.includes(:result).where(Query.arel_table[:text].matches_any(text_words))
    end
  end
end
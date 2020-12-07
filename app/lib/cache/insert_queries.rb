module Cache
  class InsertQueries < Command::Base::Abstract
    def initialize(query_texts)
      super()
      @query_texts = query_texts
    end

    def run_proc
      insert_queries
      query_ids = pluck_query_ids

      result.succeed!(query_ids)
    end

    private

    def insert_queries
      Query.insert_all(@query_texts.map {|qt| {text: qt} })
    end

    def pluck_query_ids
      Query.where(text: @query_texts).pluck(:id)
    end
  end
end

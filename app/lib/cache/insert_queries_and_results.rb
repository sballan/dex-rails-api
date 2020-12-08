module Cache
  class InsertQueriesAndResults < Command::Base::Abstract
    VALID_ATTRIBUTES = Set.new(%i[text page_id kind])

    def initialize(attributes)
      super()
      @attributes = attributes
    end

    def run_proc
      validate_attributes

      db_query_atts = insert_queries
      result_atts = @attributes.map do |att|
        {
          query_id: db_query_atts[att[:text]],
          page_id: att[:page_id],
          kind: att[:kind],
          created_at: DateTime.now.utc,
          updated_at: DateTIme.now.utc
        }
      end

      insert_results(result_atts)

      query_ids = result_atts.map {|att| att[:query_id] }
      result.succeed!(query_ids)
    end

    private

    def validate_attributes
      @attributes.each do |att|
        att_keys = Set.new(att.keys)
        raise "Invalid key" unless att_keys == VALID_ATTRIBUTES
      end
    end

    def insert_queries
      query_atts = @attributes.map do |att|
        {
          text: att[:text],
          created_at: DateTime.now.utc,
          updated_at: DateTIme.now.utc
        }
      end
      Query.insert_all(query_atts, unique_by: :index_queries_on_text)
      db_query_atts = Query.where(query_atts).pluck(:text, :id)
      db_query_atts.to_h # Hash {text => id}
    end

    def insert_results(result_atts)
      Result.insert_all(result_atts, unique_by: :index_results_on_query_id_and_page_id_and_kind)
    end
  end
end

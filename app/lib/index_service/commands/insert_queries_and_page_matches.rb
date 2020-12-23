module IndexService::Commands
  class InsertQueriesAndPageMatches < Command::Base::Abstract
    VALID_ATTRIBUTES = Set.new(%i[query_text page_id kind full distance length])

    def initialize(attributes)
      super()
      @attributes = attributes
    end

    def run_proc
      validate_attributes
      # sanitize_attributes

      db_query_atts = insert_queries
      page_match_atts = @attributes.map do |att|
        {
          query_id: db_query_atts[att[:query_text]],
          page_id: att[:page_id],
          kind: att[:kind],
          full: att[:full],
          distance: att[:distance],
          length: att[:length],
          created_at: DateTime.now.utc,
          updated_at: DateTime.now.utc
        }
      end

      insert_page_matches(page_match_atts)

      result.succeed!
    end

    private

    def validate_attributes
      @attributes.each do |att|
        att_keys = Set.new(att.keys)
        raise "Invalid key" unless att_keys == VALID_ATTRIBUTES
      end
    end

    # def sanitize_attributes
    #   @attributes.each do |att|
    #     # TODO: put this business rule in a better spot?
    #     att[:text] = att[:text].downcase[0..999]
    #   end
    # end

    def insert_queries
      query_atts = @attributes.map do |att|
        {
          text: att[:query_text],
          created_at: DateTime.now.utc,
          updated_at: DateTime.now.utc
        }
      end
      Query.insert_all(query_atts, unique_by: :index_queries_on_text)
      db_query_atts = Query.where(text: query_atts.map {|att| att[:text]} ).pluck(:text, :id)
      db_query_atts.to_h # Hash {text => id}
    end

    def insert_page_matches(page_match_atts)
      PageMatch.insert_all(page_match_atts, unique_by: :index_page_matches_on_query_page_kind_full_distance_length)
    end
  end
end

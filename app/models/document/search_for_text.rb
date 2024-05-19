class Document::SearchForText
  attr_reader :tokens, :proximity
  def initialize(text, proximity)
    @tokens = Term::Tokenizer.new(text).tokenize
    @proximity = proximity
  end

  def call
    terms_by_token = Term.where(term: @tokens).index_by(&:term)
    term_ids = @tokens.map { |token| terms_by_token[token]&.id }.compact
    return [] if term_ids.size < 1

    # Start building the SQL query
    query = <<~SQL
      SELECT DISTINCT p1.document_id
      FROM postings p1
    SQL
    conditions = []
    joins = []

    term_ids.each_with_index do |term_id, index|
      if index > 0
        joins << <<~SQL
          JOIN postings p#{index + 1} ON p#{index}.document_id = p#{index + 1}.document_id
            AND p#{index + 1}.position > p#{index}.position
            AND p#{index + 1}.position <= p#{index}.position + ?
        SQL
      end
      conditions << "p#{index + 1}.term_id = ?"
    end

    query += " " + joins.join(" ") + " WHERE " + conditions.join(" AND ")

    query += " \n" + "LIMIT 1000"

    # Prepare the parameters
    proximity_params = Array.new(term_ids.size - 1, proximity)
    term_params = term_ids

    result = Posting.find_by_sql([query, *proximity_params, *term_params])
    Document.where(id: result.map(&:document_id))
  end
end

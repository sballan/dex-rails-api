class Document::SearchForTerms
  attr_reader :terms, :proximity
  def initialize(terms, proximity)
    @terms = terms
    @proximity = proximity
  end

  def call
    term_ids = Term.where(term: terms).pluck(:id)
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

    # Prepare the parameters
    proximity_params = Array.new(term_ids.size - 1, proximity)
    term_params = term_ids

    result = Posting.find_by_sql([query, *proximity_params, *term_params])
    Document.where(id: result.map(&:document_id))
  end
end

class Term::CreateFromText
  attr_reader :text, :terms, :positions_map

  def initialize(text)
    @text = text
    @terms = nil
    @positions_map = nil
  end

  def create_terms
    tokens = token_positions.keys

    existing_terms = Term.where(term: tokens).index_by(&:term)
    new_terms = tokens - existing_terms.keys

    return existing_terms if new_terms.empty?

    Term.insert_all(new_terms.map { |term| {term: term} })
    @terms = existing_terms.values + Term.where(term: new_terms)

    raise("Some terms were not created") unless @terms.size == token_positions.size

    @positions_map = {}
    @terms.each do |term|
      @positions_map[term.id] = token_positions[term.term]
    end
  end

  private

  def token_positions
    token_positions = {}
    Term::Tokenizer.new(text).tokenize.each_with_index do |token, index|
      token_positions[token] ||= []
      token_positions[token] << index
    end
    token_positions
  end
end

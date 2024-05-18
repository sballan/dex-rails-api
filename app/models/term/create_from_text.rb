class Term::CreateFromText
  attr_reader :text, :term_positions

  def initialize(text)
    @text = text
    @term_positions = nil
  end

  def create_terms
    tokens = token_positions.keys

    existing_terms = Term.where(term: tokens).index_by(&:term)
    new_terms = tokens - existing_terms.keys

    return existing_terms if new_terms.empty?

    Term.insert_all(new_terms.map { |term| {term: term} })
    terms = existing_terms.values + Term.where(term: new_terms).to_a
    @term_positions = terms.index_by(&:term)

    terms
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

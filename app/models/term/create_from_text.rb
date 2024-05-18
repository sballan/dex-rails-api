class Term::CreateFromText
  attr_reader :text
  def initialize(text)
    @text = text
  end

  def call(text)
    tokens = Term::Tokenizer.new(text).tokenize

    existing_terms = Term.where(term: tokens).index_by(&:term)
    new_terms = tokens - existing_terms.keys

    return existing_terms if new_terms.empty?

    Term.insert_all(new_terms.map { |term| {term: term} })
    existing_terms.values + Term.where(term: new_terms)
  end
end

class Document::CreateFromText
  attr_reader :text

  def initialize(text)
    @text = text
  end

  def process_and_persist
    terms_hash = tokenize(text)
    term_records = find_or_create_terms(terms_hash.keys)
    postings_attributes = build_postings_attributes(term_records, terms_hash)
    bulk_insert_postings(postings_attributes)
  end

  private

  def tokenize(text)
    terms_hash = {}
    words = text.downcase.scan(/\w+/)
    words.each_with_index do |term, position|
      terms_hash[term] ||= []
      terms_hash[term] << position
    end
    terms_hash
  end

  def find_or_create_terms(terms)
    existing_terms = Term.where(term: terms).index_by(&:term)
    new_terms = terms - existing_terms.keys

    if new_terms.any?
      new_term_records = Term.insert_all(new_terms.map { |term| {term: term, created_at: Time.now, updated_at: Time.now} }, returning: %w[id term])
      new_term_records.rows.each do |row|
        existing_terms[row[1]] = Term.new(id: row[0], term: row[1])
      end
    end

    existing_terms
  end

  def build_postings_attributes(term_records, terms_hash)
    postings_attributes = []
    terms_hash.each do |term, positions|
      term_id = term_records[term].id
      positions.each do |position|
        postings_attributes << {document_id: document.id, term_id: term_id, position: position, created_at: Time.now, updated_at: Time.now}
      end
    end
    postings_attributes
  end

  def bulk_insert_postings(postings_attributes)
    Posting.insert_all(postings_attributes)
  end
end

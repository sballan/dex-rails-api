class Document::CreateFromText
  attr_reader :text, :document

  def initialize(text)
    @text = text
    @document = nil
  end

  def process_and_persist
    term_creator = Term::CreateFromText.new(text)
    term_creator.create_terms

    @document = Document.create!

    postings_creator = Posting::CreateFromDocumentAndPositionsMap.new(@document, term_creator.positions_map)
    postings_creator.bulk_insert_postings
  end
end

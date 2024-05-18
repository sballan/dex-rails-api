class Posting::CreateFromDocumentAndPositionsMap
  def initialize(document, positions_map)
    @document = document
    @positions_map = positions_map
  end

  def bulk_insert_postings
    Posting.insert_all(build_postings_attributes)
  end

  def build_postings_attributes
    postings_attributes = []
    @positions_map.each do |term_id, positions|
      positions.each do |position|
        postings_attributes << {
          document_id: @document.id,
          term_id: term_id,
          position: position,
          created_at: Time.now,
          updated_at: Time.now
        }
      end
    end
    postings_attributes
  end
end

class SiteScraper::Matcher
  class Matcher < StandardError
  end

  class PermanentFailure < Matcher
  end

  class TemporaryFailure < Matcher
  end

  VALID_ATTRIBUTES = Set.new(%i[query_text page_id kind full distance length])

  # @param [Integer] page_id ID of the Page this PageMatch is on
  # @param [Array<String>] words_array A list of words that has been sanitized/processed
  # @param [Integer] max_distance Upper bound on skipped words in query/page_match. If nil, defaults to length of words_array
  # @param [Integer] max_length Upper bound on total words used in query/page_match. If nil, defaults to length of words_array
  def initialize(page_id, words_array, kind, max_distance, max_length)
    @page_id = page_id
    @words_array = words_array
    @kind = kind
    @max_distance = [max_distance, [0, words_array.size - 2].max].min
    @max_length = [max_length, words_array.size].min
    @attributes = nil
  end

  def create_matches
    attributes = create_page_match_attributes
    validate_attributes(attributes)
    # sanitize_attributes

    db_query_atts = insert_queries(attributes)
    db_page_match_atts = attributes.map do |att|
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

    insert_page_matches(db_page_match_atts)
  end

  private

  def validate_attributes(attributes)
    attributes.each do |att|
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

  def insert_queries(attributes)
    query_atts = attributes.map do |att|
      {
        text: att[:query_text],
        created_at: DateTime.now.utc,
        updated_at: DateTime.now.utc
      }
    end
    Query.insert_all(query_atts, unique_by: :index_queries_on_text)
    db_query_atts = Query.where(text: query_atts.map { |att| att[:text] }).pluck(:text, :id)
    db_query_atts.to_h # Hash {text => id}
  end

  def insert_page_matches(page_match_atts)
    PageMatch.insert_all(page_match_atts, unique_by: :index_page_matches_on_query_page_kind_full_distance_length)
  end

  def create_page_match_attributes
    skip_sequences = generate_skip_sequences

    matches = skip_sequences.map do |sequence|
      generate_matches(sequence)
    end

    matches.flatten!
  end

  #  This crazy method gets us every combination of skip sequences given our parameters...!
  #  This will be used to create all uniq query strings.  We may need to reuse this when making page matches?
  def generate_skip_sequences
    skip_sequences = Set.new
    (1..@max_length).each do |length|
      (0..@max_distance).each do |distance|
        false_values = [false] * length
        true_values = [true] * distance
        permutations = (false_values + true_values).permutation
        skip_sequences.merge(permutations)
      end
    end

    skip_sequences.reject! do |sequence|
      sequence.first == true || sequence.last == true
    end

    skip_sequences.to_a
  end

  # @param [Array<Boolean>] skip_sequence Represents the number of skips between words.
  #                                       For instance, [false, true] would mean the first word was not skipped,
  #                                       but the second word was skipped.  The length of this match is the number
  #                                       of true values.
  def generate_matches(skip_sequence)
    matches = []
    base_index = 0
    full_match_string = @words_array.join(" ")
    while (base_index + skip_sequence.size) <= @words_array.size
      current_match_array = []
      skip_sequence.each_with_index do |skip, index|
        next if skip
        current_match_array << @words_array[base_index + index]
      end

      query_text = current_match_array.join(" ")
      full = query_text == full_match_string

      matches << {
        page_id: @page_id,
        query_text: query_text,
        full: full,
        kind: @kind,
        distance: skip_sequence.count(true),
        length: skip_sequence.count(false)
      }

      base_index += 1
    end

    matches
  end
end

module IndexService::Commands
  class GenerateQueryPageMatchMap < Command::Base::Abstract
    VALID_ATTRIBUTES = Set.new(%i[text page_id kind])

    # @param [Array<String>] words_array A list of words that has been sanitized/processed
    # @param [Integer] max_distance Upper bound on skipped words in query/page_match
    # @param [Integer] max_length Upper bound on total words used in query/page_match
    def initialize(words_array, max_distance, max_length)
      super()
      @words_array = words_array
      @max_distance = max_distance
      @max_length = max_length
    end

    def run_proc
      skip_sequences = generate_skip_sequences
      matches = generate_matches(skip_sequences)

      result.succeed!(query_ids)
    end

    private

    #  This crazy method gets us every combination of skip sequences given our parameters...!
    #  This will be used to create all uniq query strings.  We may need to reuse this when making page matches?
    def generate_skip_sequences
      skip_sequences = []
      (1..@max_length).each do |length|
        (0..@max_distance).each do |distance|
          false_values = [false] * length
          true_values = [true] * distance
          permutations = (false_values + true_values).permutation.to_a
          skip_sequences.concat(permutations)
        end
      end
    end

    # @param [Array<Boolean>] skip_sequence Represents the number of skips between words.
    #                                       For instance, [false, true] would mean the first word was not skipped,
    #                                       but the second word was skipped.  The length of this match is the number
    #                                       of true values.
    def generate_matches(skip_sequence)
      matches = []
      base_index = 0
      while(base_index + skip_sequence.size) <= @words_array.size do
        current_match_array = []
        skip_sequence.each_with_index do |skip, index|
          next if skip
          current_match_array << @words_array[base_index + index]
        end

        matches << {
          match_string: current_match_array.join(" "),
          skip_sequence: skip_sequence,
          distance: skip_sequence.count(true),
          length: skip_sequence.size
        }

        base_index += 1
      end

      matches
    end

    def validate_attributes
      @attributes.each do |att|
        att_keys = Set.new(att.keys)
        raise "Invalid key" unless att_keys == VALID_ATTRIBUTES
      end
    end

    def sanitize_attributes
      @attributes.each do |att|
        # TODO: put this business rule in a better spot?
        att[:text] = att[:text].downcase[0..999]
      end
    end

    def insert_queries
      query_atts = @attributes.map do |att|
        {
          text: att[:text],
          created_at: DateTime.now.utc,
          updated_at: DateTime.now.utc
        }
      end
      Query.insert_all(query_atts, unique_by: :index_queries_on_text)
      db_query_atts = Query.where(text: query_atts.map {|att| att[:text]} ).pluck(:text, :id)
      db_query_atts.to_h # Hash {text => id}
    end

    def insert_results(result_atts)
      Result.insert_all(result_atts, unique_by: :index_results_on_query_id_and_page_id_and_kind)
    end
  end
end

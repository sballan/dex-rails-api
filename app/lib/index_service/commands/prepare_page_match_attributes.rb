module IndexService::Commands
  class PreparePageMatchAttributes < Command::Base::Abstract
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

      matches = skip_sequences.map do |sequence|
        generate_matches(sequence)
      end

      matches.flatten!

      result.succeed!(matches)
    end

    private

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
          length: skip_sequence.count(false)
        }

        base_index += 1
      end

      matches
    end
  end
end

require 'rails_helper'

describe IndexService::Commands::PreparePageMatchAttributes do
  context 'Basics' do
    it 'can be created with a words array, max_distance, and max_length' do
      words_array = ['myWord']
      max_distance = 0
      max_length = 1

      command = IndexService::Commands::PreparePageMatchAttributes.new(words_array, max_distance, max_length)
      expect(command).to be
    end
  end

  context 'Execution' do
     it 'can create a match for a single word' do
      words_array = ['myWord']
      max_distance = 0
      max_length = 1

      expected_results = [{
          distance: 0,
          length: 1,
          match_string: "myWord",
          skip_sequence: [false]
      }]

      command = IndexService::Commands::PreparePageMatchAttributes.new(words_array, max_distance, max_length)
      command.run!
      expect(command.payload).to eql(expected_results)
    end
  end
end

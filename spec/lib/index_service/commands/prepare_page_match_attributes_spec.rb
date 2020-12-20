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

     it 'can create a match for a two words' do
       words_array = ['myWord', 'myOtherWord']
       max_distance = 0
       max_length = 2

       expected_results = [
         {
           distance: 0, length: 1, match_string: "myWord", skip_sequence: [false]
         },
         {
           distance: 0, length: 1, match_string: "myOtherWord", skip_sequence: [false]
         },
         {
           distance: 0, length: 2,  match_string: "myWord myOtherWord", skip_sequence: [false, false]
         }
       ]

       command = IndexService::Commands::PreparePageMatchAttributes.new(words_array, max_distance, max_length)
       command.run!
       expect(command.payload).to eql(expected_results)
     end

     it 'can create a match for a three words with distance 1' do
       words_array = ['myWord', 'myOtherWord', 'myLastWord']
       max_distance = 1
       max_length = 3

       expected_results = [
         {
           distance: 0, length: 1, match_string: "myWord", skip_sequence: [false]
         },
         {
           distance: 0, length: 1, match_string: "myOtherWord", skip_sequence: [false]
         },
         {
           distance: 0, length: 1, match_string: "myLastWord", skip_sequence: [false]
         },
         {
           distance: 0, length: 2, match_string: "myWord myOtherWord", skip_sequence: [false, false]
         },
         {
           distance: 0, length: 2, match_string: "myOtherWord myLastWord", skip_sequence: [false, false]
         },
         {
           distance: 1, length: 2, match_string: "myWord myLastWord", skip_sequence: [false, true, false]
         },
         {
           distance: 0, length: 3, match_string: "myWord myOtherWord myLastWord", skip_sequence: [false, false, false]
         }
       ]

       command = IndexService::Commands::PreparePageMatchAttributes.new(words_array, max_distance, max_length)
       command.run!
       expect(command.payload).to eql(expected_results)
     end
  end
end

require 'rails_helper'

describe Command::CreateOrFindQuery do
  context 'Basics' do
    it 'can be instantiated with text' do
      command = Command::CreateOrFindQuery.new "My Query Text"
      expect(command).to be
    end
  end

  context 'Execution' do
    let(:command) { Command::CreateOrFindQuery.new "My Other Query Text" }

    it 'can run successfully' do
      command.run
      expect(command).to be_success
    end
  end
end

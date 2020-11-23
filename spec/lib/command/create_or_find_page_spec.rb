require 'rails_helper'

describe Command::CreateOrFindPage do
  context 'Basics' do
    it 'can be instantiated with a url' do
      command = Command::CreateOrFindPage.new "https://www.wikipedia.org"
      expect(command).to be
    end
  end

  context 'Execution' do
    let(:command) { Command::CreateOrFindPage.new "https://www.wikipedia.org" }

    it 'can run successfully' do
      command.run
      expect(command).to be_success
    end
  end
end

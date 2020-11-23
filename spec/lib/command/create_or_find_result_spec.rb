require 'rails_helper'

describe Command::CreateOrFindResult do
  before(:example) do
    @query = Query.create text: "My Other Query Text"
    @page = Page.create url: "https://www.my_page.com"
    @kind = 'title'
  end

  context 'Basics' do
    it 'can be instantiated with a query, page, and kind' do
      command = Command::CreateOrFindResult.new @query, @page, @kind
      expect(command).to be
    end
  end

  context 'Execution' do
    let(:command) { Command::CreateOrFindResult.new @query, @page, @kind }

    it 'can run successfully' do
      command.run
      expect(command).to be_success
    end
  end
end

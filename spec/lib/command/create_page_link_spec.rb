require 'rails_helper'

describe Command::CreatePageLink do
  before(:example) do
    @page_from = Page.create url: "https://www.my_page.com"
    @url = "https://page_to.com"
    @text = 'My Link Text'
  end

  context 'Basics' do
    it 'can be instantiated with a page_from, url and text' do
      command = Command::CreatePageLink.new @page_from, @url, @text
      expect(command).to be
    end
  end

  context 'Execution' do
    let(:command) { Command::CreatePageLink.new @page_from, @url, @text }

    it 'can run successfully' do
      command.run
      expect(command).to be_success
    end
  end
end

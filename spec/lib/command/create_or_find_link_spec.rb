require 'rails_helper'

describe Command::CreateOrFindLink do
  before(:example) do
    @from_page = Page.create url: "https://www.from_page.com"
    @to_page = Page.create url: "https://www.to_page.com"
    @url = "https://my_url.com"
  end

  context 'Basics' do
    it 'can be instantiated with a from_page, to_page, and url' do
      command = Command::CreateOrFindLink.new @from_page.id, @to_page.id, @url
      expect(command).to be
    end
  end

  context 'Execution' do
    it 'can run successfully' do
      command = Command::CreateOrFindLink.new @from_page.id, @to_page.id, @url
      command.run
      expect(command).to be_success
    end

    it 'can run without errors' do
      command = Command::CreateOrFindLink.new @from_page.id, @to_page.id, @url
      command.run!
      expect(command).to be_success
    end

    it 'can fail with a bad page id' do
      command = Command::CreateOrFindLink.new @from_page.id, "not a page id", @url
      command.run
      expect(command).to be_failure
    end
  end
end

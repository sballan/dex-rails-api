require 'rails_helper'

RSpec.describe Site, type: :model do
  context 'Basics' do
    before(:example) do
      home_url = 'http://www.test_page.com'
      host = 'www.test_page.com'
      @site = Site.create(home_url: home_url, host: host)
    end

    it 'can be created with a home_url and host' do
      expect(@site).to be_truthy
    end
  end
end

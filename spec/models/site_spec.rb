# == Schema Information
#
# Table name: sites
#
#  id                     :integer          not null, primary key
#  home_url               :string           not null
#  host                   :string           not null
#  refresh_job_started_at :datetime
#  scrape_active          :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  refresh_job_id         :string
#
# Indexes
#
#  index_sites_on_home_url  (home_url) UNIQUE
#  index_sites_on_host      (host) UNIQUE
#
require "rails_helper"

RSpec.describe Site, type: :model do
  context "Basics" do
    before(:example) do
      home_url = "http://www.test_page.com"
      host = "www.test_page.com"
      @site = Site.create(home_url: home_url, host: host)
    end

    it "can be created with a home_url and host" do
      expect(@site).to be_truthy
    end
  end
end

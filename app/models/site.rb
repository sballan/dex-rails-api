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
class Site < ApplicationRecord
  validates_presence_of :home_url, :host

  def fetch_pages
    Page.by_site(self)
  end

  def fetch_home_page
    Page.find_by_url home_url
  end
end

class Site < ApplicationRecord
  validates_presence_of :home_url, :host

  scope :for_page, ->(page) {
    Site.find_by_host URI(page.url).host
  }

  def fetch_pages
    Page.by_site(self)
  end

  def fetch_home_page
    Page.find_by_url home_url
  end
end

class Site < ApplicationRecord
  validates_presence_of :home_url, :host

  scope :for_page, ->(page) {
    Site.find_by_host URI(page.url).host
  }
end
